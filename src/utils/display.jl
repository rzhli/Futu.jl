module Display

    using Dates
    using Crayons
    using Unicode
    using Printf
    using ..AllProtos

    export render_global_state, render_delay_statistics, render_user_info, render_sub_info, status_indicator, color_status,
           render_broker_queue, render_capital_distribution,
        # ================= push callback display ==========================
           render_basic_quote, render_order_book, render_kline, render_rt, render_ticker, render_broker

    const HEADER_STYLE = Crayon(foreground=:cyan, bold=true)
    const SECTION_STYLE = Crayon(foreground=:magenta, bold=true)
    const LABEL_STYLE = Crayon(foreground=:white, bold=true)
    const VALUE_STYLE = Crayon(foreground=:white)
    const GOOD_STYLE = Crayon(foreground=:green, bold=true)
    const WARN_STYLE = Crayon(foreground=:yellow, bold=true)
    const BAD_STYLE = Crayon(foreground=:red, bold=true)

    # Additional styles for funds display
    const ASSET_STYLE = Crayon(foreground=:light_blue, bold=true)
    const AMOUNT_POSITIVE = Crayon(foreground=:green, bold=true)
    const AMOUNT_NEGATIVE = Crayon(foreground=:red, bold=true)
    const AMOUNT_NEUTRAL = Crayon(foreground=:light_cyan)
    const AMOUNT_WARNING = Crayon(foreground=:yellow)
    const CURRENCY_STYLE = Crayon(foreground=:light_yellow)

    # ======================= Quote 模块 ==========================
    function render_basic_quote(io::IO, _quote)
        security_code = get(_quote, "code", "-")
        security_name = get(_quote, "name", "-")
        update_time = get(_quote, "update_time", "-")

        price = get(_quote, "last_price", missing)
        prev_close = get(_quote, "prev_close", missing)
        open_price = get(_quote, "open_price", missing)
        high_price = get(_quote, "high_price", missing)
        low_price = get(_quote, "low_price", missing)
        volume = get(_quote, "volume", missing)
        turnover = get(_quote, "turnover", missing)
        turnover_rate = get(_quote, "turnover_rate", missing)
        
        change = (price !== missing && prev_close !== missing && prev_close != 0) ? price - prev_close : missing
        change_pct = change === missing ? missing : change / prev_close * 100
    
        header = string(
            HEADER_STYLE("------"), " ",
            HEADER_STYLE(security_code), " | ",
            HEADER_STYLE(security_name), " | ",
            HEADER_STYLE(update_time), " ", 
            HEADER_STYLE("------")
        )
        println(io, header)
        println(io)

        function format_value(val; fmt="%.3f")
            if val === missing || val === nothing
                return "-"
            elseif val isa Number
                fmt_obj = fmt isa Printf.Format ? fmt : Printf.Format(fmt)
                return Printf.format(fmt_obj, val)
            else
                return string(val)
            end
        end

        # 趋势颜色
        trend_style = if price === missing || prev_close === missing
            VALUE_STYLE
        elseif price >= prev_close
            GOOD_STYLE
        else
            BAD_STYLE
        end

        # 统一的表格布局参数
        label_width = 8
        value_width = 10
        sep = "      "

        label_cell(text) = LABEL_STYLE(Unicode.rpad(String(text), label_width))
        function value_cell(text; style=VALUE_STYLE)
            raw = String(text)
            return style(lpad(raw, value_width))
        end
        function trend_cell(text)
            raw = String(text)
            return raw == "-" ? VALUE_STYLE(lpad(raw, value_width)) : trend_style(lpad(raw, value_width))
        end

        price_str = format_value(price; fmt="%.3f")
        change_str = change === missing ? "-" : @sprintf("%+.3f", change)
        change_pct_str = change_pct === missing ? "-" : @sprintf("%+.2f%%", change_pct)
        prev_close_str = format_value(prev_close; fmt="%.3f")
        open_price_str = format_value(open_price; fmt="%.3f")
        high_price_str = format_value(high_price; fmt="%.3f")
        low_price_str = format_value(low_price; fmt="%.3f")
        volume_str = format_value(volume; fmt="%.0f")
        turnover_str = format_value(turnover; fmt="%.0f")
        turnover_rate_str = turnover_rate === missing ? "-" : @sprintf("%.2f%%", turnover_rate)

       # 第一行：最新价 | 收盘价
        println(io, string(
            label_cell("最新价"), sep,
            trend_cell(price_str))
        )
        
        # 第二行：涨跌额 | 涨跌幅
        println(io, string(
            label_cell("涨跌额"), sep,
            trend_cell(change_str), sep,
            label_cell("涨跌幅"), sep,
            trend_cell(change_pct_str))
        )
        
        # 第三行：开盘价 | 昨收
        println(io, string(
            label_cell("开盘价"), sep,
            value_cell(open_price_str), sep,
            label_cell("昨收"), sep,
            value_cell(prev_close_str))
        )
        
        # 第四行：最高价 | 最低价
        println(io, string(
            label_cell("最高价"), sep,
            value_cell(high_price_str), sep,
            label_cell("最低价"), sep,
            value_cell(low_price_str))
        )
        
        # 第五行：成交量 | 成交额
        println(io, string(
            label_cell("成交量"), sep,
            value_cell(volume_str), sep,
            label_cell("成交额"), sep,
            value_cell(turnover_str))
        )
        
        # 第八行：换手率（只有左侧）
        println(io, string(
            label_cell("换手率"), sep,
            value_cell(turnover_rate_str))
        )
            
        println(io)
    end
    
    function render_order_book(io::IO, book; max_rows::Int = 10)
        security_code = get(book, "code", "-")
        security_name = get(book, "name", "-")
        update_time = get(book, "server_recv_time_bid", "-")

        title = string(
            HEADER_STYLE("------ 摆盘 ------"), " ",
            HEADER_STYLE(security_code), " | ",
            HEADER_STYLE(security_name), " | ",
            HEADER_STYLE(update_time), " ",
            HEADER_STYLE("------")
        )
        println(io, title)
        println(io)

        col_width = 10
        spacing = " "

        header = string(
            LABEL_STYLE(lpad("买单数", col_width)), spacing,
            LABEL_STYLE(lpad("买量", col_width)), spacing,
            GOOD_STYLE(lpad("买价", col_width)), spacing,
            BAD_STYLE(lpad("卖价", col_width)), spacing,
            LABEL_STYLE(lpad("卖量", col_width)), spacing,
            LABEL_STYLE(lpad("卖单数", col_width))
        )
        println(io, header)
        println(io, repeat('─', col_width * 6 + textwidth(spacing) * 5))

        bid_list = get(book, "bid_list", [])
        ask_list = get(book, "ask_list", [])
        depth = min(max_rows, max(length(bid_list), length(ask_list)))

        for i in 1:depth
            bid = i <= length(bid_list) ? bid_list[i] : nothing
            ask = i <= length(ask_list) ? ask_list[i] : nothing

            bid_orders = bid === nothing ? "" : string(get(bid, "order_count", 0))
            bid_price = bid === nothing ? "" : @sprintf("%.3f", get(bid, "price", 0.0))
            bid_volume = bid === nothing ? "" : @sprintf("%d", get(bid, "volume", 0))

            ask_volume = ask === nothing ? "" : @sprintf("%d", get(ask, "volume", 0))
            ask_price = ask === nothing ? "" : @sprintf("%.3f", get(ask, "price", 0.0))
            ask_orders = ask === nothing ? "" : string(get(ask, "order_count", 0))

            row = string(
                LABEL_STYLE(lpad(bid_orders, col_width)), spacing,
                LABEL_STYLE(lpad(bid_volume, col_width)), spacing,
                GOOD_STYLE(lpad(bid_price, col_width)), spacing,
                BAD_STYLE(lpad(ask_price, col_width)), spacing,
                LABEL_STYLE(lpad(ask_volume, col_width)), spacing,
                LABEL_STYLE(lpad(ask_orders, col_width))
            )
            println(io, row)
        end

        println(io)
    end

    function render_kline(io::IO, kl_data; max_rows::Int = 10)
        security_code = get(kl_data, "code", "-")
        security_name = get(kl_data, "name", "-")
        kl_type = get(kl_data, "kl_type", 0)
        rehab_type = get(kl_data, "rehab_type", 0)

        # K线类型映射
        kl_type_str = if kl_type == 1
            "1分K"
        elseif kl_type == 2
            "日K"
        elseif kl_type == 3
            "周K"
        elseif kl_type == 4
            "月K"
        elseif kl_type == 5
            "年K"
        elseif kl_type == 6
            "5分K"
        elseif kl_type == 7
            "15分K"
        elseif kl_type == 8
            "30分K"
        elseif kl_type == 9
            "60分K"
        elseif kl_type == 10
            "3分K"
        elseif kl_type == 11
            "季K"
        else
            "未知($kl_type)"
        end

        # 复权类型映射
        rehab_type_str = if rehab_type == 0
            "不复权"
        elseif rehab_type == 1
            "前复权"
        elseif rehab_type == 2
            "后复权"
        else
            "未知($rehab_type)"
        end

        title = string(
            HEADER_STYLE("------ K线 ------"), " ",
            HEADER_STYLE(security_code), " | ",
            HEADER_STYLE(security_name), " | ",
            HEADER_STYLE(kl_type_str), " | ",
            HEADER_STYLE(rehab_type_str), " ",
            HEADER_STYLE("------")
        )
        println(io, title)
        println(io)

        col_width = 12
        spacing = " "

        header = string(
            LABEL_STYLE(rpad("时间", col_width + 8)), spacing,
            LABEL_STYLE(lpad("开盘", col_width)), spacing,
            LABEL_STYLE(lpad("最高", col_width)), spacing,
            LABEL_STYLE(lpad("最低", col_width)), spacing,
            LABEL_STYLE(lpad("收盘", col_width)), spacing,
            LABEL_STYLE(lpad("成交量", col_width)), spacing,
            LABEL_STYLE(lpad("涨跌幅", col_width))
        )
        println(io, header)
        println(io, repeat('─', (col_width + 8) + col_width * 6 + textwidth(spacing) * 6))

        kl_list = get(kl_data, "kl_list", [])
        rows_to_show = min(max_rows, length(kl_list))

        for i in 1:rows_to_show
            kl = kl_list[i]

            time_str = get(kl, "time", "-")
            open_price = get(kl, "open", 0.0)
            high_price = get(kl, "high", 0.0)
            low_price = get(kl, "low", 0.0)
            close_price = get(kl, "close", 0.0)
            last_close_price = get(kl, "last_close", 0.0)
            volume = get(kl, "volume", 0)
            change_rate_raw = get(kl, "change_rate", 0.0)

            # 如果服务器提供的 change_rate 是 0，尝试自己计算
            change_rate = if change_rate_raw == 0.0 && last_close_price != 0.0
                ((close_price - last_close_price) / last_close_price) * 100
            else
                change_rate_raw
            end

            # 根据涨跌幅决定颜色
            trend_style = if change_rate == 0.0
                VALUE_STYLE
            elseif change_rate > 0
                GOOD_STYLE
            else
                BAD_STYLE
            end

            open_str = @sprintf("%.3f", open_price)
            high_str = @sprintf("%.3f", high_price)
            low_str = @sprintf("%.3f", low_price)
            close_str = @sprintf("%.3f", close_price)
            volume_str = @sprintf("%d", volume)
            change_rate_str = change_rate == 0.0 ? "-" : @sprintf("%+.2f%%", change_rate)

            row = string(
                LABEL_STYLE(rpad(time_str, col_width + 8)), spacing,
                VALUE_STYLE(lpad(open_str, col_width)), spacing,
                VALUE_STYLE(lpad(high_str, col_width)), spacing,
                VALUE_STYLE(lpad(low_str, col_width)), spacing,
                trend_style(lpad(close_str, col_width)), spacing,
                VALUE_STYLE(lpad(volume_str, col_width)), spacing,
                trend_style(lpad(change_rate_str, col_width))
            )
            println(io, row)
        end

        println(io)
    end

    function render_rt(io::IO, rt_data; max_rows::Int = 10)
        security_code = get(rt_data, "code", "-")
        security_name = get(rt_data, "name", "-")

        # 获取最新一条分时记录的时间作为更新时间
        rt_list = get(rt_data, "rt_list", [])
        update_time = if !isempty(rt_list)
            get(rt_list[1], "time", "-")
        else
            "-"
        end

        title = string(
            HEADER_STYLE("------ 分时 ------"), " ",
            HEADER_STYLE(security_code), " | ",
            HEADER_STYLE(security_name), " | ",
            HEADER_STYLE(update_time), " ",
            HEADER_STYLE("------")
        )
        println(io, title)
        println(io)

        col_width = 14
        spacing = " "

        header = string(
            LABEL_STYLE(rpad("时间", col_width + 6)), spacing,
            LABEL_STYLE(lpad("价格", col_width)), spacing,
            LABEL_STYLE(lpad("均价", col_width)), spacing,
            LABEL_STYLE(lpad("成交量", col_width)), spacing,
            LABEL_STYLE(lpad("成交额", col_width)), spacing,
            LABEL_STYLE(lpad("涨跌", col_width)), spacing,
            LABEL_STYLE(lpad("涨跌幅", col_width))
        )
        println(io, header)
        println(io, repeat('─', (col_width + 6) + col_width * 6 + textwidth(spacing) * 6))

        rows_to_show = min(max_rows, length(rt_list))

        for i in 1:rows_to_show
            rt = rt_list[i]

            time_str = get(rt, "time", "-")
            price = get(rt, "price", 0.0)
            avg_price = get(rt, "avg_price", 0.0)
            volume = get(rt, "volume", 0)
            turnover = get(rt, "turnover", 0.0)
            last_close_price = get(rt, "last_close_price", missing)

            # 计算涨跌
            change = if last_close_price === missing || last_close_price == 0
                missing
            else
                price - last_close_price
            end

            # 计算涨跌幅
            change_rate = if change === missing || last_close_price == 0
                missing
            else
                (change / last_close_price) * 100
            end

            # 根据涨跌决定颜色
            trend_style = if change === missing || change == 0
                VALUE_STYLE
            elseif change > 0
                GOOD_STYLE
            else
                BAD_STYLE
            end

            price_str = @sprintf("%.3f", price)
            avg_price_str = @sprintf("%.3f", avg_price)
            volume_str = @sprintf("%d", volume)
            turnover_str = @sprintf("%.2f", turnover)
            change_str = change === missing ? "-" : @sprintf("%+.3f", change)
            change_rate_str = change_rate === missing ? "-" : @sprintf("%+.2f%%", change_rate)

            row = string(
                LABEL_STYLE(rpad(time_str, col_width + 6)), spacing,
                trend_style(lpad(price_str, col_width)), spacing,
                VALUE_STYLE(lpad(avg_price_str, col_width)), spacing,
                VALUE_STYLE(lpad(volume_str, col_width)), spacing,
                VALUE_STYLE(lpad(turnover_str, col_width)), spacing,
                trend_style(lpad(change_str, col_width)), spacing,
                trend_style(lpad(change_rate_str, col_width))
            )
            println(io, row)
        end

        println(io)
    end

    function render_ticker(io::IO, ticker_data; max_rows::Int = 20)
        security_code = get(ticker_data, "code", "-")
        security_name = get(ticker_data, "name", "-")

        # 获取最新一条逐笔记录的时间作为更新时间
        ticker_list = get(ticker_data, "ticker_list", [])
        update_time = if !isempty(ticker_list)
            get(ticker_list[1], "time", "-")
        else
            "-"
        end

        title = string(
            HEADER_STYLE("------ 逐笔 ------"), " ",
            HEADER_STYLE(security_code), " | ",
            HEADER_STYLE(security_name), " | ",
            HEADER_STYLE(update_time), " ",
            HEADER_STYLE("------")
        )
        println(io, title)
        println(io)

        dir_width = 8       # 方向列宽
        price_width = 12    # 价格列宽
        vol_width = 12      # 成交量列宽
        amt_width = 12      # 成交额列宽
        type_width = 20     # ticker_type 列宽
        sign_width = 6      # 符号列宽
        spacing = "  "      # 列间距

        header = string(
            LABEL_STYLE(rpad("方向", dir_width)), spacing,
            LABEL_STYLE(lpad("价格", price_width)), spacing,
            LABEL_STYLE(lpad("成交量", vol_width)), spacing,
            LABEL_STYLE(lpad("成交额", amt_width)), spacing,
            LABEL_STYLE(rpad("类型", type_width)), spacing,
            LABEL_STYLE(rpad("符号", sign_width))
        )
        println(io, header)
        println(io, repeat('─', dir_width + price_width + vol_width + amt_width + type_width + sign_width + textwidth(spacing) * 5))

        ticker_list = get(ticker_data, "ticker_list", [])
        rows_to_show = min(max_rows, length(ticker_list))

        for i in 1:rows_to_show
            ticker = ticker_list[i]

            direction = get(ticker, "direction", "NEUTRAL")
            price = get(ticker, "price", 0.0)
            volume = get(ticker, "volume", 0)
            turnover = get(ticker, "turnover", 0.0)
            ticker_type = get(ticker, "ticker_type", "-")
            type_sign = get(ticker, "type_sign", "")

            # 根据买卖方向决定颜色
            direction_style = if direction == "BUY"
                GOOD_STYLE
            elseif direction == "SELL"
                BAD_STYLE
            else
                VALUE_STYLE
            end

            # 方向显示文本
            direction_str = if direction == "BUY"
                "买入"
            elseif direction == "SELL"
                "卖出"
            else
                "中性"
            end

            # 显示符号字符（如果为空显示 "-"）
            sign_str = isempty(type_sign) ? "-" : type_sign

            price_str = @sprintf("%.3f", price)
            volume_str = @sprintf("%d", volume)
            turnover_str = @sprintf("%.2f", turnover)

            row = string(
                direction_style(rpad(direction_str, dir_width)), spacing,
                VALUE_STYLE(lpad(price_str, price_width)), spacing,
                VALUE_STYLE(lpad(volume_str, vol_width)), spacing,
                VALUE_STYLE(lpad(turnover_str, amt_width)), spacing,
                VALUE_STYLE(rpad(ticker_type, type_width)), spacing,
                VALUE_STYLE(rpad(sign_str, sign_width))
            )
            println(io, row)
        end

        println(io)
    end

    function render_broker(io::IO, broker_data; max_rows::Int = 10)
        security_code = get(broker_data, "code", "-")
        security_name = get(broker_data, "name", "-")
        update_time = get(broker_data, "update_time", "-")

        title = string(
            HEADER_STYLE("------ 经纪队列 ------"), " ",
            HEADER_STYLE(security_code), " | ",
            HEADER_STYLE(security_name), " | ",
            HEADER_STYLE(update_time), " ",
            HEADER_STYLE("------")
        )
        println(io, title)
        println(io)

        pos_width = 4
        id_width = 8
        name_width = 28
        spacing = " "

        header = string(
            LABEL_STYLE(lpad("买席位", id_width)), spacing,
            GOOD_STYLE(rpad("买经纪", name_width)), spacing,
            LABEL_STYLE(lpad("买档", pos_width)), spacing,
            LABEL_STYLE(rpad("卖档", pos_width)), spacing,
            BAD_STYLE(rpad("卖经纪", name_width)), spacing,
            LABEL_STYLE(lpad("卖席位", id_width))
        )
        println(io, header)
        println(io, repeat('─', pos_width * 2 + id_width * 2 + name_width * 2 + textwidth(spacing) * 5))

        bid_brokers = get(broker_data, "bid_brokers", [])
        ask_brokers = get(broker_data, "ask_brokers", [])
        depth = min(max_rows, max(length(bid_brokers), length(ask_brokers)))

        for i in 1:depth
            bid = i <= length(bid_brokers) ? bid_brokers[i] : nothing
            ask = i <= length(ask_brokers) ? ask_brokers[i] : nothing

            bid_pos = bid === nothing ? "" : string(get(bid, "broker_pos", 0))
            bid_id = bid === nothing ? "" : string(get(bid, "broker_id", 0))
            bid_name = bid === nothing ? "" : get(bid, "broker_name", "")

            ask_pos = ask === nothing ? "" : string(get(ask, "broker_pos", 0))
            ask_name = ask === nothing ? "" : get(ask, "broker_name", "")
            ask_id = ask === nothing ? "" : string(get(ask, "broker_id", 0))

            row = string(
                LABEL_STYLE(lpad(bid_id, id_width)), spacing,
                GOOD_STYLE(rpad(bid_name, name_width)), spacing,
                LABEL_STYLE(lpad(bid_pos, pos_width)), spacing,
                LABEL_STYLE(rpad(ask_pos, pos_width)), spacing,
                BAD_STYLE(rpad(ask_name, name_width)), spacing,
                LABEL_STYLE(lpad(ask_id, id_width))
            )
            println(io, row)
        end

        println(io)
    end

    function render_capital_distribution(io::IO, rows; total_inflow, total_outflow, net_inflow, update_time)
        label_width = 8
        value_width = 14
        pct_width = 10
        spacing = " "

        net_style = net_inflow >= 0 ? GOOD_STYLE : BAD_STYLE
        println(io, LABEL_STYLE("总流入 : "), GOOD_STYLE(@sprintf("%*.2f", value_width, total_inflow)), spacing,
            LABEL_STYLE("总流出 : "), BAD_STYLE(@sprintf("%*.2f", value_width, total_outflow)))
        println(io, LABEL_STYLE("净流入 : "), net_style(@sprintf("%*.2f", value_width, net_inflow)))
        println(io, LABEL_STYLE("更新时间 : "), VALUE_STYLE(isempty(update_time) ? "-" : update_time))
        println(io)

        header = string(
            LABEL_STYLE(rpad("类别", label_width)), spacing,
            GOOD_STYLE(lpad("流入", value_width)), spacing,
            BAD_STYLE(lpad("流出", value_width)), spacing,
            LABEL_STYLE(lpad("净额", value_width)), spacing,
            GOOD_STYLE(lpad("流入占比", pct_width)), spacing,
            BAD_STYLE(lpad("流出占比", pct_width))
        )
        println(io, header)
        println(io, repeat('─', label_width + value_width * 3 + pct_width * 2 + textwidth(spacing) * 5))

        for row in rows
            inflow_str = @sprintf("%*.2f", value_width, row.inflow)
            outflow_str = @sprintf("%*.2f", value_width, row.outflow)
            net_str = @sprintf("%*.2f", value_width, row.net)
            inflow_pct_str = @sprintf("%*.2f%%", pct_width - 1, row.inflow_pct)
            outflow_pct_str = @sprintf("%*.2f%%", pct_width - 1, row.outflow_pct)

            row_net_style = row.net >= 0 ? GOOD_STYLE : BAD_STYLE

            line = string(
                LABEL_STYLE(rpad(row.label, label_width)), spacing,
                GOOD_STYLE(inflow_str), spacing,
                BAD_STYLE(outflow_str), spacing,
                row_net_style(net_str), spacing,
                GOOD_STYLE(lpad(inflow_pct_str, pct_width)), spacing,
                BAD_STYLE(lpad(outflow_pct_str, pct_width))
            )
            println(io, line)
        end
    end

    function render_broker_queue(io::IO, bids, asks; max_rows::Int = 10)
        pos_width = 4
        id_width = 8
        name_width = 28
        spacing = " "

        header = string(
            LABEL_STYLE(lpad("买席位", id_width)), spacing,
            GOOD_STYLE(rpad("买经纪", name_width)), spacing,
            LABEL_STYLE(lpad("买档", pos_width)), spacing,
            LABEL_STYLE(rpad("卖档", pos_width)), spacing,
            BAD_STYLE(rpad("卖经纪", name_width)), spacing,
            LABEL_STYLE(lpad("卖席位", id_width))
        )
        println(io, header)
        println(io, repeat('─', pos_width * 2 + id_width * 2 + name_width * 2 + textwidth(spacing) * 5))

        depth = min(max_rows, max(length(bids), length(asks)))
        for i in 1:depth
            bid = i <= length(bids) ? bids[i] : nothing
            ask = i <= length(asks) ? asks[i] : nothing

            bid_pos = bid === nothing ? "" : string(bid.pos)
            bid_id = bid === nothing ? "" : string(bid.id)
            bid_name = bid === nothing ? "" : bid.name

            ask_pos = ask === nothing ? "" : string(ask.pos)
            ask_name = ask === nothing ? "" : ask.name
            ask_id = ask === nothing ? "" : string(ask.id)

            row = string(
                LABEL_STYLE(lpad(bid_id, id_width)), spacing,
                GOOD_STYLE(rpad(bid_name, name_width)), spacing,
                LABEL_STYLE(lpad(bid_pos, pos_width)), spacing,
                LABEL_STYLE(rpad(ask_pos, pos_width)), spacing,
                BAD_STYLE(rpad(ask_name, name_width)), spacing,
                LABEL_STYLE(lpad(ask_id, id_width))
            )
            println(io, row)
        end
    end

 # ======================= Client 模块 ==========================
    function parse_market_lines(market::AbstractString)
        pairs = Vector{Pair{String,String}}()
        for raw_line in split(market, '\n')
            stripped = strip(raw_line)
            isempty(stripped) && continue
            parts = split(raw_line, ':')
            length(parts) < 2 && continue
            label = strip(parts[1])
            status = strip(join(parts[2:end], ':'))
            push!(pairs, label => status)
        end
        return pairs
    end

    function render_delay_statistics(io::IO; success::Bool, ret_type, err_code, ret_msg::AbstractString, qot_push_statistics, req_reply_statistics, place_order_statistics)
        title = "Delay Statistics"
        println(io, HEADER_STYLE(title))
        println(io, HEADER_STYLE(repeat("=", max(3, Unicode.textwidth(title)))))

        println(io, "  ", LABEL_STYLE("Status : "), status_indicator(success))
        println(io, "  ", LABEL_STYLE("ret_type : "), VALUE_STYLE(string(ret_type)))
        println(io, "  ", LABEL_STYLE("err_code : "), VALUE_STYLE(string(err_code)))
        if !isempty(ret_msg)
            println(io, "  ", LABEL_STYLE("message : "), VALUE_STYLE(ret_msg))
        end
        println(io)

        if !success
            return
        end

        render_section(io, "Quote Push Statistics")
        if isempty(qot_push_statistics)
            println(io, "  ", VALUE_STYLE("No quote push data"))
        else
            for (idx, stat) in enumerate(qot_push_statistics)
                header = @sprintf("[%d] %s (type=%d)", idx, stat.push_type_name, stat.push_type)
                println(io, "  ", LABEL_STYLE(header))
                println(io, "     ", LABEL_STYLE("avg delay : "), VALUE_STYLE(@sprintf("%.2f ms", stat.delay_avg)))
                println(io, "     ", LABEL_STYLE("count     : "), VALUE_STYLE(string(stat.count)))
                if isempty(stat.segments)
                    println(io, "     ", LABEL_STYLE("segments  : "), VALUE_STYLE("(none)"))
                else
                    println(io, "     ", LABEL_STYLE("segments:"))
                    println(io, "       ", LABEL_STYLE("begin  end    count  proportion  cumulative"))
                    for seg in stat.segments
                        line = @sprintf("%5d  %5d  %6d   %8.2f   %9.2f",
                            seg.begin_ms, seg.end_ms, seg.count, seg.proportion, seg.cumulative_ratio)
                        println(io, "       ", VALUE_STYLE(line))
                    end
                end
                println(io)
            end
        end
        println(io)

        render_section(io, "Request / Reply Statistics")
        if isempty(req_reply_statistics)
            println(io, "  ", VALUE_STYLE("No request/reply data"))
        else
            header = "proto_id  count  total_avg  open_d_avg  net_delay  local_reply"
            println(io, "  ", LABEL_STYLE(header))
            for stat in req_reply_statistics
                parts = [
                    @sprintf("%8d", stat.proto_id),
                    @sprintf("%5d", stat.count),
                    @sprintf("%9.2f", stat.total_cost_avg),
                    @sprintf("%10.2f", stat.open_d_cost_avg),
                    @sprintf("%9.2f", stat.net_delay_avg)
                ]
                prefix = join(parts, "  ")
                local_indicator = stat.is_local_reply ? GOOD_STYLE("yes") : BAD_STYLE("no")
                println(io, "  ", VALUE_STYLE(prefix), "  ", local_indicator)
            end
        end

        println(io)
        render_section(io, "Place Order Statistics")
        if isempty(place_order_statistics)
            println(io, "  ", VALUE_STYLE("No place-order data"))
        else
            println(io, "  ", LABEL_STYLE("order_id        total  open_d  net_delay  update"))
            for stat in place_order_statistics
                line = @sprintf("%-14s  %5.2f  %6.2f    %7.2f  %6.2f",
                    stat.order_id,
                    stat.total_cost,
                    stat.open_d_cost,
                    stat.net_delay,
                    stat.update_cost)
                println(io, "  ", VALUE_STYLE(line))
            end
        end
    end

    status_indicator(flag::Bool) = flag ? GOOD_STYLE("✓") : BAD_STYLE("✗")

    function color_status(status::AbstractString)
        s = strip(String(status))
        isempty(s) && return VALUE_STYLE("-")
        upper = uppercase(s)
        if occursin("CLOS", upper) || occursin("NO TRADING", upper) || occursin("NONE", upper)
            return BAD_STYLE(s)
        elseif occursin("OPEN", upper) || occursin("READY", upper) || occursin("RUN", upper) || occursin("SUCCESS", upper)
            return GOOD_STYLE(s)
        elseif occursin("END", upper) || occursin("WAIT", upper) || occursin("NIGHT", upper) || occursin("AUCTION", upper) || occursin("AFTER", upper)
            return WARN_STYLE(s)
        else
            return VALUE_STYLE(s)
        end
    end

    function render_section(io::IO, title::AbstractString)
        println(io, SECTION_STYLE(String(title)))
        underline = repeat("─", max(3, Unicode.textwidth(String(title))))
        println(io, SECTION_STYLE(underline))
    end

    function render_global_state(io::IO; market_str::AbstractString, qot_logined::Bool, trd_logined::Bool, server_ver, server_build, server_time, local_time, conn_id, program_status::AbstractString, qot_server::AbstractString, trd_server::AbstractString)
        title = "Global State"
        println(io, HEADER_STYLE(title))
        println(io, HEADER_STYLE(repeat("=", max(3, Unicode.textwidth(title)))))
        println(io)

        render_section(io, "Markets")
        market_pairs = parse_market_lines(market_str)
        if isempty(market_pairs)
            println(io, "  ", VALUE_STYLE("No market data"))
        else
            label_width = maximum(Unicode.textwidth(label) for (label, _) in market_pairs) + 2
            for (label, status) in market_pairs
                padded = rpad(string(label, " :"), label_width)
                println(io, "  ", LABEL_STYLE(padded), " ", color_status(status))
            end
        end

        println(io)
        render_section(io, "Login Status")
        println(io, "  ", LABEL_STYLE("Quote : "), status_indicator(qot_logined),
            "    ", LABEL_STYLE("Trade : "), status_indicator(trd_logined))

        println(io)
        render_section(io, "Server")

        server_dt = unix2datetime(server_time)
        local_dt = unix2datetime(local_time)
        conn_hex = @sprintf("0x%016X", conn_id)

        println(io, "  ", LABEL_STYLE("Version : "), VALUE_STYLE(string(server_ver)),
            "    ", LABEL_STYLE("Build : "), VALUE_STYLE(string(server_build)))
        println(io, "  ", LABEL_STYLE("Server Time : "), VALUE_STYLE(Dates.format(server_dt, "yyyy-mm-dd HH:MM:SS")))
        println(io, "  ", LABEL_STYLE("Local Time  : "), VALUE_STYLE(Dates.format(local_dt, "yyyy-mm-dd HH:MM:SS")))
        println(io, "  ", LABEL_STYLE("Connection ID : "), VALUE_STYLE(conn_hex))
        println(io, "  ", LABEL_STYLE("Status : "), color_status(program_status))
        !isempty(qot_server) && println(io, "  ", LABEL_STYLE("Quote Server : "), VALUE_STYLE(qot_server))
        !isempty(trd_server) && println(io, "  ", LABEL_STYLE("Trade Server : "), VALUE_STYLE(trd_server))
    end

    function render_user_info(io::IO; nick_name::AbstractString, avatar_url::AbstractString, user_id, api_level::AbstractString, quote_rights, flags)
        title = "User Info"
        println(io, HEADER_STYLE(title))
        println(io, HEADER_STYLE(repeat("=", max(3, Unicode.textwidth(title)))))
        println(io)

        render_section(io, "Profile")
        println(io, "  ", LABEL_STYLE("Nick Name : "), VALUE_STYLE(nick_name))
        println(io, "  ", LABEL_STYLE("User ID   : "), VALUE_STYLE(string(user_id)))
        if !isempty(avatar_url)
            println(io, "  ", LABEL_STYLE("Avatar    : "), VALUE_STYLE(avatar_url))
        end
        println(io)

        render_section(io, "API & Flags")
        println(io, "  ", LABEL_STYLE("API Level : "), VALUE_STYLE(api_level == "" ? "-" : api_level))
        for (label, value) in flags
            println(io, "  ", LABEL_STYLE(string(label, " : ")), VALUE_STYLE(value))
        end
        println(io)

        render_section(io, "Quote Rights")
        if isempty(quote_rights)
            println(io, "  ", VALUE_STYLE("No quote rights information"))
        else
            for (market, status) in quote_rights
                indicator = status ? GOOD_STYLE("ENABLED") : BAD_STYLE("DISABLED")
                println(io, "  ", LABEL_STYLE(rpad(market, 12)), indicator)
            end
        end
    end

    function render_sub_info(io::IO; total_used_quota, remain_quota, connections)
        title = "Subscription Info"
        println(io, HEADER_STYLE(title))
        println(io, HEADER_STYLE(repeat("=", max(3, Unicode.textwidth(title)))))
        println(io)

        render_section(io, "Quota Summary")
        println(io, "  ", LABEL_STYLE("Total Used : "), VALUE_STYLE(string(total_used_quota)))
        println(io, "  ", LABEL_STYLE("Remaining  : "), VALUE_STYLE(string(remain_quota)))
        println(io)

        render_section(io, "Connections")
        if isempty(connections)
            println(io, "  ", VALUE_STYLE("No subscription connections"))
            return
        end

        for (idx, conn) in enumerate(connections)
            conn_title = @sprintf("Connection #%d", idx)
            println(io, "  ", LABEL_STYLE(conn_title))
            println(io, "     ", LABEL_STYLE("Used Quota : "), VALUE_STYLE(string(conn.used_quota)))
            println(io, "     ", LABEL_STYLE("Own Data   : "), status_indicator(conn.is_own_conn_data))

            if isempty(conn.subscriptions)
                println(io, "     ", VALUE_STYLE("No subscription records"))
            else
                for (sub_idx, sub) in enumerate(conn.subscriptions)
                    header = @sprintf("[%d] %s (type=%d)", sub_idx, sub.sub_type_label, sub.sub_type)
                    println(io, "     ", LABEL_STYLE(header))
                    if isempty(sub.securities)
                        println(io, "       ", VALUE_STYLE("(no securities)"))
                    else
                        for security_line in sub.securities
                            println(io, "       ", VALUE_STYLE(security_line))
                        end
                    end
                end
            end

            idx < length(connections) && println(io)
        end
    end

    # ======================= Trade 模块 ==========================

    """
        Base.show(io::IO, funds::Trd_Common.Funds)

    Display account funds information with colored output.

    Displays comprehensive fund information including:
    - Asset overview (total assets, cash, market value)
    - Cash details (frozen, available for withdrawal)
    - Buying power (long, short, cash power)
    - Securities position (long/short market values)
    - P&L information (unrealized/realized)
    - Margin information
    - Risk management status
    - Day trading information (for US accounts)
    - Asset breakdown by type
    - Cash info by currency (for futures)
    - Assets by market (for universal accounts)
    """
    function Base.show(io::IO, funds::AllProtos.Trd_Common.Funds)
        # Get currency string
        currency_str = string(AllProtos.Trd_Common.Currency.T(funds.currency))

        # Print header
        println(io, HEADER_STYLE("=" ^ 70))
        println(io, HEADER_STYLE("账户资金信息 (Account Funds Information)"))
        println(io, HEADER_STYLE("=" ^ 70))

        # Asset Overview
        println(io)
        println(io, ASSET_STYLE("【资产概况 Asset Overview】"))

        label_width = 30  # 统一的标签宽度
        println(io, "  ", LABEL_STYLE(Unicode.rpad("总资产 Total Assets", label_width)), " : ",
                AMOUNT_POSITIVE(@sprintf("%.2f", funds.totalAssets)), " ", CURRENCY_STYLE(currency_str))
        println(io, "  ", LABEL_STYLE(Unicode.rpad("现金 Cash", label_width)), " : ",
                AMOUNT_NEUTRAL(@sprintf("%.2f", funds.cash)), " ", CURRENCY_STYLE(currency_str))

        if funds.marketVal > 0
            println(io, "  ", LABEL_STYLE(Unicode.rpad("证券市值 Market Value", label_width)), " : ",
                    AMOUNT_NEUTRAL(@sprintf("%.2f", funds.marketVal)), " ", CURRENCY_STYLE(currency_str))
        end

        if funds.pendingAsset > 0
            println(io, "  ", LABEL_STYLE(Unicode.rpad("在途资产 Pending Assets", label_width)), " : ",
                    AMOUNT_WARNING(@sprintf("%.2f", funds.pendingAsset)), " ", CURRENCY_STYLE(currency_str))
        end

        # Cash Details
        if funds.frozenCash > 0 || funds.avlWithdrawalCash > 0 || funds.maxWithdrawal > 0 || funds.debtCash > 0
            println(io)
            println(io, ASSET_STYLE("【现金明细 Cash Details】"))

            if funds.frozenCash > 0
                println(io, "  ", LABEL_STYLE(Unicode.rpad("冻结资金 Frozen Cash", label_width)), " : ",
                        AMOUNT_WARNING(@sprintf("%.2f", funds.frozenCash)), " ", CURRENCY_STYLE(currency_str))
            end

            if funds.avlWithdrawalCash > 0
                println(io, "  ", LABEL_STYLE(Unicode.rpad("现金可提 Available Withdraw", label_width)), " : ",
                        AMOUNT_POSITIVE(@sprintf("%.2f", funds.avlWithdrawalCash)), " ", CURRENCY_STYLE(currency_str))
            end

            if funds.maxWithdrawal > 0
                println(io, "  ", LABEL_STYLE(Unicode.rpad("融资可提 Max Withdrawal", label_width)), " : ",
                        AMOUNT_POSITIVE(@sprintf("%.2f", funds.maxWithdrawal)), " ", CURRENCY_STYLE(currency_str))
            end

            if funds.debtCash > 0
                println(io, "  ", LABEL_STYLE(Unicode.rpad("计息金额 Debt Cash", label_width)), " : ",
                        AMOUNT_NEGATIVE(@sprintf("%.2f", funds.debtCash)), " ", CURRENCY_STYLE(currency_str))
            end
        end

        # Buying Power
        println(io)
        println(io, ASSET_STYLE("【购买力 Buying Power】"))
        println(io, "  ", LABEL_STYLE(Unicode.rpad("购买力 Power (Long)", label_width)), " : ",
                AMOUNT_POSITIVE(@sprintf("%.2f", funds.power)), " ", CURRENCY_STYLE(currency_str))

        if funds.maxPowerShort > 0
            println(io, "  ", LABEL_STYLE(Unicode.rpad("卖空购买力 Short Power", label_width)), " : ",
                    AMOUNT_POSITIVE(@sprintf("%.2f", funds.maxPowerShort)), " ", CURRENCY_STYLE(currency_str))
        end

        if funds.netCashPower > 0
            println(io, "  ", LABEL_STYLE(Unicode.rpad("现金购买力 Net Cash Power", label_width)), " : ",
                    AMOUNT_POSITIVE(@sprintf("%.2f", funds.netCashPower)), " ", CURRENCY_STYLE(currency_str))
        end

        if funds.availableFunds > 0
            println(io, "  ", LABEL_STYLE(Unicode.rpad("可用资金 Available Funds", label_width)), " : ",
                    AMOUNT_POSITIVE(@sprintf("%.2f", funds.availableFunds)), " ", CURRENCY_STYLE(currency_str))
        end

        # Securities & Market Value
        if funds.longMv > 0 || funds.shortMv > 0
            println(io)
            println(io, ASSET_STYLE("【证券持仓 Securities Position】"))

            if funds.longMv > 0
                println(io, "  ", LABEL_STYLE(Unicode.rpad("多头市值 Long Market Value", label_width)), " : ",
                        AMOUNT_POSITIVE(@sprintf("%.2f", funds.longMv)), " ", CURRENCY_STYLE(currency_str))
            end

            if funds.shortMv > 0
                println(io, "  ", LABEL_STYLE(Unicode.rpad("空头市值 Short Market Value", label_width)), " : ",
                        BAD_STYLE(@sprintf("%.2f", funds.shortMv)), " ", CURRENCY_STYLE(currency_str))
            end
        end

        # P&L Information
        if funds.unrealizedPL != 0 || funds.realizedPL != 0
            println(io)
            println(io, ASSET_STYLE("【盈亏信息 P&L Information】"))

            if funds.unrealizedPL != 0
                pl_style = funds.unrealizedPL >= 0 ? AMOUNT_POSITIVE : AMOUNT_NEGATIVE
                println(io, "  ", LABEL_STYLE(Unicode.rpad("未实现盈亏 Unrealized P/L", label_width)), " : ",
                        pl_style(@sprintf("%.2f", funds.unrealizedPL)), " ", CURRENCY_STYLE(currency_str))
            end

            if funds.realizedPL != 0
                pl_style = funds.realizedPL >= 0 ? AMOUNT_POSITIVE : AMOUNT_NEGATIVE
                println(io, "  ", LABEL_STYLE(Unicode.rpad("已实现盈亏 Realized P/L", label_width)), " : ",
                        pl_style(@sprintf("%.2f", funds.realizedPL)), " ", CURRENCY_STYLE(currency_str))
            end
        end

        # Margin Information
        if funds.initialMargin > 0 || funds.maintenanceMargin > 0 || funds.marginCallMargin > 0
            println(io)
            println(io, ASSET_STYLE("【保证金信息 Margin Information】"))

            if funds.initialMargin > 0
                println(io, "  ", LABEL_STYLE(Unicode.rpad("初始保证金 Initial Margin", label_width)), " : ",
                        AMOUNT_NEUTRAL(@sprintf("%.2f", funds.initialMargin)), " ", CURRENCY_STYLE(currency_str))
            end

            if funds.maintenanceMargin > 0
                println(io, "  ", LABEL_STYLE(Unicode.rpad("维持保证金 Maint. Margin", label_width)), " : ",
                        AMOUNT_NEUTRAL(@sprintf("%.2f", funds.maintenanceMargin)), " ", CURRENCY_STYLE(currency_str))
            end

            if funds.marginCallMargin > 0
                println(io, "  ", LABEL_STYLE(Unicode.rpad("追加保证金 Margin Call", label_width)), " : ",
                        AMOUNT_NEGATIVE(@sprintf("%.2f", funds.marginCallMargin)), " ", CURRENCY_STYLE(currency_str))
            end
        end

        # Risk Management
        println(io)
        println(io, ASSET_STYLE("【风险管理 Risk Management】"))

        # Risk Level (for futures)
        risk_level_str = try
            string(AllProtos.Trd_Common.CltRiskLevel.T(funds.riskLevel))
        catch
            "Unknown"
        end

        risk_color = if risk_level_str in ["Safe", "AbsoluteSafe"]
            GOOD_STYLE
        elseif risk_level_str == "Warning"
            WARN_STYLE
        elseif risk_level_str in ["Danger", "OptDanger"]
            BAD_STYLE
        else
            VALUE_STYLE
        end

        println(io, "  ", LABEL_STYLE(Unicode.rpad("风险等级 Risk Level", label_width)), " : ", risk_color(risk_level_str))

        # Risk Status (for securities)
        risk_status_str = try
            string(AllProtos.Trd_Common.CltRiskStatus.T(funds.riskStatus))
        catch
            "Unknown"
        end

        status_color = if occursin("Level1", risk_status_str) || occursin("Level2", risk_status_str)
            GOOD_STYLE
        elseif occursin("Level3", risk_status_str) || occursin("Level4", risk_status_str)
            Crayon(foreground=:light_green, bold=true)
        elseif occursin("Level5", risk_status_str)
            WARN_STYLE
        elseif occursin("Level6", risk_status_str)
            Crayon(foreground=:light_yellow, bold=true)
        else
            BAD_STYLE
        end

        println(io, "  ", LABEL_STYLE(Unicode.rpad("风险状态 Risk Status", label_width)), " : ", status_color(risk_status_str))

        # Day Trading Information (for US accounts)
        if funds.isPdt || !isempty(funds.pdtSeq) || funds.beginningDTBP > 0 || funds.dtCallAmount > 0
            println(io)
            println(io, ASSET_STYLE("【日内交易 Day Trading】"))

            pdt_style = funds.isPdt ? WARN_STYLE : VALUE_STYLE
            pdt_text = funds.isPdt ? "是 Yes" : "否 No"
            println(io, "  ", LABEL_STYLE(Unicode.rpad("PDT账户 PDT Account", label_width)), " : ", pdt_style(pdt_text))

            if !isempty(funds.pdtSeq)
                println(io, "  ", LABEL_STYLE(Unicode.rpad("剩余次数 Remaining Trades", label_width)), " : ",
                        AMOUNT_NEUTRAL(funds.pdtSeq))
            end

            if funds.beginningDTBP > 0
                println(io, "  ", LABEL_STYLE(Unicode.rpad("初始日内购买力 Begin DTBP", label_width)), " : ",
                        AMOUNT_NEUTRAL(@sprintf("%.2f", funds.beginningDTBP)), " ", CURRENCY_STYLE(currency_str))
            end

            if funds.remainingDTBP > 0
                println(io, "  ", LABEL_STYLE(Unicode.rpad("剩余日内购买力 Remain DTBP", label_width)), " : ",
                        AMOUNT_POSITIVE(@sprintf("%.2f", funds.remainingDTBP)), " ", CURRENCY_STYLE(currency_str))
            end

            if funds.dtCallAmount > 0
                println(io, "  ", LABEL_STYLE(Unicode.rpad("日内追缴金额 DT Call Amount", label_width)), " : ",
                        AMOUNT_NEGATIVE(@sprintf("%.2f", funds.dtCallAmount)), " ", CURRENCY_STYLE(currency_str))
            end

            dt_status_str = try
                string(AllProtos.Trd_Common.DTStatus.T(funds.dtStatus))
            catch
                "Unknown"
            end

            dt_color = if dt_status_str == "Unlimited"
                GOOD_STYLE
            elseif dt_status_str in ["EMCall", "DTCall"]
                BAD_STYLE
            else
                VALUE_STYLE
            end

            println(io, "  ", LABEL_STYLE(Unicode.rpad("日内交易状态 DT Status", label_width)), " : ", dt_color(dt_status_str))
        end

        # Asset Breakdown
        if funds.securitiesAssets > 0 || funds.fundAssets > 0 || funds.bondAssets > 0
            println(io)
            println(io, ASSET_STYLE("【资产细分 Asset Breakdown】"))

            if funds.securitiesAssets > 0
                println(io, "  ", LABEL_STYLE(Unicode.rpad("证券资产 Securities Assets", label_width)), " : ",
                        AMOUNT_NEUTRAL(@sprintf("%.2f", funds.securitiesAssets)), " ", CURRENCY_STYLE(currency_str))
            end

            if funds.fundAssets > 0
                println(io, "  ", LABEL_STYLE(Unicode.rpad("基金资产 Fund Assets", label_width)), " : ",
                        AMOUNT_NEUTRAL(@sprintf("%.2f", funds.fundAssets)), " ", CURRENCY_STYLE(currency_str))
            end

            if funds.bondAssets > 0
                println(io, "  ", LABEL_STYLE(Unicode.rpad("债券资产 Bond Assets", label_width)), " : ",
                        AMOUNT_NEUTRAL(@sprintf("%.2f", funds.bondAssets)), " ", CURRENCY_STYLE(currency_str))
            end
        end

        # Cash Info by Currency (for futures)
        if !isempty(funds.cashInfoList)
            println(io)
            println(io, ASSET_STYLE("【分币种现金 Cash by Currency】"))

            sub_label_width = 24  # For sub-items
            for (i, cash_info) in enumerate(funds.cashInfoList)
                curr_str = try
                    string(AllProtos.Trd_Common.Currency.T(cash_info.currency))
                catch
                    "Unknown"
                end

                println(io, "  ", CURRENCY_STYLE("币种 Currency #$i: $curr_str"))
                println(io, "    ", LABEL_STYLE(Unicode.rpad("现金 Cash", sub_label_width)), " : ",
                        AMOUNT_NEUTRAL(@sprintf("%.2f", cash_info.cash)))
                println(io, "    ", LABEL_STYLE(Unicode.rpad("可提 Available Balance", sub_label_width)), " : ",
                        AMOUNT_NEUTRAL(@sprintf("%.2f", cash_info.availableBalance)))
                println(io, "    ", LABEL_STYLE(Unicode.rpad("购买力 Cash Power", sub_label_width)), " : ",
                        AMOUNT_POSITIVE(@sprintf("%.2f", cash_info.netCashPower)))
            end
        end

        # Market Info (for universal accounts)
        if !isempty(funds.marketInfoList)
            println(io)
            println(io, ASSET_STYLE("【分市场资产 Assets by Market】"))

            for market_info in funds.marketInfoList
                market_str = try
                    string(AllProtos.Trd_Common.TrdMarket.T(market_info.trdMarket))
                catch
                    "Unknown"
                end

                println(io, "  ", LABEL_STYLE("市场 Market: "), CURRENCY_STYLE(market_str),
                        LABEL_STYLE(" - 资产 Assets: "),
                        AMOUNT_NEUTRAL(@sprintf("%.2f", market_info.assets)), " ", CURRENCY_STYLE(currency_str))
            end
        end

        println(io)
    end

    # ======================= Protocol Display Methods ==========================

    # GetGlobalState.S2C display
    function Base.show(io::IO, state::AllProtos.GetGlobalState.S2C)
        market_data = Dict(
            :marketHK => state.marketHK,
            :marketUS => state.marketUS,
            :marketSH => state.marketSH,
            :marketSZ => state.marketSZ,
            :marketHKFuture => state.marketHKFuture,
            :marketUSFuture => state.marketUSFuture,
            :marketSGFuture => state.marketSGFuture,
            :marketJPFuture => state.marketJPFuture,
        )

        render_global_state(
            io;
            market_str = AllProtos.GetGlobalState.format_all_markets(market_data),
            qot_logined = state.qotLogined,
            trd_logined = state.trdLogined,
            server_ver = state.serverVer,
            server_build = state.serverBuildNo,
            server_time = state.time,
            local_time = state.localTime,
            conn_id = state.connID,
            program_status = AllProtos.Common.format_program_status(state.programStatus),
            qot_server = state.qotSvrIpAddr,
            trd_server = state.trdSvrIpAddr,
        )
    end

    # GetGlobalState.GlobalStateInfo display
    function Base.show(io::IO, gs::AllProtos.GetGlobalState.GlobalStateInfo)
        render_global_state(
            io;
            market_str = gs.market,
            qot_logined = gs.qot_logined,
            trd_logined = gs.trd_logined,
            server_ver = gs.server_ver,
            server_build = gs.server_build,
            server_time = gs.server_time,
            local_time = gs.local_time,
            conn_id = gs.conn_id,
            program_status = gs.program_status,
            qot_server = gs.qot_server,
            trd_server = gs.trd_server,
        )
    end

    # GetDelayStatistics.DelayStatisticsInfo display
    function Base.show(io::IO, info::AllProtos.GetDelayStatistics.DelayStatisticsInfo)
        render_delay_statistics(
            io;
            success = info.success,
            ret_type = info.ret_type,
            err_code = info.err_code,
            ret_msg = info.ret_msg,
            qot_push_statistics = info.qot_push_statistics,
            req_reply_statistics = info.req_reply_statistics,
            place_order_statistics = info.place_order_statistics,
        )
    end

    # GetUserInfo.UserInfoSummary display
    function Base.show(io::IO, info::AllProtos.GetUserInfo.UserInfoSummary)
        render_user_info(
            io;
            nick_name = info.nick_name,
            avatar_url = info.avatar_url,
            user_id = info.user_id,
            api_level = info.api_level,
            quote_rights = [(qr.name, qr.enabled) for qr in info.quote_rights],
            flags = info.flags,
        )
    end

    # Qot_GetSubInfo.S2C display
    function Base.show(io::IO, info::AllProtos.Qot_GetSubInfo.S2C)
        connections = [AllProtos.Qot_GetSubInfo.build_connection_summary(conn) for conn in info.connSubInfoList]
        render_sub_info(
            io;
            total_used_quota = info.totalUsedQuota,
            remain_quota = info.remainQuota,
            connections = connections,
        )
    end

end # module Display
