using Revise
using FutuAPI
using DataFrames
import FutuAPI.Constants

rsa_key_path = get(ENV, "FUTU_RSA_KEY_PATH", joinpath(homedir(), ".futu", "private.pem"))
tc = TradeClient(rsa_private_key_path = rsa_key_path)

connect!(tc.client)
is_connected(tc.client)
# 账户
# Test lock trade
lock_trade(tc)

# Test get account list
acc_list = get_account_list(tc.client)
println("Account list retrieved successfully:")
println(acc_list)

# Test unlock trade
unlock_trade(tc, "xxxxxxxxxxxxxxxxxxxx", is_md5 = true)

# 资产持仓
# 查询账户资金
funds = get_funds(tc.client, 7256396, Constants.TrdEnv.Simulate)
# 查询最大可买可卖
get_max_trd_qtys(
    tc.client, 7256396, Constants.TrdEnv.Simulate, "09988", 1.0, Constants.OrderType.Market;
)
# 查询持仓
get_position_list(tc.client, 7256396, Constants.TrdEnv.Simulate;)
# 获取融资融券数据
margin = get_margin_ratio(tc.client, 7256396, Constants.TrdEnv.Simulate; security_list = ["09988", "00700"])
println(margin)
# 查询账户现金流水
get_account_cash_flow(tc.client, 281756456012076895, Constants.TrdEnv.Real, "2025-10-16")

# 订单
# 市价单
order_id, order_id_ex = place_order(
    tc.client, 7256396, Constants.TrdEnv.Simulate, "09988", Constants.TrdSecMarket.HK, 
    Constants.TrdSide.Buy, Constants.OrderType.Market, 100.0
)
# 限价单
order_id, order_id_ex = place_order(
    tc.client, 7256398, Constants.TrdEnv.Simulate, "601816", Constants.TrdSecMarket.CN_SH, 
    Constants.TrdSide.Buy, Constants.OrderType.Market, 100.0
)
# 修改订单
order_id, order_id_ex = modify_order(
    tc.client, 7256396, Constants.TrdEnv.Simulate, UInt64(1349065791002572001); 
    price = 130.0, qty = 100.0, order_id_ex = "7042913"
)
# 获取订单列表
get_order_list(tc.client, 7256398, Constants.TrdEnv.Simulate)
# 取消订单
order_id, order_id_ex = modify_order(
    tc.client, 7256398, Constants.TrdEnv.Simulate, UInt64(1358205322463439231); 
    modify_order_op = Constants.ModifyOrderOp.Cancel,
)
# 修改订单
order_id, order_id_ex = modify_order(
    tc.client, 7256398, Constants.TrdEnv.Simulate, UInt64(1358204781297560059); 
    price = 5.10, qty = 100.0
)
# 取消订单
order_id, order_id_ex = modify_order(
    tc.client, 7256396, Constants.TrdEnv.Simulate, UInt64(1358136113360173046); 
    modify_order_op = Constants.ModifyOrderOp.Cancel,
)

# 删除订单
order_id, order_id_ex = modify_order(
    tc.client, 7256396, Constants.TrdEnv.Simulate, UInt64(1358136113360173046); 
    modify_order_op = Constants.ModifyOrderOp.Delete,
)

# 获取A股订单列表
get_order_list(tc.client, 7256398, Constants.TrdEnv.Simulate)

# 获取港股订单列表
get_order_list(tc.client, 7256396, Constants.TrdEnv.Simulate)

# 获取A股历史订单列表
get_history_order_list(tc.client, 7256398, Constants.TrdEnv.Simulate)

# 获取港股历史订单列表
get_history_order_list(tc.client, 7256396, Constants.TrdEnv.Simulate)

# 查询当日成交列表 (模拟交易不支持成交数据)
fills = get_order_fill_list(tc.client, 7256396, Constants.TrdEnv.Simulate)

# 查询历史成交列表 (模拟交易不支持成交数据)
history_fills = get_history_order_fill_list(tc.client, 7256396, Constants.TrdEnv.Simulate)

# 取消所有订单 （模拟交易暂不支持）
cancel_all_orders(tc.client, 7256396, Constants.TrdEnv.Simulate)
# 查询订单费用 (暂时不支持模拟交易)
get_order_fee(tc.client, 7256396, Constants.TrdEnv.Simulate, ["6989044"])

# callback function for order
function on_order(data)
    println("\n" * "="^60)
    println("订单更新推送 (Order Update)")
    println("="^60)

    # 基本信息
    println("【基本信息】")
    println("  股票代码: ", data["code"], " (", data["name"], ")")
    println("  订单ID: ", data["order_id"])
    println("  服务器订单ID: ", data["order_id_ex"])
    println("  账户ID: ", data["acc_id"])

    # 订单状态
    println("\n【订单状态】")
    println("  订单类型: ", data["order_type"])
    println("  订单状态: ", data["order_status"])
    println("  交易方向: ", data["trd_side"])
    println("  交易环境: ", data["trd_env"])
    println("  交易市场: ", data["trd_market"])

    # 价格和数量
    println("\n【价格和数量】")
    println("  订单价格: ", data["price"])
    println("  订单数量: ", data["qty"])
    println("  已成交量: ", data["fill_qty"], " (",
            round(data["fill_qty"] / data["qty"] * 100, digits=2), "%)")
    println("  平均成交价: ", data["fill_avg_price"])

    # 时间信息
    println("\n【时间信息】")
    println("  创建时间: ", data["create_time"])
    println("  更新时间: ", data["update_time"])

    # 其他信息
    println("\n【其他信息】")
    println("  有效期: ", data["time_in_force"])
    println("  币种: ", data["currency"])
    println("  市场类型: ", data["sec_market"])

    # 高级订单参数
    if data["aux_price"] > 0
        println("  触发价: ", data["aux_price"])
    end
    if data["trail_type"] != "NONE" && data["trail_type"] != ""
        println("  跟踪类型: ", data["trail_type"])
        println("  跟踪值: ", data["trail_value"])
        println("  跟踪价差: ", data["trail_spread"])
    end
    if data["fill_outside_rth"]
        println("  允许盘前盘后交易: 是")
    end

    # 备注和错误信息
    if !isempty(data["remark"])
        println("  备注: ", data["remark"])
    end
    if !isempty(data["last_err_msg"])
        println("  ⚠️  错误信息: ", data["last_err_msg"])
    end

    println("="^60 * "\n")
end

# callback function for order fill (成交推送)
function on_order_fill(data)
    println("\n" * "="^60)
    println("订单成交推送 (Order Fill)")
    println("="^60)

    # 基本信息
    println("【基本信息】")
    println("  股票代码: ", data["code"], " (", data["name"], ")")
    println("  成交ID: ", data["fill_id"])
    println("  服务器成交ID: ", data["fill_id_ex"])
    println("  账户ID: ", data["acc_id"])

    # 关联订单
    println("\n【关联订单】")
    println("  订单ID: ", data["order_id"])
    println("  服务器订单ID: ", data["order_id_ex"])

    # 成交详情
    println("\n【成交详情】")
    println("  交易方向: ", data["trd_side"])
    println("  成交价格: ", data["price"])
    println("  成交数量: ", data["qty"])
    println("  成交金额: ", round(data["price"] * data["qty"], digits=2))
    println("  成交状态: ", data["status"])

    # 市场信息
    println("\n【市场信息】")
    println("  交易环境: ", data["trd_env"])
    println("  交易市场: ", data["trd_market"])
    println("  证券市场: ", data["sec_market"])

    # 对手方信息
    println("\n【对手方信息】")
    println("  对手经纪商ID: ", data["counter_broker_id"])
    if !isempty(data["counter_broker_name"])
        println("  对手经纪商名称: ", data["counter_broker_name"])
    end

    # 时间信息
    println("\n【时间信息】")
    println("  成交时间: ", data["create_time"])
    println("  创建时间戳: ", data["create_timestamp"])
    println("  更新时间戳: ", data["update_timestamp"])

    println("="^60 * "\n")
end
# 响应订单推送回调
update_order(tc.client, on_order)
# 响应成交推送回调
update_order_fill(tc.client, on_order_fill)
# 订阅交易推送（必须先订阅才能收到回调）
subscribe_trade_push(tc.client, [7256396, 7256398])   
unsubscribe_trade_push(tc.client)

disconnect!(tc.client)
println("\nAll tests passed!")