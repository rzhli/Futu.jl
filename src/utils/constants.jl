module Constants

using ..AllProtos

# ============================================================================
# 协议ID常量定义 (Protocol ID Constants)
# ============================================================================

# ----------------------------------------------------------------------------
# 核心协议ID (Core Protocol IDs)
# 连接、认证、心跳等基础协议
# ----------------------------------------------------------------------------
const INIT_CONNECT = 1001
const GET_GLOBAL_STATE = 1002
const NOTIFY = 1003
const KEEPALIVE = 1004
const GET_USER_INFO = 1005
const VERIFICATION = 1006
const GET_DELAY_STATISTICS = 1007
const TEST_CMD = 1008
const INIT_QUANT_MODE = 1009

# ----------------------------------------------------------------------------
# 行情协议ID - 订阅 (Quote Protocol IDs - Subscription)
# ----------------------------------------------------------------------------
const QOT_SUB = 3001
const QOT_REG_QOT_PUSH = 3002
const QOT_GET_SUB_INFO = 3003

# ----------------------------------------------------------------------------
# 行情协议ID - 实时数据获取 (Quote Protocol IDs - Real-time Data)
# ----------------------------------------------------------------------------
const QOT_GET_BASIC_QOT = 3004
const QOT_GET_KLINE = 3006
const QOT_GET_RT_DATA = 3008
const QOT_GET_TICKER = 3010
const QOT_GET_ORDER_BOOK = 3012
const QOT_GET_BROKER = 3014

# ----------------------------------------------------------------------------
# 行情协议ID - 推送通知 (Quote Protocol IDs - Push Notifications)
# ----------------------------------------------------------------------------
const QOT_UPDATE_BASIC_QOT = 3005
const QOT_UPDATE_KL = 3007
const QOT_UPDATE_RT = 3009
const QOT_UPDATE_TICKER = 3011
const QOT_UPDATE_ORDER_BOOK = 3013
const QOT_UPDATE_BROKER = 3015
const QOT_UPDATE_PRICE_REMINDER = 3019

# ----------------------------------------------------------------------------
# 行情协议ID - 历史数据 (Quote Protocol IDs - Historical Data)
# ----------------------------------------------------------------------------
const QOT_REQUEST_HISTORY_KL = 3103
const QOT_REQUEST_HISTORY_KL_QUOTA = 3104
const QOT_REQUEST_REHAB = 3105

# ----------------------------------------------------------------------------
# 行情协议ID - 市场基础数据 (Quote Protocol IDs - Basic Market Data)
# ----------------------------------------------------------------------------
const QOT_GET_STATIC_INFO = 3202
const QOT_GET_SECURITY_SNAPSHOT = 3203
const QOT_GET_PLATE_SET = 3204
const QOT_GET_PLATE_SECURITY = 3205
const QOT_GET_REFERENCE = 3206
const QOT_GET_OWNER_PLATE = 3207
const QOT_GET_CAPITAL_FLOW = 3211
const QOT_GET_CAPITAL_DISTRIBUTION = 3212
const QOT_GET_MARKET_STATE = 3223

# ----------------------------------------------------------------------------
# 行情协议ID - 衍生品 (Quote Protocol IDs - Derivatives)
# ----------------------------------------------------------------------------
const QOT_GET_OPTION_CHAIN = 3209
const QOT_GET_WARRANT = 3210
const QOT_GET_FUTURE_INFO = 3218
const QOT_GET_OPTION_EXPIRATION_DATE = 3224

# ----------------------------------------------------------------------------
# 行情协议ID - 市场筛选 (Quote Protocol IDs - Market Filter)
# ----------------------------------------------------------------------------
const QOT_STOCK_FILTER = 3215
const QOT_GET_IPO_LIST = 3217
const QOT_REQUEST_TRADE_DATE = 3219

# ----------------------------------------------------------------------------
# 行情协议ID - 自选股管理 (Quote Protocol IDs - Watchlist)
# ----------------------------------------------------------------------------
const QOT_GET_USER_SECURITY = 3213
const QOT_MODIFY_USER_SECURITY = 3214
const QOT_GET_USER_SECURITY_GROUP = 3222
const QOT_SET_PRICE_REMINDER = 3220
const QOT_GET_PRICE_REMINDER = 3221

# ----------------------------------------------------------------------------
# 交易协议ID (Trade Protocol IDs)
# ----------------------------------------------------------------------------
const TRD_GET_ACC_LIST = 2001
const TRD_UNLOCK_TRADE = 2005
const TRD_SUB_ACC_PUSH = 2008
const TRD_GET_FUNDS = 2101
const TRD_GET_POSITION_LIST = 2102
const TRD_GET_ORDER_LIST = 2201
const TRD_PLACE_ORDER = 2202
const TRD_MODIFY_ORDER = 2205
const TRD_CANCEL_ORDER = 2206
const TRD_GET_ORDER_FILL_LIST = 2211
const TRD_GET_HISTORY_ORDER_LIST = 2221
const TRD_GET_HISTORY_ORDER_FILL_LIST = 2222
const TRD_UPDATE_ORDER_FILL = 2218
const TRD_UPDATE_ORDER = 2208
const TRD_GET_ACC_CASHFLOW = 2301
const TRD_GET_CAPITAL_DISTRIBUTION = 2303
const TRD_GET_MAX_TRD_QTYS = 2111
const TRD_GET_MARGIN_RATIO = 2223
const TRD_GET_ORDER_FEE = 2225
const TRD_GET_FLOW_SUMMARY = 2226

# ============================================================================
# 协议模块导出 (Protocol Module Exports)
# ============================================================================

# ----------------------------------------------------------------------------
# 核心协议 (Core Protocols)
# 连接、状态查询、用户信息等基础协议
# ----------------------------------------------------------------------------
const InitConnect = AllProtos.InitConnect              # 初始化连接
const GetGlobalState = AllProtos.GetGlobalState        # 获取全局状态
const GetDelayStatistics = AllProtos.GetDelayStatistics # 获取延迟统计
const GetUserInfo = AllProtos.GetUserInfo              # 获取用户信息
const KeepAlive = AllProtos.KeepAlive                  # 保持连接心跳
const UserInfoField = GetUserInfo.UserInfoField        # 用户信息字段

# ----------------------------------------------------------------------------
# 基础行情协议 (Basic Quote Protocols)
# 订阅、实时报价、K线、分时、逐笔、盘口等
# ----------------------------------------------------------------------------
const Qot_Sub = AllProtos.Qot_Sub                      # 订阅行情
const Qot_GetSubInfo = AllProtos.Qot_GetSubInfo        # 获取订阅信息
const Qot_GetBasicQot = AllProtos.Qot_GetBasicQot      # 获取基础报价
const Qot_GetKL = AllProtos.Qot_GetKL                  # 获取K线数据
const Qot_GetRT = AllProtos.Qot_GetRT                  # 获取分时数据
const Qot_GetTicker = AllProtos.Qot_GetTicker          # 获取逐笔成交
const Qot_GetOrderBook = AllProtos.Qot_GetOrderBook    # 获取买卖盘
const Qot_GetBroker = AllProtos.Qot_GetBroker          # 获取经纪队列

# ----------------------------------------------------------------------------
# 历史数据协议 (Historical Data Protocols)
# 历史K线、复权信息等
# ----------------------------------------------------------------------------
const Qot_RequestHistoryKL = AllProtos.Qot_RequestHistoryKL           # 请求历史K线
const Qot_RequestHistoryKLQuota = AllProtos.Qot_RequestHistoryKLQuota # 获取历史K线配额
const Qot_RequestRehab = AllProtos.Qot_RequestRehab                   # 请求复权信息

# ----------------------------------------------------------------------------
# 市场与标的信息协议 (Market & Security Info Protocols)
# 静态信息、快照、板块、市场状态、交易日期等
# ----------------------------------------------------------------------------
const Qot_GetStaticInfo = AllProtos.Qot_GetStaticInfo           # 获取股票静态信息
const Qot_GetSecuritySnapshot = AllProtos.Qot_GetSecuritySnapshot # 获取股票快照
const Qot_GetMarketState = AllProtos.Qot_GetMarketState         # 获取市场状态
const Qot_GetPlateSet = AllProtos.Qot_GetPlateSet               # 获取板块集合
const Qot_GetPlateSecurity = AllProtos.Qot_GetPlateSecurity     # 获取板块成分股
const Qot_GetOwnerPlate = AllProtos.Qot_GetOwnerPlate           # 获取股票所属板块
const Qot_GetReference = AllProtos.Qot_GetReference             # 获取关联数据
const Qot_RequestTradeDate = AllProtos.Qot_RequestTradeDate     # 获取交易日期

# ----------------------------------------------------------------------------
# 资金流向协议 (Capital Flow Protocols)
# 资金流向、资金分布等
# ----------------------------------------------------------------------------
const Qot_GetCapitalFlow = AllProtos.Qot_GetCapitalFlow               # 获取资金流向
const Qot_GetCapitalDistribution = AllProtos.Qot_GetCapitalDistribution # 获取资金分布

# ----------------------------------------------------------------------------
# 衍生品协议 (Derivatives Protocols)
# 期权、窝轮、期货等
# ----------------------------------------------------------------------------
const Qot_GetOptionChain = AllProtos.Qot_GetOptionChain                 # 获取期权链
const Qot_GetOptionExpirationDate = AllProtos.Qot_GetOptionExpirationDate # 获取期权到期日
const Qot_GetWarrant = AllProtos.Qot_GetWarrant                         # 获取窝轮
const Qot_GetFutureInfo = AllProtos.Qot_GetFutureInfo                   # 获取期货信息

# ----------------------------------------------------------------------------
# 筛选与IPO协议 (Filter & IPO Protocols)
# 股票筛选、IPO信息等
# ----------------------------------------------------------------------------
const Qot_StockFilter = AllProtos.Qot_StockFilter      # 股票筛选
const Qot_GetIpoList = AllProtos.Qot_GetIpoList        # 获取IPO列表

# ----------------------------------------------------------------------------
# 自选股与提醒协议 (Watchlist & Reminder Protocols)
# 自选股管理、到价提醒等
# ----------------------------------------------------------------------------
const Qot_GetUserSecurity = AllProtos.Qot_GetUserSecurity             # 获取自选股
const Qot_GetUserSecurityGroup = AllProtos.Qot_GetUserSecurityGroup   # 获取自选股分组
const Qot_ModifyUserSecurity = AllProtos.Qot_ModifyUserSecurity       # 修改自选股
const Qot_GetPriceReminder = AllProtos.Qot_GetPriceReminder           # 获取到价提醒
const Qot_SetPriceReminder = AllProtos.Qot_SetPriceReminder           # 设置到价提醒

# ----------------------------------------------------------------------------
# 通用定义模块 (Common Definition Modules)
# 行情通用定义、交易通用定义、全局通用定义
# ----------------------------------------------------------------------------
const Qot_Common = AllProtos.Qot_Common                # 行情通用定义
const Trd_Common = AllProtos.Trd_Common                # 交易通用定义
const Common = AllProtos.Common                        # 全局通用定义
const Trd_FlowSummary = AllProtos.Trd_FlowSummary      # 交易资金流水

# ----------------------------------------------------------------------------
# 推送协议响应类型 (Push Protocol Response Types)
# 用于处理服务端主动推送的数据类型定义
# ----------------------------------------------------------------------------
const Qot_UpdateBasicQot = AllProtos.Qot_UpdateBasicQot           # 基础报价推送
const Qot_UpdateKL = AllProtos.Qot_UpdateKL                       # K线推送
const Qot_UpdateRT = AllProtos.Qot_UpdateRT                       # 分时推送
const Qot_UpdateTicker = AllProtos.Qot_UpdateTicker               # 逐笔推送
const Qot_UpdateOrderBook = AllProtos.Qot_UpdateOrderBook         # 买卖盘推送
const Qot_UpdateBroker = AllProtos.Qot_UpdateBroker               # 经纪队列推送
const Qot_UpdatePriceReminder = AllProtos.Qot_UpdatePriceReminder # 到价提醒推送
const Trd_UpdateOrder = AllProtos.Trd_UpdateOrder                 # 订单状态推送
const Trd_UpdateOrderFill = AllProtos.Trd_UpdateOrderFill         # 订单成交推送


# ============================================================================
# 枚举类型导出 (Enum Type Exports)
# ============================================================================

# ----------------------------------------------------------------------------
# 基础枚举 (Basic Enums)
# 用于基础行情功能的枚举类型
# ----------------------------------------------------------------------------
const QotMarket = Qot_Common.QotMarket          # 行情市场
const SubType = Qot_Common.SubType              # 订阅类型
const SecurityType = Qot_Common.SecurityType    # 证券类型
const KLType = Qot_Common.KLType                # K线类型
const RehabType = Qot_Common.RehabType          # 复权类型
const PeriodType = Qot_Common.PeriodType        # 周期类型
const RetType = Common.RetType                  # 返回结果类型
const CompanyAct = Qot_Common.CompanyAct        # 公司行动类型
const ExchType = Qot_Common.ExchType            # 交易所类型
const TradeDateType = Qot_Common.TradeDateType  # 交易日类型
const TradeDateMarket = Qot_Common.TradeDateMarket  # 交易日市场
const TickerDirection = Qot_Common.TickerDirection  # 逐笔方向
const TickerType = Qot_Common.TickerType            # 逐笔类型

# ----------------------------------------------------------------------------
# 扩展行情枚举 (Extended Quote Enums)
# 用于板块、窝轮、期权等扩展行情功能
# ----------------------------------------------------------------------------
const PlateSetType = Qot_Common.PlateSetType          # 板块类型
const SortField = Qot_Common.SortField                # 排序字段
const WarrantType = Qot_Common.WarrantType            # 窝轮类型
const WarrantStatus = Qot_Common.WarrantStatus        # 窝轮状态
const Issuer = Qot_Common.Issuer                      # 窝轮发行商
const PriceType = Qot_Common.PriceType                # 价内价外类型
const IpoPeriod = Qot_Common.IpoPeriod                # IPO时段
const OptionCondType = Qot_GetOptionChain.OptionCondType # 期权价内价外
const ReferenceType = Qot_GetReference.ReferenceType     # 关联数据类型
const IndexOptionType = Qot_Common.IndexOptionType       # 指数期权类型
const OptionType = Qot_Common.OptionType                 # 期权类型
const ExpirationCycle = Qot_Common.ExpirationCycle       # 到期周期
const DataFilter = Qot_GetOptionChain.DataFilter         # 期权链数据过滤器
const OptionStandardType = Qot_Common.OptionStandardType # 期权标准类型
const OptionSettlementMode = Qot_Common.OptionSettlementMode # 期权结算方式

# ----------------------------------------------------------------------------
# 股票筛选枚举 (Stock Filter Enums)
# 用于股票筛选功能的各类枚举
# ----------------------------------------------------------------------------
const StockField = Qot_StockFilter.StockField                   # 简单筛选字段
const AccumulateField = Qot_StockFilter.AccumulateField         # 累积筛选字段
const FinancialField = Qot_StockFilter.FinancialField           # 财务筛选字段
const CustomIndicatorField = Qot_StockFilter.CustomIndicatorField # 自定义技术指标字段
const PatternField = Qot_StockFilter.PatternField               # 形态技术指标字段
const FinancialQuarter = Qot_StockFilter.FinancialQuarter       # 财报周期
const RelativePosition = Qot_StockFilter.RelativePosition       # 相对位置
const SortDir = Qot_StockFilter.SortDir                         # 排序方向

# ----------------------------------------------------------------------------
# 用户个性化枚举 (User Customization Enums)
# 用于到价提醒、自选股管理等个性化功能
# ----------------------------------------------------------------------------
const PriceReminderType = Qot_Common.PriceReminderType             # 到价提醒类型
const PriceReminderFreq = Qot_Common.PriceReminderFreq             # 到价提醒频率
const PriceReminderMarketStatus = Qot_Common.PriceReminderMarketStatus # 到价提醒时段
const ModifyUserSecurityOp = Qot_ModifyUserSecurity.ModifyUserSecurityOp # 自选股操作类型
const GroupType = Qot_GetUserSecurityGroup.GroupType               # 自选股分组类型

# ----------------------------------------------------------------------------
# 交易枚举 (Trading Enums)
# 用于交易功能的各类枚举类型
# ----------------------------------------------------------------------------
const TrdEnv = Trd_Common.TrdEnv                    # 交易环境
const TrdMarket = Trd_Common.TrdMarket              # 交易市场
const TrdAccType = Trd_Common.TrdAccType            # 账户类型
const Currency = Trd_Common.Currency                # 货币类型
const SecurityFirm = Trd_Common.SecurityFirm        # 券商
const TrdSide = Trd_Common.TrdSide                  # 交易方向
const OrderType = Trd_Common.OrderType              # 订单类型
const OrderStatus = Trd_Common.OrderStatus          # 订单状态
const TrdSecMarket = Trd_Common.TrdSecMarket        # 交易证券市场
const TimeInForce = Trd_Common.TimeInForce          # 订单有效期
const TrailType = Trd_Common.TrailType              # 跟踪类型
const ModifyOrderOp = Trd_Common.ModifyOrderOp      # 修改订单操作
const PositionSide = Trd_Common.PositionSide        # 持仓方向
const OrderFillStatus = Trd_Common.OrderFillStatus  # 成交状态
const SimAccType = Trd_Common.SimAccType            # 模拟账户类型
const TrdAccStatus = Trd_Common.TrdAccStatus        # 账户状态
const TrdCategory = Trd_Common.TrdCategory          # 交易分类
const TrdCashFlowDirection = Trd_FlowSummary.TrdCashFlowDirection  # 资金流向
const Session = Common.Session                      # 交易时段
const CltRiskLevel = Trd_Common.CltRiskLevel        # 账户风险等级
const CltRiskStatus = Trd_Common.CltRiskStatus      # 账户风险状态
const DTStatus = Trd_Common.DTStatus                # 日内交易状态


# ============================================================================
# 协议映射表 (Protocol Mapping Tables)
# ============================================================================

# ----------------------------------------------------------------------------
# 响应协议映射 (Response Protocol Mapping)
# 将协议ID映射到对应的响应类型，用于解析服务端返回的数据
# ----------------------------------------------------------------------------
const PROTO_RESPONSE_MAP = Dict{UInt32, Type}(
    # 核心协议
    KEEPALIVE => AllProtos.KeepAlive.Response,
    NOTIFY => AllProtos.Notify.Response,
    GET_GLOBAL_STATE => AllProtos.GetGlobalState.Response,
    GET_DELAY_STATISTICS => AllProtos.GetDelayStatistics.Response,
    GET_USER_INFO => AllProtos.GetUserInfo.Response,

    # 基础行情协议
    QOT_SUB => AllProtos.Qot_Sub.Response,
    QOT_REG_QOT_PUSH => AllProtos.Qot_RegQotPush.Response,
    QOT_GET_SUB_INFO => AllProtos.Qot_GetSubInfo.Response,
    QOT_GET_BASIC_QOT => AllProtos.Qot_GetBasicQot.Response,
    QOT_GET_KLINE => AllProtos.Qot_GetKL.Response,
    QOT_GET_RT_DATA => AllProtos.Qot_GetRT.Response,
    QOT_GET_TICKER => AllProtos.Qot_GetTicker.Response,
    QOT_GET_ORDER_BOOK => AllProtos.Qot_GetOrderBook.Response,
    QOT_GET_BROKER => AllProtos.Qot_GetBroker.Response,

    # 历史数据协议
    QOT_REQUEST_HISTORY_KL => AllProtos.Qot_RequestHistoryKL.Response,
    QOT_REQUEST_HISTORY_KL_QUOTA => AllProtos.Qot_RequestHistoryKLQuota.Response,
    QOT_REQUEST_REHAB => AllProtos.Qot_RequestRehab.Response,

    # 市场与标的信息协议
    QOT_GET_STATIC_INFO => AllProtos.Qot_GetStaticInfo.Response,
    QOT_GET_SECURITY_SNAPSHOT => AllProtos.Qot_GetSecuritySnapshot.Response,
    QOT_GET_PLATE_SET => AllProtos.Qot_GetPlateSet.Response,
    QOT_GET_PLATE_SECURITY => AllProtos.Qot_GetPlateSecurity.Response,
    QOT_GET_REFERENCE => AllProtos.Qot_GetReference.Response,
    QOT_GET_OWNER_PLATE => AllProtos.Qot_GetOwnerPlate.Response,
    QOT_GET_MARKET_STATE => AllProtos.Qot_GetMarketState.Response,
    QOT_REQUEST_TRADE_DATE => AllProtos.Qot_RequestTradeDate.Response,

    # 资金流向协议
    QOT_GET_CAPITAL_FLOW => AllProtos.Qot_GetCapitalFlow.Response,
    QOT_GET_CAPITAL_DISTRIBUTION => AllProtos.Qot_GetCapitalDistribution.Response,

    # 衍生品协议
    QOT_GET_OPTION_CHAIN => AllProtos.Qot_GetOptionChain.Response,
    QOT_GET_WARRANT => AllProtos.Qot_GetWarrant.Response,
    QOT_GET_FUTURE_INFO => AllProtos.Qot_GetFutureInfo.Response,
    QOT_GET_OPTION_EXPIRATION_DATE => AllProtos.Qot_GetOptionExpirationDate.Response,

    # 筛选与IPO协议
    QOT_STOCK_FILTER => AllProtos.Qot_StockFilter.Response,
    QOT_GET_IPO_LIST => AllProtos.Qot_GetIpoList.Response,

    # 自选股与提醒协议
    QOT_GET_USER_SECURITY => AllProtos.Qot_GetUserSecurity.Response,
    QOT_MODIFY_USER_SECURITY => AllProtos.Qot_ModifyUserSecurity.Response,
    QOT_GET_USER_SECURITY_GROUP => AllProtos.Qot_GetUserSecurityGroup.Response,
    QOT_SET_PRICE_REMINDER => AllProtos.Qot_SetPriceReminder.Response,
    QOT_GET_PRICE_REMINDER => AllProtos.Qot_GetPriceReminder.Response,

    # 交易协议
    TRD_GET_ACC_LIST => AllProtos.Trd_GetAccList.Response,
    TRD_UNLOCK_TRADE => AllProtos.Trd_UnlockTrade.Response,
    TRD_GET_FUNDS => AllProtos.Trd_GetFunds.Response,
    TRD_GET_POSITION_LIST => AllProtos.Trd_GetPositionList.Response,
    TRD_GET_ORDER_LIST => AllProtos.Trd_GetOrderList.Response,
    TRD_PLACE_ORDER => AllProtos.Trd_PlaceOrder.Response,
    TRD_MODIFY_ORDER => AllProtos.Trd_ModifyOrder.Response,
    TRD_GET_ORDER_FILL_LIST => AllProtos.Trd_GetOrderFillList.Response,
    TRD_GET_HISTORY_ORDER_LIST => AllProtos.Trd_GetHistoryOrderList.Response,
    TRD_GET_HISTORY_ORDER_FILL_LIST => AllProtos.Trd_GetHistoryOrderFillList.Response,
    TRD_GET_MAX_TRD_QTYS => AllProtos.Trd_GetMaxTrdQtys.Response,
    TRD_GET_MARGIN_RATIO => AllProtos.Trd_GetMarginRatio.Response,
    TRD_GET_ORDER_FEE => AllProtos.Trd_GetOrderFee.Response,
    TRD_GET_FLOW_SUMMARY => AllProtos.Trd_FlowSummary.Response,
    TRD_SUB_ACC_PUSH => AllProtos.Trd_SubAccPush.Response,
)

# ----------------------------------------------------------------------------
# 推送协议映射 (Push Protocol Mapping)
# 将协议ID映射到对应的推送类型，用于解析服务端主动推送的数据
# ----------------------------------------------------------------------------
const PROTO_PUSH_MAP = Dict{UInt32, Type}(
    # 行情推送协议
    QOT_UPDATE_BASIC_QOT => AllProtos.Qot_UpdateBasicQot.Response,
    QOT_UPDATE_KL => AllProtos.Qot_UpdateKL.Response,
    QOT_UPDATE_RT => AllProtos.Qot_UpdateRT.Response,
    QOT_UPDATE_TICKER => AllProtos.Qot_UpdateTicker.Response,
    QOT_UPDATE_ORDER_BOOK => AllProtos.Qot_UpdateOrderBook.Response,
    QOT_UPDATE_BROKER => AllProtos.Qot_UpdateBroker.Response,
    QOT_UPDATE_PRICE_REMINDER => AllProtos.Qot_UpdatePriceReminder.Response,

    # 交易推送协议
    TRD_UPDATE_ORDER_FILL => AllProtos.Trd_UpdateOrderFill.Response,
    TRD_UPDATE_ORDER => AllProtos.Trd_UpdateOrder.Response,
)

# ----------------------------------------------------------------------------
# 订阅类型到协议ID映射 (SubType to Protocol ID Mapping)
# 将订阅类型映射到对应的推送协议ID，用于处理订阅后的推送数据
# ----------------------------------------------------------------------------
const SUBTYPE_TO_PROTOID = Dict(
    # 基础报价订阅
    Qot_Common.SubType.Basic => QOT_UPDATE_BASIC_QOT,

    # 盘口订阅
    Qot_Common.SubType.OrderBook => QOT_UPDATE_ORDER_BOOK,

    # 逐笔订阅
    Qot_Common.SubType.Ticker => QOT_UPDATE_TICKER,

    # 分时订阅
    Qot_Common.SubType.RT => QOT_UPDATE_RT,

    # K线订阅（各周期）
    Qot_Common.SubType.K_1M => QOT_UPDATE_KL,
    Qot_Common.SubType.K_3M => QOT_UPDATE_KL,
    Qot_Common.SubType.K_5M => QOT_UPDATE_KL,
    Qot_Common.SubType.K_15M => QOT_UPDATE_KL,
    Qot_Common.SubType.K_30M => QOT_UPDATE_KL,
    Qot_Common.SubType.K_60M => QOT_UPDATE_KL,
    Qot_Common.SubType.K_Day => QOT_UPDATE_KL,
    Qot_Common.SubType.K_Week => QOT_UPDATE_KL,
    Qot_Common.SubType.K_Month => QOT_UPDATE_KL,
    Qot_Common.SubType.K_Quarter => QOT_UPDATE_KL,
    Qot_Common.SubType.K_Year => QOT_UPDATE_KL,

    # 经纪队列订阅
    Qot_Common.SubType.Broker => QOT_UPDATE_BROKER,
)


# ============================================================================
# 导出列表 (Export List)
# ============================================================================

# 导出协议ID常量
export INIT_CONNECT, GET_GLOBAL_STATE, NOTIFY, KEEPALIVE, GET_USER_INFO, VERIFICATION,
       GET_DELAY_STATISTICS, TEST_CMD, INIT_QUANT_MODE,
       QOT_SUB, QOT_REG_QOT_PUSH, QOT_GET_SUB_INFO,
       QOT_GET_BASIC_QOT, QOT_GET_KLINE, QOT_GET_RT_DATA, QOT_GET_TICKER,
       QOT_GET_ORDER_BOOK, QOT_GET_BROKER,
       QOT_UPDATE_BASIC_QOT, QOT_UPDATE_KL, QOT_UPDATE_RT, QOT_UPDATE_TICKER,
       QOT_UPDATE_ORDER_BOOK, QOT_UPDATE_BROKER, QOT_UPDATE_PRICE_REMINDER,
       QOT_REQUEST_HISTORY_KL, QOT_REQUEST_HISTORY_KL_QUOTA, QOT_REQUEST_REHAB,
       QOT_GET_STATIC_INFO, QOT_GET_SECURITY_SNAPSHOT, QOT_GET_PLATE_SET,
       QOT_GET_PLATE_SECURITY, QOT_GET_REFERENCE, QOT_GET_OWNER_PLATE,
       QOT_GET_CAPITAL_FLOW, QOT_GET_CAPITAL_DISTRIBUTION, QOT_GET_MARKET_STATE,
       QOT_GET_OPTION_CHAIN, QOT_GET_WARRANT, QOT_GET_FUTURE_INFO,
       QOT_GET_OPTION_EXPIRATION_DATE,
       QOT_STOCK_FILTER, QOT_GET_IPO_LIST, QOT_REQUEST_TRADE_DATE,
       QOT_GET_USER_SECURITY, QOT_MODIFY_USER_SECURITY, QOT_GET_USER_SECURITY_GROUP,
       QOT_SET_PRICE_REMINDER, QOT_GET_PRICE_REMINDER,
       TRD_GET_ACC_LIST, TRD_UNLOCK_TRADE, TRD_SUB_ACC_PUSH, TRD_GET_FUNDS,
       TRD_GET_POSITION_LIST, TRD_GET_ORDER_LIST, TRD_PLACE_ORDER,
       TRD_MODIFY_ORDER, TRD_CANCEL_ORDER, TRD_GET_ORDER_FILL_LIST,
       TRD_GET_HISTORY_ORDER_LIST, TRD_GET_HISTORY_ORDER_FILL_LIST,
       TRD_UPDATE_ORDER_FILL, TRD_UPDATE_ORDER, TRD_GET_ACC_CASHFLOW,
       TRD_GET_CAPITAL_DISTRIBUTION, TRD_GET_MAX_TRD_QTYS, TRD_GET_MARGIN_RATIO,
       TRD_GET_ORDER_FEE, TRD_GET_FLOW_SUMMARY

# 导出核心协议
export InitConnect, GetGlobalState, GetDelayStatistics, GetUserInfo, KeepAlive, UserInfoField

# 导出基础行情协议
export Qot_Sub, Qot_GetSubInfo, Qot_GetBasicQot, Qot_GetKL, Qot_GetRT, Qot_GetTicker,
       Qot_GetOrderBook, Qot_GetBroker

# 导出历史数据协议
export Qot_RequestHistoryKL, Qot_RequestHistoryKLQuota, Qot_RequestRehab

# 导出市场与标的信息协议
export Qot_GetStaticInfo, Qot_GetSecuritySnapshot, Qot_GetMarketState, Qot_GetPlateSet,
       Qot_GetPlateSecurity, Qot_GetOwnerPlate, Qot_GetReference, Qot_RequestTradeDate

# 导出资金流向协议
export Qot_GetCapitalFlow, Qot_GetCapitalDistribution

# 导出衍生品协议
export Qot_GetOptionChain, Qot_GetOptionExpirationDate, Qot_GetWarrant, Qot_GetFutureInfo

# 导出筛选与IPO协议
export Qot_StockFilter, Qot_GetIpoList

# 导出自选股与提醒协议
export Qot_GetUserSecurity, Qot_GetUserSecurityGroup, Qot_ModifyUserSecurity,
       Qot_GetPriceReminder, Qot_SetPriceReminder

# ----------------------------------------------------------------------------
# 交易协议 (Trade Protocols)
# 账户管理、资金查询、持仓、订单等交易相关协议
# ----------------------------------------------------------------------------
const Trd_GetAccList = AllProtos.Trd_GetAccList              # 获取账户列表
const Trd_UnlockTrade = AllProtos.Trd_UnlockTrade            # 解锁交易
const Trd_GetFunds = AllProtos.Trd_GetFunds                  # 获取账户资金
const Trd_GetMaxTrdQtys = AllProtos.Trd_GetMaxTrdQtys        # 获取最大可交易数量
const Trd_GetPositionList = AllProtos.Trd_GetPositionList    # 获取持仓列表
const Trd_GetOrderList = AllProtos.Trd_GetOrderList          # 获取订单列表
const Trd_PlaceOrder = AllProtos.Trd_PlaceOrder              # 下单
const Trd_ModifyOrder = AllProtos.Trd_ModifyOrder            # 修改订单
const Trd_GetOrderFillList = AllProtos.Trd_GetOrderFillList  # 获取成交列表
const Trd_GetHistoryOrderList = AllProtos.Trd_GetHistoryOrderList          # 获取历史订单列表
const Trd_GetHistoryOrderFillList = AllProtos.Trd_GetHistoryOrderFillList  # 获取历史成交列表
const Trd_GetMarginRatio = AllProtos.Trd_GetMarginRatio      # 获取保证金比例
const Trd_GetOrderFee = AllProtos.Trd_GetOrderFee            # 获取订单费用
const Trd_FlowSummary = AllProtos.Trd_FlowSummary            # 获取资金流水
const Trd_SubAccPush = AllProtos.Trd_SubAccPush              # 订阅账户推送

# 导出交易协议模块
export Trd_GetAccList, Trd_UnlockTrade, Trd_GetFunds, Trd_GetMaxTrdQtys, Trd_GetPositionList, Trd_GetOrderList,
       Trd_PlaceOrder, Trd_ModifyOrder, Trd_GetOrderFillList, Trd_GetHistoryOrderList,
       Trd_GetHistoryOrderFillList, Trd_GetMarginRatio, Trd_GetOrderFee,
       Trd_FlowSummary, Trd_SubAccPush

# 导出通用定义模块
export Qot_Common, Trd_Common, Common, Trd_FlowSummary

# 导出推送协议响应类型
export Qot_UpdateBasicQot, Qot_UpdateKL, Qot_UpdateRT, Qot_UpdateTicker,
       Qot_UpdateOrderBook, Qot_UpdateBroker, Qot_UpdatePriceReminder,
       Trd_UpdateOrder, Trd_UpdateOrderFill

# 导出基础枚举
export QotMarket, SubType, SecurityType, KLType, RehabType, PeriodType, RetType,
       CompanyAct, ExchType, TradeDateType, TradeDateMarket, TickerDirection, TickerType

# 导出扩展行情枚举
export PlateSetType, SortField, WarrantType, WarrantStatus, Issuer, PriceType,
       IpoPeriod, OptionCondType, ReferenceType, IndexOptionType, OptionType, ExpirationCycle, DataFilter, OptionStandardType, OptionSettlementMode

# 导出股票筛选枚举
export StockField, AccumulateField, FinancialField, CustomIndicatorField, PatternField,
       FinancialQuarter, RelativePosition, SortDir

# 导出用户个性化枚举
export PriceReminderType, PriceReminderFreq, ModifyUserSecurityOp, PriceReminderMarketStatus, GroupType

# 导出交易枚举
export TrdEnv, TrdMarket, TrdAccType, Currency, SecurityFirm, TrdSide, OrderType, OrderStatus,
       TrdSecMarket, TimeInForce, TrailType, ModifyOrderOp, PositionSide, OrderFillStatus,
       SimAccType, TrdAccStatus, TrdCategory, TrdCashFlowDirection, Session,
       CltRiskLevel, CltRiskStatus, DTStatus

# 导出协议映射表
export PROTO_RESPONSE_MAP, PROTO_PUSH_MAP, SUBTYPE_TO_PROTOID

end # module Constants
