module QuoteExtended

using DataFrames
using Dates

using ..Client

# Protocol message types
using ..Constants: Qot_GetOptionChain, Qot_GetOptionExpirationDate, Qot_GetWarrant, Qot_GetReference, Qot_GetFutureInfo
using ..Constants: Qot_GetPlateSecurity, Qot_GetPlateSet, Qot_GetStaticInfo
using ..Constants: Qot_GetIpoList
using ..Constants: Qot_RequestTradeDate

# Common types and enums
using ..Constants: Qot_Common, PROTO_RESPONSE_MAP
using ..Constants: QotMarket, SecurityType, ExchType

# Plate and sorting
using ..Constants: PlateSetType, SortField

# Warrant types
using ..Constants: WarrantType, Issuer, IpoPeriod, PriceType, WarrantStatus

# Option types
using ..Constants: OptionType, OptionCondType, IndexOptionType, ExpirationCycle
using ..Constants: OptionStandardType, OptionSettlementMode, DataFilter

# Reference types
using ..Constants: ReferenceType

# Trading date types
using ..Constants: TradeDateType, TradeDateMarket

# Protocol IDs
using ..Constants: QOT_GET_OPTION_EXPIRATION_DATE, QOT_GET_OPTION_CHAIN, QOT_GET_WARRANT
using ..Constants: QOT_GET_REFERENCE, QOT_GET_FUTURE_INFO
using ..Constants: QOT_GET_PLATE_SET, QOT_GET_PLATE_SECURITY, QOT_GET_STATIC_INFO
using ..Constants: QOT_GET_IPO_LIST
using ..Constants: QOT_REQUEST_TRADE_DATE

export
    # Derivatives
    get_option_expiration_date,
    get_option_chain,
    get_warrant,
    get_future_info,
    get_reference,
    
    # 板块
    get_plate_security,
    get_plate_set,
    
    # Static info
    get_static_info,
   
    # IPO
    get_ipo_list,
    
    # Trading dates，交易日历
    get_trade_date


# Get option expiration dates 获取期权到期日
function get_option_expiration_date(client::OpenDClient, underlying_code::String; market::QotMarket.T = QotMarket.HK_Security, index_option_type::Union{IndexOptionType.T, Nothing} = nothing)
    owner_proto = Qot_Common.Security(Int(market), underlying_code)
    c2s = Qot_GetOptionExpirationDate.C2S(; owner = owner_proto)

    if index_option_type !== nothing
        c2s.indexOptionType = Int32(index_option_type)
    end

    req = Qot_GetOptionExpirationDate.Request(; c2s = c2s)

    resp = Client.api_request(client, UInt32(QOT_GET_OPTION_EXPIRATION_DATE), req, PROTO_RESPONSE_MAP[UInt32(QOT_GET_OPTION_EXPIRATION_DATE)])

    dates = resp.s2c.dateList

    rows = NamedTuple[]

    for date_item in dates
        cycle_val = date_item.cycle
        cycle_enum = ExpirationCycle.T(cycle_val)

        push!(rows, (
            strike_time = date_item.strikeTime,
            strike_timestamp = unix2datetime(date_item.strikeTimestamp),
            expiry_date_distance = Int(date_item.optionExpiryDateDistance),
            cycle = cycle_enum
        ))
    end

    return DataFrame(rows)
end

# Get option chain 获取期权链
function get_option_chain(client::OpenDClient, underlying_code::String;
    market::QotMarket.T = QotMarket.HK_Security, begin_time::Union{String, Nothing} = nothing, end_time::Union{String, Nothing} = nothing,
    option_type::Union{OptionType.T, Nothing} = nothing, option_cond_type::OptionCondType.T = OptionCondType.Unknow,
    data_filter::Union{DataFilter, Nothing} = nothing
    )
    owner = Qot_Common.Security(Int(market), underlying_code)
    c2s = Qot_GetOptionChain.C2S(; owner = owner, type = option_type === nothing ? 0 : Int32(option_type), condition = Int32(option_cond_type))

    c2s.beginTime = (begin_time === nothing) ? Dates.format(now(), "yyyy-mm-dd") : begin_time
    c2s.endTime = (end_time === nothing) ? Dates.format(now() + Day(29), "yyyy-mm-dd") : end_time
    if data_filter !== nothing
        c2s.dataFilter = data_filter
    end

    req = Qot_GetOptionChain.Request(c2s = c2s)
    resp = Client.api_request(client, UInt32(QOT_GET_OPTION_CHAIN), req, PROTO_RESPONSE_MAP[UInt32(QOT_GET_OPTION_CHAIN)])
    data = resp.s2c.optionChain

    rows = NamedTuple[]

    for chain_item in data
        strike_time = chain_item.strikeTime
        strike_timestamp = unix2datetime(chain_item.strikeTimestamp)

        for opt in chain_item.option
            function process_option(option_info, option_type_str)
                if option_info !== nothing && isdefined(option_info, :basic)
                    basic = option_info.basic
                    security = basic.security
                    if !isempty(security.code)
                        market_label = string(QotMarket.T(security.market))
                        formatted_code = string(market_label, ".", security.code)

                        return (
                            type = option_type_str,
                            strike_time = strike_time,
                            strike_timestamp = strike_timestamp,
                            code = formatted_code,
                            name = basic.name,
                            lot_size = Int(basic.lotSize),
                            stock_type = string(SecurityType.T(basic.secType)),
                            list_time = basic.listTime,
                            list_timestamp = unix2datetime(basic.listTimestamp),
                            delisting = basic.delisting,
                            id = basic.id,
                        )
                    end
                end
                return nothing
            end

            call_row = process_option(opt.call, "CALL")
            if call_row !== nothing
                push!(rows, call_row)
            end

            put_row = process_option(opt.put, "PUT")
            if put_row !== nothing
                push!(rows, put_row)
            end
        end
    end

    df = DataFrame(rows)

    if all(==(unix2datetime(0)), df.list_timestamp)
        select!(df, Not(:list_time, :list_timestamp))
    end
    
    return df
end

# Get warrant information with comprehensive filtering 筛选窝轮
"""
    get_warrant(client::OpenDClient, underlying_code::String; kwargs...)

Filter and retrieve warrant data for Hong Kong market.

# Arguments
- `client::OpenDClient`: The API client
- `underlying_code::String`: The underlying stock code

# Keyword Arguments
## Basic Parameters
- `market::QotMarket.T = QotMarket.HK_Security`: Market identifier
- `begin_idx::Int = 0`: Starting index for pagination
- `num::Int = 200`: Number of records to retrieve (max 200)
- `sort_field::SortField.T = SortField.Code`: Field to sort by
- `ascending::Bool = true`: Sort order (true = ascending, false = descending)

## Filter Parameters
- `type_list::Vector{WarrantType.T} = WarrantType.T[]`: Warrant type filter (e.g., [WarrantType.Buy, WarrantType.Sell])
- `issuer_list::Vector{Issuer.T} = Issuer.T[]`: Issuer filter (e.g., [Issuer.SG, Issuer.BP])
- `maturity_time_min::Union{String, Nothing} = nothing`: Maturity date range start (format: "yyyy-MM-dd")
- `maturity_time_max::Union{String, Nothing} = nothing`: Maturity date range end (format: "yyyy-MM-dd")
- `ipo_period::Union{IpoPeriod.T, Nothing} = nothing`: Listing period filter
- `price_type::Union{PriceType.T, Nothing} = nothing`: In/out of money filter
- `status::Union{WarrantStatus.T, Nothing} = nothing`: Warrant status filter

## Price Filters (all optional)
- `cur_price_min::Union{Float64, Nothing} = nothing`: Min current price
- `cur_price_max::Union{Float64, Nothing} = nothing`: Max current price
- `strike_price_min::Union{Float64, Nothing} = nothing`: Min strike price
- `strike_price_max::Union{Float64, Nothing} = nothing`: Max strike price

## Ratio Filters (percentage values, e.g., 20 = 20%)
- `street_min::Union{Float64, Nothing} = nothing`: Min street ratio (%)
- `street_max::Union{Float64, Nothing} = nothing`: Max street ratio (%)
- `premium_min::Union{Float64, Nothing} = nothing`: Min premium (%)
- `premium_max::Union{Float64, Nothing} = nothing`: Max premium (%)

## Other Filters
- `conversion_min::Union{Float64, Nothing} = nothing`: Min conversion ratio
- `conversion_max::Union{Float64, Nothing} = nothing`: Max conversion ratio
- `vol_min::Union{UInt64, Nothing} = nothing`: Min volume
- `vol_max::Union{UInt64, Nothing} = nothing`: Max volume
- `leverage_ratio_min::Union{Float64, Nothing} = nothing`: Min leverage ratio
- `leverage_ratio_max::Union{Float64, Nothing} = nothing`: Max leverage ratio

## Call/Put Warrant Specific Filters
- `delta_min::Union{Float64, Nothing} = nothing`: Min delta value (call/put only)
- `delta_max::Union{Float64, Nothing} = nothing`: Max delta value (call/put only)
- `implied_min::Union{Float64, Nothing} = nothing`: Min implied volatility (call/put only)
- `implied_max::Union{Float64, Nothing} = nothing`: Max implied volatility (call/put only)

## Bull/Bear Certificate Specific Filters
- `recovery_price_min::Union{Float64, Nothing} = nothing`: Min recovery price (bull/bear only)
- `recovery_price_max::Union{Float64, Nothing} = nothing`: Max recovery price (bull/bear only)
- `price_recovery_ratio_min::Union{Float64, Nothing} = nothing`: Min price to recovery ratio (%) (bull/bear only)
- `price_recovery_ratio_max::Union{Float64, Nothing} = nothing`: Max price to recovery ratio (%) (bull/bear only)

# Returns
- `DataFrame`: Warrant data with comprehensive fields

# Notes
- Protocol ID: 3210
- Rate limit: 60 requests per 30 seconds
- Max records per request: 200
- Only supports Hong Kong market
"""
function get_warrant(client::OpenDClient, underlying_code::String;
    market::QotMarket.T = QotMarket.HK_Security, begin_idx::Int = 0, num::Int = 200, sort_field::SortField.T = SortField.Code, ascending::Bool = true,
    # Filters — all default to proto-zero
    type_list::Vector{WarrantType.T} = WarrantType.T[],
    issuer_list::Vector{Issuer.T} = Issuer.T[],
    maturity_time_min::Union{String, Nothing} = nothing,
    maturity_time_max::Union{String, Nothing} = nothing,
    ipo_period::Union{IpoPeriod.T, Nothing} = nothing,
    price_type::Union{PriceType.T, Nothing} = nothing,
    status::Union{WarrantStatus.T, Nothing} = nothing,
    cur_price_min::Union{Float64, Nothing} = nothing,
    cur_price_max::Union{Float64, Nothing} = nothing,
    strike_price_min::Union{Float64, Nothing} = nothing,
    strike_price_max::Union{Float64, Nothing} = nothing,
    street_min::Union{Float64, Nothing} = nothing,
    street_max::Union{Float64, Nothing} = nothing,
    conversion_min::Union{Float64, Nothing} = nothing,
    conversion_max::Union{Float64, Nothing} = nothing,
    vol_min::Union{UInt64, Nothing} = nothing,
    vol_max::Union{UInt64, Nothing} = nothing,
    premium_min::Union{Float64, Nothing} = nothing,
    premium_max::Union{Float64, Nothing} = nothing,
    leverage_ratio_min::Union{Float64, Nothing} = nothing,
    leverage_ratio_max::Union{Float64, Nothing} = nothing,
    delta_min::Union{Float64, Nothing} = nothing,
    delta_max::Union{Float64, Nothing} = nothing,
    implied_min::Union{Float64, Nothing} = nothing,
    implied_max::Union{Float64, Nothing} = nothing,
    recovery_price_min::Union{Float64, Nothing} = nothing,
    recovery_price_max::Union{Float64, Nothing} = nothing,
    price_recovery_ratio_min::Union{Float64, Nothing} = nothing,
    price_recovery_ratio_max::Union{Float64, Nothing} = nothing
    )
    # --- Construct the Qot_GetWarrant.C2S message ---
    owner_proto = Qot_Common.Security(Int32(market), underlying_code)

    c2s = Qot_GetWarrant.C2S(begin_ = Int32(begin_idx), num = Int32(num), sortField = Int32(sort_field), ascend = ascending, owner = owner_proto, typeList = [Int32(t) for t in type_list], issuerList = [Int32(i) for i in issuer_list])

    # --- Optional fields: assign only if not nothing ---
    if maturity_time_min !== nothing
        c2s.maturityTimeMin = maturity_time_min
    end
    if maturity_time_max !== nothing
        c2s.maturityTimeMax = maturity_time_max
    end
    if ipo_period !== nothing
        c2s.ipoPeriod = Int32(ipo_period)
    end
    if price_type !== nothing
        c2s.priceType = Int32(price_type)
    end
    if status !== nothing
        c2s.status = Int32(status)
    end

    for (field, val) in [(:curPriceMin, cur_price_min), (:curPriceMax, cur_price_max), (:strikePriceMin, strike_price_min), (:strikePriceMax, strike_price_max),
        (:streetMin, street_min), (:streetMax, street_max), (:conversionMin, conversion_min), (:conversionMax, conversion_max), (:premiumMin, premium_min),
        (:premiumMax, premium_max), (:leverageRatioMin, leverage_ratio_min), (:leverageRatioMax, leverage_ratio_max), (:deltaMin, delta_min), (:deltaMax, delta_max),
        (:impliedMin, implied_min), (:impliedMax, implied_max), (:recoveryPriceMin, recovery_price_min), (:recoveryPriceMax, recovery_price_max), 
        (:priceRecoveryRatioMin, price_recovery_ratio_min), (:priceRecoveryRatioMax, price_recovery_ratio_max)]
        
        if val !== nothing
            setfield!(c2s, field, Float64(val))
        end
    end

    if vol_min !== nothing
        c2s.volMin = UInt64(vol_min)
    end
    if vol_max !== nothing
        c2s.volMax = UInt64(vol_max)
    end
    
    # --- Send request ---
    req = Qot_GetWarrant.Request(c2s = c2s)
    resp = Client.api_request(client, UInt32(QOT_GET_WARRANT), req, PROTO_RESPONSE_MAP[UInt32(QOT_GET_WARRANT)])

    s2c = resp.s2c
    warrant_list = s2c.warrantDataList

    # --- Build DataFrame ---
    rows = NamedTuple[]
    for wd in warrant_list
        stock_code = string(QotMarket.T(wd.stock.market), ".", wd.stock.code)
        owner_code = string(QotMarket.T(wd.owner.market), ".", wd.owner.code)

        push!(rows, (
            code = stock_code,
            name = wd.name,
            owner = owner_code,
            type = WarrantType.T(wd.type),
            issuer = Issuer.T(wd.issuer),
            maturity_time = wd.maturityTime,
            maturity_timestamp = unix2datetime(wd.maturityTimestamp),
            list_time = wd.listTime,
            list_timestamp = unix2datetime(wd.listTimestamp),
            last_trade_time = wd.lastTradeTime,
            last_trade_timestamp = unix2datetime(wd.lastTradeTimestamp),
            strike_price = wd.strikePrice,
            last_close_price = wd.lastClosePrice,
            conversion_ratio = wd.conversionRatio,
            lot_size = Int(wd.lotSize),
            cur_price = wd.curPrice,
            price_change_val = wd.priceChangeVal,
            change_rate = wd.changeRate,
            status = WarrantStatus.T(wd.status),
            bid_price = wd.bidPrice,
            ask_price = wd.askPrice,
            bid_vol = wd.bidVol,
            ask_vol = wd.askVol,
            volume = wd.volume,
            turnover = wd.turnover,
            score = wd.score,
            premium = wd.premium,
            break_even_point = wd.breakEvenPoint,
            leverage = wd.leverage,
            effective_leverage = wd.effectiveLeverage,
            ipop = wd.ipop,
            conversion_price = wd.conversionPrice,
            street_rate = wd.streetRate,
            street_vol = wd.streetVol,
            amplitude = wd.amplitude,
            issue_size = wd.issueSize,
            high_price = wd.highPrice,
            low_price = wd.lowPrice,
            implied_volatility = wd.impliedVolatility,
            delta = wd.delta,
            recovery_price = wd.recoveryPrice,
            price_recovery_ratio = wd.priceRecoveryRatio,
            upper_strike_price = wd.upperStrikePrice,
            lower_strike_price = wd.lowerStrikePrice,
            in_line_price_status = PriceType.T(wd.inLinePriceStatus))
        )
    end

    df = DataFrame(rows)
    metadata!(df, "last_page", s2c.lastPage, style = :note)
    metadata!(df, "all_count", s2c.allCount, style = :note)
    return df
end

# Get reference securities (related warrants or futures contracts) 获取窝轮和期货列表

"""
    get_reference(client::OpenDClient, code::String; kwargs...)

Get related securities for a given stock or futures contract.

# Arguments
- `client::OpenDClient`: The API client
- `code::String`: The security code (underlying stock for warrants, or main futures contract)

# Keyword Arguments
- `market::QotMarket.T = QotMarket.HK_Security`: Market identifier
- `reference_type::ReferenceType.T = ReferenceType.Warrant`: Type of reference
  - `ReferenceType.Warrant`: Get warrants related to the underlying stock
  - `ReferenceType.Future`: Get related contracts for the main futures contract

# Returns
- `DataFrame`: Related securities with the following columns:
  - `code`: Security code with market prefix (e.g., "HK_Security.12345")
  - `name`: Security name
  - `id`: Security ID
  - `lot_size`: Lot size (for options and futures, this represents contract multiplier)
  - `sec_type`: Security type (as enum)
  - `list_time`: Listing date (format: "yyyy-MM-dd")
  - `list_timestamp`: Listing timestamp as DateTime
  - `delisting`: Whether the security is delisted
  - `exch_type`: Exchange type (as enum)

  For warrant references, additional columns:
  - `warrant_type`: Type of warrant (as enum)
  - `warrant_owner`: Owner security code

  For option references, additional columns:
  - `option_type`: Type of option (as enum)
  - `option_owner`: Underlying security code
  - `strike_time`: Strike date
  - `strike_timestamp`: Strike timestamp as DateTime
  - `strike_price`: Strike price
  - `suspend`: Whether suspended
  - `market_str`: Market/exchange string
  - `index_option_type`: Index option type (as enum, if applicable)
  - `expiration_cycle`: Expiration cycle (as enum)
  - `option_standard_type`: Standard option type (as enum)
  - `option_settlement_mode`: Settlement mode (as enum)

  For future references, additional columns:
  - `last_trade_time`: Last trading date
  - `last_trade_timestamp`: Last trading timestamp as DateTime
  - `is_main_contract`: Whether this is the main contract

# Notes
- Protocol ID: 3206
- Rate limit: 10 requests per 30 seconds (general)
- When getting warrants for underlying stocks, no rate limit applies
- For warrants: Returns all warrants related to the specified underlying stock
- For futures: Returns all related contracts for the specified main futures contract
"""
function get_reference(client::OpenDClient, code::String;   
    market::QotMarket.T = QotMarket.HK_Security, reference_type::ReferenceType.T = ReferenceType.Warrant
    )
    # Create security object
    security = Qot_Common.Security(Int32(market), code)

    # Build C2S request
    c2s = Qot_GetReference.C2S(security = security, referenceType = Int32(reference_type))

    # Create request and send
    req = Qot_GetReference.Request(c2s = c2s)
    resp = Client.api_request(client, UInt32(QOT_GET_REFERENCE), req, PROTO_RESPONSE_MAP[UInt32(QOT_GET_REFERENCE)])

    # Parse response
    static_info_list = resp.s2c.staticInfoList

    # Build DataFrame
    rows = NamedTuple[]

    for static_info in static_info_list
        basic = static_info.basic

        # Format code with market prefix
        sec_code = string(QotMarket.T(basic.security.market), ".", basic.security.code)

        # Base row data (common to all security types)
        base_data = (
            code = sec_code,
            name = basic.name,
            id = basic.id,
            lot_size = Int(basic.lotSize),
            sec_type = SecurityType.T(basic.secType),
            list_time = basic.listTime,
            list_timestamp = unix2datetime(basic.listTimestamp),
            delisting = basic.delisting,
            exch_type = ExchType.T(basic.exchType)
        )

        # Add type-specific data based on reference type
        if reference_type == ReferenceType.Warrant
            # Warrant-specific data
            warrant_ex = static_info.warrantExData
            owner_code = string(QotMarket.T(warrant_ex.owner.market), ".", warrant_ex.owner.code)

            row = merge(base_data, (
                warrant_type = WarrantType.T(warrant_ex.type),
                warrant_owner = owner_code)
            )
        elseif reference_type == ReferenceType.Future
            # Future-specific data
            future_ex = static_info.futureExData

            row = merge(base_data, (
                last_trade_time = future_ex.lastTradeTime,
                last_trade_timestamp = unix2datetime(future_ex.lastTradeTimestamp),
                is_main_contract = future_ex.isMainContract)
            )
        else
            # For options or other types, include available extended data
            option_ex = static_info.optionExData
            if isdefined(option_ex, :owner) && !isempty(option_ex.owner.code)
                owner_code = string(QotMarket.T(option_ex.owner.market), ".", option_ex.owner.code)

                row = merge(base_data, (
                    option_type = OptionType.T(option_ex.type),
                    option_owner = owner_code,
                    strike_time = option_ex.strikeTime,
                    strike_timestamp = unix2datetime(option_ex.strikeTimestamp),
                    strike_price = option_ex.strikePrice,
                    suspend = option_ex.suspend,
                    market_str = option_ex.market,
                    index_option_type = IndexOptionType.T(option_ex.indexOptionType),
                    expiration_cycle = ExpirationCycle.T(option_ex.expirationCycle),
                    option_standard_type = OptionStandardType.T(option_ex.optionStandardType),
                    option_settlement_mode = OptionSettlementMode.T(option_ex.optionSettlementMode))
                )
            else
                row = base_data
            end
        end

        push!(rows, row)
    end

    df = DataFrame(rows)

    # Remove list_time and list_timestamp columns if all timestamps are unix epoch 0
    if !isempty(df) && all(==(unix2datetime(0)), df.list_timestamp)
        select!(df, Not(:list_time, :list_timestamp))
    end

    return df
end

# Get futures contract information
"""
    get_future_info(client::OpenDClient, codes::Vector{String}; market::QotMarket.T = QotMarket.US_Future)

Get detailed information about futures contracts.

# Arguments
- `client::OpenDClient`: The API client
- `codes::Vector{String}`: List of futures contract codes (max 200)

# Keyword Arguments
- `market::QotMarket.T = QotMarket.US_Future`: Market identifier for the futures contracts

# Returns
- `DataFrame`: Futures contract information with the following columns:

  **Basic Information:**
  - `code`: Contract code with market prefix
  - `name`: Contract name
  - `last_trade_time`: Last trading date (format: "yyyy-MM-dd", only for non-main contracts)
  - `last_trade_timestamp`: Last trading timestamp as DateTime (only for non-main contracts)

  **Underlying Information:**
  - `owner`: Underlying security code (for stock futures and index futures)
  - `owner_other`: Underlying description
  - `origin`: Original contract code

  **Contract Specifications:**
  - `exchange`: Exchange name
  - `contract_type`: Contract type description
  - `contract_size`: Contract size/multiplier
  - `contract_size_unit`: Unit for contract size
  - `time_zone`: Time zone
  - `exchange_format_url`: Exchange specification URL

  **Pricing Information:**
  - `quote_currency`: Quote currency
  - `quote_unit`: Quote unit
  - `min_var`: Minimum price variation
  - `min_var_unit`: Unit for minimum variation

  **Trading Times:**
  - `trade_times`: Vector of trading time ranges (start and end times in minutes from midnight)

# Notes
- Protocol ID: 3218
- Rate limit: 30 requests per 30 seconds
- Max contracts per request: 200
- Supports futures markets: US_Future, HK_Future, JP_Future, SG_Future, etc.
"""
function get_future_info(client::OpenDClient, codes::Vector{String}; market::QotMarket.T = QotMarket.US_Future)
    # Build security list
    security_list = [Qot_Common.Security(Int32(market), code) for code in codes]

    # Build C2S request
    c2s = Qot_GetFutureInfo.C2S(securityList = security_list)

    # Create request and send
    req = Qot_GetFutureInfo.Request(c2s = c2s)
    resp = Client.api_request(client, UInt32(QOT_GET_FUTURE_INFO), req, PROTO_RESPONSE_MAP[UInt32(QOT_GET_FUTURE_INFO)])

    # Parse response
    future_info_list = resp.s2c.futureInfoList

    # Build DataFrame
    rows = NamedTuple[]

    for future_info in future_info_list
        # Format codes with market prefix
        code = string(QotMarket.T(future_info.security.market), ".", future_info.security.code)

        # Format owner code if available
        owner_code = if !isempty(future_info.owner.code)
            string(QotMarket.T(future_info.owner.market), ".", future_info.owner.code)
        else
            missing
        end

        # Format origin code if available
        origin_code = if !isempty(future_info.origin.code)
            string(QotMarket.T(future_info.origin.market), ".", future_info.origin.code)
        else
            missing
        end

        # Process trading times
        trade_times = [(begin_min = tt.begin_, end_min = tt.end_) for tt in future_info.tradeTime]

        row = (
            # Basic information
            code = code,
            name = future_info.name,
            last_trade_time = future_info.lastTradeTime,
            last_trade_timestamp = unix2datetime(future_info.lastTradeTimestamp),

            # Underlying
            owner = owner_code,
            owner_other = future_info.ownerOther,
            origin = origin_code,

            # Contract specifications
            exchange = future_info.exchange,
            contract_type = future_info.contractType,
            contract_size = future_info.contractSize,
            contract_size_unit = future_info.contractSizeUnit,
            time_zone = future_info.timeZone,
            exchange_format_url = future_info.exchangeFormatUrl,

            # Pricing
            quote_currency = future_info.quoteCurrency,
            quote_unit = future_info.quoteUnit,
            min_var = future_info.minVar,
            min_var_unit = future_info.minVarUnit,

            # Trading times
            trade_times = trade_times
        )

        push!(rows, row)
    end

    df = DataFrame(rows)

    # Remove last_trade_time and last_trade_timestamp columns if all timestamps are unix epoch 0
    if !isempty(df) && all(==(unix2datetime(0)), df.last_trade_timestamp)
        select!(df, Not(:last_trade_time, :last_trade_timestamp))
    end

    # Remove min_var_unit column if all values are empty
    if !isempty(df) && all(isempty, df.min_var_unit)
        select!(df, Not(:min_var_unit))
    end

    return df
end

# Get securities in a plate 获取板块内股票
"""
    get_plate_security(client::OpenDClient, plate_code::String; kwargs...)

Get the list of stocks within a specified plate/sector, or get constituent stocks of an index.

# Arguments
- `client::OpenDClient`: The API client
- `plate_code::String`: Plate code (without market prefix, e.g., "HSI Constituent Stocks")

# Keyword Arguments
- `market::QotMarket.T = QotMarket.HK_Security`: Market identifier
- `sort_field::SortField.T = SortField.Code`: Field to sort by
- `ascending::Bool = true`: Sort order (true = ascending, false = descending)

# Returns
- `DataFrame`: Securities within the plate with the following columns:

  **Basic Information:**
  - `code`: Security code with market prefix (e.g., "HK_Security.00700")
  - `name`: Security name
  - `id`: Security ID
  - `lot_size`: Lot size (for options and futures, this represents contract multiplier)
  - `sec_type`: Security type (as enum)
  - `list_time`: Listing date (format: "yyyy-MM-dd")
  - `list_timestamp`: Listing timestamp as DateTime
  - `delisting`: Whether the security is delisted
  - `exch_type`: Exchange type (as enum)

  **Extended Data (when applicable):**
  For warrant securities:
  - `warrant_type`: Type of warrant (as enum)
  - `warrant_owner`: Underlying security code

  For option securities:
  - `option_type`: Type of option (as enum)
  - `option_owner`: Underlying security code
  - `strike_time`: Strike date
  - `strike_timestamp`: Strike timestamp as DateTime
  - `strike_price`: Strike price
  - `suspend`: Whether suspended
  - `market_str`: Market/exchange string
  - `index_option_type`: Index option type (as enum)
  - `expiration_cycle`: Expiration cycle (as enum)
  - `option_standard_type`: Standard option type (as enum)
  - `option_settlement_mode`: Settlement mode (as enum)

  For futures securities:
  - `last_trade_time`: Last trading date
  - `last_trade_timestamp`: Last trading timestamp as DateTime
  - `is_main_contract`: Whether this is the main contract

# Notes
- Protocol ID: 3205
- Rate limit: 10 requests per 30 seconds
- Supports getting constituent stocks of indices
- Returns full SecurityStaticInfo structures including extended data for warrants/options/futures

# Common Plate/Index Codes

**Hong Kong Market:**
- "HSI Constituent Stocks" - Hang Seng Index constituents
- "HSCEI Constituent Stocks" - Hang Seng China Enterprises Index constituents
- "HSTECH Constituent Stocks" - Hang Seng TECH Index constituents
- "Motherboard" - HK Main Board stocks
- "GEM" - HK Growth Enterprise Market stocks

**US Market:**
- "Dow Jones" - Dow Jones Industrial Average
- "S&P 500" - S&P 500 Index
- "Nasdaq 100" - Nasdaq 100 Index
- "NYSE" - New York Stock Exchange listed stocks
- "NASDAQ" - NASDAQ listed stocks

**A-share Market:**
- "LIST3000000" - Shanghai Main Board (use market SH)
- "LIST3000001" - Shanghai Science and Technology Innovation Board (use market SH)
- "LIST3000002" - Shenzhen Main Board (use market SZ)
- "LIST3000003" - Shenzhen ChiNext (use market SZ)
- "LIST3000005" - Beijing Stock Exchange (use market SH)
"""
function get_plate_security(client::OpenDClient, plate_code::String; market::QotMarket.T = QotMarket.HK_Security, sort_field::SortField.T = SortField.Code, ascending::Bool = true)
    # Create plate security object
    plate = Qot_Common.Security(Int32(market), plate_code)

    # Build C2S request
    c2s = Qot_GetPlateSecurity.C2S(plate = plate, sortField = Int32(sort_field), ascend = ascending)

    # Create request and send
    req = Qot_GetPlateSecurity.Request(c2s = c2s)
    resp = Client.api_request(client, UInt32(QOT_GET_PLATE_SECURITY), req, PROTO_RESPONSE_MAP[UInt32(QOT_GET_PLATE_SECURITY)])

    # Parse response
    static_info_list = resp.s2c.staticInfoList

    # Build DataFrame
    rows = NamedTuple[]

    for static_info in static_info_list
        basic = static_info.basic

        # Format code with market prefix
        sec_code = string(QotMarket.T(basic.security.market), ".", basic.security.code)

        # Base row data (common to all security types)
        base_data = (
            code = sec_code,
            name = basic.name,
            id = basic.id,
            lot_size = Int(basic.lotSize),
            sec_type = SecurityType.T(basic.secType),
            list_time = basic.listTime,
            list_timestamp = unix2datetime(basic.listTimestamp),
            delisting = basic.delisting,
            exch_type = ExchType.T(basic.exchType)
        )

        # Check if we have extended data and add type-specific fields
        row = base_data

        # Check for warrant extended data
        if isdefined(static_info, :warrantExData) && !isempty(static_info.warrantExData.owner.code)
            warrant_ex = static_info.warrantExData
            owner_code = string(QotMarket.T(warrant_ex.owner.market), ".", warrant_ex.owner.code)
            row = merge(base_data, (
                warrant_type = WarrantType.T(warrant_ex.type),
                warrant_owner = owner_code)
            )
        # Check for option extended data
        elseif isdefined(static_info, :optionExData) && !isempty(static_info.optionExData.owner.code)
            option_ex = static_info.optionExData
            owner_code = string(QotMarket.T(option_ex.owner.market), ".", option_ex.owner.code)
            row = merge(base_data, (
                option_type = OptionType.T(option_ex.type),
                option_owner = owner_code,
                strike_time = option_ex.strikeTime,
                strike_timestamp = unix2datetime(option_ex.strikeTimestamp),
                strike_price = option_ex.strikePrice,
                suspend = option_ex.suspend,
                market_str = option_ex.market,
                index_option_type = IndexOptionType.T(option_ex.indexOptionType),
                expiration_cycle = ExpirationCycle.T(option_ex.expirationCycle),
                option_standard_type = OptionStandardType.T(option_ex.optionStandardType),
                option_settlement_mode = OptionSettlementMode.T(option_ex.optionSettlementMode))
            )
        # Check for future extended data
        elseif isdefined(static_info, :futureExData) && !isempty(static_info.futureExData.lastTradeTime)
            future_ex = static_info.futureExData
            row = merge(base_data, (
                last_trade_time = future_ex.lastTradeTime,
                last_trade_timestamp = unix2datetime(future_ex.lastTradeTimestamp),
                is_main_contract = future_ex.isMainContract)
            )
        end

        push!(rows, row)
    end

    return DataFrame(rows)
end

# Get plate set (list of plates) 获取板块列表
function get_plate_set(client::OpenDClient, market::QotMarket.T; plate_set_type::PlateSetType.T = PlateSetType.All)
    c2s = Qot_GetPlateSet.C2S(market = Int32(market), plateSetType = Int32(plate_set_type))

    req = Qot_GetPlateSet.Request(c2s = c2s)
    resp = Client.api_request(client, UInt32(QOT_GET_PLATE_SET), req, PROTO_RESPONSE_MAP[UInt32(QOT_GET_PLATE_SET)])
    plate_info_list = resp.s2c.plateInfoList

    rows = NamedTuple[]

    for plate_info in plate_info_list
        plate = plate_info.plate
        plate_type = PlateSetType.T(plate_info.plateType)
        push!(rows, (
            code = plate.code,
            name = plate_info.name,
            plate_type = string(plate_type))
        )
    end

    return DataFrame(rows)
end

# Get static information for securities 获取静态信息
"""
    get_static_info(client::OpenDClient; kwargs...)

Get static information for securities by market/type or specific security list.

# Keyword Arguments

**Option 1: Query by Market and Security Type**
- `market::Union{QotMarket.T, Nothing} = nothing`: Stock market (e.g., HK_Security, US_Security, CNSH_Security, CNSZ_Security)
- `sec_type::Union{SecurityType.T, Nothing} = nothing`: Security type (e.g., Eqty, Index, Warrant, etc.)

**Option 2: Query by Specific Securities**
- `security_list::Vector{Qot_Common.Security} = []`: List of specific securities to query

# Parameter Priority
When `security_list` is provided, it takes precedence and `market`/`sec_type` parameters are ignored.

# Returns
- `DataFrame`: Security static information with the following columns:

  **Basic Information:**
  - `code`: Security code with market prefix (e.g., "HK_Security.00700")
  - `name`: Security name (shows "未知股票" for unrecognized/delisted stocks)
  - `id`: Security ID
  - `lot_size`: Lot size (for options and futures, this represents contract multiplier)
  - `sec_type`: Security type (as enum)
  - `list_time`: Listing date (format: "yyyy-MM-dd")
  - `list_timestamp`: Listing timestamp as DateTime
  - `delisting`: Whether the security is delisted (true for unrecognized stocks)
  - `exch_type`: Exchange type (as enum)

  **Extended Data (when applicable):**
  For warrant securities:
  - `warrant_type`: Type of warrant (as enum)
  - `warrant_owner`: Underlying security code

  For option securities:
  - `option_type`: Type of option (as enum)
  - `option_owner`: Underlying security code
  - `strike_time`: Strike date
  - `strike_timestamp`: Strike timestamp as DateTime
  - `strike_price`: Strike price
  - `suspend`: Whether suspended
  - `market_str`: Market/exchange string
  - `index_option_type`: Index option type (as enum)
  - `expiration_cycle`: Expiration cycle (as enum)
  - `option_standard_type`: Standard option type (as enum)
  - `option_settlement_mode`: Settlement mode (as enum)

  For futures securities:
  - `last_trade_time`: Last trading date
  - `last_trade_timestamp`: Last trading timestamp as DateTime
  - `is_main_contract`: Whether this is the main contract

# Notes
- Protocol ID: 3202
- Special behavior: Unlike other quote APIs, this endpoint will return data even for unrecognized stocks
  - Unrecognized/delisted stocks show `name = "未知股票"` (Unknown stock)
  - The `delisting` field indicates whether the stock is delisted/unrecognized
  - All other fields will have default values (0 for numbers, empty string for text)
- Other quote APIs will reject unrecognized stocks with an error
- Returns full SecurityStaticInfo structures including extended data for warrants/options/futures
"""
function get_static_info(client::OpenDClient; market::QotMarket.T = QotMarket.HK_Security, sec_type::SecurityType.T = SecurityType.Bond, security_list::Vector{Qot_Common.Security} = Qot_Common.Security[])
    # Build C2S request
    c2s = Qot_GetStaticInfo.C2S()

    # If security_list is provided, use it (ignores market and sec_type)
    if !isempty(security_list)
        c2s.securityList = security_list
    else
        # Use market and sec_type
        if market !== nothing
            c2s.market = Int32(market)
        end
        if sec_type !== nothing
            c2s.secType = Int32(sec_type)
        end
    end

    # Create request and send
    req = Qot_GetStaticInfo.Request(c2s = c2s)
    resp = Client.api_request(client, UInt32(QOT_GET_STATIC_INFO), req, PROTO_RESPONSE_MAP[UInt32(QOT_GET_STATIC_INFO)])

    # Parse response
    static_info_list = resp.s2c.staticInfoList

    # Build DataFrame
    rows = NamedTuple[]

    for static_info in static_info_list
        basic = static_info.basic

        # Format code with market prefix
        sec_code = string(QotMarket.T(basic.security.market), ".", basic.security.code)

        # Base row data (common to all security types)
        base_data = (
            code = sec_code,
            name = basic.name,
            id = basic.id,
            lot_size = Int(basic.lotSize),
            sec_type = SecurityType.T(basic.secType),
            list_time = basic.listTime,
            list_timestamp = unix2datetime(basic.listTimestamp),
            delisting = basic.delisting,
            exch_type = ExchType.T(basic.exchType)
        )

        # Check if we have extended data and add type-specific fields
        row = base_data

        # Check for warrant extended data
        if isdefined(static_info, :warrantExData) && !isempty(static_info.warrantExData.owner.code)
            warrant_ex = static_info.warrantExData
            owner_code = string(QotMarket.T(warrant_ex.owner.market), ".", warrant_ex.owner.code)
            row = merge(base_data, (
                warrant_type = WarrantType.T(warrant_ex.type),
                warrant_owner = owner_code)
            )
        # Check for option extended data
        elseif isdefined(static_info, :optionExData) && !isempty(static_info.optionExData.owner.code)
            option_ex = static_info.optionExData
            owner_code = string(QotMarket.T(option_ex.owner.market), ".", option_ex.owner.code)
            row = merge(base_data, (
                option_type = OptionType.T(option_ex.type),
                option_owner = owner_code,
                strike_time = option_ex.strikeTime,
                strike_timestamp = unix2datetime(option_ex.strikeTimestamp),
                strike_price = option_ex.strikePrice,
                suspend = option_ex.suspend,
                market_str = option_ex.market,
                index_option_type = IndexOptionType.T(option_ex.indexOptionType),
                expiration_cycle = ExpirationCycle.T(option_ex.expirationCycle),
                option_standard_type = OptionStandardType.T(option_ex.optionStandardType),
                option_settlement_mode = OptionSettlementMode.T(option_ex.optionSettlementMode))
            )
        # Check for future extended data
        elseif isdefined(static_info, :futureExData) && !isempty(static_info.futureExData.lastTradeTime)
            future_ex = static_info.futureExData
            row = merge(base_data, (
                last_trade_time = future_ex.lastTradeTime,
                last_trade_timestamp = unix2datetime(future_ex.lastTradeTimestamp),
                is_main_contract = future_ex.isMainContract)
            )
        end

        push!(rows, row)
    end

    return DataFrame(rows)
end

# 获取IPO列表
"""
    get_ipo_list(client::OpenDClient; market::QotMarket.T = QotMarket.HK_Security)

Get IPO (Initial Public Offering) information for a specified market.

# Keyword Arguments
- `market::QotMarket.T = QotMarket.HK_Security`: Stock market (supports HK_Security, US_Security, CNSH_Security, CNSZ_Security)
  - Note: For A-shares, CNSH and CNSZ are treated as the same market and will return combined results

# Returns
- `DataFrame`: IPO data with market-specific fields

  **Common Fields (all markets):**
  - `code`: Security code with market prefix
  - `name`: Stock name
  - `list_time`: Listing date (format: "yyyy-MM-dd")
  - `list_timestamp`: Listing timestamp as DateTime

  **Hong Kong Market Additional Fields:**
  - `ipo_price_min`: Minimum offering price
  - `ipo_price_max`: Maximum offering price
  - `list_price`: Listing price
  - `lot_size`: Shares per lot
  - `entrance_price`: Entry fee
  - `is_subscribe_status`: Whether in subscription status (true=subscribing, false=pending listing)
  - `apply_end_time`: Subscription deadline (format: "yyyy-MM-dd")
  - `apply_end_timestamp`: Subscription deadline as DateTime

  **US Market Additional Fields:**
  - `ipo_price_min`: Minimum offering price
  - `ipo_price_max`: Maximum offering price
  - `issue_size`: Issue size (number of shares)

  **A-share Market Additional Fields:**
  - `apply_code`: Subscription code
  - `issue_size`: Total issue size
  - `online_issue_size`: Online issue size
  - `apply_upper_limit`: Subscription limit
  - `apply_limit_market_value`: Market value required for maximum subscription
  - `is_estimate_ipo_price`: Whether IPO price is estimated
  - `ipo_price`: IPO price (estimated values may change)
  - `industry_pe_rate`: Industry P/E ratio
  - `is_estimate_winning_ratio`: Whether winning ratio is estimated
  - `winning_ratio`: Winning ratio (percentage, e.g., 20 = 20%)
  - `issue_pe_rate`: Issue P/E ratio
  - `apply_time`: Subscription date
  - `apply_timestamp`: Subscription timestamp as DateTime
  - `winning_time`: Winning number announcement date
  - `winning_timestamp`: Winning number announcement timestamp as DateTime
  - `is_has_won`: Whether winning numbers have been announced
  - `winning_num_data`: Vector of winning number data (tuples with winning_name and winning_info)

# Notes
- Protocol ID: 3217
- Rate limit: 10 requests per 30 seconds
- For A-shares: Shanghai (CNSH) and Shenzhen (CNSZ) markets are combined
- Estimated values (prices, ratios) may change based on募集资金/发行数量/发行费用
- Futu subscription deadline may be earlier than exchange-announced deadline
"""
function get_ipo_list(client::OpenDClient; market::QotMarket.T = QotMarket.HK_Security)

    # Build C2S request
    c2s = Qot_GetIpoList.C2S(market = Int32(market))

    # Create request and send
    req = Qot_GetIpoList.Request(c2s = c2s)
    resp = Client.api_request(client, UInt32(QOT_GET_IPO_LIST), req, PROTO_RESPONSE_MAP[UInt32(QOT_GET_IPO_LIST)])

    # Parse response
    ipo_list = resp.s2c.ipoList

    # Build DataFrame with market-specific fields
    rows = NamedTuple[]

    for ipo_data in ipo_list
        basic = ipo_data.basic

        # Format code with market prefix
        code = string(QotMarket.T(basic.security.market), ".", basic.security.code)

        # Base data common to all markets
        base_data = (
            code = code,
            name = basic.name,
            list_time = isempty(basic.listTime) ? missing : basic.listTime,
            list_timestamp = basic.listTimestamp == 0.0 ? missing : unix2datetime(basic.listTimestamp)
        )

        # Add market-specific extended data
        row = base_data

        # Check for Hong Kong extended data
        if isdefined(ipo_data, :hkExData)
            hk_ex = ipo_data.hkExData
            row = merge(base_data, (
                ipo_price_min = hk_ex.ipoPriceMin,
                ipo_price_max = hk_ex.ipoPriceMax,
                list_price = hk_ex.listPrice,
                lot_size = Int(hk_ex.lotSize),
                entrance_price = hk_ex.entrancePrice,
                is_subscribe_status = hk_ex.isSubscribeStatus,
                apply_end_time = isempty(hk_ex.applyEndTime) ? missing : hk_ex.applyEndTime,
                apply_end_timestamp = hk_ex.applyEndTimestamp == 0.0 ? missing : unix2datetime(hk_ex.applyEndTimestamp))
            )
        # Check for US extended data
        elseif isdefined(ipo_data, :usExData)
            us_ex = ipo_data.usExData
            row = merge(base_data, (
                ipo_price_min = us_ex.ipoPriceMin,
                ipo_price_max = us_ex.ipoPriceMax,
                issue_size = us_ex.issueSize)
            )
        # Check for A-share extended data
        elseif isdefined(ipo_data, :cnExData)
            cn_ex = ipo_data.cnExData

            # Parse winning number data
            winning_nums = [(winning_name = wn.winningName, winning_info = wn.winningInfo) for wn in cn_ex.winningNumData]

            row = merge(base_data, (
                apply_code = cn_ex.applyCode,
                issue_size = cn_ex.issueSize,
                online_issue_size = cn_ex.onlineIssueSize,
                apply_upper_limit = cn_ex.applyUpperLimit,
                apply_limit_market_value = cn_ex.applyLimitMarketValue,
                is_estimate_ipo_price = cn_ex.isEstimateIpoPrice,
                ipo_price = cn_ex.ipoPrice,
                industry_pe_rate = cn_ex.industryPeRate,
                is_estimate_winning_ratio = cn_ex.isEstimateWinningRatio,
                winning_ratio = cn_ex.winningRatio,
                issue_pe_rate = cn_ex.issuePeRate,
                apply_time = isempty(cn_ex.applyTime) ? missing : cn_ex.applyTime,
                apply_timestamp = cn_ex.applyTimestamp == 0.0 ? missing : unix2datetime(cn_ex.applyTimestamp),
                winning_time = isempty(cn_ex.winningTime) ? missing : cn_ex.winningTime,
                winning_timestamp = cn_ex.winningTimestamp == 0.0 ? missing : unix2datetime(cn_ex.winningTimestamp),
                is_has_won = cn_ex.isHasWon,
                winning_num_data = winning_nums)
            )
        end

        push!(rows, row)
    end

    return DataFrame(rows)
end

"""
    get_trade_date(client::OpenDClient; kwargs...)

Request trading calendar for a specified market or security.

# Keyword Arguments

**Option 1: Query by Market**
- `market::Union{TradeDateMarket.T, Nothing} = nothing`: Market to query (e.g., TradeDateMarket.HK, TradeDateMarket.US, TradeDateMarket.CN)
- `begin_time::Union{String, Date, Nothing} = nothing`: Start date (format: "yyyy-MM-dd" or Date object)
- `end_time::Union{String, Date, Nothing} = nothing`: End date (format: "yyyy-MM-dd" or Date object)

**Option 2: Query by Specific Security**
- `security::Union{Qot_Common.Security, Nothing} = nothing`: Specific security to query
- `begin_time::Union{String, Date, Nothing} = nothing`: Start date
- `end_time::Union{String, Date, Nothing} = nothing`: End date

# Parameter Priority
When `security` is provided, it takes precedence and `market` parameter is ignored.

# Returns
- `DataFrame`: Trading calendar with the following columns:
  - `time`: Date string (format: "yyyy-MM-dd")
  - `timestamp`: Unix timestamp as DateTime
  - `trade_date_type`: Trading date type (enum):
    - `WHOLE`: Full trading day
    - `MORNING`: Morning trading only
    - `AFTERNOON`: Afternoon trading only

# Notes
- Protocol ID: 3219
- Rate limit: 30 requests per 30 seconds
- Historical data: Provides past 10 years of data
- Future data: Provides up to December 31 of current year
- Trading dates are derived by removing weekends and holidays from natural days
- Does NOT include temporary market closures

# Trading Date Types

The `trade_date_type` field indicates the trading session type:
- **WHOLE (0)**: Full trading day (most common)
- **MORNING (1)**: Morning session only (e.g., half-day trading before holidays)
- **AFTERNOON (2)**: Afternoon session only (rare)

# Examples
```julia
# Get Hong Kong trading calendar for 2024
hk_calendar = get_trade_date(client,
    market=TradeDateMarket.HK,
    begin_time="2024-01-01",
    end_time="2024-12-31")

# Get US trading calendar for Q1 2024
us_calendar = get_trade_date(client,
    market=TradeDateMarket.US,
    begin_time=Date(2024, 1, 1),
    end_time=Date(2024, 3, 31))

# Get A-share trading calendar
cn_calendar = get_trade_date(client,
    market=TradeDateMarket.CN,
    begin_time="2024-01-01",
    end_time="2024-12-31")

# Get trading calendar for a specific security
security = Qot_Common.Security(Int32(QotMarket.HK_Security), "00700")
tencent_calendar = get_trade_date(client,
    security=security,
    begin_time="2024-01-01",
    end_time="2024-12-31")

# Filter half-day trading dates
half_days = filter(row -> row.trade_date_type != TradeDateType.WHOLE, hk_calendar)
```
"""
function get_trade_date(client::OpenDClient; market::Union{TradeDateMarket.T, Nothing} = nothing, security::Union{Qot_Common.Security, Nothing} = nothing,
    begin_time::Union{Date, Nothing} = nothing, end_time::Union{Date, Nothing} = nothing
    )

    # Validate that either market or security is provided
    if market === nothing && security === nothing
        throw(ArgumentError("Either market or security must be provided"))
    end

    # Format dates to string
    begin_str = if begin_time === nothing
        ""
    else
        Dates.format(begin_time, "yyyy-mm-dd")
    end

    end_str = if end_time === nothing
        ""
    else
        Dates.format(end_time, "yyyy-mm-dd")
    end

    # Build C2S request
    c2s = Qot_RequestTradeDate.C2S(beginTime = begin_str, endTime = end_str)

    # If security is provided, it takes precedence
    if security !== nothing
        c2s.security = security
    elseif market !== nothing
        c2s.market = Int32(market)
    end

    # Create request and send
    req = Qot_RequestTradeDate.Request(c2s = c2s)
    resp = Client.api_request(client, UInt32(QOT_REQUEST_TRADE_DATE), req, PROTO_RESPONSE_MAP[UInt32(QOT_REQUEST_TRADE_DATE)])

    # Parse response
    trade_dates = resp.s2c.tradeDateList

    # Build DataFrame
    rows = NamedTuple[]

    for trade_date in trade_dates
        push!(rows, (
            time = trade_date.time,
            timestamp = trade_date.timestamp == 0.0 ? missing : unix2datetime(trade_date.timestamp),
            trade_date_type = TradeDateType.T(trade_date.tradeDateType))
        )
    end

    return DataFrame(rows)
end
end # module QuoteExtended
