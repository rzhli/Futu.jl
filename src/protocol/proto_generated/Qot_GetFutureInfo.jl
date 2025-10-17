module Qot_GetFutureInfo

import ProtoBuf as PB
import ..Common
import ..Qot_Common

# 交易时间
mutable struct TradeTime
    begin_::Float64  # 开始时间,以分钟为单位
    end_::Float64    # 结束时间,以分钟为单位
end
PB.default_values(::Type{TradeTime}) = (; begin_ = zero(Float64), end_ = zero(Float64))
PB.field_numbers(::Type{TradeTime}) = (; begin_ = 1, end_ = 2)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:TradeTime})
    begin_ = zero(Float64)
    end_ = zero(Float64)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            begin_ = PB.decode(d, Float64)
        elseif field_number == 2
            end_ = PB.decode(d, Float64)
        else
            PB.skip(d, wire_type)
        end
    end
    return TradeTime(begin_, end_)
end

# 期货合约资料
mutable struct FutureInfo
    name::String                          # 合约名称
    security::Qot_Common.Security         # 合约代码
    lastTradeTime::String                 # 最后交易日
    lastTradeTimestamp::Float64           # 最后交易日时间戳
    owner::Qot_Common.Security            # 标的股
    ownerOther::String                    # 标的
    exchange::String                      # 交易所
    contractType::String                  # 合约类型
    contractSize::Float64                 # 合约规模
    contractSizeUnit::String              # 合约规模的单位
    quoteCurrency::String                 # 报价货币
    minVar::Float64                       # 最小变动单位
    minVarUnit::String                    # 最小变动单位的单位
    quoteUnit::String                     # 报价单位
    tradeTime::Vector{TradeTime}          # 交易时间
    timeZone::String                      # 所在时区
    exchangeFormatUrl::String             # 交易所规格
    origin::Qot_Common.Security           # 实际合约代码
    FutureInfo(; name = "", security = Qot_Common.Security(), lastTradeTime = "", lastTradeTimestamp = 0.0, owner = Qot_Common.Security(), ownerOther = "", exchange = "", contractType = "", contractSize = 0.0, contractSizeUnit = "", quoteCurrency = "", minVar = 0.0, minVarUnit = "", quoteUnit = "", tradeTime = Vector{TradeTime}(), timeZone = "", exchangeFormatUrl = "", origin = Qot_Common.Security()) = new(name, security, lastTradeTime, lastTradeTimestamp, owner, ownerOther, exchange, contractType, contractSize, contractSizeUnit, quoteCurrency, minVar, minVarUnit, quoteUnit, tradeTime, timeZone, exchangeFormatUrl, origin)
end
PB.default_values(::Type{FutureInfo}) = (; name = "", security = Qot_Common.Security(), lastTradeTime = "", lastTradeTimestamp = zero(Float64), owner = Qot_Common.Security(), ownerOther = "", exchange = "", contractType = "", contractSize = zero(Float64), contractSizeUnit = "", quoteCurrency = "", minVar = zero(Float64), minVarUnit = "", quoteUnit = "", tradeTime = Vector{TradeTime}(), timeZone = "", exchangeFormatUrl = "", origin = Qot_Common.Security())
PB.field_numbers(::Type{FutureInfo}) = (name = 1, security = 2, lastTradeTime = 3, lastTradeTimestamp = 4, owner = 5, ownerOther = 6, exchange = 7, contractType = 8, contractSize = 9, contractSizeUnit = 10, quoteCurrency = 11, minVar = 12, minVarUnit = 13, quoteUnit = 14, tradeTime = 15, timeZone = 16, exchangeFormatUrl = 17, origin = 18)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:FutureInfo})
    name = ""
    security = Qot_Common.Security()
    lastTradeTime = ""
    lastTradeTimestamp = zero(Float64)
    owner = Qot_Common.Security()
    ownerOther = ""
    exchange = ""
    contractType = ""
    contractSize = zero(Float64)
    contractSizeUnit = ""
    quoteCurrency = ""
    minVar = zero(Float64)
    minVarUnit = ""
    quoteUnit = ""
    tradeTime = Vector{TradeTime}()
    timeZone = ""
    exchangeFormatUrl = ""
    origin = Qot_Common.Security()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            name = PB.decode(d, String)
        elseif field_number == 2
            security = PB.decode(d, Ref{Qot_Common.Security})
        elseif field_number == 3
            lastTradeTime = PB.decode(d, String)
        elseif field_number == 4
            lastTradeTimestamp = PB.decode(d, Float64)
        elseif field_number == 5
            owner = PB.decode(d, Ref{Qot_Common.Security})
        elseif field_number == 6
            ownerOther = PB.decode(d, String)
        elseif field_number == 7
            exchange = PB.decode(d, String)
        elseif field_number == 8
            contractType = PB.decode(d, String)
        elseif field_number == 9
            contractSize = PB.decode(d, Float64)
        elseif field_number == 10
            contractSizeUnit = PB.decode(d, String)
        elseif field_number == 11
            quoteCurrency = PB.decode(d, String)
        elseif field_number == 12
            minVar = PB.decode(d, Float64)
        elseif field_number == 13
            minVarUnit = PB.decode(d, String)
        elseif field_number == 14
            quoteUnit = PB.decode(d, String)
        elseif field_number == 15
            push!(tradeTime, PB.decode(d, Ref{TradeTime}))
        elseif field_number == 16
            timeZone = PB.decode(d, String)
        elseif field_number == 17
            exchangeFormatUrl = PB.decode(d, String)
        elseif field_number == 18
            origin = PB.decode(d, Ref{Qot_Common.Security})
        else
            PB.skip(d, wire_type)
        end
    end
    return FutureInfo(name = name, security = security, lastTradeTime = lastTradeTime, lastTradeTimestamp = lastTradeTimestamp, owner = owner, ownerOther = ownerOther,
        exchange = exchange, contractType = contractType, contractSize = contractSize, contractSizeUnit = contractSizeUnit, quoteCurrency = quoteCurrency, minVar = minVar,
        minVarUnit = minVarUnit, quoteUnit = quoteUnit, tradeTime = tradeTime, timeZone = timeZone, exchangeFormatUrl = exchangeFormatUrl, origin = origin
    )
end

# 客户端到服务端请求消息
mutable struct C2S
    securityList::Vector{Qot_Common.Security}  # 股票列表
    C2S(; securityList = Vector{Qot_Common.Security}()) = new(securityList)
end
PB.default_values(::Type{C2S}) = (; securityList = Vector{Qot_Common.Security}())
PB.field_numbers(::Type{C2S}) = (; securityList = 1)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    for security in x.securityList
        PB.encode(e, 1, security)
    end
    return position(e.io) - initpos
end

# 服务端到客户端响应消息
mutable struct S2C
    futureInfoList::Vector{FutureInfo}  # 期货合约资料的列表
    S2C(; futureInfoList = Vector{FutureInfo}()) = new(futureInfoList)
end
PB.default_values(::Type{S2C}) = (; futureInfoList = Vector{FutureInfo}())
PB.field_numbers(::Type{S2C}) = (; futureInfoList = 1)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    futureInfoList = Vector{FutureInfo}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            push!(futureInfoList, PB.decode(d, Ref{FutureInfo}))
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(futureInfoList = futureInfoList)
end

# 请求消息
mutable struct Request
    c2s::C2S  # 客户端到服务端请求
    Request(; c2s = C2S()) = new(c2s)
end
PB.default_values(::Type{Request}) = (; c2s = C2S())
PB.field_numbers(::Type{Request}) = (; c2s = 1)
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
PB.default_values(::Type{Response}) = (; retType = Int32(-400), retMsg = "", errCode = zero(Int32), s2c = S2C())
PB.field_numbers(::Type{Response}) = (; retType = 1, retMsg = 2, errCode = 3, s2c = 4)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:Response})
    retType = Int32(-400)
    retMsg = ""
    errCode = zero(Int32)
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
    return Response(retType = retType, retMsg = retMsg, errCode = errCode, s2c = s2c)
end

export TradeTime, FutureInfo, C2S, S2C, Request, Response

end
