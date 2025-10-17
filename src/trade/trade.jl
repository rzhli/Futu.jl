module Trade

    using DataFrames
    using Dates
    using MD5

    using ..Client
    using ..PushCallbacks
    using ..Constants:
        # 协议 ID
        TRD_UNLOCK_TRADE, TRD_GET_ACC_LIST, TRD_GET_FUNDS, TRD_GET_MAX_TRD_QTYS,
        TRD_GET_ORDER_FILL_LIST, TRD_GET_POSITION_LIST, TRD_GET_MARGIN_RATIO, TRD_GET_FLOW_SUMMARY,
        TRD_PLACE_ORDER, TRD_MODIFY_ORDER, TRD_GET_ORDER_LIST, TRD_GET_HISTORY_ORDER_LIST,
        TRD_GET_HISTORY_ORDER_FILL_LIST, TRD_GET_ORDER_FEE, TRD_SUB_ACC_PUSH,
        TRD_UPDATE_ORDER, TRD_UPDATE_ORDER_FILL,
        # 协议模块
        Trd_GetAccList, Trd_UnlockTrade, Trd_GetFunds, Trd_GetMaxTrdQtys, Trd_FlowSummary,
        Trd_GetOrderFillList, Trd_GetPositionList, Trd_GetMarginRatio,
        Trd_PlaceOrder, Trd_ModifyOrder, Trd_GetOrderList, Trd_GetHistoryOrderList,
        Trd_GetHistoryOrderFillList, Trd_GetOrderFee, Trd_SubAccPush,
        # 通用模块
        Trd_Common, Qot_Common, Common,
        # 枚举类型
        TrdEnv, TrdMarket, TrdAccType, Currency, SecurityFirm, TrdSide, OrderType, OrderStatus,
        TrdSecMarket, TimeInForce, TrailType, ModifyOrderOp, PositionSide, OrderFillStatus,
        SimAccType, TrdAccStatus, TrdCategory, TrdCashFlowDirection, Session,
        CltRiskLevel, CltRiskStatus, DTStatus

    export TradeClient, get_account_list, unlock_trade, lock_trade
    export get_funds, get_max_trd_qtys, get_position_list, get_margin_ratio, get_account_cash_flow
    export place_order, modify_order, get_order_list, get_history_order_list
    export get_order_fee, get_order_fill_list, get_history_order_fill_list, cancel_all_orders
    export update_order, update_order_fill, subscribe_trade_push, unsubscribe_trade_push

    struct TradeClient
        client::OpenDClient
        trd_env::TrdEnv.T
        acc_id::Union{String, Nothing}
        acc_type::TrdAccType.T

        function TradeClient(host::String="127.0.0.1", port::Int = 11111; trd_env::TrdEnv.T = TrdEnv.Simulate, acc_type::TrdAccType.T = TrdAccType.Cash, rsa_private_key_path::String = "")
            client = OpenDClient(host = host, port = port, rsa_private_key_path = rsa_private_key_path)
            new(client, trd_env, nothing, acc_type)
        end
    end

    function Base.show(io::IO, tc::TradeClient)
        println(io, "TradeClient:")
        println(io, "  Client Details:")
        println(io, "    id: ", tc.client.client_id)
        println(io, "    ver: ", tc.client.client_ver)
        println(io, "    connected: ", is_connected(tc.client))
        println(io, "  Trade Details:")
        println(io, "    trd_env: ", tc.trd_env)
        println(io, "    acc_id: ", isnothing(tc.acc_id) ? "Not set" : tc.acc_id)
        print(io, "    acc_type: ", tc.acc_type)
    end

    function unlock_trade(tc::TradeClient, password::String; is_md5::Bool = false, security_firm::SecurityFirm.T = SecurityFirm.FutuSecurities)

        pwd_md5 = if is_md5
            lowercase(password)
        else
            bytes2hex(md5(password))
        end

        c2s = Trd_UnlockTrade.C2S(unlock = true, pwdMD5 = pwd_md5, securityFirm = Int32(security_firm))
        req = Trd_UnlockTrade.Request(c2s=c2s)

        response = Client.api_request(tc.client, UInt32(TRD_UNLOCK_TRADE), req, Trd_UnlockTrade.Response)
        return (response.retType, response.retMsg)
    end

    function lock_trade(tc::TradeClient; security_firm::SecurityFirm.T = SecurityFirm.FutuSecurities)
        c2s = Trd_UnlockTrade.C2S(unlock = false, pwdMD5 = "", securityFirm = Int32(security_firm))
        req = Trd_UnlockTrade.Request(c2s=c2s)

        response = Client.api_request(tc.client, UInt32(TRD_UNLOCK_TRADE), req, Trd_UnlockTrade.Response)
        return (response.retType, response.retMsg)
    end

    # Get the list of trading accounts
    function get_account_list(client::OpenDClient; trd_category::Union{TrdCategory.T, Nothing} = nothing, need_general_sec_account::Bool = false)
        """
        Get a list of trading accounts

        Parameters:
        - client: OpenDClient instance
        - trd_category: Transaction Category (optional) - TrdCategory.T enum
        - need_general_sec_account: Whether to return general securities accounts (for HK/US/SG/AU universal accounts)

        Returns:
        - DataFrame with account information including:
            - acc_id: Account ID
            - trd_env: Trading environment (real/simulate)
            - acc_type: Account type (cash/margin)
            - card_num: Card number
            - security_firm: Security firm
            - trd_market_auth: Trading market permissions
        """

        trdCategory = isnothing(trd_category) ? Int32(0) : Int32(trd_category)
        # Build request object
        c2s = Trd_GetAccList.C2S(userID = UInt64(0), trdCategory = trdCategory, needGeneralSecAccount = need_general_sec_account)
        req = Trd_GetAccList.Request(c2s=c2s)

        resp = Client.api_request(client, UInt32(TRD_GET_ACC_LIST), req, Trd_GetAccList.Response)
        data = resp.s2c.accList

        # Collect rows as named tuples
        rows = map(data) do acc
            trd_env_str = string(TrdEnv.T(acc.trdEnv))
            acc_type_str = string(TrdAccType.T(acc.accType))
            security_firm_str = string(SecurityFirm.T(acc.securityFirm))

            # Parse trading market auth list
            trd_markets = [string(TrdMarket.T(market)) for market in acc.trdMarketAuthList]

            sim_acc_type_str = string(SimAccType.T(acc.simAccType))
            acc_status_str = string(TrdAccStatus.T(acc.accStatus))

            (
                acc_id = acc.accID,
                trd_env = trd_env_str,
                acc_type = acc_type_str,
                card_num = acc.cardNum,
                security_firm = security_firm_str,
                trd_market_auth = trd_markets,
                sim_acc_type = sim_acc_type_str,
                acc_status = acc_status_str
            )
        end

        # Create DataFrame from rows
        return DataFrame(rows)
    end

    # Get account funds
    function get_funds(client::OpenDClient, acc_id::Int64, trd_env::TrdEnv.T; refresh_cache::Bool = false, currency::Union{Currency.T, Nothing} = nothing, trd_market::TrdMarket.T = TrdMarket.HK)
        """
        Query fund data of trading account

        Parameters:
        - client: OpenDClient instance
        - acc_id: Account ID
        - trd_env: Trading environment (TRD_ENV_REAL or TRD_ENV_SIMULATE)
        - refresh_cache: Force update cache from server (default: false)
        - currency: Currency.T type (required for universal/futures accounts)
        - trd_market: Trading market (optional)

        Returns:
        - Trd_Common.Funds structure with comprehensive fund information including:
            - Asset overview (power, total assets, cash, market value)
            - Cash details (frozen, available for withdrawal)
            - Buying power (long, short, cash power)
            - P&L information (unrealized/realized)
            - Margin information
            - Risk management status
            - Day trading information (for US accounts)
            - Asset breakdown by type
            - Cash info by currency (for futures)
            - Assets by market (for universal accounts)

        Note:
        - Limited to 10 requests per 30 seconds per account ID
        - Only limited when refresh_cache is true
        - The returned Funds structure will display with colored formatting
        """

        header = Trd_Common.TrdHeader(trdEnv = Int32(trd_env), accID = UInt64(acc_id), trdMarket = Int32(trd_market))
        currency_val = isnothing(currency) ? Int32(0) : Int32(currency)

        c2s = Trd_GetFunds.C2S(header = header, refreshCache = refresh_cache, currency = currency_val)
        req = Trd_GetFunds.Request(c2s = c2s)

        resp = Client.api_request(client, UInt32(TRD_GET_FUNDS), req, Trd_GetFunds.Response)

        # Return the Funds structure directly - it will be displayed with colored formatting
        return resp.s2c.funds
    end

    # Get maximum tradable quantities
    function get_max_trd_qtys(client::OpenDClient, acc_id::Int64, trd_env::TrdEnv.T, code::String, price::Float64, order_type::OrderType.T;
        order_id::Union{Int64, Nothing} = nothing, order_id_ex::Union{String, Nothing} = nothing, adjust_price::Bool = false,
        adjust_side_and_limit::Float64 = 0.0, sec_market::TrdSecMarket.T = TrdSecMarket.HK, trd_market::TrdMarket.T = TrdMarket.HK,
        session::Union{Session.T, Nothing} = nothing
        )
        """
        Query the maximum quantity that can be bought or sold

        Parameters:
        - client: OpenDClient instance
        - acc_id: Account ID
        - trd_env: Trading environment
        - code: Stock code (5 digits for HK, 6 digits for A-shares)
        - price: Price (3 decimal places for securities, 9 for futures)
        - order_type: Order type
        - order_id: Order ID (for modifying existing order)
        - order_id_ex: Server order ID (alternative to order_id)
        - adjust_price: Whether to adjust illegal price
        - adjust_side_and_limit: Adjustment direction and range limit (%)
        - sec_market: Security market
        - trd_market: Trading market
        - session: US stock session

        Returns:
        - NamedTuple with maximum tradable quantities:
            - max_cash_buy: Maximum quantity buyable with cash
            - max_cash_and_margin_buy: Maximum quantity buyable with margin
            - max_position_sell: Maximum quantity sellable from position
            - max_sell_short: Maximum quantity for short selling
            - max_buy_back: Quantity needed to close short position
            - long_required_im: Initial margin change for buying one contract
            - short_required_im: Initial margin change for selling one contract

        Note:
        - Limited to 10 requests per 30 seconds per account ID
        - Cash accounts don't support options trading
        """

        inferred_trd_market = isnothing(trd_market) ? begin
            if sec_market == TrdSecMarket.HK
                TrdMarket.HK
            elseif sec_market == TrdSecMarket.US
                TrdMarket.US
            elseif sec_market == TrdSecMarket.CN_SH || sec_market == TrdSecMarket.CN_SZ
                TrdMarket.CN
            else
                TrdMarket.Unknown
            end
        end : trd_market

        header = Trd_Common.TrdHeader(trdEnv = Int32(trd_env), accID = UInt64(acc_id), trdMarket = Int32(inferred_trd_market))

        c2s = Trd_GetMaxTrdQtys.C2S(
            header = header, orderType = Int32(order_type), code = code, price = price,
            orderID = isnothing(order_id) ? UInt64(0) : UInt64(order_id),
            adjustPrice = adjust_price, adjustSideAndLimit = adjust_side_and_limit,
            secMarket = Int32(sec_market),
            orderIDEx = isnothing(order_id_ex) ? "" : order_id_ex,
            session = isnothing(session) ? Int32(0) : Int32(session)
        )

        req = Trd_GetMaxTrdQtys.Request(c2s = c2s)
        resp = Client.api_request(client, UInt32(TRD_GET_MAX_TRD_QTYS), req, Trd_GetMaxTrdQtys.Response)

        qtys_data = resp.s2c.maxTrdQtys

        # Parse and format the max tradable quantities
        return (
            max_cash_buy = qtys_data.maxCashBuy,
            max_cash_and_margin_buy = qtys_data.maxCashAndMarginBuy,
            max_position_sell = qtys_data.maxPositionSell,
            max_sell_short = qtys_data.maxSellShort,
            max_buy_back = qtys_data.maxBuyBack,
            long_required_im = qtys_data.longRequiredIM,
            short_required_im = qtys_data.shortRequiredIM
        )
    end

    # Get position list
    function get_position_list(client::OpenDClient, acc_id::Int64, trd_env::TrdEnv.T; code_list::Union{Vector{String}, Nothing} = nothing,
        id_list::Union{Vector{Int64}, Nothing} = nothing, begin_time::Union{String, Nothing} = nothing, end_time::Union{String, Nothing} = nothing,
        filter_pl_ratio_min::Union{Float64, Nothing} = nothing, filter_pl_ratio_max::Union{Float64, Nothing} = nothing,
        refresh_cache::Bool = false, trd_market::TrdMarket.T = TrdMarket.HK
        )
        """
        Query the holding position list of a trading account

        Parameters:
        - client: OpenDClient instance
        - acc_id: Account ID
        - trd_env: Trading environment
        - code_list: Filter by stock codes (optional)
        - id_list: Filter by position IDs (optional)
        - begin_time: Start time filter (format: "YYYY-MM-DD HH:MM:SS")
        - end_time: End time filter (format: "YYYY-MM-DD HH:MM:SS")
        - filter_pl_ratio_min: Minimum P/L ratio filter
        - filter_pl_ratio_max: Maximum P/L ratio filter
        - refresh_cache: Force refresh from server
        - trd_market: Trading market

        Returns:
        - DataFrame with position information including:
            - position_id: Position ID
            - position_side: Position direction (LONG/SHORT)
            - code: Stock code
            - name: Stock name
            - qty: Holding quantity
            - can_sell_qty: Available quantity
            - price: Current market price
            - cost_price: Average cost price
            - val: Market value
            - pl_val: Profit/Loss amount
            - pl_ratio: Profit/Loss ratio
            - And more fields...

        Note:
        - Limited to 10 requests per 30 seconds per account ID
        - Only limited when refresh_cache is true
        """

        header = Trd_Common.TrdHeader(trdEnv = Int32(trd_env), accID = UInt64(acc_id), trdMarket = Int32(trd_market))

        # Build filter conditions
        filter_conditions = Trd_Common.TrdFilterConditions(codeList = isnothing(code_list) ? String[] : code_list, idList = isnothing(id_list) ? UInt64[] : UInt64.(id_list),
            beginTime = isnothing(begin_time) ? "" : begin_time, endTime = isnothing(end_time) ? "" : end_time
        )

        c2s = Trd_GetPositionList.C2S(header = header, filterConditions = filter_conditions, filterPLRatioMin = isnothing(filter_pl_ratio_min) ? 0.0 : filter_pl_ratio_min,
            filterPLRatioMax = isnothing(filter_pl_ratio_max) ? 0.0 : filter_pl_ratio_max, refreshCache = refresh_cache
        )

        req = Trd_GetPositionList.Request(c2s = c2s)
        resp = Client.api_request(client, UInt32(TRD_GET_POSITION_LIST), req, Trd_GetPositionList.Response)

        if isempty(resp.s2c.positionList)
            return DataFrame()  # Return empty DataFrame if no positions
        end

        position_data = resp.s2c.positionList

        # Convert to DataFrame
        rows = map(position_data) do pos
            (
                position_id = pos.positionID,
                position_side = string(PositionSide.T(pos.positionSide)),
                code = pos.code,
                name = pos.name,
                qty = pos.qty,
                can_sell_qty = pos.canSellQty,
                price = pos.price,
                cost_price = pos.costPrice,
                val = pos.val,
                pl_val = pos.plVal,
                pl_ratio = pos.plRatio,
                sec_market = string(TrdSecMarket.T(pos.secMarket)),
                td_pl_val = pos.td_plVal,
                td_trd_val = pos.td_trdVal,
                td_buy_val = pos.td_buyVal,
                td_buy_qty = pos.td_buyQty,
                td_sell_val = pos.td_sellVal,
                td_sell_qty = pos.td_sellQty,
                unrealized_pl = pos.unrealizedPL,
                realized_pl = pos.realizedPL,
                currency = string(Currency.T(pos.currency)),
                trd_market = string(TrdMarket.T(pos.trdMarket)),
                diluted_cost_price = pos.dilutedCostPrice,
                average_cost_price = pos.averageCostPrice,
                average_pl_ratio = pos.averagePlRatio
            )
        end

        return DataFrame(rows)
    end

    # Get margin ratio
    function get_margin_ratio(client::OpenDClient, acc_id::Int64, trd_env::TrdEnv.T; security_list::Vector{String} = String[], trd_market::TrdMarket.T = TrdMarket.HK)
        """
        Query account margin data (for margin accounts)

        Parameters:
        - client: OpenDClient instance
        - acc_id: Account ID
        - trd_env: Trading environment
        - security_list: List of stock codes (max 100)
        - trd_market: Trading market

        Returns:
        - DataFrame with margin information including:
            - code: Stock code
            - is_long_permit: Whether long position is allowed
            - is_short_permit: Whether short selling is allowed
            - short_pool_remain: Remaining shares available for short
            - short_fee_rate: Short selling annual interest rate (%)
            - alert_long_ratio: Long alert ratio (%)
            - alert_short_ratio: Short alert ratio (%)
            - im_long_ratio: Long initial margin ratio (%)
            - im_short_ratio: Short initial margin ratio (%)
            - mcm_long_ratio: Long liquidation margin ratio (%)
            - mcm_short_ratio: Short liquidation margin ratio (%)
            - mm_long_ratio: Long maintenance margin ratio (%)
            - mm_short_ratio: Short maintenance margin ratio (%)

        Note:
        - Only available for margin accounts
        - Request frequency limit: 10 requests per 30 seconds
        - Maximum 100 securities per request
        """

        # Validate security list size
        if length(security_list) > 100
            throw(ArgumentError("Maximum 100 securities per request, got $(length(security_list))"))
        end

        header = Trd_Common.TrdHeader(trdEnv = Int32(trd_env), accID = UInt64(acc_id), trdMarket = Int32(trd_market))

        # Map TrdMarket to QotMarket for Security objects
        qot_market = if trd_market == TrdMarket.HK
            Int32(Qot_Common.QotMarket.HK_Security)
        elseif trd_market == TrdMarket.US
            Int32(Qot_Common.QotMarket.US_Security)
        elseif trd_market == TrdMarket.CN
            # Default to Shanghai for CN market, could be enhanced to detect based on code
            Int32(Qot_Common.QotMarket.CNSH_Security)
        else
            Int32(0)  # Unknown
        end

        # Build security list as proto objects with proper market
        sec_list = [Qot_Common.Security(market = qot_market, code = code) for code in security_list]

        c2s = Trd_GetMarginRatio.C2S(header = header, securityList = sec_list)

        req = Trd_GetMarginRatio.Request(c2s = c2s)
        resp = Client.api_request(client, UInt32(TRD_GET_MARGIN_RATIO), req, Trd_GetMarginRatio.Response)

        if isempty(resp.s2c.marginRatioInfoList)
            return DataFrame()  # Return empty DataFrame if no data
        end

        margin_data = resp.s2c.marginRatioInfoList

        # Convert to DataFrame
        rows = map(margin_data) do item
            (
                code = item.security.code,
                is_long_permit = item.isLongPermit,
                is_short_permit = item.isShortPermit,
                short_pool_remain = item.shortPoolRemain,
                short_fee_rate = item.shortFeeRate,
                alert_long_ratio = item.alertLongRatio,
                alert_short_ratio = item.alertShortRatio,
                im_long_ratio = item.imLongRatio,
                im_short_ratio = item.imShortRatio,
                mcm_long_ratio = item.mcmLongRatio,
                mcm_short_ratio = item.mcmShortRatio,
                mm_long_ratio = item.mmLongRatio,
                mm_short_ratio = item.mmShortRatio
            )
        end

        return DataFrame(rows)
    end

    # Get account cash flow summary
    function get_account_cash_flow(client::OpenDClient, acc_id::Int64, trd_env::TrdEnv.T, clearing_date::String;
        cash_flow_direction::Union{TrdCashFlowDirection.T, Nothing} = nothing, trd_market::TrdMarket.T = TrdMarket.HK
        )
        """
        Query the cash flow list of a trading account on a specified date

        Parameters:
        - client: OpenDClient instance
        - acc_id: Account ID
        - trd_env: Trading environment
        - clearing_date: Clearing date (format: "YYYY-MM-DD", e.g., "2017-05-20")
        - cash_flow_direction: Cash flow direction filter (IN/OUT)
        - trd_market: Trading market

        Returns:
        - DataFrame with cash flow information including:
            - flow_type: Transaction type description
            - business_type: Business type code
            - flow_amount: Cash flow amount (positive=in, negative=out)
            - currency: Currency.T type
            - exchange_rate: Exchange rate
            - flow_time: Transaction time
            - description: Transaction description
            - is_deposit: Whether it's a deposit
            - is_withdrawal: Whether it's a withdrawal
            - stock_code: Related stock code (if applicable)
            - stock_name: Related stock name (if applicable)
            - quantity: Transaction quantity (if applicable)
            - price: Transaction price (if applicable)

        Note:
        - Limited to 20 requests per 30 seconds per account ID
        - Cannot query cash flow through paper trading accounts
        - Results are arranged in chronological order
        """

        header = Trd_Common.TrdHeader(trdEnv = Int32(trd_env), accID = UInt64(acc_id), trdMarket = Int32(trd_market))

        c2s = Trd_FlowSummary.C2S(header = header, clearingDate = clearing_date, cashFlowDirection = isnothing(cash_flow_direction) ? Int32(0) : Int32(cash_flow_direction))

        req = Trd_FlowSummary.Request(c2s = c2s)
        resp = Client.api_request(client, UInt32(TRD_GET_FLOW_SUMMARY), req, Trd_FlowSummary.Response)

        if isempty(resp.s2c.flowSummaryInfoList)
            return DataFrame()  # Return empty DataFrame if no data
        end

        flow_data = resp.s2c.flowSummaryInfoList

        # Convert to DataFrame
        rows = map(flow_data) do item
            (
                flow_type = item.cashFlowType,
                business_type = string(TrdCashFlowDirection.T(item.cashFlowDirection)),
                flow_amount = item.cashFlowAmount,
                currency = string(Currency.T(item.currency)),
                exchange_rate = 1.0,  # Not in FlowSummaryInfo proto
                flow_time = item.clearingDate,
                description = item.cashFlowRemark,
                is_deposit = item.cashFlowDirection == Int32(TrdCashFlowDirection.TrdCashFlowDirection_In),
                is_withdrawal = item.cashFlowDirection == Int32(TrdCashFlowDirection.TrdCashFlowDirection_Out),
                stock_code = "",
                stock_name = "",
                quantity = 0.0,
                price = 0.0
            )
        end

        return DataFrame(rows)
    end
 
    # Place an order
    function place_order(client::OpenDClient, acc_id::Int64, trd_env::TrdEnv.T, code::String, sec_market::TrdSecMarket.T, trd_side::TrdSide.T, order_type::OrderType.T, qty::Float64;
        price::Union{Float64, Nothing} = nothing, adjust_price::Bool = false, adjust_side_and_limit::Float64 = 0.0, remark::String = "", time_in_force::Union{TimeInForce.T, Nothing} = nothing, 
        fill_outside_rth::Bool = false, aux_price::Union{Float64, Nothing} = nothing, trail_type::Union{TrailType.T, Nothing} = nothing, trail_value::Union{Float64, Nothing} = nothing, 
        trail_spread::Union{Float64, Nothing} = nothing, session::Union{Session.T, Nothing} = nothing, trd_market::Union{TrdMarket.T, Nothing} = nothing
        )
        """
        Place a trading order

        Parameters:
        - client: OpenDClient instance
        - acc_id: Account ID
        - trd_env: Trading environment
        - code: Stock code (5 decimals for HK, 6 for A-shares, no limit for US)
        - trd_side: Trading direction (BUY, SELL, SELL_SHORT, BUY_BACK)
        - order_type: Order type (NORMAL, MARKET, LIMIT, STOP, etc.)
        - qty: Quantity (3 decimals for securities, 9 for futures)
        - sec_market: Security market (required)
        - price: Price (optional for market orders, 0 decimal accuracy)
        - adjust_price: Whether to adjust illegal price to legal price
        - adjust_side_and_limit: Adjustment direction and limit (% as decimal)
        - remark: User remark (max 64 bytes)
        - time_in_force: Order validity (DAY, GTC, GTD, IOC, FOK)
        - fill_outside_rth: Allow pre/post-market trade (US stocks only)
        - aux_price: Trigger price for stop orders
        - trail_type: Trailing type (RATIO or AMOUNT)
        - trail_value: Trailing amount or ratio
        - trail_spread: Specified spread for trailing orders
        - session: US stock session (RTH, ETH, ALL, OVERNIGHT)
        - trd_market: Trading market

        Returns:
        - NamedTuple with order_id and order_id_ex (服务器订单id)

        Note:
        - Limited to 15 requests per 30 seconds per account ID
        - Minimum 0.02 seconds between consecutive requests
        - Live accounts need unlock_trade, paper accounts don't
        - US stocks 24-hour trading only supports limit orders
        """

        inferred_trd_market = isnothing(trd_market) ? begin
            if sec_market == TrdSecMarket.HK
                TrdMarket.HK
            elseif sec_market == TrdSecMarket.US
                TrdMarket.US
            elseif sec_market == TrdSecMarket.CN_SH || sec_market == TrdSecMarket.CN_SZ
                TrdMarket.CN
            else
                TrdMarket.Unknown
            end
        end : trd_market

        header = Trd_Common.TrdHeader(trdEnv = Int32(trd_env), accID = UInt64(acc_id), trdMarket = Int32(inferred_trd_market))

        # Generate packet ID for replay protection (use only lower 32 bits of timestamp)
        packet_id = Common.PacketID(client.connection.conn_id, UInt32(trunc(UInt64, time() * 1000) & 0xffffffff))

        # Convert security market to Int32
        sec_market_val = Int32(sec_market)

        c2s = Trd_PlaceOrder.C2S(packetID = packet_id, header = header, trdSide = Int32(trd_side), orderType = Int32(order_type),
            code = code, qty = qty, price = isnothing(price) ? 0.0 : price, adjustPrice = adjust_price, adjustSideAndLimit = adjust_side_and_limit,
            secMarket = sec_market_val, remark = remark[1:min(64, length(remark))], timeInForce = isnothing(time_in_force) ? Int32(0) : Int32(time_in_force),
            fillOutsideRTH = fill_outside_rth, auxPrice = isnothing(aux_price) ? 0.0 : aux_price, trailType = isnothing(trail_type) ? Int32(0) : Int32(trail_type),
            trailValue = isnothing(trail_value) ? 0.0 : trail_value, trailSpread = isnothing(trail_spread) ? 0.0 : trail_spread,
            session = isnothing(session) ? Int32(0) : Int32(session)
        )

        req = Trd_PlaceOrder.Request(c2s = c2s)
        resp = Client.api_request(client, UInt32(TRD_PLACE_ORDER), req, Trd_PlaceOrder.Response)

        if resp.retType != 0
            error_msg = resp.retMsg
            throw(Errors.FutuError(resp.retType, error_msg))
        end
        return (order_id = resp.s2c.orderID, order_id_ex = resp.s2c.orderIDEx)
    end

    # Modify order
    function modify_order(client::OpenDClient, acc_id::Int64, trd_env::TrdEnv.T, order_id::UInt64; modify_order_op::ModifyOrderOp.T = ModifyOrderOp.Normal,
        qty::Union{Float64, Nothing} = nothing, price::Union{Float64, Nothing} = nothing, adjust_price::Bool = false, adjust_side_and_limit::Float64 = 0.0,
        aux_price::Union{Float64, Nothing} = nothing, trail_type::Union{TrailType.T, Nothing} = nothing, trail_value::Union{Float64, Nothing} = nothing,
        trail_spread::Union{Float64, Nothing} = nothing, order_id_ex::Union{String, Nothing} = nothing, trd_market::TrdMarket.T = TrdMarket.HK
        )
        """
        Modify an existing order

        Parameters:
        - client: OpenDClient instance
        - acc_id: Account ID
        - trd_env: Trading environment
        - order_id: Order ID (UInt64, pass 0x0 if using order_id_ex or for_all)
        - modify_order_op: Operation type (NORMAL, CANCEL, DISABLE, ENABLE, DELETE)
        - qty: New total quantity (REQUIRED for NORMAL operation, this is the total quantity, not incremental)
        - price: New price (REQUIRED for NORMAL operation)
        - adjust_price: Whether to adjust illegal price to legal price
        - adjust_side_and_limit: Adjustment direction and limit (% as decimal, + for up, - for down)
        - aux_price: New trigger price (for stop orders)
        - trail_type: Trailing type
        - trail_value: Trailing amount/ratio
        - trail_spread: Specified spread
        - order_id_ex: Server order ID (alternative to order_id)
        - trd_market: Trading market

        Returns:
        - NamedTuple with modified order_id

        Note:
        - Limited to 20 requests per 30 seconds per account
        - Minimum 0.04 seconds between consecutive requests
        - For NORMAL operation, BOTH qty and price are REQUIRED - they represent the total new values
        - To partially cancel, use NORMAL with reduced qty
        - To fully cancel, use CANCEL operation
        """

        # Validate parameters for NORMAL operation
        if modify_order_op == ModifyOrderOp.Normal
            if isnothing(qty) || isnothing(price)
                throw(ArgumentError("For ModifyOrderOp.Normal, both qty and price must be provided (these are the total new values, not incremental changes)"))
            end
        end

        header = Trd_Common.TrdHeader(trdEnv = Int32(trd_env), accID = UInt64(acc_id), trdMarket = Int32(trd_market))

        # Generate packet ID for replay protection (use only lower 32 bits of timestamp)
        packet_id = Common.PacketID(client.connection.conn_id, UInt32(trunc(UInt64, time() * 1000) & 0xffffffff))

        c2s = Trd_ModifyOrder.C2S(packetID = packet_id, header = header, orderID = order_id, modifyOrderOp = Int32(modify_order_op),
            forAll = false, trdMarket = Int32(0), qty = isnothing(qty) ? 0.0 : qty, price = isnothing(price) ? 0.0 : price,
            adjustPrice = adjust_price, adjustSideAndLimit = adjust_side_and_limit, auxPrice = isnothing(aux_price) ? 0.0 : aux_price,
            trailType = isnothing(trail_type) ? Int32(0) : Int32(trail_type), trailValue = isnothing(trail_value) ? 0.0 : trail_value,
            trailSpread = isnothing(trail_spread) ? 0.0 : trail_spread, orderIDEx = isnothing(order_id_ex) ? "" : order_id_ex
        )

        req = Trd_ModifyOrder.Request(c2s = c2s)
        resp = Client.api_request(client, UInt32(TRD_MODIFY_ORDER), req, Trd_ModifyOrder.Response)

        if resp.retType != 0
            error_msg = resp.retMsg
            throw(Errors.FutuError(resp.retType, error_msg))
        end

        return (order_id = resp.s2c.orderID, order_id_ex = resp.s2c.orderIDEx)
    end

    # Get open order list
    function get_order_list(client::OpenDClient, acc_id::Int64, trd_env::TrdEnv.T; code_list::Union{Vector{String}, Nothing} = nothing,
        id_list::Union{Vector{Int64}, Nothing} = nothing, begin_time::Union{String, Nothing} = nothing, end_time::Union{String, Nothing} = nothing,
        filter_status_list::Vector{OrderStatus.T} = OrderStatus.T[], refresh_cache::Bool = false, trd_market::TrdMarket.T = TrdMarket.HK
        )
        """
        Query the open order list of the specified trading account

        Parameters:
        - client: OpenDClient instance
        - acc_id: Account ID
        - trd_env: Trading environment (TRD_ENV_REAL or TRD_ENV_SIMULATE)
        - code_list: Filter by stock codes (optional)
        - id_list: Filter by order IDs (optional)
        - begin_time: Start time filter (format: "YYYY-MM-DD HH:MM:SS")
        - end_time: End time filter (format: "YYYY-MM-DD HH:MM:SS")
        - filter_status_list: Order status list to filter
        - refresh_cache: Force refresh from server (default: false)
        - trd_market: Trading market

        Returns:
        - DataFrame with order information including:
            - order_id: Order ID
            - order_id_ex: Server order ID
            - order_type: Order type
            - order_status: Order status
            - trd_side: Trading direction
            - code: Stock code
            - name: Stock name
            - qty: Order quantity
            - price: Order price
            - create_time: Order creation time
            - update_time: Last update time
            - fill_qty: Filled quantity
            - fill_avg_price: Average fill price
            - last_err_msg: Last error message (if any)
            - remark: User remark
            - time_in_force: Order validity
            - fill_outside_rth: Whether allows pre/post-market trading
            - aux_price: Trigger price (for stop orders)
            - trail_type: Trailing type
            - trail_value: Trailing value
            - trail_spread: Trailing spread
            - currency: Currency.T
            - trd_market: Trading market

            Note:
            - Limited to 10 requests per 30 seconds per account ID
            - Only limited when refresh_cache is true
            - Open orders are arranged in chronological order
            """

        header = Trd_Common.TrdHeader(trdEnv = Int32(trd_env), accID = UInt64(acc_id), trdMarket = Int32(trd_market))

        # Build filter conditions
        filter_conditions = Trd_Common.TrdFilterConditions(
            codeList = isnothing(code_list) ? String[] : code_list,
            idList = isnothing(id_list) ? UInt64[] : UInt64.(id_list),
            beginTime = isnothing(begin_time) ? "" : begin_time,
            endTime = isnothing(end_time) ? "" : end_time
        )

        # Build filter status list
        status_list = isempty(filter_status_list) ? Int32[] : Int32.(filter_status_list)

        c2s = Trd_GetOrderList.C2S(header = header, filterConditions = filter_conditions, filterStatusList = status_list, refreshCache = refresh_cache)

        req = Trd_GetOrderList.Request(c2s = c2s)
        resp = Client.api_request(client, UInt32(TRD_GET_ORDER_LIST), req, Trd_GetOrderList.Response)

        if isempty(resp.s2c.orderList)
            return DataFrame()  # Return empty DataFrame if no orders
        end

        order_data = resp.s2c.orderList

        # Convert to DataFrame
        rows = map(order_data) do order
            (
                order_id = order.orderID,
                order_id_ex = order.orderIDEx,
                order_type = string(OrderType.T(order.orderType)),
                order_status = string(OrderStatus.T(order.orderStatus)),
                trd_side = string(TrdSide.T(order.trdSide)),
                code = order.code,
                name = order.name,
                qty = order.qty,
                price = order.price,
                create_time = order.createTime,
                update_time = order.updateTime,
                fill_qty = order.fillQty,
                fill_avg_price = order.fillAvgPrice,
                last_err_msg = order.lastErrMsg,
                sec_market = string(TrdSecMarket.T(order.secMarket)),
                remark = order.remark,
                time_in_force = string(TimeInForce.T(order.timeInForce)),
                fill_outside_rth = order.fillOutsideRTH,
                aux_price = order.auxPrice,
                trail_type = string(TrailType.T(order.trailType)),
                trail_value = order.trailValue,
                trail_spread = order.trailSpread,
                currency = string(Currency.T(order.currency)),
                trd_market = string(TrdMarket.T(order.trdMarket))
            )
        end

        return DataFrame(rows)
    end

    # Get historical order list
    function get_history_order_list(client::OpenDClient, acc_id::Int64, trd_env::TrdEnv.T; code_list::Union{Vector{String}, Nothing} = nothing,
        id_list::Union{Vector{Int64}, Nothing} = nothing, begin_time::Union{String, Nothing} = nothing, end_time::Union{String, Nothing} = nothing,
        filter_status_list::Vector{OrderStatus.T} = OrderStatus.T[], trd_market::TrdMarket.T = TrdMarket.HK
        )
        """
        Query the historical order list of a specified trading account

        Parameters:
        - client: OpenDClient instance
        - acc_id: Account ID
        - trd_env: Trading environment (TRD_ENV_REAL or TRD_ENV_SIMULATE)
        - code_list: Filter by stock codes (optional)
        - id_list: Filter by order IDs (optional)
        - begin_time: Start time filter (format: "YYYY-MM-DD HH:MM:SS", defaults to 90 days ago)
        - end_time: End time filter (format: "YYYY-MM-DD HH:MM:SS", defaults to now)
        - filter_status_list: Order status list to filter
        - trd_market: Trading market

        Returns:
        - DataFrame with historical order information including:
            - order_id: Order ID
            - order_id_ex: Server order ID
            - order_type: Order type
            - order_status: Order status
            - trd_side: Trading direction
            - code: Stock code
            - name: Stock name
            - qty: Order quantity
            - price: Order price
            - create_time: Order creation time
            - update_time: Last update time
            - fill_qty: Filled quantity
            - fill_avg_price: Average fill price
            - last_err_msg: Last error message (if any)
            - remark: User remark
            - time_in_force: Order validity
            - fill_outside_rth: Whether allows pre/post-market trading
            - aux_price: Trigger price (for stop orders)
            - trail_type: Trailing type
            - trail_value: Trailing value
            - trail_spread: Trailing spread
            - currency: Currency.T
            - trd_market: Trading market

        Note:
        - Limited to 10 requests per 30 seconds per account ID
        - Historical orders are arranged in reverse chronological order (newest first)
        - Time range is REQUIRED for historical queries - defaults to last 90 days if not specified
        """

        # Set default time range if not provided (last 90 days)
        actual_begin_time = if isnothing(begin_time)
            Dates.format(Dates.now() - Dates.Day(90), "yyyy-mm-dd HH:MM:SS")
        else
            begin_time
        end

        actual_end_time = if isnothing(end_time)
            Dates.format(Dates.now(), "yyyy-mm-dd HH:MM:SS")
        else
            end_time
        end

        header = Trd_Common.TrdHeader(trdEnv = Int32(trd_env), accID = UInt64(acc_id), trdMarket = Int32(trd_market))

        # Build filter conditions - REQUIRED parameter with time range
        filter_conditions = Trd_Common.TrdFilterConditions(
            codeList = isnothing(code_list) ? String[] : code_list,
            idList = isnothing(id_list) ? UInt64[] : UInt64.(id_list),
            beginTime = actual_begin_time,
            endTime = actual_end_time
        )

        # Build filter status list
        status_list = isempty(filter_status_list) ? Int32[] : Int32.(filter_status_list)

        c2s = Trd_GetHistoryOrderList.C2S(header = header, filterConditions = filter_conditions, filterStatusList = status_list)

        req = Trd_GetHistoryOrderList.Request(c2s = c2s)
        resp = Client.api_request(client, UInt32(TRD_GET_HISTORY_ORDER_LIST), req, Trd_GetHistoryOrderList.Response)

        if isempty(resp.s2c.orderList)
            return DataFrame()  # Return empty DataFrame if no orders
        end

        order_data = resp.s2c.orderList

        # Convert to DataFrame
        rows = map(order_data) do order
            (
                order_id = order.orderID,
                order_id_ex = order.orderIDEx,
                order_type = string(OrderType.T(order.orderType)),
                order_status = string(OrderStatus.T(order.orderStatus)),
                trd_side = string(TrdSide.T(order.trdSide)),
                code = order.code,
                name = order.name,
                qty = order.qty,
                price = order.price,
                create_time = order.createTime,
                update_time = order.updateTime,
                fill_qty = order.fillQty,
                fill_avg_price = order.fillAvgPrice,
                last_err_msg = order.lastErrMsg,
                sec_market = string(TrdSecMarket.T(order.secMarket)),
                remark = order.remark,
                time_in_force = string(TimeInForce.T(order.timeInForce)),
                fill_outside_rth = order.fillOutsideRTH,
                aux_price = order.auxPrice,
                trail_type = string(TrailType.T(order.trailType)),
                trail_value = order.trailValue,
                trail_spread = order.trailSpread,
                currency = string(Currency.T(order.currency)),
                trd_market = string(TrdMarket.T(order.trdMarket))
            )
        end
        return DataFrame(rows)
    end

        # Get today's order fill list (当日成交列表)
    function get_order_fill_list(client::OpenDClient, acc_id::Int64, trd_env::TrdEnv.T; code_list::Union{Vector{String}, Nothing} = nothing,
        id_list::Union{Vector{Int64}, Nothing} = nothing, begin_time::Union{String, Nothing} = nothing, end_time::Union{String, Nothing} = nothing,
        refresh_cache::Bool = false, trd_market::TrdMarket.T = TrdMarket.HK
        )
        """
        Query today's order fill list for a specified trading account

        Parameters:
        - client: OpenDClient instance
        - acc_id: Account ID
        - trd_env: Trading environment (TRD_ENV_REAL or TRD_ENV_SIMULATE)
        - code_list: Filter by stock codes (optional)
        - id_list: Filter by fill IDs (optional)
        - begin_time: Start time filter (format: "YYYY-MM-DD HH:MM:SS")
        - end_time: End time filter (format: "YYYY-MM-DD HH:MM:SS")
        - refresh_cache: Force refresh from server (default: false)
        - trd_market: Trading market

        Returns:
        - DataFrame with order fill information including:
            - fill_id: Fill ID
            - fill_id_ex: Server fill ID
            - order_id: Related order ID
            - order_id_ex: Server order ID
            - code: Stock code
            - name: Stock name
            - trd_side: Trading direction
            - qty: Fill quantity
            - price: Fill price
            - create_time: Fill time
            - counter_broker_id: Counter broker ID
            - counter_broker_name: Counter broker name
            - sec_market: Security market
            - create_timestamp: Creation timestamp
            - update_timestamp: Update timestamp
            - status: Fill status

        Note:
        - Limited to 10 requests per 30 seconds per account ID
        - Only limited when refresh_cache is true
        - This interface only supports real trading, not simulated trading
        - Fills are arranged in chronological order (earliest first)
        """

        header = Trd_Common.TrdHeader(trdEnv = Int32(trd_env), accID = UInt64(acc_id), trdMarket = Int32(trd_market))

        # Build filter conditions
        filter_conditions = Trd_Common.TrdFilterConditions(
            codeList = isnothing(code_list) ? String[] : code_list,
            idList = isnothing(id_list) ? UInt64[] : UInt64.(id_list),
            beginTime = isnothing(begin_time) ? "" : begin_time,
            endTime = isnothing(end_time) ? "" : end_time
        )

        c2s = Trd_GetOrderFillList.C2S(header = header, filterConditions = filter_conditions, refreshCache = refresh_cache)

        req = Trd_GetOrderFillList.Request(c2s = c2s)
        resp = Client.api_request(client, UInt32(TRD_GET_ORDER_FILL_LIST), req, Trd_GetOrderFillList.Response)

        if isempty(resp.s2c.orderFillList)
            return DataFrame()  # Return empty DataFrame if no fills
        end

        fill_data = resp.s2c.orderFillList

        # Convert to DataFrame
        rows = map(fill_data) do fill
            (
                fill_id = fill.fillID,
                fill_id_ex = fill.fillIDEx,
                order_id = fill.orderID,
                order_id_ex = fill.orderIDEx,
                code = fill.code,
                name = fill.name,
                trd_side = string(TrdSide.T(fill.trdSide)),
                qty = fill.qty,
                price = fill.price,
                create_time = fill.createTime,
                counter_broker_id = fill.counterBrokerID,
                counter_broker_name = fill.counterBrokerName,
                sec_market = string(TrdSecMarket.T(fill.secMarket)),
                create_timestamp = fill.createTimestamp,
                update_timestamp = fill.updateTimestamp,
                status = string(OrderFillStatus.T(fill.status))
            )
        end

        return DataFrame(rows)
    end

    # Get historical order fill list (历史成交列表)
    function get_history_order_fill_list(client::OpenDClient, acc_id::Int64, trd_env::TrdEnv.T; code_list::Union{Vector{String}, Nothing} = nothing,
        id_list::Union{Vector{Int64}, Nothing} = nothing, begin_time::Union{String, Nothing} = nothing, end_time::Union{String, Nothing} = nothing,
        trd_market::TrdMarket.T = TrdMarket.HK
        )
        """
        Query historical order fill list for a specified trading account

        Parameters:
        - client: OpenDClient instance
        - acc_id: Account ID
        - trd_env: Trading environment (TRD_ENV_REAL or TRD_ENV_SIMULATE)
        - code_list: Filter by stock codes (optional)
        - id_list: Filter by fill IDs (optional)
        - begin_time: Start time filter (format: "YYYY-MM-DD HH:MM:SS", defaults to 90 days ago)
        - end_time: End time filter (format: "YYYY-MM-DD HH:MM:SS", defaults to now)
        - trd_market: Trading market

        Returns:
        - DataFrame with historical order fill information including:
            - fill_id: Fill ID
            - fill_id_ex: Server fill ID
            - order_id: Related order ID
            - order_id_ex: Server order ID
            - code: Stock code
            - name: Stock name
            - trd_side: Trading direction
            - qty: Fill quantity
            - price: Fill price
            - create_time: Fill time
            - counter_broker_id: Counter broker ID
            - counter_broker_name: Counter broker name
            - sec_market: Security market
            - create_timestamp: Creation timestamp
            - update_timestamp: Update timestamp
            - status: Fill status

        Note:
        - Limited to 10 requests per 30 seconds per account ID
        - This interface only supports real trading, not simulated trading
        - Historical fills are arranged in reverse chronological order (newest first)
        - Time range defaults to last 90 days if not specified
        """

        # Set default time range if not provided (last 90 days)
        actual_begin_time = if isnothing(begin_time)
            Dates.format(Dates.now() - Dates.Day(90), "yyyy-mm-dd HH:MM:SS")
        else
            begin_time
        end

        actual_end_time = if isnothing(end_time)
            Dates.format(Dates.now(), "yyyy-mm-dd HH:MM:SS")
        else
            end_time
        end

        header = Trd_Common.TrdHeader(trdEnv = Int32(trd_env), accID = UInt64(acc_id), trdMarket = Int32(trd_market))

        # Build filter conditions
        filter_conditions = Trd_Common.TrdFilterConditions(
            codeList = isnothing(code_list) ? String[] : code_list,
            idList = isnothing(id_list) ? UInt64[] : UInt64.(id_list),
            beginTime = actual_begin_time,
            endTime = actual_end_time
        )

        c2s = Trd_GetHistoryOrderFillList.C2S(header = header, filterConditions = filter_conditions)

        req = Trd_GetHistoryOrderFillList.Request(c2s = c2s)
        resp = Client.api_request(client, UInt32(TRD_GET_HISTORY_ORDER_FILL_LIST), req, Trd_GetHistoryOrderFillList.Response)

        if isempty(resp.s2c.orderFillList)
            return DataFrame()  # Return empty DataFrame if no fills
        end

        fill_data = resp.s2c.orderFillList

        # Convert to DataFrame
        rows = map(fill_data) do fill
            (
                fill_id = fill.fillID,
                fill_id_ex = fill.fillIDEx,
                order_id = fill.orderID,
                order_id_ex = fill.orderIDEx,
                code = fill.code,
                name = fill.name,
                trd_side = string(TrdSide.T(fill.trdSide)),
                qty = fill.qty,
                price = fill.price,
                create_time = fill.createTime,
                counter_broker_id = fill.counterBrokerID,
                counter_broker_name = fill.counterBrokerName,
                sec_market = string(TrdSecMarket.T(fill.secMarket)),
                create_timestamp = fill.createTimestamp,
                update_timestamp = fill.updateTimestamp,
                status = string(OrderFillStatus.T(fill.status))
            )
        end

        return DataFrame(rows)
    end

     # Get order fee details
    function get_order_fee(client::OpenDClient, acc_id::Int64, trd_env::TrdEnv.T, order_id_ex_list::Vector{String}; trd_market::TrdMarket.T = TrdMarket.HK)
        """
        Get specified orders' fee details

        Parameters:
        - client: OpenDClient instance
        - acc_id: Account ID
        - trd_env: Trading environment (TRD_ENV_REAL or TRD_ENV_SIMULATE)
        - order_id_ex_list: List of server order IDs (orderIDEx)
        - trd_market: Trading market (optional)

        Returns:
        - DataFrame with order fee details including:
            - order_id_ex: Server order ID
            - fee_amount: Total fee amount
            - fee_list: Detailed fee breakdown
                - fee_name: Name of the fee
                - value: Fee value
                - currency: Currency.T of the fee

        Note:
        - Limited to 10 requests per 30 seconds per account ID
        - Only orders after 2018-01-01 are supported
        - Minimum version requirement: 8.2.4218
        """

        # Validate input
        if isempty(order_id_ex_list)
            throw(ArgumentError("Order ID list cannot be empty"))
        end

        header = Trd_Common.TrdHeader(trdEnv = Int32(trd_env), accID = UInt64(acc_id), trdMarket = Int32(trd_market))

        c2s = Trd_GetOrderFee.C2S(header = header, orderIdExList = order_id_ex_list)

        req = Trd_GetOrderFee.Request(c2s = c2s)
        resp = Client.api_request(client, UInt32(TRD_GET_ORDER_FEE), req, Trd_GetOrderFee.Response)

        if isempty(resp.s2c.orderFeeList)
            return DataFrame()  # Return empty DataFrame if no data
        end

        fee_data = resp.s2c.orderFeeList

        # Convert to DataFrame
        rows = map(fee_data) do order_fee
            # Initialize fee values
            commission = 0.0
            platform_fee = 0.0
            trade_fee = 0.0
            clearing_fee = 0.0
            stamp_duty = 0.0
            exchange_fee = 0.0
            transaction_levy = 0.0
            sec_fee = 0.0
            finra_taf = 0.0
            other_fees = 0.0

            # Parse fee list
            fee_details = []
            fee_currency = ""

            if !isempty(order_fee.feeList)
                for fee_item in order_fee.feeList
                    fee_name = fee_item.title
                    fee_value = fee_item.value

                    push!(fee_details, Dict("name" => fee_name, "value" => fee_value, "currency" => ""))

                    # Categorize fees based on common names
                    fee_name_lower = lowercase(fee_name)
                    if occursin("commission", fee_name_lower) || occursin("佣金", fee_name_lower)
                        commission += fee_value
                    elseif occursin("platform", fee_name_lower) || occursin("平台", fee_name_lower)
                        platform_fee += fee_value
                    elseif occursin("trade fee", fee_name_lower) || occursin("交易费", fee_name_lower)
                        trade_fee += fee_value
                    elseif occursin("clearing", fee_name_lower) || occursin("结算", fee_name_lower)
                        clearing_fee += fee_value
                    elseif occursin("stamp", fee_name_lower) || occursin("印花税", fee_name_lower)
                        stamp_duty += fee_value
                    elseif occursin("exchange", fee_name_lower) || occursin("交易所", fee_name_lower)
                        exchange_fee += fee_value
                    elseif occursin("levy", fee_name_lower) || occursin("征费", fee_name_lower)
                        transaction_levy += fee_value
                    elseif occursin("sec", fee_name_lower)
                        sec_fee += fee_value
                    elseif occursin("finra", fee_name_lower) || occursin("taf", fee_name_lower)
                        finra_taf += fee_value
                    else
                        other_fees += fee_value
                    end
                end
            end

            # Calculate total fee
            fee_amount = order_fee.feeAmount
            if fee_amount == 0.0
                # If not provided, calculate from components
                fee_amount = commission + platform_fee + trade_fee + clearing_fee + 
                           stamp_duty + exchange_fee + transaction_levy + sec_fee +
                           finra_taf + other_fees
            end

            (
                order_id_ex = order_fee.orderIDEx,
                fee_amount = fee_amount,
                fee_currency = fee_currency,
                commission = commission,
                platform_fee = platform_fee,
                trade_fee = trade_fee,
                clearing_fee = clearing_fee,
                stamp_duty = stamp_duty,
                exchange_fee = exchange_fee,
                transaction_levy = transaction_levy,
                sec_fee = sec_fee,
                finra_taf = finra_taf,
                other_fees = other_fees,
                fee_details = fee_details
            )
        end

        return DataFrame(rows)
    end
    # Cancel all orders (模拟交易暂不支持)
    function cancel_all_orders(client::OpenDClient, acc_id::Int64, trd_env::TrdEnv.T; trd_market::TrdMarket.T = TrdMarket.HK)
        """
        Cancel all orders for the trading account

        Parameters:
        - client: OpenDClient instance
        - acc_id: Account ID
        - trd_env: Trading environment
        - trd_market: Trading market

        Returns:
        - true if successful

        Note:
        - Batch operations only support canceling all orders
        - Does not support disable all, enable all, or delete all
        """

        header = Trd_Common.TrdHeader(trdEnv = Int32(trd_env), accID = UInt64(acc_id), trdMarket = Int32(trd_market))

        # Generate packet ID for replay protection (use only lower 32 bits of timestamp)
        packet_id = Common.PacketID(client.connection.conn_id, UInt32(trunc(UInt64, time() * 1000) & 0xffffffff))

        # When forAll = true, trdMarket should match the header to cancel all orders for that specific market
        c2s = Trd_ModifyOrder.C2S(packetID = packet_id, header = header, orderID = UInt64(0), modifyOrderOp = Int32(ModifyOrderOp.Cancel),
            forAll = true, trdMarket = Int32(trd_market), qty = 0.0, price = 0.0, adjustPrice = false, adjustSideAndLimit = 0.0, auxPrice = 0.0,
            trailType = Int32(0), trailValue = 0.0, trailSpread = 0.0, orderIDEx = ""
        )

        req = Trd_ModifyOrder.Request(c2s = c2s)
        resp = Client.api_request(client, UInt32(TRD_MODIFY_ORDER), req, Trd_ModifyOrder.Response)

        if resp.retType != 0
            error_msg = resp.retMsg
            throw(Errors.FutuError(resp.retType, error_msg))
        end

        return true
    end

    # Register callback for order updates 响应订单推送回调
    function update_order(client::OpenDClient, callback::Function)
        """
        Register a callback function to receive order update notifications

        Parameters:
        - client: OpenDClient instance
        - callback: Function that accepts a Dict with order update data

        Returns:
        - Nothing

        Callback Data Structure:
        The callback will receive a Dict with the following keys:
        - acc_id: Account ID
        - trd_env: Trading environment ("SIMULATE" or "REAL")
        - trd_market: Trading market ("HK", "US", "CN", etc.)
        - order_id: Order ID
        - order_id_ex: Server order ID
        - order_type: Order type ("NORMAL", "MARKET", "LIMIT", etc.)
        - order_status: Order status ("SUBMITTED", "FILLED", "CANCELLED", etc.)
        - trd_side: Trading side ("BUY", "SELL", "SELL_SHORT", "BUY_BACK")
        - code: Stock code
        - name: Stock name
        - qty: Order quantity
        - price: Order price
        - create_time: Order creation time
        - update_time: Last update time
        - fill_qty: Filled quantity
        - fill_avg_price: Average fill price
        - last_err_msg: Last error message (if any)
        - remark: User remark
        - time_in_force: Order validity
        - fill_outside_rth: Whether pre/post-market trading is allowed
        - aux_price: Trigger price (for stop orders)
        - trail_type: Trailing type
        - trail_value: Trailing value
        - trail_spread: Trailing spread
        - currency: Currency code

        Note:
        - You must subscribe to trade push notifications using subscribe_trade_push first
        - Multiple callbacks can be registered for the same protocol
        - Callbacks are called asynchronously when order updates are received
        """
        PushCallbacks.register_callback(client.callbacks, UInt32(TRD_UPDATE_ORDER), callback)
    end

    # Register callback for order fill updates
    function update_order_fill(client::OpenDClient, callback::Function)
        """
        Register a callback function to receive order fill (deal) notifications

        Parameters:
        - client: OpenDClient instance
        - callback: Function that accepts a Dict with order fill data

        Returns:
        - Nothing

        Callback Data Structure:
        The callback will receive a Dict with the following keys:
        - acc_id: Account ID
        - trd_env: Trading environment ("SIMULATE" or "REAL")
        - trd_market: Trading market ("HK", "US", "CN", etc.)
        - fill_id: Fill ID
        - fill_id_ex: Server fill ID
        - order_id: Related order ID
        - order_id_ex: Server order ID
        - code: Stock code
        - name: Stock name
        - trd_side: Trading side ("BUY", "SELL", "SELL_SHORT", "BUY_BACK")
        - qty: Fill quantity
        - price: Fill price
        - create_time: Fill creation time
        - counter_broker_id: Counter broker ID
        - counter_broker_name: Counter broker name
        - sec_market: Security market
        - create_timestamp: Creation timestamp
        - update_timestamp: Update timestamp
        - status: Fill status ("OK", "CANCELLED", "CHANGED")

        Note:
        - You must subscribe to trade push notifications using subscribe_trade_push first
        - Multiple callbacks can be registered for the same protocol
        - Callbacks are called asynchronously when fill updates are received
        """
        PushCallbacks.register_callback(client.callbacks, UInt32(TRD_UPDATE_ORDER_FILL), callback)
    end

    # Subscribe to trade push notifications
    function subscribe_trade_push(client::OpenDClient, acc_id_list::Vector{Int64})
        """
        Subscribe to receive pushed data from trading accounts

        Parameters:
        - client: OpenDClient instance
        - acc_id_list: List of trading account IDs to subscribe

        Returns:
        - true if subscription successful

        Note:
        - Always pass the full account list
        - Users should pass all trading accounts that need to receive pushed data every time
        - After subscribing, you will receive order updates and fill notifications via callbacks
        """

        # Validate input
        if isempty(acc_id_list)
            throw(ArgumentError("Account ID list cannot be empty"))
        end

        c2s = Trd_SubAccPush.C2S(accIDList = UInt64.(acc_id_list))

        req = Trd_SubAccPush.Request(c2s = c2s)
        resp = Client.api_request(client, UInt32(TRD_SUB_ACC_PUSH), req, Trd_SubAccPush.Response)

        if resp.retType != 0
            error_msg = resp.retMsg
            throw(Errors.FutuError(resp.retType, error_msg))
        end

        return true
    end

    # Unsubscribe from trade push notifications
    function unsubscribe_trade_push(client::OpenDClient)
        """
        Unsubscribe from all trade push notifications

        Parameters:
        - client: OpenDClient instance

        Returns:
        - true if unsubscription successful

        Note:
        - To unsubscribe, pass an empty account list
        - This will stop all trade push notifications
        """

        # Pass empty list to unsubscribe
        c2s = Trd_SubAccPush.C2S(accIDList = UInt64[])

        req = Trd_SubAccPush.Request(c2s = c2s)
        resp = Client.api_request(client, UInt32(TRD_SUB_ACC_PUSH), req, Trd_SubAccPush.Response)

        if resp.retType != 0
            error_msg = resp.retMsg
            throw(Errors.FutuError(resp.retType, error_msg))
        end

        return true
    end


end
