module Qot_GetCodeChange

import ProtoBuf as PB
using ProtoBuf.EnumX
import ..Common
import ..Qot_Common

# 代码变化类型枚举
@enumx CodeChangeType begin
    CodeChangeType_Unkown = 0      # 未知
    CodeChangeType_GemToMain = 1   # 创业板转主板
    CodeChangeType_Unpaid = 2      # 买卖未缴款供股权
    CodeChangeType_ChangeLot = 3    # 更改买卖单位
    CodeChangeType_Split = 4       # 拆股
    CodeChangeType_Joint = 5       # 合股
    CodeChangeType_JointSplit = 6  # 股份先并后拆
    CodeChangeType_SplitJoint = 7  # 股份先拆后并
    CodeChangeType_Other = 8       # 其他
end

# 代码变化信息
mutable struct CodeChangeInfo
    type::Int32                          # 代码变化或者新增临时代码的事件类型
    security::Qot_Common.Security        # 主代码，在创业板转主板中表示主板
    relatedSecurity::Qot_Common.Security # 关联代码，在创业板转主板中表示创业板，在剩余事件中表示临时代码
    publicTime::String                   # 公布时间
    publicTimestamp::Float64             # 公布时间戳
    effectiveTime::String                # 生效时间
    effectiveTimestamp::Float64          # 生效时间戳
    endTime::String                      # 结束时间，在创业板转主板事件不存在该字段，在剩余事件表示临时代码交易结束时间
    endTimestamp::Float64                # 结束时间戳，在创业板转主板事件不存在该字段，在剩余事件表示临时代码交易结束时间
end
PB.default_values(::Type{CodeChangeInfo}) = (;type = 0, security = Qot_Common.Security(), relatedSecurity = Qot_Common.Security(), publicTime = "", publicTimestamp = 0.0, effectiveTime = "", effectiveTimestamp = 0.0, endTime = "", endTimestamp = 0.0)
PB.field_numbers(::Type{CodeChangeInfo}) = (;type = 1, security = 2, relatedSecurity = 3, publicTime = 4, publicTimestamp = 5, effectiveTime = 6, effectiveTimestamp = 7, endTime = 8, endTimestamp = 9)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:CodeChangeInfo})
    type = 0
    security = Qot_Common.Security()
    relatedSecurity = Qot_Common.Security()
    publicTime = ""
    publicTimestamp = 0.0
    effectiveTime = ""
    effectiveTimestamp = 0.0
    endTime = ""
    endTimestamp = 0.0
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            type = PB.decode(d, Int32)
        elseif field_number == 2
            security = PB.decode(d, Qot_Common.Security)
        elseif field_number == 3
            relatedSecurity = PB.decode(d, Qot_Common.Security)
        elseif field_number == 4
            publicTime = PB.decode(d, String)
        elseif field_number == 5
            publicTimestamp = PB.decode(d, Float64)
        elseif field_number == 6
            effectiveTime = PB.decode(d, String)
        elseif field_number == 7
            effectiveTimestamp = PB.decode(d, Float64)
        elseif field_number == 8
            endTime = PB.decode(d, String)
        elseif field_number == 9
            endTimestamp = PB.decode(d, Float64)
        else
            PB.skip(d, wire_type)
        end
    end
    return CodeChangeInfo(type, security, relatedSecurity, publicTime, publicTimestamp, effectiveTime, effectiveTimestamp, endTime, endTimestamp)
end

# 时间过滤类型枚举
@enumx TimeFilterType begin
    TimeFilterType_Unknow = 0      # 未知
    TimeFilterType_Public = 1      # 根据公布时间过滤
    TimeFilterType_Effective = 2   # 根据生效时间过滤
    TimeFilterType_End = 3         # 根据结束时间过滤
end

# 时间过滤器
mutable struct TimeFilter
    type::Int32       # 过滤类型
    beginTime::String # 开始时间点
    endTime::String   # 结束时间点
end
PB.default_values(::Type{TimeFilter}) = (;type = 0, beginTime = "", endTime = "")
PB.field_numbers(::Type{TimeFilter}) = (;type = 1, beginTime = 2, endTime = 3)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:TimeFilter})
    type = 0
    beginTime = ""
    endTime = ""
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            type = PB.decode(d, Int32)
        elseif field_number == 2
            beginTime = PB.decode(d, String)
        elseif field_number == 3
            endTime = PB.decode(d, String)
        else
            PB.skip(d, wire_type)
        end
    end
    return TimeFilter(type, beginTime, endTime)
end

# 客户端到服务端请求消息
mutable struct C2S
    placeHolder::Int32                       # 占位
    securityList::Vector{Qot_Common.Security} # 根据股票筛选
    timeFilterList::Vector{TimeFilter}       # 根据时间筛选
    typeList::Vector{Int32}                  # 根据类型筛选
end
PB.default_values(::Type{C2S}) = (;placeHolder = 0, securityList = Vector{Qot_Common.Security}(), timeFilterList = Vector{TimeFilter}(), typeList = Vector{Int32}())
PB.field_numbers(::Type{C2S}) = (;placeHolder = 1, securityList = 2, timeFilterList = 3, typeList = 4)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    x.placeHolder != 0 && PB.encode(e, 1, x.placeHolder)
    for item in x.securityList
        PB.encode(e, 2, item)
    end
    for item in x.timeFilterList
        PB.encode(e, 3, item)
    end
    for item in x.typeList
        PB.encode(e, 4, item)
    end
    return position(e.io) - initpos
end

# 服务端到客户端响应消息
mutable struct S2C
    codeChangeList::Vector{CodeChangeInfo}  # 股票代码更换信息，目前仅有港股数据
end
PB.default_values(::Type{S2C}) = (;codeChangeList = Vector{CodeChangeInfo}())
PB.field_numbers(::Type{S2C}) = (;codeChangeList = 1)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    codeChangeList = Vector{CodeChangeInfo}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            push!(codeChangeList, PB.decode(d, CodeChangeInfo))
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(codeChangeList)
end

# 请求消息
mutable struct Request
    c2s::C2S  # 客户端到服务端请求
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

export CodeChangeType, CodeChangeInfo, TimeFilterType, TimeFilter, C2S, S2C, Request, Response

end
