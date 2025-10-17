module Qot_GetSubInfo

import ProtoBuf as PB
import ..Common
import ..Qot_Common

mutable struct C2S
    isReqAllConn::Bool
    C2S(isReqAllConn::Bool) = new(isReqAllConn)
    C2S(; isReqAllConn::Bool = false) = new(isReqAllConn)
end
PB.default_values(::Type{C2S}) = (;isReqAllConn = false)
PB.field_numbers(::Type{C2S}) = (;isReqAllConn = 1)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    x.isReqAllConn != false && PB.encode(e, 1, x.isReqAllConn)
    return position(e.io) - initpos
end

mutable struct S2C
    connSubInfoList::Vector{Qot_Common.ConnSubInfo}
    totalUsedQuota::Int32
    remainQuota::Int32
    S2C(; connSubInfoList = Vector{Qot_Common.ConnSubInfo}(), totalUsedQuota = 0, remainQuota = 0) = new(connSubInfoList, totalUsedQuota, remainQuota)
end
PB.default_values(::Type{S2C}) = (;connSubInfoList = Vector{Qot_Common.ConnSubInfo}(), totalUsedQuota = 0, remainQuota = 0)
PB.field_numbers(::Type{S2C}) = (;connSubInfoList = 1, totalUsedQuota = 2, remainQuota = 3)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    connSubInfoList = Vector{Qot_Common.ConnSubInfo}()
    totalUsedQuota = 0
    remainQuota = 0
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            push!(connSubInfoList, PB.decode(d, Ref{Qot_Common.ConnSubInfo}))
        elseif field_number == 2
            totalUsedQuota = PB.decode(d, Int32)
        elseif field_number == 3
            remainQuota = PB.decode(d, Int32)
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(connSubInfoList = connSubInfoList, totalUsedQuota = totalUsedQuota, remainQuota = remainQuota)
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

function format_sub_type_label(value::Int32)
    try
        enum_value = Qot_Common.SubType.T(value)
        label = string(Symbol(enum_value))
        label = replace(label, "_" => " ")
        label = replace(label, r"([a-z])([A-Z])" => s"\1 \2")
        return label
    catch
        return string(value)
    end
end

function format_market_label(value::Int32)
    try
        enum_value = Qot_Common.QotMarket.T(value)
        label = string(Symbol(enum_value))
        label = replace(label, "_" => " ")
        label = replace(label, r"([a-z])([A-Z])" => s"\1 \2")
        return isempty(label) ? string(value) : label
    catch
        return string(value)
    end
end

function format_security_line(security::Qot_Common.Security)
    market_label = format_market_label(security.market)
    code = isempty(security.code) ? "-" : security.code
    return string(market_label, " : ", code)
end

function build_subscription_summary(sub_info::Qot_Common.SubInfo)
    securities = [format_security_line(sec) for sec in sub_info.securityList]
    return (;
        sub_type = sub_info.subType,
        sub_type_label = format_sub_type_label(sub_info.subType),
        securities = securities,
    )
end

function build_connection_summary(conn::Qot_Common.ConnSubInfo)
    subscriptions = [build_subscription_summary(sub_info) for sub_info in conn.subInfoList]
    return (;
        used_quota = conn.usedQuota,
        is_own_conn_data = conn.isOwnConnData,
        subscriptions = subscriptions,
    )
end

export C2S, S2C, Request, Response, build_connection_summary

end
