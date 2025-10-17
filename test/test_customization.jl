using Revise, DataFrames
using Futu
import Futu.Constants

rsa_key_path = get(ENV, "FUTU_RSA_KEY_PATH", joinpath(homedir(), ".futu", "private.pem"))
client = OpenDClient(rsa_private_key_path = rsa_key_path)
connect!(client)
is_connected(client)

# 设置到价提醒
key1 = set_price_reminder(
    client, "00700"; market = QotMarket.HK_Security, reminder_type = Constants.PriceReminderType.PriceUp,                                      
    value = 450.0, note = "Target price reached", freq = Constants.PriceReminderFreq.OnceADay                   
)         

key2 = set_price_reminder(
    client, "00700", market = QotMarket.HK_Security, reminder_type = Constants.PriceReminderType.PriceDown,         
    value = 400.0, note = "Stop loss level", freq = Constants.PriceReminderFreq.Always                                   
)   

key3 = set_price_reminder(
    client, "00700", market = QotMarket.HK_Security, reminder_type = Constants.PriceReminderType.VolumeUp, 
    value = 50000000.0,  # 50M shares   
    note = "High volume alert",         
    freq = Constants.PriceReminderFreq.OnlyOnce  
)

# Get Price Reminders
## Get all reminders for a specific stock    
reminders_00700 = get_price_reminder(client, "00700", market = QotMarket.HK_Security) 
## Get all HK market reminders  
reminders_hk = get_price_reminder(client, market = QotMarket.HK_Security)       
 
# Modify Price Reminder
if !iszero(key1)
    # Modify the value of the first reminder
    println("Modifying reminder $key1...")
    modified_key = modify_price_reminder(
        client, "00700", key1, 
        market = QotMarket.HK_Security,
        value = 660.0,
        note = "Updated target price"
    )
    println("✓ Modified reminder with key: $modified_key")

    # Verify the modification
    println("\nVerifying modification...")
    reminders_updated = get_price_reminder(client, "00700", market = QotMarket.HK_Security)
    modified_reminder = filter(row -> row.key == key1, reminders_updated)
    if nrow(modified_reminder) > 0
        println("Updated reminder:")
        println(modified_reminder)
    end
end

# Enable/Disable Reminder
if !iszero(key2)
    # Disable a reminder
    println("Disabling reminder $key2...")
    disable_price_reminder(client, "00700", key2, market = QotMarket.HK_Security)
    println("✓ Disabled reminder")

    # Verify it's disabled
    reminders_check = get_price_reminder(client, "00700", market = QotMarket.HK_Security)
    disabled_reminder = filter(row -> row.key == key2, reminders_check)
    if nrow(disabled_reminder) > 0
        println("Reminder status: $(disabled_reminder[1, :is_enable] ? "Enabled" : "Disabled")")
    end

    # Re-enable it
    println("\nRe-enabling reminder $key2...")
    enable_price_reminder(client, "00700", key2, market = QotMarket.HK_Security)
    println("✓ Re-enabled reminder")
end
# Delete Price Reminders
# Delete a specific reminder
if !iszero(key3)
    println("Deleting reminder $key3...")
    delete_price_reminder(client, "00700", key3, market = QotMarket.HK_Security)
    println("✓ Deleted reminder $key3")
end

# Delete all reminders for a security
# Uncomment the following lines if you want to clean up all reminders
println("\nDeleting all reminders for 00700...")
delete_all_price_reminders(client, "00700", market = QotMarket.HK_Security)
println("✓ Deleted all reminders for 00700")

# Verify deletion
println("\nVerifying deletion...")
reminders_final = get_price_reminder(client, "00700", market = QotMarket.HK_Security)
println("Remaining reminders for 00700: $(nrow(reminders_final))")
# Advanced Reminder Types
# Change rate reminder (percentage-based)
println("Setting daily change rate reminder...")
key_change = set_price_reminder(
    client, "00700",
    market = QotMarket.HK_Security,
    reminder_type = Constants.PriceReminderType.ChangeRateUp,
    value = 5.0,  # 5% change
    note = "5% daily gain",
    freq = Constants.PriceReminderFreq.Always
)
println("✓ Created change rate reminder with key: $key_change")

# Turnover rate reminder
println("\nSetting turnover rate reminder...")
key_turnover = set_price_reminder(
    client, "00700",
    market = QotMarket.HK_Security,
    reminder_type = Constants.PriceReminderType.TurnoverRateUp,
    value = 10.0,  # 10% turnover rate
    note = "High turnover",
    freq = Constants.PriceReminderFreq.OnceADay
)
println("✓ Created turnover rate reminder with key: $key_turnover")

# Display all reminder types for the stock
println("\nAll reminders for 00700:")
all_reminders = get_price_reminder(client, "00700", market = QotMarket.HK_Security)
for row in eachrow(all_reminders)
    status = row.is_enable ? "✓" : "✗"
    println("$status [$(row.reminder_type)] Value: $(row.value) | Note: $(row.note) | Freq: $(row.freq)")
end


# 设置提醒
# 先订阅
subscribe(
    client, ["09988", "00700"], 
    [SubType.Basic, SubType.OrderBook, SubType.RT, SubType.K_Day, SubType.K_1M, SubType.Ticker, SubType.Broker]
)

# Set up a price reminder
key = set_price_reminder(client, "00700"; market = QotMarket.HK_Security,
    reminder_type = Constants.PriceReminderType.PriceUp,
    value = 627.0,
    note = "Target price"
)

# Register callback to receive push notifications
function cb_price_reminder(data)
    println("Price reminder triggered!")
    println("  Code: $(data["code"])")
    println("  Name: $(data["name"])")
    println("  Type: $(data["reminder_type"])")
    println("  Price: $(data["price"])")
    println("  Target: $(data["set_value"])")
    println("  Note: $(data["note"])")
end
update_price_reminder(client, cb_price_reminder)

# Get user-defined groups only (default)
custom_groups = get_user_security_group(client)

# Get system groups only
system_groups = get_user_security_group(client, group_type = Constants.GroupType.System)

# Get all groups (both custom and system)
all_groups = get_user_security_group(client, group_type = Constants.GroupType.All)

# Filter custom groups
user_groups = filter(row -> row.group_type == "Custom", custom_groups)

my_stocks = get_user_security(client, "recomend")
# Get all HK stocks in watchlist
hk_stocks = get_user_security(client, "港股")

# Get custom watchlist group
my_stocks = get_user_security(client, "特别关注")


# Add securities to a custom group
modify_user_security(client, "recomend", ["00700", "09988"],
    market = QotMarket.HK_Security, operation = Constants.ModifyUserSecurityOp.Add
)

# Remove securities from a group (using string operation)
modify_user_security(client, "recomend", ["00700"],
    market = QotMarket.HK_Security, operation = Constants.ModifyUserSecurityOp.Del
)

# Move securities out of a group
modify_user_security(client, "recomend", ["09988"], operation = Constants.ModifyUserSecurityOp.MoveOut)

# Add US stocks to a custom group
modify_user_security(client, "recomend", ["AAPL", "TSLA"],
    market = QotMarket.US_Security, operation = Constants.ModifyUserSecurityOp.Add
)

disconnect!(client)
