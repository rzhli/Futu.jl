module Qot_GetWarrant

import ProtoBuf as PB
import ..Common
import ..Qot_Common

# 客户端到服务端请求消息
mutable struct C2S
    begin_::Int32                   # 数据起始点
    num::Int32                      # 请求数据个数，最大200
    sortField::Int32                # 根据哪个字段排序
    ascend::Bool                    # 升序true，降序false
    owner::Qot_Common.Security      # 所属正股
    typeList::Vector{Int32}         # 窝轮类型过滤列表
    issuerList::Vector{Int32}       # 发行人过滤列表
    maturityTimeMin::String         # 到期日范围的开始时间戳
    maturityTimeMax::String         # 到期日范围的结束时间戳
    ipoPeriod::Int32                # 上市日
    priceType::Int32                # 价内/价外（暂不支持界内证的界内外筛选）
    status::Int32                   # 窝轮状态
    curPriceMin::Float64            # 最新价的过滤下限（闭区间）
    curPriceMax::Float64            # 最新价的过滤上限（闭区间）
    strikePriceMin::Float64         # 行使价的过滤下限（闭区间）
    strikePriceMax::Float64         # 行使价的过滤上限（闭区间）
    streetMin::Float64              # 街货占比的过滤下限（闭区间）
    streetMax::Float64              # 街货占比的过滤上限（闭区间）
    conversionMin::Float64          # 换股比率的过滤下限（闭区间）
    conversionMax::Float64          # 换股比率的过滤上限（闭区间）
    volMin::UInt64                  # 成交量的过滤下限（闭区间）
    volMax::UInt64                  # 成交量的过滤上限（闭区间）
    premiumMin::Float64             # 溢价的过滤下限（闭区间）
    premiumMax::Float64             # 溢价的过滤上限（闭区间）
    leverageRatioMin::Float64       # 杠杆比率的过滤下限（闭区间）
    leverageRatioMax::Float64       # 杠杆比率的过滤上限（闭区间）
    deltaMin::Float64               # 对冲值的过滤下限（闭区间）
    deltaMax::Float64               # 对冲值的过滤上限（闭区间）
    impliedMin::Float64             # 引伸波幅的过滤下限（闭区间）
    impliedMax::Float64             # 引伸波幅的过滤上限（闭区间）
    recoveryPriceMin::Float64       # 收回价的过滤下限（闭区间）
    recoveryPriceMax::Float64       # 收回价的过滤上限（闭区间）
    priceRecoveryRatioMin::Float64  # 正股距收回价的过滤下限（闭区间）
    priceRecoveryRatioMax::Float64  # 正股距收回价的过滤上限（闭区间）
    C2S(; begin_ = 0, num = 0, sortField = 0, ascend = false, owner = Qot_Common.Security(), typeList = Vector{Int32}(), issuerList = Vector{Int32}(), maturityTimeMin = "", maturityTimeMax = "", ipoPeriod = 0, priceType = 0, status = 0, curPriceMin = 0.0, curPriceMax = 0.0, strikePriceMin = 0.0, strikePriceMax = 0.0, streetMin = 0.0, streetMax = 0.0, conversionMin = 0.0, conversionMax = 0.0, volMin = 0, volMax = 0, premiumMin = 0.0, premiumMax = 0.0, leverageRatioMin = 0.0, leverageRatioMax = 0.0, deltaMin = 0.0, deltaMax = 0.0, impliedMin = 0.0, impliedMax = 0.0, recoveryPriceMin = 0.0, recoveryPriceMax = 0.0, priceRecoveryRatioMin = 0.0, priceRecoveryRatioMax = 0.0) = new(begin_, num, sortField, ascend, owner, typeList, issuerList, maturityTimeMin, maturityTimeMax, ipoPeriod, priceType, status, curPriceMin, curPriceMax, strikePriceMin, strikePriceMax, streetMin, streetMax, conversionMin, conversionMax, volMin, volMax, premiumMin, premiumMax, leverageRatioMin, leverageRatioMax, deltaMin, deltaMax, impliedMin, impliedMax, recoveryPriceMin, recoveryPriceMax, priceRecoveryRatioMin, priceRecoveryRatioMax)
end
PB.default_values(::Type{C2S}) = (;begin_ = zero(Int32), num = zero(Int32), sortField = zero(Int32), ascend = false, owner = Qot_Common.Security(), typeList = Vector{Int32}(), issuerList = Vector{Int32}(), maturityTimeMin = "", maturityTimeMax = "", ipoPeriod = zero(Int32), priceType = zero(Int32), status = zero(Int32), curPriceMin = zero(Float64), curPriceMax = zero(Float64), strikePriceMin = zero(Float64), strikePriceMax = zero(Float64), streetMin = zero(Float64), streetMax = zero(Float64), conversionMin = zero(Float64), conversionMax = zero(Float64), volMin = zero(UInt64), volMax = zero(UInt64), premiumMin = zero(Float64), premiumMax = zero(Float64), leverageRatioMin = zero(Float64), leverageRatioMax = zero(Float64), deltaMin = zero(Float64), deltaMax = zero(Float64), impliedMin = zero(Float64), impliedMax = zero(Float64), recoveryPriceMin = zero(Float64), recoveryPriceMax = zero(Float64), priceRecoveryRatioMin = zero(Float64), priceRecoveryRatioMax = zero(Float64))
PB.field_numbers(::Type{C2S}) = (;begin_ = 1, num = 2, sortField = 3, ascend = 4, owner = 5, typeList = 6, issuerList = 7, maturityTimeMin = 8, maturityTimeMax = 9, ipoPeriod = 10, priceType = 11, status = 12, curPriceMin = 13, curPriceMax = 14, strikePriceMin = 15, strikePriceMax = 16, streetMin = 17, streetMax = 18, conversionMin = 19, conversionMax = 20, volMin = 21, volMax = 22, premiumMin = 23, premiumMax = 24, leverageRatioMin = 25, leverageRatioMax = 26, deltaMin = 27, deltaMax = 28, impliedMin = 29, impliedMax = 30, recoveryPriceMin = 31, recoveryPriceMax = 32, priceRecoveryRatioMin = 33, priceRecoveryRatioMax = 34)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    PB.encode(e, 1, x.begin_)
    PB.encode(e, 2, x.num)
    PB.encode(e, 3, x.sortField)
    PB.encode(e, 4, x.ascend)
    PB.encode(e, 5, x.owner)
    !isempty(x.typeList) && PB.encode(e, 6, x.typeList)
    !isempty(x.issuerList) && PB.encode(e, 7, x.issuerList)
    x.maturityTimeMin != "" && PB.encode(e, 8, x.maturityTimeMin)
    x.maturityTimeMax != "" && PB.encode(e, 9, x.maturityTimeMax)
    x.ipoPeriod != zero(Int32) && PB.encode(e, 10, x.ipoPeriod)
    x.priceType != zero(Int32) && PB.encode(e, 11, x.priceType)
    x.status != zero(Int32) && PB.encode(e, 12, x.status)
    x.curPriceMin != zero(Float64) && PB.encode(e, 13, x.curPriceMin)
    x.curPriceMax != zero(Float64) && PB.encode(e, 14, x.curPriceMax)
    x.strikePriceMin != zero(Float64) && PB.encode(e, 15, x.strikePriceMin)
    x.strikePriceMax != zero(Float64) && PB.encode(e, 16, x.strikePriceMax)
    x.streetMin != zero(Float64) && PB.encode(e, 17, x.streetMin)
    x.streetMax != zero(Float64) && PB.encode(e, 18, x.streetMax)
    x.conversionMin != zero(Float64) && PB.encode(e, 19, x.conversionMin)
    x.conversionMax != zero(Float64) && PB.encode(e, 20, x.conversionMax)
    x.volMin != zero(UInt64) && PB.encode(e, 21, x.volMin)
    x.volMax != zero(UInt64) && PB.encode(e, 22, x.volMax)
    x.premiumMin != zero(Float64) && PB.encode(e, 23, x.premiumMin)
    x.premiumMax != zero(Float64) && PB.encode(e, 24, x.premiumMax)
    x.leverageRatioMin != zero(Float64) && PB.encode(e, 25, x.leverageRatioMin)
    x.leverageRatioMax != zero(Float64) && PB.encode(e, 26, x.leverageRatioMax)
    x.deltaMin != zero(Float64) && PB.encode(e, 27, x.deltaMin)
    x.deltaMax != zero(Float64) && PB.encode(e, 28, x.deltaMax)
    x.impliedMin != zero(Float64) && PB.encode(e, 29, x.impliedMin)
    x.impliedMax != zero(Float64) && PB.encode(e, 30, x.impliedMax)
    x.recoveryPriceMin != zero(Float64) && PB.encode(e, 31, x.recoveryPriceMin)
    x.recoveryPriceMax != zero(Float64) && PB.encode(e, 32, x.recoveryPriceMax)
    x.priceRecoveryRatioMin != zero(Float64) && PB.encode(e, 33, x.priceRecoveryRatioMin)
    x.priceRecoveryRatioMax != zero(Float64) && PB.encode(e, 34, x.priceRecoveryRatioMax)
    return position(e.io) - initpos
end

# 窝轮数据
mutable struct WarrantData
    # 静态数据项
    stock::Qot_Common.Security      # 股票
    owner::Qot_Common.Security       # 所属正股
    type::Int32                     # 窝轮类型
    issuer::Int32                   # 发行人
    maturityTime::String            # 到期日
    maturityTimestamp::Float64      # 到期日时间戳
    listTime::String                # 上市时间
    listTimestamp::Float64          # 上市时间戳
    lastTradeTime::String           # 最后交易日
    lastTradeTimestamp::Float64     # 最后交易日时间戳
    recoveryPrice::Float64          # 收回价，仅牛熊证支持此字段
    conversionRatio::Float64        # 换股比率
    lotSize::Int32                  # 每手数量
    strikePrice::Float64            # 行使价
    lastClosePrice::Float64         # 昨收价
    name::String                    # 名称

    # 动态数据项
    curPrice::Float64               # 当前价
    priceChangeVal::Float64         # 涨跌额
    changeRate::Float64             # 涨跌幅
    status::Int32                   # 窝轮状态
    bidPrice::Float64               # 买入价
    askPrice::Float64               # 卖出价
    bidVol::Int64                   # 买量
    askVol::Int64                   # 卖量
    volume::Int64                   # 成交量
    turnover::Float64               # 成交额
    score::Float64                  # 综合评分
    premium::Float64                # 溢价
    breakEvenPoint::Float64         # 打和点
    leverage::Float64               # 杠杆比率（倍）
    ipop::Float64                   # 价内/价外，正数表示价内，负数表示价外
    priceRecoveryRatio::Float64     # 正股距收回价，仅牛熊证支持此字段
    conversionPrice::Float64        # 换股价
    streetRate::Float64             # 街货占比
    streetVol::Int64                # 街货量
    amplitude::Float64              # 振幅
    issueSize::Int64                # 发行量
    highPrice::Float64              # 最高价
    lowPrice::Float64               # 最低价
    impliedVolatility::Float64      # 引申波幅，仅认购认沽支持此字段
    delta::Float64                  # 对冲值，仅认购认沽支持此字段
    effectiveLeverage::Float64      # 有效杠杆
    upperStrikePrice::Float64       # 上限价，仅界内证支持此字段
    lowerStrikePrice::Float64       # 下限价，仅界内证支持此字段
    inLinePriceStatus::Int32        # 界内界外，仅界内证支持此字段
    WarrantData(; stock = Qot_Common.Security(), owner = Qot_Common.Security(), type = 0, issuer = 0, maturityTime = "", maturityTimestamp = 0.0, listTime = "", listTimestamp = 0.0, lastTradeTime = "", lastTradeTimestamp = 0.0, recoveryPrice = 0.0, conversionRatio = 0.0, lotSize = 0, strikePrice = 0.0, lastClosePrice = 0.0, name = "", curPrice = 0.0, priceChangeVal = 0.0, changeRate = 0.0, status = 0, bidPrice = 0.0, askPrice = 0.0, bidVol = 0, askVol = 0, volume = 0, turnover = 0.0, score = 0.0, premium = 0.0, breakEvenPoint = 0.0, leverage = 0.0, ipop = 0.0, priceRecoveryRatio = 0.0, conversionPrice = 0.0, streetRate = 0.0, streetVol = 0, amplitude = 0.0, issueSize = 0, highPrice = 0.0, lowPrice = 0.0, impliedVolatility = 0.0, delta = 0.0, effectiveLeverage = 0.0, upperStrikePrice = 0.0, lowerStrikePrice = 0.0, inLinePriceStatus = 0) = new(stock, owner, type, issuer, maturityTime, maturityTimestamp, listTime, listTimestamp, lastTradeTime, lastTradeTimestamp, recoveryPrice, conversionRatio, lotSize, strikePrice, lastClosePrice, name, curPrice, priceChangeVal, changeRate, status, bidPrice, askPrice, bidVol, askVol, volume, turnover, score, premium, breakEvenPoint, leverage, ipop, priceRecoveryRatio, conversionPrice, streetRate, streetVol, amplitude, issueSize, highPrice, lowPrice, impliedVolatility, delta, effectiveLeverage, upperStrikePrice, lowerStrikePrice, inLinePriceStatus)
end
PB.default_values(::Type{WarrantData}) = (;stock = Qot_Common.Security(), owner = Qot_Common.Security(), type = zero(Int32), issuer = zero(Int32), maturityTime = "", maturityTimestamp = zero(Float64), listTime = "", listTimestamp = zero(Float64), lastTradeTime = "", lastTradeTimestamp = zero(Float64), recoveryPrice = zero(Float64), conversionRatio = zero(Float64), lotSize = zero(Int32), strikePrice = zero(Float64), lastClosePrice = zero(Float64), name = "", curPrice = zero(Float64), priceChangeVal = zero(Float64), changeRate = zero(Float64), status = zero(Int32), bidPrice = zero(Float64), askPrice = zero(Float64), bidVol = zero(Int64), askVol = zero(Int64), volume = zero(Int64), turnover = zero(Float64), score = zero(Float64), premium = zero(Float64), breakEvenPoint = zero(Float64), leverage = zero(Float64), ipop = zero(Float64), priceRecoveryRatio = zero(Float64), conversionPrice = zero(Float64), streetRate = zero(Float64), streetVol = zero(Int64), amplitude = zero(Float64), issueSize = zero(Int64), highPrice = zero(Float64), lowPrice = zero(Float64), impliedVolatility = zero(Float64), delta = zero(Float64), effectiveLeverage = zero(Float64), upperStrikePrice = zero(Float64), lowerStrikePrice = zero(Float64), inLinePriceStatus = zero(Int32))
PB.field_numbers(::Type{WarrantData}) = (;stock = 1, owner = 2, type = 3, issuer = 4, maturityTime = 5, maturityTimestamp = 6, listTime = 7, listTimestamp = 8, lastTradeTime = 9, lastTradeTimestamp = 10, recoveryPrice = 11, conversionRatio = 12, lotSize = 13, strikePrice = 14, lastClosePrice = 15, name = 16, curPrice = 17, priceChangeVal = 18, changeRate = 19, status = 20, bidPrice = 21, askPrice = 22, bidVol = 23, askVol = 24, volume = 25, turnover = 26, score = 27, premium = 28, breakEvenPoint = 29, leverage = 30, ipop = 31, priceRecoveryRatio = 32, conversionPrice = 33, streetRate = 34, streetVol = 35, amplitude = 36, issueSize = 37, highPrice = 38, lowPrice = 39, impliedVolatility = 40, delta = 41, effectiveLeverage = 42, upperStrikePrice = 43, lowerStrikePrice = 44, inLinePriceStatus = 45)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:WarrantData})
    stock = Qot_Common.Security()
    owner = Qot_Common.Security()
    type = zero(Int32)
    issuer = zero(Int32)
    maturityTime = ""
    maturityTimestamp = zero(Float64)
    listTime = ""
    listTimestamp = zero(Float64)
    lastTradeTime = ""
    lastTradeTimestamp = zero(Float64)
    recoveryPrice = zero(Float64)
    conversionRatio = zero(Float64)
    lotSize = zero(Int32)
    strikePrice = zero(Float64)
    lastClosePrice = zero(Float64)
    name = ""
    curPrice = zero(Float64)
    priceChangeVal = zero(Float64)
    changeRate = zero(Float64)
    status = zero(Int32)
    bidPrice = zero(Float64)
    askPrice = zero(Float64)
    bidVol = zero(Int64)
    askVol = zero(Int64)
    volume = zero(Int64)
    turnover = zero(Float64)
    score = zero(Float64)
    premium = zero(Float64)
    breakEvenPoint = zero(Float64)
    leverage = zero(Float64)
    ipop = zero(Float64)
    priceRecoveryRatio = zero(Float64)
    conversionPrice = zero(Float64)
    streetRate = zero(Float64)
    streetVol = zero(Int64)
    amplitude = zero(Float64)
    issueSize = zero(Int64)
    highPrice = zero(Float64)
    lowPrice = zero(Float64)
    impliedVolatility = zero(Float64)
    delta = zero(Float64)
    effectiveLeverage = zero(Float64)
    upperStrikePrice = zero(Float64)
    lowerStrikePrice = zero(Float64)
    inLinePriceStatus = zero(Int32)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            stock = PB.decode(d, Ref{Qot_Common.Security})
        elseif field_number == 2
            owner = PB.decode(d, Ref{Qot_Common.Security})
        elseif field_number == 3
            type = PB.decode(d, Int32)
        elseif field_number == 4
            issuer = PB.decode(d, Int32)
        elseif field_number == 5
            maturityTime = PB.decode(d, String)
        elseif field_number == 6
            maturityTimestamp = PB.decode(d, Float64)
        elseif field_number == 7
            listTime = PB.decode(d, String)
        elseif field_number == 8
            listTimestamp = PB.decode(d, Float64)
        elseif field_number == 9
            lastTradeTime = PB.decode(d, String)
        elseif field_number == 10
            lastTradeTimestamp = PB.decode(d, Float64)
        elseif field_number == 11
            recoveryPrice = PB.decode(d, Float64)
        elseif field_number == 12
            conversionRatio = PB.decode(d, Float64)
        elseif field_number == 13
            lotSize = PB.decode(d, Int32)
        elseif field_number == 14
            strikePrice = PB.decode(d, Float64)
        elseif field_number == 15
            lastClosePrice = PB.decode(d, Float64)
        elseif field_number == 16
            name = PB.decode(d, String)
        elseif field_number == 17
            curPrice = PB.decode(d, Float64)
        elseif field_number == 18
            priceChangeVal = PB.decode(d, Float64)
        elseif field_number == 19
            changeRate = PB.decode(d, Float64)
        elseif field_number == 20
            status = PB.decode(d, Int32)
        elseif field_number == 21
            bidPrice = PB.decode(d, Float64)
        elseif field_number == 22
            askPrice = PB.decode(d, Float64)
        elseif field_number == 23
            bidVol = PB.decode(d, Int64)
        elseif field_number == 24
            askVol = PB.decode(d, Int64)
        elseif field_number == 25
            volume = PB.decode(d, Int64)
        elseif field_number == 26
            turnover = PB.decode(d, Float64)
        elseif field_number == 27
            score = PB.decode(d, Float64)
        elseif field_number == 28
            premium = PB.decode(d, Float64)
        elseif field_number == 29
            breakEvenPoint = PB.decode(d, Float64)
        elseif field_number == 30
            leverage = PB.decode(d, Float64)
        elseif field_number == 31
            ipop = PB.decode(d, Float64)
        elseif field_number == 32
            priceRecoveryRatio = PB.decode(d, Float64)
        elseif field_number == 33
            conversionPrice = PB.decode(d, Float64)
        elseif field_number == 34
            streetRate = PB.decode(d, Float64)
        elseif field_number == 35
            streetVol = PB.decode(d, Int64)
        elseif field_number == 36
            amplitude = PB.decode(d, Float64)
        elseif field_number == 37
            issueSize = PB.decode(d, Int64)
        elseif field_number == 38
            highPrice = PB.decode(d, Float64)
        elseif field_number == 39
            lowPrice = PB.decode(d, Float64)
        elseif field_number == 40
            impliedVolatility = PB.decode(d, Float64)
        elseif field_number == 41
            delta = PB.decode(d, Float64)
        elseif field_number == 42
            effectiveLeverage = PB.decode(d, Float64)
        elseif field_number == 43
            upperStrikePrice = PB.decode(d, Float64)
        elseif field_number == 44
            lowerStrikePrice = PB.decode(d, Float64)
        elseif field_number == 45
            inLinePriceStatus = PB.decode(d, Int32)
        else
            PB.skip(d, wire_type)
        end
    end
    return WarrantData(stock=stock, owner=owner, type=type, issuer=issuer, maturityTime=maturityTime, maturityTimestamp=maturityTimestamp, listTime=listTime, listTimestamp=listTimestamp, lastTradeTime=lastTradeTime, lastTradeTimestamp=lastTradeTimestamp, recoveryPrice=recoveryPrice, conversionRatio=conversionRatio, lotSize=lotSize, strikePrice=strikePrice, lastClosePrice=lastClosePrice, name=name, curPrice=curPrice, priceChangeVal=priceChangeVal, changeRate=changeRate, status=status, bidPrice=bidPrice, askPrice=askPrice, bidVol=bidVol, askVol=askVol, volume=volume, turnover=turnover, score=score, premium=premium, breakEvenPoint=breakEvenPoint, leverage=leverage, ipop=ipop, priceRecoveryRatio=priceRecoveryRatio, conversionPrice=conversionPrice, streetRate=streetRate, streetVol=streetVol, amplitude=amplitude, issueSize=issueSize, highPrice=highPrice, lowPrice=lowPrice, impliedVolatility=impliedVolatility, delta=delta, effectiveLeverage=effectiveLeverage, upperStrikePrice=upperStrikePrice, lowerStrikePrice=lowerStrikePrice, inLinePriceStatus=inLinePriceStatus)
end

# 服务端到客户端响应消息
mutable struct S2C
    lastPage::Bool                   # 是否最后一页了
    allCount::Int32                  # 该条件请求所有数据的个数
    warrantDataList::Vector{WarrantData}  # 窝轮数据
    S2C(; lastPage = false, allCount = 0, warrantDataList = Vector{WarrantData}()) = new(lastPage, allCount, warrantDataList)
end
PB.default_values(::Type{S2C}) = (;lastPage = false, allCount = zero(Int32), warrantDataList = Vector{WarrantData}())
PB.field_numbers(::Type{S2C}) = (;lastPage = 1, allCount = 2, warrantDataList = 3)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    lastPage = false
    allCount = zero(Int32)
    warrantDataList = PB.BufferedVector{WarrantData}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            lastPage = PB.decode(d, Bool)
        elseif field_number == 2
            allCount = PB.decode(d, Int32)
        elseif field_number == 3
            PB.decode!(d, warrantDataList)
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(lastPage=lastPage, allCount=allCount, warrantDataList=warrantDataList[])
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
    retType = -400
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
    return Response(; retType = retType, retMsg = retMsg, errCode = errCode, s2c = s2c)
end

export C2S, WarrantData, S2C, Request, Response

end
