module Client

using Logging
using MD5
using Crayons
using Printf

using ..Errors
using ..Connection
using ..Constants
using ..PushCallbacks: CallbackManager, start_callback_handler, stop_callback_handler

export OpenDClient, connect!, disconnect!, is_connected, keep_alive
export get_global_state, get_delay_statistics, get_user_info

# Display styles
const HEADER_STYLE = Crayon(foreground=:cyan, bold=true)
const LABEL_STYLE = Crayon(foreground=:white, bold=true)
const VALUE_STYLE = Crayon(foreground=:white)
const GOOD_STYLE = Crayon(foreground=:green, bold=true)
const BAD_STYLE = Crayon(foreground=:red, bold=true)
const DIM_STYLE = Crayon(foreground=:light_gray)

# OpenD client
mutable struct OpenDClient
    connection::OpenDConnection
    callbacks::CallbackManager
    client_id::String
    client_ver::Int

    function OpenDClient(;
        host::String = Connection.DEFAULT_HOST,
        port::Int = Connection.DEFAULT_PORT,
        client_id::String = "FutuAPI.jl",
        client_ver::Int = 310,
        rsa_private_key_path::String = ""
        )
        conn = OpenDConnection(host, port; rsa_private_key_path=rsa_private_key_path)
        callbacks = CallbackManager()
        new(conn, callbacks, client_id, client_ver)
    end
end

function Base.show(io::IO, client::OpenDClient)
    # Header
    println(io, HEADER_STYLE("OpenDClient"))
    println(io, HEADER_STYLE("═══════════"))
    println(io)

    # Client info
    println(io, LABEL_STYLE("  ID  : "), VALUE_STYLE(client.client_id))
    println(io, LABEL_STYLE("  Ver : "), VALUE_STYLE(string(client.client_ver)))
    println(io)

    # Connection info
    println(io, LABEL_STYLE("  Connection:"))
    conn = client.connection

    # Connection status
    connected = is_connected(client)
    status_icon = connected ? GOOD_STYLE(" ✓ ") : BAD_STYLE(" ✗ ")
    status_text = connected ? GOOD_STYLE("Connected") : BAD_STYLE("Disconnected")
    println(io, "    ", LABEL_STYLE("Status      : "), status_icon, status_text)
    println(io, "    ", LABEL_STYLE("Host        : "), VALUE_STYLE(conn.host))
    println(io, "    ", LABEL_STYLE("Port        : "), VALUE_STYLE(string(conn.port)))

    if connected
        println(io, "    ", LABEL_STYLE("Server Ver  : "), VALUE_STYLE(string(conn.server_ver)))
        println(io, "    ", LABEL_STYLE("User ID     : "), VALUE_STYLE(string(conn.login_user_id)))
        println(io, "    ", LABEL_STYLE("Conn ID     : "), VALUE_STYLE(@sprintf("0x%016X", conn.conn_id)))
        println(io, "    ", LABEL_STYLE("AES Key     : "), DIM_STYLE(conn.conn_aes_key))
        println(io, "    ", LABEL_STYLE("AES IV      : "), DIM_STYLE(conn.conn_aes_iv))
        println(io, "    ", LABEL_STYLE("Keep-alive  : "), VALUE_STYLE(string(conn.keep_alive_interval), " sec"))
    end

    if !isempty(conn.rsa_private_key_path)
        println(io, "    ", LABEL_STYLE("RSA Key     : "), DIM_STYLE(conn.rsa_private_key_path))
    end

    println(io, "    ", DIM_STYLE("(Run `client.connection` for details)"))

    println(io)

    # Callbacks summary
    println(io, LABEL_STYLE("  Callbacks:"))
    callbacks = client.callbacks

    # Callback handler status
    handler_status = callbacks.is_running ? GOOD_STYLE(" ✓ Running") : BAD_STYLE(" ✗ Stopped")
    println(io, "    ", LABEL_STYLE("Handler     : "), handler_status)

    # Registered callbacks count
    total_callbacks = sum(length(v) for v in values(callbacks.callbacks); init=0)
    protocol_count = length(callbacks.callbacks)

    if protocol_count > 0
        println(io, "    ", LABEL_STYLE("Registered  : "),
                VALUE_STYLE(string(total_callbacks)),
                DIM_STYLE(" callback(s) on "),
                VALUE_STYLE(string(protocol_count)),
                DIM_STYLE(" protocol(s)"))
        println(io, "    ", DIM_STYLE("(Run `client.callbacks` for details)"))
    else
        println(io, "    ", LABEL_STYLE("Registered  : "), DIM_STYLE("None"))
    end
end

# Connect to OpenD
function connect!(client::OpenDClient)
    # Connection.connect! already starts the keep-alive task internally
    Connection.connect!(client.connection)
    start_callback_handler(client.callbacks, client.connection)
    return client
end

# Disconnect from OpenD
function disconnect!(client::OpenDClient)
    stop_callback_handler(client.callbacks)
    Connection.disconnect!(client.connection)
end

# Check if connected
function is_connected(client::OpenDClient)::Bool
    return Connection.is_connected(client.connection)
end

# Keep alive (manual trigger, normally handled automatically by connection)
function keep_alive(client::OpenDClient)
    return Connection.keep_alive(client.connection)
end

# Get global state
function get_global_state(client::OpenDClient)
    return Connection.get_global_state(client.connection)
end

# Get delay statistics
function get_delay_statistics(
    client::OpenDClient; 
    type_list::Vector{Int32} = Int32[],
    qot_push_stage::Int32 = Int32(0),
    segment_list::Vector{Int32} = Int32[]
    )
    
    return Connection.get_delay_statistics(
        client.connection; 
        type_list=type_list,
        qot_push_stage=qot_push_stage,
        segment_list=segment_list
    )
end

# Get user info
function get_user_info(client::OpenDClient; flag::Union{UserInfoField.T, Integer} = UserInfoField.API)
    return Connection.get_user_info(client.connection; flag=flag)
end

# Make API request
function api_request(client::OpenDClient, proto_id::UInt32, req_proto, RspType::Type{T}) where T
    if !is_connected(client)
        throw(ConnectionError("Client not connected"))
    end
    return Connection.request_sync(client.connection, proto_id, req_proto, RspType)
end

end # module Client
