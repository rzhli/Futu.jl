module Qot_GetUserSecurity

import ProtoBuf as PB
import ..Common
import ..Qot_Common

# 客户端到服务端请求消息
mutable struct C2S
    groupName::String  # 分组名，有同名的返回排序首个
end
C2S(; groupName = "") = C2S(String(groupName))

PB.default_values(::Type{C2S}) = (; groupName = "")
PB.field_numbers(::Type{C2S}) = (; groupName = 1)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    PB.encode(e, 1, x.groupName)  # Always encode groupName (required field)
    return position(e.io) - initpos
end

# 服务端到客户端响应消息
mutable struct S2C
    staticInfoList::Vector{Qot_Common.SecurityStaticInfo}  # 自选股分组下的股票列表
end
S2C(; staticInfoList = Vector{Qot_Common.SecurityStaticInfo}()) = S2C(staticInfoList)

PB.default_values(::Type{S2C}) = (; staticInfoList = Vector{Qot_Common.SecurityStaticInfo}())
PB.field_numbers(::Type{S2C}) = (; staticInfoList = 1)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    staticInfoList = Vector{Qot_Common.SecurityStaticInfo}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            push!(staticInfoList, PB.decode(d, Ref{Qot_Common.SecurityStaticInfo}))
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(staticInfoList)
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

export C2S, S2C, Request, Response

end
