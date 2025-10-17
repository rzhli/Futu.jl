module Qot_GetUserSecurityGroup

import ProtoBuf as PB
using ProtoBuf.EnumX
import ..Common
import ..Qot_Common

# 自选股分组类型
@enumx GroupType begin
    Unknown = 0  # 未知
    Custom = 1   # 自定义分组
    System = 2   # 系统分组
    All = 3      # 全部分组
end

# 客户端到服务端请求消息
mutable struct C2S
    groupType::Int32  # GroupType,自选股分组类型。
end
C2S(; groupType = Int32(1)) = C2S(Int32(groupType))

PB.default_values(::Type{C2S}) = (; groupType = Int32(1))
PB.field_numbers(::Type{C2S}) = (; groupType = 1)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    PB.encode(e, 1, x.groupType)  # Always encode groupType (required field)
    return position(e.io) - initpos
end

# 分组数据
mutable struct GroupData
    groupName::String  # 自选股分组名字
    groupType::Int32   # GroupType,自选股分组类型。
end
GroupData(; groupName = "", groupType = Int32(0)) = GroupData(String(groupName), Int32(groupType))

PB.default_values(::Type{GroupData}) = (; groupName = "", groupType = Int32(0))
PB.field_numbers(::Type{GroupData}) = (; groupName = 1, groupType = 2)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:GroupData})
    groupName = ""
    groupType = Int32(0)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            groupName = PB.decode(d, String)
        elseif field_number == 2
            groupType = PB.decode(d, Int32)
        else
            PB.skip(d, wire_type)
        end
    end
    return GroupData(groupName, groupType)
end

# 服务端到客户端响应消息
mutable struct S2C
    groupList::Vector{GroupData}  # 自选股分组列表
end
S2C(; groupList = Vector{GroupData}()) = S2C(groupList)

PB.default_values(::Type{S2C}) = (; groupList = Vector{GroupData}())
PB.field_numbers(::Type{S2C}) = (; groupList = 1)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    groupList = Vector{GroupData}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            push!(groupList, PB.decode(d, Ref{GroupData}))
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(groupList)
end

# 请求消息
mutable struct Request
    c2s::C2S
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
    retMsg::String
    errCode::Int32
    s2c::S2C
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

export GroupType, C2S, GroupData, S2C, Request, Response

end
