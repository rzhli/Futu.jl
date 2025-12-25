module Quote

using Dates
using DataFrames
using ..Client

# Protocol message types
using ..Constants: Qot_Sub, Qot_GetSubInfo
using ..Constants: Qot_GetSecuritySnapshot, Qot_GetBasicQot, Qot_GetOrderBook
using ..Constants: Qot_GetKL, Qot_GetRT, Qot_GetTicker, Qot_GetBroker
using ..Constants: Qot_GetCapitalDistribution, Qot_GetCapitalFlow, Qot_GetMarketState
using ..Constants: Qot_GetOwnerPlate
using ..Constants: Qot_RequestHistoryKL, Qot_RequestRehab, Qot_RequestHistoryKLQuota

# Common types and enums
using ..Constants: Qot_Common, Common, PROTO_RESPONSE_MAP, SUBTYPE_TO_PROTOID
using ..Constants: QotMarket, SecurityType, RetType

# Subscription and data types
using ..Constants: SubType, KLType, RehabType, PeriodType, CompanyAct

# Protocol IDs
using ..Constants: QOT_SUB, QOT_GET_SUB_INFO
using ..Constants: QOT_GET_SECURITY_SNAPSHOT, QOT_GET_BASIC_QOT, QOT_GET_ORDER_BOOK
using ..Constants: QOT_GET_KLINE, QOT_GET_RT_DATA, QOT_GET_TICKER, QOT_GET_BROKER
using ..Constants: QOT_GET_CAPITAL_DISTRIBUTION, QOT_GET_CAPITAL_FLOW, QOT_GET_MARKET_STATE
using ..Constants: QOT_GET_OWNER_PLATE
using ..Constants: QOT_REQUEST_HISTORY_KL, QOT_REQUEST_REHAB, QOT_REQUEST_HISTORY_KL_QUOTA

using ..Display: render_order_book, render_broker_queue, render_capital_distribution
using ..PushCallbacks: register_callback, unregister_callback

export
    # Subscription
    subscribe, unsubscribe, get_sub_info,
    
    # ================ 推送回调 ===================
    update_quote,

    # ================ 拉取 ==================
    get_market_snapshot, get_basic_quote, get_order_book, get_kline, get_rt, 
    get_ticker, get_broker_queue,

    # ================ 基本数据 =================
    get_market_state, get_capital_flow, get_capital_distribution, get_owner_plate,
    get_history_kline, get_rehab, get_history_kl_quota

# ============================= 订阅 =============================
# Subscribe to market data
function subscribe(client::OpenDClient, codes::Vector{String}, sub_types::Vector{SubType.T}; market::QotMarket.T = QotMarket.HK_Security, is_sub::Bool = true)
    securities = [Qot_Common.Security(Int32(market), code) for code in codes]
    sub_type_list = Int32[Int(st) for st in sub_types]
    c2s = Qot_Sub.C2S(
        securityList = securities,
        subTypeList = sub_type_list,
        isSubOrUnSub = is_sub,
        isRegOrUnRegPush = true
    )
    req = Qot_Sub.Request(c2s = c2s)
    resp = Client.api_request(client, UInt32(QOT_SUB), req, PROTO_RESPONSE_MAP[UInt32(QOT_SUB)])
    return (
        ret_type = Symbol(RetType.T(resp.retType)),
        err_code = resp.errCode,
        ret_msg = resp.retMsg
    )
end

# Unsubscribe from market data
function unsubscribe(client::OpenDClient, codes::Vector{String}, sub_types::Vector{SubType.T}; market::QotMarket.T = QotMarket.HK_Security)
    return subscribe(client, codes, sub_types; market = market, is_sub = false)
end

# Get subscription info
function get_sub_info(client::OpenDClient)
    req = Qot_GetSubInfo.Request(c2s = Qot_GetSubInfo.C2S())
    resp = Client.api_request(client, UInt32(QOT_GET_SUB_INFO), req, PROTO_RESPONSE_MAP[UInt32(QOT_GET_SUB_INFO)])
    return resp.s2c
end

# ============================== 推送回调 ===============================

"""
    update_quote(client, codes, sub_type, callback; is_sub = true)

Subscribe or unsubscribe to real-time data pushes for the given `codes` and register/unregister a callback.

- `client`: Active `OpenDClient`
- `codes`: Vector of stock symbols in "MARKET.NUMBER" format (e.g., "SH.601019", "SZ.000100", "HK.00700")
- `sub_type`: The `SubType` to subscribe to (e.g., `SubType.Basic`, `SubType.Ticker`)
- `callback`: Function invoked with parsed push payload. For unsubscription, can be `nothing` to keep callback registered.
- `is_sub`: `true` to subscribe and register_callback, `false` to unsubscribe and unregister_callback

The function automatically detects the market from each code and groups them for batch subscription.
"""
function update_quote(client::OpenDClient, codes::Vector{String}, sub_type::SubType.T, callback::Union{Function, Nothing}; is_sub::Bool = true)
    proto_id = get(SUBTYPE_TO_PROTOID, sub_type, nothing)

    # 按市场分组股票代码
    market_groups = Dict{QotMarket.T, Vector{String}}()

    for code in codes
        # 解析市场前缀（支持 "SH.601019" 或 "sh.601019" 格式）
        parts = split(code, ".")
        market_str = uppercase(String(parts[1]))  # 市场前缀
        pure_code = String(parts[2])  

        market = if market_str == "SH"
            QotMarket.CNSH_Security
        elseif market_str == "SZ"
            QotMarket.CNSZ_Security
        elseif market_str == "HK"
            QotMarket.HK_Security
        else
            @warn "Unknown market prefix in code: $code, defaulting to HK"
            QotMarket.HK_Security
        end

        # 将纯代码添加到对应市场的组
        if !haskey(market_groups, market)
            market_groups[market] = String[]
        end
        push!(market_groups[market], pure_code)
    end

    # 对每个市场分别订阅
    results = []
    for (market, pure_codes) in market_groups
        result = subscribe(client, pure_codes, SubType.T[sub_type]; market = market, is_sub = is_sub)
        push!(results, result)

        if is_sub
            if result.ret_type != :Succeed
                @warn "Subscription failed for market $(market)" sub_type=sub_type ret_type=result.ret_type err_code=result.err_code ret_msg=result.ret_msg
            end
        end
    end

    # 注册/注销回调（只需注册一次，所有市场共用）
    if is_sub
        if any(r.ret_type == :Succeed for r in results) && callback !== nothing
            register_callback(client.callbacks, UInt32(proto_id), callback)
        end
    else # Unsubscribe
        if callback !== nothing
            unregister_callback(client.callbacks, callback)
        end
    end

    # 返回第一个结果（或者可以返回所有结果）
    return results
end

# ================================ 拉取 ==================================
# Get market snapshot - optimized with pre-allocated vector
function get_market_snapshot(client::OpenDClient, codes::Vector{String}; market::QotMarket.T = QotMarket.HK_Security)
    securities = [Qot_Common.Security(Int(market), code) for code in codes]

    c2s = Qot_GetSecuritySnapshot.C2S(; securityList = securities)
    req = Qot_GetSecuritySnapshot.Request(; c2s = c2s)

    resp = Client.api_request(client, UInt32(QOT_GET_SECURITY_SNAPSHOT), req, PROTO_RESPONSE_MAP[UInt32(QOT_GET_SECURITY_SNAPSHOT)])
    snapshots = resp.s2c.snapshotList

    # Use map with explicit processing to avoid Vector{Any}
    rows = map(snapshots) do snapshot
        basic = snapshot.basic
        security = basic.security

        security_type = SecurityType.T(basic.type)
        market_label= string(QotMarket.T(security.market))
        formatted_code =  string(market_label, ".", security.code)

        stock_owner = missing
        if security_type == SecurityType.Warrant
            owner = snapshot.warrantExData.owner
            owner_market = string(QotMarket.T(owner.market))
            stock_owner = string(owner_market, ".", owner.code)
        elseif security_type == SecurityType.Drvt
            owner = snapshot.optionExData.owner
            owner_market = string(QotMarket.T(owner.market))
            stock_owner = string(owner_market, ".", owner.code)
        end

        base_fields = (
            code = formatted_code,
            name = basic.name,
            update_time = basic.updateTime,
            last_price = basic.curPrice,
            open_price = basic.openPrice,
            high_price = basic.highPrice,
            low_price = basic.lowPrice,
            prev_close_price = basic.lastClosePrice,
            volume = basic.volume,
            turnover = basic.turnover,
            turnover_rate = basic.turnoverRate,
            suspension = basic.isSuspend,
            listing_date = basic.listTime,
            lot_size = Int64(basic.lotSize),
            price_spread = basic.priceSpread,
            stock_owner = stock_owner,
            ask_price = basic.askPrice,
            bid_price = basic.bidPrice,
            ask_vol = basic.askVol,
            bid_vol = basic.bidVol,
            enable_margin = basic.enableMargin,
            mortgage_ratio = basic.mortgageRatio,
            long_margin_initial_ratio = basic.longMarginInitialRatio,
            enable_short_sell = basic.enableShortSell,
            short_sell_rate = basic.shortSellRate,
            short_available_volume = basic.shortAvailableVolume,
            short_margin_initial_ratio = basic.shortMarginInitialRatio,
            amplitude = basic.amplitude,
            avg_price = basic.avgPrice,
            bid_ask_ratio = basic.bidAskRatio,
            volume_ratio = basic.volumeRatio,
            highest52weeks_price = basic.highest52WeeksPrice,
            lowest52weeks_price = basic.lowest52WeeksPrice,
            highest_history_price = basic.highestHistoryPrice,
            lowest_history_price = basic.lowestHistoryPrice,
            close_price_5min = basic.closePrice5Minute,
            after_volume = basic.afterMarket.volume,
            after_turnover = basic.afterMarket.turnover,
            sec_status = string(Qot_Common.SecurityStatus.T(basic.secStatus))
        )

        equity = snapshot.equityExData
        equity_valid = security_type == SecurityType.Eqty
        equity_fields = (
            equity_valid = equity_valid,
            issued_shares = equity_valid ? equity.issuedShares : missing,
            total_market_val = equity_valid ? equity.issuedMarketVal : missing,
            net_asset = equity_valid ? equity.netAsset : missing,
            net_profit = equity_valid ? equity.netProfit : missing,
            earning_per_share = equity_valid ? equity.earningsPershare : missing,
            outstanding_shares = equity_valid ? equity.outstandingShares : missing,
            circular_market_val = equity_valid ? equity.outstandingMarketVal : missing,
            net_asset_per_share = equity_valid ? equity.netAssetPershare : missing,
            ey_ratio = equity_valid ? equity.eyRate : missing,
            pe_ratio = equity_valid ? equity.peRate : missing,
            pb_ratio = equity_valid ? equity.pbRate : missing,
            pe_ttm_ratio = equity_valid ? equity.peTTMRate : missing,
            dividend_ttm = equity_valid ? equity.dividendTTM : missing,
            dividend_ratio_ttm = equity_valid ? equity.dividendRatioTTM : missing,
            dividend_lfy = equity_valid ? equity.dividendLFY : missing,
            dividend_lfy_ratio = equity_valid ? equity.dividendLFYRatio : missing
        )

        warrant = snapshot.warrantExData
        wrt_valid = security_type == SecurityType.Warrant
        wrt_fields = (
            wrt_valid = wrt_valid,
            wrt_conversion_ratio = wrt_valid ? warrant.conversionRate : missing,
            wrt_type = wrt_valid ? string(Qot_Common.WarrantType.T(warrant.warrantType)) : missing,
            wrt_strike_price = wrt_valid ? warrant.strikePrice : missing,
            wrt_maturity_date = wrt_valid ? warrant.maturityTime : missing,
            wrt_end_trade = wrt_valid ? warrant.endTradeTime : missing,
            wrt_recovery_price = wrt_valid ? warrant.recoveryPrice : missing,
            wrt_street_vol = wrt_valid ? warrant.streetVolumn : missing,
            wrt_issue_vol = wrt_valid ? warrant.issueVolumn : missing,
            wrt_street_ratio = wrt_valid ? warrant.streetRate : missing,
            wrt_delta = wrt_valid ? warrant.delta : missing,
            wrt_implied_volatility = wrt_valid ? warrant.impliedVolatility : missing,
            wrt_premium = wrt_valid ? warrant.premium : missing,
            wrt_leverage = wrt_valid ? warrant.leverage : missing,
            wrt_ipop = wrt_valid ? warrant.ipop : missing,
            wrt_break_even_point = wrt_valid ? warrant.breakEvenPoint : missing,
            wrt_conversion_price = wrt_valid ? warrant.conversionPrice : missing,
            wrt_price_recovery_ratio = wrt_valid ? warrant.priceRecoveryRatio : missing,
            wrt_score = wrt_valid ? warrant.score : missing,
            wrt_upper_strike_price = wrt_valid ? warrant.upperStrikePrice : missing,
            wrt_lower_strike_price = wrt_valid ? warrant.lowerStrikePrice : missing,
            wrt_inline_price_status = wrt_valid ? string(Qot_Common.PriceType.T(warrant.inLinePriceStatus)) : missing,
            wrt_issuer_code = wrt_valid ? warrant.issuerCode : missing
        )

        option = snapshot.optionExData
        option_valid = security_type == SecurityType.Drvt
        option_fields = (
            option_valid = option_valid,
            option_type = option_valid ? string(Qot_Common.OptionType.T(option.type)) : missing,
            strike_time = option_valid ? option.strikeTime : missing,
            option_strike_price = option_valid ? option.strikePrice : missing,
            option_contract_size = option_valid ? option.contractSizeFloat : missing,
            option_open_interest = option_valid ? option.openInterest : missing,
            option_implied_volatility = option_valid ? option.impliedVolatility : missing,
            option_premium = option_valid ? option.premium : missing,
            option_delta = option_valid ? option.delta : missing,
            option_gamma = option_valid ? option.gamma : missing,
            option_vega = option_valid ? option.vega : missing,
            option_theta = option_valid ? option.theta : missing,
            option_rho = option_valid ? option.rho : missing,
            option_net_open_interest = option_valid ? (option.netOpenInterest) : missing,
            option_expiry_date_distance = option_valid ? option.expiryDateDistance : missing,
            option_contract_nominal_value = option_valid ? option.contractNominalValue : missing,
            option_owner_lot_multiplier = option_valid ? option.ownerLotMultiplier : missing,
            option_area_type = option_valid ? string(Qot_Common.OptionAreaType.T(option.optionAreaType)) : missing,
            option_contract_multiplier = option_valid ? option.contractMultiplier : missing,
            index_option_type = option_valid ? string(Qot_Common.IndexOptionType.T(option.indexOptionType)) : missing
        )

        index_data = snapshot.indexExData
        index_valid = security_type == SecurityType.Index
        index_fields = (
            index_valid = index_valid,
            index_raise_count = index_valid ? index_data.raiseCount : missing,
            index_fall_count = index_valid ? index_data.fallCount : missing,
            index_equal_count = index_valid ? index_data.equalCount : missing
        )

        plate_data = snapshot.plateExData
        plate_valid = security_type == SecurityType.Plate
        plate_fields = (
            plate_valid = plate_valid,
            plate_raise_count = plate_valid ? plate_data.raiseCount : missing,
            plate_fall_count = plate_valid ? plate_data.fallCount : missing,
            plate_equal_count = plate_valid ? plate_data.equalCount : missing
        )

        future = snapshot.futureExData
        future_valid = security_type == SecurityType.Future
        future_fields = (
            future_valid = future_valid,
            future_last_settle_price = future_valid ? future.lastSettlePrice : missing,
            future_position = future_valid ? future.position : missing,
            future_position_change = future_valid ? future.positionChange : missing,
            future_main_contract = future_valid ? future.isMainContract : missing,
            future_last_trade_time = future_valid ? future.lastTradeTime : missing
        )

        trust = snapshot.trustExData
        trust_valid = security_type == SecurityType.Trust
        trust_fields = (
            trust_valid = trust_valid,
            trust_dividend_yield = trust_valid ? trust.dividendYield : missing,
            trust_aum = trust_valid ? trust.aum : missing,
            trust_outstanding_units = trust_valid ? trust.outstandingUnits : missing,
            trust_netAssetValue = trust_valid ? trust.netAssetValue : missing,
            trust_premium = trust_valid ? trust.premium : missing,
            trust_assetClass = trust_valid ? string(Qot_Common.AssetClass.T(trust.assetClass)) : missing
        )

        pre = basic.preMarket
        pre_fields = (
            pre_price = pre.price,
            pre_high_price = pre.highPrice,
            pre_low_price = pre.lowPrice,
            pre_volume = pre.volume,
            pre_turnover = pre.turnover,
            pre_change_val = pre.changeVal,
            pre_change_rate = pre.changeRate,
            pre_amplitude = pre.amplitude
        )

        after_data = basic.afterMarket
        after_fields = (
            after_price = after_data.price,
            after_high_price = after_data.highPrice,
            after_low_price = after_data.lowPrice,
            after_change_val = after_data.changeVal,
            after_change_rate = after_data.changeRate,
            after_amplitude = after_data.amplitude
        )

        overnight = basic.overnight
        overnight_fields = (
            overnight_price = overnight.price,
            overnight_high_price = overnight.highPrice,
            overnight_low_price = overnight.lowPrice,
            overnight_volume = overnight.volume,
            overnight_turnover = overnight.turnover,
            overnight_change_val = overnight.changeVal,
            overnight_change_rate = overnight.changeRate,
            overnight_amplitude = overnight.amplitude
        )

        # Return merged tuple instead of push!
        merge(base_fields, equity_fields, wrt_fields, option_fields, index_fields, plate_fields, future_fields, trust_fields, pre_fields, after_fields, overnight_fields)
    end

    return DataFrame(rows)
end

# Get real-time basic quote for subscribed securities - optimized with map
function get_basic_quote(client::OpenDClient, codes::Vector{String}; market::QotMarket.T = QotMarket.HK_Security)
    securities = [Qot_Common.Security(Int(market), code) for code in codes]

    c2s = Qot_GetBasicQot.C2S(securities)
    req = Qot_GetBasicQot.Request(; c2s = c2s)

    resp = Client.api_request(client, UInt32(QOT_GET_BASIC_QOT), req, PROTO_RESPONSE_MAP[UInt32(QOT_GET_BASIC_QOT)])
    quotes = resp.s2c.basicQotList

    rows = map(quotes) do basic
        security = basic.security
        market_label = string(QotMarket.T(security.market))
        formatted_code = string(market_label, ".", security.code)

        base_fields = (
            code = formatted_code,
            market = market_label,
            raw_code = security.code,
            name = basic.name,
            is_suspended = basic.isSuspended,
            list_time = basic.listTime,
            list_timestamp = basic.listTimestamp,
            price_spread = basic.priceSpread,
            update_time = basic.updateTime,
            update_timestamp = basic.updateTimestamp,
            high_price = basic.highPrice,
            open_price = basic.openPrice,
            low_price = basic.lowPrice,
            last_price = basic.curPrice,
            prev_close_price = basic.lastClosePrice,
            volume = basic.volume,
            turnover = basic.turnover,
            turnover_rate = basic.turnoverRate,
            amplitude = basic.amplitude,
            dark_status = string(Qot_Common.DarkStatus.T(basic.darkStatus)),
            sec_status = string(Qot_Common.SecurityStatus.T(basic.secStatus))
        )

        pre = basic.preMarket
        pre_fields = (
            pre_price = pre.price,
            pre_high_price = pre.highPrice,
            pre_low_price = pre.lowPrice,
            pre_volume = pre.volume,
            pre_turnover = pre.turnover,
            pre_change_val = pre.changeVal,
            pre_change_rate = pre.changeRate,
            pre_amplitude = pre.amplitude
        )

        after_market = basic.afterMarket
        after_fields = (
            after_price = after_market.price,
            after_high_price = after_market.highPrice,
            after_low_price = after_market.lowPrice,
            after_volume = after_market.volume,
            after_turnover = after_market.turnover,
            after_change_val = after_market.changeVal,
            after_change_rate = after_market.changeRate,
            after_amplitude = after_market.amplitude
        )

        overnight = basic.overnight
        overnight_fields = (
            overnight_price = overnight.price,
            overnight_high_price = overnight.highPrice,
            overnight_low_price = overnight.lowPrice,
            overnight_volume = overnight.volume,
            overnight_turnover = overnight.turnover,
            overnight_change_val = overnight.changeVal,
            overnight_change_rate = overnight.changeRate,
            overnight_amplitude = overnight.amplitude
        )

        future_data = basic.futureExData
        future_fields = (
            future_last_settle_price = future_data.lastSettlePrice,
            future_position = future_data.position,
            future_position_change = future_data.positionChange,
            future_expiry_date_distance = future_data.expiryDateDistance
        )

        warrant_data = basic.warrantExData
        warrant_fields = (
            warrant_delta = warrant_data.delta,
            warrant_implied_volatility = warrant_data.impliedVolatility,
            warrant_premium = warrant_data.premium
        )

        option_data = basic.optionExData
        option_fields = (
            option_strike_price = option_data.strikePrice,
            option_contract_size = option_data.contractSize,
            option_open_interest = option_data.openInterest,
            option_implied_volatility = option_data.impliedVolatility,
            option_premium = option_data.premium,
            option_delta = option_data.delta,
            option_gamma = option_data.gamma,
            option_vega = option_data.vega,
            option_theta = option_data.theta,
            option_rho = option_data.rho,
            option_net_open_interest = option_data.netOpenInterest,
            option_expiry_date_distance = option_data.expiryDateDistance,
            option_contract_nominal_value = option_data.contractNominalValue,
            option_owner_lot_multiplier = option_data.ownerLotMultiplier,
            option_area_type = string(Qot_Common.OptionAreaType.T(option_data.optionAreaType)),
            option_contract_multiplier = option_data.contractMultiplier,
            option_contract_size_float = option_data.contractSizeFloat,
            option_index_option_type = string(Qot_Common.IndexOptionType.T(option_data.indexOptionType))
        )

        # Return merged tuple instead of push!
        merge(base_fields, pre_fields, after_fields, overnight_fields, future_fields, warrant_fields, option_fields)
    end

    return DataFrame(rows)
end

# Get order book - optimized with NamedTuple
function get_order_book(client::OpenDClient, code::String; market::QotMarket.T = QotMarket.HK_Security, depth::Int = 10)
    security = Qot_Common.Security(Int(market), code)

    req = Qot_GetOrderBook.Request(
        c2s = Qot_GetOrderBook.C2S(
            security = security,
            num = depth
        )
    )

    resp = Client.api_request(client, UInt32(QOT_GET_ORDER_BOOK), req, PROTO_RESPONSE_MAP[UInt32(QOT_GET_ORDER_BOOK)])
    ask_list = resp.s2c.orderBookAskList
    bid_list = resp.s2c.orderBookBidList

    # Use NamedTuple instead of Dict for type stability
    OrderBookEntry = @NamedTuple{price::Float64, volume::Int64, order_count::Int64}
    asks = [(price = item.price, volume = Int64(item.volume), order_count = Int64(item.orederCount))::OrderBookEntry for item in ask_list]
    bids = [(price = item.price, volume = Int64(item.volume), order_count = Int64(item.orederCount))::OrderBookEntry for item in bid_list]

    security = resp.s2c.security
    market_label = string(Qot_Common.QotMarket.T(security.market))
    formatted_code = string(market_label, ".", security.code)

    book = Dict(
        "code" => formatted_code,
        "market" => security.market,
        "name" => resp.s2c.name,
        "bid_list" => bids,
        "ask_list" => asks,
        "server_recv_time_bid" => resp.s2c.svrRecvTimeBid,
        "server_recv_time_bid_timestamp" => resp.s2c.svrRecvTimeBidTimestamp,
        "server_recv_time_ask" => resp.s2c.svrRecvTimeAsk,
        "server_recv_time_ask_timestamp" => resp.s2c.svrRecvTimeAskTimestamp
    )

    rows = length(ask_list)
    render_order_book(stdout, book; max_rows = rows)
    # return book
end

# Get K-line data - optimized with map
function get_kline(client::OpenDClient, code::String; market::QotMarket.T = QotMarket.HK_Security, kl_type::KLType.T = KLType.K_Day, count::Int = 100, from_date::Union{Date, Nothing} = nothing, to_date::Union{Date, Nothing} = nothing)
    security = Qot_Common.Security(Int(market), code)

    c2s = Qot_GetKL.C2S(
        Int32(Qot_Common.RehabType.None),
        Int32(kl_type),
        security,
        Int32(count)
    )

    # Note: Qot_GetKL does not support beginTime/endTime parameters
    # For historical K-line with date range, use Qot_RequestHistoryKL instead
    if from_date !== nothing || to_date !== nothing
        @warn "Qot_GetKL does not support date range filtering. Use request_history_kline() for date-based queries."
    end

    req = Qot_GetKL.Request(c2s)
    resp = Client.api_request(client, UInt32(QOT_GET_KLINE), req, PROTO_RESPONSE_MAP[UInt32(QOT_GET_KLINE)])
    data = resp.s2c.klList

    # Convert to DataFrame using map for type stability
    rows = map(data) do item
        (
            time = item.time,
            open = item.openPrice,
            close = item.closePrice,
            high = item.highPrice,
            low = item.lowPrice,
            volume = item.volume,
            turnover = item.turnover
        )
    end

    return DataFrame(rows)
end

# Get real-time data - optimized with map
function get_rt(client::OpenDClient, code::String; market::QotMarket.T = QotMarket.HK_Security)
    security = Qot_Common.Security(Int(market), code)

    req = Qot_GetRT.Request(
        c2s = Qot_GetRT.C2S(
            security = security
        )
    )

    resp = Client.api_request(client, UInt32(QOT_GET_RT_DATA), req, PROTO_RESPONSE_MAP[UInt32(QOT_GET_RT_DATA)])
    data = resp.s2c.rtList

    # Convert to DataFrame using map for type stability
    rows = map(data) do item
        # Convert Unix timestamp to DateTime, then extract time part
        dt = unix2datetime(item.timestamp) + Hour(8)    # 转换为北京时间
        (
            time = item.time,
            minute = item.minute,
            is_blank = item.isBlank,
            price = item.price,
            last_close_price = item.lastClosePrice,
            avg_price = item.avgPrice,
            volume = item.volume,
            turnover = item.turnover,
            timestamp = Time(dt)
        )
    end

    return DataFrame(rows)
end

# Get ticker data - optimized with map
function get_ticker(client::OpenDClient, code::String; market::QotMarket.T = QotMarket.HK_Security, count::Int = 100)
    security = Qot_Common.Security(Int(market), code)

    req = Qot_GetTicker.Request(
        c2s = Qot_GetTicker.C2S(
            security = security,
            maxRetNum = count
        )
    )

    resp = Client.api_request(client, UInt32(QOT_GET_TICKER), req, PROTO_RESPONSE_MAP[UInt32(QOT_GET_TICKER)])
    data = resp.s2c.tickerList

    # Convert to DataFrame using map for type stability
    rows = map(data) do item
        direction = item.dir == 1 ? "BUY" : item.dir == 2 ? "SELL" : "NEUTRAL"
        ticker_type = Qot_Common.TickerType.T(item.type)
        timestamp = unix2datetime(item.timestamp) + Hour(8)     # 转换为北京时间
        (
            time = item.time,
            sequence = item.sequence,
            direction = direction,
            price = item.price,
            volume = item.volume,
            turnover = item.turnover,
            recv_time = unix2datetime(item.recvTime) |> Time,
            ticker_type = string(ticker_type),
            type_sign = Int32(item.typeSign),
            push_data_type = item.pushDataType,
            timestamp = Time(timestamp)
        )
    end

    return DataFrame(rows)
end

# Get broker queue
function get_broker_queue(client::OpenDClient, code::String; market::QotMarket.T = QotMarket.HK_Security)
    security = Qot_Common.Security(Int(market), code)

    req = Qot_GetBroker.Request(
        c2s = Qot_GetBroker.C2S(
            security = security
        )
    )

    resp = Client.api_request(client, UInt32(QOT_GET_BROKER), req, PROTO_RESPONSE_MAP[UInt32(QOT_GET_BROKER)])
    data = resp.s2c

    ask_entries = [(id = Int64(item.id), name = item.name, pos = Int64(item.pos)) for item in data.brokerAskList]

    bid_entries = [(id = Int64(item.id), name = item.name, pos = Int64(item.pos)) for item in data.brokerBidList]

    book = (bids = bid_entries, asks = ask_entries)
    rows = max(length(book.bids), length(book.asks))
    render_broker_queue(stdout, book.bids, book.asks; max_rows = rows)

    # return book
end

# ================================ 基本数据 ===================================
# Get market state for securities - optimized with map
function get_market_state(client::OpenDClient, codes::Vector{String}; market::QotMarket.T = QotMarket.HK_Security)
    securities = [Qot_Common.Security(Int(market), code) for code in codes]

    c2s = Qot_GetMarketState.C2S(; securityList = securities)
    req = Qot_GetMarketState.Request(; c2s = c2s)

    resp = Client.api_request(client, UInt32(QOT_GET_MARKET_STATE), req, PROTO_RESPONSE_MAP[UInt32(QOT_GET_MARKET_STATE)])
    market_infos = resp.s2c.marketInfoList

    rows = map(market_infos) do info
        security = info.security
        market_label = string(QotMarket.T(security.market))
        formatted_code = string(market_label, ".", security.code)
        state_enum = Qot_Common.QotMarketState.T(info.marketState)

        (
            code = formatted_code,
            market = market_label,
            raw_code = security.code,
            name = info.name,
            market_state = string(state_enum),
            market_state_value = Int(info.marketState)
        )
    end

    return DataFrame(rows)
end

# Get capital flow
function get_capital_flow(client::OpenDClient, code::String; market::QotMarket.T = QotMarket.HK_Security, period::PeriodType.T = PeriodType.INTRADAY, begin_time::Union{Nothing, Date} = nothing, end_time::Union{Nothing, Date} = nothing)
    # Notes:
    # - Maximum 30 requests per 30 seconds.
    # - Supports equities, warrants, and funds only.
    # - Historical periods provide up to the most recent year; intraday only covers the latest day.
    # - Returned data includes regular session trades only (no pre/post market).
    security = Qot_Common.Security(Int(market), code)
    if period == PeriodType.INTRADAY
        begin_str = ""
        end_str = ""
    else
        begin_str = begin_time === nothing ? "" : Dates.format(begin_time, dateformat"yyyy-mm-dd")
        end_str = end_time === nothing ? "" : Dates.format(end_time, dateformat"yyyy-mm-dd")
    end

    c2s = Qot_GetCapitalFlow.C2S(; security = security, periodType = Int32(period), beginTime = begin_str, endTime = end_str)
    req = Qot_GetCapitalFlow.Request(; c2s = c2s)

    resp = Client.api_request(client, UInt32(QOT_GET_CAPITAL_FLOW), req, PROTO_RESPONSE_MAP[UInt32(QOT_GET_CAPITAL_FLOW)])
    flow_items = resp.s2c.flowItemList

    # Use map for type stability
    rows = map(flow_items) do item
        dt = unix2datetime(item.timestamp) + Hour(8)
        timestamp = Time(dt)
        (
            time = isempty(item.time) ? missing : item.time,
            timestamp = item.timestamp == 0.0 ? missing : timestamp,
            inflow = item.inFlow,
            main_inflow = item.mainInFlow,
            super_inflow = item.superInFlow,
            big_inflow = item.bigInFlow,
            mid_inflow = item.midInFlow,
            small_inflow = item.smlInFlow,
        )
    end

    df = DataFrame(rows)

    return (data = df,
        last_valid_time = isempty(resp.s2c.lastValidTime) ? missing : resp.s2c.lastValidTime,
        last_valid_timestamp = resp.s2c.lastValidTimestamp == 0.0 ? missing : resp.s2c.lastValidTimestamp,
    )
end

# Get capital distribution (capital flow)
function get_capital_distribution(client::OpenDClient, code::String; market::QotMarket.T = QotMarket.HK_Security)
    """
    Get capital distribution (capital flow) for a security

    Parameters:
    - client: OpenDClient instance
    - code: Stock code
    - market: Market (default: QotMarket.HK_Security)

    Returns:
    - Dict with capital flow information including:
        - capital_in_super: Inflow capital, extra-large order
        - capital_in_big: Inflow capital, large order
        - capital_in_mid: Inflow capital, medium order
        - capital_in_small: Inflow capital, small order
        - capital_out_super: Outflow capital, extra-large order
        - capital_out_big: Outflow capital, large order
        - capital_out_mid: Outflow capital, medium order
        - capital_out_small: Outflow capital, small order
        - net_inflow: Net capital inflow (positive for inflow, negative for outflow)
        - update_time: Update time string
        - update_timestamp: Update timestamp

    Note:
    - Maximum 30 requests per 30 seconds
    - Only supports stocks, warrants and funds
    - Data only includes Regular Trading Hours, not Pre/Post-Market
    - Classification is based on average turnover in previous month (3 days for warrants):
        * Small orders: < average turnover
        * Large orders: >= 10x average turnover
        * Medium orders: between small and large
        * Extra-large orders: specific larger threshold
    """

    security = Qot_Common.Security(Int(market), code)

    c2s = Qot_GetCapitalDistribution.C2S(security)
    req = Qot_GetCapitalDistribution.Request(; c2s = c2s)

    resp = Client.api_request(client, UInt32(QOT_GET_CAPITAL_DISTRIBUTION), req, PROTO_RESPONSE_MAP[UInt32(QOT_GET_CAPITAL_DISTRIBUTION)])

    data = resp.s2c
    total_inflow = data.capitalInSuper + data.capitalInBig + data.capitalInMid + data.capitalInSmall
    total_outflow = data.capitalOutSuper + data.capitalOutBig + data.capitalOutMid + data.capitalOutSmall
    net_inflow = total_inflow - total_outflow

    rows = [
        (
            label = "特大单",
            inflow = data.capitalInSuper,
            outflow = data.capitalOutSuper,
            net = data.capitalInSuper - data.capitalOutSuper,
            inflow_pct = total_inflow > 0 ? data.capitalInSuper / total_inflow * 100 : 0.0,
            outflow_pct = total_outflow > 0 ? data.capitalOutSuper / total_outflow * 100 : 0.0
        ),
        (
            label = "大单",
            inflow = data.capitalInBig,
            outflow = data.capitalOutBig,
            net = data.capitalInBig - data.capitalOutBig,
            inflow_pct = total_inflow > 0 ? data.capitalInBig / total_inflow * 100 : 0.0,
            outflow_pct = total_outflow > 0 ? data.capitalOutBig / total_outflow * 100 : 0.0
        ),
        (
            label = "中单",
            inflow = data.capitalInMid,
            outflow = data.capitalOutMid,
            net = data.capitalInMid - data.capitalOutMid,
            inflow_pct = total_inflow > 0 ? data.capitalInMid / total_inflow * 100 : 0.0,
            outflow_pct = total_outflow > 0 ? data.capitalOutMid / total_outflow * 100 : 0.0
        ),
        (
            label = "小单",
            inflow = data.capitalInSmall,
            outflow = data.capitalOutSmall,
            net = data.capitalInSmall - data.capitalOutSmall,
            inflow_pct = total_inflow > 0 ? data.capitalInSmall / total_inflow * 100 : 0.0,
            outflow_pct = total_outflow > 0 ? data.capitalOutSmall / total_outflow * 100 : 0.0
        )
    ]

    render_capital_distribution(stdout, rows; total_inflow = total_inflow, total_outflow = total_outflow, net_inflow = net_inflow, update_time = data.updateTime)
    # return rows
end

# 获取股票所属板块 - optimized with Iterators.flatten
function get_owner_plate(client::OpenDClient, codes::Vector{String}; market::QotMarket.T = QotMarket.HK_Security)
    securities = [Qot_Common.Security(Int(market), code) for code in codes]

    c2s = Qot_GetOwnerPlate.C2S(; securityList = securities)
    req = Qot_GetOwnerPlate.Request(; c2s = c2s)

    resp = Client.api_request(client, UInt32(QOT_GET_OWNER_PLATE), req, PROTO_RESPONSE_MAP[UInt32(QOT_GET_OWNER_PLATE)])
    owner_list = resp.s2c.ownerPlateList

    # Use Iterators.flatten to avoid push! with abstract NamedTuple[]
    rows = collect(Iterators.flatten(map(owner_list) do item
        security = item.security
        market_label = string(QotMarket.T(security.market))
        code_str = string(market_label, ".", security.code)

        map(item.plateInfoList) do plate
            (
                code = code_str,
                raw_code = security.code,
                name = isempty(item.name) ? missing : item.name,
                plate_code = plate.plate.code,
                plate_market = string(QotMarket.T(plate.plate.market)),
                plate_name = isempty(plate.name) ? missing : plate.name,
                plate_type = string(Qot_Common.PlateSetType.T(plate.plateType))
            )
        end
    end))

    return DataFrame(rows)
end

# 获取历史K线
function get_history_kline(client::OpenDClient, code::String;
    market::QotMarket.T = QotMarket.HK_Security, kl_type::KLType.T = KLType.K_Day,
    rehab_type::RehabType.T = RehabType.Forward, begin_time::Union{Date, Nothing} = nothing,
    end_time::Union{Date, Nothing} = today(), max_count::Union{Int, Nothing} = nothing,
    need_fields_flag::Union{Int, Nothing} = nothing, next_req_key::Vector{UInt8} = UInt8[],
    extended_time::Bool = false, session::Union{Int, Nothing} = nothing
    )
    security = Qot_Common.Security(Int(market), code)

    if begin_time === nothing
        if max_count !== nothing
            begin_time = end_time - Day(ceil(Int, max_count * 1.5))
        else
            error("Either begin_time or max_count must be provided")
        end
    end

    begin_str = Dates.format(begin_time, dateformat"yyyy-mm-dd")
    end_str = Dates.format(end_time, dateformat"yyyy-mm-dd")

    c2s = Qot_RequestHistoryKL.C2S(; 
        rehabType = Int32(rehab_type), klType = Int32(kl_type),
        security = security, beginTime = begin_str, endTime = end_str,
        maxAckKLNum = max_count === nothing ? Int32(0) : Int32(max_count),
        needKLFieldsFlag = need_fields_flag === nothing ? Int64(0) : Int64(need_fields_flag),
        nextReqKey = next_req_key, extendedTime = extended_time,
        session = session === nothing ? Int32(0) : Int32(session)
    )

    req = Qot_RequestHistoryKL.Request(; c2s = c2s)
    resp = Client.api_request(client, UInt32(QOT_REQUEST_HISTORY_KL), req, PROTO_RESPONSE_MAP[UInt32(QOT_REQUEST_HISTORY_KL)])

    # Use map for type stability
    rows = map(resp.s2c.klList) do item
        (
            time = item.time,
            is_blank = item.isBlank,
            high = item.highPrice,
            open = item.openPrice,
            low = item.lowPrice,
            close = item.closePrice,
            last_close = item.lastClosePrice,
            volume = item.volume,
            turnover = item.turnover,
            turnover_rate = item.turnoverRate,
            pe = item.pe,
            change_rate = item.changeRate
        )
    end

    return (
        data = DataFrame(rows),
        next_req_key = resp.s2c.nextReqKey,
        security = resp.s2c.security,
        name = isempty(resp.s2c.name) ? missing : resp.s2c.name
    )
end

# 获取复权因子 - optimized with typed rows
function get_rehab(client::OpenDClient, code::String; market::QotMarket.T = QotMarket.HK_Security)
    security = Qot_Common.Security(Int(market), code)

    req = Qot_RequestRehab.Request(; c2s = Qot_RequestRehab.C2S(; security = security))
    resp = Client.api_request(client, UInt32(QOT_REQUEST_REHAB), req, PROTO_RESPONSE_MAP[UInt32(QOT_REQUEST_REHAB)])

    ratio(base, ert) = base == 0 ? missing : ert / base

    # Use map with all fields pre-defined (missing for non-applicable fields)
    rows = map(resp.s2c.rehabList) do item
        has_flag(flag) = (item.companyActFlag & Int64(flag)) != 0

        (
            time = item.time,
            timestamp = item.timestamp,
            company_act_flag = item.companyActFlag,
            fwd_factor_a = item.fwdFactorA,
            fwd_factor_b = item.fwdFactorB,
            bwd_factor_a = item.bwdFactorA,
            bwd_factor_b = item.bwdFactorB,
            # Split fields
            split_base = has_flag(CompanyAct.Split) ? item.splitBase : missing,
            split_ert = has_flag(CompanyAct.Split) ? item.splitErt : missing,
            split_ratio = has_flag(CompanyAct.Split) ? ratio(item.splitBase, item.splitErt) : missing,
            # Join fields
            join_base = has_flag(CompanyAct.Join) ? item.joinBase : missing,
            join_ert = has_flag(CompanyAct.Join) ? item.joinErt : missing,
            join_ratio = has_flag(CompanyAct.Join) ? ratio(item.joinBase, item.joinErt) : missing,
            # Bonus fields
            bonus_base = has_flag(CompanyAct.Bonus) ? item.bonusBase : missing,
            bonus_ert = has_flag(CompanyAct.Bonus) ? item.bonusErt : missing,
            bonus_ratio = has_flag(CompanyAct.Bonus) ? ratio(item.bonusBase, item.bonusErt) : missing,
            # Transfer fields
            transfer_base = has_flag(CompanyAct.Transfer) ? item.transferBase : missing,
            transfer_ert = has_flag(CompanyAct.Transfer) ? item.transferErt : missing,
            transfer_ratio = has_flag(CompanyAct.Transfer) ? ratio(item.transferBase, item.transferErt) : missing,
            # Allot fields
            allot_base = has_flag(CompanyAct.Allot) ? item.allotBase : missing,
            allot_ert = has_flag(CompanyAct.Allot) ? item.allotErt : missing,
            allot_ratio = has_flag(CompanyAct.Allot) ? ratio(item.allotBase, item.allotErt) : missing,
            allot_price = has_flag(CompanyAct.Allot) ? item.allotPrice : missing,
            # Add fields
            add_base = has_flag(CompanyAct.Add) ? item.addBase : missing,
            add_ert = has_flag(CompanyAct.Add) ? item.addErt : missing,
            add_ratio = has_flag(CompanyAct.Add) ? ratio(item.addBase, item.addErt) : missing,
            add_price = has_flag(CompanyAct.Add) ? item.addPrice : missing,
            # Dividend fields
            dividend = has_flag(CompanyAct.Dividend) ? item.dividend : missing,
            sp_dividend = has_flag(CompanyAct.SPDividend) ? item.spDividend : missing,
            # SpinOff fields
            spin_off_base = has_flag(CompanyAct.SpinOff) ? item.spinOffBase : missing,
            spin_off_ert = has_flag(CompanyAct.SpinOff) ? item.spinOffErt : missing,
            spin_off_ratio = has_flag(CompanyAct.SpinOff) ? ratio(item.spinOffBase, item.spinOffErt) : missing
        )
    end

    df = DataFrame(rows)

    # Drop columns where all values are missing
    cols_to_drop = Symbol[]
    for col_name in names(df)
        if all(ismissing, df[!, col_name])
            push!(cols_to_drop, Symbol(col_name))
        end
    end

    if !isempty(cols_to_drop)
        select!(df, Not(cols_to_drop))
    end

    return df
end

"""
    get_history_kl_quota(client::OpenDClient; get_detail::Bool = false)

Get historical K-line quota usage details.

# Keyword Arguments
- `get_detail::Bool = false`: Whether to return detailed historical pull records

# Returns
- `NamedTuple` with the following fields:
  - `used_quota`: Number of stocks already downloaded in the current cycle
  - `remain_quota`: Remaining quota
  - `detail_list`: DataFrame with detailed pull history (only if `get_detail=true`)
    - `code`: Security code with market prefix
    - `name`: Security name
    - `request_time`: Pull time string (format: "yyyy-MM-dd HH:mm:ss")
    - `request_timestamp`: Pull timestamp as DateTime

# Notes
- Protocol ID: 3104
- Quota allocation is based on your account assets and trading activity
- Within 30 days, you can only download historical K-line data for a limited number of stocks
- Quota consumed today will be automatically released after 30 days
- The `detail_list` may be empty even when `used_quota > 0`, as the API may not persist all historical records
- See official documentation for detailed quota rules

# Historical K-line Quota Rules
Historical K-line quota is allocated based on:
1. **Account Assets**: Higher assets = more quota
2. **Trading Activity**: Active trading = more quota
3. **30-Day Rolling Window**: Quota consumed is released after 30 days

# Example
```julia
# Check quota without details
quota = get_history_kl_quota(client)
println("Used: \$(quota.used_quota), Remaining: \$(quota.remain_quota)")

# Check quota with details (if available from server)
quota_detail = get_history_kl_quota(client; get_detail=true)
if !isempty(quota_detail.detail_list)
    println(quota_detail.detail_list)
end
```
"""
function get_history_kl_quota(client::OpenDClient; get_detail::Bool = false)
    # Build C2S request
    c2s = Qot_RequestHistoryKLQuota.C2S(bGetDetail = get_detail)

    # Create request and send
    req = Qot_RequestHistoryKLQuota.Request(c2s = c2s)
    resp = Client.api_request(client, UInt32(QOT_REQUEST_HISTORY_KL_QUOTA), req, PROTO_RESPONSE_MAP[UInt32(QOT_REQUEST_HISTORY_KL_QUOTA)])

    # Parse response
    s2c = resp.s2c

    # Build detail list if requested - use map for type stability
    detail_df = if get_detail && !isempty(s2c.detailList)
        rows = map(s2c.detailList) do detail_item
            security = detail_item.security
            code = string(QotMarket.T(security.market), ".", security.code)

            (
                code = code,
                name = detail_item.name,
                request_time = detail_item.requestTime,
                request_timestamp = unix2datetime(detail_item.requestTimeStamp)
            )
        end
        DataFrame(rows)
    else
        DataFrame()  # Empty DataFrame if no detail requested
    end

    return (used_quota = Int(s2c.usedQuota), remain_quota = Int(s2c.remainQuota), detail_list = detail_df)
end

end # module Quote
