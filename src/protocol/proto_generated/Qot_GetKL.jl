module Qot_GetKL

using ProtoBuf
import ProtoBuf as PB
import ..Common
import ..Qot_Common

mutable struct C2S
    rehabType::Int32
    klType::Int32
    security::Qot_Common.Security
    reqNum::Int32
    C2S(rehabType::Int32, klType::Int32, security::Qot_Common.Security, reqNum::Int32) = new(rehabType, klType, security, reqNum)
    C2S(; rehabType::Int32 = Int32(0), klType::Int32 = Int32(0), security::Qot_Common.Security = Qot_Common.Security(), reqNum::Int32 = Int32(0)) = new(rehabType, klType, security, reqNum)
end
PB.default_values(::Type{C2S}) = (;rehabType = 0, klType = 0, security = Qot_Common.Security(), reqNum = 0)
PB.field_numbers(::Type{C2S}) = (;rehabType = 1, klType = 2, security = 3, reqNum = 4)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    PB.encode(e, 1, x.rehabType)
    PB.encode(e, 2, x.klType)
    PB.encode(e, 3, x.security)
    PB.encode(e, 4, x.reqNum)
    return position(e.io) - initpos
end

mutable struct S2C
    security::Qot_Common.Security
    name::String
    klList::Vector{Qot_Common.KLine}
    S2C(; security = Qot_Common.Security(), name = "", klList = Vector{Qot_Common.KLine}()) = new(security, name, klList)
end
PB.default_values(::Type{S2C}) = (;security = Qot_Common.Security(), name = "", klList = Vector{Qot_Common.KLine}())
PB.field_numbers(::Type{S2C}) = (;security = 1, name = 3, klList = 2)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    security = Qot_Common.Security()
    name = ""
    klList = Vector{Qot_Common.KLine}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            security = PB.decode(d, Ref{Qot_Common.Security})
        elseif field_number == 2
            push!(klList, PB.decode(d, Ref{Qot_Common.KLine}))
        elseif field_number == 3
            name = PB.decode(d, String)
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(security = security, name = name, klList = klList)
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
    Response(retType::Int32, retMsg::String, errCode::Int32, s2c::S2C) = new(retType, retMsg, errCode, s2c)
    Response(; retType = Common.RetType.Unknown, retMsg = "", errCode = 0, s2c = S2C()) = new(retType, retMsg, errCode, s2c)
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

export C2S, S2C, Request, Response

end
