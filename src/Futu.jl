module Futu

# Core dependencies
using Sockets
using ProtoBuf
using SHA
using Dates
using DataFrames
using JSON3

# Include submodules in correct order
include("core/errors.jl")
include("utils/encryption.jl")
include("protocol/AllProtos.jl")
include("utils/display.jl")
include("utils/constants.jl")
include("core/connection.jl")
include("core/push_callbacks.jl")
include("core/client.jl")
include("quote/quote.jl")
include("quote/quote_extended.jl")
include("quote/filter.jl")
include("quote/customization.jl")
include("trade/trade.jl")

# Use submodules
using .Errors
using .AllProtos
using .Connection
using .Client
using .Quote
using .QuoteExtended
using .Filter
using .Customization
using .Trade
using .Constants
using .PushCallbacks
using .Display

# Re-export main types and functions from submodules
export
    # Types
    OpenDClient, TradeClient,
    FutuError, ConnectionError, ProtocolError, APIError,

    # Connection
    connect!, disconnect!, is_connected,

    # Authentication
    get_global_state, get_delay_statistics, get_user_info,

    # Quote - Basic
    subscribe, unsubscribe, get_sub_info, update_quote,

    get_market_snapshot, get_basic_quote, get_market_state, get_capital_flow, get_capital_distribution,
    get_owner_plate, get_history_kline, get_rehab, get_history_kl_quota, get_kline, get_rt, get_ticker, get_order_book, get_broker_queue,

    # Quote - Extended
    get_option_expiration_date, get_option_chain, get_warrant, get_reference, get_future_info,

    get_plate_security, get_plate_set, get_static_info, get_ipo_list, get_trade_date,

    # Filter
    stock_filter, base_filter, accumulate_filter, financial_filter, pattern_filter, custom_indicator_filter,

    # Customization
    set_price_reminder, get_price_reminder, delete_price_reminder, delete_all_price_reminders,
    enable_price_reminder, disable_price_reminder, modify_price_reminder, update_price_reminder,
    get_user_security, get_user_security_group, modify_user_security,
    
    # Trade
    # 账户
    unlock_trade, lock_trade, get_account_list, 
    
    # 资产持仓
    get_funds, get_max_trd_qtys, get_position_list, get_margin_ratio, get_account_cash_flow,
    
    # 订单
    place_order, modify_order, get_order_list, get_history_order_list, get_order_fill_list, get_history_order_fill_list,
    cancel_all_orders, get_order_fee, 
    
    # 订阅, 更新订单
    subscribe_trade_push, unsubscribe_trade_push, update_order, update_order_fill,
    
    MARKET_LABELS, MARKET_FIELD_ORDER, QOT_MARKET_STATE,
    # constants 模块
    PROTO_RESPONSE_MAP, UserInfoField,
    # quote模块用的常量
    QotMarket, SubType, KLType, RehabType, PeriodType, TradeDateType, WarrantType,
    # quote_extended模块用的常量 
    ReferenceType,
    # trade模块常量
    TrdMarket, TrdType, TrdSide, TrdStatus
end # module
