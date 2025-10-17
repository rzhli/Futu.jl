module Qot_GetOptionChain

import ProtoBuf as PB
using ProtoBuf.EnumX
import ..Common
import ..Qot_Common

# 期权条件类型枚举
@enumx OptionCondType begin
    Unknow = 0  # 未知
    WithIn = 1  # 价内
    Outside = 2 # 价外
end

# 数据字段筛选条件
mutable struct DataFilter
    impliedVolatilityMin::Float64  # 隐含波动率过滤起点
    impliedVolatilityMax::Float64  # 隐含波动率过滤终点
    deltaMin::Float64              # 希腊值 Delta过滤起点
    deltaMax::Float64              # 希腊值 Delta过滤终点
    gammaMin::Float64              # 希腊值 Gamma过滤起点
    gammaMax::Float64              # 希腊值 Gamma过滤终点
    vegaMin::Float64               # 希腊值 Vega过滤起点
    vegaMax::Float64               # 希腊值 Vega过滤终点
    thetaMin::Float64              # 希腊值 Theta过滤起点
    thetaMax::Float64              # 希腊值 Theta过滤终点
    rhoMin::Float64                # 希腊值 Rho过滤起点
    rhoMax::Float64                # 希腊值 Rho过滤终点
    netOpenInterestMin::Float64    # 净未平仓合约数过滤起点
    netOpenInterestMax::Float64    # 净未平仓合约数过滤终点
    openInterestMin::Float64       # 未平仓合约数过滤起点
    openInterestMax::Float64       # 未平仓合约数过滤终点
    volMin::Float64                # 成交量过滤起点
    volMax::Float64                # 成交量过滤终点
end
function DataFilter(; impliedVolatilityMin::Real = 0.0, impliedVolatilityMax::Real = 0.0, deltaMin::Real = 0.0, deltaMax::Real = 0.0, gammaMin::Real = 0.0,
    gammaMax::Real = 0.0, vegaMin::Real = 0.0, vegaMax::Real = 0.0, thetaMin::Real = 0.0, thetaMax::Real = 0.0, rhoMin::Real = 0.0, rhoMax::Real = 0.0,
    netOpenInterestMin::Real = 0.0, netOpenInterestMax::Real = 0.0, openInterestMin::Real = 0.0, openInterestMax::Real = 0.0, volMin::Real = 0.0, volMax::Real = 0.0
    )
    return DataFilter(Float64(impliedVolatilityMin), Float64(impliedVolatilityMax),
        Float64(deltaMin), Float64(deltaMax), Float64(gammaMin), Float64(gammaMax),
        Float64(vegaMin), Float64(vegaMax), Float64(thetaMin), Float64(thetaMax),
        Float64(rhoMin), Float64(rhoMax), Float64(netOpenInterestMin), Float64(netOpenInterestMax),
        Float64(openInterestMin), Float64(openInterestMax), Float64(volMin), Float64(volMax)
    )
end

PB.default_values(::Type{DataFilter}) = (; impliedVolatilityMin = 0.0, impliedVolatilityMax = 0.0, deltaMin = 0.0, deltaMax = 0.0, gammaMin = 0.0, gammaMax = 0.0,
    vegaMin = 0.0, vegaMax = 0.0, thetaMin = 0.0, thetaMax = 0.0, rhoMin = 0.0, rhoMax = 0.0, netOpenInterestMin = 0.0, netOpenInterestMax = 0.0, openInterestMin = 0.0,
    openInterestMax = 0.0, volMin = 0.0, volMax = 0.0)
PB.field_numbers(::Type{DataFilter}) = (impliedVolatilityMin = 1, impliedVolatilityMax = 2, deltaMin = 3, deltaMax = 4, gammaMin = 5, gammaMax = 6, vegaMin = 7, vegaMax = 8,
    thetaMin = 9, thetaMax = 10, rhoMin = 11, rhoMax = 12, netOpenInterestMin = 13, netOpenInterestMax = 14, openInterestMin = 15, openInterestMax = 16, volMin = 17, volMax = 18)
function PB.encode(e::PB.AbstractProtoEncoder, x::DataFilter)
    initpos = position(e.io)
    x.impliedVolatilityMin != 0.0 && PB.encode(e, 1, x.impliedVolatilityMin)
    x.impliedVolatilityMax != 0.0 && PB.encode(e, 2, x.impliedVolatilityMax)
    x.deltaMin != 0.0 && PB.encode(e, 3, x.deltaMin)
    x.deltaMax != 0.0 && PB.encode(e, 4, x.deltaMax)
    x.gammaMin != 0.0 && PB.encode(e, 5, x.gammaMin)
    x.gammaMax != 0.0 && PB.encode(e, 6, x.gammaMax)
    x.vegaMin != 0.0 && PB.encode(e, 7, x.vegaMin)
    x.vegaMax != 0.0 && PB.encode(e, 8, x.vegaMax)
    x.thetaMin != 0.0 && PB.encode(e, 9, x.thetaMin)
    x.thetaMax != 0.0 && PB.encode(e, 10, x.thetaMax)
    x.rhoMin != 0.0 && PB.encode(e, 11, x.rhoMin)
    x.rhoMax != 0.0 && PB.encode(e, 12, x.rhoMax)
    x.netOpenInterestMin != 0.0 && PB.encode(e, 13, x.netOpenInterestMin)
    x.netOpenInterestMax != 0.0 && PB.encode(e, 14, x.netOpenInterestMax)
    x.openInterestMin != 0.0 && PB.encode(e, 15, x.openInterestMin)
    x.openInterestMax != 0.0 && PB.encode(e, 16, x.openInterestMax)
    x.volMin != 0.0 && PB.encode(e, 17, x.volMin)
    x.volMax != 0.0 && PB.encode(e, 18, x.volMax)
    return position(e.io) - initpos
end
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:DataFilter})
    impliedVolatilityMin = 0.0
    impliedVolatilityMax = 0.0
    deltaMin = 0.0
    deltaMax = 0.0
    gammaMin = 0.0
    gammaMax = 0.0
    vegaMin = 0.0
    vegaMax = 0.0
    thetaMin = 0.0
    thetaMax = 0.0
    rhoMin = 0.0
    rhoMax = 0.0
    netOpenInterestMin = 0.0
    netOpenInterestMax = 0.0
    openInterestMin = 0.0
    openInterestMax = 0.0
    volMin = 0.0
    volMax = 0.0
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            impliedVolatilityMin = PB.decode(d, Float64)
        elseif field_number == 2
            impliedVolatilityMax = PB.decode(d, Float64)
        elseif field_number == 3
            deltaMin = PB.decode(d, Float64)
        elseif field_number == 4
            deltaMax = PB.decode(d, Float64)
        elseif field_number == 5
            gammaMin = PB.decode(d, Float64)
        elseif field_number == 6
            gammaMax = PB.decode(d, Float64)
        elseif field_number == 7
            vegaMin = PB.decode(d, Float64)
        elseif field_number == 8
            vegaMax = PB.decode(d, Float64)
        elseif field_number == 9
            thetaMin = PB.decode(d, Float64)
        elseif field_number == 10
            thetaMax = PB.decode(d, Float64)
        elseif field_number == 11
            rhoMin = PB.decode(d, Float64)
        elseif field_number == 12
            rhoMax = PB.decode(d, Float64)
        elseif field_number == 13
            netOpenInterestMin = PB.decode(d, Float64)
        elseif field_number == 14
            netOpenInterestMax = PB.decode(d, Float64)
        elseif field_number == 15
            openInterestMin = PB.decode(d, Float64)
        elseif field_number == 16
            openInterestMax = PB.decode(d, Float64)
        elseif field_number == 17
            volMin = PB.decode(d, Float64)
        elseif field_number == 18
            volMax = PB.decode(d, Float64)
        else
            PB.skip(d, wire_type)
        end
    end
    return DataFilter(impliedVolatilityMin, impliedVolatilityMax, deltaMin, deltaMax, gammaMin, gammaMax, vegaMin, vegaMax, 
    thetaMin, thetaMax, rhoMin, rhoMax, netOpenInterestMin, netOpenInterestMax, openInterestMin, openInterestMax, volMin, volMax
    )
end

# 客户端到服务端请求消息
mutable struct C2S
    owner::Qot_Common.Security      # 期权标的股，目前仅支持传入港美正股以及恒指国指
    indexOptionType::Int32          # 指数期权的类型，仅用于恒指国指
    type::Int32                     # 期权类型，可选字段，不指定则表示都返回
    condition::Int32                # 价内价外，可选字段，不指定则表示都返回
    beginTime::String               # 期权到期日开始时间
    endTime::String                 # 期权到期日结束时间，时间跨度最多一个月
    dataFilter::DataFilter          # 数据字段筛选
    C2S(; owner = Qot_Common.Security(), indexOptionType = 0, type = 0, condition = 0, beginTime = "", endTime = "", dataFilter = DataFilter()) = new(owner, indexOptionType, type, condition, beginTime, endTime, dataFilter)
end

PB.default_values(::Type{C2S}) = (; owner = Qot_Common.Security(), indexOptionType = Int32(0), type = Int32(0), condition = Int32(0), beginTime = "", endTime = "", dataFilter = DataFilter())
PB.field_numbers(::Type{C2S}) = (owner = 1, type = 2, condition = 3, beginTime = 4, endTime = 5, indexOptionType = 6, dataFilter = 7)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    PB.encode(e, 1, x.owner)
    x.type != Int32(0) && PB.encode(e, 2, x.type)
    x.condition != Int32(0) && PB.encode(e, 3, x.condition)
    !isempty(x.beginTime) && PB.encode(e, 4, x.beginTime)
    !isempty(x.endTime) && PB.encode(e, 5, x.endTime)
    x.indexOptionType != Int32(0) && PB.encode(e, 6, x.indexOptionType)
    x.dataFilter != DataFilter() && PB.encode(e, 7, x.dataFilter)
    return position(e.io) - initpos
end

# 期权项
mutable struct OptionItem
    call::Qot_Common.SecurityStaticInfo  # 看涨期权，不一定有该字段，由请求条件决定
    put::Qot_Common.SecurityStaticInfo   # 看跌期权，不一定有该字段，由请求条件决定
    OptionItem(; call = Qot_Common.SecurityStaticInfo(), put = Qot_Common.SecurityStaticInfo()) = new(call, put)
end

PB.default_values(::Type{OptionItem}) = (; call = Qot_Common.SecurityStaticInfo(), put = Qot_Common.SecurityStaticInfo())
PB.field_numbers(::Type{OptionItem}) = (call = 1, put = 2)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:OptionItem})
    call = Qot_Common.SecurityStaticInfo()
    put = Qot_Common.SecurityStaticInfo()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            call = PB.decode(d, Ref{Qot_Common.SecurityStaticInfo})
        elseif field_number == 2
            put = PB.decode(d, Ref{Qot_Common.SecurityStaticInfo})
        else
            PB.skip(d, wire_type)
        end
    end
    return OptionItem(; call = call, put = put)
end

# 期权链
mutable struct OptionChain
    strikeTime::String              # 行权日
    option::Vector{OptionItem}      # 期权信息
    strikeTimestamp::Float64        # 行权日时间戳
    OptionChain(; strikeTime = "", option = Vector{OptionItem}(), strikeTimestamp = 0.0) = new(strikeTime, option, strikeTimestamp)
end

PB.default_values(::Type{OptionChain}) = (; strikeTime = "", option = Vector{OptionItem}(), strikeTimestamp = 0.0)
PB.field_numbers(::Type{OptionChain}) = (strikeTime = 1, option = 2, strikeTimestamp = 3)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:OptionChain})
    strikeTime = ""
    option = PB.BufferedVector{OptionItem}()
    strikeTimestamp = 0.0
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            strikeTime = PB.decode(d, String)
        elseif field_number == 2
            PB.decode!(d, option)
        elseif field_number == 3
            strikeTimestamp = PB.decode(d, Float64)
        else
            PB.skip(d, wire_type)
        end
    end
    return OptionChain(; strikeTime = strikeTime, option = option[], strikeTimestamp = strikeTimestamp)
end

# 服务端到客户端响应消息
mutable struct S2C
    optionChain::Vector{OptionChain}  # 期权链
    S2C(; optionChain = Vector{OptionChain}()) = new(optionChain)
end

PB.default_values(::Type{S2C}) = (; optionChain = Vector{OptionChain}())
PB.field_numbers(::Type{S2C}) = (optionChain = 1,)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    optionChain = PB.BufferedVector{OptionChain}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            PB.decode!(d, optionChain)
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(; optionChain = optionChain[])
end

# 请求消息
mutable struct Request
    c2s::C2S  # 客户端到服务端请求
    Request(; c2s = C2S()) = new(c2s)
end

PB.default_values(::Type{Request}) = (; c2s = C2S())
PB.field_numbers(::Type{Request}) = (c2s = 1,)
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

PB.default_values(::Type{Response}) = (; retType = Int32(-400), retMsg = "", errCode = Int32(0), s2c = S2C())
PB.field_numbers(::Type{Response}) = (retType = 1, retMsg = 2, errCode = 3, s2c = 4)

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
    return Response(; retType = retType, retMsg = retMsg, errCode = errCode, s2c = s2c)
end

export OptionCondType, DataFilter, C2S, OptionItem, OptionChain, S2C, Request, Response

end
