
using FutuAPI.MarketFilter
using FutuAPI.Constants

# Example 1: Basic filtering by market cap and PE
filters = [
    base_filter(StockField.StockField_MarketVal,
        filter_min=10e9, filter_max=100e9, is_no_filter=false),
    base_filter(StockField.StockField_PeTTM,
        filter_min=0, filter_max=30, is_no_filter=false,
        sort_dir=SortDir.SortDir_Ascend)
]
df = stock_filter(client, market=QotMarket.CNSH_Security, base_filters=filters)

# Example 2: Find stocks with strong momentum
acc_filters = [
    accumulate_filter(AccumulateField.AccumulateField_ChangeRate, 5,
        filter_min=10.0, is_no_filter=false),
    accumulate_filter(AccumulateField.AccumulateField_TurnoverRate, 5,
        filter_min=50.0, is_no_filter=false)
]
df = stock_filter(client, accumulate_filters=acc_filters)

# Example 3: Growth stocks with good financials
fin_filters = [
    financial_filter(FinancialField.FinancialField_NetProfitGrowth,
        FinancialQuarter.FinancialQuarter_MostRecentQuarter,
        filter_min=20.0, is_no_filter=false),
    financial_filter(FinancialField.FinancialField_ReturnOnEquityRate,
        FinancialQuarter.FinancialQuarter_MostRecentQuarter,
        filter_min=15.0, is_no_filter=false)
]
df = stock_filter(client, financial_filters=fin_filters)

# Example 4: Technical breakout pattern
pattern_filters = [
    pattern_filter(PatternField.PatternField_MAAlignmentLong,
        Qot_Common.KLType.K_Day,
        is_no_filter=false,
        consecutive_period=2)
]
df = stock_filter(client, pattern_filters=pattern_filters)

# Example 5: Custom MA crossover
custom_filters = [
    custom_indicator_filter(
        CustomIndicatorField.CustomIndicatorField_MA5,
        CustomIndicatorField.CustomIndicatorField_MA10,
        RelativePosition.RelativePosition_CrossUp,
        Qot_Common.KLType.K_Day,
        is_no_filter=false)
]
df = stock_filter(client, custom_indicator_filters=custom_filters)

# Example 6: Complex multi-filter strategy
df = stock_filter(client,
    market = QotMarket.CNSH_Security,
    base_filters = [
        base_filter(StockField.StockField_MarketVal, filter_min=5e9, is_no_filter=false)
    ],
    accumulate_filters = [
        accumulate_filter(AccumulateField.AccumulateField_ChangeRate, 10, filter_min=15.0,
is_no_filter=false)
    ],
    financial_filters = [
        financial_filter(FinancialField.FinancialField_NetProfitGrowth,
            FinancialQuarter.FinancialQuarter_MostRecentQuarter,
            filter_min=25.0, is_no_filter=false)
    ]
)

# Access the data
for row in eachrow(df)
    println("$(row.name) ($(row.code))")

    # Access specific metrics
    if haskey(row.base_data, StockField.StockField_CurPrice)
        println("  Price: $(row.base_data[StockField.StockField_CurPrice])")
    end
end
