module Qot_GetCapitalFlow

import ProtoBuf as PB
import ..Common
import ..Qot_Common

# 客户端到服务端请求消息
mutable struct C2S
    security::Qot_Common.Security  # 股票
    periodType::Int32              # 周期类型
    beginTime::String              # 开始时间（格式：yyyy-MM-dd），仅周期类型不为实时有效
    endTime::String                # 结束时间（格式：yyyy-MM-dd），仅周期类型不为实时有效
    C2S(; 
    security = Qot_Common.Security(), periodType::Integer = 0, beginTime::AbstractString = "", endTime::AbstractString = ""
    ) = new(security, periodType, beginTime, endTime)
end
PB.default_values(::Type{C2S}) = (;security = Qot_Common.Security(), periodType = 0, beginTime = "", endTime = "")
PB.field_numbers(::Type{C2S}) = (;security = 1, periodType = 2, beginTime = 3, endTime = 4)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    x.security != Qot_Common.Security() && PB.encode(e, 1, x.security)
    x.periodType != 0 && PB.encode(e, 2, x.periodType)
    x.beginTime != "" && PB.encode(e, 3, x.beginTime)
    x.endTime != "" && PB.encode(e, 4, x.endTime)
    return position(e.io) - initpos
end

# 资金流向项
mutable struct CapitalFlowItem
    inFlow::Float64                # 整体净流入
    time::String                   # 开始时间字符串,以分钟为单位
    timestamp::Float64             # 开始时间戳
    mainInFlow::Float64            # 主力大单净流入，仅周期类型不为实时有效
    superInFlow::Float64           # 特大单净流入
    bigInFlow::Float64             # 大单净流入
    midInFlow::Float64             # 中单净流入
    smlInFlow::Float64             # 小单净流入
    
    CapitalFlowItem(; 
    inFlow = 0.0, time = "", timestamp = 0.0, mainInFlow = 0.0, superInFlow = 0.0, bigInFlow = 0.0, midInFlow = 0.0, smlInFlow = 0.0
    ) = new(inFlow, time, timestamp, mainInFlow, superInFlow, bigInFlow, midInFlow, smlInFlow)
end
PB.default_values(::Type{CapitalFlowItem}) = (;inFlow = zero(Float64), time = "", timestamp = zero(Float64), mainInFlow = zero(Float64), superInFlow = zero(Float64), bigInFlow = zero(Float64), midInFlow = zero(Float64), smlInFlow = zero(Float64))
PB.field_numbers(::Type{CapitalFlowItem}) = (;inFlow = 1, time = 2, timestamp = 3, mainInFlow = 4, superInFlow = 5, bigInFlow = 6, midInFlow = 7, smlInFlow = 8)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:CapitalFlowItem})
    inFlow = zero(Float64)
    time = ""
    timestamp = zero(Float64)
    mainInFlow = zero(Float64)
    superInFlow = zero(Float64)
    bigInFlow = zero(Float64)
    midInFlow = zero(Float64)
    smlInFlow = zero(Float64)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            inFlow = PB.decode(d, Float64)
        elseif field_number == 2
            time = PB.decode(d, String)
        elseif field_number == 3
            timestamp = PB.decode(d, Float64)
        elseif field_number == 4
            mainInFlow = PB.decode(d, Float64)
        elseif field_number == 5
            superInFlow = PB.decode(d, Float64)
        elseif field_number == 6
            bigInFlow = PB.decode(d, Float64)
        elseif field_number == 7
            midInFlow = PB.decode(d, Float64)
        elseif field_number == 8
            smlInFlow = PB.decode(d, Float64)
        else
            PB.skip(d, wire_type)
        end
    end
    return CapitalFlowItem(; inFlow, time, timestamp, mainInFlow, superInFlow, bigInFlow, midInFlow, smlInFlow)
end

# 服务端到客户端响应消息
mutable struct S2C
    flowItemList::Vector{CapitalFlowItem}  # 资金流向
    lastValidTime::String                  # 数据最后有效时间字符串
    lastValidTimestamp::Float64            # 数据最后有效时间戳
    S2C(; 
    flowItemList = Vector{CapitalFlowItem}(), lastValidTime = "", lastValidTimestamp = 0.0
    ) = new(flowItemList, lastValidTime, lastValidTimestamp)
end
PB.default_values(::Type{S2C}) = (;flowItemList = Vector{CapitalFlowItem}(), lastValidTime = "", lastValidTimestamp = 0.0)
PB.field_numbers(::Type{S2C}) = (;flowItemList = 1, lastValidTime = 2, lastValidTimestamp = 3)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    flowItemList = Vector{CapitalFlowItem}()
    lastValidTime = ""
    lastValidTimestamp = 0.0
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            push!(flowItemList, PB.decode(d, Ref{CapitalFlowItem}))
        elseif field_number == 2
            lastValidTime = PB.decode(d, String)
        elseif field_number == 3
            lastValidTimestamp = PB.decode(d, Float64)
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(; flowItemList, lastValidTime, lastValidTimestamp)
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
    Response(; 
    retType::Integer = Common.RetType.Unknown, retMsg::AbstractString = "", errCode::Integer = 0, s2c = S2C()
    ) = new(retType, retMsg, errCode, s2c)
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
    return Response(; retType, retMsg, errCode, s2c)
end

export C2S, CapitalFlowItem, S2C, Request, Response

end
