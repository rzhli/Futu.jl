module Qot_GetStaticInfo

import ProtoBuf as PB
import ..Common
import ..Qot_Common

mutable struct C2S
    market::Int32 #Qot_Common.QotMarket,股票市场
    secType::Int32 #Qot_Common.SecurityType,股票类型
    securityList::Vector{Qot_Common.Security} #股票，若该字段存在，忽略其他字段，只返回该字段股票的静态信息
end
C2S(; market = Int32(0), secType = Int32(0), securityList = Vector{Qot_Common.Security}()) = C2S(Int32(market), Int32(secType), securityList)

PB.default_values(::Type{C2S}) = (; market = Int32(0), secType = Int32(0), securityList = Vector{Qot_Common.Security}())
PB.field_numbers(::Type{C2S}) = (; market = 1, secType = 2, securityList = 3)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    x.market != 0 && PB.encode(e, 1, x.market)
    x.secType != 0 && PB.encode(e, 2, x.secType)
    for item in x.securityList
        PB.encode(e, 3, item)
    end
    return position(e.io) - initpos
end

mutable struct S2C
    staticInfoList::Vector{Qot_Common.SecurityStaticInfo} #静态信息
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

mutable struct Response
    retType::Int32    # RetType,返回结果
    retMsg::String
    errCode::Int32
    s2c::S2C
end
Response(; retType = Int32(Common.RetType.Unknown), retMsg = "", errCode = Int32(0), s2c = S2C()) = Response(retType, retMsg, errCode, s2c)

PB.default_values(::Type{Response}) = (; retType = Int32(Common.RetType.Unknown), retMsg = "", errCode = Int32(0), s2c = S2C())
PB.field_numbers(::Type{Response}) = (; retType = 1, retMsg = 2, errCode = 3, s2c = 4)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:Response})
    retType = Int32(Common.RetType.Unknown)
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
