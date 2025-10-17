module Qot_GetMarketState

import ProtoBuf as PB
import ..Common
import ..Qot_Common

mutable struct C2S
    securityList::Vector{Qot_Common.Security}  # 股票列表
    C2S(; securityList = Vector{Qot_Common.Security}()) = new(securityList)
end
PB.default_values(::Type{C2S}) = (; securityList = Vector{Qot_Common.Security}())
PB.field_numbers(::Type{C2S}) = (; securityList = 1)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    for security in x.securityList
        PB.encode(e, 1, security)
    end
    return position(e.io) - initpos
end

mutable struct MarketInfo
    security::Qot_Common.Security  # 股票代码
    name::String                   # 股票名称
    marketState::Int32             # Qot_Common.QotMarketState,市场状态
    MarketInfo(; security = Qot_Common.Security(), name = "", marketState = 0) = new(security, name, marketState)
end
PB.default_values(::Type{MarketInfo}) = (; security = Qot_Common.Security(), name = "", marketState = Int32(0))
PB.field_numbers(::Type{MarketInfo}) = (; security = 1, name = 2, marketState = 3)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{MarketInfo})
    security = Qot_Common.Security()
    name = ""
    marketState = Int32(0)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            security = PB.decode(d, Ref{Qot_Common.Security})
        elseif field_number == 2
            name = PB.decode(d, String)
        elseif field_number == 3
            marketState = PB.decode(d, Int32)
        else
            PB.skip(d, wire_type)
        end
    end
    return MarketInfo(; security = security, name = name, marketState = marketState)
end

mutable struct S2C
    marketInfoList::Vector{MarketInfo}  # 市场状态信息
    S2C(; marketInfoList = Vector{MarketInfo}()) = new(marketInfoList)
end
PB.default_values(::Type{S2C}) = (; marketInfoList = Vector{MarketInfo}())
PB.field_numbers(::Type{S2C}) = (; marketInfoList = 1)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{S2C})
    marketInfoList = Vector{MarketInfo}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            push!(marketInfoList, PB.decode(d, Ref{MarketInfo}))
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(; marketInfoList = marketInfoList)
end

mutable struct Request
    c2s::C2S
    Request(; c2s = C2S()) = new(c2s)
end
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
    Response(; retType = -400, retMsg = "", errCode = 0, s2c = S2C()) = new(retType, retMsg, errCode, s2c)
end
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
    return Response(; retType = retType, retMsg = retMsg, errCode = errCode, s2c = s2c)
end

export C2S, MarketInfo, S2C, Request, Response

end
