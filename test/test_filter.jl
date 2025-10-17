using Revise
using Futu
import Futu.Constants
import Futu.Display
using Dates

rsa_key_path = get(ENV, "FUTU_RSA_KEY_PATH", joinpath(homedir(), ".futu", "private.pem"))
client = OpenDClient(rsa_private_key_path = rsa_key_path)
connect!(client)
is_connected(client)

# Filter A-share stocks by market cap and PE ratio
println("\n=== 1. Filter by Market Cap (10B-100B) and PE (<30) ===")
base_filters = [
    base_filter(Constants.StockField.MarketVal, filter_min=100e9, filter_max=1000e9, is_no_filter=false),
    base_filter(Constants.StockField.PeTTM, filter_min=0, filter_max=20, is_no_filter=false, sort_dir=Constants.SortDir.Ascend)
]
df_base = stock_filter(client, QotMarket.CNSH_Security; base_filters = base_filters)

# Filter with accumulate (5-day change rate)
println("\n=== 2. Filter by 5-day Change Rate (>10%) ===")
acc_filters = [accumulate_filter(Constants.AccumulateField.ChangeRate, 5, filter_min=10.0, is_no_filter=false)]
df_acc = stock_filter(client, QotMarket.CNSH_Security, accumulate_filters=acc_filters)

# Filter with financial metrics
println("\n=== 3. Filter by Net Profit Growth (>20%) ===")
fin_filters = [
    financial_filter(
        Constants.FinancialField.NetProfitGrowth,
        Constants.FinancialQuarter.Annual,  # Use Annual for A-shares (MostRecentQuarter not supported)
        filter_min=2000.0, is_no_filter=false
    )
]
df_fin = stock_filter(client, QotMarket.CNSH_Security, financial_filters=fin_filters)

# Custom indicator: MA5 greater than MA10 (more common than CrossUp)
println("\n=== 4. Filter by MA5 > MA10 ===")
custom_filters = [custom_indicator_filter(
    Constants.CustomIndicatorField.MA5,
    Constants.CustomIndicatorField.MA10,
    Constants.RelativePosition.More,  # Use "More" instead of "CrossUp" for more results
    Constants.KLType.K_Day,
    is_no_filter=false)
]
df_custom = stock_filter(client, QotMarket.CNSH_Security, custom_indicator_filters=custom_filters)

# Alternative: Pattern filter - MA bullish alignment
println("\n=== 5. Filter by MA Bullish Alignment ===")
pattern_filters = [pattern_filter(
    Constants.PatternField.MAAlignmentLong,
    Constants.KLType.K_Day,
    is_no_filter=false)
]
df_pattern = stock_filter(client, QotMarket.CNSH_Security, pattern_filters=pattern_filters)

disconnect!(client)