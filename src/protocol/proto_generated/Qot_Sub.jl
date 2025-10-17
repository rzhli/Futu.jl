module Qot_Sub

import ProtoBuf as PB
import ..Common
import ..Qot_Common

mutable struct C2S
    securityList::Vector{Qot_Common.Security}
    subTypeList::Vector{Int32}
    isSubOrUnSub::Bool
    isRegOrUnRegPush::Bool
    regPushRehabTypeList::Vector{Int32}
    isFirstPush::Bool
    isUnsubAll::Bool
    isSubOrderBookDetail::Bool
    extendedTime::Bool
    session::Int32
    C2S(; securityList = Vector{Qot_Common.Security}(), subTypeList = Vector{Int32}(), isSubOrUnSub = false, isRegOrUnRegPush = false, regPushRehabTypeList = Vector{Int32}(), isFirstPush = false, isUnsubAll = false, isSubOrderBookDetail = false, extendedTime = false, session = 0) = new(securityList, subTypeList, isSubOrUnSub, isRegOrUnRegPush, regPushRehabTypeList, isFirstPush, isUnsubAll, isSubOrderBookDetail, extendedTime, session)
end
PB.default_values(::Type{C2S}) = (;securityList = Vector{Qot_Common.Security}(), subTypeList = Vector{Int32}(), isSubOrUnSub = false, isRegOrUnRegPush = false, regPushRehabTypeList = Vector{Int32}(), isFirstPush = false, isUnsubAll = false, isSubOrderBookDetail = false, extendedTime = false, session = 0)
PB.field_numbers(::Type{C2S}) = (;securityList = 1, subTypeList = 2, isSubOrUnSub = 3, isRegOrUnRegPush = 4, regPushRehabTypeList = 5, isFirstPush = 6, isUnsubAll = 7, isSubOrderBookDetail = 8, extendedTime = 9, session = 10)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    for item in x.securityList
        PB.encode(e, 1, item)
    end
    for item in x.subTypeList
        PB.encode(e, 2, item)
    end
    PB.encode(e, 3, x.isSubOrUnSub)
    x.isRegOrUnRegPush != false && PB.encode(e, 4, x.isRegOrUnRegPush)
    for item in x.regPushRehabTypeList
        PB.encode(e, 5, item)
    end
    x.isFirstPush != false && PB.encode(e, 6, x.isFirstPush)
    x.isUnsubAll != false && PB.encode(e, 7, x.isUnsubAll)
    x.isSubOrderBookDetail != false && PB.encode(e, 8, x.isSubOrderBookDetail)
    x.extendedTime != false && PB.encode(e, 9, x.extendedTime)
    x.session != 0 && PB.encode(e, 10, x.session)
    return position(e.io) - initpos
end

mutable struct S2C
    S2C() = new()
end
PB.default_values(::Type{S2C}) = NamedTuple()
PB.field_numbers(::Type{S2C}) = NamedTuple()
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        PB.skip(d, wire_type)
    end
    return S2C()
end

mutable struct Request
    c2s::C2S
    Request(; c2s = C2S()) = new(c2s)
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
