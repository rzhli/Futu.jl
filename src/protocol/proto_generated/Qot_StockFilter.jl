module Qot_StockFilter

import ProtoBuf as PB
using ProtoBuf.EnumX
import ..Common
import ..Qot_Common
using ..Qot_Common: KLType

# 简单属性枚举
@enumx StockField begin
    Unknown = 0                                  # 未知
    StockCode = 1                                # 股票代码
    StockName = 2                                # 股票名称
    CurPrice = 3                                 # 最新价
    CurPriceToHighest52WeeksRatio = 4            # (现价 - 52周最高)/52周最高，对应PC端离52周最高
    CurPriceToLowest52WeeksRatio = 5             # (现价 - 52周最低)/52周最低，对应PC端离52周最低
    HighPriceToHighest52WeeksRatio = 6           # (今日最高 - 52周最高)/52周最高
    LowPriceToLowest52WeeksRatio = 7             # (今日最低 - 52周最低)/52周最低
    VolumeRatio = 8                              # 量比
    BidAskRatio = 9                              # 委比
    LotPrice = 10                                # 每手价格
    MarketVal = 11                               # 市值
    PeAnnual = 12                                # 市盈率（静态）
    PeTTM = 13                                   # 市盈率TTM
    PbRate = 14                                  # 市净率
    ChangeRate5min = 15                          # 五分钟价格涨跌幅
    ChangeRateBeginYear = 16                     # 年初至今价格涨跌幅
    PSTTM = 17                                   # 市销率TTM
    PCFTTM = 18                                  # 市现率TTM
    TotalShare = 19                              # 总股数
    FloatShare = 20                              # 流通股数
    FloatMarketVal = 21                          # 流通市值
end

# 累积属性枚举
@enumx AccumulateField begin
    Unknown = 0          # 未知
    ChangeRate = 1       # 涨跌幅
    Amplitude = 2        # 振幅
    Volume = 3           # 日均成交量
    Turnover = 4         # 日均成交额
    TurnoverRate = 5     # 换手率
end

# 财务属性枚举
@enumx FinancialField begin
    Unknown = 0                            # 未知
    NetProfit = 1                          # 净利润
    NetProfitGrowth = 2                    # 净利润增长率
    SumOfBusiness = 3                      # 营业收入
    SumOfBusinessGrowth = 4                # 营业收入增长率
    NetProfitRate = 5                      # 净利率
    GrossProfitRate = 6                    # 毛利率
    DebtAssetsRate = 7                     # 资产负债率
    ReturnOnEquityRate = 8                 # 净资产收益率
    ROIC = 9                               # 盈利能力投入资本回报率
    ROATTM = 10                            # 总资产净利率
    EBITTTM = 11                           # 息税前利润TTM
    EBITDA = 12                            # 息税折旧摊销前利润
    OperatingMarginTTM = 13                # 营业利润率TTM
    EBITMargin = 14                        # EBIT利润率
    EBITDAMargin = 15                      # EBITDA利润率
    FinancialCostRate = 16                 # 财务成本率
    OperatingProfitTTM = 17                # 营业利润TTM
    ShareholderNetProfitTTM = 18           # 股东应占净利润TTM
    NetProfitCashCoverTTM = 19             # 盈利中的现金收入比例TTM
    CurrentRatio = 20                      # 流动比率
    QuickRatio = 21                        # 速动比率
    CurrentAssetRatio = 22                 # 流动资产率
    CurrentDebtRatio = 23                  # 流动负债率
    EquityMultiplier = 24                  # 权益乘数
    PropertyRatio = 25                     # 产权比率
    CashAndCashEquivalents = 26            # 现金和现金等价物
    TotalAssetTurnover = 27                # 总资产周转率
    FixedAssetTurnover = 28                # 固定资产周转率
    InventoryTurnover = 29                 # 存货周转率
    OperatingCashFlowTTM = 30              # 经营活动现金流TTM
    AccountsReceivable = 31                # 应收账款
    EBITGrowthRate = 32                    # EBIT同比增长率
    OperatingProfitGrowthRate = 33         # 营业利润同比增长率
    TotalAssetsGrowthRate = 34             # 总资产同比增长率
    ProfitToShareholdersGrowthRate = 35    # 归属于母公司的净利润同比增长率
    ProfitBeforeTaxGrowthRate = 36         # 总利润同比增长率
    EPSGrowthRate = 37                     # 每股收益同比增长率
    ROEGrowthRate = 38                     # ROE同比增长率
    ROICGrowthRate = 39                    # ROIC同比增长率
    NOCFGrowthRate = 40                    # 经营现金流同比增长率
    NOCFPerShareGrowthRate = 41            # 每股经营现金流同比增长率
    OperatingRevenueCashCover = 42         # 营收现金率
    OperatingProfitToTotalProfit = 43      # 营业利润占比
    BasicEPS = 44                          # 基本每股收益
    DilutedEPS = 45                        # 稀释每股收益
    NOCFPerShare = 46                      # 每股经营现金流
end

# 自定义技术指标属性枚举
@enumx CustomIndicatorField begin
    Unknown = 0          # 未知
    Price = 1            # 价格
    MA5 = 2              # 5日均线
    MA10 = 3             # 10日均线
    MA20 = 4             # 20日均线
    MA30 = 5             # 30日均线
    MA60 = 6             # 60日均线
    MA120 = 7            # 120日均线
    MA250 = 8            # 250日均线
    RSI = 9              # RSI指标
    EMA5 = 10            # 5日指数移动均线
    EMA10 = 11           # 10日指数移动均线
    EMA20 = 12           # 20日指数移动均线
    EMA30 = 13           # 30日指数移动均线
    EMA60 = 14           # 60日指数移动均线
    EMA120 = 15          # 120日指数移动均线
    EMA250 = 16          # 250日指数移动均线
    Value = 17           # 自定义数值
    MA = 30              # 均线
    EMA = 40             # 指数移动均线
    KDJ_K = 50           # KDJ指标K值
    KDJ_D = 51           # KDJ指标D值
    KDJ_J = 52           # KDJ指标J值
    MACD_DIFF = 60       # MACD指标DIFF
    MACD_DEA = 61        # MACD指标DEA
    MACD = 62            # MACD指标
    BOLL_UPPER = 70      # 布林线上轨
    BOLL_MIDDLER = 71    # 布林线中轨
    BOLL_LOWER = 72      # 布林线下轨
end

# 形态技术指标属性枚举
@enumx PatternField begin
    Unknown = 0                    # 未知
    MAAlignmentLong = 1            # MA多头排列
    MAAlignmentShort = 2           # MA空头排列
    EMAAlignmentLong = 3           # EMA多头排列
    EMAAlignmentShort = 4          # EMA空头排列
    RSIGoldCrossLow = 5            # RSI低位金叉
    RSIDeathCrossHigh = 6          # RSI高位死叉
    RSITopDivergence = 7           # RSI顶背驰
    RSIBottomDivergence = 8        # RSI底背驰
    KDJGoldCrossLow = 9            # KDJ低位金叉
    KDJDeathCrossHigh = 10         # KDJ高位死叉
    KDJTopDivergence = 11          # KDJ顶背驰
    KDJBottomDivergence = 12       # KDJ底背驰
    MACDGoldCrossLow = 13          # MACD低位金叉
    MACDDeathCrossHigh = 14        # MACD高位死叉
    MACDTopDivergence = 15         # MACD顶背驰
    MACDBottomDivergence = 16      # MACD底背驰
    BOLLBreakUpper = 17            # 价格突破布林线上轨
    BOLLLower = 18                 # 价格跌穿布林线下轨
    BOLLCrossMiddleUp = 19         # 价格由下向上穿越布林线中轨
    BOLLCrossMiddleDown = 20       # 价格由上向下穿越布林线中轨
end

# 财务时间周期枚举
@enumx FinancialQuarter begin
    Unknown = 0               # 未知
    Annual = 1                # 年报
    FirstQuarter = 2          # 一季报
    Interim = 3               # 中报
    ThirdQuarter = 4          # 三季报
    MostRecentQuarter = 5     # 最近季报
end

# 相对位置比较枚举
@enumx RelativePosition begin
    Unknown = 0       # 未知
    More = 1          # 大于
    Less = 2          # 小于
    CrossUp = 3       # 升穿
    CrossDown = 4     # 跌穿
end

# 排序方向枚举
@enumx SortDir begin
    No = 0          # 不排序
    Ascend = 1      # 升序
    Descend = 2     # 降序
end

# 简单属性筛选
mutable struct BaseFilter
    fieldName::Int32    # 简单属性
    filterMin::Float64  # 区间下限（闭区间）
    filterMax::Float64  # 区间上限（闭区间）
    isNoFilter::Bool    # 该字段是否不需要筛选
    sortDir::Int32      # 排序方向
    BaseFilter(; fieldName = 0, filterMin = 0.0, filterMax = 0.0, isNoFilter = true, sortDir = 0) = new(fieldName, filterMin, filterMax, isNoFilter, sortDir)
end
PB.default_values(::Type{BaseFilter}) = (;fieldName = Int32(0), filterMin = 0.0, filterMax = 0.0, isNoFilter = true, sortDir = Int32(0))
PB.field_numbers(::Type{BaseFilter}) = (;fieldName = 1, filterMin = 2, filterMax = 3, isNoFilter = 4, sortDir = 5)
function PB.encode(e::PB.AbstractProtoEncoder, x::BaseFilter)
    initpos = position(e.io)
    x.fieldName != 0 && PB.encode(e, 1, x.fieldName)
    x.filterMin != 0.0 && PB.encode(e, 2, x.filterMin)
    x.filterMax != 0.0 && PB.encode(e, 3, x.filterMax)
    x.isNoFilter != true && PB.encode(e, 4, x.isNoFilter)
    x.sortDir != 0 && PB.encode(e, 5, x.sortDir)
    return position(e.io) - initpos
end

# 累积属性筛选
mutable struct AccumulateFilter
    fieldName::Int32    # 累积属性
    filterMin::Float64  # 区间下限（闭区间）
    filterMax::Float64  # 区间上限（闭区间）
    isNoFilter::Bool    # 该字段是否不需要筛选
    sortDir::Int32      # 排序方向
    days::Int32         # 近几日，累积时间
    AccumulateFilter(; fieldName = 0, filterMin = 0.0, filterMax = 0.0, isNoFilter = true, sortDir = 0, days = 0) = new(fieldName, filterMin, filterMax, isNoFilter, sortDir, days)
end
PB.default_values(::Type{AccumulateFilter}) = (;fieldName = Int32(0), filterMin = 0.0, filterMax = 0.0, isNoFilter = true, sortDir = Int32(0), days = Int32(0))
PB.field_numbers(::Type{AccumulateFilter}) = (;fieldName = 1, filterMin = 2, filterMax = 3, isNoFilter = 4, sortDir = 5, days = 6)
function PB.encode(e::PB.AbstractProtoEncoder, x::AccumulateFilter)
    initpos = position(e.io)
    x.fieldName != 0 && PB.encode(e, 1, x.fieldName)
    x.filterMin != 0.0 && PB.encode(e, 2, x.filterMin)
    x.filterMax != 0.0 && PB.encode(e, 3, x.filterMax)
    x.isNoFilter != true && PB.encode(e, 4, x.isNoFilter)
    x.sortDir != 0 && PB.encode(e, 5, x.sortDir)
    x.days != 0 && PB.encode(e, 6, x.days)
    return position(e.io) - initpos
end

# 财务属性筛选
mutable struct FinancialFilter
    fieldName::Int32    # 财务属性
    filterMin::Float64  # 区间下限（闭区间）
    filterMax::Float64  # 区间上限（闭区间）
    isNoFilter::Bool    # 该字段是否不需要筛选
    sortDir::Int32      # 排序方向
    quarter::Int32      # 财报累积时间
    FinancialFilter(; fieldName = 0, filterMin = 0.0, filterMax = 0.0, isNoFilter = true, sortDir = 0, quarter = 0) = new(fieldName, filterMin, filterMax, isNoFilter, sortDir, quarter)
end
PB.default_values(::Type{FinancialFilter}) = (;fieldName = Int32(0), filterMin = 0.0, filterMax = 0.0, isNoFilter = true, sortDir = Int32(0), quarter = Int32(0))
PB.field_numbers(::Type{FinancialFilter}) = (;fieldName = 1, filterMin = 2, filterMax = 3, isNoFilter = 4, sortDir = 5, quarter = 6)
function PB.encode(e::PB.AbstractProtoEncoder, x::FinancialFilter)
    initpos = position(e.io)
    x.fieldName != 0 && PB.encode(e, 1, x.fieldName)
    x.filterMin != 0.0 && PB.encode(e, 2, x.filterMin)
    x.filterMax != 0.0 && PB.encode(e, 3, x.filterMax)
    x.isNoFilter != true && PB.encode(e, 4, x.isNoFilter)
    x.sortDir != 0 && PB.encode(e, 5, x.sortDir)
    x.quarter != 0 && PB.encode(e, 6, x.quarter)
    return position(e.io) - initpos
end

# 形态技术指标属性筛选
mutable struct PatternFilter
    fieldName::Int32    # 形态技术指标属性
    klType::Int32       # K线类型
    isNoFilter::Bool    # 该字段是否不需要筛选
    consecutivePeriod::Int32  # 筛选连续周期都符合条件的数据
    PatternFilter(; fieldName = 0, klType = 0, isNoFilter = true, consecutivePeriod = 0) = new(fieldName, klType, isNoFilter, consecutivePeriod)
end
PB.default_values(::Type{PatternFilter}) = (;fieldName = Int32(0), klType = Int32(0), isNoFilter = true, consecutivePeriod = Int32(0))
PB.field_numbers(::Type{PatternFilter}) = (;fieldName = 1, klType = 2, isNoFilter = 3, consecutivePeriod = 4)
function PB.encode(e::PB.AbstractProtoEncoder, x::PatternFilter)
    initpos = position(e.io)
    x.fieldName != 0 && PB.encode(e, 1, x.fieldName)
    x.klType != 0 && PB.encode(e, 2, x.klType)
    x.isNoFilter != true && PB.encode(e, 3, x.isNoFilter)
    x.consecutivePeriod != 0 && PB.encode(e, 4, x.consecutivePeriod)
    return position(e.io) - initpos
end

# 自定义技术指标属性筛选
mutable struct CustomIndicatorFilter
    firstFieldName::Int32         # 自定义技术指标属性
    secondFieldName::Int32        # 自定义技术指标属性
    relativePosition::Int32       # 相对位置
    fieldValue::Float64           # 自定义数值
    klType::Int32                 # K线类型
    isNoFilter::Bool              # 该字段是否不需要筛选
    firstFieldParaList::Vector{Int32}   # 自定义指标参数
    secondFieldParaList::Vector{Int32}  # 自定义指标参数
    consecutivePeriod::Int32      # 筛选连续周期都符合条件的数据
    CustomIndicatorFilter(; firstFieldName = 0, secondFieldName = 0, relativePosition = 0, fieldValue = 0.0, klType = 0, isNoFilter = true, firstFieldParaList = Vector{Int32}(), secondFieldParaList = Vector{Int32}(), consecutivePeriod = 0) = new(firstFieldName, secondFieldName, relativePosition, fieldValue, klType, isNoFilter, firstFieldParaList, secondFieldParaList, consecutivePeriod)
end
PB.default_values(::Type{CustomIndicatorFilter}) = (;firstFieldName = Int32(0), secondFieldName = Int32(0), relativePosition = Int32(0), fieldValue = 0.0, klType = Int32(0), isNoFilter = true, firstFieldParaList = Vector{Int32}(), secondFieldParaList = Vector{Int32}(), consecutivePeriod = Int32(0))
PB.field_numbers(::Type{CustomIndicatorFilter}) = (;firstFieldName = 1, secondFieldName = 2, relativePosition = 3, fieldValue = 4, klType = 5, isNoFilter = 6, firstFieldParaList = 7, secondFieldParaList = 8, consecutivePeriod = 9)
function PB.encode(e::PB.AbstractProtoEncoder, x::CustomIndicatorFilter)
    initpos = position(e.io)
    x.firstFieldName != 0 && PB.encode(e, 1, x.firstFieldName)
    x.secondFieldName != 0 && PB.encode(e, 2, x.secondFieldName)
    x.relativePosition != 0 && PB.encode(e, 3, x.relativePosition)
    x.fieldValue != 0.0 && PB.encode(e, 4, x.fieldValue)
    x.klType != 0 && PB.encode(e, 5, x.klType)
    x.isNoFilter != true && PB.encode(e, 6, x.isNoFilter)
    !isempty(x.firstFieldParaList) && PB.encode(e, 7, x.firstFieldParaList)
    !isempty(x.secondFieldParaList) && PB.encode(e, 8, x.secondFieldParaList)
    x.consecutivePeriod != 0 && PB.encode(e, 9, x.consecutivePeriod)
    return position(e.io) - initpos
end

# 简单属性数据
mutable struct BaseData
    fieldName::Int32  # 简单属性
    value::Float64    # 属性值
end
PB.default_values(::Type{BaseData}) = (;fieldName = Int32(0), value = 0.0)
PB.field_numbers(::Type{BaseData}) = (;fieldName = 1, value = 2)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:BaseData})
    fieldName = Int32(0)
    value = 0.0
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            fieldName = PB.decode(d, Int32)
        elseif field_number == 2
            value = PB.decode(d, Float64)
        else
            PB.skip(d, wire_type)
        end
    end
    return BaseData(fieldName, value)
end

# 累积属性数据
mutable struct AccumulateData
    fieldName::Int32  # 累积属性
    value::Float64    # 属性值
    days::Int32       # 近几日，累积时间
end
PB.default_values(::Type{AccumulateData}) = (;fieldName = Int32(0), value = 0.0, days = Int32(0))
PB.field_numbers(::Type{AccumulateData}) = (;fieldName = 1, value = 2, days = 3)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:AccumulateData})
    fieldName = Int32(0)
    value = 0.0
    days = Int32(0)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            fieldName = PB.decode(d, Int32)
        elseif field_number == 2
            value = PB.decode(d, Float64)
        elseif field_number == 3
            days = PB.decode(d, Int32)
        else
            PB.skip(d, wire_type)
        end
    end
    return AccumulateData(fieldName, value, days)
end

# 财务属性数据
mutable struct FinancialData
    fieldName::Int32  # 财务属性
    value::Float64    # 属性值
    quarter::Int32    # 财报累积时间
end
PB.default_values(::Type{FinancialData}) = (;fieldName = Int32(0), value = 0.0, quarter = Int32(0))
PB.field_numbers(::Type{FinancialData}) = (;fieldName = 1, value = 2, quarter = 3)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:FinancialData})
    fieldName = Int32(0)
    value = 0.0
    quarter = Int32(0)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            fieldName = PB.decode(d, Int32)
        elseif field_number == 2
            value = PB.decode(d, Float64)
        elseif field_number == 3
            quarter = PB.decode(d, Int32)
        else
            PB.skip(d, wire_type)
        end
    end
    return FinancialData(fieldName, value, quarter)
end

# 自定义技术指标属性数据
mutable struct CustomIndicatorData
    fieldName::Int32           # 自定义技术指标属性
    value::Float64             # 属性值
    klType::Int32              # K线类型
    fieldParaList::Vector{Int32}  # 自定义指标参数
    CustomIndicatorData(; fieldName = 0, value = 0.0, klType = 0, fieldParaList = Vector{Int32}()) = new(fieldName, value, klType, fieldParaList)
end
PB.default_values(::Type{CustomIndicatorData}) = (;fieldName = Int32(0), value = 0.0, klType = Int32(0), fieldParaList = Vector{Int32}())
PB.field_numbers(::Type{CustomIndicatorData}) = (;fieldName = 1, value = 2, klType = 3, fieldParaList = 4)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:CustomIndicatorData})
    fieldName = Int32(0)
    value = 0.0
    klType = Int32(0)
    fieldParaList = Vector{Int32}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            fieldName = PB.decode(d, Int32)
        elseif field_number == 2
            value = PB.decode(d, Float64)
        elseif field_number == 3
            klType = PB.decode(d, Int32)
        elseif field_number == 4
            push!(fieldParaList, PB.decode(d, Int32))
        else
            PB.skip(d, wire_type)
        end
    end
    return CustomIndicatorData(fieldName = fieldName, value = value, klType = klType, fieldParaList = fieldParaList)
end

# 返回的股票数据
mutable struct StockData
    security::Qot_Common.Security                    # 股票
    name::String                                     # 股票名称
    baseDataList::Vector{BaseData}                   # 筛选后的简单指标属性数据
    accumulateDataList::Vector{AccumulateData}       # 筛选后的累积指标属性数据
    financialDataList::Vector{FinancialData}         # 筛选后的财务指标属性数据
    customIndicatorDataList::Vector{CustomIndicatorData}  # 自定义技术指标属性数据
    StockData(; security = Qot_Common.Security(), name = "", baseDataList = Vector{BaseData}(), accumulateDataList = Vector{AccumulateData}(), financialDataList = Vector{FinancialData}(), customIndicatorDataList = Vector{CustomIndicatorData}()) = new(security, name, baseDataList, accumulateDataList, financialDataList, customIndicatorDataList)
end
PB.default_values(::Type{StockData}) = (;security = Qot_Common.Security(), name = "", baseDataList = Vector{BaseData}(), accumulateDataList = Vector{AccumulateData}(), financialDataList = Vector{FinancialData}(), customIndicatorDataList = Vector{CustomIndicatorData}())
PB.field_numbers(::Type{StockData}) = (;security = 1, name = 2, baseDataList = 3, accumulateDataList = 4, financialDataList = 5, customIndicatorDataList = 6)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:StockData})
    security = Qot_Common.Security()
    name = ""
    baseDataList = Vector{BaseData}()
    accumulateDataList = Vector{AccumulateData}()
    financialDataList = Vector{FinancialData}()
    customIndicatorDataList = Vector{CustomIndicatorData}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            security = PB.decode(d, Ref{Qot_Common.Security})
        elseif field_number == 2
            name = PB.decode(d, String)
        elseif field_number == 3
            push!(baseDataList, PB.decode(d, Ref{BaseData}))
        elseif field_number == 4
            push!(accumulateDataList, PB.decode(d, Ref{AccumulateData}))
        elseif field_number == 5
            push!(financialDataList, PB.decode(d, Ref{FinancialData}))
        elseif field_number == 6
            push!(customIndicatorDataList, PB.decode(d, Ref{CustomIndicatorData}))
        else
            PB.skip(d, wire_type)
        end
    end
    return StockData(security = security, name = name, baseDataList = baseDataList, accumulateDataList = accumulateDataList, financialDataList = financialDataList, customIndicatorDataList = customIndicatorDataList)
end

# 客户端到服务端请求消息
mutable struct C2S
    begin_::Int32                                    # 数据起始点
    num::Int32                                       # 请求数据个数，最大200
    market::Int32                                    # 股票市场
    plate::Union{Nothing, Qot_Common.Security}       # 板块
    baseFilterList::Vector{BaseFilter}               # 简单指标过滤器
    accumulateFilterList::Vector{AccumulateFilter}   # 累积指标过滤器
    financialFilterList::Vector{FinancialFilter}     # 财务指标过滤器
    patternFilterList::Vector{PatternFilter}         # 形态技术指标过滤器
    customIndicatorFilterList::Vector{CustomIndicatorFilter}  # 自定义技术指标过滤器
    C2S(; begin_ = 0, num = 0, market = 0, plate = nothing, baseFilterList = Vector{BaseFilter}(), accumulateFilterList = Vector{AccumulateFilter}(), financialFilterList = Vector{FinancialFilter}(), patternFilterList = Vector{PatternFilter}(), customIndicatorFilterList = Vector{CustomIndicatorFilter}()) = new(begin_, num, market, plate, baseFilterList, accumulateFilterList, financialFilterList, patternFilterList, customIndicatorFilterList)
end
PB.default_values(::Type{C2S}) = (;begin_ = Int32(0), num = Int32(0), market = Int32(0), plate = nothing, baseFilterList = Vector{BaseFilter}(), accumulateFilterList = Vector{AccumulateFilter}(), financialFilterList = Vector{FinancialFilter}(), patternFilterList = Vector{PatternFilter}(), customIndicatorFilterList = Vector{CustomIndicatorFilter}())
PB.field_numbers(::Type{C2S}) = (;begin_ = 1, num = 2, market = 3, plate = 4, baseFilterList = 5, accumulateFilterList = 6, financialFilterList = 7, patternFilterList = 8, customIndicatorFilterList = 9)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    PB.encode(e, 1, x.begin_)
    PB.encode(e, 2, x.num)
    PB.encode(e, 3, x.market)
    !isnothing(x.plate) && PB.encode(e, 4, x.plate)
    !isempty(x.baseFilterList) && PB.encode(e, 5, x.baseFilterList)
    !isempty(x.accumulateFilterList) && PB.encode(e, 6, x.accumulateFilterList)
    !isempty(x.financialFilterList) && PB.encode(e, 7, x.financialFilterList)
    !isempty(x.patternFilterList) && PB.encode(e, 8, x.patternFilterList)
    !isempty(x.customIndicatorFilterList) && PB.encode(e, 9, x.customIndicatorFilterList)
    return position(e.io) - initpos
end

# 服务端到客户端响应消息
mutable struct S2C
    lastPage::Bool                   # 是否最后一页了
    allCount::Int32                  # 该条件请求所有数据的个数
    dataList::Vector{StockData}      # 返回的股票数据列表
    S2C(; lastPage = false, allCount = 0, dataList = Vector{StockData}()) = new(lastPage, allCount, dataList)
end
PB.default_values(::Type{S2C}) = (;lastPage = false, allCount = Int32(0), dataList = Vector{StockData}())
PB.field_numbers(::Type{S2C}) = (;lastPage = 1, allCount = 2, dataList = 3)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    lastPage = false
    allCount = Int32(0)
    dataList = Vector{StockData}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            lastPage = PB.decode(d, Bool)
        elseif field_number == 2
            allCount = PB.decode(d, Int32)
        elseif field_number == 3
            push!(dataList, PB.decode(d, Ref{StockData}))
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(lastPage = lastPage, allCount = allCount, dataList = dataList)
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
PB.default_values(::Type{Response}) = (;retType = Int32(-400), retMsg = "", errCode = Int32(0), s2c = S2C())
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
    return Response(retType = retType, retMsg = retMsg, errCode = errCode, s2c = s2c)
end

export StockField, AccumulateField, FinancialField, CustomIndicatorField, PatternField, FinancialQuarter, RelativePosition, SortDir, BaseFilter, AccumulateFilter, FinancialFilter, PatternFilter, CustomIndicatorFilter, BaseData, AccumulateData, FinancialData, CustomIndicatorData, StockData, C2S, S2C, Request, Response

# Custom show functions for better display
import Base: show

function show(io::IO, f::BaseFilter)
    field = StockField.T(f.fieldName)
    sort_str = f.sortDir == Int32(SortDir.Ascend) ? " ↑" : (f.sortDir == Int32(SortDir.Descend) ? " ↓" : "")
    if f.isNoFilter
        print(io, "BaseFilter($(field)$(sort_str), no filter)")
    else
        print(io, "BaseFilter($(field): $(f.filterMin) ~ $(f.filterMax)$(sort_str))")
    end
end

function show(io::IO, f::AccumulateFilter)
    field = AccumulateField.T(f.fieldName)
    sort_str = f.sortDir == Int32(SortDir.Ascend) ? " ↑" : (f.sortDir == Int32(SortDir.Descend) ? " ↓" : "")
    if f.isNoFilter
        print(io, "AccumulateFilter($(field), $(f.days)d$(sort_str), no filter)")
    else
        print(io, "AccumulateFilter($(field), $(f.days)d: $(f.filterMin) ~ $(f.filterMax)$(sort_str))")
    end
end

function show(io::IO, f::FinancialFilter)
    field = FinancialField.T(f.fieldName)
    quarter = FinancialQuarter.T(f.quarter)
    sort_str = f.sortDir == Int32(SortDir.Ascend) ? " ↑" : (f.sortDir == Int32(SortDir.Descend) ? " ↓" : "")
    if f.isNoFilter
        print(io, "FinancialFilter($(field), $(quarter)$(sort_str), no filter)")
    else
        print(io, "FinancialFilter($(field), $(quarter): $(f.filterMin) ~ $(f.filterMax)$(sort_str))")
    end
end

function show(io::IO, f::PatternFilter)
    field = PatternField.T(f.fieldName)
    kl = KLType.T(f.klType)
    if f.isNoFilter
        print(io, "PatternFilter($(field), $(kl), no filter)")
    else
        period_str = f.consecutivePeriod > 1 ? ", $(f.consecutivePeriod) periods" : ""
        print(io, "PatternFilter($(field), $(kl)$(period_str))")
    end
end

function show(io::IO, f::CustomIndicatorFilter)
    first = CustomIndicatorField.T(f.firstFieldName)
    second = CustomIndicatorField.T(f.secondFieldName)
    pos = RelativePosition.T(f.relativePosition)
    kl = KLType.T(f.klType)
    if f.isNoFilter
        print(io, "CustomIndicatorFilter($(first) $(pos) $(second), $(kl), no filter)")
    else
        period_str = f.consecutivePeriod > 1 ? ", $(f.consecutivePeriod) periods" : ""
        print(io, "CustomIndicatorFilter($(first) $(pos) $(second), $(kl)$(period_str))")
    end
end

end
