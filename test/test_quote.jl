using Revise
using Futu
import Futu.Display
using Dates

# Set RSA private key path via environment variable
# Example: export FUTU_RSA_KEY_PATH="/path/to/your/private.pem"
rsa_key_path = get(ENV, "FUTU_RSA_KEY_PATH", joinpath(homedir(), ".futu", "private.pem"))
client = OpenDClient(rsa_private_key_path = rsa_key_path)
connect!(client)
is_connected(client)

user_info = get_user_info(client; flag = UserInfoField.QotRight)
global_state = get_global_state(client)

# 市场
SH = QotMarket.CNSH_Security
SZ = QotMarket.CNSZ_Security
HK = QotMarket.HK_Security
US = QotMarket.US_Security
owner_plate = get_owner_plate(client, ["BABA"]; market = US)

# ========================== 订阅 =============================
subscribe(
    client, ["601390", "601816", "600219"], 
    [SubType.Basic, SubType.OrderBook, SubType.RT, SubType.K_Day, SubType.K_1M, SubType.Ticker, SubType.Broker]; market = SH
)
subscribe(
    client, ["002424", "000100", "002367"], 
    [SubType.Basic, SubType.OrderBook, SubType.RT, SubType.K_Day, SubType.K_1M, SubType.Ticker, SubType.Broker]; market = SZ
)
subscribe(
    client, ["09988", "00005"], 
    [SubType.Basic, SubType.OrderBook, SubType.RT, SubType.K_Day, SubType.K_1M, SubType.Ticker, SubType.Broker]; market = HK
)
subscribe(
    client, ["BABA", "AAPL"], 
    [SubType.Basic, SubType.OrderBook, SubType.RT, SubType.K_Day, SubType.K_1M, SubType.Ticker, SubType.Broker]; market = US
)

# 获取订阅信息
get_sub_info(client)


# =================== 推送回调 ===================
# 实时报价回调
function on_basic_quote(quotes)
    for _quote in quotes
        Display.render_basic_quote(stdout, _quote)
    end
end
update_quote(client, ["03759"], SubType.Basic, on_basic_quote; market = HK)
update_quote(client, ["03759"], SubType.Basic, on_basic_quote; market = HK, is_sub = false)

# 实时摆盘回调
function on_order_book(quotes)
    Display.render_order_book(stdout, quotes)
end
update_quote(client, ["03759"], SubType.OrderBook, on_order_book; market = HK)
update_quote(client, ["03759"], SubType.OrderBook, on_order_book; market = HK, is_sub = false)

# 实时 K 线回调
function on_kline(kl_data)
    Display.render_kline(stdout, kl_data; max_rows = 5)
end
# 注册日K回调
update_quote(client, ["03759"], SubType.K_Day, on_kline; market = HK)
update_quote(client, ["03759"], SubType.K_Day, on_kline; market = HK, is_sub = false)
# 注册1分钟K线回调
update_quote(client, ["03759"], SubType.K_1M, on_kline; market = HK)
update_quote(client, ["03759"], SubType.K_1M, on_kline; market = HK, is_sub = false)

# 实时分时回调
function on_rt(rt_data)
    Display.render_rt(stdout, rt_data; max_rows = 10)
end
update_quote(client, ["03759"], SubType.RT, on_rt; market = HK)
update_quote(client, ["03759"], SubType.RT, on_rt; market = HK, is_sub = false)

# 实时逐笔回调
function on_ticker(ticker_data)
    Display.render_ticker(stdout, ticker_data; max_rows = 15)
end
update_quote(client, ["03759"], SubType.Ticker, on_ticker; market = HK)
update_quote(client, ["03759"], SubType.Ticker, on_ticker; market = HK, is_sub = false)

# 实时经纪队列回调
function on_broker(broker_data)
    Display.render_broker(stdout, broker_data; max_rows = 10)
end
update_quote(client, ["03759"], SubType.Broker, on_broker; market = HK)
update_quote(client, ["03759"], SubType.Broker, on_broker; market = HK, is_sub = false)


# =================== 拉取 ======================
# 获取行情快照  (表列太多，后续显示优化)
market_snapshot = get_market_snapshot(client, ["601390", "601816", "600219"]; market = SH)
market_snapshot = get_market_snapshot(client, ["002424", "000100", "002367"]; market = SZ)
market_snapshot = get_market_snapshot(client, ["00005", "09988"]; market = HK)

# 获取实时报价
basic_quote = get_basic_quote(client, ["09988"])

# 获取实时 K 线
get_kline(client, "00700")
get_kline(client, "601390"; market = SH, kl_type = KLType.K_1M, count = 331)

# 获取实时分时
rt_data = get_rt(client, "000100"; market = SZ)
# 获取实时逐笔
ticker = get_ticker(client, "09988")
# 获取实时摆盘
order_book = get_order_book(client, "09988")
# 获取实时经纪队列
broker_queue = get_broker_queue(client, "00005")

# ======================= 基本数据 =============================
# 获取市场状态
market_state = get_market_state(client, ["601390", "601816"]; market = SH)

# 获取资金流向
capital_flow_daily = get_capital_flow(
    client, "00005"; market = HK, period = PeriodType.DAY,
    begin_time = Date(2025, 1, 1), end_time = today()
)

# 获取资金分布
capital_distribution = get_capital_distribution(client, "09988")

# 获取股票所属板块
owner_plate = get_owner_plate(client, ["601390", "601816"]; market = SH)

# 获取历史K线
history_kline = get_history_kline(client, "09618")

# Get quota summary only
quota = get_history_kl_quota(client)
println("Used: $(quota.used_quota), Remaining: $(quota.remain_quota)")

# Get quota with detailed pull history. detail_list is empty
quota_detail = get_history_kl_quota(client; get_detail = true)

# 获取复权因子
rehab = get_rehab(client, "601816"; market = SH)

unsubscribe(
    client, ["601390", "601816", "600219"], 
    [SubType.Basic, SubType.OrderBook, SubType.RT, SubType.K_Day, SubType.K_1M, SubType.Ticker, SubType.Broker]; market = SH
)
unsubscribe(
    client, ["002424", "000100", "002367"], 
    [SubType.Basic, SubType.OrderBook, SubType.RT, SubType.K_Day, SubType.K_1M, SubType.Ticker, SubType.Broker]; market = SZ
)
unsubscribe(
    client, ["09988", "00005"], 
    [SubType.Basic, SubType.OrderBook, SubType.RT, SubType.K_Day, SubType.K_1M, SubType.Ticker, SubType.Broker]
)
get_sub_info(client)
disconnect!(client)
