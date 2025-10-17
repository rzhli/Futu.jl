"""
    Trd_GetMarginRatio

查询账户融资融券数据模块 (Query account margin data module)

Protocol ID: 2223 (0x08AF)

此协议用于查询融资融券账户的保证金比率信息，包括是否允许做多/做空、可融券数量、融券费率、
各种保证金比率等信息。仅适用于融资融券账户。

This protocol is used to query margin ratio information for margin trading accounts, including
whether long/short positions are allowed, available shares for shorting, short fee rates,
and various margin ratios. Only available for margin accounts.

Request frequency limit: 10 requests per 30 seconds per account ID
Maximum: 100 securities per request
"""
module Trd_GetMarginRatio

import ProtoBuf as PB
using ProtoBuf.EnumX
import ..Trd_Common
import ..Qot_Common

"""
    MarginRatioInfo

单个证券的融资融券信息 (Margin ratio information for a single security)

Fields:
- security: 股票标识 (Security identifier)
- isLongPermit: 是否允许做多 (Whether long position is allowed)
- isShortPermit: 是否允许做空 (Whether short selling is allowed)
- shortPoolRemain: 可融券数量 (Remaining shares available for short selling)
- shortFeeRate: 融券年利率(%) (Short selling annual interest rate in %)
- alertLongRatio: 多头预警比率(%) (Long alert ratio in %)
- alertShortRatio: 空头预警比率(%) (Short alert ratio in %)
- imLongRatio: 多头初始保证金比率(%) (Long initial margin ratio in %)
- imShortRatio: 空头初始保证金比率(%) (Short initial margin ratio in %)
- mcmLongRatio: 多头强制平仓保证金比率(%) (Long liquidation margin ratio in %)
- mcmShortRatio: 空头强制平仓保证金比率(%) (Short liquidation margin ratio in %)
- mmLongRatio: 多头维持保证金比率(%) (Long maintenance margin ratio in %)
- mmShortRatio: 空头维持保证金比率(%) (Short maintenance margin ratio in %)
"""
mutable struct MarginRatioInfo
    security::Qot_Common.Security              # 股票标识
    isLongPermit::Bool                         # 是否允许做多
    isShortPermit::Bool                        # 是否允许做空
    shortPoolRemain::Float64                   # 可融券数量
    shortFeeRate::Float64                      # 融券年利率(%)
    alertLongRatio::Float64                    # 多头预警比率(%)
    alertShortRatio::Float64                   # 空头预警比率(%)
    imLongRatio::Float64                       # 多头初始保证金比率(%)
    imShortRatio::Float64                      # 空头初始保证金比率(%)
    mcmLongRatio::Float64                      # 多头强制平仓保证金比率(%)
    mcmShortRatio::Float64                     # 空头强制平仓保证金比率(%)
    mmLongRatio::Float64                       # 多头维持保证金比率(%)
    mmShortRatio::Float64                      # 空头维持保证金比率(%)
    MarginRatioInfo(; security = Qot_Common.Security(), isLongPermit = false, isShortPermit = false, shortPoolRemain = 0.0, shortFeeRate = 0.0, alertLongRatio = 0.0, alertShortRatio = 0.0, imLongRatio = 0.0, imShortRatio = 0.0, mcmLongRatio = 0.0, mcmShortRatio = 0.0, mmLongRatio = 0.0, mmShortRatio = 0.0) = new(security, isLongPermit, isShortPermit, shortPoolRemain, shortFeeRate, alertLongRatio, alertShortRatio, imLongRatio, imShortRatio, mcmLongRatio, mcmShortRatio, mmLongRatio, mmShortRatio)
end

PB.default_values(::Type{MarginRatioInfo}) = (;security = Qot_Common.Security(), isLongPermit = false, isShortPermit = false, shortPoolRemain = 0.0, shortFeeRate = 0.0, alertLongRatio = 0.0, alertShortRatio = 0.0, imLongRatio = 0.0, imShortRatio = 0.0, mcmLongRatio = 0.0, mcmShortRatio = 0.0, mmLongRatio = 0.0, mmShortRatio = 0.0)
PB.field_numbers(::Type{MarginRatioInfo}) = (;security = 1, isLongPermit = 2, isShortPermit = 3, shortPoolRemain = 4, shortFeeRate = 5, alertLongRatio = 6, alertShortRatio = 7, imLongRatio = 8, imShortRatio = 9, mcmLongRatio = 10, mcmShortRatio = 11, mmLongRatio = 12, mmShortRatio = 13)

# ProtoBuf 解码函数 (ProtoBuf decode function)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:MarginRatioInfo})
    security = Qot_Common.Security()
    isLongPermit = false
    isShortPermit = false
    shortPoolRemain = 0.0
    shortFeeRate = 0.0
    alertLongRatio = 0.0
    alertShortRatio = 0.0
    imLongRatio = 0.0
    imShortRatio = 0.0
    mcmLongRatio = 0.0
    mcmShortRatio = 0.0
    mmLongRatio = 0.0
    mmShortRatio = 0.0
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            security = PB.decode(d, Ref{Qot_Common.Security})
        elseif field_number == 2
            isLongPermit = PB.decode(d, Bool)
        elseif field_number == 3
            isShortPermit = PB.decode(d, Bool)
        elseif field_number == 4
            shortPoolRemain = PB.decode(d, Float64)
        elseif field_number == 5
            shortFeeRate = PB.decode(d, Float64)
        elseif field_number == 6
            alertLongRatio = PB.decode(d, Float64)
        elseif field_number == 7
            alertShortRatio = PB.decode(d, Float64)
        elseif field_number == 8
            imLongRatio = PB.decode(d, Float64)
        elseif field_number == 9
            imShortRatio = PB.decode(d, Float64)
        elseif field_number == 10
            mcmLongRatio = PB.decode(d, Float64)
        elseif field_number == 11
            mcmShortRatio = PB.decode(d, Float64)
        elseif field_number == 12
            mmLongRatio = PB.decode(d, Float64)
        elseif field_number == 13
            mmShortRatio = PB.decode(d, Float64)
        else
            PB.skip(d, wire_type)
        end
    end
    return MarginRatioInfo(security = security, isLongPermit = isLongPermit, isShortPermit = isShortPermit,
        shortPoolRemain = shortPoolRemain, shortFeeRate = shortFeeRate, alertLongRatio = alertLongRatio,
        alertShortRatio = alertShortRatio, imLongRatio = imLongRatio, imShortRatio = imShortRatio,
        mcmLongRatio = mcmLongRatio, mcmShortRatio = mcmShortRatio, mmLongRatio = mmLongRatio, mmShortRatio = mmShortRatio)
end

"""
    C2S

客户端到服务端请求结构 (Client to Server request structure)

Fields:
- header: 交易公共参数头 (Trading common header)
- securityList: 股票列表，最多100个 (Security list, max 100 securities)
"""
mutable struct C2S
    header::Trd_Common.TrdHeader               # 交易公共参数头
    securityList::Vector{Qot_Common.Security}  # 股票列表，最多100个
    C2S(; header = Trd_Common.TrdHeader(), securityList = Vector{Qot_Common.Security}()) = new(header, securityList)
end

PB.default_values(::Type{C2S}) = (;header = Trd_Common.TrdHeader(), securityList = Vector{Qot_Common.Security}())
PB.field_numbers(::Type{C2S}) = (;header = 1, securityList = 2)

# ProtoBuf 编码函数 (ProtoBuf encode function)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    PB.encode(e, 1, x.header)
    !isempty(x.securityList) && PB.encode(e, 2, x.securityList)
    return position(e.io) - initpos
end

"""
    S2C

服务端到客户端响应结构 (Server to Client response structure)

Fields:
- header: 交易公共参数头 (Trading common header)
- marginRatioInfoList: 融资融券数据列表 (List of margin ratio information)
"""
mutable struct S2C
    header::Trd_Common.TrdHeader                   # 交易公共参数头
    marginRatioInfoList::Vector{MarginRatioInfo}   # 融资融券数据列表
    S2C(; header = Trd_Common.TrdHeader(), marginRatioInfoList = Vector{MarginRatioInfo}()) = new(header, marginRatioInfoList)
end

PB.default_values(::Type{S2C}) = (;header = Trd_Common.TrdHeader(), marginRatioInfoList = Vector{MarginRatioInfo}())
PB.field_numbers(::Type{S2C}) = (;header = 1, marginRatioInfoList = 2)

# ProtoBuf 解码函数 (ProtoBuf decode function)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    header = Trd_Common.TrdHeader()
    marginRatioInfoList = Vector{MarginRatioInfo}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            header = PB.decode(d, Ref{Trd_Common.TrdHeader})
        elseif field_number == 2
            push!(marginRatioInfoList, PB.decode(d, Ref{MarginRatioInfo}))
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(header = header, marginRatioInfoList = marginRatioInfoList)
end

"""
    Request

完整的请求消息 (Complete request message)

Fields:
- c2s: 客户端到服务端请求数据 (Client to Server request data)
"""
mutable struct Request
    c2s::C2S  # 客户端到服务端请求数据
    Request(; c2s = C2S()) = new(c2s)
end

PB.default_values(::Type{Request}) = (;c2s = C2S())
PB.field_numbers(::Type{Request}) = (;c2s = 1)

# ProtoBuf 编码函数 (ProtoBuf encode function)
function PB.encode(e::PB.AbstractProtoEncoder, x::Request)
    initpos = position(e.io)
    PB.encode(e, 1, x.c2s)
    return position(e.io) - initpos
end

"""
    Response

完整的响应消息 (Complete response message)

Fields:
- retType: 返回结果类型，0表示成功，其他值表示失败 (Return result type, 0 means success, other values mean failure)
- retMsg: 返回结果描述 (Return result description)
- errCode: 错误码 (Error code)
- s2c: 服务端到客户端响应数据 (Server to Client response data)
"""
mutable struct Response
    retType::Int32   # 返回结果类型
    retMsg::String   # 返回结果描述
    errCode::Int32   # 错误码
    s2c::S2C         # 服务端到客户端响应数据
    Response(; retType = -400, retMsg = "", errCode = 0, s2c = S2C()) = new(retType, retMsg, errCode, s2c)
end

PB.default_values(::Type{Response}) = (;retType = Int32(-400), retMsg = "", errCode = Int32(0), s2c = S2C())
PB.field_numbers(::Type{Response}) = (;retType = 1, retMsg = 2, errCode = 3, s2c = 4)

# ProtoBuf 解码函数 (ProtoBuf decode function)
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
    return Response(retType = retType, retMsg = retMsg, errCode = errCode, s2c = s2c)
end

# 导出所有公共类型 (Export all public types)
export MarginRatioInfo, C2S, S2C, Request, Response

end
