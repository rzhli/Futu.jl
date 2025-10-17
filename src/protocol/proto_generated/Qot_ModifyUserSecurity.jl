module Qot_ModifyUserSecurity

import ProtoBuf as PB
using ProtoBuf.EnumX
import ..Common
import ..Qot_Common

# 用户自选股操作类型枚举
@enumx ModifyUserSecurityOp begin
    Unknown = 0  # 未知
    Add = 1      # 新增
    Del = 2      # 删除自选
    MoveOut = 3  # 移出分组
end

# 客户端到服务端请求消息
mutable struct C2S
    groupName::String                    # 分组名，有同名的返回排序的首个
    op::Int32                           # 操作类型
    securityList::Vector{Qot_Common.Security}  # 新增、删除或移出该分组下的股票
end
C2S(; groupName = "", op = Int32(0), securityList = Vector{Qot_Common.Security}()) =
    C2S(String(groupName), Int32(op), securityList)

PB.default_values(::Type{C2S}) = (; groupName = "", op = Int32(0), securityList = Vector{Qot_Common.Security}())
PB.field_numbers(::Type{C2S}) = (; groupName = 1, op = 2, securityList = 3)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    PB.encode(e, 1, x.groupName)  # Always encode groupName (required)
    PB.encode(e, 2, x.op)  # Always encode op (required)
    !isempty(x.securityList) && PB.encode(e, 3, x.securityList)
    return position(e.io) - initpos
end

# 服务端到客户端响应消息（空结构体）
mutable struct S2C
end

PB.default_values(::Type{S2C}) = NamedTuple()
PB.field_numbers(::Type{S2C}) = NamedTuple()
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        PB.skip(d, wire_type)
    end
    return S2C()
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
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:Response})
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

export ModifyUserSecurityOp, C2S, S2C, Request, Response

end
