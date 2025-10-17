module Qot_SetPriceReminder

import ProtoBuf as PB
using ProtoBuf.EnumX
import ..Common
import ..Qot_Common

# 到价提醒操作类型枚举
@enumx SetPriceReminderOp begin
    Unknown = 0  # 未知
    Add = 1      # 新增
    Del = 2      # 删除
    Enable = 3   # 启用
    Disable = 4  # 禁用
    Modify = 5   # 修改
    DelAll = 6   # 删除该支股票下所有到价提醒
end

# 客户端到服务端请求消息
mutable struct C2S
    security::Qot_Common.Security              # 股票
    op::Int32                                  # 操作类型
    key::Int64                                 # 到价提醒的标识
    type::Int32                                # 提醒类型
    freq::Int32                                # 提醒频率类型
    value::Float64                             # 提醒值
    note::String                               # 用户设置到价提醒时的标注
    reminderSessionList::Vector{Int32}         # 到价提醒的时段列表
end
C2S(; security = Qot_Common.Security(), op = Int32(0), key = Int64(0), type = Int32(0), freq = Int32(0), value = 0.0, note = "", reminderSessionList = Vector{Int32}()) =
    C2S(security, Int32(op), Int64(key), Int32(type), Int32(freq), Float64(value), String(note), reminderSessionList)

PB.default_values(::Type{C2S}) = (; security = Qot_Common.Security(), op = Int32(0), key = Int64(0), type = Int32(0), freq = Int32(0), value = 0.0, note = "", reminderSessionList = Vector{Int32}())
PB.field_numbers(::Type{C2S}) = (; security = 1, op = 2, key = 3, type = 4, value = 5, note = 6, freq = 7, reminderSessionList = 8)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    PB.encode(e, 1, x.security)
    x.op != 0 && PB.encode(e, 2, x.op)
    x.key != 0 && PB.encode(e, 3, x.key)
    x.type != 0 && PB.encode(e, 4, x.type)
    x.value != 0.0 && PB.encode(e, 5, x.value)
    x.note != "" && PB.encode(e, 6, x.note)
    x.freq != 0 && PB.encode(e, 7, x.freq)
    !isempty(x.reminderSessionList) && PB.encode(e, 8, x.reminderSessionList)
    return position(e.io) - initpos
end

# 服务端到客户端响应消息
mutable struct S2C
    key::Int64  # 设置成功的情况下返回对应的key，不成功返回0
end
S2C(; key = Int64(0)) = S2C(Int64(key))

PB.default_values(::Type{S2C}) = (; key = Int64(0))
PB.field_numbers(::Type{S2C}) = (; key = 1)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{S2C})
    key = Int64(0)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            key = PB.decode(d, Int64)
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(key)
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
    return Response(retType, retMsg, errCode, s2c)
end

export SetPriceReminderOp, C2S, S2C, Request, Response

end
