module Qot_RequestHistoryKLQuota

import ProtoBuf as PB
import ..Common
import ..Qot_Common

# 拉取过的历史纪录明细项
mutable struct DetailItem
    security::Qot_Common.Security  # 拉取的股票
    name::String                   # 股票名称
    requestTime::String            # 拉取的时间字符串
    requestTimeStamp::Int64        # 拉取的时间戳
    DetailItem(; security = Qot_Common.Security(), name = "", requestTime = "", requestTimeStamp = Int64(0)) = new(security, name, requestTime, requestTimeStamp)
end
PB.default_values(::Type{DetailItem}) = (; security = Qot_Common.Security(), name = "", requestTime = "", requestTimeStamp = Int64(0))
PB.field_numbers(::Type{DetailItem}) = (; security = 1, name = 2, requestTime = 3, requestTimeStamp = 4)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:DetailItem})
    security = Qot_Common.Security()
    name = ""
    requestTime = ""
    requestTimeStamp = Int64(0)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            security = PB.decode(d, Ref{Qot_Common.Security})
        elseif field_number == 2
            name = PB.decode(d, String)
        elseif field_number == 3
            requestTime = PB.decode(d, String)
        elseif field_number == 4
            requestTimeStamp = PB.decode(d, Int64)
        else
            PB.skip(d, wire_type)
        end
    end
    return DetailItem(; security, name, requestTime, requestTimeStamp)
end

# 客户端到服务端请求消息
mutable struct C2S
    bGetDetail::Bool  # 是否返回详细拉取过的历史纪录
    C2S(; bGetDetail = false) = new(bGetDetail)
end
PB.default_values(::Type{C2S}) = (; bGetDetail = false)
PB.field_numbers(::Type{C2S}) = (; bGetDetail = 1)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    x.bGetDetail && PB.encode(e, 1, x.bGetDetail)
    return position(e.io) - initpos
end

# 服务端到客户端响应消息
mutable struct S2C
    usedQuota::Int32              # 已使用过的额度，即当前周期内已经下载过多少只股票
    remainQuota::Int32            # 剩余额度
    detailList::Vector{DetailItem} # 每只拉取过的股票的下载时间
    S2C(; usedQuota = Int32(0), remainQuota = Int32(0), detailList = Vector{DetailItem}()) = new(usedQuota, remainQuota, detailList)
end
PB.default_values(::Type{S2C}) = (; usedQuota = Int32(0), remainQuota = Int32(0), detailList = Vector{DetailItem}())
PB.field_numbers(::Type{S2C}) = (; usedQuota = 1, remainQuota = 2, detailList = 3)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    usedQuota = Int32(0)
    remainQuota = Int32(0)
    detailList = Vector{DetailItem}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            usedQuota = PB.decode(d, Int32)
        elseif field_number == 2
            remainQuota = PB.decode(d, Int32)
        elseif field_number == 3
            push!(detailList, PB.decode(d, Ref{DetailItem}))
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(; usedQuota, remainQuota, detailList)
end

# 请求消息
mutable struct Request
    c2s::C2S  # 客户端到服务端请求
    Request(; c2s = C2S(bGetDetail = false)) = new(c2s)
end
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
    Response(; retType = Int32(-400), retMsg = "", errCode = Int32(0), s2c = S2C()) = new(retType, retMsg, errCode, s2c)
end
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
    return Response(; retType, retMsg, errCode, s2c)
end

export DetailItem, C2S, S2C, Request, Response

end
