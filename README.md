# Futu.jl

A comprehensive Julia SDK for Futu OpenAPI, providing complete access to market data, trading functions, and real-time subscriptions. This SDK implements the full Futu OpenAPI protocol with support for Hong Kong, US, China A-shares, and other markets.

## Features

### Core Modules

#### **Client** - Connection & Authentication
- Connect to Futu OpenD gateway with RSA encryption support
- Get global state, delay statistics, and user information
- Connection management with keep-alive functionality

#### **Quote** - Real-time Market Data
- **Subscription**: Subscribe to real-time quotes, order books, K-lines, tickers, brokers
- **Push Callbacks**: Register callbacks for real-time data updates
- **Market Data**: Get market snapshots, basic quotes, K-lines, real-time data
- **Order Book**: Get order book depth and broker queues
- **Capital Flow**: Analyze capital flow and distribution by order size
- **Market State**: Check market trading status

#### **QuoteExtended** - Advanced Market Information
- **Derivatives**: Options chains, warrants screening, futures information
- **Reference Data**: Get related warrants and futures for securities
- **Plate/Sector**: Get plate lists and securities within plates
- **Static Info**: Retrieve all stocks by market and security type
- **IPO Information**: Track IPO listings and application status
- **Trading Calendar**: Get trading dates with holiday information

#### **Filter** - Stock Screening
- **Base Filters**: Filter by market cap, PE ratio, price, volume, etc.
- **Accumulate Filters**: Filter by N-day change rate, turnover, etc.
- **Financial Filters**: Filter by financial metrics (profit growth, ROE, etc.)
- **Pattern Filters**: Technical patterns (MA alignment, breakthrough, etc.)
- **Custom Indicators**: Custom technical indicator comparisons

#### **Customization** - Alerts & Watchlists
- **Price Reminders**: Set price alerts with various trigger conditions
- **Watchlist Management**: Create and manage custom watchlists
- **Push Notifications**: Real-time callbacks for price alerts

#### **Trade** - Trading Functions
- **Account Management**: Get account list, funds, positions, margin ratios
- **Order Management**: Place, modify, cancel orders with advanced order types
- **Order Query**: Get open orders, historical orders, and order fills
- **Fee Analysis**: Query detailed order fees and commissions
- **Real-time Updates**: Subscribe to order and trade push notifications

## Installation

```julia
using Pkg

# Clone and develop locally
Pkg.develop(path="/path/to/FutuAPI")
```

## Prerequisites

1. **Futu OpenD Gateway**: Download and run Futu OpenD
   - Download from: https://www.futunn.com/download/OpenAPI
   - Default connection: `127.0.0.1:11111`

2. **Trading Account**:
   - Futu/moomoo account (real or paper trading)
   - API access enabled in account settings

3. **RSA Key (Recommended)**:
   - Generate RSA private key for secure connection
   - Store in `~/.futu/private.pem` or specify path

4. **Julia Environment**:
   - Julia 1.6+ (tested on 1.12)

## Quick Start

```julia
using Futu

# Set RSA key path (optional but recommended)
rsa_key_path = get(ENV, "FUTU_RSA_KEY_PATH", joinpath(homedir(), ".futu", "private.pem"))

# Create and connect client
client = OpenDClient(rsa_private_key_path = rsa_key_path)
connect!(client)

# Check connection
is_connected(client)  # true

# Get user info
user_info = get_user_info(client; flag = UserInfoField.QotRight)

# Get global state
global_state = get_global_state(client)

# Subscribe to real-time data
subscribe(client, ["00700", "09988"], [SubType.Basic, SubType.OrderBook])

# Get market snapshot
snapshot = get_market_snapshot(client, ["00700", "09988"])

# Disconnect
disconnect!(client)
```

## API Documentation

### 1. Client Module

#### Connection Management
```julia
# Create client with RSA encryption
client = OpenDClient(
    host = "127.0.0.1",
    port = 11111,
    rsa_private_key_path = "/path/to/private.pem"
)

# Connect/disconnect
connect!(client)
is_connected(client)
disconnect!(client)
```

#### System Information
```julia
# Get global state (markets, login status, server info)
global_state = get_global_state(client)

# Get delay statistics
stats = get_delay_statistics(client)

# Get user information
user_info = get_user_info(client; flag = UserInfoField.Basic)
user_info = get_user_info(client; flag = UserInfoField.QotRight)
user_info = get_user_info(client; flag = UserInfoField.API)
```

### 2. Quote Module

#### Subscription
```julia
# Subscribe to multiple markets
subscribe(client, ["601390", "601816"],
    [SubType.Basic, SubType.OrderBook, SubType.K_Day];
    market = QotMarket.CNSH_Security)

subscribe(client, ["00700", "09988"],
    [SubType.Basic, SubType.OrderBook, SubType.Ticker];
    market = QotMarket.HK_Security)

# Get subscription info
get_sub_info(client)

# Unsubscribe
unsubscribe(client, ["00700"], [SubType.Basic])
```

#### Real-time Push Callbacks
```julia
# Register quote callback
function on_basic_quote(quotes)
    for quote in quotes
        println("$(quote["code"]): $(quote["last_price"])")
    end
end
update_quote(client, ["00700"], SubType.Basic, on_basic_quote)

# Register order book callback
function on_order_book(book)
    println("Order book for $(book["code"])")
    println("Best bid: $(book["bid_list"][1])")
end
update_quote(client, ["00700"], SubType.OrderBook, on_order_book)

# Register K-line callback
function on_kline(kl_data)
    println("K-line update for $(kl_data["code"])")
end
update_quote(client, ["00700"], SubType.K_Day, on_kline)

# Unregister callback
update_quote(client, ["00700"], SubType.Basic, on_basic_quote; is_sub = false)
```

#### Market Data Queries
```julia
# Get market snapshot
snapshot = get_market_snapshot(client, ["00700", "09988"]; market = QotMarket.HK_Security)

# Get basic quote
quote = get_basic_quote(client, ["00700"])

# Get K-line data
kline = get_kline(client, "00700"; kl_type = KLType.K_Day, count = 100)
kline = get_kline(client, "601390"; market = QotMarket.CNSH_Security,
    kl_type = KLType.K_1M, count = 331)

# Get real-time data
rt_data = get_rt(client, "00700")

# Get ticker (tick-by-tick)
ticker = get_ticker(client, "09988")

# Get order book
order_book = get_order_book(client, "09988")

# Get broker queue
broker_queue = get_broker_queue(client, "00005")
```

#### Market Analysis
```julia
# Get market state
market_state = get_market_state(client, ["00700", "09988"])

# Get capital flow (historical)
capital_flow = get_capital_flow(client, "00005";
    period = PeriodType.DAY,
    begin_time = Date(2025, 1, 1),
    end_time = today())

# Get capital distribution (real-time)
distribution = get_capital_distribution(client, "09988")

# Get owner plates
plates = get_owner_plate(client, ["00700"])

# Get historical K-line
history_kline = get_history_kline(client, "00700")

# Get K-line quota
quota = get_history_kl_quota(client)

# Get rehab factors
rehab = get_rehab(client, "00700")
```

### 3. Quote Extended Module

#### Options & Derivatives
```julia
# Get option expiration dates
expiration_dates = get_option_expiration_date(client, "00700")

# Get option chain
option_chain = get_option_chain(client, "00700")

# Screen warrants
warrants = get_warrant(client, "00700",
    type_list = [Constants.WarrantType.Buy],
    issuer_list = [Constants.Issuer.SG],
    premium_max = 15.0,
    leverage_ratio_min = 5.0,
    num = 100
)

# Get related warrants/futures
warrants = get_reference(client, "00700",
    reference_type = ReferenceType.Warrant)
futures = get_reference(client, "HSImain",
    market = QotMarket.HK_Future,
    reference_type = ReferenceType.Future)

# Get futures information
futures_info = get_future_info(client, ["HSImain", "MHImain"],
    market = QotMarket.HK_Future)
```

#### Market Structure
```julia
# Get plate securities
hsi_stocks = get_plate_security(client, "HSI Constituent Stocks",
    market = QotMarket.HK_Security)

# Get plate set
plate_set = get_plate_set(client, QotMarket.HK_Security)
us_industries = get_plate_set(client, QotMarket.US_Security;
    plate_set_type = Constants.PlateSetType.Industry)

# Get static info (all stocks)
hk_stocks = get_static_info(client,
    market = QotMarket.HK_Security,
    sec_type = Constants.SecurityType.Eqty)

# Get specific securities info
securities = [
    Constants.Qot_Common.Security(Int32(QotMarket.HK_Security), "00700"),
    Constants.Qot_Common.Security(Int32(QotMarket.US_Security), "AAPL")
]
info = get_static_info(client, security_list = securities)
```

#### IPO & Calendar
```julia
# Get IPO list
hk_ipos = get_ipo_list(client, market = QotMarket.HK_Security)
us_ipos = get_ipo_list(client, market = QotMarket.US_Security)

# Filter IPOs
subscribing = filter(row -> row.is_subscribe_status, hk_ipos)

# Get trading calendar
calendar = get_trade_date(client;
    market = Constants.TradeDateMarket.HK,
    begin_time = Date(2024, 1, 1),
    end_time = Date(2024, 12, 31))

# Filter half-day trading
half_days = filter(row -> row.trade_date_type != Constants.TradeDateType.Whole, calendar)
```

### 4. Filter Module

```julia
# Base filters (market cap, PE ratio, etc.)
base_filters = [
    base_filter(Constants.StockField.MarketVal,
        filter_min = 100e9, filter_max = 1000e9),
    base_filter(Constants.StockField.PeTTM,
        filter_min = 0, filter_max = 20,
        sort_dir = Constants.SortDir.Ascend)
]
df = stock_filter(client, QotMarket.CNSH_Security; base_filters = base_filters)

# Accumulate filters (N-day change)
acc_filters = [
    accumulate_filter(Constants.AccumulateField.ChangeRate, 5, filter_min = 10.0)
]
df = stock_filter(client, QotMarket.CNSH_Security, accumulate_filters = acc_filters)

# Financial filters
fin_filters = [
    financial_filter(
        Constants.FinancialField.NetProfitGrowth,
        Constants.FinancialQuarter.Annual,
        filter_min = 2000.0
    )
]
df = stock_filter(client, QotMarket.CNSH_Security, financial_filters = fin_filters)

# Pattern filters
pattern_filters = [
    pattern_filter(
        Constants.PatternField.MAAlignmentLong,
        Constants.KLType.K_Day
    )
]
df = stock_filter(client, QotMarket.CNSH_Security, pattern_filters = pattern_filters)

# Custom indicator filters
custom_filters = [
    custom_indicator_filter(
        Constants.CustomIndicatorField.MA5,
        Constants.CustomIndicatorField.MA10,
        Constants.RelativePosition.More,
        Constants.KLType.K_Day
    )
]
df = stock_filter(client, QotMarket.CNSH_Security,
    custom_indicator_filters = custom_filters)
```

### 5. Customization Module

#### Price Reminders
```julia
# Set price reminder
key = set_price_reminder(client, "00700";
    market = QotMarket.HK_Security,
    reminder_type = Constants.PriceReminderType.PriceUp,
    value = 450.0,
    note = "Target price reached",
    freq = Constants.PriceReminderFreq.OnceADay
)

# Get reminders
reminders = get_price_reminder(client, "00700", market = QotMarket.HK_Security)
all_reminders = get_price_reminder(client, market = QotMarket.HK_Security)

# Modify reminder
modify_price_reminder(client, "00700", key,
    market = QotMarket.HK_Security,
    value = 460.0,
    note = "Updated target"
)

# Enable/disable reminder
disable_price_reminder(client, "00700", key, market = QotMarket.HK_Security)
enable_price_reminder(client, "00700", key, market = QotMarket.HK_Security)

# Delete reminders
delete_price_reminder(client, "00700", key, market = QotMarket.HK_Security)
delete_all_price_reminders(client, "00700", market = QotMarket.HK_Security)

# Register push callback
function on_price_reminder(data)
    println("Price alert: $(data["code"]) reached $(data["price"])")
end
update_price_reminder(client, on_price_reminder)
```

#### Watchlist Management
```julia
# Get security groups
custom_groups = get_user_security_group(client)
system_groups = get_user_security_group(client,
    group_type = Constants.GroupType.System)

# Get securities in group
my_stocks = get_user_security(client, "自选股")

# Modify watchlist
modify_user_security(client, "自选股", ["00700", "09988"],
    market = QotMarket.HK_Security,
    operation = Constants.ModifyUserSecurityOp.Add
)

modify_user_security(client, "自选股", ["00700"],
    operation = Constants.ModifyUserSecurityOp.Del
)
```

### 6. Trade Module

#### Account Management
```julia
# Create trade client
tc = TradeClient(rsa_private_key_path = rsa_key_path)
connect!(tc.client)

# Lock/unlock trade
unlock_trade(tc, "your_password_md5", is_md5 = true)
lock_trade(tc)

# Get account list
accounts = get_account_list(tc.client)

# Get account funds
funds = get_funds(tc.client, acc_id, Constants.TrdEnv.Simulate)

# Get max tradable quantities
max_qty = get_max_trd_qtys(tc.client, acc_id, Constants.TrdEnv.Simulate,
    "00700", 450.0, Constants.OrderType.Market)

# Get positions
positions = get_position_list(tc.client, acc_id, Constants.TrdEnv.Simulate)

# Get margin ratio
margin = get_margin_ratio(tc.client, acc_id, Constants.TrdEnv.Simulate;
    security_list = ["00700", "09988"])

# Get cash flow
cash_flow = get_account_cash_flow(tc.client, acc_id,
    Constants.TrdEnv.Real, "2025-10-16")
```

#### Order Management
```julia
# Place market order
order_id, order_id_ex = place_order(
    tc.client, acc_id, Constants.TrdEnv.Simulate,
    "09988", Constants.TrdSecMarket.HK,
    Constants.TrdSide.Buy, Constants.OrderType.Market, 100.0
)

# Place limit order
order_id, order_id_ex = place_order(
    tc.client, acc_id, Constants.TrdEnv.Simulate,
    "00700", Constants.TrdSecMarket.HK,
    Constants.TrdSide.Buy, Constants.OrderType.Normal, 100.0;
    price = 450.0
)

# Modify order
modify_order(tc.client, acc_id, Constants.TrdEnv.Simulate, order_id;
    price = 455.0, qty = 200.0
)

# Cancel order
modify_order(tc.client, acc_id, Constants.TrdEnv.Simulate, order_id;
    modify_order_op = Constants.ModifyOrderOp.Cancel
)

# Cancel all orders
cancel_all_orders(tc.client, acc_id, Constants.TrdEnv.Simulate)
```

#### Order Queries
```julia
# Get open orders
orders = get_order_list(tc.client, acc_id, Constants.TrdEnv.Simulate)

# Get historical orders
history = get_history_order_list(tc.client, acc_id, Constants.TrdEnv.Simulate)

# Get today's fills
fills = get_order_fill_list(tc.client, acc_id, Constants.TrdEnv.Simulate)

# Get historical fills
history_fills = get_history_order_fill_list(tc.client, acc_id,
    Constants.TrdEnv.Simulate)

# Get order fees
fees = get_order_fee(tc.client, acc_id, Constants.TrdEnv.Real,
    ["order_id_ex_1", "order_id_ex_2"])
```

#### Real-time Trade Updates
```julia
# Register order update callback
function on_order(data)
    println("Order update: $(data["code"]) - $(data["order_status"])")
    println("  Filled: $(data["fill_qty"]) / $(data["qty"])")
end
update_order(tc.client, on_order)

# Register fill callback
function on_order_fill(data)
    println("Trade executed: $(data["code"])")
    println("  Price: $(data["price"]), Qty: $(data["qty"])")
end
update_order_fill(tc.client, on_order_fill)

# Subscribe to trade push
subscribe_trade_push(tc.client, [acc_id])

# Unsubscribe
unsubscribe_trade_push(tc.client)
```

## Constants & Enumerations

### Markets
```julia
QotMarket.HK_Security       # Hong Kong stocks
QotMarket.US_Security       # US stocks
QotMarket.CNSH_Security     # Shanghai A-shares
QotMarket.CNSZ_Security     # Shenzhen A-shares
QotMarket.HK_Future         # Hong Kong futures
QotMarket.US_Future         # US futures
```

### Subscription Types
```julia
SubType.Basic          # Basic quotes
SubType.OrderBook      # Order book
SubType.Ticker         # Tick-by-tick
SubType.RT             # Real-time data
SubType.K_Day          # Daily K-line
SubType.K_1M           # 1-minute K-line
SubType.Broker         # Broker queue
```

### K-line Types
```julia
KLType.K_1M           # 1 minute
KLType.K_5M           # 5 minutes
KLType.K_15M          # 15 minutes
KLType.K_30M          # 30 minutes
KLType.K_60M          # 60 minutes
KLType.K_Day          # Daily
KLType.K_Week         # Weekly
KLType.K_Month        # Monthly
```

### Trading Environment
```julia
TrdEnv.Real           # Real trading
TrdEnv.Simulate       # Paper trading
```

### Order Types
```julia
OrderType.Normal      # Limit order
OrderType.Market      # Market order
OrderType.Stop        # Stop order
OrderType.StopLimit   # Stop limit order
```

### Trading Side
```julia
TrdSide.Buy           # Buy
TrdSide.Sell          # Sell
TrdSide.SellShort     # Short sell
TrdSide.BuyBack       # Buy to cover
```

### User Info Fields
```julia
UserInfoField.Basic       # Nickname, avatar, user ID
UserInfoField.API         # API permissions
UserInfoField.QotRight    # Quote rights
UserInfoField.Disclaimer  # Disclaimer
UserInfoField.Update      # Update info
UserInfoField.WebKey      # Web key
```

## Test Files

The `test/` directory contains comprehensive examples:

1. **test_client.jl**: Connection management, system information
2. **test_quote.jl**: Real-time quotes, subscriptions, market data, callbacks
3. **test_quote_extended.jl**: Options, warrants, futures, IPOs, trading calendar
4. **test_filter.jl**: Stock screening with various filters
5. **test_customization.jl**: Price reminders and watchlist management
6. **test_trade.jl**: Trading operations, orders, positions, callbacks

Run tests:
```julia
include("test/test_quote.jl")
```

## API Limits & Quotas

### Frequency Limits (per 30 seconds)
- Quote APIs: 60 requests
- Historical Data: 30 requests
- Trading APIs:
  - Place Order: 15 requests
  - Modify/Cancel: 20 requests
  - Query APIs: 10 requests

### Subscription Quotas
| User Level | Subscription Quota | Historical K-line Quota |
|------------|-------------------|------------------------|
| Basic      | 100               | 100                    |
| Medium     | 300               | 300                    |
| Advanced   | 1000              | 1000                   |
| Premium    | 2000              | 2000                   |

## Error Handling

```julia
try
    result = get_market_snapshot(client, ["00700"])
catch e
    if isa(e, Futu.Errors.ConnectionError)
        println("Connection error: ", e.message)
    elseif isa(e, Futu.Errors.APIError)
        println("API error: ", e.code, " - ", e.message)
    else
        rethrow(e)
    end
end
```

## Security Best Practices

- Use RSA encryption for secure connections
- Never commit passwords or API keys to version control
- Use environment variables for sensitive data
- Always use MD5 hashed passwords for `unlock_trade`
- Keep your OpenD gateway secure and updated

## Display Features

The SDK includes colored terminal display for better readability:

- **Quote Display**: Real-time quotes with color-coded price changes
- **Order Book**: Formatted order book with bid/ask separation
- **K-line Display**: Formatted K-line data with trend indicators
- **Funds Display**: Comprehensive account funds with color-coded P&L
- **System Info**: Formatted global state and user information

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Add tests for new features
4. Submit a pull request

## License

MIT License - see LICENSE file for details

## Support

- **Official Futu OpenAPI Documentation**: https://openapi.futunn.com/futu-api-doc/
- **GitHub Issues**: https://github.com/rzhli/Futu.jl/issues

## Project Status

Current Version: **v0.1.0** (Active Development)

### Implemented ✅
- Complete client connection with RSA encryption
- Full quote module with real-time subscriptions and callbacks
- Extended market data (options, warrants, futures, IPOs)
- Stock filtering with multiple filter types
- Price reminders and watchlist management
- Complete trading functionality (orders, positions, accounts)
- Real-time trade push notifications
- Colored terminal display

## Disclaimer

This SDK is provided as-is for educational and trading purposes. Trading stocks and other financial instruments involves substantial risk of loss. Always:
- Test thoroughly in paper trading before using real money
- Verify all data independently
- Understand the risks involved in algorithmic trading
- Comply with all applicable regulations

**The authors are not responsible for any financial losses incurred through the use of this software.**

---

*Empowering Julia developers with algorithmic trading capabilities*
