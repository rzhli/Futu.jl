module Qot_RequestTradeDate

import ProtoBuf as PB
import ..Common
import ..Qot_Common

# 客户端到服务端请求消息
mutable struct C2S
    market::Int32                    # 要查询的市场
    beginTime::String                # 开始时间字符串
    endTime::String                  # 结束时间字符串
    security::Qot_Common.Security    # 指定标的
    C2S(; market = 0, beginTime = "", endTime = "", security = Qot_Common.Security()) = new(market, beginTime, endTime, security)
end
PB.default_values(::Type{C2S}) = (;market = 0, beginTime = "", endTime = "", security = Qot_Common.Security())
PB.field_numbers(::Type{C2S}) = (;market = 1, beginTime = 2, endTime = 3, security = 4)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    PB.encode(e, 1, x.market)
    PB.encode(e, 2, x.beginTime)
    PB.encode(e, 3, x.endTime)
    (x.security.market != Int32(0) || x.security.code != "") && PB.encode(e, 4, x.security)
    return position(e.io) - initpos
end
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:C2S})
    market = Int32(0)
    beginTime = ""
    endTime = ""
    security = Qot_Common.Security()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            market = PB.decode(d, Int32)
        elseif field_number == 2
            beginTime = PB.decode(d, String)
        elseif field_number == 3
            endTime = PB.decode(d, String)
        elseif field_number == 4
            security = PB.decode(d, Ref{Qot_Common.Security})
        else
            PB.skip(d, wire_type)
        end
    end
    return C2S(market=market, beginTime=beginTime, endTime=endTime, security=security)
end

# 交易日信息
mutable struct TradeDate
    time::String           # 时间字符串
    timestamp::Float64     # 时间戳
    tradeDateType::Int32   # 交易时间类型
    TradeDate(; time = "", timestamp = 0.0, tradeDateType = 0) = new(time, timestamp, tradeDateType)
end
PB.default_values(::Type{TradeDate}) = (;time = "", timestamp = 0.0, tradeDateType = 0)
PB.field_numbers(::Type{TradeDate}) = (;time = 1, timestamp = 2, tradeDateType = 3)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:TradeDate})
    time = ""
    timestamp = 0.0
    tradeDateType = Int32(0)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            time = PB.decode(d, String)
        elseif field_number == 2
            timestamp = PB.decode(d, Float64)
        elseif field_number == 3
            tradeDateType = PB.decode(d, Int32)
        else
            PB.skip(d, wire_type)
        end
    end
    return TradeDate(time=time, timestamp=timestamp, tradeDateType=tradeDateType)
end

# 服务端到客户端响应消息
mutable struct S2C
    tradeDateList::Vector{TradeDate}  # 交易日,注意该交易日是通过自然日去除周末以及节假日得到，不包括临时休市数据
    S2C(; tradeDateList = Vector{TradeDate}()) = new(tradeDateList)
end
PB.default_values(::Type{S2C}) = (;tradeDateList = Vector{TradeDate}())
PB.field_numbers(::Type{S2C}) = (;tradeDateList = 1)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    tradeDateList = Vector{TradeDate}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            push!(tradeDateList, PB.decode(d, Ref{TradeDate}))
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(tradeDateList=tradeDateList)
end

# 请求消息
mutable struct Request
    c2s::C2S  # 客户端到服务端请求
    Request(; c2s = C2S()) = new(c2s)
end
PB.default_values(::Type{Request}) = (;c2s = C2S())
PB.field_numbers(::Type{Request}) = (;c2s = 1)
function PB.encode(e::PB.AbstractProtoEncoder, x::Request)
    initpos = position(e.io)
    PB.encode(e, 1, x.c2s)
    return position(e.io) - initpos
end

# 响应消息
mutable struct Response
    retType::Int32    # RetType,返回结果
    retMsg::String    # 返回消息
    errCode::Int32    # 错误码
    s2c::S2C          # 服务端到客户端响应
    Response(; retType = -400, retMsg = "", errCode = 0, s2c = S2C()) = new(retType, retMsg, errCode, s2c)
end
PB.default_values(::Type{Response}) = (;retType = -400, retMsg = "", errCode = 0, s2c = S2C())
PB.field_numbers(::Type{Response}) = (;retType = 1, retMsg = 2, errCode = 3, s2c = 4)
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
    return Response(retType=retType, retMsg=retMsg, errCode=errCode, s2c=s2c)
end

export C2S, TradeDate, S2C, Request, Response

end
