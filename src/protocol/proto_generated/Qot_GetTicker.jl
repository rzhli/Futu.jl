module Qot_GetTicker

using ProtoBuf
import ProtoBuf as PB
import ..Common
import ..Qot_Common

mutable struct C2S
    security::Qot_Common.Security
    maxRetNum::Int32
end
function C2S(; security = Qot_Common.Security(), maxRetNum = Int32(0))
    return C2S(security, Int32(maxRetNum))
end
PB.default_values(::Type{C2S}) = (;security = Qot_Common.Security(), maxRetNum = Int32(0))
PB.field_numbers(::Type{C2S}) = (;security = 1, maxRetNum = 2)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    PB.encode(e, 1, x.security)
    x.maxRetNum != 0 && PB.encode(e, 2, x.maxRetNum)
    return position(e.io) - initpos
end

mutable struct S2C
    security::Qot_Common.Security
    name::String
    tickerList::Vector{Qot_Common.Ticker}
end
function S2C(; security = Qot_Common.Security(), name = "", tickerList = Vector{Qot_Common.Ticker}())
    return S2C(security, name, tickerList)
end
PB.default_values(::Type{S2C}) = (;security = Qot_Common.Security(), name = "", tickerList = Vector{Qot_Common.Ticker}())
PB.field_numbers(::Type{S2C}) = (;security = 1, tickerList = 2, name = 3)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    security = Qot_Common.Security()
    name = ""
    tickerList = Vector{Qot_Common.Ticker}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            security = PB.decode(d, Ref{Qot_Common.Security})
        elseif field_number == 2
            push!(tickerList, PB.decode(d, Ref{Qot_Common.Ticker}))
        elseif field_number == 3
            name = PB.decode(d, String)
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(security, name, tickerList)
end

mutable struct Request
    c2s::C2S
end
function Request(; c2s = C2S())
    return Request(c2s)
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
function Response(; retType = Int32(Common.RetType.Unknown), retMsg = "", errCode = Int32(0), s2c = S2C())
    return Response(retType, retMsg, errCode, s2c)
end
PB.default_values(::Type{Response}) = (;retType = Int32(Common.RetType.Unknown), retMsg = "", errCode = Int32(0), s2c = S2C())
PB.field_numbers(::Type{Response}) = (;retType = 1, retMsg = 2, errCode = 3, s2c = 4)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:Response})
    retType = Int32(Common.RetType.Unknown)
    retMsg = ""
    errCode = Int32(0)
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

export C2S, S2C, Request, Response

end
