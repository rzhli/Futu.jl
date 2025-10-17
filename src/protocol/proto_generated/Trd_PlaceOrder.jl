module Trd_PlaceOrder

import ProtoBuf as PB
using ProtoBuf.EnumX
import ..Common
import ..Trd_Common

mutable struct C2S
    packetID::Common.PacketID
    header::Trd_Common.TrdHeader
    trdSide::Int32
    orderType::Int32
    code::String
    qty::Float64
    price::Float64
    adjustPrice::Bool
    adjustSideAndLimit::Float64
    secMarket::Int32
    remark::String
    timeInForce::Int32
    fillOutsideRTH::Bool
    auxPrice::Float64
    trailType::Int32
    trailValue::Float64
    trailSpread::Float64
    session::Int32
    C2S(; packetID = Common.PacketID(), header = Trd_Common.TrdHeader(), trdSide = 0, orderType = 0, code = "", qty = 0.0, price = 0.0, adjustPrice = false, adjustSideAndLimit = 0.0, secMarket = 0, remark = "", timeInForce = 0, fillOutsideRTH = false, auxPrice = 0.0, trailType = 0, trailValue = 0.0, trailSpread = 0.0, session = 0) = new(packetID, header, trdSide, orderType, code, qty, price, adjustPrice, adjustSideAndLimit, secMarket, remark, timeInForce, fillOutsideRTH, auxPrice, trailType, trailValue, trailSpread, session)
end

PB.default_values(::Type{C2S}) = (;packetID = Common.PacketID(), header = Trd_Common.TrdHeader(), trdSide = Int32(0), orderType = Int32(0), code = "", qty = 0.0, price = 0.0, adjustPrice = false, adjustSideAndLimit = 0.0, secMarket = Int32(0), remark = "", timeInForce = Int32(0), fillOutsideRTH = false, auxPrice = 0.0, trailType = Int32(0), trailValue = 0.0, trailSpread = 0.0, session = Int32(0))
PB.field_numbers(::Type{C2S}) = (;packetID = 1, header = 2, trdSide = 3, orderType = 4, code = 5, qty = 6, price = 7, adjustPrice = 8, adjustSideAndLimit = 9, secMarket = 10, remark = 11, timeInForce = 12, fillOutsideRTH = 13, auxPrice = 14, trailType = 15, trailValue = 16, trailSpread = 17, session = 18)

function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    PB.encode(e, 1, x.packetID)
    PB.encode(e, 2, x.header)
    x.trdSide != Int32(0) && PB.encode(e, 3, x.trdSide)
    x.orderType != Int32(0) && PB.encode(e, 4, x.orderType)
    x.code != "" && PB.encode(e, 5, x.code)
    x.qty != 0.0 && PB.encode(e, 6, x.qty)
    x.price != 0.0 && PB.encode(e, 7, x.price)
    x.adjustPrice != false && PB.encode(e, 8, x.adjustPrice)
    x.adjustSideAndLimit != 0.0 && PB.encode(e, 9, x.adjustSideAndLimit)
    x.secMarket != Int32(0) && PB.encode(e, 10, x.secMarket)
    x.remark != "" && PB.encode(e, 11, x.remark)
    x.timeInForce != Int32(0) && PB.encode(e, 12, x.timeInForce)
    x.fillOutsideRTH != false && PB.encode(e, 13, x.fillOutsideRTH)
    x.auxPrice != 0.0 && PB.encode(e, 14, x.auxPrice)
    x.trailType != Int32(0) && PB.encode(e, 15, x.trailType)
    x.trailValue != 0.0 && PB.encode(e, 16, x.trailValue)
    x.trailSpread != 0.0 && PB.encode(e, 17, x.trailSpread)
    x.session != Int32(0) && PB.encode(e, 18, x.session)
    return position(e.io) - initpos
end

mutable struct S2C
    header::Trd_Common.TrdHeader
    orderID::UInt64
    orderIDEx::String
    S2C(; header = Trd_Common.TrdHeader(), orderID = 0, orderIDEx = "") = new(header, orderID, orderIDEx)
end

PB.default_values(::Type{S2C}) = (;header = Trd_Common.TrdHeader(), orderID = UInt64(0), orderIDEx = "")
PB.field_numbers(::Type{S2C}) = (;header = 1, orderID = 2, orderIDEx = 3)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    header = Trd_Common.TrdHeader()
    orderID = UInt64(0)
    orderIDEx = ""
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            header = PB.decode(d, Ref{Trd_Common.TrdHeader})
        elseif field_number == 2
            orderID = PB.decode(d, UInt64)
        elseif field_number == 3
            orderIDEx = PB.decode(d, String)
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(header = header, orderID = orderID, orderIDEx = orderIDEx)
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
