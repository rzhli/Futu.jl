using Revise
using Futu, Dates, DataFrames
import Futu.Constants

# Set RSA private key path via environment variable
# Example: export FUTU_RSA_KEY_PATH="/path/to/your/private.pem"
rsa_key_path = get(ENV, "FUTU_RSA_KEY_PATH", joinpath(homedir(), ".futu", "private.pem"))
client = OpenDClient(rsa_private_key_path = rsa_key_path)
connect!(client)
is_connected(client)

# =================== 相关衍生品 ===================

# 获取期权链到期日
option_expiration_date = get_option_expiration_date(client, "00005")
# 获取期权链
option_chain = get_option_chain(client, "00005")
# 筛选窝轮
# Basic usage - get all warrants for a stock
df = get_warrant(client, "00700")

# Screen warrants with multiple filters
warrants = get_warrant(client, "00700",
    type_list = [Constants.WarrantType.Buy],
    issuer_list = [Constants.Issuer.SG, Constants.Issuer.GS],
    premium_max = 15.0,
    leverage_ratio_min = 5.0,
    maturity_time_min = "2024-06-01",
    maturity_time_max = "2026-12-31",
    sort_field = Constants.SortField.Premium,
    ascending = true,
    num = 100
)
# Pagination support
df_page1 = get_warrant(client, "00700", begin_idx=0, num=200)
df_page2 = get_warrant(client, "00700", begin_idx=200, num=200)

# 获取窝轮和期货列表
# Get all warrants for Tencent (00700)
warrants_df = get_reference(client, "00700", market=QotMarket.HK_Security, reference_type=ReferenceType.Warrant)
# Get related futures contracts for a main contract
futures_df = get_reference(client, "HSImain", market=QotMarket.HK_Future, reference_type=ReferenceType.Future)

# 获取期权合约资料
# Get info for specific futures contracts
# 如果有美国期货权限
us_future_codes = ["CLmain", "GCmain"]      # 原油主连、黄金主连
df = get_future_info(client, us_future_codes)

# Get info for HSI futures
# 如果有香港期货权限
hsi_codes = ["HSImain", "MHImain"]      # 恒指主连、小型恒指主连
df = get_future_info(client, hsi_codes, market=QotMarket.HK_Future)
println(df)

# Access trading times
for row in eachrow(df)
    println("$(row.name): $(length(row.trade_times)) trading sessions")
    for (i, tt) in enumerate(row.trade_times)
        println("  Session $i: $(tt.begin_min) - $(tt.end_min) minutes")
    end
end
# 结果

"""
恒指主连 (2510): 3 trading sessions
  Session 1: 555.0 - 720.0 minutes
  Session 2: 780.0 - 990.0 minutes
  Session 3: 1035.0 - 180.0 minutes
小恒指主连 (2510): 3 trading sessions
  Session 1: 555.0 - 720.0 minutes
  Session 2: 780.0 - 990.0 minutes
  Session 3: 1035.0 - 180.0 minutes

这是香港期货市场（恒生指数期货和小型恒指期货）的交易时间段，使用的是从午夜（00:00）开始计算的分钟数。让我解释一下：

  交易时段解析

  Session 1: 555.0 - 720.0 minutes

  - 开始: 555 分钟 = 9小时15分 = 09:15
  - 结束: 720 分钟 = 12小时 = 12:00
  - 说明: 早盘交易时段

  Session 2: 780.0 - 990.0 minutes

  - 开始: 780 分钟 = 13小时 = 13:00
  - 结束: 990 分钟 = 16小时30分 = 16:30
  - 说明: 午盘交易时段

  Session 3: 1035.0 - 180.0 minutes ⚠

  - 开始: 1035 分钟 = 17小时15分 = 17:15
  - 结束: 180 分钟 = 3小时 = 03:00 (次日)
  - 说明: 夜盘交易时段（跨日）

  关键说明

  Session 3 跨越午夜：
  - 开始时间 (1035 分钟) 大于 结束时间 (180 分钟)
  - 这表示交易从当天 17:15 开始，持续到第二天凌晨 03:00
  - 这是典型的夜盘交易时段

  完整交易时间表

  | 时段        | 开始时间  | 结束时间       | 说明  |
  |-----------|-------|------------|-----|
  | Session 1 | 09:15 | 12:00      | 早盘  |
  | Session 2 | 13:00 | 16:30      | 午盘  |
  | Session 3 | 17:15 | 03:00 (次日) | 夜盘  |

  如何判断跨日

  for (i, tt) in enumerate(row.trade_times)
      start_hour = div(tt.begin_min, 60)
      start_min = mod(tt.begin_min, 60)
      end_hour = div(tt.end_min, 60)
      end_min = mod(tt.end_min, 60)

      if tt.end_min < tt.begin_min
          # 跨日交易
          println("  Session $i: $(start_hour):$(lpad(start_min,2,'0')) - $(end_hour):$(lpad(end_min,2,'0')) (次日)")
      else
          println("  Session $i: $(start_hour):$(lpad(start_min,2,'0')) - $(end_hour):$(lpad(end_min,2,'0'))")
      end
  end

  这种设计允许香港期货市场提供几乎全天候的交易服务，特别是夜盘时段可以覆盖欧美市场的主要交易时间。
"""


# =================== 全市场筛选模块 =====================

# Get all stocks in HSI constituent stocks
hsi_stocks = get_plate_security(client, "HSI Constituent Stocks", market = QotMarket.HK_Security, 
sort_field = Constants.SortField.Code, ascending = true)

# Get stocks in Shanghai Main Board sorted by name
sh_stocks = get_plate_security(client, "LIST3000000", market = QotMarket.CNSH_Security, 
sort_field = Constants.SortField.Code
)

# 获取板块列表
plate_set = get_plate_set(client, QotMarket.HK_Security)
us_plate_set = get_plate_set(client, QotMarket.US_Security; plate_set_type = Constants.PlateSetType.Industry)
# Get NASDAQ 100 constituents
nasdaq100 = get_plate_security(client, "LIST2004", market = QotMarket.US_Security)

# 获取静态数据
# 获取香港/上海/深圳所有股票
# Get all Hong Kong/SH/SZ stocks
hk_stocks = get_static_info(client, market = QotMarket.HK_Security, sec_type = Constants.SecurityType.Eqty)
sh_stocks = get_static_info(client, market = QotMarket.CNSH_Security, sec_type = Constants.SecurityType.Eqty)
sz_stocks = get_static_info(client, market = QotMarket.CNSZ_Security, sec_type = Constants.SecurityType.Eqty)

# Get all US indices
us_indices = get_static_info(client,market = QotMarket.US_Security, sec_type = Constants.SecurityType.Index)

# Get specific securities (takes precedence over market/type)
securities = [
    Constants.Qot_Common.Security(Int32(QotMarket.HK_Security), "00700"),  # Tencent
    Constants.Qot_Common.Security(Int32(QotMarket.US_Security), "AAPL"),   # Apple
    Constants.Qot_Common.Security(Int32(QotMarket.CNSH_Security), "600000") # Pudong Bank
]
specific_stocks = get_static_info(client, security_list = securities)

# Check for unrecognized stocks
for row in eachrow(specific_stocks)
    if row.delisting
        println("Unrecognized/delisted: \$(row.code) - \$(row.name)")
    end
end

# 获取特定证券（优先级更高）
securities = [
Constants.Qot_Common.Security(Int32(QotMarket.HK_Security), "00700"),  # 腾讯
Constants.Qot_Common.Security(Int32(QotMarket.US_Security), "AAPL")    # 苹果
]
specific_stocks = get_static_info(client, security_list = securities)

# 检查退市股票
for row in eachrow(specific_stocks)
    if row.delisting
        println("未知/退市: $(row.code) - $(row.name)")
    end
end

# 获取香港 IPO 列表
hk_ipos = get_ipo_list(client, market = QotMarket.HK_Security)
println(hk_ipos)
# 获取美国 IPO 列表
us_ipos = get_ipo_list(client, market = QotMarket.US_Security)
println(us_ipos)
# 获取 A 股 IPO 列表
cn_ipos = get_ipo_list(client, market = QotMarket.CNSH_Security)
println(cn_ipos)
# 筛选正在认购的香港 IPO
hk_subscribing = filter(row -> row.is_subscribe_status, hk_ipos)

# 筛选已公布中签号的 A 股 IPO
cn_won = filter(row -> row.is_has_won, cn_ipos)

# 1. 获取香港市场 2024 年全年交易日历
hk_calendar = get_trade_date(client; market = Constants.TradeDateMarket.HK, begin_time = Date(2024, 1, 1), end_time = Date(2024, 12, 31))

# 获取交易日历
# 2. 获取美股 Q1 交易日历
us_calendar = get_trade_date(client; market = Constants.TradeDateMarket.US, begin_time = Date(2024, 1, 1), end_time = Date(2024, 3, 31))

# 3. 获取 A 股（上海）交易日历
sh_calendar = get_trade_date(client; market = Constants.TradeDateMarket.CN, begin_time = Date(2024, 1, 1), end_time = Date(2024, 12, 31))    

# 4. 获取特定证券的交易日历
security = Constants.Qot_Common.Security(Int32(QotMarket.CNSH_Security), "601816")
tencent_calendar = get_trade_date(client; security = security, begin_time = Date(2024, 1, 1), end_time = Date(2024, 12, 31))

# 5. 筛选半天交易日
half_days = filter(row -> row.trade_date_type != Constants.TradeDateType.Whole, hk_calendar)

# 6. 统计交易日数量
println("2024年香港市场交易日数量: ", nrow(hk_calendar))

# 7. 查看最近的交易日
println("最近5个交易日:")
println(last(hk_calendar, 5))

disconnect!(client)