module Filter

using DataFrames
using Dates

using ..Client
using ..Constants: Qot_Common, Qot_StockFilter, QotMarket, StockField, AccumulateField, FinancialField, KLType,
                   CustomIndicatorField, PatternField, FinancialQuarter, RelativePosition, SortDir, PROTO_RESPONSE_MAP,
                   QOT_STOCK_FILTER

export
    stock_filter,
    # Filter builder helpers
    base_filter,
    accumulate_filter,
    financial_filter,
    pattern_filter,
    custom_indicator_filter

# Helper function to create BaseFilter
"""
    base_filter(field::StockField.T; filter_min=nothing, filter_max=nothing, is_no_filter=true, sort_dir=SortDir.OptionStandardTypeNo)

Create a simple attribute filter.

# Arguments
- `field::StockField.T`: Stock field to filter on
- `filter_min`: Minimum value (closed interval), nothing means -∞
- `filter_max`: Maximum value (closed interval), nothing means +∞
- `is_no_filter`: Whether to skip filtering (true: no filter, false: apply filter)
- `sort_dir::SortDir.T`: Sort direction
"""
function base_filter(field::StockField.T; filter_min::Union{Real, Nothing} = nothing, filter_max::Union{Real, Nothing} = nothing, is_no_filter::Bool = true, sort_dir::SortDir.T = SortDir.No)
    # Create filter - set filterMin and filterMax directly in constructor
    # Note: ProtoBuf only encodes fields that differ from default values
    # Default for filterMin/filterMax is 0.0, so we need to always set them if provided
    return Qot_StockFilter.BaseFilter(
        fieldName = Int32(field),
        filterMin = filter_min === nothing ? 0.0 : Float64(filter_min),
        filterMax = filter_max === nothing ? 0.0 : Float64(filter_max),
        isNoFilter = is_no_filter,
        sortDir = Int32(sort_dir)
    )
end

# Helper function to create AccumulateFilter
"""
    accumulate_filter(field::AccumulateField.T, days::Int; filter_min=nothing, filter_max=nothing, is_no_filter=true, sort_dir=SortDir.OptionStandardTypeNo)

Create an accumulate attribute filter.

# Arguments
- `field::AccumulateField.T`: Accumulate field to filter on
- `days::Int`: Number of days for accumulation period
- `filter_min`: Minimum value
- `filter_max`: Maximum value
- `is_no_filter`: Whether to skip filtering
- `sort_dir::SortDir.T`: Sort direction

# Note
Maximum 10 filters of the same accumulate field type.
"""
function accumulate_filter(field::AccumulateField.T, days::Int; filter_min::Union{Real, Nothing} = nothing, filter_max::Union{Real, Nothing} = nothing, is_no_filter::Bool = true, sort_dir::SortDir.T = SortDir.No)
    # Create filter - set all fields in constructor
    return Qot_StockFilter.AccumulateFilter(
        fieldName = Int32(field),
        filterMin = filter_min === nothing ? 0.0 : Float64(filter_min),
        filterMax = filter_max === nothing ? 0.0 : Float64(filter_max),
        isNoFilter = is_no_filter,
        sortDir = Int32(sort_dir),
        days = Int32(days)
    )
end

# Helper function to create FinancialFilter
"""
    financial_filter(field::FinancialField.T, quarter::FinancialQuarter.T; filter_min=nothing, filter_max=nothing, is_no_filter=true, sort_dir=SortDir.OptionStandardTypeNo)

Create a financial attribute filter.

# Arguments
- `field::FinancialField.T`: Financial field to filter on
- `quarter::FinancialQuarter.T`: Financial quarter period
- `filter_min`: Minimum value
- `filter_max`: Maximum value
- `is_no_filter`: Whether to skip filtering
- `sort_dir::SortDir.T`: Sort direction
"""
function financial_filter(field::FinancialField.T, quarter::FinancialQuarter.T; filter_min::Union{Real, Nothing} = nothing, filter_max::Union{Real, Nothing} = nothing, is_no_filter::Bool = true, sort_dir::SortDir.T = SortDir.No)
    # Create filter - set all fields in constructor
    return Qot_StockFilter.FinancialFilter(
        fieldName = Int32(field),
        filterMin = filter_min === nothing ? 0.0 : Float64(filter_min),
        filterMax = filter_max === nothing ? 0.0 : Float64(filter_max),
        isNoFilter = is_no_filter,
        sortDir = Int32(sort_dir),
        quarter = Int32(quarter)
    )
end

# Helper function to create PatternFilter
"""
    pattern_filter(field::PatternField.T, kl_type::KLType.T; is_no_filter=true, consecutive_period=1)

Create a pattern technical indicator filter.

# Arguments
- `field::PatternField.T`: Pattern field to filter on
- `kl_type::KLType.T`: K-line type (supports K_60M, K_Day, K_Week, K_Month)
- `is_no_filter`: Whether to skip filtering
- `consecutive_period`: Number of consecutive periods (1-12)
"""
function pattern_filter(field::PatternField.T, kl_type::KLType.T; is_no_filter::Bool = true, consecutive_period::Int = 1)
    return Qot_StockFilter.PatternFilter(
        fieldName = Int32(field),
        klType = Int32(kl_type),
        isNoFilter = is_no_filter,
        consecutivePeriod = Int32(consecutive_period)
    )
end

# Helper function to create CustomIndicatorFilter
"""
custom_indicator_filter(
    first_field::CustomIndicatorField.T, second_field::CustomIndicatorField.T,
    relative_pos::RelativePosition.T, kl_type::KLType.T; field_value=nothing, 
    is_no_filter=true, first_params=Int32[], second_params=Int32[], consecutive_period=1
)

Create a custom technical indicator filter.

# Arguments
- `first_field::CustomIndicatorField.T`: First custom indicator field
- `second_field::CustomIndicatorField.T`: Second custom indicator field (or Value)
- `relative_pos::RelativePosition.T`: Relative position (More, Less, CrossUp, CrossDown)
- `kl_type::KLType.T`: K-line type
- `field_value`: Custom numeric value (when second_field is Value)
- `is_no_filter`: Whether to skip filtering
- `first_params`: Parameters for first indicator (e.g., MA: [period], MACD: [fast, slow, DIF])
- `second_params`: Parameters for second indicator
- `consecutive_period`: Number of consecutive periods (1-12)

# Note
Maximum 10 filters of the same custom indicator type.
Only same-type indicators can be compared.
"""
function custom_indicator_filter(
    first_field::CustomIndicatorField.T, second_field::CustomIndicatorField.T, relative_pos::RelativePosition.T, kl_type::KLType.T; 
    field_value::Union{Float64, Nothing} = nothing, is_no_filter::Bool = true, first_params::Vector{Int32} = Int32[], 
    second_params::Vector{Int32} = Int32[], consecutive_period::Int = 1
    )

    return Qot_StockFilter.CustomIndicatorFilter(
        firstFieldName = Int32(first_field),
        secondFieldName = Int32(second_field),
        relativePosition = Int32(relative_pos),
        fieldValue = field_value === nothing ? 0.0 : Float64(field_value),
        klType = Int32(kl_type),
        isNoFilter = is_no_filter,
        firstFieldParaList = first_params,
        secondFieldParaList = second_params,
        consecutivePeriod = Int32(consecutive_period)
    )
end

# Main stock filter function
"""
    stock_filter(client::OpenDClient; kwargs...)

Filter stocks based on various criteria (conditional stock screening).

# Keyword Arguments
- `market::QotMarket.T = QotMarket.CNSH_Security`: Stock market (CNSH_Security, CNSZ_Security for A-shares, HK_Security for HK, US_Security for US)
- `plate::Union{Qot_Common.Security, Nothing} = nothing`: Plate/sector filter
- `begin_idx::Int = 0`: Starting index for pagination
- `num::Int = 200`: Number of results per page (max 200)
- `base_filters::Vector{Qot_StockFilter.BaseFilter} = []`: Simple attribute filters
- `accumulate_filters::Vector{Qot_StockFilter.AccumulateFilter} = []`: Accumulate attribute filters (max 10 same-type)
- `financial_filters::Vector{Qot_StockFilter.FinancialFilter} = []`: Financial attribute filters
- `pattern_filters::Vector{Qot_StockFilter.PatternFilter} = []`: Pattern technical indicator filters
- `custom_indicator_filters::Vector{Qot_StockFilter.CustomIndicatorFilter} = []`: Custom technical indicator filters (max 10 same-type)

# Returns
- `DataFrame`: Filtered stock data with metadata

# Notes
- Protocol ID: 3215
- Rate limit: 10 requests per 30 seconds
- Max 200 results per page
- Recommended max 250 total filter conditions
- Cannot use pre-market/after-hours/night trading data
- Same field cannot be reused in simple/financial/pattern filters
- Cross-indicator type comparisons not supported
- **Pattern filters return only code and name columns (no numeric data)**
- Other filters (base/accumulate/financial/custom_indicator) return additional data columns

# Supported Plates
- Hong Kong: Industry and concept plates
- US: Industry plates
- A-shares: Industry, concept, and regional plates
- Special indices: HK.Motherboard, HK.GEM, US.NYSE, US.NASDAQ, SH.3000000, SZ.3000001, etc.
"""
function stock_filter(client::OpenDClient, market::QotMarket.T;
    plate::Union{Qot_Common.Security, Nothing} = nothing, begin_idx::Int = 0,
    num::Int = 200, base_filters::Vector{Qot_StockFilter.BaseFilter} = Qot_StockFilter.BaseFilter[],
    accumulate_filters::Vector{Qot_StockFilter.AccumulateFilter} = Qot_StockFilter.AccumulateFilter[],
    financial_filters::Vector{Qot_StockFilter.FinancialFilter} = Qot_StockFilter.FinancialFilter[],
    pattern_filters::Vector{Qot_StockFilter.PatternFilter} = Qot_StockFilter.PatternFilter[],
    custom_indicator_filters::Vector{Qot_StockFilter.CustomIndicatorFilter} = Qot_StockFilter.CustomIndicatorFilter[]
    )
    # Build C2S request
    c2s = Qot_StockFilter.C2S(begin_ = Int32(begin_idx), num = Int32(min(num, 200)), market = Int32(market))

    # Add plate if specified
    if plate !== nothing
        c2s.plate = plate
    end

    # Add filters
    if !isempty(base_filters)
        c2s.baseFilterList = base_filters
    end

    if !isempty(accumulate_filters)
        c2s.accumulateFilterList = accumulate_filters
    end

    if !isempty(financial_filters)
        c2s.financialFilterList = financial_filters
    end

    if !isempty(pattern_filters)
        c2s.patternFilterList = pattern_filters
    end

    if !isempty(custom_indicator_filters)
        c2s.customIndicatorFilterList = custom_indicator_filters
    end

    # Create request and send
    req = Qot_StockFilter.Request(c2s = c2s)

    resp = Client.api_request(client, UInt32(QOT_STOCK_FILTER), req, PROTO_RESPONSE_MAP[UInt32(QOT_STOCK_FILTER)])

    # Parse response
    s2c = resp.s2c
    stock_data_list = s2c.dataList

    @info "stock_filter response" total_count=s2c.allCount returned_count=length(stock_data_list) last_page=s2c.lastPage

    # Build DataFrame
    rows = NamedTuple[]

    for stock_data in stock_data_list
        # Format code with market prefix
        code = string(QotMarket.T(stock_data.security.market), ".", stock_data.security.code)

        # Parse base data into a Dict first
        base_dict = Dict{Symbol, Float64}()
        for bd in stock_data.baseDataList
            field_name = StockField.T(bd.fieldName)
            # Convert enum to Symbol for cleaner keys
            base_dict[Symbol(field_name)] = bd.value
        end

        # Parse accumulate data
        accumulate_dict = Dict{Tuple{Symbol, Int}, Float64}()
        for ad in stock_data.accumulateDataList
            field_name = AccumulateField.T(ad.fieldName)
            accumulate_dict[(Symbol(field_name), ad.days)] = ad.value
        end

        # Parse financial data
        financial_dict = Dict{Tuple{Symbol, Symbol}, Float64}()
        for fd in stock_data.financialDataList
            field_name = FinancialField.T(fd.fieldName)
            quarter = FinancialQuarter.T(fd.quarter)
            financial_dict[(Symbol(field_name), Symbol(quarter))] = fd.value
        end

        # Parse custom indicator data
        custom_indicator_dict = Dict{Tuple{Symbol, Symbol}, Float64}()
        for cid in stock_data.customIndicatorDataList
            field_name = CustomIndicatorField.T(cid.fieldName)
            kl_type = KLType.T(cid.klType)
            custom_indicator_dict[(Symbol(field_name), Symbol(kl_type))] = cid.value
        end

        # Create base row with code and name
        row_dict = Dict{Symbol, Any}(
            :code => code,
            :name => stock_data.name
        )

        # Add all base data fields as separate columns
        for (field, value) in base_dict
            row_dict[field] = value
        end

        # Add accumulate data fields with suffix
        for ((field, days), value) in accumulate_dict
            col_name = Symbol(string(field, "_", days, "d"))
            row_dict[col_name] = value
        end

        # Add financial data fields with suffix
        for ((field, quarter), value) in financial_dict
            col_name = Symbol(string(field, "_", quarter))
            row_dict[col_name] = value
        end

        # Add custom indicator data fields with suffix
        for ((field, kl_type), value) in custom_indicator_dict
            col_name = Symbol(string(field, "_", kl_type))
            row_dict[col_name] = value
        end

        push!(rows, NamedTuple(pairs(row_dict)))
    end

    df = DataFrame(rows)

    # Reorder columns: code and name first, then all other columns
    if ncol(df) > 2
        other_cols = setdiff(names(df), ["code", "name"])
        select!(df, :code, :name, other_cols...)
    end

    # Add metadata
    metadata!(df, "last_page", s2c.lastPage, style=:note)
    metadata!(df, "all_count", s2c.allCount, style=:note)

    return df
end

end # module MarketFilter
