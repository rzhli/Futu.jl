module Qot_GetCapitalDistribution

using ProtoBuf
import ProtoBuf as PB
import ..Common
import ..Qot_Common

# 客户端到服务端请求消息
mutable struct C2S
    security::Qot_Common.Security  # 股票
end
PB.default_values(::Type{C2S}) = (;security = Qot_Common.Security())
PB.field_numbers(::Type{C2S}) = (;security = 1)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    x.security != Qot_Common.Security() && PB.encode(e, 1, x.security)
    return position(e.io) - initpos
end

# 服务端到客户端响应消息
mutable struct S2C
    capitalInBig::Float64       # 流入资金额度，大单
    capitalInMid::Float64       # 流入资金额度，中单
    capitalInSmall::Float64     # 流入资金额度，小单
    capitalOutBig::Float64      # 流出资金额度，大单
    capitalOutMid::Float64      # 流出资金额度，中单
    capitalOutSmall::Float64    # 流出资金额度，小单
    updateTime::String          # 更新时间字符串
    updateTimestamp::Float64    # 更新时间戳
    capitalInSuper::Float64     # 流入资金额度，特大单
    capitalOutSuper::Float64    # 流出资金额度，特大单
end
S2C(; capitalInBig = 0.0, capitalInMid = 0.0, capitalInSmall = 0.0, capitalOutBig = 0.0, capitalOutMid = 0.0, capitalOutSmall = 0.0, updateTime = "", updateTimestamp = 0.0, capitalInSuper = 0.0, capitalOutSuper = 0.0) = S2C(capitalInBig, capitalInMid, capitalInSmall, capitalOutBig, capitalOutMid, capitalOutSmall, updateTime, updateTimestamp, capitalInSuper, capitalOutSuper)
PB.default_values(::Type{S2C}) = (;capitalInBig = zero(Float64), capitalInMid = zero(Float64), capitalInSmall = zero(Float64), capitalOutBig = zero(Float64), capitalOutMid = zero(Float64), capitalOutSmall = zero(Float64), updateTime = "", updateTimestamp = zero(Float64), capitalInSuper = zero(Float64), capitalOutSuper = zero(Float64))
PB.field_numbers(::Type{S2C}) = (;capitalInBig = 1, capitalInMid = 2, capitalInSmall = 3, capitalOutBig = 4, capitalOutMid = 5, capitalOutSmall = 6, updateTime = 7, updateTimestamp = 8, capitalInSuper = 9, capitalOutSuper = 10)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    capitalInBig = zero(Float64)
    capitalInMid = zero(Float64)
    capitalInSmall = zero(Float64)
    capitalOutBig = zero(Float64)
    capitalOutMid = zero(Float64)
    capitalOutSmall = zero(Float64)
    updateTime = ""
    updateTimestamp = zero(Float64)
    capitalInSuper = zero(Float64)
    capitalOutSuper = zero(Float64)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            capitalInBig = PB.decode(d, Float64)
        elseif field_number == 2
            capitalInMid = PB.decode(d, Float64)
        elseif field_number == 3
            capitalInSmall = PB.decode(d, Float64)
        elseif field_number == 4
            capitalOutBig = PB.decode(d, Float64)
        elseif field_number == 5
            capitalOutMid = PB.decode(d, Float64)
        elseif field_number == 6
            capitalOutSmall = PB.decode(d, Float64)
        elseif field_number == 7
            updateTime = PB.decode(d, String)
        elseif field_number == 8
            updateTimestamp = PB.decode(d, Float64)
        elseif field_number == 9
            capitalInSuper = PB.decode(d, Float64)
        elseif field_number == 10
            capitalOutSuper = PB.decode(d, Float64)
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(capitalInBig, capitalInMid, capitalInSmall, capitalOutBig, capitalOutMid, capitalOutSmall, updateTime, updateTimestamp, capitalInSuper, capitalOutSuper)
end

# 请求消息
mutable struct Request
    c2s::C2S  # 客户端到服务端请求
    Request(; c2s = C2S()) = new(c2s)
end
PB.default_values(::Type{Request}) = (;c2s = C2S())
PB.field_numbers(::Type{Request}) = (;c2s = 1)
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
PB.default_values(::Type{Response}) = (;retType = Common.RetType.Unknown, retMsg = "", errCode = 0, s2c = S2C())
PB.field_numbers(::Type{Response}) = (;retType = 1, retMsg = 2, errCode = 3, s2c = 4)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:Response})
    retType = Common.RetType.Unknown
    retMsg = ""
    errCode = 0
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
