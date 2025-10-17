module Trd_Common

"""
    Trd_Common

交易公共模块 (Trading common module)

此模块定义了交易相关的枚举类型和数据结构，用于富途OpenAPI交易功能。
This module defines trading-related enumerations and data structures for Futu OpenAPI trading functionality.
"""

import ProtoBuf as PB
using ProtoBuf.EnumX
import ..Common

"""
    TrdEnv

交易环境 (Trading Environment)

- Simulate = 0: 仿真环境(模拟环境) / Simulation environment (paper trading)
- Real = 1: 真实环境 / Real trading environment
"""
@enumx TrdEnv begin
    Simulate = 0  # 仿真环境(模拟环境)
    Real = 1      # 真实环境
end

"""
    TrdCategory

交易品类 (Trading Category)

- Unknown = 0: 未知品类 / Unknown category
- Security = 1: 证券 / Securities
- Future = 2: 期货 / Futures
"""
@enumx TrdCategory begin
    Unknown = 0   # 未知品类
    Security = 1  # 证券
    Future = 2    # 期货
end

"""
    TrdMarket

交易市场，是大的市场，不是具体品种 (Trading Market, broad market classification)

- Unknown = 0: 未知市场 / Unknown market
- HK = 1: 香港市场 / Hong Kong market
- US = 2: 美国市场 / US market
- CN = 3: 大陆市场 / China mainland market
- HKCC = 4: 香港A股通市场 / Hong Kong Stock Connect market
- Futures = 5: 期货市场 / Futures market
- SG = 6: 新加坡市场 / Singapore market
- AU = 8: 澳洲市场 / Australia market
- Futures_Simulate_HK = 10: 模拟交易期货市场(香港) / Simulated futures market (HK)
- Futures_Simulate_US = 11: 模拟交易期货市场(美国) / Simulated futures market (US)
- Futures_Simulate_SG = 12: 模拟交易期货市场(新加坡) / Simulated futures market (SG)
- Futures_Simulate_JP = 13: 模拟交易期货市场(日本) / Simulated futures market (JP)
- Jp = 15: 日本市场 / Japan market
- MY = 111: 马来西亚市场 / Malaysia market
- CA = 112: 加拿大市场 / Canada market
- HK_Fund = 113: 香港基金市场 / Hong Kong fund market
- US_Fund = 123: 美国基金市场 / US fund market
"""
@enumx TrdMarket begin
    Unknown = 0                 # 未知市场
    HK = 1                      # 香港市场
    US = 2                      # 美国市场
    CN = 3                      # 大陆市场
    HKCC = 4                    # 香港A股通市场
    Futures = 5                 # 期货市场
    SG = 6                      # 新加坡市场
    AU = 8                      # 澳洲市场
    Futures_Simulate_HK = 10    # 模拟交易期货市场(香港)
    Futures_Simulate_US = 11    # 模拟交易期货市场(美国)
    Futures_Simulate_SG = 12    # 模拟交易期货市场(新加坡)
    Futures_Simulate_JP = 13    # 模拟交易期货市场(日本)
    Jp = 15                     # 日本市场
    MY = 111                    # 马来西亚市场
    CA = 112                    # 加拿大市场
    HK_Fund = 113              # 香港基金市场
    US_Fund = 123              # 美国基金市场
end

"""
    TrdSecMarket

可交易证券所属市场，目前主要是区分A股的沪市和深市，香港和美国暂不需要细分
(Tradeable security market, mainly differentiates Shanghai and Shenzhen for A-shares)

- Unknown = 0: 未知市场 / Unknown market
- HK = 1: 香港市场(股票、窝轮、牛熊、期权、期货等) / HK market (stocks, warrants, CBBCs, options, futures, etc.)
- US = 2: 美国市场(股票、期权、期货等) / US market (stocks, options, futures, etc.)
- CN_SH = 31: 沪股市场(股票) / Shanghai stock market
- CN_SZ = 32: 深股市场(股票) / Shenzhen stock market
- SG = 41: 新加坡市场(期货) / Singapore market (futures)
- Jp = 51: 日本市场(期货) / Japan market (futures)
- AU = 61: 澳大利亚市场 / Australia market
- MY = 71: 马来西亚市场 / Malaysia market
- CA = 81: 加拿大市场 / Canada market
- FX = 91: 外汇市场 / Foreign exchange market
"""
@enumx TrdSecMarket begin
    Unknown = 0  # 未知市场
    HK = 1       # 香港市场(股票、窝轮、牛熊、期权、期货等)
    US = 2       # 美国市场(股票、期权、期货等)
    CN_SH = 31   # 沪股市场(股票)
    CN_SZ = 32   # 深股市场(股票)
    SG = 41      # 新加坡市场(期货)
    Jp = 51      # 日本市场(期货)
    AU = 61      # 澳大利亚
    MY = 71      # 马来西亚
    CA = 81      # 加拿大
    FX = 91      # 外汇
end

"""
    TrdSide

交易方向 (Trading Side)

客户端下单只传Buy或Sell即可，SellShort是美股订单时服务器返回有此方向，BuyBack目前不存在，但也不排除服务器会传
(Client only needs to send Buy or Sell, SellShort is returned by server for US stocks, BuyBack may be returned by server)

- Unknown = 0: 未知方向 / Unknown
- Buy = 1: 买入 / Buy
- Sell = 2: 卖出 / Sell
- SellShort = 3: 卖空 / Sell short
- BuyBack = 4: 买回 / Buy back
"""
@enumx TrdSide begin
    Unknown = 0    # 未知方向
    Buy = 1        # 买入
    Sell = 2       # 卖出
    SellShort = 3  # 卖空
    BuyBack = 4    # 买回
end

"""
    OrderType

订单类型 (Order Type)

- Unknown = 0: 未知类型 / Unknown
- Normal = 1: 普通订单(港股的增强限价单、港股期权的限价单，A股限价委托、美股的限价单，港股期货的限价单，CME期货的限价单) / Normal order (Enhanced limit order for HK stocks, limit order for HK options, A-share limit order, US limit order, HK futures limit order, CME futures limit order). Currently only this type is supported for HK options.
- Market = 2: 市价订单(目前支持美股、港股正股、涡轮、牛熊、界内证) / Market order (currently supports US stocks, HK stocks, warrants, CBBCs, inline warrants)
- AbsoluteLimit = 5: 绝对限价订单(目前仅港股)，只有价格完全匹配才成交 / Absolute limit order (HK only), trades only at exact price
- Auction = 6: 竞价订单(目前仅港股)，仅港股早盘竞价和收盘竞价有效 / Auction order (HK only), valid for opening and closing auctions
- AuctionLimit = 7: 竞价限价订单(目前仅港股) / Auction limit order (HK only)
- SpecialLimit = 8: 特别限价订单(目前仅港股)，成交规则同增强限价订单，且部分成交后，交易所自动撤销订单 / Special limit order (HK only)
- SpecialLimit_All = 9: 特别限价且要求全部成交订单(目前仅港股) / Special limit order requiring full fill (HK only)
- Stop = 10: 止损市价单 / Stop market order
- StopLimit = 11: 止损限价单 / Stop limit order
- MarketifTouched = 12: 触及市价单（止盈） / Market if touched order (take profit)
- LimitifTouched = 13: 触及限价单（止盈） / Limit if touched order (take profit)
- TrailingStop = 14: 跟踪止损市价单 / Trailing stop market order
- TrailingStopLimit = 15: 跟踪止损限价单 / Trailing stop limit order
- TWAP_MARKET = 16: TWAP 市价单 / TWAP market order
- TWAP_LIMIT = 17: TWAP 限价单 / TWAP limit order
- VWAP_MARKET = 18: VWAP 市价单 / VWAP market order
- VWAP_LIMIT = 19: VWAP 限价单 / VWAP limit order
"""
@enumx OrderType begin
    Unknown = 0               # 未知类型
    Normal = 1                # 普通订单(增强限价单/限价单)
    Market = 2                # 市价订单
    AbsoluteLimit = 5         # 绝对限价订单(仅港股)
    Auction = 6               # 竞价订单(仅港股)
    AuctionLimit = 7          # 竞价限价订单(仅港股)
    SpecialLimit = 8          # 特别限价订单(仅港股)
    SpecialLimit_All = 9      # 特别限价且要求全部成交订单(仅港股)
    Stop = 10                 # 止损市价单
    StopLimit = 11            # 止损限价单
    MarketifTouched = 12      # 触及市价单（止盈）
    LimitifTouched = 13       # 触及限价单（止盈）
    TrailingStop = 14         # 跟踪止损市价单
    TrailingStopLimit = 15    # 跟踪止损限价单
    TWAP_MARKET = 16          # TWAP 市价单
    TWAP_LIMIT = 17           # TWAP 限价单
    VWAP_MARKET = 18          # VWAP 市价单
    VWAP_LIMIT = 19           # VWAP 限价单
end

"""
    TrailType

跟踪类型 (Trail Type)

- Unknown = 0: 未知类型 / Unknown
- Ratio = 1: 比例 / Ratio (percentage)
- Amount = 2: 金额 / Amount (absolute value)
"""
@enumx TrailType begin
    Unknown = 0  # 未知类型
    Ratio = 1    # 比例
    Amount = 2   # 金额
end

"""
    OrderStatus

订单状态 (Order Status)

- Unsubmitted = 0: 未提交 / Not submitted
- Unknown = -1: 未知状态 / Unknown status
- WaitingSubmit = 1: 等待提交 / Waiting to submit
- Submitting = 2: 提交中 / Submitting
- SubmitFailed = 3: 提交失败，下单失败 / Submit failed, order placement failed
- TimeOut = 4: 处理超时，结果未知 / Processing timeout, result unknown
- Submitted = 5: 已提交，等待成交 / Submitted, waiting for fill
- Filled_Part = 10: 部分成交 / Partially filled
- Filled_All = 11: 全部已成 / Fully filled
- Cancelling_Part = 12: 正在撤单_部分(部分已成交，正在撤销剩余部分) / Cancelling partial (partially filled, cancelling remaining)
- Cancelling_All = 13: 正在撤单_全部 / Cancelling all
- Cancelled_Part = 14: 部分成交，剩余部分已撤单 / Partially filled, remaining cancelled
- Cancelled_All = 15: 全部已撤单，无成交 / Fully cancelled, no fill
- Failed = 21: 下单失败，服务拒绝 / Order failed, rejected by server
- Disabled = 22: 已失效 / Disabled
- Deleted = 23: 已删除，无成交的订单才能删除 / Deleted, only unfilled orders can be deleted
- FillCancelled = 24: 成交被撤销 / Fill cancelled
"""
@enumx OrderStatus begin
    Unsubmitted = 0         # 未提交
    Unknown = -1            # 未知状态
    WaitingSubmit = 1       # 等待提交
    Submitting = 2          # 提交中
    SubmitFailed = 3        # 提交失败，下单失败
    TimeOut = 4             # 处理超时，结果未知
    Submitted = 5           # 已提交，等待成交
    Filled_Part = 10        # 部分成交
    Filled_All = 11         # 全部已成
    Cancelling_Part = 12    # 正在撤单_部分
    Cancelling_All = 13     # 正在撤单_全部
    Cancelled_Part = 14     # 部分成交，剩余部分已撤单
    Cancelled_All = 15      # 全部已撤单，无成交
    Failed = 21             # 下单失败，服务拒绝
    Disabled = 22           # 已失效
    Deleted = 23            # 已删除
    FillCancelled = 24      # 成交被撤销
end

"""
    OrderFillStatus

一笔成交的状态 (Fill Status)

- OK = 0: 正常 / Normal
- Cancelled = 1: 成交被取消 / Fill cancelled
- Changed = 2: 成交被更改 / Fill changed
"""
@enumx OrderFillStatus begin
    OK = 0         # 正常
    Cancelled = 1  # 成交被取消
    Changed = 2    # 成交被更改
end

"""
    PositionSide

持仓方向类型 (Position Side)

- Long = 0: 多仓，默认情况是多仓 / Long position, default
- Unknown = -1: 未知方向 / Unknown
- Short = 1: 空仓 / Short position
"""
@enumx PositionSide begin
    Long = 0      # 多仓，默认情况是多仓
    Unknown = -1  # 未知方向
    Short = 1     # 空仓
end

"""
    ModifyOrderOp

修改订单的操作类型 (Modify Order Operation)

港股支持全部操作，美股目前仅支持Normal和Cancel
(HK stocks support all operations, US stocks currently only support Normal and Cancel)

- Unknown = 0: 未知操作 / Unknown
- Normal = 1: 修改订单的价格、数量等，即以前的改单 / Modify order price, quantity, etc.
- Cancel = 2: 撤单 / Cancel order
- Disable = 3: 失效 / Disable order
- Enable = 4: 生效 / Enable order
- Delete = 5: 删除 / Delete order
"""
@enumx ModifyOrderOp begin
    Unknown = 0  # 未知操作
    Normal = 1   # 修改订单的价格、数量等
    Cancel = 2   # 撤单
    Disable = 3  # 失效
    Enable = 4   # 生效
    Delete = 5   # 删除
end

"""
    TrdAccType

交易账户类型 (Trading Account Type)

- Unknown = 0: 未知类型 / Unknown
- Cash = 1: 现金账户 / Cash account
- Margin = 2: 保证金账户 / Margin account
"""
@enumx TrdAccType begin
    Unknown = 0  # 未知类型
    Cash = 1     # 现金账户
    Margin = 2   # 保证金账户
end

"""
    TrdAccStatus

交易账户状态 (Trading Account Status)

- Active = 0: 激活 / Active
- Disabled = 1: 禁用 / Disabled
"""
@enumx TrdAccStatus begin
    Active = 0    # 激活
    Disabled = 1  # 禁用
end

"""
    Currency

货币种类 (Currency)

- Unknown = 0: 未知货币 / Unknown
- HKD = 1: 港币 / Hong Kong Dollar
- USD = 2: 美元 / US Dollar
- CNH = 3: 离岸人民币 / Offshore Chinese Yuan
- JPY = 4: 日元 / Japanese Yen
- SGD = 5: 新币 / Singapore Dollar
- AUD = 6: 澳元 / Australian Dollar
- CAD = 7: 加拿大元 / Canadian Dollar
- MYR = 8: 马来西亚林吉特 / Malaysian Ringgit
"""
@enumx Currency begin
    Unknown = 0  # 未知货币
    HKD = 1      # 港币
    USD = 2      # 美元
    CNH = 3      # 离岸人民币
    JPY = 4      # 日元
    SGD = 5      # 新币
    AUD = 6      # 澳元
    CAD = 7      # 加拿大元
    MYR = 8      # 马来西亚林吉特
end

"""
    CltRiskLevel

账户风险控制等级 (Account Risk Level)

- Unknown = -1: 未知 / Unknown
- Safe = 0: 安全 / Safe
- Warning = 1: 预警 / Warning
- Danger = 2: 危险 / Danger
- AbsoluteSafe = 3: 绝对安全 / Absolutely safe
- OptDanger = 4: 危险, 期权相关 / Danger, option related
"""
@enumx CltRiskLevel begin
    Unknown = -1       # 未知
    Safe = 0           # 安全
    Warning = 1        # 预警
    Danger = 2         # 危险
    AbsoluteSafe = 3   # 绝对安全
    OptDanger = 4      # 危险, 期权相关
end

"""
    TimeInForce

订单有效期 (Time In Force)

- DAY = 0: 当日有效 / Day order
- GTC = 1: 撤单前有效，最多持续90自然日 / Good till cancelled, maximum 90 calendar days
"""
@enumx TimeInForce begin
    DAY = 0  # 当日有效
    GTC = 1  # 撤单前有效，最多持续90自然日
end

"""
    SecurityFirm

券商 (Security Firm)

- Unknown = 0: 未知 / Unknown
- FutuSecurities = 1: 富途证券（香港） / Futu Securities (Hong Kong)
- FutuInc = 2: 富途证券（美国） / Futu Inc (US)
- FutuSG = 3: 富途证券（新加坡） / Futu (Singapore)
- FutuAU = 4: 富途证券（澳洲） / Futu (Australia)
"""
@enumx SecurityFirm begin
    Unknown = 0          # 未知
    FutuSecurities = 1   # 富途证券（香港）
    FutuInc = 2          # 富途证券（美国）
    FutuSG = 3           # 富途证券（新加坡）
    FutuAU = 4           # 富途证券（澳洲）
end

"""
    SimAccType

模拟交易账户类型 (Simulation Account Type)

- Unknown = 0: 未知 / Unknown
- Stock = 1: 股票模拟账户（仅用于交易证券类产品，不支持交易期权） / Stock simulation account (for securities only, no options)
- Option = 2: 期权模拟账户（仅用于交易期权，不支持交易股票证券类产品） / Option simulation account (for options only, no stocks)
- Futures = 3: 期货模拟账户 / Futures simulation account
"""
@enumx SimAccType begin
    Unknown = 0   # 未知
    Stock = 1     # 股票模拟账户
    Option = 2    # 期权模拟账户
    Futures = 3   # 期货模拟账户
end

"""
    CltRiskStatus

风险状态，共分 9 个等级，LEVEL1是最安全，LEVEL9是最危险
(Risk Status, 9 levels, LEVEL1 is safest, LEVEL9 is most dangerous)

- Unknown = 0: 未知 / Unknown
- Level1 = 1: 非常安全 / Very safe
- Level2 = 2: 安全 / Safe
- Level3 = 3: 较安全 / Relatively safe
- Level4 = 4: 较低风险 / Low risk
- Level5 = 5: 中等风险 / Medium risk
- Level6 = 6: 较高风险 / Relatively high risk
- Level7 = 7: 预警 / Warning
- Level8 = 8: 预警 / Warning
- Level9 = 9: 预警 / Warning
"""
@enumx CltRiskStatus begin
    Unknown = 0  # 未知
    Level1 = 1   # 非常安全
    Level2 = 2   # 安全
    Level3 = 3   # 较安全
    Level4 = 4   # 较低风险
    Level5 = 5   # 中等风险
    Level6 = 6   # 较高风险
    Level7 = 7   # 预警
    Level8 = 8   # 预警
    Level9 = 9   # 预警
end

"""
    DTStatus

日内交易限制情况 (Day Trading Status)

- Unknown = 0: 未知 / Unknown
- Unlimited = 1: 无限次(当前可以无限次日内交易，注意留意剩余日内交易购买力) / Unlimited (can day trade unlimited times, watch remaining day trading buying power)
- EMCall = 2: EM Call(当前状态不能新建仓位，需要补充资产净值至\$25000以上) / EM Call (cannot open new positions, need to increase net asset value to above \$25000)
- DTCall = 3: DT Call(当前状态有未补平的日内交易追缴金额，需要在5个交易日内足额入金来补平) / DT Call (has outstanding day trading call amount, need to deposit funds within 5 trading days)
"""
@enumx DTStatus begin
    Unknown = 0     # 未知
    Unlimited = 1   # 无限次
    EMCall = 2      # EM Call
    DTCall = 3      # DT Call
end

"""
    AccCashInfo

账户现金信息，目前仅用于期货账户
(Account cash information, currently only for futures accounts)

Fields:
- currency::Int32: 货币类型，取值参考 Currency / Currency type, refer to Currency enum
- cash::Float64: 现金结余 / Cash balance
- availableBalance::Float64: 现金可提金额 / Available cash for withdrawal
- netCashPower::Float64: 现金购买力 / Cash buying power
"""
mutable struct AccCashInfo
    currency::Int32              # 货币类型
    cash::Float64                # 现金结余
    availableBalance::Float64    # 现金可提金额
    netCashPower::Float64        # 现金购买力
    AccCashInfo(; currency = 0, cash = 0.0, availableBalance = 0.0, netCashPower = 0.0) =
        new(Int32(currency), Float64(cash), Float64(availableBalance), Float64(netCashPower))
end

PB.default_values(::Type{AccCashInfo}) = (;currency = Int32(0), cash = 0.0, availableBalance = 0.0, netCashPower = 0.0)
PB.field_numbers(::Type{AccCashInfo}) = (;currency = 1, cash = 2, availableBalance = 3, netCashPower = 4)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:AccCashInfo})
    currency = Int32(0)
    cash = 0.0
    availableBalance = 0.0
    netCashPower = 0.0
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            currency = PB.decode(d, Int32)
        elseif field_number == 2
            cash = PB.decode(d, Float64)
        elseif field_number == 3
            availableBalance = PB.decode(d, Float64)
        elseif field_number == 4
            netCashPower = PB.decode(d, Float64)
        else
            PB.skip(d, wire_type)
        end
    end
    return AccCashInfo(currency = currency, cash = cash, availableBalance = availableBalance, netCashPower = netCashPower)
end

"""
    AccMarketInfo

分市场资产信息 (Asset information by market)

Fields:
- trdMarket::Int32: 交易市场, 参见TrdMarket的枚举定义 / Trading market, refer to TrdMarket enum
- assets::Float64: 分市场资产信息 / Assets in this market
"""
mutable struct AccMarketInfo
    trdMarket::Int32  # 交易市场
    assets::Float64   # 分市场资产信息
    AccMarketInfo(; trdMarket = 0, assets = 0.0) = new(Int32(trdMarket), Float64(assets))
end

PB.default_values(::Type{AccMarketInfo}) = (;trdMarket = Int32(0), assets = 0.0)
PB.field_numbers(::Type{AccMarketInfo}) = (;trdMarket = 1, assets = 2)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:AccMarketInfo})
    trdMarket = Int32(0)
    assets = 0.0
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            trdMarket = PB.decode(d, Int32)
        elseif field_number == 2
            assets = PB.decode(d, Float64)
        else
            PB.skip(d, wire_type)
        end
    end
    return AccMarketInfo(trdMarket = trdMarket, assets = assets)
end

"""
    TrdHeader

交易协议公共参数头 (Trading protocol common header)

Fields:
- trdEnv::Int32: 交易环境, 参见TrdEnv的枚举定义 / Trading environment, refer to TrdEnv enum
- accID::UInt64: 业务账号, 业务账号与交易环境、市场权限需要匹配，否则会返回错误 / Account ID, must match trading environment and market permissions
- trdMarket::Int32: 交易市场, 参见TrdMarket的枚举定义 / Trading market, refer to TrdMarket enum
"""
mutable struct TrdHeader
    trdEnv::Int32      # 交易环境
    accID::UInt64      # 业务账号
    trdMarket::Int32   # 交易市场
    TrdHeader(; trdEnv = 0, accID = 0, trdMarket = 0) = new(Int32(trdEnv), UInt64(accID), Int32(trdMarket))
end

PB.default_values(::Type{TrdHeader}) = (;trdEnv = Int32(0), accID = UInt64(0), trdMarket = Int32(0))
PB.field_numbers(::Type{TrdHeader}) = (;trdEnv = 1, accID = 2, trdMarket = 3)

function PB.encode(e::PB.AbstractProtoEncoder, x::TrdHeader)
    initpos = position(e.io)
    PB.encode(e, 1, x.trdEnv)  # Always encode trdEnv (Simulate=0 is meaningful)
    PB.encode(e, 2, x.accID)   # Always encode accID
    PB.encode(e, 3, x.trdMarket)  # Always encode trdMarket
    return position(e.io) - initpos
end

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:TrdHeader})
    trdEnv = Int32(0)
    accID = UInt64(0)
    trdMarket = Int32(0)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            trdEnv = PB.decode(d, Int32)
        elseif field_number == 2
            accID = PB.decode(d, UInt64)
        elseif field_number == 3
            trdMarket = PB.decode(d, Int32)
        else
            PB.skip(d, wire_type)
        end
    end
    return TrdHeader(trdEnv = trdEnv, accID = accID, trdMarket = trdMarket)
end

"""
    TrdAcc

交易业务账户结构 (Trading account structure)

Fields:
- trdEnv::Int32: 交易环境，参见TrdEnv的枚举定义 / Trading environment, refer to TrdEnv enum
- accID::UInt64: 业务账号 / Account ID
- trdMarketAuthList::Vector{Int32}: 业务账户支持的交易市场权限，即此账户能交易那些市场, 可拥有多个交易市场权限，目前仅单个，取值参见TrdMarket的枚举定义 / Trading market permissions, refer to TrdMarket enum
- accType::Int32: 账户类型，取值见TrdAccType / Account type, refer to TrdAccType enum
- cardNum::String: 卡号 / Card number
- securityFirm::Int32: 所属券商，取值见SecurityFirm / Security firm, refer to SecurityFirm enum
- simAccType::Int32: 模拟交易账号类型，取值见SimAccType / Simulation account type, refer to SimAccType enum
- uniCardNum::String: 所属综合账户卡号 / Universal account card number
- accStatus::Int32: 账号状态，取值见TrdAccStatus / Account status, refer to TrdAccStatus enum
"""
mutable struct TrdAcc
    trdEnv::Int32                     # 交易环境
    accID::UInt64                     # 业务账号
    trdMarketAuthList::Vector{Int32}  # 业务账户支持的交易市场权限
    accType::Int32                    # 账户类型
    cardNum::String                   # 卡号
    securityFirm::Int32               # 所属券商
    simAccType::Int32                 # 模拟交易账号类型
    uniCardNum::String                # 所属综合账户卡号
    accStatus::Int32                  # 账号状态
    TrdAcc(; trdEnv = 0, accID = 0, trdMarketAuthList = Vector{Int32}(), accType = 0, cardNum = "", securityFirm = 0, simAccType = 0, uniCardNum = "", accStatus = 0) = new(trdEnv, accID, trdMarketAuthList, accType, cardNum, securityFirm, simAccType, uniCardNum, accStatus)
end

PB.default_values(::Type{TrdAcc}) = (;trdEnv = Int32(0), accID = UInt64(0), trdMarketAuthList = Vector{Int32}(), accType = Int32(0), cardNum = "", securityFirm = Int32(0), simAccType = Int32(0), uniCardNum = "", accStatus = Int32(0))
PB.field_numbers(::Type{TrdAcc}) = (;trdEnv = 1, accID = 2, trdMarketAuthList = 3, accType = 4, cardNum = 5, securityFirm = 6, simAccType = 7, uniCardNum = 8, accStatus = 9)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:TrdAcc})
    trdEnv = Int32(0)
    accID = UInt64(0)
    trdMarketAuthList = Vector{Int32}()
    accType = Int32(0)
    cardNum = ""
    securityFirm = Int32(0)
    simAccType = Int32(0)
    uniCardNum = ""
    accStatus = Int32(0)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            trdEnv = PB.decode(d, Int32)
        elseif field_number == 2
            accID = PB.decode(d, UInt64)
        elseif field_number == 3
            push!(trdMarketAuthList, PB.decode(d, Int32))
        elseif field_number == 4
            accType = PB.decode(d, Int32)
        elseif field_number == 5
            cardNum = PB.decode(d, String)
        elseif field_number == 6
            securityFirm = PB.decode(d, Int32)
        elseif field_number == 7
            simAccType = PB.decode(d, Int32)
        elseif field_number == 8
            uniCardNum = PB.decode(d, String)
        elseif field_number == 9
            accStatus = PB.decode(d, Int32)
        else
            PB.skip(d, wire_type)
        end
    end
    return TrdAcc(trdEnv = trdEnv, accID = accID, trdMarketAuthList = trdMarketAuthList, accType = accType, cardNum = cardNum, securityFirm = securityFirm, simAccType = simAccType, uniCardNum = uniCardNum, accStatus = accStatus)
end

"""
    Funds

账户资金结构 (Account funds structure)

Fields:
- power::Float64: 最大购买力（做多），3位精度 / Maximum buying power (long), 3 decimal places
- totalAssets::Float64: 资产净值 / Total net assets
- cash::Float64: 现金 / Cash
- marketVal::Float64: 证券市值, 仅证券账户适用 / Securities market value, only for securities accounts
- frozenCash::Float64: 冻结资金 / Frozen cash
- debtCash::Float64: 计息金额 / Interest-bearing amount
- avlWithdrawalCash::Float64: 现金可提，仅证券账户适用 / Available cash for withdrawal, only for securities accounts
- currency::Int32: 币种，本结构体资金相关的货币类型，取值参见 Currency，期货适用 / Currency, refer to Currency enum, for futures
- availableFunds::Float64: 可用资金，期货适用 / Available funds, for futures
- unrealizedPL::Float64: 未实现盈亏，期货适用 / Unrealized profit/loss, for futures
- realizedPL::Float64: 已实现盈亏，期货适用 / Realized profit/loss, for futures
- riskLevel::Int32: 风控状态，参见 CltRiskLevel, 期货适用 / Risk level, refer to CltRiskLevel enum, for futures
- initialMargin::Float64: 初始保证金 / Initial margin
- maintenanceMargin::Float64: 维持保证金 / Maintenance margin
- cashInfoList::Vector{AccCashInfo}: 分币种的现金信息，期货适用 / Cash information by currency, for futures
- maxPowerShort::Float64: 卖空购买力 / Short selling buying power
- netCashPower::Float64: 现金购买力 / Net cash buying power
- longMv::Float64: 多头市值 / Long market value
- shortMv::Float64: 空头市值 / Short market value
- pendingAsset::Float64: 在途资产 / Pending assets
- maxWithdrawal::Float64: 融资可提，仅证券账户适用 / Maximum withdrawal (margin), only for securities accounts
- riskStatus::Int32: 风险状态，参见 CltRiskStatus，证券账户适用，共分 9 个等级，LEVEL1是最安全，LEVEL9是最危险 / Risk status, refer to CltRiskStatus, for securities accounts, 9 levels
- marginCallMargin::Float64: Margin Call 保证金 / Margin call margin
- isPdt::Bool: 是否PDT账户，仅富途证券（美国）账户适用 / Is PDT account, only for Futu Inc (US) accounts
- pdtSeq::String: 剩余日内交易次数 / Remaining day trading count
- beginningDTBP::Float64: 初始日内交易购买力 / Beginning day trading buying power
- remainingDTBP::Float64: 剩余日内交易购买力 / Remaining day trading buying power
- dtCallAmount::Float64: 日内交易待缴金额 / Day trading call amount
- dtStatus::Int32: 日内交易限制情况，取值见DTStatus / Day trading status, refer to DTStatus enum
- securitiesAssets::Float64: 证券资产净值 / Securities assets
- fundAssets::Float64: 基金资产净值 / Fund assets
- bondAssets::Float64: 债券资产净值 / Bond assets
- marketInfoList::Vector{AccMarketInfo}: 分市场资产信息 / Asset information by market
"""
mutable struct Funds
    power::Float64                        # 最大购买力（做多）
    totalAssets::Float64                  # 资产净值
    cash::Float64                         # 现金
    marketVal::Float64                    # 证券市值
    frozenCash::Float64                   # 冻结资金
    debtCash::Float64                     # 计息金额
    avlWithdrawalCash::Float64            # 现金可提
    currency::Int32                       # 币种
    availableFunds::Float64               # 可用资金（期货）
    unrealizedPL::Float64                 # 未实现盈亏（期货）
    realizedPL::Float64                   # 已实现盈亏（期货）
    riskLevel::Int32                      # 风控状态（期货）
    initialMargin::Float64                # 初始保证金
    maintenanceMargin::Float64            # 维持保证金
    cashInfoList::Vector{AccCashInfo}     # 分币种的现金信息（期货）
    maxPowerShort::Float64                # 卖空购买力
    netCashPower::Float64                 # 现金购买力
    longMv::Float64                       # 多头市值
    shortMv::Float64                      # 空头市值
    pendingAsset::Float64                 # 在途资产
    maxWithdrawal::Float64                # 融资可提
    riskStatus::Int32                     # 风险状态（证券）
    marginCallMargin::Float64             # Margin Call 保证金
    isPdt::Bool                           # 是否PDT账户
    pdtSeq::String                        # 剩余日内交易次数
    beginningDTBP::Float64                # 初始日内交易购买力
    remainingDTBP::Float64                # 剩余日内交易购买力
    dtCallAmount::Float64                 # 日内交易待缴金额
    dtStatus::Int32                       # 日内交易限制情况
    securitiesAssets::Float64             # 证券资产净值
    fundAssets::Float64                   # 基金资产净值
    bondAssets::Float64                   # 债券资产净值
    marketInfoList::Vector{AccMarketInfo} # 分市场资产信息
    Funds(; power = 0, totalAssets = 0, cash = 0, marketVal = 0, frozenCash = 0, debtCash = 0, avlWithdrawalCash = 0, currency = 0, availableFunds = 0, unrealizedPL = 0, realizedPL = 0, riskLevel = 0, initialMargin = 0, maintenanceMargin = 0, cashInfoList = Vector{AccCashInfo}(), maxPowerShort = 0, netCashPower = 0, longMv = 0, shortMv = 0, pendingAsset = 0, maxWithdrawal = 0, riskStatus = 0, marginCallMargin = 0, isPdt = false, pdtSeq = "", beginningDTBP = 0, remainingDTBP = 0, dtCallAmount = 0, dtStatus = 0, securitiesAssets = 0, fundAssets = 0, bondAssets = 0, marketInfoList = Vector{AccMarketInfo}()) = new(power, totalAssets, cash, marketVal, frozenCash, debtCash, avlWithdrawalCash, currency, availableFunds, unrealizedPL, realizedPL, riskLevel, initialMargin, maintenanceMargin, cashInfoList, maxPowerShort, netCashPower, longMv, shortMv, pendingAsset, maxWithdrawal, riskStatus, marginCallMargin, isPdt, pdtSeq, beginningDTBP, remainingDTBP, dtCallAmount, dtStatus, securitiesAssets, fundAssets, bondAssets, marketInfoList)
end

PB.default_values(::Type{Funds}) = (;power = 0.0, totalAssets = 0.0, cash = 0.0, marketVal = 0.0, frozenCash = 0.0, debtCash = 0.0, avlWithdrawalCash = 0.0, currency = Int32(0), availableFunds = 0.0, unrealizedPL = 0.0, realizedPL = 0.0, riskLevel = Int32(0), initialMargin = 0.0, maintenanceMargin = 0.0, cashInfoList = Vector{AccCashInfo}(), maxPowerShort = 0.0, netCashPower = 0.0, longMv = 0.0, shortMv = 0.0, pendingAsset = 0.0, maxWithdrawal = 0.0, riskStatus = Int32(0), marginCallMargin = 0.0, isPdt = false, pdtSeq = "", beginningDTBP = 0.0, remainingDTBP = 0.0, dtCallAmount = 0.0, dtStatus = Int32(0), securitiesAssets = 0.0, fundAssets = 0.0, bondAssets = 0.0, marketInfoList = Vector{AccMarketInfo}())
PB.field_numbers(::Type{Funds}) = (;power = 1, totalAssets = 2, cash = 3, marketVal = 4, frozenCash = 5, debtCash = 6, avlWithdrawalCash = 7, currency = 8, availableFunds = 9, unrealizedPL = 10, realizedPL = 11, riskLevel = 12, initialMargin = 13, maintenanceMargin = 14, cashInfoList = 15, maxPowerShort = 16, netCashPower = 17, longMv = 18, shortMv = 19, pendingAsset = 20, maxWithdrawal = 21, riskStatus = 22, marginCallMargin = 23, isPdt = 24, pdtSeq = 25, beginningDTBP = 26, remainingDTBP = 27, dtCallAmount = 28, dtStatus = 29, securitiesAssets = 30, fundAssets = 31, bondAssets = 32, marketInfoList = 33)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:Funds})
    power = 0.0
    totalAssets = 0.0
    cash = 0.0
    marketVal = 0.0
    frozenCash = 0.0
    debtCash = 0.0
    avlWithdrawalCash = 0.0
    currency = Int32(0)
    availableFunds = 0.0
    unrealizedPL = 0.0
    realizedPL = 0.0
    riskLevel = Int32(0)
    initialMargin = 0.0
    maintenanceMargin = 0.0
    cashInfoList = Vector{AccCashInfo}()
    maxPowerShort = 0.0
    netCashPower = 0.0
    longMv = 0.0
    shortMv = 0.0
    pendingAsset = 0.0
    maxWithdrawal = 0.0
    riskStatus = Int32(0)
    marginCallMargin = 0.0
    isPdt = false
    pdtSeq = ""
    beginningDTBP = 0.0
    remainingDTBP = 0.0
    dtCallAmount = 0.0
    dtStatus = Int32(0)
    securitiesAssets = 0.0
    fundAssets = 0.0
    bondAssets = 0.0
    marketInfoList = Vector{AccMarketInfo}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            power = PB.decode(d, Float64)
        elseif field_number == 2
            totalAssets = PB.decode(d, Float64)
        elseif field_number == 3
            cash = PB.decode(d, Float64)
        elseif field_number == 4
            marketVal = PB.decode(d, Float64)
        elseif field_number == 5
            frozenCash = PB.decode(d, Float64)
        elseif field_number == 6
            debtCash = PB.decode(d, Float64)
        elseif field_number == 7
            avlWithdrawalCash = PB.decode(d, Float64)
        elseif field_number == 8
            currency = PB.decode(d, Int32)
        elseif field_number == 9
            availableFunds = PB.decode(d, Float64)
        elseif field_number == 10
            unrealizedPL = PB.decode(d, Float64)
        elseif field_number == 11
            realizedPL = PB.decode(d, Float64)
        elseif field_number == 12
            riskLevel = PB.decode(d, Int32)
        elseif field_number == 13
            initialMargin = PB.decode(d, Float64)
        elseif field_number == 14
            maintenanceMargin = PB.decode(d, Float64)
        elseif field_number == 15
            push!(cashInfoList, PB.decode(d, Ref{AccCashInfo}))
        elseif field_number == 16
            maxPowerShort = PB.decode(d, Float64)
        elseif field_number == 17
            netCashPower = PB.decode(d, Float64)
        elseif field_number == 18
            longMv = PB.decode(d, Float64)
        elseif field_number == 19
            shortMv = PB.decode(d, Float64)
        elseif field_number == 20
            pendingAsset = PB.decode(d, Float64)
        elseif field_number == 21
            maxWithdrawal = PB.decode(d, Float64)
        elseif field_number == 22
            riskStatus = PB.decode(d, Int32)
        elseif field_number == 23
            marginCallMargin = PB.decode(d, Float64)
        elseif field_number == 24
            isPdt = PB.decode(d, Bool)
        elseif field_number == 25
            pdtSeq = PB.decode(d, String)
        elseif field_number == 26
            beginningDTBP = PB.decode(d, Float64)
        elseif field_number == 27
            remainingDTBP = PB.decode(d, Float64)
        elseif field_number == 28
            dtCallAmount = PB.decode(d, Float64)
        elseif field_number == 29
            dtStatus = PB.decode(d, Int32)
        elseif field_number == 30
            securitiesAssets = PB.decode(d, Float64)
        elseif field_number == 31
            fundAssets = PB.decode(d, Float64)
        elseif field_number == 32
            bondAssets = PB.decode(d, Float64)
        elseif field_number == 33
            push!(marketInfoList, PB.decode(d, Ref{AccMarketInfo}))
        else
            PB.skip(d, wire_type)
        end
    end
    return Funds(power = power, totalAssets = totalAssets, cash = cash, marketVal = marketVal, frozenCash = frozenCash, debtCash = debtCash, avlWithdrawalCash = avlWithdrawalCash, currency = currency, availableFunds = availableFunds, unrealizedPL = unrealizedPL, realizedPL = realizedPL, riskLevel = riskLevel, initialMargin = initialMargin, maintenanceMargin = maintenanceMargin, cashInfoList = cashInfoList, maxPowerShort = maxPowerShort, netCashPower = netCashPower, longMv = longMv, shortMv = shortMv, pendingAsset = pendingAsset, maxWithdrawal = maxWithdrawal, riskStatus = riskStatus, marginCallMargin = marginCallMargin, isPdt = isPdt, pdtSeq = pdtSeq, beginningDTBP = beginningDTBP, remainingDTBP = remainingDTBP, dtCallAmount = dtCallAmount, dtStatus = dtStatus, securitiesAssets = securitiesAssets, fundAssets = fundAssets, bondAssets = bondAssets, marketInfoList = marketInfoList)
end

"""
    Position

账户持仓结构 (Account position structure)

Fields:
- positionID::UInt64: 持仓ID，一条持仓的唯一标识 / Position ID, unique identifier
- positionSide::Int32: 持仓方向，参见PositionSide的枚举定义 / Position side, refer to PositionSide enum
- code::String: 代码 / Code
- name::String: 名称 / Name
- qty::Float64: 持有数量，2位精度，期权单位是"张" / Quantity held, 2 decimal places, options in contracts
- canSellQty::Float64: 可卖数量 / Quantity available for selling
- price::Float64: 市价，3位精度，期货为2位精度 / Market price, 3 decimal places (2 for futures)
- costPrice::Float64: 成本价，无精度限制，期货为2位精度（已废弃，请使用 dilutedCostPrice 或 averageCostPrice） / Cost price (deprecated, use dilutedCostPrice or averageCostPrice)
- val::Float64: 市值，3位精度, 期货此字段值为0 / Market value, 3 decimal places (0 for futures)
- plVal::Float64: 盈亏金额，3位精度，期货为2位精度 / P/L amount, 3 decimal places (2 for futures)
- plRatio::Float64: 摊薄成本价的盈亏百分比 / P/L ratio based on diluted cost
- secMarket::Int32: 证券所属市场，参见TrdSecMarket的枚举定义 / Security market, refer to TrdSecMarket enum
- td_plVal::Float64: 今日盈亏金额，3位精度, 期货为2位精度 / Today's P/L, 3 decimal places (2 for futures)
- td_trdVal::Float64: 今日交易额，期货不适用 / Today's trade value, not for futures
- td_buyVal::Float64: 今日买入总额，期货不适用 / Today's buy value, not for futures
- td_buyQty::Float64: 今日买入总量，期货不适用 / Today's buy quantity, not for futures
- td_sellVal::Float64: 今日卖出总额，期货不适用 / Today's sell value, not for futures
- td_sellQty::Float64: 今日卖出总量，期货不适用 / Today's sell quantity, not for futures
- unrealizedPL::Float64: 未实现盈亏，期货适用 / Unrealized P/L, for futures
- realizedPL::Float64: 已实现盈亏，期货适用 / Realized P/L, for futures
- currency::Int32: 货币类型，取值参考 Currency / Currency type, refer to Currency enum
- trdMarket::Int32: 交易市场, 参见TrdMarket的枚举定义 / Trading market, refer to TrdMarket enum
- dilutedCostPrice::Float64: 摊薄成本价，仅支持证券账户使用 / Diluted cost price, only for securities accounts
- averageCostPrice::Float64: 平均成本价，模拟交易证券账户不适用 / Average cost price, not for paper trading securities accounts
- averagePlRatio::Float64: 平均成本价的盈亏百分比 / P/L ratio based on average cost
"""
mutable struct Position
    positionID::UInt64          # 持仓ID
    positionSide::Int32         # 持仓方向
    code::String                # 代码
    name::String                # 名称
    qty::Float64                # 持有数量
    canSellQty::Float64         # 可卖数量
    price::Float64              # 市价
    costPrice::Float64          # 成本价（已废弃）
    val::Float64                # 市值
    plVal::Float64              # 盈亏金额
    plRatio::Float64            # 盈亏百分比
    secMarket::Int32            # 证券所属市场
    td_plVal::Float64           # 今日盈亏金额
    td_trdVal::Float64          # 今日交易额
    td_buyVal::Float64          # 今日买入总额
    td_buyQty::Float64          # 今日买入总量
    td_sellVal::Float64         # 今日卖出总额
    td_sellQty::Float64         # 今日卖出总量
    unrealizedPL::Float64       # 未实现盈亏（期货）
    realizedPL::Float64         # 已实现盈亏（期货）
    currency::Int32             # 货币类型
    trdMarket::Int32            # 交易市场
    dilutedCostPrice::Float64   # 摊薄成本价
    averageCostPrice::Float64   # 平均成本价
    averagePlRatio::Float64     # 平均成本价的盈亏百分比
    Position(; positionID = 0, positionSide = 0, code = "", name = "", qty = 0.0, canSellQty = 0.0, price = 0.0, costPrice = 0.0,
        val = 0.0, plVal = 0.0, plRatio = 0.0, secMarket = 0, td_plVal = 0.0, td_trdVal = 0.0, td_buyVal = 0.0, td_buyQty = 0.0,
        td_sellVal = 0.0, td_sellQty = 0.0, unrealizedPL = 0.0, realizedPL = 0.0, currency = 0, trdMarket = 0,
        dilutedCostPrice = 0.0, averageCostPrice = 0.0, averagePlRatio = 0.0) =
        new(UInt64(positionID), Int32(positionSide), String(code), String(name), Float64(qty), Float64(canSellQty), Float64(price),
            Float64(costPrice), Float64(val), Float64(plVal), Float64(plRatio), Int32(secMarket), Float64(td_plVal), Float64(td_trdVal),
            Float64(td_buyVal), Float64(td_buyQty), Float64(td_sellVal), Float64(td_sellQty), Float64(unrealizedPL), Float64(realizedPL),
            Int32(currency), Int32(trdMarket), Float64(dilutedCostPrice), Float64(averageCostPrice), Float64(averagePlRatio))
end

PB.default_values(::Type{Position}) = (;positionID = UInt64(0), positionSide = Int32(0), code = "", name = "", qty = 0.0, canSellQty = 0.0, price = 0.0, costPrice = 0.0, val = 0.0, plVal = 0.0, plRatio = 0.0, secMarket = Int32(0), td_plVal = 0.0, td_trdVal = 0.0, td_buyVal = 0.0, td_buyQty = 0.0, td_sellVal = 0.0, td_sellQty = 0.0, unrealizedPL = 0.0, realizedPL = 0.0, currency = Int32(0), trdMarket = Int32(0), dilutedCostPrice = 0.0, averageCostPrice = 0.0, averagePlRatio = 0.0)
PB.field_numbers(::Type{Position}) = (;positionID = 1, positionSide = 2, code = 3, name = 4, qty = 5, canSellQty = 6, price = 7, costPrice = 8, val = 9, plVal = 10, plRatio = 11, secMarket = 12, td_plVal = 13, td_trdVal = 14, td_buyVal = 15, td_buyQty = 16, td_sellVal = 17, td_sellQty = 18, unrealizedPL = 19, realizedPL = 20, currency = 21, trdMarket = 22, dilutedCostPrice = 23, averageCostPrice = 24, averagePlRatio = 25)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:Position})
    positionID = UInt64(0)
    positionSide = Int32(0)
    code = ""
    name = ""
    qty = 0.0
    canSellQty = 0.0
    price = 0.0
    costPrice = 0.0
    val = 0.0
    plVal = 0.0
    plRatio = 0.0
    secMarket = Int32(0)
    td_plVal = 0.0
    td_trdVal = 0.0
    td_buyVal = 0.0
    td_buyQty = 0.0
    td_sellVal = 0.0
    td_sellQty = 0.0
    unrealizedPL = 0.0
    realizedPL = 0.0
    currency = Int32(0)
    trdMarket = Int32(0)
    dilutedCostPrice = 0.0
    averageCostPrice = 0.0
    averagePlRatio = 0.0
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            positionID = PB.decode(d, UInt64)
        elseif field_number == 2
            positionSide = PB.decode(d, Int32)
        elseif field_number == 3
            code = PB.decode(d, String)
        elseif field_number == 4
            name = PB.decode(d, String)
        elseif field_number == 5
            qty = PB.decode(d, Float64)
        elseif field_number == 6
            canSellQty = PB.decode(d, Float64)
        elseif field_number == 7
            price = PB.decode(d, Float64)
        elseif field_number == 8
            costPrice = PB.decode(d, Float64)
        elseif field_number == 9
            val = PB.decode(d, Float64)
        elseif field_number == 10
            plVal = PB.decode(d, Float64)
        elseif field_number == 11
            plRatio = PB.decode(d, Float64)
        elseif field_number == 12
            secMarket = PB.decode(d, Int32)
        elseif field_number == 13
            td_plVal = PB.decode(d, Float64)
        elseif field_number == 14
            td_trdVal = PB.decode(d, Float64)
        elseif field_number == 15
            td_buyVal = PB.decode(d, Float64)
        elseif field_number == 16
            td_buyQty = PB.decode(d, Float64)
        elseif field_number == 17
            td_sellVal = PB.decode(d, Float64)
        elseif field_number == 18
            td_sellQty = PB.decode(d, Float64)
        elseif field_number == 19
            unrealizedPL = PB.decode(d, Float64)
        elseif field_number == 20
            realizedPL = PB.decode(d, Float64)
        elseif field_number == 21
            currency = PB.decode(d, Int32)
        elseif field_number == 22
            trdMarket = PB.decode(d, Int32)
        elseif field_number == 23
            dilutedCostPrice = PB.decode(d, Float64)
        elseif field_number == 24
            averageCostPrice = PB.decode(d, Float64)
        elseif field_number == 25
            averagePlRatio = PB.decode(d, Float64)
        else
            PB.skip(d, wire_type)
        end
    end
    return Position(positionID = positionID, positionSide = positionSide, code = code, name = name, qty = qty, canSellQty = canSellQty,
        price = price, costPrice = costPrice, val = val, plVal = plVal, plRatio = plRatio, secMarket = secMarket, td_plVal = td_plVal,
        td_trdVal = td_trdVal, td_buyVal = td_buyVal, td_buyQty = td_buyQty, td_sellVal = td_sellVal, td_sellQty = td_sellQty,
        unrealizedPL = unrealizedPL, realizedPL = realizedPL, currency = currency, trdMarket = trdMarket, dilutedCostPrice = dilutedCostPrice,
        averageCostPrice = averageCostPrice, averagePlRatio = averagePlRatio)
end

"""
    Order

订单结构 (Order structure)

Fields:
- trdSide::Int32: 交易方向, 参见TrdSide的枚举定义 / Trading side, refer to TrdSide enum
- orderType::Int32: 订单类型, 参见OrderType的枚举定义 / Order type, refer to OrderType enum
- orderStatus::Int32: 订单状态, 参见OrderStatus的枚举定义 / Order status, refer to OrderStatus enum
- orderID::UInt64: 订单号 / Order ID
- orderIDEx::String: 扩展订单号(仅查问题时备用) / Extended order ID (for troubleshooting only)
- code::String: 代码 / Code
- name::String: 名称 / Name
- qty::Float64: 订单数量，2位精度，期权单位是"张" / Order quantity, 2 decimal places, options in contracts
- price::Float64: 订单价格，3位精度 / Order price, 3 decimal places
- createTime::String: 创建时间，格式YYYY-MM-DD HH:MM:SS / Creation time, format YYYY-MM-DD HH:MM:SS
- updateTime::String: 最后更新时间，格式YYYY-MM-DD HH:MM:SS / Last update time, format YYYY-MM-DD HH:MM:SS
- fillQty::Float64: 成交数量，2位精度 / Filled quantity, 2 decimal places
- fillAvgPrice::Float64: 成交均价，无精度限制 / Average fill price
- lastErrMsg::String: 最后的错误描述 / Last error message
- secMarket::Int32: 证券所属市场，参见TrdSecMarket的枚举定义 / Security market, refer to TrdSecMarket enum
- createTimestamp::Float64: 创建时间戳 / Creation timestamp
- updateTimestamp::Float64: 最后更新时间戳 / Last update timestamp
- remark::String: 用户备注字符串，最大长度64字节 / User remark, max 64 bytes
- timeInForce::Int32: 订单期限，参考TimeInForce / Time in force, refer to TimeInForce enum
- fillOutsideRTH::Bool: 是否允许美股订单盘前盘后成交 / Whether allows pre/post-market fill for US stocks
- auxPrice::Float64: 触发价格 / Trigger price
- trailType::Int32: 跟踪类型, 参见TrailType的枚举定义 / Trail type, refer to TrailType enum
- trailValue::Float64: 跟踪金额/百分比 / Trail amount/percentage
- trailSpread::Float64: 指定价差 / Specified spread
- currency::Int32: 货币类型，取值参考Currency / Currency type, refer to Currency enum
- trdMarket::Int32: 交易市场, 参见TrdMarket的枚举定义 / Trading market, refer to TrdMarket enum
- session::Int32: 美股订单时段, 参见Common.Session的枚举定义 / US stock session, refer to Common.Session enum
"""
mutable struct Order
    trdSide::Int32              # 交易方向
    orderType::Int32            # 订单类型
    orderStatus::Int32          # 订单状态
    orderID::UInt64             # 订单号
    orderIDEx::String           # 扩展订单号
    code::String                # 代码
    name::String                # 名称
    qty::Float64                # 订单数量
    price::Float64              # 订单价格
    createTime::String          # 创建时间
    updateTime::String          # 最后更新时间
    fillQty::Float64            # 成交数量
    fillAvgPrice::Float64       # 成交均价
    lastErrMsg::String          # 最后的错误描述
    secMarket::Int32            # 证券所属市场
    createTimestamp::Float64    # 创建时间戳
    updateTimestamp::Float64    # 最后更新时间戳
    remark::String              # 用户备注字符串
    timeInForce::Int32          # 订单期限
    fillOutsideRTH::Bool        # 是否允许美股订单盘前盘后成交
    auxPrice::Float64           # 触发价格
    trailType::Int32            # 跟踪类型
    trailValue::Float64         # 跟踪金额/百分比
    trailSpread::Float64        # 指定价差
    currency::Int32             # 货币类型
    trdMarket::Int32            # 交易市场
    session::Int32              # 美股订单时段
    Order(; trdSide = 0, orderType = 0, orderStatus = 0, orderID = 0, orderIDEx = "", code = "", name = "", qty = 0.0, price = 0.0,
        createTime = "", updateTime = "", fillQty = 0.0, fillAvgPrice = 0.0, lastErrMsg = "", secMarket = 0, createTimestamp = 0.0,
        updateTimestamp = 0.0, remark = "", timeInForce = 0, fillOutsideRTH = false, auxPrice = 0.0, trailType = 0, trailValue = 0.0,
        trailSpread = 0.0, currency = 0, trdMarket = 0, session = 0) =
        new(Int32(trdSide), Int32(orderType), Int32(orderStatus), UInt64(orderID), String(orderIDEx), String(code), String(name),
            Float64(qty), Float64(price), String(createTime), String(updateTime), Float64(fillQty), Float64(fillAvgPrice), String(lastErrMsg),
            Int32(secMarket), Float64(createTimestamp), Float64(updateTimestamp), String(remark), Int32(timeInForce), Bool(fillOutsideRTH),
            Float64(auxPrice), Int32(trailType), Float64(trailValue), Float64(trailSpread), Int32(currency), Int32(trdMarket), Int32(session))
end

PB.default_values(::Type{Order}) = (;trdSide = Int32(0), orderType = Int32(0), orderStatus = Int32(0), orderID = UInt64(0), orderIDEx = "", code = "", name = "", qty = 0.0, price = 0.0, createTime = "", updateTime = "", fillQty = 0.0, fillAvgPrice = 0.0, lastErrMsg = "", secMarket = Int32(0), createTimestamp = 0.0, updateTimestamp = 0.0, remark = "", timeInForce = Int32(0), fillOutsideRTH = false, auxPrice = 0.0, trailType = Int32(0), trailValue = 0.0, trailSpread = 0.0, currency = Int32(0), trdMarket = Int32(0), session = Int32(0))
PB.field_numbers(::Type{Order}) = (;trdSide = 1, orderType = 2, orderStatus = 3, orderID = 4, orderIDEx = 5, code = 6, name = 7, qty = 8, price = 9, createTime = 10, updateTime = 11, fillQty = 12, fillAvgPrice = 13, lastErrMsg = 14, secMarket = 15, createTimestamp = 16, updateTimestamp = 17, remark = 18, timeInForce = 19, fillOutsideRTH = 20, auxPrice = 21, trailType = 22, trailValue = 23, trailSpread = 24, currency = 25, trdMarket = 26, session = 27)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:Order})
    trdSide = Int32(0)
    orderType = Int32(0)
    orderStatus = Int32(0)
    orderID = UInt64(0)
    orderIDEx = ""
    code = ""
    name = ""
    qty = 0.0
    price = 0.0
    createTime = ""
    updateTime = ""
    fillQty = 0.0
    fillAvgPrice = 0.0
    lastErrMsg = ""
    secMarket = Int32(0)
    createTimestamp = 0.0
    updateTimestamp = 0.0
    remark = ""
    timeInForce = Int32(0)
    fillOutsideRTH = false
    auxPrice = 0.0
    trailType = Int32(0)
    trailValue = 0.0
    trailSpread = 0.0
    currency = Int32(0)
    trdMarket = Int32(0)
    session = Int32(0)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            trdSide = PB.decode(d, Int32)
        elseif field_number == 2
            orderType = PB.decode(d, Int32)
        elseif field_number == 3
            orderStatus = PB.decode(d, Int32)
        elseif field_number == 4
            orderID = PB.decode(d, UInt64)
        elseif field_number == 5
            orderIDEx = PB.decode(d, String)
        elseif field_number == 6
            code = PB.decode(d, String)
        elseif field_number == 7
            name = PB.decode(d, String)
        elseif field_number == 8
            qty = PB.decode(d, Float64)
        elseif field_number == 9
            price = PB.decode(d, Float64)
        elseif field_number == 10
            createTime = PB.decode(d, String)
        elseif field_number == 11
            updateTime = PB.decode(d, String)
        elseif field_number == 12
            fillQty = PB.decode(d, Float64)
        elseif field_number == 13
            fillAvgPrice = PB.decode(d, Float64)
        elseif field_number == 14
            lastErrMsg = PB.decode(d, String)
        elseif field_number == 15
            secMarket = PB.decode(d, Int32)
        elseif field_number == 16
            createTimestamp = PB.decode(d, Float64)
        elseif field_number == 17
            updateTimestamp = PB.decode(d, Float64)
        elseif field_number == 18
            remark = PB.decode(d, String)
        elseif field_number == 19
            timeInForce = PB.decode(d, Int32)
        elseif field_number == 20
            fillOutsideRTH = PB.decode(d, Bool)
        elseif field_number == 21
            auxPrice = PB.decode(d, Float64)
        elseif field_number == 22
            trailType = PB.decode(d, Int32)
        elseif field_number == 23
            trailValue = PB.decode(d, Float64)
        elseif field_number == 24
            trailSpread = PB.decode(d, Float64)
        elseif field_number == 25
            currency = PB.decode(d, Int32)
        elseif field_number == 26
            trdMarket = PB.decode(d, Int32)
        elseif field_number == 27
            session = PB.decode(d, Int32)
        else
            PB.skip(d, wire_type)
        end
    end
    return Order(trdSide = trdSide, orderType = orderType, orderStatus = orderStatus, orderID = orderID, orderIDEx = orderIDEx,
        code = code, name = name, qty = qty, price = price, createTime = createTime, updateTime = updateTime, fillQty = fillQty,
        fillAvgPrice = fillAvgPrice, lastErrMsg = lastErrMsg, secMarket = secMarket, createTimestamp = createTimestamp,
        updateTimestamp = updateTimestamp, remark = remark, timeInForce = timeInForce, fillOutsideRTH = fillOutsideRTH,
        auxPrice = auxPrice, trailType = trailType, trailValue = trailValue, trailSpread = trailSpread, currency = currency,
        trdMarket = trdMarket, session = session)
end

"""
    OrderFeeItem

订单费用明细 (Order fee item)

Fields:
- title::String: 费用名字 / Fee name
- value::Float64: 费用金额 / Fee amount
"""
mutable struct OrderFeeItem
    title::String  # 费用名字
    value::Float64 # 费用金额
    OrderFeeItem(; title = "", value = 0.0) = new(String(title), Float64(value))
end

PB.default_values(::Type{OrderFeeItem}) = (;title = "", value = 0.0)
PB.field_numbers(::Type{OrderFeeItem}) = (;title = 1, value = 2)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:OrderFeeItem})
    title = ""
    value = 0.0
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            title = PB.decode(d, String)
        elseif field_number == 2
            value = PB.decode(d, Float64)
        else
            PB.skip(d, wire_type)
        end
    end
    return OrderFeeItem(title = title, value = value)
end

"""
    OrderFee

订单费用 (Order fee)

Fields:
- orderIDEx::String: 扩展订单号 / Extended order ID
- feeAmount::Float64: 费用总额 / Total fee amount
- feeList::Vector{OrderFeeItem}: 费用明细 / Fee details
"""
mutable struct OrderFee
    orderIDEx::String                # 扩展订单号
    feeAmount::Float64               # 费用总额
    feeList::Vector{OrderFeeItem}    # 费用明细
    OrderFee(; orderIDEx = "", feeAmount = 0, feeList = Vector{OrderFeeItem}()) = new(orderIDEx, feeAmount, feeList)
end

PB.default_values(::Type{OrderFee}) = (;orderIDEx = "", feeAmount = 0.0, feeList = Vector{OrderFeeItem}())
PB.field_numbers(::Type{OrderFee}) = (;orderIDEx = 1, feeAmount = 2, feeList = 3)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:OrderFee})
    orderIDEx = ""
    feeAmount = 0.0
    feeList = Vector{OrderFeeItem}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            orderIDEx = PB.decode(d, String)
        elseif field_number == 2
            feeAmount = PB.decode(d, Float64)
        elseif field_number == 3
            push!(feeList, PB.decode(d, Ref{OrderFeeItem}))
        else
            PB.skip(d, wire_type)
        end
    end
    return OrderFee(orderIDEx = orderIDEx, feeAmount = feeAmount, feeList = feeList)
end

"""
    OrderFill

成交结构 (Fill structure)

Fields:
- trdSide::Int32: 交易方向, 参见TrdSide的枚举定义 / Trading side, refer to TrdSide enum
- fillID::UInt64: 成交号 / Fill ID
- fillIDEx::String: 扩展成交号(仅查问题时备用) / Extended fill ID (for troubleshooting only)
- orderID::UInt64: 订单号 / Order ID
- orderIDEx::String: 扩展订单号(仅查问题时备用) / Extended order ID (for troubleshooting only)
- code::String: 代码 / Code
- name::String: 名称 / Name
- qty::Float64: 成交数量，2位精度，期权单位是"张" / Fill quantity, 2 decimal places, options in contracts
- price::Float64: 成交价格，3位精度 / Fill price, 3 decimal places
- createTime::String: 创建时间（成交时间），格式YYYY-MM-DD HH:MM:SS / Creation time (fill time), format YYYY-MM-DD HH:MM:SS
- counterBrokerID::Int32: 对手经纪号，港股有效 / Counter broker ID, valid for HK stocks
- counterBrokerName::String: 对手经纪名称，港股有效 / Counter broker name, valid for HK stocks
- secMarket::Int32: 证券所属市场，参见TrdSecMarket的枚举定义 / Security market, refer to TrdSecMarket enum
- createTimestamp::Float64: 创建时间戳 / Creation timestamp
- updateTimestamp::Float64: 最后更新时间戳 / Last update timestamp
- status::Int32: 成交状态, 参见OrderFillStatus的枚举定义 / Fill status, refer to OrderFillStatus enum
- trdMarket::Int32: 交易市场, 参见TrdMarket的枚举定义 / Trading market, refer to TrdMarket enum
"""
mutable struct OrderFill
    trdSide::Int32                # 交易方向
    fillID::UInt64                # 成交号
    fillIDEx::String              # 扩展成交号
    orderID::UInt64               # 订单号
    orderIDEx::String             # 扩展订单号
    code::String                  # 代码
    name::String                  # 名称
    qty::Float64                  # 成交数量
    price::Float64                # 成交价格
    createTime::String            # 创建时间（成交时间）
    counterBrokerID::Int32        # 对手经纪号
    counterBrokerName::String     # 对手经纪名称
    secMarket::Int32              # 证券所属市场
    createTimestamp::Float64      # 创建时间戳
    updateTimestamp::Float64      # 最后更新时间戳
    status::Int32                 # 成交状态
    trdMarket::Int32              # 交易市场
    OrderFill(; trdSide = 0, fillID = 0, fillIDEx = "", orderID = 0, orderIDEx = "", code = "", name = "", qty = 0.0, price = 0.0,
        createTime = "", counterBrokerID = 0, counterBrokerName = "", secMarket = 0, createTimestamp = 0.0, updateTimestamp = 0.0,
        status = 0, trdMarket = 0) =
        new(Int32(trdSide), UInt64(fillID), String(fillIDEx), UInt64(orderID), String(orderIDEx), String(code), String(name),
            Float64(qty), Float64(price), String(createTime), Int32(counterBrokerID), String(counterBrokerName), Int32(secMarket),
            Float64(createTimestamp), Float64(updateTimestamp), Int32(status), Int32(trdMarket))
end

PB.default_values(::Type{OrderFill}) = (;trdSide = Int32(0), fillID = UInt64(0), fillIDEx = "", orderID = UInt64(0), orderIDEx = "", code = "", name = "", qty = 0.0, price = 0.0, createTime = "", counterBrokerID = Int32(0), counterBrokerName = "", secMarket = Int32(0), createTimestamp = 0.0, updateTimestamp = 0.0, status = Int32(0), trdMarket = Int32(0))
PB.field_numbers(::Type{OrderFill}) = (;trdSide = 1, fillID = 2, fillIDEx = 3, orderID = 4, orderIDEx = 5, code = 6, name = 7, qty = 8, price = 9, createTime = 10, counterBrokerID = 11, counterBrokerName = 12, secMarket = 13, createTimestamp = 14, updateTimestamp = 15, status = 16, trdMarket = 17)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:OrderFill})
    trdSide = Int32(0)
    fillID = UInt64(0)
    fillIDEx = ""
    orderID = UInt64(0)
    orderIDEx = ""
    code = ""
    name = ""
    qty = 0.0
    price = 0.0
    createTime = ""
    counterBrokerID = Int32(0)
    counterBrokerName = ""
    secMarket = Int32(0)
    createTimestamp = 0.0
    updateTimestamp = 0.0
    status = Int32(0)
    trdMarket = Int32(0)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            trdSide = PB.decode(d, Int32)
        elseif field_number == 2
            fillID = PB.decode(d, UInt64)
        elseif field_number == 3
            fillIDEx = PB.decode(d, String)
        elseif field_number == 4
            orderID = PB.decode(d, UInt64)
        elseif field_number == 5
            orderIDEx = PB.decode(d, String)
        elseif field_number == 6
            code = PB.decode(d, String)
        elseif field_number == 7
            name = PB.decode(d, String)
        elseif field_number == 8
            qty = PB.decode(d, Float64)
        elseif field_number == 9
            price = PB.decode(d, Float64)
        elseif field_number == 10
            createTime = PB.decode(d, String)
        elseif field_number == 11
            counterBrokerID = PB.decode(d, Int32)
        elseif field_number == 12
            counterBrokerName = PB.decode(d, String)
        elseif field_number == 13
            secMarket = PB.decode(d, Int32)
        elseif field_number == 14
            createTimestamp = PB.decode(d, Float64)
        elseif field_number == 15
            updateTimestamp = PB.decode(d, Float64)
        elseif field_number == 16
            status = PB.decode(d, Int32)
        elseif field_number == 17
            trdMarket = PB.decode(d, Int32)
        else
            PB.skip(d, wire_type)
        end
    end
    return OrderFill(trdSide = trdSide, fillID = fillID, fillIDEx = fillIDEx, orderID = orderID, orderIDEx = orderIDEx,
        code = code, name = name, qty = qty, price = price, createTime = createTime, counterBrokerID = counterBrokerID,
        counterBrokerName = counterBrokerName, secMarket = secMarket, createTimestamp = createTimestamp,
        updateTimestamp = updateTimestamp, status = status, trdMarket = trdMarket)
end

"""
    MaxTrdQtys

最大可交易数量 (Maximum tradeable quantities)

因目前服务器实现的问题，卖空需要先卖掉持仓才能再卖空，是分开两步卖的，买回来同样是逆向两步；而看多的买是可以现金加融资一起一步买的，请注意这个差异
(Due to current server implementation, short selling requires selling positions first, then short selling again (two steps), buying back is also reverse two steps; while buying long can use cash plus margin in one step, please note this difference)

Fields:
- maxCashBuy::Float64: 不使用融资，仅自己的现金最大可买整手股数，期货此字段值为0 / Maximum buyable lots with cash only (no margin), 0 for futures
- maxCashAndMarginBuy::Float64: 使用融资，自己的现金 + 融资资金总共的最大可买整手股数，期货不适用 / Maximum buyable lots with cash + margin, not for futures
- maxPositionSell::Float64: 不使用融券(卖空)，仅自己的持仓最大可卖整手股数 / Maximum sellable lots from positions only (no short selling)
- maxSellShort::Float64: 使用融券(卖空)，最大可卖空整手股数，不包括多仓，期货不适用 / Maximum short sellable lots, not including long positions, not for futures
- maxBuyBack::Float64: 卖空后，需要买回的最大整手股数，期货不适用 / Maximum buyback lots after short selling, not for futures
- longRequiredIM::Float64: 开多仓每张合约初始保证金，当前仅期货和期权适用（最低 FutuOpenD 版本要求：5.0.1310） / Initial margin per contract for long position, currently only for futures and options (min FutuOpenD version: 5.0.1310)
- shortRequiredIM::Float64: 开空仓每张合约初始保证金，当前仅期货和期权适用（最低 FutuOpenD 版本要求：5.0.1310） / Initial margin per contract for short position, currently only for futures and options (min FutuOpenD version: 5.0.1310)
- session::Int32: 美股订单时段, 参见Common.Session的枚举定义（最低 FutuOpenD 版本要求：9.4.5408） / US stock session, refer to Common.Session enum (min FutuOpenD version: 9.4.5408)
"""
mutable struct MaxTrdQtys
    maxCashBuy::Float64             # 不使用融资，仅现金最大可买整手股数
    maxCashAndMarginBuy::Float64    # 使用融资，最大可买整手股数
    maxPositionSell::Float64        # 不使用融券，仅持仓最大可卖整手股数
    maxSellShort::Float64           # 使用融券，最大可卖空整手股数
    maxBuyBack::Float64             # 卖空后，需要买回的最大整手股数
    longRequiredIM::Float64         # 开多仓每张合约初始保证金
    shortRequiredIM::Float64        # 开空仓每张合约初始保证金
    session::Int32                  # 美股订单时段
    MaxTrdQtys(; maxCashBuy = 0.0, maxCashAndMarginBuy = 0.0, maxPositionSell = 0.0, maxSellShort = 0.0, maxBuyBack = 0.0,
        longRequiredIM = 0.0, shortRequiredIM = 0.0, session = 0) =
        new(Float64(maxCashBuy), Float64(maxCashAndMarginBuy), Float64(maxPositionSell), Float64(maxSellShort),
            Float64(maxBuyBack), Float64(longRequiredIM), Float64(shortRequiredIM), Int32(session))
end

PB.default_values(::Type{MaxTrdQtys}) = (;maxCashBuy = 0.0, maxCashAndMarginBuy = 0.0, maxPositionSell = 0.0, maxSellShort = 0.0, maxBuyBack = 0.0, longRequiredIM = 0.0, shortRequiredIM = 0.0, session = Int32(0))
PB.field_numbers(::Type{MaxTrdQtys}) = (;maxCashBuy = 1, maxCashAndMarginBuy = 2, maxPositionSell = 3, maxSellShort = 4, maxBuyBack = 5, longRequiredIM = 6, shortRequiredIM = 7, session = 8)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:MaxTrdQtys})
    maxCashBuy = 0.0
    maxCashAndMarginBuy = 0.0
    maxPositionSell = 0.0
    maxSellShort = 0.0
    maxBuyBack = 0.0
    longRequiredIM = 0.0
    shortRequiredIM = 0.0
    session = Int32(0)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            maxCashBuy = PB.decode(d, Float64)
        elseif field_number == 2
            maxCashAndMarginBuy = PB.decode(d, Float64)
        elseif field_number == 3
            maxPositionSell = PB.decode(d, Float64)
        elseif field_number == 4
            maxSellShort = PB.decode(d, Float64)
        elseif field_number == 5
            maxBuyBack = PB.decode(d, Float64)
        elseif field_number == 6
            longRequiredIM = PB.decode(d, Float64)
        elseif field_number == 7
            shortRequiredIM = PB.decode(d, Float64)
        elseif field_number == 8
            session = PB.decode(d, Int32)
        else
            PB.skip(d, wire_type)
        end
    end
    return MaxTrdQtys(maxCashBuy = maxCashBuy, maxCashAndMarginBuy = maxCashAndMarginBuy, maxPositionSell = maxPositionSell,
        maxSellShort = maxSellShort, maxBuyBack = maxBuyBack, longRequiredIM = longRequiredIM, shortRequiredIM = shortRequiredIM, session = session)
end

"""
    TrdFilterConditions

过滤条件，条件组合是"与"不是"或"，用于获取订单、成交、持仓等时二次过滤
(Filter conditions, conditions are combined with "AND" not "OR", used for secondary filtering when getting orders, fills, positions, etc.)

Fields:
- codeList::Vector{String}: 代码过滤，只返回包含这些代码的数据，没传不过滤 / Code filter, only returns data containing these codes, no filter if not provided
- idList::Vector{UInt64}: ID主键过滤，只返回包含这些ID的数据，没传不过滤，订单是orderID、成交是fillID、持仓是positionID / ID primary key filter, only returns data containing these IDs, no filter if not provided, orderID for orders, fillID for fills, positionID for positions
- beginTime::String: 开始时间，严格按YYYY-MM-DD HH:MM:SS或YYYY-MM-DD HH:MM:SS.MS格式传，对持仓无效，拉历史数据必须填 / Begin time, strictly format as YYYY-MM-DD HH:MM:SS or YYYY-MM-DD HH:MM:SS.MS, invalid for positions, required for historical data
- endTime::String: 结束时间，严格按YYYY-MM-DD HH:MM:SS或YYYY-MM-DD HH:MM:SS.MS格式传，对持仓无效，拉历史数据必须填 / End time, strictly format as YYYY-MM-DD HH:MM:SS or YYYY-MM-DD HH:MM:SS.MS, invalid for positions, required for historical data
- orderIDExList::Vector{String}: 服务器订单ID，可以用来替代orderID，二选一 / Server order ID, can be used to replace orderID, choose one of the two
- filterMarket::Int32: 指定交易市场, 参见TrdMarket的枚举定义 / Specified trading market, refer to TrdMarket enum
"""
mutable struct TrdFilterConditions
    codeList::Vector{String}      # 代码过滤
    idList::Vector{UInt64}         # ID主键过滤
    beginTime::String              # 开始时间
    endTime::String                # 结束时间
    orderIDExList::Vector{String}  # 服务器订单ID
    filterMarket::Int32            # 指定交易市场
    TrdFilterConditions(; codeList = Vector{String}(), idList = Vector{UInt64}(), beginTime = "", endTime = "", orderIDExList = Vector{String}(), filterMarket = 0) = new(codeList, idList, beginTime, endTime, orderIDExList, filterMarket)
end

PB.default_values(::Type{TrdFilterConditions}) = (;codeList = Vector{String}(), idList = Vector{UInt64}(), beginTime = "", endTime = "", orderIDExList = Vector{String}(), filterMarket = Int32(0))
PB.field_numbers(::Type{TrdFilterConditions}) = (;codeList = 1, idList = 2, beginTime = 3, endTime = 4, orderIDExList = 5, filterMarket = 6)

function PB.encode(e::PB.AbstractProtoEncoder, x::TrdFilterConditions)
    initpos = position(e.io)
    !isempty(x.codeList) && foreach(v -> PB.encode(e, 1, v), x.codeList)
    !isempty(x.idList) && foreach(v -> PB.encode(e, 2, v), x.idList)
    x.beginTime != "" && PB.encode(e, 3, x.beginTime)
    x.endTime != "" && PB.encode(e, 4, x.endTime)
    !isempty(x.orderIDExList) && foreach(v -> PB.encode(e, 5, v), x.orderIDExList)
    x.filterMarket != Int32(0) && PB.encode(e, 6, x.filterMarket)
    return position(e.io) - initpos
end

export TrdEnv, TrdCategory, TrdMarket, TrdSecMarket, TrdSide, OrderType, TrailType, OrderStatus, OrderFillStatus, PositionSide, ModifyOrderOp, TrdAccType, TrdAccStatus, Currency, CltRiskLevel, TimeInForce, SecurityFirm, SimAccType, CltRiskStatus, DTStatus, AccCashInfo, AccMarketInfo, TrdHeader, TrdAcc, Funds, Position, Order, OrderFeeItem, OrderFee, OrderFill, MaxTrdQtys, TrdFilterConditions

end
