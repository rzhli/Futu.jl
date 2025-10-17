module Qot_Common

import ProtoBuf as PB
using ProtoBuf.EnumX
using ..Common
using Printf: @sprintf
import Base: show

@enumx QotMarket begin
    Unknown = 0             # 未知市场
    HK_Security = 1         # 香港市场
    HK_Future = 2           # 港期货(已废弃，使用QotMarket_HK_Security即可)
    US_Security = 11        # 美国市场
    CNSH_Security = 21      # 沪股市场
    CNSZ_Security = 22      # 深股市场
    SG_Security = 31        # 新加坡市场
    JP_Security = 41        # 日本市场
    US_Option = 49          # 美股期权
    US_Future = 50          # 美股期货
    AU_Security = 51        # 澳大利亚市场
	MY_Security = 61        # 马来西亚市场
	CA_Security = 71        # 加拿大市场
	FX_Security = 81        # 外汇市场
end

@enumx SecurityType begin
    Unknown = 0             # 未知
    Bond = 1                # 债券
    Bwrt = 2                # 一揽子权证
    Eqty = 3                # 正股
    Trust = 4               # 信托,基金
    Warrant = 5             # 窝轮
    Index = 6               # 指数
    Plate = 7               # 板块
    Drvt = 8                # 期权
    PlateSet = 9            # 板块集
    Future = 10             # 期货
end

@enumx PlateSetType begin
    All = 0                 # 所有板块
    Industry = 1            # 行业板块
    Region = 2              # 地域板块,港美股市场的地域分类数据暂为空
    Concept = 3             # 概念板块
    Other = 4               # 其他板块, 仅用于3207（获取股票所属板块）协议返回,不可作为其他协议的请求参数
end

@enumx WarrantType begin
    Unknown = 0             # 未知
    Buy = 1                 # 认购
    Sell = 2                # 认沽
    Bull = 3                # 牛
    Bear = 4                # 熊
    InLine = 5              # 界内证
end

@enumx OptionType begin
    Unknown = 0             # 未知
    Call = 1                # 涨
    Put = 2                 # 跌
end

@enumx IndexOptionType begin
    Unknown = 0             # 未知
    Normal = 1              # 正常普通的指数期权
    Small = 2               # 小型指数期权
end

@enumx OptionAreaType begin
    Unknown = 0             # 未知
    American = 1            # 美式
    European = 2            # 欧式
    Bermuda = 3             # 百慕大
end

@enumx QotMarketState begin
    None = 0                # 无交易
    Auction = 1             # 竞价
    WaitingOpen = 2         # 早盘前等待开盘
    Morning = 3             # 早盘
    Rest = 4                # 午间休市
    Afternoon = 5           # 午盘
    Closed = 6              # 收盘
    PreMarketBegin = 8      # 盘前
    PreMarketEnd = 9        # 盘前结束
    AfterHoursBegin = 10    # 盘后
    AfterHoursEnd = 11      # 盘后结束
    FUTU_SWITCH_DATE = 12   # (无注释)
    NightOpen = 13          # 夜市开盘
    NightEnd = 14           # 夜市收盘
    FutureDayOpen = 15      # 期货日市开盘
    FutureDayBreak = 16     # 期货日市休市
    FutureDayClose = 17     # 期货日市收盘
    FutureDayWaitForOpen = 18  # 期货日市等待开盘
    HkCas = 19              # 盘后竞价,港股市场增加CAS机制对应的市场状态
	FutureNightWait = 20    # 夜市等待开盘（已废弃）
	FutureAfternoon = 21    # 期货下午开盘（已废弃）
	FutureSwitchDate = 22   # 期货切交易日（已废弃）
	FutureOpen = 23         # 期货开盘
	FutureBreak = 24        # 期货中盘休息
	FutureBreakOver = 25    # 期货休息后开盘
	FutureClose = 26        # 期货收盘
    StibAfterHoursWait = 27 # 科创板的盘后撮合时段（已废弃）
    StibAfterHoursBegin = 28# 科创板的盘后交易开始（已废弃）
    StibAfterHoursEnd = 29  # 科创板的盘后交易结束（已废弃）
    CLOSE_AUCTION = 30      # 收市竞价
    AFTERNOON_END = 31      # 已收盘
    NIGHT = 32              # 交易中
    OVERNIGHT_BEGIN = 33    # 夜盘开始
    OVERNIGHT_END = 34      # 夜盘结束
    TRADE_AT_LAST = 35      # 收盘前成交（在交易时间表内）
    TRADE_AUCTION = 36      # 收盘前的竞价 （在交易时间表内）
	OVERNIGHT = 37          # 美股夜盘交易时段
end

@enumx TradeDateMarket begin
    Unknown = 0             # 未知
    HK = 1                  # 港股市场
    US = 2                  # 美股市场
    CN = 3                  # A股市场
    NT = 4                  # 深（沪）股通
    ST = 5                  # 港股通（深、沪）
	JP_Future = 6           # 日本期货
	SG_Future = 7           # 新加坡期货
end

@enumx TradeDateType begin
    Whole = 0               # 全天交易
    Morning = 1             # 上午交易，下午休市
    Afternoon = 2           # 下午交易，上午休市
end

@enumx RehabType begin
    None = 0                # 不复权
    Forward = 1             # 前复权
    Backward = 2            # 后复权
end

@enumx KLType begin
    K_Unknown = 0  # 未知
    K_1M = 1  # 1分K
    K_Day = 2  # 日K
    K_Week = 3  # 周K
    K_Month = 4  # 月K
    K_Year = 5  # 年K
    K_5M = 6  # 5分K
    K_15M = 7  # 15分K
    K_30M = 8  # 30分K
    K_60M = 9  # 60分K
    K_3M = 10  # 3分K
    K_Quarter = 11  # 季K
end

@enumx KLFields begin
    None = 0  #
    High = 1  # 最高价
    Open = 2  # 开盘价
    Low = 4  # 最低价
    Close = 8  # 收盘价
    LastClose = 16  # 昨收价
    Volume = 32  # 成交量
    Turnover = 64  # 成交额
    TurnoverRate = 128  # 换手率
    PE = 256  # 市盈率
    ChangeRate = 512  # 涨跌幅
end

@enumx SubType begin
    None = 0  # (无注释)
    Basic = 1  # 基础报价
    OrderBook = 2  # 摆盘
    Ticker = 4  # 逐笔
    RT = 5  # 分时
    K_Day = 6  # 日K
    K_5M = 7  # 5分K
    K_15M = 8  # 15分K
    K_30M = 9  # 30分K
    K_60M = 10  # 60分K
    K_1M = 11  # 1分K
    K_Week = 12  # 周K
    K_Month = 13  # 月K
    Broker = 14  # 经纪队列
    K_Quarter = 15  # 季K
    K_Year = 16  # 年K
    K_3M = 17  # 3分K
end

@enumx TickerDirection begin
    Unknown = 0  # 未知
    Bid = 1  # 外盘
    Ask = 2  # 内盘
    Neutral = 3  # 中性盘
end

@enumx TickerType begin
    Unknown = 0                         # 未知
    Automatch = 1                       # 自动对盘
    Late = 2                            # 开市前成交盘
    NoneAutomatch = 3                   # 非自动对盘
    InterAutomatch = 4                  # 同一证券商自动对盘
    InterNoneAutomatch = 5              # 同一证券商非自动对盘
    OddLot = 6                          # 碎股交易
    Auction = 7                         # 竞价交易
    Bulk = 8                            # 批量交易
    Crash = 9                           # 现金交易
    CrossMarket = 10                    # 跨市场交易
    BulkSold = 11                       # 批量卖出
    FreeOnBoard = 12                    # 离价交易
    Rule127Or155 = 13                   # 第127条交易（纽交所规则）或第155条交易
    Delay = 14                          # 延迟交易
    MarketCenterClosePrice = 15         # 中央收市价
    NextDay = 16                        # 隔日交易
    MarketCenterOpening = 17            # 中央开盘价交易
    PriorReferencePrice = 18            # 前参考价
    MarketCenterOpenPrice = 19          # 中央开盘价
    Seller = 20                         # 卖方
    T_Type = 21                         # T类交易(盘前和盘后交易)
    ExtendedTradingHours = 22           # 延长交易时段
    Contingent = 23                     # 合单交易
    AvgPrice = 24                       # 平均价成交
    OTCSold = 25                        # 场外售出
    OddLotCrossMarket = 26              # 碎股跨市场交易
    DerivativelyPriced = 27             # 衍生工具定价
    ReOpeningPriced = 28                # 再开盘定价
    ClosingPriced = 29                  # 收盘定价
    ComprehensiveDelayPrice = 30        # 综合延迟价格
    Overseas = 31                       # 交易的一方不是香港交易所的成员，属于场外交易
end

@enumx DarkStatus begin
    None = 0                # 无暗盘交易
    Trading = 1             # 暗盘交易中
    End = 2                 # 暗盘交易结束
end

@enumx SecurityStatus begin
    Unknown = 0             # 未知
    Normal = 1              # 正常状态
    Listing = 2  # 待上市
    Purchasing = 3  # 申购中
    Subscribing = 4  # 认购中
    BeforeDrakTradeOpening = 5  # 暗盘开盘前
    DrakTrading = 6  # 暗盘交易中
    DrakTradeEnd = 7  # 暗盘已收盘
    ToBeOpen = 8  # 待开盘
    Suspended = 9  # 停牌
    Called = 10  # 已收回
    ExpiredLastTradingDate = 11  # 已过最后交易日
    Expired = 12  # 已过期
    Delisted = 13  # 已退市
    ChangeToTemporaryCode = 14  # 公司行动中，交易关闭，转至临时代码交易
    TemporaryCodeTradeEnd = 15  # 临时买卖结束，交易关闭
    ChangedPlateTradeEnd = 16  # 已转板，旧代码交易关闭
    ChangedCodeTradeEnd = 17  # 已换代码，旧代码交易关闭
    RecoverableCircuitBreaker = 18  # 可恢复性熔断
    UnRecoverableCircuitBreaker = 19  # 不可恢复性熔断
    AfterCombination = 20  # 盘后撮合
    AfterTransation = 21  # 盘后交易
end

# 已废弃
@enumx HolderCategory begin
    Unknown = 0  # 未知
    Agency = 1  # 机构
    Fund = 2  # 基金
    SeniorManager = 3  # 高管
end

@enumx PushDataType begin
    Unknown = 0  # (无注释)
    Realtime = 1  # 实时推送的数据
    ByDisConn = 2  # 对后台行情连接断开期间拉取补充的数据 最多50个
    Cache = 3  # 非实时非连接断开补充数据
end

@enumx SortField begin
    Unknown = 0  # (无注释)
    Code = 1  # 代码
    CurPrice = 2  # 最新价
    PriceChangeVal = 3  # 涨跌额
    ChangeRate = 4  # 涨跌幅%
    Status = 5  # 状态
    BidPrice = 6  # 买入价
    AskPrice = 7  # 卖出价
    BidVol = 8  # 买量
    AskVol = 9  # 卖量
    Volume = 10  # 成交量
    Turnover = 11  # 成交额
    Amplitude = 30  # 振幅%
    Score = 12  # 综合评分
    Premium = 13  # 溢价%
    EffectiveLeverage = 14  # 有效杠杆
    Delta = 15  # 对冲值,仅认购认沽支持该字段
    ImpliedVolatility = 16  # 引伸波幅,仅认购认沽支持该字段
    Type = 17  # 类型
    StrikePrice = 18  # 行权价
    BreakEvenPoint = 19  # 打和点
    MaturityTime = 20  # 到期日
    ListTime = 21  # 上市日期
    LastTradeTime = 22  # 最后交易日
    Leverage = 23  # 杠杆比率
    InOutMoney = 24  # 价内/价外%
    RecoveryPrice = 25  # 收回价,仅牛熊证支持该字段
    ChangePrice = 26  # 换股价
    Change = 27  # 换股比率
    StreetRate = 28  # 街货比%
    StreetVol = 29  # 街货量
    WarrantName = 31  # 窝轮名称
    Issuer = 32  # 发行人
    LotSize = 33  # 每手
    IssueSize = 34  # 发行量
    UpperStrikePrice = 45  # 上限价，仅用于界内证
    LowerStrikePrice = 46  # 下限价，仅用于界内证
    InLinePriceStatus = 47  # 界内界外，仅用于界内证
    PreCurPrice = 35  # 盘前最新价
    AfterCurPrice = 36  # 盘后最新价
    PrePriceChangeVal = 37  # 盘前涨跌额
    AfterPriceChangeVal = 38  # 盘后涨跌额
    PreChangeRate = 39  # 盘前涨跌幅%
    AfterChangeRate = 40  # 盘后涨跌幅%
    PreAmplitude = 41  # 盘前振幅%
    AfterAmplitude = 42  # 盘后振幅%
    PreTurnover = 43  # 盘前成交额
    AfterTurnover = 44  # 盘后成交额
    LastSettlePrice = 48  # 昨结
    Position = 49  # 持仓量
    PositionChange = 50  # 日增仓
end

@enumx Issuer begin
    Unknown = 0  # 未知
    SG = 1  # 法兴
    BP = 2  # 法巴
    CS = 3  # 瑞信
    CT = 4  # 花旗
    EA = 5  # 东亚
    GS = 6  # 高盛
    HS = 7  # 汇丰
    JP = 8  # 摩通
    MB = 9  # 麦银
    SC = 10  # 渣打
    UB = 11  # 瑞银
    BI = 12  # 中银
    DB = 13  # 德银
    DC = 14  # 大和
    ML = 15  # 美林
    NM = 16  # 野村
    RB = 17  # 荷合
    RS = 18  # 苏皇
    BC = 19  # 巴克莱
    HT = 20  # 海通
    VT = 21  # 瑞通
    KC = 22  # 比联
    MS = 23  # 摩利
    GJ = 24  # 国君
    XZ = 25  # 星展
    HU = 26  # 华泰
    KS = 27  # 韩投
    CI = 28  # 信证
end

@enumx IpoPeriod begin
    Unknown = 0                 # 未知
    Today = 1                   # 今日上市
    Tomorrow = 2                # 明日上市
    Nextweek = 3                # 未来一周上市
    Lastweek = 4                # 过去一周上市
    Lastmonth = 5               # 过去一月上市
end

@enumx PriceType begin
    Unknown = 0                 # (无注释)
    Outside = 1                 # 价外，界内证表示界外
    WithIn = 2                  # 价内，界内证表示界内
end

@enumx WarrantStatus begin
    Unknown = 0                 # 未知
    Normal = 1                  # 正常状态
    Suspend = 2                 # 停牌
    StopTrade = 3               # 终止交易
    PendingListing = 4          # 等待上市
end

@enumx CompanyAct begin
    None = 0                # 无
    Split = 1               # 拆股
    Join = 2                # 合股
    Bonus = 4               # 送股
    Transfer = 8            # 转赠股
    Allot = 16              # 配股
    Add = 32                # 增发股
    Dividend = 64           # 现金分红
    SPDividend = 128        # 特别股息
    SpinOff = 256           # 分立
end

@enumx QotRight begin
    Unknown = 0             # 未知
    Bmp = 1                 # Bmp，无法订阅
    Level1 = 2              # Level1
    Level2 = 3              # Level2
    SF = 4                  # SF高级行情
    No = 5                  # 无权限
end

@enumx PriceReminderType begin
    Unknown = 0                 # 未知
    PriceUp = 1                 # 价格涨到
    PriceDown = 2               # 价格跌到
    ChangeRateUp = 3            # 日涨幅超（该字段为百分比字段，设置时填 20 表示 20%）
    ChangeRateDown = 4          # 日跌幅超（该字段为百分比字段，设置时填 20 表示 20%）
    ChangeRateUp_5Min = 5       # 5 分钟涨幅超（该字段为百分比字段，设置时填 20 表示 20%）
    ChangeRateDown_5Min = 6     # 5 分钟跌幅超（该字段为百分比字段，设置时填 20 表示 20%）
    VolumeUp = 7                # 成交量超过
    TurnoverUp = 8              # 成交额超过
    TurnoverRateUp = 9          # 换手率超过（该字段为百分比字段，设置时填 20 表示 20%）
    BidPriceUp = 10             # 买一价高于
    AskPriceDown = 11           # 卖一价低于
    BidVolUp = 12               # 买一量高于
    AskVolUp = 13               # 卖一量高于
    ChangeRateUp_3Min = 14      # 3 分钟涨幅超（该字段为百分比字段，设置时填 20 表示 20%）
    ChangeRateDown_3Min = 15    # 3 分钟跌幅超（该字段为百分比字段，设置时填 20 表示 20%）
end

@enumx PriceReminderFreq begin
    Unknown = 0                 # 未知
    Always = 1                  # 持续提醒
    OnceADay = 2                # 每日一次
    OnlyOnce = 3                # 仅提醒一次
end

@enumx AssetClass begin
	Unknown = 0                 # 未知
	Stock = 1                   # 股票
	Bond = 2                    # 债券
	Commodity = 3               # 商品
	CurrencyMarket = 4          # 货币市场
	Future = 5                  # 期货
	Swap = 6                    # 掉期
end

@enumx ExpirationCycle begin
	Unknown = 0                 # 未知
	Week = 1                    # 周期权
	Month = 2                   # 月期权
	MonthEnd = 3                # 月末期权
	Quarter = 4                 # 季度期权
	WeekMon = 11                # 周一
	WeekTue = 12                # 周二
	WeekWed = 13                # 周三
	WeekThu = 14                # 周四
	WeekFri = 15                # 周五
end

@enumx OptionStandardType begin
	Unknown = 0                 # 未知
	Standard = 1                # 标准
	NonStandard = 2             # 非标准
end

@enumx OptionSettlementMode begin
	Unknown = 0             # 未知
	AM = 1                  # AM
	PM = 2                  # PM
end

@enumx ExchType begin
    Unknown = 0             # 未知
    HK_MainBoard = 1        # 港交所·主板
    HK_GEMBoard = 2         # 港交所·创业板
    HK_HKEX = 3             # 港交所
    US_NYSE = 4             # 纽交所
    US_Nasdaq = 5           # 纳斯达克
    US_Pink = 6             # OTC 市场
    US_AMEX = 7             # 美交所
    US_Option = 8           # 美国（仅美股期权适用）
    US_NYMEX = 9            # NYMEX
    US_COMEX = 10           # COMEX
    US_CBOT = 11            # CBOT
    US_CME = 12             # CME
    US_CBOE = 13            # CBOE
    CN_SH = 14              # 上交所
    CN_SZ = 15              # 深交所
    CN_STIB = 16            # 科创板
    SG_SGX = 17             # 新交所
    JP_OSE = 18             # 大阪交易所
end

@enumx PeriodType begin
    Unknown = 0             # 未知
    INTRADAY = 1            # 实时
	DAY = 2                 # 日
	WEEK = 3                # 周
	MONTH = 4               # 月
end

@enumx PriceReminderMarketStatus begin
	Unknown = 0              # (无注释)
	Open = 1                # 盘中
	USPre = 2               # 美股盘前
	USAfter = 3             # 美股盘后
	USOverNight = 4         # 美股夜盘
end

mutable struct Security
    market::Int32
    code::String
end
Security(market::Integer, code::AbstractString) = Security(Int32(market), String(code))
Security(; market::Integer = 0, code::AbstractString = "") = Security(Int32(market), String(code))

PB.default_values(::Type{Security}) = (;market = Int32(0), code = "")
PB.field_numbers(::Type{Security}) = (;market = 1, code = 2)
function PB.encode(e::PB.AbstractProtoEncoder, x::Security)
    initpos = position(e.io)
    x.market != Int32(0) && PB.encode(e, 1, x.market)
    x.code != "" && PB.encode(e, 2, x.code)
    return position(e.io) - initpos
end
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:Security})
    market = Int32(0)
    code = ""
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            market = PB.decode(d, Int32)
        elseif field_number == 2
            code = PB.decode(d, String)
        else
            PB.skip(d, wire_type)
        end
    end
    return Security(market, code)
end

mutable struct KLine
    time::String
    isBlank::Bool
    highPrice::Float64
    openPrice::Float64
    lowPrice::Float64
    closePrice::Float64
    lastClosePrice::Float64
    volume::Int64
    turnover::Float64
    turnoverRate::Float64
    pe::Float64
    changeRate::Float64
    timestamp::Float64
    KLine(time::String, isBlank::Bool, highPrice::Float64, openPrice::Float64, lowPrice::Float64,
        closePrice::Float64, lastClosePrice::Float64, volume::Int64, turnover::Float64, turnoverRate::Float64,
        pe::Float64, changeRate::Float64, timestamp::Float64) = new(
        time, isBlank, highPrice, openPrice, lowPrice, closePrice, lastClosePrice, volume, turnover, turnoverRate, pe, changeRate, timestamp
    )
    KLine(; time = "", isBlank = false, highPrice = 0.0, openPrice = 0.0, lowPrice = 0.0, closePrice = 0.0, lastClosePrice = 0.0,
        volume = 0, turnover = 0.0, turnoverRate = 0.0, pe = 0.0, changeRate = 0.0, timestamp = 0.0) = new(
        String(time), Bool(isBlank), Float64(highPrice), Float64(openPrice), Float64(lowPrice), Float64(closePrice), Float64(lastClosePrice), 
        Int64(volume), Float64(turnover), Float64(turnoverRate), Float64(pe), Float64(changeRate), Float64(timestamp),
    )
end
PB.default_values(::Type{KLine}) = (;time = "", isBlank = false, highPrice = 0.0, openPrice = 0.0, lowPrice = 0.0, closePrice = 0.0, lastClosePrice = 0.0, volume = 0, turnover = 0.0, turnoverRate = 0.0, pe = 0.0, changeRate = 0.0, timestamp = 0.0)
PB.field_numbers(::Type{KLine}) = (;time = 1, isBlank = 2, highPrice = 3, openPrice = 4, lowPrice = 5, closePrice = 6, lastClosePrice = 7, volume = 8, turnover = 9, turnoverRate = 10, pe = 11, changeRate = 12, timestamp = 13)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:KLine})
    time = ""
    isBlank = false
    highPrice = 0.0
    openPrice = 0.0
    lowPrice = 0.0
    closePrice = 0.0
    lastClosePrice = 0.0
    volume = Int64(0)
    turnover = 0.0
    turnoverRate = 0.0
    pe = 0.0
    changeRate = 0.0
    timestamp = 0.0
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            time = PB.decode(d, String)
        elseif field_number == 2
            isBlank = PB.decode(d, Bool)
        elseif field_number == 3
            highPrice = PB.decode(d, Float64)
        elseif field_number == 4
            openPrice = PB.decode(d, Float64)
        elseif field_number == 5
            lowPrice = PB.decode(d, Float64)
        elseif field_number == 6
            closePrice = PB.decode(d, Float64)
        elseif field_number == 7
            lastClosePrice = PB.decode(d, Float64)
        elseif field_number == 8
            volume = PB.decode(d, Int64)
        elseif field_number == 9
            turnover = PB.decode(d, Float64)
        elseif field_number == 10
            turnoverRate = PB.decode(d, Float64)
        elseif field_number == 11
            pe = PB.decode(d, Float64)
        elseif field_number == 12
            changeRate = PB.decode(d, Float64)
        elseif field_number == 13
            timestamp = PB.decode(d, Float64)
        else
            PB.skip(d, wire_type)
        end
    end
    return KLine(time = time, isBlank = isBlank, highPrice = highPrice, openPrice = openPrice, lowPrice = lowPrice, closePrice = closePrice,
        lastClosePrice = lastClosePrice, volume = volume, turnover = turnover,
        turnoverRate = turnoverRate, pe = pe, changeRate = changeRate, timestamp = timestamp,
    )
end

mutable struct OptionBasicQotExData
    strikePrice::Float64                # 行权价
    contractSize::Int32                 # 每份合约数(整型数据)
    openInterest::Int32                 # 未平仓合约数
    impliedVolatility::Float64          # 隐含波动率（该字段为百分比字段，默认不展示%，如20实际对应20%）
    premium::Float64                    # 溢价（该字段为百分比字段，默认不展示%，如20实际对应20%）
    delta::Float64                      # delta值
    gamma::Float64                      # gamma值
    vega::Float64                       # vega值
    theta::Float64                      # theta值
    rho::Float64                        # rho值
    netOpenInterest::Int32              # 净未平仓合约数，仅港股期权适用
    expiryDateDistance::Int32           # 距离到期日天数，负数表示已过期
    contractNominalValue::Float64       # 合约名义金额，仅港股期权适用
    ownerLotMultiplier::Float64         # 相等正股手数，指数期权无该字段，仅港股期权适用
    optionAreaType::Int32               # OptionAreaType，期权类型（按行权时间）
    contractMultiplier::Float64         # 合约乘数
    contractSizeFloat::Float64          # 每份合约数(浮点数数据)
    indexOptionType::Int32              # 指数期权类型
    OptionBasicQotExData(; 
    strikePrice = 0.0, contractSize = 0, openInterest = 0, impliedVolatility = 0.0, premium = 0.0, delta = 0.0, gamma = 0.0, 
    vega = 0.0, theta = 0.0, rho = 0.0, netOpenInterest = 0, expiryDateDistance = 0, contractNominalValue = 0.0, 
    ownerLotMultiplier = 0.0, optionAreaType = 0, contractMultiplier = 0.0, contractSizeFloat = 0.0, indexOptionType = 0
    ) = new(
        strikePrice, Int32(contractSize), Int32(openInterest), impliedVolatility, premium, delta, gamma, vega, theta,
        rho, Int32(netOpenInterest), Int32(expiryDateDistance), contractNominalValue, ownerLotMultiplier, Int32(optionAreaType),
        contractMultiplier, contractSizeFloat, Int32(indexOptionType)
    )
end
PB.default_values(::Type{OptionBasicQotExData}) = (;
strikePrice = 0.0, contractSize = 0, openInterest = 0, impliedVolatility = 0.0, premium = 0.0, 
delta = 0.0, gamma = 0.0, vega = 0.0, theta = 0.0, rho = 0.0, netOpenInterest = 0, 
expiryDateDistance = 0, contractNominalValue = 0.0, ownerLotMultiplier = 0.0, optionAreaType = 0, 
contractMultiplier = 0.0, contractSizeFloat = 0.0, indexOptionType = 0
)
PB.field_numbers(::Type{OptionBasicQotExData}) = (;
strikePrice = 1, contractSize = 2, openInterest = 3, impliedVolatility = 4, premium = 5, delta = 6, 
gamma = 7, vega = 8, theta = 9, rho = 10, netOpenInterest = 11, expiryDateDistance = 12, contractNominalValue = 13, 
ownerLotMultiplier = 14, optionAreaType = 15, contractMultiplier = 16, contractSizeFloat = 17, indexOptionType = 18
)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:OptionBasicQotExData})
    strikePrice = 0.0
    contractSize = 0
    openInterest = 0
    impliedVolatility = 0.0
    premium = 0.0
    delta = 0.0
    gamma = 0.0
    vega = 0.0
    theta = 0.0
    rho = 0.0
    netOpenInterest = 0
    expiryDateDistance = 0
    contractNominalValue = 0.0
    ownerLotMultiplier = 0.0
    optionAreaType = 0
    contractMultiplier = 0.0
    contractSizeFloat = 0.0
    indexOptionType = 0
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            strikePrice = PB.decode(d, Float64)
        elseif field_number == 2
            contractSize = PB.decode(d, Int32)
        elseif field_number == 3
            openInterest = PB.decode(d, Int32)
        elseif field_number == 4
            impliedVolatility = PB.decode(d, Float64)
        elseif field_number == 5
            premium = PB.decode(d, Float64)
        elseif field_number == 6
            delta = PB.decode(d, Float64)
        elseif field_number == 7
            gamma = PB.decode(d, Float64)
        elseif field_number == 8
            vega = PB.decode(d, Float64)
        elseif field_number == 9
            theta = PB.decode(d, Float64)
        elseif field_number == 10
            rho = PB.decode(d, Float64)
        elseif field_number == 11
            netOpenInterest = PB.decode(d, Int32)
        elseif field_number == 12
            expiryDateDistance = PB.decode(d, Int32)
        elseif field_number == 13
            contractNominalValue = PB.decode(d, Float64)
        elseif field_number == 14
            ownerLotMultiplier = PB.decode(d, Float64)
        elseif field_number == 15
            optionAreaType = PB.decode(d, Int32)
        elseif field_number == 16
            contractMultiplier = PB.decode(d, Float64)
        elseif field_number == 17
            contractSizeFloat = PB.decode(d, Float64)
        elseif field_number == 18
            indexOptionType = PB.decode(d, Int32)
        else
            PB.skip(d, wire_type)
        end
    end
    return OptionBasicQotExData(strikePrice, contractSize, openInterest, impliedVolatility, premium, delta, gamma, vega, theta, rho, netOpenInterest, expiryDateDistance, contractNominalValue, ownerLotMultiplier, optionAreaType, contractMultiplier, contractSizeFloat, indexOptionType)
end

mutable struct PreAfterMarketData
    price::Float64
    highPrice::Float64
    lowPrice::Float64
    volume::Int64
    turnover::Float64
    changeVal::Float64
    changeRate::Float64
    amplitude::Float64
    PreAfterMarketData(; 
    price = 0.0, highPrice = 0.0, lowPrice = 0.0, volume = 0, turnover = 0.0, changeVal = 0.0, changeRate = 0.0, amplitude = 0.0
    ) = new(price, highPrice, lowPrice, Int64(volume), turnover, changeVal, changeRate, amplitude)
end
PB.default_values(::Type{PreAfterMarketData}) = (;price = 0.0, highPrice = 0.0, lowPrice = 0.0, volume = 0, turnover = 0.0, changeVal = 0.0, changeRate = 0.0, amplitude = 0.0)
PB.field_numbers(::Type{PreAfterMarketData}) = (;price = 1, highPrice = 2, lowPrice = 3, volume = 4, turnover = 5, changeVal = 6, changeRate = 7, amplitude = 8)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:PreAfterMarketData})
    price = 0.0
    highPrice = 0.0
    lowPrice = 0.0
    volume = 0
    turnover = 0.0
    changeVal = 0.0
    changeRate = 0.0
    amplitude = 0.0
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            price = PB.decode(d, Float64)
        elseif field_number == 2
            highPrice = PB.decode(d, Float64)
        elseif field_number == 3
            lowPrice = PB.decode(d, Float64)
        elseif field_number == 4
            volume = PB.decode(d, Int64)
        elseif field_number == 5
            turnover = PB.decode(d, Float64)
        elseif field_number == 6
            changeVal = PB.decode(d, Float64)
        elseif field_number == 7
            changeRate = PB.decode(d, Float64)
        elseif field_number == 8
            amplitude = PB.decode(d, Float64)
        else
            PB.skip(d, wire_type)
        end
    end
    return PreAfterMarketData(price, highPrice, lowPrice, volume, turnover, changeVal, changeRate, amplitude)
end

mutable struct FutureBasicQotExData
    lastSettlePrice::Float64            # 昨结
    position::Int32                     # 持仓
    positionChange::Int32               # 日增仓
    expiryDateDistance::Int32           # 距离到期日天数
    FutureBasicQotExData(; lastSettlePrice = 0.0, position = 0, positionChange = 0, expiryDateDistance = 0) = new(lastSettlePrice, Int32(position), Int32(positionChange), Int32(expiryDateDistance))
end
PB.default_values(::Type{FutureBasicQotExData}) = (;lastSettlePrice = 0.0, position = 0, positionChange = 0, expiryDateDistance = 0)
PB.field_numbers(::Type{FutureBasicQotExData}) = (;lastSettlePrice = 1, position = 2, positionChange = 3, expiryDateDistance = 4)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:FutureBasicQotExData})
    lastSettlePrice = 0.0
    position = 0
    positionChange = 0
    expiryDateDistance = 0
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            lastSettlePrice = PB.decode(d, Float64)
        elseif field_number == 2
            position = PB.decode(d, Int32)
        elseif field_number == 3
            positionChange = PB.decode(d, Int32)
        elseif field_number == 4
            expiryDateDistance = PB.decode(d, Int32)
        else
            PB.skip(d, wire_type)
        end
    end
    return FutureBasicQotExData(lastSettlePrice, position, positionChange, expiryDateDistance)
end

mutable struct WarrantBasicQotExData
    delta::Float64                      # 对冲值,仅认购认沽支持该字段
    impliedVolatility::Float64          # 引申波幅,仅认购认沽支持该字段
    premium::Float64                    # 溢价（该字段为百分比字段，默认不展示%，如20实际对应20%）
    WarrantBasicQotExData(; delta = 0.0, impliedVolatility = 0.0, premium = 0.0) = new(delta, impliedVolatility, premium)
end
PB.default_values(::Type{WarrantBasicQotExData}) = (;delta = 0.0, impliedVolatility = 0.0, premium = 0.0)
PB.field_numbers(::Type{WarrantBasicQotExData}) = (;delta = 1, impliedVolatility = 2, premium = 3)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:WarrantBasicQotExData})
    delta = 0.0
    impliedVolatility = 0.0
    premium = 0.0
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            delta = PB.decode(d, Float64)
        elseif field_number == 2
            impliedVolatility = PB.decode(d, Float64)
        elseif field_number == 3
            premium = PB.decode(d, Float64)
        else
            PB.skip(d, wire_type)
        end
    end
    return WarrantBasicQotExData(delta, impliedVolatility, premium)
end

mutable struct BasicQot
    security::Security                  # 股票  
    isSuspended::Bool                   # 是否停牌
    listTime::String                    # 上市日期字符串
    priceSpread::Float64                # 价差
    updateTime::String                  # 最新价的更新时间字符串，对其他字段不适用
    highPrice::Float64                  # 最高价
    openPrice::Float64                  # 开盘价
    lowPrice::Float64                   # 最低价
    curPrice::Float64                   # 最新价
    lastClosePrice::Float64             # 昨收
    volume::Int64                       # 成交量
    turnover::Float64                   # 成交额
    turnoverRate::Float64               # 换手率（该字段为百分比字段，默认不展示%，如20实际对应20%）
    amplitude::Float64                  # 振幅(该字段为百分比字段，默认不展示%，如20实际对应20%)
    darkStatus::Int32                   # 暗盘状态
    optionExData::OptionBasicQotExData  # 期权扩展数据
    listTimestamp::Float64              # 上市时间戳
    updateTimestamp::Float64            # 更新时间戳
    preMarket::PreAfterMarketData       # 盘前数据
    afterMarket::PreAfterMarketData     # 盘后数据
    secStatus::Int32                    # 股票状态
    futureExData::FutureBasicQotExData   # 期货扩展数据
    warrantExData::WarrantBasicQotExData # 窝轮扩展数据
    name::String                         # 股票名称
    overnight::PreAfterMarketData        # 夜盘数据
    BasicQot(; 
    security = Security(), isSuspended = false, listTime = "", priceSpread = 0.0, 
    updateTime = "", highPrice = 0.0, openPrice = 0.0, lowPrice = 0.0, curPrice = 0.0, 
    lastClosePrice = 0.0, volume = 0, turnover = 0.0, turnoverRate = 0.0, amplitude = 0.0, 
    darkStatus = 0, optionExData = OptionBasicQotExData(), listTimestamp = 0.0, updateTimestamp = 0.0, 
    preMarket = PreAfterMarketData(), afterMarket = PreAfterMarketData(), secStatus = 0, 
    futureExData = FutureBasicQotExData(), warrantExData = WarrantBasicQotExData(), name = "", 
    overnight = PreAfterMarketData()
    ) = new(
        security, isSuspended, listTime, priceSpread, updateTime, highPrice, openPrice, lowPrice, 
        curPrice, lastClosePrice, volume, turnover, turnoverRate, amplitude, darkStatus, optionExData, 
        listTimestamp, updateTimestamp, preMarket, afterMarket, secStatus, futureExData, warrantExData, name, overnight
    )
end

PB.default_values(::Type{BasicQot}) = (;
security = Security(), isSuspended = false, listTime = "", priceSpread = 0.0, updateTime = "", highPrice = 0.0, 
openPrice = 0.0, lowPrice = 0.0, curPrice = 0.0, lastClosePrice = 0.0, volume = 0, turnover = 0.0, turnoverRate = 0.0, 
amplitude = 0.0, darkStatus = 0, optionExData = OptionBasicQotExData(), listTimestamp = 0.0, updateTimestamp = 0.0, 
preMarket = PreAfterMarketData(), afterMarket = PreAfterMarketData(), secStatus = 0, futureExData = FutureBasicQotExData(), 
warrantExData = WarrantBasicQotExData(), name = "", overnight = PreAfterMarketData()
)

PB.field_numbers(::Type{BasicQot}) = (;
security = 1, isSuspended = 2, listTime = 3, priceSpread = 4, updateTime = 5, highPrice = 6, openPrice = 7, 
lowPrice = 8, curPrice = 9, lastClosePrice = 10, volume = 11, turnover = 12, turnoverRate = 13, amplitude = 14, darkStatus = 15, 
optionExData = 16, listTimestamp = 17, updateTimestamp = 18, preMarket = 19, afterMarket = 20, secStatus = 21, futureExData = 22, 
warrantExData = 23, name = 24, overnight = 25
)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:BasicQot})
    security = Security()
    isSuspended = false
    listTime = ""
    priceSpread = 0.0
    updateTime = ""
    highPrice = 0.0
    openPrice = 0.0
    lowPrice = 0.0
    curPrice = 0.0
    lastClosePrice = 0.0
    volume = 0
    turnover = 0.0
    turnoverRate = 0.0
    amplitude = 0.0
    darkStatus = 0
    optionExData = OptionBasicQotExData()
    listTimestamp = 0.0
    updateTimestamp = 0.0
    preMarket = PreAfterMarketData()
    afterMarket = PreAfterMarketData()
    secStatus = 0
    futureExData = FutureBasicQotExData()
    warrantExData = WarrantBasicQotExData()
    name = ""
    overnight = PreAfterMarketData()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            security = PB.decode(d, Ref{Security})
        elseif field_number == 2
            isSuspended = PB.decode(d, Bool)
        elseif field_number == 3
            listTime = PB.decode(d, String)
        elseif field_number == 4
            priceSpread = PB.decode(d, Float64)
        elseif field_number == 5
            updateTime = PB.decode(d, String)
        elseif field_number == 6
            highPrice = PB.decode(d, Float64)
        elseif field_number == 7
            openPrice = PB.decode(d, Float64)
        elseif field_number == 8
            lowPrice = PB.decode(d, Float64)
        elseif field_number == 9
            curPrice = PB.decode(d, Float64)
        elseif field_number == 10
            lastClosePrice = PB.decode(d, Float64)
        elseif field_number == 11
            volume = PB.decode(d, Int64)
        elseif field_number == 12
            turnover = PB.decode(d, Float64)
        elseif field_number == 13
            turnoverRate = PB.decode(d, Float64)
        elseif field_number == 14
            amplitude = PB.decode(d, Float64)
        elseif field_number == 15
            darkStatus = PB.decode(d, Int32)
        elseif field_number == 16
            optionExData = PB.decode(d, Ref{OptionBasicQotExData})
        elseif field_number == 17
            listTimestamp = PB.decode(d, Float64)
        elseif field_number == 18
            updateTimestamp = PB.decode(d, Float64)
        elseif field_number == 19
            preMarket = PB.decode(d, Ref{PreAfterMarketData})
        elseif field_number == 20
            afterMarket = PB.decode(d, Ref{PreAfterMarketData})
        elseif field_number == 21
            secStatus = PB.decode(d, Int32)
        elseif field_number == 22
            futureExData = PB.decode(d, Ref{FutureBasicQotExData})
        elseif field_number == 23
            warrantExData = PB.decode(d, Ref{WarrantBasicQotExData})
        elseif field_number == 24
            name = PB.decode(d, String)
        elseif field_number == 25
            overnight = PB.decode(d, Ref{PreAfterMarketData})
        else
            PB.skip(d, wire_type)
        end
    end
    return BasicQot(security = security, isSuspended = isSuspended, listTime = listTime, priceSpread = priceSpread, updateTime = updateTime,
        highPrice = highPrice, openPrice = openPrice, lowPrice = lowPrice, curPrice = curPrice, lastClosePrice = lastClosePrice, volume = volume, 
        turnover = turnover, turnoverRate = turnoverRate, amplitude = amplitude, darkStatus = darkStatus, optionExData = optionExData, 
        listTimestamp = listTimestamp, updateTimestamp = updateTimestamp, preMarket = preMarket, afterMarket = afterMarket, secStatus = secStatus,
        futureExData = futureExData, warrantExData = warrantExData, name = name, overnight = overnight
    )
end

mutable struct TimeShare
    time::String            # 时间字符串
    minute::Int32           # 距离0点过了多少分钟
    isBlank::Bool           # 是否是空内容的点,若为ture则只有时间信息
    price::Float64          # 当前价
    lastClosePrice::Float64 # 昨收价
    avgPrice::Float64       # 均价
    volume::Int64           # 成交量
    turnover::Float64       # 成交额
    timestamp::Float64      # 时间戳
end
# 位置参数构造函数
TimeShare(time::AbstractString, minute::Integer, isBlank::Bool, price::Real, lastClosePrice::Real, avgPrice::Real, volume::Integer, turnover::Real, timestamp::Real) =
    TimeShare(String(time), Int32(minute), Bool(isBlank), Float64(price), Float64(lastClosePrice), Float64(avgPrice), Int64(volume), Float64(turnover), Float64(timestamp))
# 关键字参数构造函数
TimeShare(; time::AbstractString = "", minute::Integer = 0, isBlank::Bool = false, price::Real = 0.0, lastClosePrice::Real = 0.0, avgPrice::Real = 0.0, volume::Integer = 0, turnover::Real = 0.0, timestamp::Real = 0.0) =
    TimeShare(String(time), Int32(minute), Bool(isBlank), Float64(price), Float64(lastClosePrice), Float64(avgPrice), Int64(volume), Float64(turnover), Float64(timestamp))

PB.default_values(::Type{TimeShare}) = (; time = "", minute = Int32(0), isBlank = false, price = 0.0, lastClosePrice = 0.0, avgPrice = 0.0, volume = Int64(0), turnover = 0.0, timestamp = 0.0)
PB.field_numbers(::Type{TimeShare}) = (; time = 1, minute = 2, isBlank = 3, price = 4, lastClosePrice = 5, avgPrice = 6, volume = 7, turnover = 8, timestamp = 9)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:TimeShare})
    time = ""
    minute = Int32(0)
    isBlank = false
    price = 0.0
    lastClosePrice = 0.0
    avgPrice = 0.0
    volume = Int64(0)
    turnover = 0.0
    timestamp = 0.0
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            time = PB.decode(d, String)
        elseif field_number == 2
            minute = PB.decode(d, Int32)
        elseif field_number == 3
            isBlank = PB.decode(d, Bool)
        elseif field_number == 4
            price = PB.decode(d, Float64)
        elseif field_number == 5
            lastClosePrice = PB.decode(d, Float64)
        elseif field_number == 6
            avgPrice = PB.decode(d, Float64)
        elseif field_number == 7
            volume = PB.decode(d, Int64)
        elseif field_number == 8
            turnover = PB.decode(d, Float64)
        elseif field_number == 9
            timestamp = PB.decode(d, Float64)
        else
            PB.skip(d, wire_type)
        end
    end
    return TimeShare(time, minute, isBlank, price, lastClosePrice, avgPrice, volume, turnover, timestamp)
end

mutable struct SecurityStaticBasic
    security::Security                  # 股票
    id::Int64                           # ID
    lotSize::Int32                      # 每手数量,期权以及期货类型表示合约乘数
    secType::Int32                      # Qot_Common.SecurityType,股票类型
    name::String                        # 股票名称
    listTime::String                    # 上市时间
    delisting::Bool                     # 是否退市
    listTimestamp::Float64              # 上市时间戳
    exchType::Int32                     # Qot_Common.ExchType,所属交易所
    SecurityStaticBasic(; security = Security(), id = 0, lotSize = 0, secType = 0, name = "", listTime = "", delisting = false, listTimestamp = 0.0, exchType = 0) = new(security, id, lotSize, secType, name, listTime, delisting, listTimestamp, exchType)
end

PB.default_values(::Type{SecurityStaticBasic}) = (; security = Security(), id = Int64(0), lotSize = Int32(0), secType = Int32(0), name = "", listTime = "", delisting = false, listTimestamp = 0.0, exchType = Int32(0))
PB.field_numbers(::Type{SecurityStaticBasic}) = (security = 1, id = 2, lotSize = 3, secType = 4, name = 5, listTime = 6, delisting = 7, listTimestamp = 8, exchType = 9)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:SecurityStaticBasic})
    security = Security()
    id = Int64(0)
    lotSize = Int32(0)
    secType = Int32(0)
    name = ""
    listTime = ""
    delisting = false
    listTimestamp = 0.0
    exchType = Int32(0)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            security = PB.decode(d, Ref{Security})
        elseif field_number == 2
            id = PB.decode(d, Int64)
        elseif field_number == 3
            lotSize = PB.decode(d, Int32)
        elseif field_number == 4
            secType = PB.decode(d, Int32)
        elseif field_number == 5
            name = PB.decode(d, String)
        elseif field_number == 6
            listTime = PB.decode(d, String)
        elseif field_number == 7
            delisting = PB.decode(d, Bool)
        elseif field_number == 8
            listTimestamp = PB.decode(d, Float64)
        elseif field_number == 9
            exchType = PB.decode(d, Int32)
        else
            PB.skip(d, wire_type)
        end
    end
    return SecurityStaticBasic(; security = security, id = id, lotSize = lotSize, secType = secType, name = name, listTime = listTime,
        delisting = delisting, listTimestamp = listTimestamp, exchType = exchType)
end

mutable struct WarrantStaticExData
    type::Int32                         # Qot_Common.WarrantType,窝轮类型
    owner::Security                     # 所属正股
    WarrantStaticExData(; type = 0, owner = Security()) = new(type, owner)
end

PB.default_values(::Type{WarrantStaticExData}) = (; type = Int32(0), owner = Security())
PB.field_numbers(::Type{WarrantStaticExData}) = (; type = 1, owner = 2)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:WarrantStaticExData})
    type = Int32(0)
    owner = Security()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            type = PB.decode(d, Int32)
        elseif field_number == 2
            owner = PB.decode(d, Ref{Security})
        else
            PB.skip(d, wire_type)
        end
    end
    return WarrantStaticExData(; type = type, owner = owner)
end

mutable struct OptionStaticExData
    type::Int32                         # Qot_Common.OptionType,期权类型
    owner::Security                     # 标的股
    strikeTime::String                  # 行权时间
    strikePrice::Float64                # 行权价
    suspend::Bool                       # 是否停牌
    market::String                      # 交易所
    strikeTimestamp::Float64            # 行权时间戳
    indexOptionType::Int32              # Qot_Common.IndexOptionType, 指数期权的类型，仅在指数期权有效
    expirationCycle::Int32              # ExpirationCycle，交割周期
    optionStandardType::Int32           # OptionStandardType，标准期权
    optionSettlementMode::Int32         # OptionSettlementMode，结算方式
    
    OptionStaticExData(; 
    type = 0, owner = Security(), strikeTime = "", strikePrice = 0.0, suspend = false, market = "", 
    strikeTimestamp = 0.0, indexOptionType = 0, expirationCycle = 0, optionStandardType = 0, 
    optionSettlementMode = 0) = new(type, owner, strikeTime, strikePrice, suspend, market, 
    strikeTimestamp, indexOptionType, expirationCycle, optionStandardType, optionSettlementMode
    )
end

PB.default_values(::Type{OptionStaticExData}) = (; type = Int32(0), owner = Security(), strikeTime = "", strikePrice = 0.0, suspend = false, market = "", strikeTimestamp = 0.0, indexOptionType = Int32(0), expirationCycle = Int32(0), optionStandardType = Int32(0), optionSettlementMode = Int32(0))
PB.field_numbers(::Type{OptionStaticExData}) = (; type = 1, owner = 2, strikeTime = 3, strikePrice = 4, suspend = 5, market = 6, strikeTimestamp = 7, indexOptionType = 8, expirationCycle = 9, optionStandardType = 10, optionSettlementMode = 11)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:OptionStaticExData})
    type = Int32(0)
    owner = Security()
    strikeTime = ""
    strikePrice = 0.0
    suspend = false
    market = ""
    strikeTimestamp = 0.0
    indexOptionType = Int32(0)
    expirationCycle = Int32(0)
    optionStandardType = Int32(0)
    optionSettlementMode = Int32(0)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            type = PB.decode(d, Int32)
        elseif field_number == 2
            owner = PB.decode(d, Ref{Security})
        elseif field_number == 3
            strikeTime = PB.decode(d, String)
        elseif field_number == 4
            strikePrice = PB.decode(d, Float64)
        elseif field_number == 5
            suspend = PB.decode(d, Bool)
        elseif field_number == 6
            market = PB.decode(d, String)
        elseif field_number == 7
            strikeTimestamp = PB.decode(d, Float64)
        elseif field_number == 8
            indexOptionType = PB.decode(d, Int32)
        elseif field_number == 9
            expirationCycle = PB.decode(d, Int32)
        elseif field_number == 10
            optionStandardType = PB.decode(d, Int32)
        elseif field_number == 11
            optionSettlementMode = PB.decode(d, Int32)
        else
            PB.skip(d, wire_type)
        end
    end
    return OptionStaticExData(type = type, owner = owner, strikeTime = strikeTime, strikePrice = strikePrice, suspend = suspend, market = market, strikeTimestamp = strikeTimestamp, indexOptionType = indexOptionType, expirationCycle = expirationCycle, optionStandardType = optionStandardType, optionSettlementMode = optionSettlementMode)
end

mutable struct FutureStaticExData
    lastTradeTime::String               # 最后交易日，只有非主连期货合约才有该字段
    lastTradeTimestamp::Float64         # 最后交易日时间戳，只有非主连期货合约才有该字段
    isMainContract::Bool                # 是否主连期货合约
    FutureStaticExData(; lastTradeTime = "", lastTradeTimestamp = 0.0, isMainContract = false) = new(lastTradeTime, lastTradeTimestamp, isMainContract)
end

PB.default_values(::Type{FutureStaticExData}) = (; lastTradeTime = "", lastTradeTimestamp = 0.0, isMainContract = false)
PB.field_numbers(::Type{FutureStaticExData}) = (; lastTradeTime = 1, lastTradeTimestamp = 2, isMainContract = 3)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:FutureStaticExData})
    lastTradeTime = ""
    lastTradeTimestamp = 0.0
    isMainContract = false
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            lastTradeTime = PB.decode(d, String)
        elseif field_number == 2
            lastTradeTimestamp = PB.decode(d, Float64)
        elseif field_number == 3
            isMainContract = PB.decode(d, Bool)
        else
            PB.skip(d, wire_type)
        end
    end
    return FutureStaticExData(; lastTradeTime = lastTradeTime, lastTradeTimestamp = lastTradeTimestamp, isMainContract = isMainContract)
end

mutable struct SecurityStaticInfo
    basic::SecurityStaticBasic              # 基本股票静态信息
    warrantExData::WarrantStaticExData      # 窝轮额外股票静态信息
    optionExData::OptionStaticExData        # 期权额外股票静态信息
    futureExData::FutureStaticExData        # 期货额外股票静态信息
    SecurityStaticInfo(; basic = SecurityStaticBasic(), warrantExData = WarrantStaticExData(), optionExData = OptionStaticExData(), futureExData = FutureStaticExData()) = new(basic, warrantExData, optionExData, futureExData)
end

PB.default_values(::Type{SecurityStaticInfo}) = (;
    basic = SecurityStaticBasic(),
    warrantExData = WarrantStaticExData(),
    optionExData = OptionStaticExData(),
    futureExData = FutureStaticExData(),
)
PB.field_numbers(::Type{SecurityStaticInfo}) = (;
    basic = 1,
    warrantExData = 2,
    optionExData = 3,
    futureExData = 4,
)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:SecurityStaticInfo})
    basic = SecurityStaticBasic()
    warrantExData = WarrantStaticExData()
    optionExData = OptionStaticExData()
    futureExData = FutureStaticExData()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            basic = PB.decode(d, Ref{SecurityStaticBasic})
        elseif field_number == 2
            warrantExData = PB.decode(d, Ref{WarrantStaticExData})
        elseif field_number == 3
            optionExData = PB.decode(d, Ref{OptionStaticExData})
        elseif field_number == 4
            futureExData = PB.decode(d, Ref{FutureStaticExData})
        else
            PB.skip(d, wire_type)
        end
    end
    return SecurityStaticInfo(
        basic = basic,
        warrantExData = warrantExData,
        optionExData = optionExData,
        futureExData = futureExData,
    )
end

mutable struct Broker
    id::Int64                              # 经纪ID
    name::String                           # 经纪名称
    pos::Int32                             # 经纪档位
    orderID::Int64                         # 交易所订单ID，与交易接口返回的订单ID并不一样
    volume::Int64                          # 订单股数
end
# 位置参数构造函数
Broker(id::Integer, name::AbstractString, pos::Integer, orderID::Integer, volume::Integer) =
    Broker(Int64(id), String(name), Int32(pos), Int64(orderID), Int64(volume))
# 关键字参数构造函数
Broker(; id::Integer = 0, name::AbstractString = "", pos::Integer = 0, orderID::Integer = 0, volume::Integer = 0) =
    Broker(Int64(id), String(name), Int32(pos), Int64(orderID), Int64(volume))

PB.default_values(::Type{Broker}) = (id = Int64(0), name = "", pos = Int32(0), orderID = Int64(0), volume = Int64(0))
PB.field_numbers(::Type{Broker}) = (id = 1, name = 2, pos = 3, orderID = 4, volume = 5)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:Broker})
    id = Int64(0)
    name = ""
    pos = Int32(0)
    orderID = Int64(0)
    volume = Int64(0)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            id = PB.decode(d, Int64)
        elseif field_number == 2
            name = PB.decode(d, String)
        elseif field_number == 3
            pos = PB.decode(d, Int32)
        elseif field_number == 4
            orderID = PB.decode(d, Int64)
        elseif field_number == 5
            volume = PB.decode(d, Int64)
        else
            PB.skip(d, wire_type)
        end
    end
    return Broker(id, name, pos, orderID, volume)
end

mutable struct Ticker
    time::String                    # 时间字符串
    sequence::Int64                 # 唯一标识
    dir::Int32                      # TickerDirection, 买卖方向
    price::Float64                  # 价格
    volume::Int64                   # 成交量
    turnover::Float64               # 成交额
    recvTime::Float64               # 收到推送数据的本地时间戳，用于定位延迟
    type::Int32                     # TickerType, 逐笔类型
    typeSign::Int32                 # 逐笔类型符号
    pushDataType::Int32             # 用于区分推送情况
    timestamp::Float64              # 时间戳
end
# 位置参数构造函数
Ticker(time::AbstractString, sequence::Integer, dir::Integer, price::Real, volume::Integer, turnover::Real,
       recvTime::Real, type::Integer, typeSign::Integer, pushDataType::Integer, timestamp::Real) =
    Ticker(String(time), Int64(sequence), Int32(dir), Float64(price), Int64(volume), Float64(turnover),
           Float64(recvTime), Int32(type), Int32(typeSign), Int32(pushDataType), Float64(timestamp))
# 关键字参数构造函数
Ticker(; time::AbstractString = "", sequence::Integer = 0, dir::Integer = 0, price::Real = 0.0, volume::Integer = 0, turnover::Real = 0.0,
       recvTime::Real = 0.0, type::Integer = 0, typeSign::Integer = 0, pushDataType::Integer = 0, timestamp::Real = 0.0) =
    Ticker(String(time), Int64(sequence), Int32(dir), Float64(price), Int64(volume), Float64(turnover),
           Float64(recvTime), Int32(type), Int32(typeSign), Int32(pushDataType), Float64(timestamp))

PB.default_values(::Type{Ticker}) = (time = "", sequence = Int64(0), dir = Int32(0), price = 0.0, volume = Int64(0), turnover = 0.0, recvTime = 0.0, type = Int32(0), typeSign = Int32(0), pushDataType = Int32(0), timestamp = 0.0)
PB.field_numbers(::Type{Ticker}) = (time = 1, sequence = 2, dir = 3, price = 4, volume = 5, turnover = 6, recvTime = 7, type = 8, typeSign = 9, pushDataType = 10, timestamp = 11)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:Ticker})
    time = ""
    sequence = Int64(0)
    dir = Int32(0)
    price = 0.0
    volume = Int64(0)
    turnover = 0.0
    recvTime = 0.0
    type = Int32(0)
    typeSign = Int32(0)
    pushDataType = Int32(0)
    timestamp = 0.0
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            time = PB.decode(d, String)
        elseif field_number == 2
            sequence = PB.decode(d, Int64)
        elseif field_number == 3
            dir = PB.decode(d, Int32)
        elseif field_number == 4
            price = PB.decode(d, Float64)
        elseif field_number == 5
            volume = PB.decode(d, Int64)
        elseif field_number == 6
            turnover = PB.decode(d, Float64)
        elseif field_number == 7
            recvTime = PB.decode(d, Float64)
        elseif field_number == 8
            type = PB.decode(d, Int32)
        elseif field_number == 9
            typeSign = PB.decode(d, Int32)
        elseif field_number == 10
            pushDataType = PB.decode(d, Int32)
        elseif field_number == 11
            timestamp = PB.decode(d, Float64)
        else
            PB.skip(d, wire_type)
        end
    end
    return Ticker(time, sequence, dir, price, volume, turnover, recvTime, type, typeSign, pushDataType, timestamp)
end

mutable struct OrderBookDetail
    orderID::Int64
    volume::Int64
end
# 位置参数构造函数
OrderBookDetail(orderID::Integer, volume::Integer) = OrderBookDetail(Int64(orderID), Int64(volume))
# 关键字参数构造函数
OrderBookDetail(; orderID::Integer = 0, volume::Integer = 0) = OrderBookDetail(Int64(orderID), Int64(volume))

PB.default_values(::Type{OrderBookDetail}) = (orderID = Int64(0), volume = Int64(0))
PB.field_numbers(::Type{OrderBookDetail}) = (orderID = 1, volume = 2)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:OrderBookDetail})
    orderID = Int64(0)
    volume = Int64(0)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            orderID = PB.decode(d, Int64)
        elseif field_number == 2
            volume = PB.decode(d, Int64)
        else
            PB.skip(d, wire_type)
        end
    end
    return OrderBookDetail(orderID, volume)
end

mutable struct OrderBook
    price::Float64                          # 委托价格
    volume::Int64                           # 委托数量
    orederCount::Int32                      # 委托订单个数
    detailList::Vector{OrderBookDetail}     # 订单信息，SF行情特有
end
# 位置参数构造函数
OrderBook(price::Real, volume::Integer, orederCount::Integer, detailList::Vector{OrderBookDetail}) =
    OrderBook(Float64(price), Int64(volume), Int32(orederCount), detailList)
# 关键字参数构造函数
OrderBook(; price::Real = 0.0, volume::Integer = 0, orederCount::Integer = 0, detailList::Vector{OrderBookDetail} = Vector{OrderBookDetail}()) =
    OrderBook(Float64(price), Int64(volume), Int32(orederCount), detailList)
PB.default_values(::Type{OrderBook}) = (price = 0.0, volume = Int64(0), orederCount = Int32(0), detailList = Vector{OrderBookDetail}())
PB.field_numbers(::Type{OrderBook}) = (price = 1, volume = 2, orederCount = 3, detailList = 4)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:OrderBook})
    price = 0.0
    volume = Int64(0)
    orederCount = Int32(0)
    detailList = Vector{OrderBookDetail}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            price = PB.decode(d, Float64)
        elseif field_number == 2
            volume = PB.decode(d, Int64)
        elseif field_number == 3
            orederCount = PB.decode(d, Int32)
        elseif field_number == 4
            push!(detailList, PB.decode(d, Ref{OrderBookDetail}))
        else
            PB.skip(d, wire_type)
        end
    end
    return OrderBook(price, volume, orederCount, detailList)
end

mutable struct ShareHoldingChange
    holderName::String
    holdingQty::Float64
    holdingRatio::Float64
    changeQty::Float64
    changeRatio::Float64
    time::String
    timestamp::Float64
end

mutable struct SubInfo
    subType::Int32
    securityList::Vector{Security}
    SubInfo(subType::Int32, securityList::Vector{Security}) = new(subType, securityList)
    SubInfo(; subType = 0, securityList = Vector{Security}()) = new(Int32(subType), securityList)
end
PB.default_values(::Type{SubInfo}) = (;subType = 0, securityList = Vector{Security}())
PB.field_numbers(::Type{SubInfo}) = (;subType = 1, securityList = 2)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:SubInfo})
    subType = 0
    securityList = Vector{Security}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            subType = PB.decode(d, Int32)
        elseif field_number == 2
            push!(securityList, PB.decode(d, Ref{Security}))
        else
            PB.skip(d, wire_type)
        end
    end
    return SubInfo(subType = subType, securityList = securityList)
end

mutable struct ConnSubInfo
    subInfoList::Vector{SubInfo}
    usedQuota::Int32
    isOwnConnData::Bool
    ConnSubInfo(subInfoList::Vector{SubInfo}, usedQuota::Int32, isOwnConnData::Bool) = new(subInfoList, usedQuota, isOwnConnData)
    ConnSubInfo(; subInfoList = Vector{SubInfo}(), usedQuota = 0, isOwnConnData = false) = new(subInfoList, Int32(usedQuota), Bool(isOwnConnData))
end
PB.default_values(::Type{ConnSubInfo}) = (;subInfoList = Vector{SubInfo}(), usedQuota = 0, isOwnConnData = false)
PB.field_numbers(::Type{ConnSubInfo}) = (;subInfoList = 1, usedQuota = 2, isOwnConnData = 3)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:ConnSubInfo})
    subInfoList = Vector{SubInfo}()
    usedQuota = 0
    isOwnConnData = false
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            push!(subInfoList, PB.decode(d, Ref{SubInfo}))
        elseif field_number == 2
            usedQuota = PB.decode(d, Int32)
        elseif field_number == 3
            isOwnConnData = PB.decode(d, Bool)
        else
            PB.skip(d, wire_type)
        end
    end
    return ConnSubInfo(subInfoList = subInfoList, usedQuota = usedQuota, isOwnConnData = isOwnConnData)
end

mutable struct PlateInfo
    plate::Security
    name::String
    plateType::Int32
    PlateInfo(; plate::Security = Security(), name::String = "", plateType::Int32 = Int32(0)) = new(plate, name, plateType)
end
PB.default_values(::Type{PlateInfo}) = (; plate = Security(), name = "", plateType = Int32(0))
PB.field_numbers(::Type{PlateInfo}) = (; plate = 1, name = 2, plateType = 3)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:PlateInfo})
    plate = Security()
    name = ""
    plateType = Int32(0)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            plate = PB.decode(d, Ref{Security})
        elseif field_number == 2
            name = PB.decode(d, String)
        elseif field_number == 3
            plateType = PB.decode(d, Int32)
        else
            PB.skip(d, wire_type)
        end
    end
    return PlateInfo(; plate, name, plateType)
end

mutable struct Rehab
    time::String            # 时间字符串
    companyActFlag::Int64   # 公司行动(CompanyAct)组合标志位,指定某些字段值是否有效
    fwdFactorA::Float64     # 前复权因子A
    fwdFactorB::Float64     # 前复权因子B
    bwdFactorA::Float64     # 后复权因子A
    bwdFactorB::Float64     # 后复权因子B
    splitBase::Int32        # 拆股基数 (例如，1拆5，Base为1，Ert为5，optional)
    splitErt::Int32         # 拆股结果 (optional)
    joinBase::Int32         # 合股基数 (例如，50合1，Base为50，Ert为1，optional)
    joinErt::Int32          # 合股结果 (optional)
    bonusBase::Int32        # 送股基数 (例如，10送3, Base为10,Ert为3，optional)
    bonusErt::Int32         # 送股结果 (optional)
    transferBase::Int32     # 转赠股基数 (例如，10转3, Base为10,Ert为3，optional)
    transferErt::Int32      # 转赠股结果 (optional)
    allotBase::Int32        # 配股基数 (例如，10送2, 配股价为6.3元, Base为10, Ert为2, Price为6.3，optional)
    allotErt::Int32         # 配股结果 (optional)
    allotPrice::Float64     # 配股价格 (optional)
    addBase::Int32          # 增发股基数 (例如，10送2, 增发股价为6.3元, Base为10, Ert为2, Price为6.3，optional)
    addErt::Int32           # 增发股结果 (optional)
    addPrice::Float64       # 增发股价格 (optional)
    dividend::Float64       # 现金分红 (例如，每10股派现0.5元,则该字段值为0.05，optional)
    spDividend::Float64     # 特别股息 (例如，每10股派特别股息0.5元,则该字段值为0.05，optional)
    spinOffBase::Float64    # 分立基数 (optional)
    spinOffErt::Float64     # 分立结果 (optional)
    timestamp::Float64
    Rehab(; time = "", companyActFlag = Int64(0), fwdFactorA = 0.0, fwdFactorB = 0.0,
    bwdFactorA = 0.0, bwdFactorB = 0.0, splitBase = Int32(0), splitErt = Int32(0),
    joinBase = Int32(0), joinErt = Int32(0), bonusBase = Int32(0), bonusErt = Int32(0),
    transferBase = Int32(0), transferErt = Int32(0), allotBase = Int32(0), allotErt = Int32(0),
    allotPrice = 0.0, addBase = Int32(0), addErt = Int32(0), addPrice = 0.0, dividend = 0.0, 
    spDividend = 0.0, spinOffBase = 0.0, spinOffErt = 0.0, timestamp = 0.0
    ) = new(
        time, companyActFlag, fwdFactorA, fwdFactorB, bwdFactorA, bwdFactorB, splitBase, splitErt, 
        joinBase, joinErt, bonusBase, bonusErt, transferBase, transferErt, allotBase, allotErt, 
        allotPrice, addBase, addErt, addPrice, dividend, spDividend, spinOffBase, spinOffErt, timestamp
    )
end
PB.default_values(::Type{Rehab}) = (; time = "", companyActFlag = Int64(0), fwdFactorA = 0.0, fwdFactorB = 0.0,
bwdFactorA = 0.0, bwdFactorB = 0.0, splitBase = Int32(0), splitErt = Int32(0), joinBase = Int32(0),
joinErt = Int32(0), bonusBase = Int32(0), bonusErt = Int32(0), transferBase = Int32(0), transferErt = Int32(0),
allotBase = Int32(0), allotErt = Int32(0), allotPrice = 0.0, addBase = Int32(0), addErt = Int32(0),
addPrice = 0.0, dividend = 0.0, spDividend = 0.0, spinOffBase = 0.0, spinOffErt = 0.0, timestamp = 0.0
)
PB.field_numbers(::Type{Rehab}) = (; time = 1, companyActFlag = 2, fwdFactorA = 3, fwdFactorB = 4, bwdFactorA = 5, 
bwdFactorB = 6, splitBase = 7, splitErt = 8, joinBase = 9, joinErt = 10, bonusBase = 11, bonusErt = 12, 
transferBase = 13, transferErt = 14, allotBase = 15, allotErt = 16, allotPrice = 17, addBase = 18, addErt = 19, 
addPrice = 20, dividend = 21, spDividend = 22, timestamp = 23, spinOffBase = 24, spinOffErt = 25
)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:Rehab})
    time = ""
    companyActFlag = Int64(0)
    fwdFactorA = 0.0
    fwdFactorB = 0.0
    bwdFactorA = 0.0
    bwdFactorB = 0.0
    splitBase = Int32(0)
    splitErt = Int32(0)
    joinBase = Int32(0)
    joinErt = Int32(0)
    bonusBase = Int32(0)
    bonusErt = Int32(0)
    transferBase = Int32(0)
    transferErt = Int32(0)
    allotBase = Int32(0)
    allotErt = Int32(0)
    allotPrice = 0.0
    addBase = Int32(0)
    addErt = Int32(0)
    addPrice = 0.0
    dividend = 0.0
    spDividend = 0.0
    timestamp = 0.0
    spinOffBase = 0.0
    spinOffErt = 0.0
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            time = PB.decode(d, String)
        elseif field_number == 2
            companyActFlag = PB.decode(d, Int64)
        elseif field_number == 3
            fwdFactorA = PB.decode(d, Float64)
        elseif field_number == 4
            fwdFactorB = PB.decode(d, Float64)
        elseif field_number == 5
            bwdFactorA = PB.decode(d, Float64)
        elseif field_number == 6
            bwdFactorB = PB.decode(d, Float64)
        elseif field_number == 7
            splitBase = PB.decode(d, Int32)
        elseif field_number == 8
            splitErt = PB.decode(d, Int32)
        elseif field_number == 9
            joinBase = PB.decode(d, Int32)
        elseif field_number == 10
            joinErt = PB.decode(d, Int32)
        elseif field_number == 11
            bonusBase = PB.decode(d, Int32)
        elseif field_number == 12
            bonusErt = PB.decode(d, Int32)
        elseif field_number == 13
            transferBase = PB.decode(d, Int32)
        elseif field_number == 14
            transferErt = PB.decode(d, Int32)
        elseif field_number == 15
            allotBase = PB.decode(d, Int32)
        elseif field_number == 16
            allotErt = PB.decode(d, Int32)
        elseif field_number == 17
            allotPrice = PB.decode(d, Float64)
        elseif field_number == 18
            addBase = PB.decode(d, Int32)
        elseif field_number == 19
            addErt = PB.decode(d, Int32)
        elseif field_number == 20
            addPrice = PB.decode(d, Float64)
        elseif field_number == 21
            dividend = PB.decode(d, Float64)
        elseif field_number == 22
            spDividend = PB.decode(d, Float64)
        elseif field_number == 23
            timestamp = PB.decode(d, Float64)
        elseif field_number == 24
            spinOffBase = PB.decode(d, Float64)
        elseif field_number == 25
            spinOffErt = PB.decode(d, Float64)
        else
            PB.skip(d, wire_type)
        end
    end
    return Rehab(; time = time, companyActFlag = companyActFlag, fwdFactorA = fwdFactorA, fwdFactorB = fwdFactorB, 
    bwdFactorA = bwdFactorA, bwdFactorB = bwdFactorB, splitBase = splitBase, splitErt = splitErt, joinBase = joinBase, 
    joinErt = joinErt, bonusBase = bonusBase, bonusErt = bonusErt, transferBase = transferBase, transferErt = transferErt, 
    allotBase = allotBase, allotErt = allotErt, allotPrice = allotPrice, addBase = addBase, addErt = addErt, addPrice = addPrice,
    dividend = dividend, spDividend = spDividend, spinOffBase = spinOffBase, spinOffErt = spinOffErt, timestamp = timestamp
    )
end

# Format market status for user-friendly display
function format_market_status(state::QotMarketState.T)
    # Use EnumX's symbol function to get the enum name
    label = string(Symbol(state))
    # Convert to more readable format
    label = replace(label, "_" => " ")
    label = replace(label, r"([a-z])([A-Z])" => s"\1 \2")
    return label
end

export QotMarket, SecurityType, PlateSetType, WarrantType, OptionType, IndexOptionType, OptionAreaType, QotMarketState, 
       TradeDateMarket, TradeDateType, RehabType, KLType, KLFields, SubType, TickerDirection, TickerType, DarkStatus, 
       SecurityStatus, HolderCategory, PushDataType, SortField, Issuer, IpoPeriod, PriceType, WarrantStatus, CompanyAct, 
       QotRight, PriceReminderType, PriceReminderFreq, AssetClass, ExpirationCycle, OptionStandardType, OptionSettlementMode, 
       ExchType, PeriodType, PriceReminderMarketStatus, Security, KLine, OptionBasicQotExData, PreAfterMarketData, 
       FutureBasicQotExData, WarrantBasicQotExData, BasicQot, TimeShare, SecurityStaticBasic, WarrantStaticExData, 
       OptionStaticExData, FutureStaticExData, SecurityStaticInfo, Broker, Ticker, OrderBookDetail, OrderBook, ShareHoldingChange, 
       SubInfo, ConnSubInfo, PlateInfo, Rehab, format_market_status

end
