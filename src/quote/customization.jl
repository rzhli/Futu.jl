module Customization

using DataFrames
using Dates
using ..Client
                    # Protocol IDs
using ..Constants: QOT_GET_USER_SECURITY_GROUP, QOT_GET_USER_SECURITY, QOT_MODIFY_USER_SECURITY,
                   QOT_SET_PRICE_REMINDER, QOT_GET_PRICE_REMINDER, QOT_UPDATE_PRICE_REMINDER
                    # Protocol message types
using ..Constants: Qot_GetUserSecurityGroup, Qot_GetUserSecurity, Qot_ModifyUserSecurity,
                 Qot_SetPriceReminder, Qot_GetPriceReminder
                    # Enums
using ..Constants: SecurityType, ExchType, QotMarket, PriceReminderType, PriceReminderFreq, ModifyUserSecurityOp, PriceReminderMarketStatus, GroupType
using ..Constants: PROTO_RESPONSE_MAP         # Other

using ..AllProtos.Qot_Common
using ..AllProtos.Trd_Common
using ..PushCallbacks: register_callback, unregister_callback

const WATCHLIST_GROUP_ALL = "All"
const WATCHLIST_GROUP_CN = "CN"
const WATCHLIST_GROUP_HK = "HK"
const WATCHLIST_GROUP_US = "US"
const WATCHLIST_GROUP_OPTIONS = "Options"
const WATCHLIST_GROUP_HK_OPTIONS = "HK options"
const WATCHLIST_GROUP_US_OPTIONS = "US options"
const WATCHLIST_GROUP_STARRED = "Starred"
const WATCHLIST_GROUP_FUTURES = "Futures"
const WATCHLIST_GROUP_ALL_CN = "全部"
const WATCHLIST_GROUP_CN_CN = "沪深"
const WATCHLIST_GROUP_HK_CN = "港股"
const WATCHLIST_GROUP_US_CN = "美股"
const WATCHLIST_GROUP_OPTIONS_CN = "期权"
const WATCHLIST_GROUP_HK_OPTIONS_CN = "港股期权"
const WATCHLIST_GROUP_US_OPTIONS_CN = "美股期权"
const WATCHLIST_GROUP_STARRED_CN = "特别关注"
const WATCHLIST_GROUP_FUTURES_CN = "期货"

export
    # Watchlist management
    get_user_security, get_user_security_group, modify_user_security,

    # Price reminder
    set_price_reminder,
    get_price_reminder,
    delete_price_reminder,
    delete_all_price_reminders,
    enable_price_reminder,
    disable_price_reminder,
    modify_price_reminder,
    update_price_reminder

"""
    get_user_security_group(client::OpenDClient; group_type::Int32 = Int32(1))

Get watchlist group list by type.

# Arguments
- `client::OpenDClient`: The API client

# Keyword Arguments
- `group_type::Int32 = Int32(1)`: Group type filter
  - `1` (Custom): User-defined groups only (default)
  - `2` (System): System groups only
  - `3` (All): All groups (both custom and system)

# Returns
- `DataFrame` with the following columns:
  - `group_name::String`: Watchlist group name
  - `group_type::String`: Group type (CUSTOM or SYSTEM)

# Group Types
- **CUSTOM**: User-created watchlist groups
- **SYSTEM**: Built-in system groups like "All", "HK", "US", "CN", "Starred", etc.

# Notes
- Protocol ID: 3222
- Rate limit: 10 requests per 30 seconds
- Default behavior returns only user-defined groups
"""
function get_user_security_group(client::OpenDClient; group_type::GroupType.T = GroupType.Custom)
    # Build C2S request
    c2s = Qot_GetUserSecurityGroup.C2S(groupType = Int32(group_type))

    # Create request and send
    req = Qot_GetUserSecurityGroup.Request(c2s = c2s)
    resp = Client.api_request(client, UInt32(QOT_GET_USER_SECURITY_GROUP), req, PROTO_RESPONSE_MAP[UInt32(QOT_GET_USER_SECURITY_GROUP)])

    # Parse response
    data = resp.s2c.groupList

    # Use map for type stability
    rows = map(data) do item
        group_type_str = string(Qot_GetUserSecurityGroup.GroupType.T(item.groupType))
        (group_name = item.groupName, group_type = group_type_str)
    end

    return DataFrame(rows)
end

"""
    get_user_security(client::OpenDClient, group_name::String)

Get securities in a specified watchlist group.

# Arguments
- `client::OpenDClient`: The API client
- `group_name::String`: Group name (if duplicate names exist, returns the first one by sort order)

# Returns
- `DataFrame` with the following columns:
  - `code::String`: Security code
  - `name::String`: Security name
  - `market::Int32`: Market identifier
  - `lot_size::Int64`: Lot size (for options and futures, represents contract multiplier)
  - `stock_type::String`: Security type
  - `listing_date::String`: Listing date string
  - `stock_id::Int64`: Stock ID
  - `exchange_type::String`: Exchange type
  - `delist_flag::Bool`: Whether delisted

# System Groups
The following system groups are available (Chinese/English names):
- "All" / "全部": All markets
- "CN" / "沪深": Shanghai and Shenzhen markets
- "HK" / "港股": Hong Kong market
- "US" / "美股": US market
- "Options" / "期权": Options
- "HK options" / "港股期权": Hong Kong options
- "US options" / "美股期权": US options
- "Starred" / "特别关注": Favorites
- "Futures" / "期货": Futures

# Notes
- Protocol ID: 3213
- Rate limit: 10 requests per 30 seconds
- Does not support: Positions, Mutual Fund, Forex groups
"""
function get_user_security(client::OpenDClient, group_name::String)
    # Build C2S request
    c2s = Qot_GetUserSecurity.C2S(groupName = group_name)

    # Create request and send
    req = Qot_GetUserSecurity.Request(c2s = c2s)
    resp = Client.api_request(client, UInt32(QOT_GET_USER_SECURITY), req, PROTO_RESPONSE_MAP[UInt32(QOT_GET_USER_SECURITY)])

    # Parse response
    data = resp.s2c.staticInfoList

    # Use map for type stability
    rows = map(data) do item
        basic = item.basic
        security = basic.security

        # Convert security type enum to string
        stock_type_str = string(SecurityType.T(basic.secType))

        # Convert exchange type enum to string
        exchange_type_str = if !hasproperty(basic, :exchType)
            "Unknown"
        else
            string(ExchType.T(basic.exchType))
        end

        (
            code = security.code,
            name = basic.name,
            market = security.market,
            lot_size = Int64(basic.lotSize),
            stock_type = stock_type_str,
            listing_date = basic.listTime,
            stock_id = Int64(basic.id),
            exchange_type = exchange_type_str,
            delist_flag = hasproperty(basic, :delisting) ? basic.delisting : false
        )
    end

    return DataFrame(rows)
end

"""
    modify_user_security(client::OpenDClient, group_name::String, codes::Vector{String}; kwargs...)

Modify watchlist by adding, removing, or moving securities out from a group.

# Arguments
- `client::OpenDClient`: The API client
- `group_name::String`: Group name (if duplicate names exist, operates on the first one by sort order)
- `codes::Vector{String}`: List of security codes to modify

# Keyword Arguments
- `market::QotMarket.T = QotMarket.HK_Security`: Market identifier
- `operation::Union{String, ModifyUserSecurityOp.T} = ModifyUserSecurityOp.Add`: Operation type

# Operation Types
- `ModifyUserSecurityOp.Add` or `"ADD"`: Add securities to the group
- `ModifyUserSecurityOp.Del` or `"REMOVE"/"DEL"/"DELETE"`: Remove securities from the group
- `ModifyUserSecurityOp.MoveOut` or `"MOVE"/"MOVE_OUT"/"MOVEOUT"`: Move securities out of the group

# Returns
- Empty `S2C` struct (operation success indicated by no error)

# Restrictions
- **Only custom groups can be modified**, system groups cannot be modified
- Rate limit: 10 requests per 30 seconds
- "All" watchlist limits: 500 securities (non-trading accounts), 2000 securities (trading accounts)
- Adding to any group also adds to the "All" group
- If duplicate group names exist, operates on the first one by sort order

# System Groups (Cannot Be Modified)
The following system groups are read-only:
- English: "All", "CN", "HK", "US", "Options", "HK options", "US options", "Starred", "Futures"
- Chinese: "全部", "沪深", "港股", "美股", "期权", "港股期权", "美股期权", "特别关注", "期货"

# Notes
- Protocol ID: 3214
- When adding securities, they are automatically added to the "All" group
- System will validate that the group is user-created before modification
"""
function modify_user_security(
    client::OpenDClient, group_name::String, codes::Vector{String};
    market::QotMarket.T = QotMarket.HK_Security, operation::ModifyUserSecurityOp.T = ModifyUserSecurityOp.Add
    )
    # Validate that we're not trying to modify system groups
    system_groups = [
        WATCHLIST_GROUP_ALL, WATCHLIST_GROUP_CN, WATCHLIST_GROUP_HK,
        WATCHLIST_GROUP_US, WATCHLIST_GROUP_OPTIONS, WATCHLIST_GROUP_HK_OPTIONS,
        WATCHLIST_GROUP_US_OPTIONS, WATCHLIST_GROUP_STARRED, WATCHLIST_GROUP_FUTURES,
        WATCHLIST_GROUP_ALL_CN, WATCHLIST_GROUP_CN_CN, WATCHLIST_GROUP_HK_CN,
        WATCHLIST_GROUP_US_CN, WATCHLIST_GROUP_OPTIONS_CN, WATCHLIST_GROUP_HK_OPTIONS_CN,
        WATCHLIST_GROUP_US_OPTIONS_CN, WATCHLIST_GROUP_STARRED_CN, WATCHLIST_GROUP_FUTURES_CN
    ]

    if group_name in system_groups
        error("Cannot modify system watchlist group: $group_name. Only user-created groups can be modified.")
    end

    # Create security objects
    securities = [Qot_Common.Security(Int32(market), code) for code in codes]

    # Build C2S request
    c2s = Qot_ModifyUserSecurity.C2S(groupName = group_name, op = Int32(operation), securityList = securities)

    # Create request and send
    req = Qot_ModifyUserSecurity.Request(c2s = c2s)
    resp = Client.api_request(client, UInt32(QOT_MODIFY_USER_SECURITY), req, PROTO_RESPONSE_MAP[UInt32(QOT_MODIFY_USER_SECURITY)])

    return resp.s2c
end

"""
    set_price_reminder(client::OpenDClient, code::String; kwargs...)

Add a new price reminder for a security.

# Arguments
- `client::OpenDClient`: The API client
- `code::String`: Security code

# Keyword Arguments
- `market::QotMarket.T = QotMarket.HK_Security`: Market identifier
- `reminder_type::PriceReminderType.T = PriceReminderType.PriceUp`: Reminder type
- `value::Float64 = 0.0`: Reminder threshold value (precision: 3 decimal places)
- `note::String = ""`: User note (max 20 Chinese characters)
- `freq::PriceReminderFreq.T = PriceReminderFreq.OnceADay`: Reminder frequency
- `reminder_session_list::Vector{PriceReminderMarketStatus.T} = PriceReminderMarketStatus.T[]`: Trading session list

# Returns
- `Int64`: Key of the created reminder (0 if failed)

# Notes
- Protocol ID: 3220
- Rate limit: 60 requests per 30 seconds
- Max 10 reminders per security per type
- Precision rules:
  - TURNOVER_UP: Min precision 10 (rounds down)
  - VOLUME_UP: A-share 1000 shares, others 10 shares (rounds down)
  - BID_VOL_UP, ASK_VOL_UP: A-share 100 shares (rounds down)
  - Others: 3 decimal places precision
"""
function set_price_reminder(client::OpenDClient, code::String; market::QotMarket.T = QotMarket.HK_Security,
    reminder_type::PriceReminderType.T = PriceReminderType.PriceUp, value::Float64 = 0.0, note::String = "",
    freq::PriceReminderFreq.T = PriceReminderFreq.OnceADay, reminder_session_list::Vector{PriceReminderMarketStatus.T} = PriceReminderMarketStatus.T[]
    )
    # Create security object
    security = Qot_Common.Security(Int32(market), code)

    # Build C2S request
    c2s = Qot_SetPriceReminder.C2S(security = security, op = Int32(Qot_SetPriceReminder.SetPriceReminderOp.Add),
        type = Int32(reminder_type), freq = Int32(freq), value = value, note = note
    )

    # Add reminder session list if provided (convert enums to Int32)
    if !isempty(reminder_session_list)
        c2s.reminderSessionList = [Int32(s) for s in reminder_session_list]
    end

    # Create request and send
    req = Qot_SetPriceReminder.Request(c2s = c2s)
    resp = Client.api_request(client, UInt32(QOT_SET_PRICE_REMINDER), req, PROTO_RESPONSE_MAP[UInt32(QOT_SET_PRICE_REMINDER)])

    return Int64(resp.s2c.key)
end

"""
    get_price_reminder(client::OpenDClient, code::Union{String, Nothing} = nothing; market::Union{QotMarket.T, Nothing} = nothing)

Get price reminder list for specified security or market.

# Arguments
- `client::OpenDClient`: The API client
- `code::Union{String, Nothing} = nothing`: Security code (optional)

# Keyword Arguments
- `market::Union{QotMarket.T, Nothing} = nothing`: Market identifier (required if `code` is not provided)

# Query Modes
1. **Specific Security**: When both `code` and `market` are provided, returns reminders for that specific security
2. **Market-wide**: When only `market` is provided, returns all reminders for that market (SH and SZ are not distinguished)

# Returns
- `DataFrame` with the following columns:
  - `key::Int64`: Unique identifier for each reminder
  - `code::String`: Security code
  - `name::String`: Security name
  - `reminder_type::String`: Reminder type (PRICE_UP, PRICE_DOWN, CHANGE_RATE_UP, etc.)
  - `value::Float64`: Reminder threshold value
  - `is_enable::Bool`: Whether the reminder is enabled
  - `note::String`: User note (max 20 Chinese characters)
  - `freq::String`: Reminder frequency (ALWAYS, ONCE_A_DAY, ONLY_ONCE)
  - `reminder_sessions::Vector{String}`: Trading session list (empty if not set)

# Notes
- Protocol ID: 3221
- Rate limit: 10 requests per 30 seconds
- At least one of `code`+`market` or `market` must be provided
- Securities and market are mutually exclusive; if both are provided, security takes precedence
- For market queries, SH and SZ markets are not distinguished
"""
function get_price_reminder(client::OpenDClient, code::Union{String, Nothing} = nothing; market::Union{QotMarket.T, Nothing} = nothing)
    # Validate input parameters
    if code === nothing && market === nothing
        error("At least one of 'code'+'market' or 'market' must be provided. The API does not support querying all reminders across all markets.")
    end

    # Build C2S request
    c2s = Qot_GetPriceReminder.C2S()

    # Handle different query modes according to documentation:
    # 1. Both security and market provided -> query specific security (security takes precedence)
    # 2. Only market provided -> query all reminders in that market
    if code !== nothing && market !== nothing
        c2s.security = Qot_Common.Security(Int32(market), code)
    elseif market !== nothing
        c2s.market = Int32(market)
    else
        # This should never happen due to the validation above, but keeping for safety
        error("Invalid parameter combination: code provided without market")
    end

    # Create request and send
    req = Qot_GetPriceReminder.Request(c2s = c2s)
    resp = Client.api_request(client, UInt32(QOT_GET_PRICE_REMINDER), req, PROTO_RESPONSE_MAP[UInt32(QOT_GET_PRICE_REMINDER)])

    # Parse response
    data = resp.s2c.priceReminderList

    # Use Iterators.flatten for nested structure - type stable
    rows = collect(Iterators.flatten(map(data) do reminder_item
        security = reminder_item.security
        security_name = reminder_item.name

        map(reminder_item.itemList) do item
            # Convert reminder type enum to string
            reminder_type_str = string(PriceReminderType.T(item.type))

            # Convert frequency enum to string
            freq_str = string(PriceReminderFreq.T(item.freq))

            # Convert reminder session list to string array
            session_strs = [string(PriceReminderMarketStatus.T(s)) for s in item.reminderSessionList]

            (
                key = Int64(item.key),
                code = security.code,
                name = security_name,
                reminder_type = reminder_type_str,
                value = item.value,
                is_enable = item.isEnable,
                note = item.note,
                freq = freq_str,
                reminder_sessions = session_strs
            )
        end
    end))

    return DataFrame(rows)
end

"""
    delete_price_reminder(client::OpenDClient, code::String, reminder_key::Int64; market::QotMarket.T = QotMarket.HK_Security)

Delete a specific price reminder.

# Arguments
- `client::OpenDClient`: The API client
- `code::String`: Security code
- `reminder_key::Int64`: Reminder key (obtained from get_price_reminder)

# Keyword Arguments
- `market::QotMarket.T = QotMarket.HK_Security`: Market identifier

# Returns
- `Int64`: Key of the deleted reminder (0 if failed)

# Notes
- Protocol ID: 3220
- Rate limit: 60 requests per 30 seconds
"""
function delete_price_reminder(client::OpenDClient, code::String, reminder_key::Int64; market::QotMarket.T = QotMarket.HK_Security)
    # Create security object
    security = Qot_Common.Security(Int32(market), code)

    # Build C2S request
    c2s = Qot_SetPriceReminder.C2S(security = security, op = Int32(Qot_SetPriceReminder.SetPriceReminderOp.Del), key = reminder_key)

    # Create request and send
    req = Qot_SetPriceReminder.Request(c2s = c2s)
    resp = Client.api_request(client, UInt32(QOT_SET_PRICE_REMINDER), req, PROTO_RESPONSE_MAP[UInt32(QOT_SET_PRICE_REMINDER)])

    return Int64(resp.s2c.key)
end

"""
    delete_all_price_reminders(client::OpenDClient, code::String; market::QotMarket.T = QotMarket.HK_Security)

Delete all price reminders for a security.

# Arguments
- `client::OpenDClient`: The API client
- `code::String`: Security code

# Keyword Arguments
- `market::QotMarket.T = QotMarket.HK_Security`: Market identifier

# Returns
- `Int64`: Key of the operation (0 if failed)

# Notes
- Protocol ID: 3220
- Rate limit: 60 requests per 30 seconds
- Deletes all reminders for the specified security
"""
function delete_all_price_reminders(client::OpenDClient, code::String; market::QotMarket.T = QotMarket.HK_Security)
    # Create security object
    security = Qot_Common.Security(Int32(market), code)

    # Build C2S request
    c2s = Qot_SetPriceReminder.C2S(security = security, op = Int32(Qot_SetPriceReminder.SetPriceReminderOp.DelAll))

    # Create request and send
    req = Qot_SetPriceReminder.Request(c2s = c2s)
    resp = Client.api_request(client, UInt32(QOT_SET_PRICE_REMINDER), req, PROTO_RESPONSE_MAP[UInt32(QOT_SET_PRICE_REMINDER)])

    return Int64(resp.s2c.key)
end

"""
    enable_price_reminder(client::OpenDClient, code::String, reminder_key::Int64; market::QotMarket.T = QotMarket.HK_Security)

Enable a disabled price reminder.

# Arguments
- `client::OpenDClient`: The API client
- `code::String`: Security code
- `reminder_key::Int64`: Reminder key (obtained from get_price_reminder)

# Keyword Arguments
- `market::QotMarket.T = QotMarket.HK_Security`: Market identifier

# Returns
- `Int64`: Key of the enabled reminder (0 if failed)

# Notes
- Protocol ID: 3220
- Rate limit: 60 requests per 30 seconds
"""
function enable_price_reminder(client::OpenDClient, code::String, reminder_key::Int64; market::QotMarket.T = QotMarket.HK_Security)
    # Create security object
    security = Qot_Common.Security(Int32(market), code)

    # Build C2S request
    c2s = Qot_SetPriceReminder.C2S(security = security, op = Int32(Qot_SetPriceReminder.SetPriceReminderOp.Enable), key = reminder_key)

    # Create request and send
    req = Qot_SetPriceReminder.Request(c2s = c2s)
    resp = Client.api_request(client, UInt32(QOT_SET_PRICE_REMINDER), req, PROTO_RESPONSE_MAP[UInt32(QOT_SET_PRICE_REMINDER)])

    return Int64(resp.s2c.key)
end

"""
    disable_price_reminder(client::OpenDClient, code::String, reminder_key::Int64; market::QotMarket.T = QotMarket.HK_Security)

Disable an enabled price reminder.

# Arguments
- `client::OpenDClient`: The API client
- `code::String`: Security code
- `reminder_key::Int64`: Reminder key (obtained from get_price_reminder)

# Keyword Arguments
- `market::QotMarket.T = QotMarket.HK_Security`: Market identifier

# Returns
- `Int64`: Key of the disabled reminder (0 if failed)

# Notes
- Protocol ID: 3220
- Rate limit: 60 requests per 30 seconds
"""
function disable_price_reminder(client::OpenDClient, code::String, reminder_key::Int64; market::QotMarket.T = QotMarket.HK_Security)
    # Create security object
    security = Qot_Common.Security(Int32(market), code)

    # Build C2S request
    c2s = Qot_SetPriceReminder.C2S(security = security, op = Int32(Qot_SetPriceReminder.SetPriceReminderOp.Disable), key = reminder_key)

    # Create request and send
    req = Qot_SetPriceReminder.Request(c2s = c2s)
    resp = Client.api_request(client, UInt32(QOT_SET_PRICE_REMINDER), req, PROTO_RESPONSE_MAP[UInt32(QOT_SET_PRICE_REMINDER)])

    return Int64(resp.s2c.key)
end

"""
    modify_price_reminder(client::OpenDClient, code::String, reminder_key::Int64; kwargs...)

Modify an existing price reminder.

# Arguments
- `client::OpenDClient`: The API client
- `code::String`: Security code
- `reminder_key::Int64`: Reminder key (obtained from get_price_reminder)

# Keyword Arguments
- `market::QotMarket.T = QotMarket.HK_Security`: Market identifier
- `reminder_type::Union{PriceReminderType.T, Nothing} = nothing`: New reminder type
- `value::Union{Float64, Nothing} = nothing`: New threshold value
- `note::Union{String, Nothing} = nothing`: New user note (max 20 Chinese characters)
- `freq::Union{PriceReminderFreq.T, Nothing} = nothing`: New reminder frequency
- `reminder_session_list::Union{Vector{PriceReminderMarketStatus.T}, Nothing} = nothing`: New trading session list

# Returns
- `Int64`: Key of the modified reminder (0 if failed)

# Notes
- Protocol ID: 3220
- Rate limit: 60 requests per 30 seconds
- Only provided parameters will be modified; others remain unchanged
"""
function modify_price_reminder(client::OpenDClient, code::String, reminder_key::Int64;
    market::QotMarket.T = QotMarket.HK_Security, reminder_type::Union{PriceReminderType.T, Nothing} = nothing,
    value::Union{Float64, Nothing} = nothing, note::Union{String, Nothing} = nothing, freq::Union{PriceReminderFreq.T, Nothing} = nothing,
    reminder_session_list::Union{Vector{PriceReminderMarketStatus.T}, Nothing} = nothing
    )
    # Create security object
    security = Qot_Common.Security(Int32(market), code)

    # Build C2S request
    c2s = Qot_SetPriceReminder.C2S(security = security, op = Int32(Qot_SetPriceReminder.SetPriceReminderOp.Modify), key = reminder_key)

    # Add optional fields
    if reminder_type !== nothing
        c2s.type = Int32(reminder_type)
    end
    if value !== nothing
        c2s.value = value
    end
    if note !== nothing
        c2s.note = note
    end
    if freq !== nothing
        c2s.freq = Int32(freq)
    end
    if reminder_session_list !== nothing && !isempty(reminder_session_list)
        c2s.reminderSessionList = [Int32(s) for s in reminder_session_list]
    end

    # Create request and send
    req = Qot_SetPriceReminder.Request(c2s = c2s)
    resp = Client.api_request(client, UInt32(QOT_SET_PRICE_REMINDER), req, PROTO_RESPONSE_MAP[UInt32(QOT_SET_PRICE_REMINDER)])

    return Int64(resp.s2c.key)
end

"""
    update_price_reminder(client::OpenDClient, callback::Function)

Register a callback function to receive price reminder push notifications.

# Arguments
- `client::OpenDClient`: The API client
- `callback::Function`: Callback function that will be invoked when a price reminder is triggered

# Callback Data Structure
The callback receives a `Dict` with the following fields:
- `code::String`: Security code
- `name::String`: Security name
- `price::Float64`: Current price
- `change_rate::Float64`: Daily change rate (%)
- `market_status::String`: Market status ("OPEN", "US_PRE", "US_AFTER", "US_OVERNIGHT", "UNKNOWN")
- `content::String`: Reminder content message
- `note::String`: User's note (max 20 Chinese characters)
- `key::Int64`: Reminder identifier
- `reminder_type::String`: Reminder type ("PRICE_UP", "PRICE_DOWN", "VOLUME_UP", etc.)
- `set_value::Float64`: The threshold value that was set
- `cur_value::Float64`: Current value that triggered the reminder

# Notes
- Protocol ID: 3019 (push notification)
- This is an async push notification, not a polling request
- The callback will be invoked automatically when any configured reminder is triggered
- Reminders must be configured first using `set_price_reminder`
- Multiple callbacks can be registered for the same protocol

# Comparison with `get_price_reminder`
- `get_price_reminder`: One-time query to get list of configured reminders
- `update_price_reminder`: Continuous push notifications when reminders are triggered

# See Also
- `set_price_reminder`: Create a new price reminder
- `get_price_reminder`: Query configured reminders
- `modify_price_reminder`: Modify an existing reminder
- `delete_price_reminder`: Delete a reminder
"""
function update_price_reminder(client::OpenDClient, callback::Function)
    register_callback(client.callbacks, UInt32(QOT_UPDATE_PRICE_REMINDER), callback)
end

end # module Customization
