module PushCallbacks

using Logging
using Dates
using ProtoBuf
import ProtoBuf as PB
using Crayons
using Printf

using ..AllProtos
using ..Connection: OpenDConnection, ResponsePacket

# ----------------------------------------------------------------------------
# 协议ID常量 (Protocol ID Constants)
# ----------------------------------------------------------------------------
using ..Constants: QOT_UPDATE_BASIC_QOT, QOT_UPDATE_ORDER_BOOK,
                   QOT_UPDATE_KL, QOT_UPDATE_RT, QOT_UPDATE_TICKER, QOT_UPDATE_BROKER,
                   QOT_UPDATE_PRICE_REMINDER, TRD_UPDATE_ORDER, TRD_UPDATE_ORDER_FILL

# ----------------------------------------------------------------------------
# 推送协议响应类型 (Push Protocol Response Types)
# ----------------------------------------------------------------------------
using ..Constants: Qot_UpdateBasicQot, Qot_UpdateKL, Qot_UpdateRT, Qot_UpdateTicker,
                   Qot_UpdateOrderBook, Qot_UpdateBroker, Qot_UpdatePriceReminder,
                   Trd_UpdateOrder, Trd_UpdateOrderFill

# ----------------------------------------------------------------------------
# 协议映射表 (Protocol Mapping)
# ----------------------------------------------------------------------------
using ..Constants: PROTO_PUSH_MAP

# ----------------------------------------------------------------------------
# 枚举类型 (Enum Types)
# ----------------------------------------------------------------------------
using ..Constants: QotMarket, TickerType

export
    CallbackManager,
    register_callback,
    unregister_callback,
    start_callback_handler,
    stop_callback_handler

# Callback manager
mutable struct CallbackManager
    callbacks::Dict{UInt32, Vector{Function}}
    connection::Union{OpenDConnection, Nothing}
    is_running::Bool
    handler_task::Union{Task, Nothing}

    function CallbackManager()
        new(Dict{UInt32, Vector{Function}}(), nothing, false, nothing)
    end
end

# Display styles for CallbackManager
const HEADER_STYLE = Crayon(foreground=:cyan, bold=true)
const LABEL_STYLE = Crayon(foreground=:white, bold=true)
const VALUE_STYLE = Crayon(foreground=:white)
const GOOD_STYLE = Crayon(foreground=:green, bold=true)
const BAD_STYLE = Crayon(foreground=:red, bold=true)
const DIM_STYLE = Crayon(foreground=:light_gray)
const HIGHLIGHT_STYLE = Crayon(foreground=:yellow)

# Protocol ID to name mapping
const PROTO_NAMES = Dict{UInt32, String}(
    QOT_UPDATE_BASIC_QOT => "Basic Quote",
    QOT_UPDATE_ORDER_BOOK => "Order Book",
    QOT_UPDATE_KL => "K-Line",
    QOT_UPDATE_RT => "Real-Time Data",
    QOT_UPDATE_TICKER => "Ticker",
    QOT_UPDATE_BROKER => "Broker Queue",
    QOT_UPDATE_PRICE_REMINDER => "Price Reminder",
    TRD_UPDATE_ORDER => "Order Update",
    TRD_UPDATE_ORDER_FILL => "Order Fill"
)

function get_protocol_name(proto_id::UInt32)
    return get(PROTO_NAMES, proto_id, "Unknown")
end

function Base.show(io::IO, manager::CallbackManager)
    # Header
    println(io, HEADER_STYLE("CallbackManager"))
    println(io, HEADER_STYLE("═══════════════"))
    println(io)

    # Handler status
    handler_status = manager.is_running ? GOOD_STYLE(" ✓ Running") : BAD_STYLE(" ✗ Stopped")
    println(io, LABEL_STYLE("  Handler Status: "), handler_status)

    # Connection status
    conn_status = manager.connection !== nothing ? GOOD_STYLE(" ✓ Connected") : DIM_STYLE(" ✗ No Connection")
    println(io, LABEL_STYLE("  Connection    : "), conn_status)

    # Task status
    if manager.handler_task !== nothing
        task_status = istaskdone(manager.handler_task) ? BAD_STYLE(" ✗ Done") :
                     istaskfailed(manager.handler_task) ? BAD_STYLE(" ✗ Failed") :
                     GOOD_STYLE(" ✓ Active")
        println(io, LABEL_STYLE("  Handler Task  : "), task_status)
    end

    println(io)

    # Callbacks statistics
    total_callbacks = sum(length(v) for v in values(manager.callbacks); init=0)
    protocol_count = length(manager.callbacks)

    println(io, LABEL_STYLE("  Registered Callbacks:"))

    if protocol_count > 0
        println(io, "    ", LABEL_STYLE("Total       : "),
                VALUE_STYLE(string(total_callbacks)),
                DIM_STYLE(" callback(s) on "),
                VALUE_STYLE(string(protocol_count)),
                DIM_STYLE(" protocol(s)"))
        println(io)

        # Show detailed callback information for each protocol
        println(io, "    ", LABEL_STYLE("Details:"))

        # Sort protocols by ID for consistent display
        proto_ids = sort(collect(keys(manager.callbacks)))

        for proto_id in proto_ids
            callbacks = manager.callbacks[proto_id]
            cb_count = length(callbacks)
            proto_name = get_protocol_name(proto_id)

            # Protocol ID (hex) = decimal
            proto_id_display = @sprintf("ProtoID: 0x%04X (%d)", proto_id, proto_id)

            # For single callback, show it directly
            if cb_count == 1
                callback_name = string(callbacks[1])
                println(io, "      ", DIM_STYLE(proto_id_display))
                println(io, "      ", VALUE_STYLE(@sprintf("%-20s", proto_name)),
                        DIM_STYLE(" → "), GOOD_STYLE(callback_name))
            else
                # Multiple callbacks - show count and list them
                println(io, "      ", DIM_STYLE(proto_id_display))
                println(io, "      ", VALUE_STYLE(@sprintf("%-20s", proto_name)),
                        DIM_STYLE(" → "), GOOD_STYLE(string(cb_count), " callbacks:"))

                # List each callback
                for (idx, callback) in enumerate(callbacks)
                    func_name = string(callback)
                    println(io, "        ", DIM_STYLE(@sprintf("[%d]", idx)), " ", GOOD_STYLE(func_name))
                end
            end
            println(io)  # Add spacing between protocols
        end
    else
        println(io, "    ", DIM_STYLE("None"))
    end
end

# Register a callback for a specific protocol ID
function register_callback(manager::CallbackManager, proto_id::UInt32, callback::Function)
    if !haskey(manager.callbacks, proto_id)
        manager.callbacks[proto_id] = Function[]
    end
    push!(manager.callbacks[proto_id], callback)
end

# Unregister a callback from all protocols where it's registered
function unregister_callback(manager::CallbackManager, callback::Function)
    protocols_to_delete = UInt32[]

    for (proto_id, callbacks) in manager.callbacks
        # Remove this callback from the protocol's callback list
        filter!(c -> c !== callback, callbacks)

        # Mark protocol for deletion if no callbacks remain
        if isempty(callbacks)
            push!(protocols_to_delete, proto_id)
        end
    end

    # Delete protocols with no remaining callbacks
    for proto_id in protocols_to_delete
        delete!(manager.callbacks, proto_id)
    end
end

function decode_push_data(proto_id::UInt32, data::Vector{UInt8})
    response_type = get(PROTO_PUSH_MAP, proto_id, nothing)
    if response_type === nothing
        error("Unknown push proto_id: $proto_id")
    end
    return PB.decode(ProtoDecoder(IOBuffer(data)), response_type)
end

# Process push message
function process_push_message(manager::CallbackManager, packet::ResponsePacket)
    callbacks = get(manager.callbacks, packet.proto_id, nothing)
    callbacks === nothing && return

    try
        decoded_data = decode_push_data(packet.proto_id, packet.data)
        parsed_data = parse_push_data(packet.proto_id, decoded_data)

        for callback in callbacks
            try
                Base.invokelatest(callback, parsed_data)
            catch e
                @error "Error in callback for protocol $(packet.proto_id)" exception=(e, catch_backtrace())
            end
        end
    catch e
        @error "Failed to process push message for protocol $(packet.proto_id)" exception=(e, catch_backtrace())
    end
end

# Parse push data based on protocol type
function parse_push_data(proto_id::UInt32, resp)
    if proto_id == QOT_UPDATE_BASIC_QOT
        return parse_basic_quote_push(resp)
    elseif proto_id == QOT_UPDATE_ORDER_BOOK
        return parse_order_book_push(resp)
    elseif proto_id == QOT_UPDATE_KL
        return parse_kline_push(resp)
    elseif proto_id == QOT_UPDATE_RT
        return parse_rt_data_push(resp)
    elseif proto_id == QOT_UPDATE_TICKER
        return parse_ticker_push(resp)
    elseif proto_id == QOT_UPDATE_BROKER
        return parse_broker_push(resp)
    elseif proto_id == QOT_UPDATE_PRICE_REMINDER
        return parse_price_reminder_push(resp)
    elseif proto_id == TRD_UPDATE_ORDER
        return parse_order_update_push(resp)
    elseif proto_id == TRD_UPDATE_ORDER_FILL
        return parse_deals_push(resp) # Alias for order fill
    else
        return resp # Should not happen if PROTO_PUSH_MAP is correct
    end
end

# Parse basic quote push data - optimized with NamedTuple instead of Dict
function parse_basic_quote_push(resp::Qot_UpdateBasicQot.Response)
    basicQotList = resp.s2c.basicQotList
    n = length(basicQotList)

    # Pre-allocate with known NamedTuple type
    results = Vector{@NamedTuple{
        code::String, market::Int32, name::String,
        last_price::Float64, prev_close::Float64, open_price::Float64,
        high_price::Float64, low_price::Float64, volume::Int64,
        turnover::Float64, turnover_rate::Float64, amplitude::Float64,
        update_time::String, update_timestamp::Float64, is_suspended::Bool,
        list_time::String, list_timestamp::Float64, dark_status::Int32, sec_status::Int32
    }}(undef, n)

    @inbounds for i in 1:n
        qot = basicQotList[i]
        security = qot.security
        market_label = string(QotMarket.T(security.market))
        formatted_code = string(market_label, ".", security.code)
        results[i] = (
            code = formatted_code,
            market = security.market,
            name = qot.name,
            last_price = qot.curPrice,
            prev_close = qot.lastClosePrice,
            open_price = qot.openPrice,
            high_price = qot.highPrice,
            low_price = qot.lowPrice,
            volume = qot.volume,
            turnover = qot.turnover,
            turnover_rate = qot.turnoverRate,
            amplitude = qot.amplitude,
            update_time = qot.updateTime,
            update_timestamp = qot.updateTimestamp,
            is_suspended = qot.isSuspended,
            list_time = qot.listTime,
            list_timestamp = qot.listTimestamp,
            dark_status = qot.darkStatus,
            sec_status = qot.secStatus
        )
    end

    return results
end

# Parse order book push data - optimized with NamedTuple
function parse_order_book_push(resp::Qot_UpdateOrderBook.Response)
    s2c = resp.s2c
    security = s2c.security

    display_name = s2c.name
    market_label = string(QotMarket.T(security.market))
    formatted_code = string(market_label, ".", security.code)

    # Type alias for order book level
    OrderDetail = @NamedTuple{order_id::UInt64, volume::Int64}
    OrderBookLevel = @NamedTuple{price::Float64, volume::Int64, order_count::Int32, details::Vector{OrderDetail}}

    function level_details(list)
        return [
            (
                price = item.price,
                volume = item.volume,
                order_count = item.orederCount,
                details = [(order_id = detail.orderID, volume = detail.volume) for detail in item.detailList]
            )::OrderBookLevel for item in list
        ]
    end

    ask_list = level_details(s2c.orderBookAskList)
    bid_list = level_details(s2c.orderBookBidList)

    return (
        code = formatted_code,
        market = security.market,
        name = display_name,
        ask_list = ask_list,
        bid_list = bid_list,
        server_recv_time_bid = s2c.svrRecvTimeBid,
        server_recv_time_bid_timestamp = s2c.svrRecvTimeBidTimestamp,
        server_recv_time_ask = s2c.svrRecvTimeAsk,
        server_recv_time_ask_timestamp = s2c.svrRecvTimeAskTimestamp
    )
end

# Parse K-line push data - optimized with NamedTuple
function parse_kline_push(resp::Qot_UpdateKL.Response)
    s2c = resp.s2c
    security = s2c.security

    display_name = s2c.name
    market_label = string(QotMarket.T(security.market))
    formatted_code = string(market_label, ".", security.code)

    KLineData = @NamedTuple{
        time::String, timestamp::Float64, is_blank::Bool,
        open::Float64, high::Float64, low::Float64, close::Float64, last_close::Float64,
        volume::Int64, turnover::Float64, turnover_rate::Float64, pe_ratio::Float64, change_rate::Float64
    }

    kl_list = [
        (
            time = item.time,
            timestamp = item.timestamp,
            is_blank = item.isBlank,
            open = item.openPrice,
            high = item.highPrice,
            low = item.lowPrice,
            close = item.closePrice,
            last_close = item.lastClosePrice,
            volume = item.volume,
            turnover = item.turnover,
            turnover_rate = item.turnoverRate,
            pe_ratio = item.pe,
            change_rate = item.changeRate
        )::KLineData for item in s2c.klList
    ]

    return (
        code = formatted_code,
        market = security.market,
        name = display_name,
        rehab_type = s2c.rehabType,
        kl_type = s2c.klType,
        kl_list = kl_list
    )
end

# Parse real-time data push - optimized with NamedTuple
function parse_rt_data_push(resp::Qot_UpdateRT.Response)
    s2c = resp.s2c
    security = s2c.security

    market_label = string(QotMarket.T(security.market))
    formatted_code = string(market_label, ".", security.code)

    RTData = @NamedTuple{
        time::String, minute::Int32, is_blank::Bool, price::Float64,
        last_close_price::Float64, avg_price::Float64, volume::Int64,
        turnover::Float64, timestamp::Float64
    }

    rt_list = [
        (
            time = item.time,
            minute = item.minute,
            is_blank = item.isBlank,
            price = item.price,
            last_close_price = item.lastClosePrice,
            avg_price = item.avgPrice,
            volume = item.volume,
            turnover = item.turnover,
            timestamp = item.timestamp
        )::RTData for item in s2c.rtList
    ]

    return (
        code = formatted_code,
        market = security.market,
        name = s2c.name,
        rt_list = rt_list
    )
end

# Parse ticker push data - optimized with NamedTuple
function parse_ticker_push(resp::Qot_UpdateTicker.Response)
    s2c = resp.s2c
    security = s2c.security

    market_label = string(QotMarket.T(security.market))
    formatted_code = string(market_label, ".", security.code)

    TickerData = @NamedTuple{
        time::String, sequence::Int64, direction::String, price::Float64,
        volume::Int64, turnover::Float64, recv_time::String,
        ticker_type::String, type_sign::String, timestamp::Float64
    }

    tickerList = s2c.tickerList
    n = length(tickerList)
    ticker_list = Vector{TickerData}(undef, n)

    @inbounds for i in 1:n
        item = tickerList[i]
        direction = item.dir == 1 ? "BUY" : item.dir == 2 ? "SELL" : "NEUTRAL"
        ticker_type_str = string(TickerType.T(item.type))
        type_sign_str = item.typeSign == 0 ? "" : string(Char(item.typeSign))

        ticker_list[i] = (
            time = item.time,
            sequence = item.sequence,
            direction = direction,
            price = item.price,
            volume = item.volume,
            turnover = item.turnover,
            recv_time = item.recvTime,
            ticker_type = ticker_type_str,
            type_sign = type_sign_str,
            timestamp = item.timestamp
        )
    end

    return (
        code = formatted_code,
        market = security.market,
        name = s2c.name,
        ticker_list = ticker_list
    )
end

# Parse broker queue push data - optimized with NamedTuple
function parse_broker_push(resp::Qot_UpdateBroker.Response)
    s2c = resp.s2c
    security = s2c.security

    market_label = string(QotMarket.T(security.market))
    formatted_code = string(market_label, ".", security.code)

    BrokerData = @NamedTuple{broker_id::Int64, broker_name::String, broker_pos::Int32}

    ask_brokers = [
        (broker_id = item.id, broker_name = item.name, broker_pos = item.pos)::BrokerData
        for item in s2c.brokerAskList
    ]

    bid_brokers = [
        (broker_id = item.id, broker_name = item.name, broker_pos = item.pos)::BrokerData
        for item in s2c.brokerBidList
    ]

    update_time = Dates.format(now(), "HH:MM:SS")

    return (
        code = formatted_code,
        market = security.market,
        name = s2c.name,
        ask_brokers = ask_brokers,
        bid_brokers = bid_brokers,
        update_time = update_time
    )
end

# Parse price reminder push data - optimized with NamedTuple
function parse_price_reminder_push(resp::Qot_UpdatePriceReminder.Response)
    s2c = resp.s2c
    security = s2c.security

    # Parse reminder type using a tuple lookup for better performance
    reminder_type = s2c._type
    reminder_type_str = if reminder_type == 1
        "PRICE_UP"
    elseif reminder_type == 2
        "PRICE_DOWN"
    elseif reminder_type == 3
        "CHANGE_RATE_UP"
    elseif reminder_type == 4
        "CHANGE_RATE_DOWN"
    elseif reminder_type == 5
        "5MIN_CHANGE_RATE_UP"
    elseif reminder_type == 6
        "5MIN_CHANGE_RATE_DOWN"
    elseif reminder_type == 7
        "VOLUME_UP"
    elseif reminder_type == 8
        "TURNOVER_UP"
    elseif reminder_type == 9
        "TURNOVER_RATE_UP"
    elseif reminder_type == 10
        "BID_PRICE_UP"
    elseif reminder_type == 11
        "ASK_PRICE_DOWN"
    elseif reminder_type == 12
        "BID_VOL_UP"
    elseif reminder_type == 13
        "ASK_VOL_UP"
    else
        "UNKNOWN"
    end

    # Parse market status
    market_status_int = s2c.marketStatus
    market_status_str = if market_status_int == 1
        "OPEN"
    elseif market_status_int == 2
        "US_PRE"
    elseif market_status_int == 3
        "US_AFTER"
    elseif market_status_int == 4
        "US_OVERNIGHT"
    else
        "UNKNOWN"
    end

    return (
        code = security.code,
        name = s2c.name,
        price = s2c.price,
        change_rate = s2c.changeRate,
        market_status = market_status_str,
        content = s2c.content,
        note = s2c.note,
        key = s2c.key,
        reminder_type = reminder_type_str,
        set_value = s2c.setValue,
        cur_value = s2c.curValue
    )
end

# Parse order update push data (trading) - optimized with NamedTuple
function parse_order_update_push(resp::Trd_UpdateOrder.Response)
    s2c = resp.s2c
    header = s2c.header
    order = s2c.order

    # Parse order type
    order_type_int = order.orderType
    order_type_str = if order_type_int == 1
        "NORMAL"
    elseif order_type_int == 2
        "MARKET"
    elseif order_type_int == 3
        "LIMIT"
    elseif order_type_int == 4
        "STOP"
    elseif order_type_int == 5
        "STOP_LIMIT"
    elseif order_type_int == 6
        "TRAILING_STOP"
    elseif order_type_int == 7
        "TRAILING_STOP_LIMIT"
    elseif order_type_int == 8
        "MARKET_IF_TOUCHED"
    elseif order_type_int == 9
        "LIMIT_IF_TOUCHED"
    elseif order_type_int == 10
        "AUCTION"
    elseif order_type_int == 11
        "AUCTION_LIMIT"
    elseif order_type_int == 12
        "ENHANCED_LIMIT"
    else
        "UNKNOWN"
    end

    # Parse order status
    order_status_int = order.orderStatus
    order_status_str = if order_status_int == 0
        "UNSUBMITTED"
    elseif order_status_int == 1
        "SUBMITTING"
    elseif order_status_int == 2
        "SUBMITTED"
    elseif order_status_int == 3
        "FAILED"
    elseif order_status_int == 4
        "TIMEOUT"
    elseif order_status_int == 5
        "PART_FILLED"
    elseif order_status_int == 6
        "FILLED"
    elseif order_status_int == 7
        "CANCELLING"
    elseif order_status_int == 8
        "CANCELLED"
    elseif order_status_int == 9
        "DELETED"
    elseif order_status_int == 10
        "FILL_CANCELLED"
    elseif order_status_int == 11
        "WAIT_OPEN"
    else
        "UNKNOWN"
    end

    # Parse trading side
    trd_side_int = order.trdSide
    trd_side_str = if trd_side_int == 0
        "UNKNOWN"
    elseif trd_side_int == 1
        "BUY"
    elseif trd_side_int == 2
        "SELL"
    elseif trd_side_int == 3
        "SELL_SHORT"
    elseif trd_side_int == 4
        "BUY_BACK"
    else
        "UNKNOWN"
    end

    # Parse trading environment
    trd_env_str = header.trdEnv == 0 ? "SIMULATE" : "REAL"

    # Parse trading market
    trd_market_int = header.trdMarket
    trd_market_str = if trd_market_int == 1
        "HK"
    elseif trd_market_int == 2
        "US"
    elseif trd_market_int == 3
        "CN"
    elseif trd_market_int == 4
        "HKCC"
    elseif trd_market_int == 5
        "FUTURES"
    else
        "UNKNOWN"
    end

    return (
        acc_id = header.accID,
        trd_env = trd_env_str,
        trd_market = trd_market_str,
        order_id = order.orderID,
        order_id_ex = order.orderIDEx,
        order_type = order_type_str,
        order_status = order_status_str,
        trd_side = trd_side_str,
        code = order.code,
        name = order.name,
        qty = order.qty,
        price = order.price,
        create_time = order.createTime,
        update_time = order.updateTime,
        fill_qty = order.fillQty,
        fill_avg_price = order.fillAvgPrice,
        last_err_msg = order.lastErrMsg,
        remark = order.remark,
        time_in_force = order.timeInForce,
        fill_outside_rth = order.fillOutsideRTH,
        aux_price = order.auxPrice,
        trail_type = order.trailType,
        trail_value = order.trailValue,
        trail_spread = order.trailSpread,
        currency = order.currency
    )
end

# Parse order fill push data (trading) - optimized with NamedTuple
function parse_order_fill_push(resp::Trd_UpdateOrderFill.Response)
    s2c = resp.s2c
    header = s2c.header
    fill = s2c.orderFill

    # Parse trading side
    trd_side_int = fill.trdSide
    trd_side_str = if trd_side_int == 0
        "UNKNOWN"
    elseif trd_side_int == 1
        "BUY"
    elseif trd_side_int == 2
        "SELL"
    elseif trd_side_int == 3
        "SELL_SHORT"
    elseif trd_side_int == 4
        "BUY_BACK"
    else
        "UNKNOWN"
    end

    # Parse trading environment
    trd_env_str = header.trdEnv == 0 ? "SIMULATE" : "REAL"

    # Parse trading market
    trd_market_int = header.trdMarket
    trd_market_str = if trd_market_int == 1
        "HK"
    elseif trd_market_int == 2
        "US"
    elseif trd_market_int == 3
        "CN"
    elseif trd_market_int == 4
        "HKCC"
    elseif trd_market_int == 5
        "FUTURES"
    else
        "UNKNOWN"
    end

    return (
        acc_id = header.accID,
        trd_env = trd_env_str,
        trd_market = trd_market_str,
        fill_id = fill.fillID,
        fill_id_ex = fill.fillIDEx,
        order_id = fill.orderID,
        order_id_ex = fill.orderIDEx,
        trd_side = trd_side_str,
        code = fill.code,
        name = fill.name,
        qty = fill.qty,
        price = fill.price,
        create_time = fill.createTime,
        counter_broker_id = fill.counterBrokerID,
        counter_broker_name = fill.counterBrokerName,
        sec_market = fill.secMarket,
        create_timestamp = fill.createTimestamp,
        update_timestamp = fill.updateTimestamp,
        status = fill.status
    )
end

# Parse deals push message (order fill push) - optimized with NamedTuple
function parse_deals_push(resp::Trd_UpdateOrderFill.Response)
    s2c = resp.s2c
    header = s2c.header
    fill = s2c.orderFill

    # Parse trading environment
    trd_env = header.trdEnv == 0 ? "SIMULATE" : "REAL"

    # Parse trading market
    trd_market_int = header.trdMarket
    trd_market = if trd_market_int == 1
        "HK"
    elseif trd_market_int == 2
        "US"
    elseif trd_market_int == 3
        "CN"
    elseif trd_market_int == 4
        "HKCC"
    elseif trd_market_int == 5
        "FUTURES"
    else
        "UNKNOWN"
    end

    # Parse trading side
    trd_side_int = fill.trdSide
    trd_side = if trd_side_int == 1
        "BUY"
    elseif trd_side_int == 2
        "SELL"
    elseif trd_side_int == 3
        "SELL_SHORT"
    elseif trd_side_int == 4
        "BUY_BACK"
    else
        "UNKNOWN"
    end

    # Parse security market
    sec_market_int = fill.secMarket
    sec_market = if sec_market_int == 1
        "HK"
    elseif sec_market_int == 2
        "US"
    elseif sec_market_int == 31
        "CN_SH"
    elseif sec_market_int == 32
        "CN_SZ"
    else
        "UNKNOWN"
    end

    # Parse fill status
    status_int = fill.status
    status = if status_int == 0
        "OK"
    elseif status_int == 1
        "CANCELLED"
    elseif status_int == 2
        "CHANGED"
    else
        "UNKNOWN"
    end

    return (
        acc_id = header.accID,
        trd_env = trd_env,
        trd_market = trd_market,
        fill_id = fill.fillID,
        fill_id_ex = fill.fillIDEx,
        order_id = fill.orderID,
        order_id_ex = fill.orderIDEx,
        code = fill.code,
        name = fill.name,
        trd_side = trd_side,
        qty = fill.qty,
        price = fill.price,
        create_time = fill.createTime,
        counter_broker_id = fill.counterBrokerID,
        counter_broker_name = fill.counterBrokerName,
        sec_market = sec_market,
        create_timestamp = fill.createTimestamp,
        update_timestamp = fill.updateTimestamp,
        status = status
    )
end

# Start callback handler
function start_callback_handler(manager::CallbackManager, connection::OpenDConnection)
    if manager.is_running
        @warn "Callback handler already running"
        return
    end

    manager.connection = connection
    manager.is_running = true

    # Start async handler that consumes from the push channel
    manager.handler_task = @async begin
        try
            for packet in connection.push_channel
                process_push_message(manager, packet)
            end
        catch e
            if manager.is_running && !(e isa InvalidStateException)
                @error "Error in callback handler task" exception=(e, catch_backtrace())
            end
        finally
            @info "Callback handler task stopped."
        end
    end
end

# Stop callback handler
function stop_callback_handler(manager::CallbackManager)
    manager.is_running = false
    if manager.connection !== nothing
        channel = manager.connection.push_channel
        if isopen(channel)
            close(channel)
        end
    end
    if manager.handler_task !== nothing
        wait(manager.handler_task)
        manager.handler_task = nothing
    end
    manager.connection = nothing
end

# Example wrapper for common callback patterns
function create_quote_logger(log_file::String = "quotes.log")
    return function(data)
        open(log_file, "a") do io
            for item in data
                println(io, "$(now()) - $(item["code"]): $(item["last_price"])")
            end
        end
    end
end

function create_price_alert(threshold_func::Function, alert_func::Function)
    return function(data)
        for item in data
            if threshold_func(item)
                alert_func(item)
            end
        end
    end
end

end # module PushCallbacks
