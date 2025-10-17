module Qot_RequestHistoryKL

import ProtoBuf as PB
import ..Common
import ..Qot_Common

mutable struct C2S
    rehabType::Int32
    klType::Int32
    security::Qot_Common.Security
    beginTime::String
    endTime::String
    maxAckKLNum::Int32
    needKLFieldsFlag::Int64
    nextReqKey::Vector{UInt8}
    extendedTime::Bool
    session::Int32
    C2S(; rehabType = 0, klType = 0, security = Qot_Common.Security(), beginTime = "", endTime = "", maxAckKLNum = 0, needKLFieldsFlag = 0, nextReqKey = Vector{UInt8}(), extendedTime = false, session = 0) = new(rehabType, klType, security, beginTime, endTime, maxAckKLNum, needKLFieldsFlag, nextReqKey, extendedTime, session)
end
PB.default_values(::Type{C2S}) = (; rehabType = Int32(0), klType = Int32(0), security = Qot_Common.Security(), beginTime = "", endTime = "", maxAckKLNum = Int32(0), needKLFieldsFlag = Int64(0), nextReqKey = Vector{UInt8}(), extendedTime = false, session = Int32(0))
PB.field_numbers(::Type{C2S}) = (; rehabType = 1, klType = 2, security = 3, beginTime = 4, endTime = 5, maxAckKLNum = 6, needKLFieldsFlag = 7, nextReqKey = 8, extendedTime = 9, session = 10)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    PB.encode(e, 1, x.rehabType)
    PB.encode(e, 2, x.klType)
    PB.encode(e, 3, x.security)
    x.beginTime != "" && PB.encode(e, 4, x.beginTime)
    x.endTime != "" && PB.encode(e, 5, x.endTime)
    x.maxAckKLNum != 0 && PB.encode(e, 6, x.maxAckKLNum)
    x.needKLFieldsFlag != 0 && PB.encode(e, 7, x.needKLFieldsFlag)
    !isempty(x.nextReqKey) && PB.encode(e, 8, x.nextReqKey)
    x.extendedTime && PB.encode(e, 9, x.extendedTime)
    x.session != 0 && PB.encode(e, 10, x.session)
    return position(e.io) - initpos
end

mutable struct S2C
    security::Qot_Common.Security
    name::String
    klList::Vector{Qot_Common.KLine}
    nextReqKey::Vector{UInt8}
    S2C(; security = Qot_Common.Security(), name = "", klList = Vector{Qot_Common.KLine}(), nextReqKey = Vector{UInt8}()) = new(security, name, klList, nextReqKey)
end
PB.default_values(::Type{S2C}) = (; security = Qot_Common.Security(), name = "", klList = Vector{Qot_Common.KLine}(), nextReqKey = Vector{UInt8}())
PB.field_numbers(::Type{S2C}) = (; security = 1, klList = 2, nextReqKey = 3, name = 4)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    security = Qot_Common.Security()
    name = ""
    klList = Vector{Qot_Common.KLine}()
    nextReqKey = Vector{UInt8}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            security = PB.decode(d, Ref{Qot_Common.Security})
        elseif field_number == 2
            push!(klList, PB.decode(d, Ref{Qot_Common.KLine}))
        elseif field_number == 3
            nextReqKey = PB.decode(d, Vector{UInt8})
        elseif field_number == 4
            name = PB.decode(d, String)
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(; security, name, klList, nextReqKey)
end

mutable struct Request
    c2s::C2S
    Request(; c2s = C2S()) = new(c2s)
end
PB.default_values(::Type{Request}) = (; c2s = C2S())
PB.field_numbers(::Type{Request}) = (; c2s = 1)
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
    Response(; retType = -400, retMsg = "", errCode = 0, s2c = S2C()) = new(retType, retMsg, errCode, s2c)
end
PB.default_values(::Type{Response}) = (; retType = Int32(-400), retMsg = "", errCode = Int32(0), s2c = S2C())
PB.field_numbers(::Type{Response}) = (; retType = 1, retMsg = 2, errCode = 3, s2c = 4)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:Response})
    retType = Int32(-400)
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
    return Response(; retType, retMsg, errCode, s2c)
end

export C2S, S2C, Request, Response

end
