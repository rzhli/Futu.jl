module GetGlobalState

using Printf: @sprintf
using Dates
import ProtoBuf as PB
using ..Common
using ..Qot_Common

# Market labels and field order for GlobalState display
const MARKET_LABELS = Dict(
    :marketHK => "HK Main Board",
    :marketUS => "US NASDAQ",
    :marketSH => "Shanghai",
    :marketSZ => "Shenzhen",
    :marketHKFuture => "HK Futures",
    :marketUSFuture => "US Futures",
    :marketSGFuture => "Singapore Futures",
    :marketJPFuture => "Japan Futures",
)

const MARKET_FIELD_ORDER = (
    :marketHK,
    :marketUS,
    :marketSH,
    :marketSZ,
    :marketHKFuture,
    :marketUSFuture,
    :marketSGFuture,
    :marketJPFuture,
)

# Helper function to format all markets for GlobalState
function format_all_markets(global_state)
    rows = String[]
    for key in MARKET_FIELD_ORDER
        raw = get(global_state, key, nothing)
        raw === nothing && continue
        label = MARKET_LABELS[key]
        # Convert Int32 to QotMarketState enum and format
        state_enum = Qot_Common.QotMarketState.T(raw)
        state_label = Qot_Common.format_market_status(state_enum)
        push!(rows, @sprintf("    %-20s : %s", label, state_label))
    end
    return join(rows, "\n")
end
mutable struct C2S
    userID::UInt64
end
PB.default_values(::Type{C2S}) = (;userID = zero(UInt64))
PB.field_numbers(::Type{C2S}) = (;userID = 1)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    x.userID != zero(UInt64) && PB.encode(e, 1, x.userID)
    return position(e.io) - initpos
end

mutable struct S2C
    marketHK::Int32
    marketUS::Int32
    marketSH::Int32
    marketSZ::Int32
    marketHKFuture::Int32
    marketUSFuture::Int32
    marketSGFuture::Int32
    marketJPFuture::Int32
    qotLogined::Bool
    trdLogined::Bool
    serverVer::Int32
    serverBuildNo::Int32
    time::Int64
    localTime::Float64
    programStatus::Common.ProgramStatus
    qotSvrIpAddr::String
    trdSvrIpAddr::String
    connID::UInt64
end
S2C() = S2C(zero(Int32), zero(Int32), zero(Int32), zero(Int32), zero(Int32), zero(Int32), zero(Int32), zero(Int32), false, false, zero(Int32), zero(Int32), zero(Int64), zero(Float64), Common.ProgramStatus(), "", "", zero(UInt64))
PB.default_values(::Type{S2C}) = (;marketHK = zero(Int32), marketUS = zero(Int32), marketSH = zero(Int32), marketSZ = zero(Int32), marketHKFuture = zero(Int32), marketUSFuture = zero(Int32), marketSGFuture = zero(Int32), marketJPFuture = zero(Int32), qotLogined = false, trdLogined = false, serverVer = zero(Int32), serverBuildNo = zero(Int32), time = zero(Int64), localTime = zero(Float64), programStatus = Common.ProgramStatus(), qotSvrIpAddr = "", trdSvrIpAddr = "", connID = zero(UInt64))
PB.field_numbers(::Type{S2C}) = (;marketHK = 1, marketUS = 2, marketSH = 3, marketSZ = 4, marketHKFuture = 5, marketUSFuture = 15, marketSGFuture = 17, marketJPFuture = 18, qotLogined = 6, trdLogined = 7, serverVer = 8, serverBuildNo = 9, time = 10, localTime = 11, programStatus = 12, qotSvrIpAddr = 13, trdSvrIpAddr = 14, connID = 16)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    marketHK = zero(Int32)
    marketUS = zero(Int32)
    marketSH = zero(Int32)
    marketSZ = zero(Int32)
    marketHKFuture = zero(Int32)
    marketUSFuture = zero(Int32)
    marketSGFuture = zero(Int32)
    marketJPFuture = zero(Int32)
    qotLogined = false
    trdLogined = false
    serverVer = zero(Int32)
    serverBuildNo = zero(Int32)
    time = zero(Int64)
    localTime = zero(Float64)
    programStatus = Common.ProgramStatus()
    qotSvrIpAddr = ""
    trdSvrIpAddr = ""
    connID = zero(UInt64)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            marketHK = PB.decode(d, Int32)
        elseif field_number == 2
            marketUS = PB.decode(d, Int32)
        elseif field_number == 3
            marketSH = PB.decode(d, Int32)
        elseif field_number == 4
            marketSZ = PB.decode(d, Int32)
        elseif field_number == 5
            marketHKFuture = PB.decode(d, Int32)
        elseif field_number == 6
            qotLogined = PB.decode(d, Bool)
        elseif field_number == 7
            trdLogined = PB.decode(d, Bool)
        elseif field_number == 8
            serverVer = PB.decode(d, Int32)
        elseif field_number == 9
            serverBuildNo = PB.decode(d, Int32)
        elseif field_number == 10
            time = PB.decode(d, Int64)
        elseif field_number == 11
            localTime = PB.decode(d, Float64)
        elseif field_number == 12
            programStatus = PB.decode(d, Ref{Common.ProgramStatus})
        elseif field_number == 13
            qotSvrIpAddr = PB.decode(d, String)
        elseif field_number == 14
            trdSvrIpAddr = PB.decode(d, String)
        elseif field_number == 15
            marketUSFuture = PB.decode(d, Int32)
        elseif field_number == 16
            connID = PB.decode(d, UInt64)
        elseif field_number == 17
            marketSGFuture = PB.decode(d, Int32)
        elseif field_number == 18
            marketJPFuture = PB.decode(d, Int32)
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(marketHK, marketUS, marketSH, marketSZ, marketHKFuture, marketUSFuture, marketSGFuture, marketJPFuture, qotLogined, trdLogined, serverVer, serverBuildNo, time, localTime, programStatus, qotSvrIpAddr, trdSvrIpAddr, connID)
end

mutable struct Request
    c2s::C2S
end
PB.default_values(::Type{Request}) = (;c2s = C2S())
PB.field_numbers(::Type{Request}) = (;c2s = 1)
function PB.encode(e::PB.AbstractProtoEncoder, x::Request)
    initpos = position(e.io)
    PB.encode(e, 1, x.c2s)
    return position(e.io) - initpos
end

mutable struct Response
    retType::Int32
    retMsg::String
    errCode::Int32
    s2c::S2C
end
PB.default_values(::Type{Response}) = (;retType = Common.RetType.Unknown, retMsg = "", errCode = 0, s2c = S2C())
PB.field_numbers(::Type{Response}) = (;retType = 1, retMsg = 2, errCode = 3, s2c = 4)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:Response})
    retType = Common.RetType.Unknown
    retMsg = ""
    errCode = 0
    s2c = S2C()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            retType = PB.decode(d, Int32)
        elseif field_number == 2
            retMsg = PB.decode(d, String)
        elseif field_number == 3
            errCode = PB.decode(d, Int32)
        elseif field_number == 4
            s2c = PB.decode(d, Ref{S2C})
        else
            PB.skip(d, wire_type)
        end
    end
    return Response(retType, retMsg, errCode, s2c)
end

# Custom type for GlobalState display with optimized formatting
struct GlobalStateInfo
    market::String
    qot_logined::Bool
    trd_logined::Bool
    server_ver::Int32
    server_build::Int32
    server_time::Int64
    local_time::Float64
    conn_id::UInt64
    program_status::String
    program_status_raw::Common.ProgramStatus
    qot_server::String
    trd_server::String
end

export C2S, S2C, Request, Response, GlobalStateInfo, format_all_markets

end
