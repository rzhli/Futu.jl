module Trd_GetMaxTrdQtys

import ProtoBuf as PB
using ProtoBuf.EnumX
import ..Trd_Common

mutable struct C2S
    header::Trd_Common.TrdHeader
    orderType::Int32
    code::String
    price::Float64
    orderID::UInt64
    adjustPrice::Bool
    adjustSideAndLimit::Float64
    secMarket::Int32
    orderIDEx::String
    session::Int32
    C2S(; header = Trd_Common.TrdHeader(), orderType = 0, code = "", price = 0.0, orderID = 0, adjustPrice = false, adjustSideAndLimit = 0.0, secMarket = 0, orderIDEx = "", session = 0) = new(header, orderType, code, price, orderID, adjustPrice, adjustSideAndLimit, secMarket, orderIDEx, session)
end

PB.default_values(::Type{C2S}) = (;header = Trd_Common.TrdHeader(), orderType = Int32(0), code = "", price = 0.0, orderID = UInt64(0), adjustPrice = false, adjustSideAndLimit = 0.0, secMarket = Int32(0), orderIDEx = "", session = Int32(0))
PB.field_numbers(::Type{C2S}) = (;header = 1, orderType = 2, code = 3, price = 4, orderID = 5, adjustPrice = 6, adjustSideAndLimit = 7, secMarket = 8, orderIDEx = 9, session = 10)

function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    PB.encode(e, 1, x.header)
    x.orderType != Int32(0) && PB.encode(e, 2, x.orderType)
    x.code != "" && PB.encode(e, 3, x.code)
    x.price != 0.0 && PB.encode(e, 4, x.price)
    x.orderID != UInt64(0) && PB.encode(e, 5, x.orderID)
    x.adjustPrice != false && PB.encode(e, 6, x.adjustPrice)
    x.adjustSideAndLimit != 0.0 && PB.encode(e, 7, x.adjustSideAndLimit)
    x.secMarket != Int32(0) && PB.encode(e, 8, x.secMarket)
    x.orderIDEx != "" && PB.encode(e, 9, x.orderIDEx)
    x.session != Int32(0) && PB.encode(e, 10, x.session)
    return position(e.io) - initpos
end

mutable struct S2C
    header::Trd_Common.TrdHeader
    maxTrdQtys::Trd_Common.MaxTrdQtys
    S2C(; header = Trd_Common.TrdHeader(), maxTrdQtys = Trd_Common.MaxTrdQtys()) = new(header, maxTrdQtys)
end

PB.default_values(::Type{S2C}) = (;header = Trd_Common.TrdHeader(), maxTrdQtys = Trd_Common.MaxTrdQtys())
PB.field_numbers(::Type{S2C}) = (;header = 1, maxTrdQtys = 2)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    header = Trd_Common.TrdHeader()
    maxTrdQtys = Trd_Common.MaxTrdQtys()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            header = PB.decode(d, Ref{Trd_Common.TrdHeader})
        elseif field_number == 2
            maxTrdQtys = PB.decode(d, Ref{Trd_Common.MaxTrdQtys})
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(header = header, maxTrdQtys = maxTrdQtys)
end

mutable struct Request
    c2s::C2S
    Request(; c2s = C2S()) = new(c2s)
end

PB.default_values(::Type{Request}) = (;c2s = C2S())
PB.field_numbers(::Type{Request}) = (;c2s = 1)

function PB.encode(e::PB.AbstractProtoEncoder, x::Request)
    initpos = position(e.io)
    PB.encode(e, 1, x.c2s)
    return position(e.io) - initpos
end

mutable struct Response
    retType::Int32
    retMsg::String
    errCode::Int32
    s2c::S2C
    Response(; retType = -400, retMsg = "", errCode = 0, s2c = S2C()) = new(retType, retMsg, errCode, s2c)
end

PB.default_values(::Type{Response}) = (;retType = Int32(-400), retMsg = "", errCode = Int32(0), s2c = S2C())
PB.field_numbers(::Type{Response}) = (;retType = 1, retMsg = 2, errCode = 3, s2c = 4)

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
    return Response(retType = retType, retMsg = retMsg, errCode = errCode, s2c = s2c)
end

export C2S, S2C, Request, Response

end
