module Trd_ModifyOrder

import ProtoBuf as PB
using ProtoBuf.EnumX
import ..Common
import ..Trd_Common

mutable struct C2S
    packetID::Common.PacketID
    header::Trd_Common.TrdHeader
    orderID::UInt64
    modifyOrderOp::Int32
    forAll::Bool
    trdMarket::Int32
    qty::Float64
    price::Float64
    adjustPrice::Bool
    adjustSideAndLimit::Float64
    auxPrice::Float64
    trailType::Int32
    trailValue::Float64
    trailSpread::Float64
    orderIDEx::String
    C2S(; packetID = Common.PacketID(), header = Trd_Common.TrdHeader(), orderID = 0, modifyOrderOp = 0, forAll = false, trdMarket = 0, qty = 0.0, price = 0.0, adjustPrice = false, adjustSideAndLimit = 0.0, auxPrice = 0.0, trailType = 0, trailValue = 0.0, trailSpread = 0.0, orderIDEx = "") = new(packetID, header, orderID, modifyOrderOp, forAll, trdMarket, qty, price, adjustPrice, adjustSideAndLimit, auxPrice, trailType, trailValue, trailSpread, orderIDEx)
end

PB.default_values(::Type{C2S}) = (;packetID = Common.PacketID(), header = Trd_Common.TrdHeader(), orderID = UInt64(0), modifyOrderOp = Int32(0), forAll = false, trdMarket = Int32(0), qty = 0.0, price = 0.0, adjustPrice = false, adjustSideAndLimit = 0.0, auxPrice = 0.0, trailType = Int32(0), trailValue = 0.0, trailSpread = 0.0, orderIDEx = "")
PB.field_numbers(::Type{C2S}) = (;packetID = 1, header = 2, orderID = 3, modifyOrderOp = 4, forAll = 5, trdMarket = 6, qty = 8, price = 9, adjustPrice = 10, adjustSideAndLimit = 11, auxPrice = 12, trailType = 13, trailValue = 14, trailSpread = 15, orderIDEx = 16)

function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    PB.encode(e, 1, x.packetID)
    PB.encode(e, 2, x.header)
    PB.encode(e, 3, x.orderID)
    PB.encode(e, 4, x.modifyOrderOp)
    x.forAll != false && PB.encode(e, 5, x.forAll)
    x.trdMarket != Int32(0) && PB.encode(e, 6, x.trdMarket)

    # For NORMAL modify operations (modifyOrderOp == 1), always encode qty and price
    # The server requires these fields to be present even if they're 0.0
    if x.modifyOrderOp == Int32(1)  # ModifyOrderOp.Normal
        PB.encode(e, 8, x.qty)
        PB.encode(e, 9, x.price)
    else
        x.qty != 0.0 && PB.encode(e, 8, x.qty)
        x.price != 0.0 && PB.encode(e, 9, x.price)
    end

    x.adjustPrice != false && PB.encode(e, 10, x.adjustPrice)
    x.adjustSideAndLimit != 0.0 && PB.encode(e, 11, x.adjustSideAndLimit)
    x.auxPrice != 0.0 && PB.encode(e, 12, x.auxPrice)
    x.trailType != Int32(0) && PB.encode(e, 13, x.trailType)
    x.trailValue != 0.0 && PB.encode(e, 14, x.trailValue)
    x.trailSpread != 0.0 && PB.encode(e, 15, x.trailSpread)
    x.orderIDEx != "" && PB.encode(e, 16, x.orderIDEx)
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
