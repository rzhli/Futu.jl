module Connection

using Sockets
using Logging
using SHA
using ProtoBuf
using Base64
using Base.Threads: Atomic, atomic_add!
using Crayons
using Printf
import ProtoBuf as PB

using ..Errors
using ..Encryption
using ..AllProtos
using ..AllProtos.Common
using ..Constants: PROTO_RESPONSE_MAP, PROTO_PUSH_MAP, InitConnect, GetGlobalState, GetDelayStatistics, GetUserInfo, KeepAlive, UserInfoField,
                   INIT_CONNECT, GET_GLOBAL_STATE, KEEPALIVE, GET_DELAY_STATISTICS, GET_USER_INFO

export OpenDConnection, request_sync

# Display styles
const HEADER_STYLE = Crayon(foreground=:cyan, bold=true)
const LABEL_STYLE = Crayon(foreground=:white, bold=true)
const VALUE_STYLE = Crayon(foreground=:white)
const GOOD_STYLE = Crayon(foreground=:green, bold=true)
const BAD_STYLE = Crayon(foreground=:red, bold=true)
const DIM_STYLE = Crayon(foreground=:light_gray)

const DEFAULT_HOST = "127.0.0.1"
const DEFAULT_PORT = 11111
const PROTO_HEADER_SIZE = 44

# Protocol header structure
struct ProtoHeader
    header_flag::Vector{UInt8}  # 'F' 'T' (2 bytes)
    proto_id::UInt32            # Protocol ID (4 bytes)
    proto_fmt_type::Common.ProtoFmt.T      # Protocol format type (1 byte)
    proto_ver::UInt8            # Protocol version (1 byte)
    serial_no::UInt32           # Serial number (4 bytes)
    body_len::UInt32            # Body length (4 bytes)
    body_sha1::Vector{UInt8}    # SHA1 hash of body (20 bytes)
    reserved::Vector{UInt8}     # Reserved (8 bytes)
end

# Create protocol header
function ProtoHeader(proto_id::UInt32, body_len::UInt32, serial_no::UInt32 = 0)
    ProtoHeader(
        UInt8['F', 'T'],
        proto_id,
        Common.ProtoFmt.Protobuf,
        UInt8(0),
        serial_no,
        body_len,
        zeros(UInt8, 20),
        zeros(UInt8, 8)
    )
end

# Serialize header to bytes
function serialize_header(header::ProtoHeader)::Vector{UInt8}
    buffer = IOBuffer()
    write(buffer, header.header_flag)
    write(buffer, htol(header.proto_id))
    write(buffer, UInt8(header.proto_fmt_type))
    write(buffer, header.proto_ver)
    write(buffer, htol(header.serial_no))
    write(buffer, htol(header.body_len))
    write(buffer, header.body_sha1)
    write(buffer, header.reserved)
    return take!(buffer)
end

# Deserialize header from bytes
function deserialize_header(buffer::Vector{UInt8})::ProtoHeader
    @assert length(buffer) >= PROTO_HEADER_SIZE "Invalid header size"
    @assert buffer[1:2] == UInt8['F','T'] "Invalid header flag"

    io = IOBuffer(buffer)
    skip(io, 2) # Skip 'FT'

    ProtoHeader(
        UInt8['F', 'T'],
        ltoh(read(io, UInt32)),
        Common.ProtoFmt.T(read(io, UInt8)),
        read(io, UInt8),
        ltoh(read(io, UInt32)),
        ltoh(read(io, UInt32)),
        read(io, 20),
        read(io, 8)
    )
end

# Response message types
struct ResponsePacket
    serial_no::UInt32
    proto_id::UInt32
    data::Vector{UInt8}
end

struct ResponseResult
    success::Bool
    data::Any
    error::Union{Exception, Nothing}
end

# OpenD connection manager (Julia style with Channels)
mutable struct OpenDConnection
    host::String
    port::Int
    socket::Union{TCPSocket, Nothing}
    connected::Bool
    serial_no::Atomic{UInt32}
    rsa_private_key_path::String
    packet_enc_algo::Common.PacketEncAlgo.T

    # Connection info from InitConnect
    server_ver::Int32
    login_user_id::UInt64
    conn_id::UInt64
    conn_aes_key::String
    conn_aes_iv::String
    keep_alive_interval::Int32
    last_keep_alive::Atomic{Float64}
    
    # Julia-style: Use Channels for communication
    response_channel::Channel{ResponsePacket}  # Receive task -> Request handlers
    push_channel::Channel{ResponsePacket}      # Receive task -> Push handlers
    pending_requests::Dict{UInt32, Channel{ResponseResult}}  # serial_no -> result channel
    request_lock::ReentrantLock  # Only for pending_requests dict
    
    # Background tasks
    receive_task::Union{Task, Nothing}
    keepalive_task::Union{Task, Nothing}

    function OpenDConnection(host::String = DEFAULT_HOST, port::Int = DEFAULT_PORT; rsa_private_key_path::String="")
        default_algo = !isempty(rsa_private_key_path) ? Common.PacketEncAlgo.FTAES_ECB : Common.PacketEncAlgo.None
        new(host, port, nothing, false, Atomic{UInt32}(0), rsa_private_key_path, default_algo, Int32(0), UInt64(0), 
        UInt64(0), "", "", Int32(10), Atomic{Float64}(0.0), Channel{ResponsePacket}(100), Channel{ResponsePacket}(100),
        Dict{UInt32, Channel{ResponseResult}}(), ReentrantLock(), nothing, nothing
        )
    end
end

function Base.show(io::IO, conn::OpenDConnection)
    # Header
    println(io, HEADER_STYLE("OpenDConnection"))
    println(io, HEADER_STYLE("═══════════════"))
    println(io)

    # Connection status
    connected = is_connected(conn)
    status_icon = connected ? GOOD_STYLE(" ✓ ") : BAD_STYLE(" ✗ ")
    status_text = connected ? GOOD_STYLE("Connected") : BAD_STYLE("Disconnected")
    println(io, LABEL_STYLE("  Status        : "), status_icon, status_text)

    # Basic connection info
    println(io, LABEL_STYLE("  Host          : "), VALUE_STYLE(conn.host))
    println(io, LABEL_STYLE("  Port          : "), VALUE_STYLE(string(conn.port)))

    if !isempty(conn.rsa_private_key_path)
        println(io, LABEL_STYLE("  RSA Key       : "), DIM_STYLE(conn.rsa_private_key_path))
    end

    # Packet encryption
    enc_algo_str = if conn.packet_enc_algo == Common.PacketEncAlgo.None
        "None"
    elseif conn.packet_enc_algo == Common.PacketEncAlgo.AES_ECB
        "AES-ECB"
    elseif conn.packet_enc_algo == Common.PacketEncAlgo.FTAES_ECB
        "FTAES-ECB"
    elseif conn.packet_enc_algo == Common.PacketEncAlgo.AES_CBC
        "AES-CBC"
    else
        "Unknown"
    end
    println(io, LABEL_STYLE("  Encryption    : "), VALUE_STYLE(enc_algo_str))

    println(io)

    if connected
        # Server information
        println(io, LABEL_STYLE("  Server Info:"))
        println(io, "    ", LABEL_STYLE("Version     : "), VALUE_STYLE(string(conn.server_ver)))
        println(io, "    ", LABEL_STYLE("User ID     : "), VALUE_STYLE(string(conn.login_user_id)))
        println(io, "    ", LABEL_STYLE("Conn ID     : "), VALUE_STYLE(@sprintf("0x%016X", conn.conn_id)))

        println(io)

        # Encryption keys (if available)
        if !isempty(conn.conn_aes_key)
            println(io, LABEL_STYLE("  Session Keys:"))
            println(io, "    ", LABEL_STYLE("AES Key     : "), DIM_STYLE(conn.conn_aes_key))
            println(io, "    ", LABEL_STYLE("AES IV      : "), DIM_STYLE(conn.conn_aes_iv))
            println(io)
        end

        # Keep-alive information
        println(io, LABEL_STYLE("  Keep-Alive:"))
        println(io, "    ", LABEL_STYLE("Interval    : "), VALUE_STYLE(string(conn.keep_alive_interval), " seconds"))

        last_ka = conn.last_keep_alive[]
        if last_ka > 0
            time_since = round(time() - last_ka, digits=1)
            ka_status = time_since < conn.keep_alive_interval ? GOOD_STYLE("✓") : BAD_STYLE("⚠")
            println(io, "    ", LABEL_STYLE("Last Sent   : "), ka_status, " ",
                    DIM_STYLE(string(time_since), " seconds ago"))
        end

        println(io)
    end

    # Background tasks status
    println(io, LABEL_STYLE("  Background Tasks:"))

    # Receive task
    if conn.receive_task !== nothing
        recv_status = istaskdone(conn.receive_task) ? BAD_STYLE(" ✗ Done") :
                     istaskfailed(conn.receive_task) ? BAD_STYLE(" ✗ Failed") :
                     GOOD_STYLE(" ✓ Running")
        println(io, "    ", LABEL_STYLE("Receive     : "), recv_status)
    else
        println(io, "    ", LABEL_STYLE("Receive     : "), DIM_STYLE(" ✗ Not Started"))
    end

    # Keep-alive task
    if conn.keepalive_task !== nothing
        ka_task_status = istaskdone(conn.keepalive_task) ? BAD_STYLE(" ✗ Done") :
                        istaskfailed(conn.keepalive_task) ? BAD_STYLE(" ✗ Failed") :
                        GOOD_STYLE(" ✓ Running")
        println(io, "    ", LABEL_STYLE("Keep-Alive  : "), ka_task_status)
    else
        println(io, "    ", LABEL_STYLE("Keep-Alive  : "), DIM_STYLE(" ✗ Not Started"))
    end

    println(io)

    # Channels status
    println(io, LABEL_STYLE("  Channels:"))

    # Response channel
    resp_open = isopen(conn.response_channel)
    resp_ready = isready(conn.response_channel)
    resp_status = resp_open ? GOOD_STYLE(" ✓ Open") : BAD_STYLE(" ✗ Closed")
    resp_info = resp_ready ? DIM_STYLE(" (", string(length(conn.response_channel.data)), " pending)") : DIM_STYLE(" (empty)")
    println(io, "    ", LABEL_STYLE("Response    : "), resp_status, resp_info)

    # Push channel
    push_open = isopen(conn.push_channel)
    push_ready = isready(conn.push_channel)
    push_status = push_open ? GOOD_STYLE(" ✓ Open") : BAD_STYLE(" ✗ Closed")
    push_info = push_ready ? DIM_STYLE(" (", string(length(conn.push_channel.data)), " pending)") : DIM_STYLE(" (empty)")
    println(io, "    ", LABEL_STYLE("Push        : "), push_status, push_info)

    println(io)

    # Pending requests
    pending_count = lock(conn.request_lock) do
        length(conn.pending_requests)
    end

    println(io, LABEL_STYLE("  Pending Requests: "),
            pending_count > 0 ? VALUE_STYLE(string(pending_count)) : DIM_STYLE("0"))
end

# Get next serial number (using atomic operation)
function get_next_serial_no(conn::OpenDConnection)::UInt32
    return atomic_add!(conn.serial_no, UInt32(1)) + UInt32(1)
end

# Connect to OpenD
function connect!(conn::OpenDConnection)
    if conn.connected
        @warn "Already connected to OpenD"
        return true
    end

    try
        conn.socket = Sockets.connect(conn.host, conn.port)
        conn.connected = true
        conn.serial_no[] = UInt32(0)

        if !isopen(conn.response_channel)
            conn.response_channel = Channel{ResponsePacket}(100)
        else
            while isready(conn.response_channel)
                try
                    take!(conn.response_channel)
                catch
                    break
                end
            end
        end

        lock(conn.request_lock) do
            empty!(conn.pending_requests)
        end

        # Send InitConnect request
        c2s = InitConnect.C2S(
            310,
            "FutuAPI.jl_v1.0",
            true,
            conn.packet_enc_algo,
            Common.ProtoFmt.Protobuf,
            "Julia"
        )
        req = InitConnect.Request(c2s)

        # Serialize the body
        io = IOBuffer()
        PB.encode(ProtoEncoder(io), req)
        req_body_bytes = take!(io)

        # Calculate SHA1 on the UNENCRYPTED body (per protocol documentation)
        body_sha1 = sha1(req_body_bytes)

        # Encrypt body with RSA public key if private key is configured
        final_body_bytes = req_body_bytes
        if !isempty(conn.rsa_private_key_path)
            # Replace private.pem with public.pem to get public key path
            pub_key_path = replace(conn.rsa_private_key_path, "private.pem" => "public.pem")
            final_body_bytes = Encryption.encrypt_rsa(req_body_bytes, pub_key_path)
        end

        header = ProtoHeader(
            UInt32(INIT_CONNECT),
            UInt32(length(final_body_bytes)),
            get_next_serial_no(conn)
        )
        header.body_sha1 .= body_sha1

        packet = vcat(serialize_header(header), final_body_bytes)
        write(conn.socket, packet)

        # Receive InitConnect response
        header_buffer = read(conn.socket, PROTO_HEADER_SIZE)
        @assert length(header_buffer) >= PROTO_HEADER_SIZE "Invalid header size"
        resp_header = deserialize_header(header_buffer)
        
        body_bytes = read(conn.socket, resp_header.body_len)
        @assert length(body_bytes) >= resp_header.body_len "Invalid body size"
        
        # Decrypt RSA if configured
        resp_body = body_bytes
        if !isempty(conn.rsa_private_key_path)
            resp_body = Encryption.decrypt_rsa(body_bytes, conn.rsa_private_key_path)
        end
        
        # Verify SHA1
        calculated_sha1 = sha1(resp_body)
        @assert calculated_sha1 == resp_header.body_sha1 "SHA1 mismatch"

        # Parse response
        resp = nothing
        try
            resp = PB.decode(ProtoDecoder(IOBuffer(resp_body)), InitConnect.Response)
            # @info "InitConnect response: retType=$(resp.retType), retMsg='$(resp.retMsg)', errCode=$(resp.errCode)"
        catch e
            @error "Failed to parse InitConnect response" exception=(e, catch_backtrace())
            @error "Failed response data (hex): $(bytes2hex(resp_body))"
            rethrow(e)
        end
        
        if resp.retType != Common.RetType.Succeed
            throw(ConnectionError("Failed to initialize connection: retType=$(resp.retType), retMsg='$(resp.retMsg)', errCode=$(resp.errCode)"))
        end

        # Store connection info
        s2c = resp.s2c

        conn.server_ver = s2c.serverVer
        conn.login_user_id = s2c.loginUserID
        conn.conn_id = s2c.connID
        conn.conn_aes_key = s2c.connAESKey
        conn.conn_aes_iv = s2c.aesCBCiv
        conn.keep_alive_interval = s2c.keepAliveInterval
        conn.last_keep_alive[] = time()
        
        # @info "Connection info:" serverVer=conn.server_ver loginUserID=conn.login_user_id connID=conn.conn_id
        # @info "AES Key: $(conn.conn_aes_key), AES IV: $(conn.conn_aes_iv)"

        # Start background tasks for receiving responses and keep-alive
        start_receive_task(conn)
        start_keepalive_task(conn)

        # @info "Connected to OpenD: $(conn.host):$(conn.port)"
        return true
    catch e
        @error "Connection failed:" exception=(e, catch_backtrace())
        conn.connected = false
        conn.socket = nothing
        throw(ConnectionError("Failed to connect to OpenD: $e"))
    end
end

# Disconnect from OpenD
function disconnect!(conn::OpenDConnection)
    if !conn.connected return false end

    # Mark immediately to avoid re-entrant disconnects from background tasks
    conn.connected = false

    # Stop background tasks
    if conn.keepalive_task !== nothing && !istaskdone(conn.keepalive_task)
        schedule(conn.keepalive_task, InterruptException(), error=true)
        conn.keepalive_task = nothing
    end
    
    if conn.receive_task !== nothing && !istaskdone(conn.receive_task)
        schedule(conn.receive_task, InterruptException(), error=true)
        conn.receive_task = nothing
    end

    # Close all pending request channels
    lock(conn.request_lock) do
        for (_, chan) in conn.pending_requests
            close(chan)
        end
        empty!(conn.pending_requests)
    end

    try
        isopen(conn.socket) && close(conn.socket)
    catch 
    finally
        conn.socket = nothing
    end

    @info "Disconnected from OpenD"
    return true
end

# Check if connected
is_connected(conn::OpenDConnection)::Bool = conn.connected && conn.socket !== nothing && isopen(conn.socket)

# Helper to pack body into a full packet
function pack_body(conn::OpenDConnection, proto_id::UInt32, body_bytes::Vector{UInt8}, serial_no::UInt32)::Vector{UInt8}
    # Calculate SHA1 on the UNENCRYPTED body (per protocol documentation)
    # arrBodySHA1: 包体原始数据(解密后)的 SHA1 哈希值
    body_sha1 = sha1(body_bytes)
    
    # Encrypt body based on requested algorithm
    encrypted_body = if conn.packet_enc_algo == Common.PacketEncAlgo.None
        # No encryption requested
        body_bytes
    elseif isempty(conn.conn_aes_key)
        # No AES key available, cannot encrypt
        body_bytes
    elseif conn.packet_enc_algo == Common.PacketEncAlgo.AES_CBC
        # Use AES CBC mode
        Encryption.encrypt_aes_cbc(body_bytes, conn.conn_aes_key, conn.conn_aes_iv)
    else
        # Default: FTAES_ECB or AES_ECB
        Encryption.encrypt_aes_ecb(body_bytes, conn.conn_aes_key)
    end

    # Create header with encrypted body length
    header = ProtoHeader(
        proto_id,
        UInt32(length(encrypted_body)),
        serial_no
    )
    header.body_sha1 .= body_sha1
    header_bytes = serialize_header(header)
    return vcat(header_bytes, encrypted_body)
end

# Julia-style: Use Channels for request-response pattern
function request_sync(conn::OpenDConnection, proto_id::UInt32, req_proto, RspType::Type{T}; timeout::Float64=30.0) where T
    if !is_connected(conn)      # 后续连接稳定后，可以删除
        @warn "Not connected. Attempting to reconnect..."
        try
            connect!(conn)
        catch e
            @error "Reconnection failed" exception=(e, catch_backtrace())
            throw(ConnectionError("Reconnection failed: $e"))
        end
    end

    # Get next serial number (atomic operation)
    serial_no = atomic_add!(conn.serial_no, UInt32(1)) + UInt32(1)
    
    # Create a channel for this request's response
    result_channel = Channel{ResponseResult}(1)
    
    lock(conn.request_lock) do
        conn.pending_requests[serial_no] = result_channel
    end

    try
        # Send request
        io = IOBuffer()
        PB.encode(ProtoEncoder(io), req_proto)
        body_bytes = take!(io)
        packet = pack_body(conn, proto_id, body_bytes, serial_no)
        write(conn.socket, packet)

        # Wait for response with timeout (Julia's timedwait on Channel)
        result = nothing
        timeout_occurred = Ref{Bool}(false)

        timer = Timer(timeout) do _
            timeout_occurred[] = true
            # Close the result channel to unblock fetch
            lock(conn.request_lock) do
                if haskey(conn.pending_requests, serial_no)
                    chan = conn.pending_requests[serial_no]
                    if isopen(chan)
                        close(chan)
                    end
                end
            end
        end

        try
            result = fetch(result_channel)

            if timeout_occurred[]
                throw(ConnectionError("Request timeout after $(timeout) seconds (proto_id: $proto_id)"))
            end
        catch e
            if timeout_occurred[]
                throw(ConnectionError("Request timeout after $(timeout) seconds (proto_id: $proto_id)"))
            elseif e isa InvalidStateException && !isopen(result_channel)
                # Channel closed, connection lost or timeout
                if timeout_occurred[]
                    throw(ConnectionError("Request timeout after $(timeout) seconds (proto_id: $proto_id)"))
                else
                    throw(ConnectionError("Connection closed while waiting for response"))
                end
            end
            rethrow(e)
        finally
            close(timer)
        end

        # Check result
        if !result.success
            throw(result.error)
        end
        
        return result.data
    finally
        lock(conn.request_lock) do
            delete!(conn.pending_requests, serial_no)
        end
        close(result_channel)
    end
end

# Julia-style: Receive task reads from socket and puts packets into channel
function start_receive_task(conn::OpenDConnection)
    conn.receive_task = @async begin
        try
            while is_connected(conn)
                # Read and decrypt packet
                header_buffer = read(conn.socket, PROTO_HEADER_SIZE)
                length(header_buffer) < PROTO_HEADER_SIZE && break
                
                header = deserialize_header(header_buffer)
                body_bytes = read(conn.socket, header.body_len)
                length(body_bytes) < header.body_len && break
                
                # Decrypt
                decrypted_body = if conn.packet_enc_algo == Common.PacketEncAlgo.None
                    body_bytes
                elseif isempty(conn.conn_aes_key)
                    body_bytes
                elseif conn.packet_enc_algo == Common.PacketEncAlgo.AES_CBC
                    Encryption.decrypt_aes_cbc(body_bytes, conn.conn_aes_key, conn.conn_aes_iv)
                else
                    Encryption.decrypt_aes_ecb(body_bytes, conn.conn_aes_key)
                end
                #@show decrypted_body
                # Verify SHA1
                calculated_sha1 = sha1(decrypted_body)
                if calculated_sha1 != header.body_sha1
                    @error "SHA1 verification failed" proto_id=header.proto_id
                    continue
                end
                packet = ResponsePacket(header.serial_no, header.proto_id, decrypted_body)

                if haskey(PROTO_PUSH_MAP, packet.proto_id)
                    # Put into push channel for processing
                    if isopen(conn.push_channel)
                        put!(conn.push_channel, packet)
                    else
                        @warn "Push channel is closed, dropping message" serial_no=packet.serial_no proto_id=packet.proto_id
                    end
                else
                    # Put into response channel for processing
                    put!(conn.response_channel, packet)
                end
            end
        catch e
            if !(e isa EOFError || e isa Base.IOError || e isa InterruptException)
                @error "Receive task error" exception=e
            end
        finally
            close(conn.response_channel)
            disconnect!(conn)
        end
    end
    
    # Dispatcher task: reads from channel and dispatches to waiting requests
    @async begin
        try
            for packet in conn.response_channel
                # Find the waiting request
                result_chan = lock(conn.request_lock) do
                    get(conn.pending_requests, packet.serial_no, nothing)
                end

                # Check if there's a pending request for this response
                if result_chan === nothing
                    @warn "Dropping response with no pending request" serial_no=packet.serial_no proto_id=packet.proto_id
                    continue
                end

                # Decode and send result
                try
                    # Use multiple dispatch to handle different proto types
                    # @info "Received response" proto_id=packet.proto_id data_length=length(packet.data)
                    resp = decode_response(packet.proto_id, packet.data)

                    if resp.retType != Int32(Common.RetType.Succeed)
                        put!(result_chan, ResponseResult(false, nothing, FutuError(resp.retType, resp.retMsg)))
                    else
                        put!(result_chan, ResponseResult(true, resp, nothing))
                    end
                catch e
                    @error "Failed to decode response" proto_id=packet.proto_id data_length=length(packet.data) exception=(e, catch_backtrace())
                    put!(result_chan, ResponseResult(false, nothing, e))
                end
            end
        catch e
            @error "Dispatcher error" exception=e
        end
    end
end

# Decode response using dictionary lookup
function decode_response(proto_id::UInt32, data::Vector{UInt8})
    response_type = get(PROTO_RESPONSE_MAP, proto_id, nothing)
    if response_type === nothing
        error("Unknown proto_id: $proto_id")
    end
    return PB.decode(ProtoDecoder(IOBuffer(data)), response_type)
end

# Julia-style: Keep-alive using the same request mechanism
function start_keepalive_task(conn::OpenDConnection)
    conn.keepalive_task = @async begin
        try
            while is_connected(conn)
                sleep(conn.keep_alive_interval / 2)
                current_time = time()
                last_ka = conn.last_keep_alive[]
                
                if is_connected(conn) && (current_time - last_ka) >= conn.keep_alive_interval
                    try
                        c2s = KeepAlive.C2S(round(Int64, current_time))
                        req = KeepAlive.Request(c2s)
                        request_sync(conn, UInt32(KEEPALIVE), req, KeepAlive.Response; timeout=5.0)
                        conn.last_keep_alive[] = current_time
                    catch e
                        if e isa InterruptException
                            break
                        elseif e isa EOFError || e isa Base.IOError
                            @debug "Keep-alive failed: connection closed" exception=e
                            break
                        elseif e isa ConnectionError
                            @debug "Keep-alive failed: connection error" exception=e
                            break
                        else
                            @warn "Keep-alive failed with unexpected error" exception=e
                            break
                        end
                    end
                end
            end
        catch e
            if !(e isa InterruptException)
                @debug "Keep-alive task stopped" exception=e
            end
        end
    end
end

# Get global state
function get_global_state(conn::OpenDConnection)
    c2s = GetGlobalState.C2S(conn.login_user_id)
    req = GetGlobalState.Request(c2s)
    resp = request_sync(conn, UInt32(GET_GLOBAL_STATE), req, GetGlobalState.Response)
    gs = resp.s2c
    return GetGlobalState.GlobalStateInfo(
        GetGlobalState.format_all_markets(Dict(
            :marketHK => gs.marketHK,
            :marketUS => gs.marketUS,
            :marketSH => gs.marketSH,
            :marketSZ => gs.marketSZ,
            :marketHKFuture => gs.marketHKFuture,
            :marketUSFuture => gs.marketUSFuture,
            :marketSGFuture => gs.marketSGFuture,
            :marketJPFuture => gs.marketJPFuture,
        )),
        gs.qotLogined,
        gs.trdLogined,
        gs.serverVer,
        gs.serverBuildNo,
        gs.time,
        gs.localTime,
        gs.connID,
        Common.format_program_status(gs.programStatus),
        gs.programStatus,
        gs.qotSvrIpAddr,
        gs.trdSvrIpAddr,
    )
end

# Get delay statistics
function get_delay_statistics(conn::OpenDConnection; 
    type_list::Vector{Int32} = Int32[
        DelayStatisticsType.DelayStatisticsType_QotPush,
        DelayStatisticsType.DelayStatisticsType_ReqReply,
        DelayStatisticsType.DelayStatisticsType_PlaceOrder
    ],
    qot_push_stage::Int32 = Int32(0), segment_list::Vector{Int32} = Int32[]
    )
    
    c2s = GetDelayStatistics.C2S(type_list, qot_push_stage, segment_list)
    req = GetDelayStatistics.Request(c2s)
    resp = request_sync(conn, UInt32(GET_DELAY_STATISTICS), req, GetDelayStatistics.Response)
    return GetDelayStatistics.build_delay_statistics_info(resp)
end

# Get user info
function get_user_info(conn::OpenDConnection; flag::Union{UserInfoField.T, Integer} = UserInfoField.API)
    mask = Int32(flag)
    c2s = GetUserInfo.C2S(mask)
    req = GetUserInfo.Request(c2s)
    resp = request_sync(conn, UInt32(GET_USER_INFO), req, GetUserInfo.Response)
    return GetUserInfo.build_user_info_summary(resp, mask)
end

end # module Connection
