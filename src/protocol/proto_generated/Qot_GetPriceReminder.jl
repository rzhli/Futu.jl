module Qot_GetPriceReminder

import ProtoBuf as PB
using ProtoBuf.EnumX
import ..Common
import ..Qot_Common

# 提醒信息列表
mutable struct PriceReminderItem
    key::Int64                           # 每个提醒的唯一标识
    type::Int32                          # 提醒类型
    value::Float64                       # 提醒参数值
    note::String                         # 备注仅支持 20 个以内的中文字符
    freq::Int32                          # 提醒频率类型
    isEnable::Bool                       # 该提醒设置是否生效
    reminderSessionList::Vector{Int32}   # 枚举参考Qot_Common::PriceReminderMarketStatus
end
PriceReminderItem(; key = Int64(0), type = Int32(0), value = 0.0, note = "", freq = Int32(0), isEnable = false, reminderSessionList = Vector{Int32}()) =
    PriceReminderItem(Int64(key), Int32(type), Float64(value), String(note), Int32(freq), Bool(isEnable), reminderSessionList)

PB.default_values(::Type{PriceReminderItem}) = (; key = Int64(0), type = Int32(0), value = 0.0, note = "", freq = Int32(0), isEnable = false, reminderSessionList = Vector{Int32}())
PB.field_numbers(::Type{PriceReminderItem}) = (; key = 1, type = 2, value = 3, note = 4, freq = 5, isEnable = 6, reminderSessionList = 7)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{PriceReminderItem})
    key = Int64(0)
    type = Int32(0)
    value = 0.0
    note = ""
    freq = Int32(0)
    isEnable = false
    reminderSessionList = Vector{Int32}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            key = PB.decode(d, Int64)
        elseif field_number == 2
            type = PB.decode(d, Int32)
        elseif field_number == 3
            value = PB.decode(d, Float64)
        elseif field_number == 4
            note = PB.decode(d, String)
        elseif field_number == 5
            freq = PB.decode(d, Int32)
        elseif field_number == 6
            isEnable = PB.decode(d, Bool)
        elseif field_number == 7
            push!(reminderSessionList, PB.decode(d, Int32))
        else
            PB.skip(d, wire_type)
        end
    end
    return PriceReminderItem(key = key, type = type, value = value, note = note, freq = freq, isEnable = isEnable, reminderSessionList = reminderSessionList)
end

# 到价提醒信息
mutable struct PriceReminder
    security::Qot_Common.Security        # 股票
    name::String                         # 股票名称
    itemList::Vector{PriceReminderItem}  # 提醒信息列表
end
PriceReminder(; security = Qot_Common.Security(), name = "", itemList = Vector{PriceReminderItem}()) =
    PriceReminder(security, String(name), itemList)

PB.default_values(::Type{PriceReminder}) = (; security = Qot_Common.Security(), name = "", itemList = Vector{PriceReminderItem}())
PB.field_numbers(::Type{PriceReminder}) = (; security = 1, itemList = 2, name = 3)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{PriceReminder})
    security = Qot_Common.Security()
    name = ""
    itemList = Vector{PriceReminderItem}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            security = PB.decode(d, Ref{Qot_Common.Security})
        elseif field_number == 2
            push!(itemList, PB.decode(d, Ref{PriceReminderItem}))
        elseif field_number == 3
            name = PB.decode(d, String)
        else
            PB.skip(d, wire_type)
        end
    end
    return PriceReminder(security = security, name = name, itemList = itemList)
end

# 客户端到服务端请求消息
mutable struct C2S
    security::Union{Nothing, Qot_Common.Security}  # 查询股票下的到价提醒项
    market::Int32                                  # 市场，查询市场下的到价提醒项
end
C2S(; security = nothing, market = Int32(0)) = C2S(security, Int32(market))

PB.default_values(::Type{C2S}) = (; security = nothing, market = Int32(0))
PB.field_numbers(::Type{C2S}) = (; security = 1, market = 2)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    !isnothing(x.security) && PB.encode(e, 1, x.security)
    x.market != 0 && PB.encode(e, 2, x.market)
    return position(e.io) - initpos
end

# 服务端到客户端响应消息
mutable struct S2C
    priceReminderList::Vector{PriceReminder}  # 到价提醒
end
S2C(; priceReminderList = Vector{PriceReminder}()) = S2C(priceReminderList)

PB.default_values(::Type{S2C}) = (; priceReminderList = Vector{PriceReminder}())
PB.field_numbers(::Type{S2C}) = (; priceReminderList = 1)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{S2C})
    priceReminderList = Vector{PriceReminder}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            push!(priceReminderList, PB.decode(d, Ref{PriceReminder}))
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(priceReminderList = priceReminderList)
end

# 请求消息
mutable struct Request
    c2s::C2S  # 客户端到服务端请求
end
Request(; c2s = C2S()) = Request(c2s)

PB.default_values(::Type{Request}) = (; c2s = C2S())
PB.field_numbers(::Type{Request}) = (; c2s = 1)
function PB.encode(e::PB.AbstractProtoEncoder, x::Request)
    initpos = position(e.io)
    PB.encode(e, 1, x.c2s)
    return position(e.io) - initpos
end

# 响应消息
mutable struct Response
    retType::Int32    # RetType,返回结果
    retMsg::String    # 返回消息
    errCode::Int32    # 错误码
    s2c::S2C          # 服务端到客户端响应
end
Response(; retType = Int32(-400), retMsg = "", errCode = Int32(0), s2c = S2C()) =
    Response(Int32(retType), String(retMsg), Int32(errCode), s2c)

PB.default_values(::Type{Response}) = (; retType = Int32(-400), retMsg = "", errCode = Int32(0), s2c = S2C())
PB.field_numbers(::Type{Response}) = (; retType = 1, retMsg = 2, errCode = 3, s2c = 4)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{Response})
    retType = Int32(-400)
    retMsg = ""
    errCode = Int32(0)
    s2c = S2C()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            retType = PB.decode(d, Int32)
        elseif field_number == 2
            retMsg = PB.decode(d, String)
        elseif field_number == 3
            errCode = PB.decode(d, Int32)
        elseif field_number == 4
            s2c = PB.decode(d, Ref{S2C})
        else
            PB.skip(d, wire_type)
        end
    end
    return Response(retType = retType, retMsg = retMsg, errCode = errCode, s2c = s2c)
end

export PriceReminderItem, PriceReminder, C2S, S2C, Request, Response

end
