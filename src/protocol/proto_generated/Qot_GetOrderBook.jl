module Qot_GetOrderBook

using ProtoBuf
import ProtoBuf as PB
import ..Common
import ..Qot_Common

mutable struct C2S
    security::Qot_Common.Security
    num::Int32
end
function C2S(; security = Qot_Common.Security(), num = Int32(0))
    return C2S(security, Int32(num))
end
PB.default_values(::Type{C2S}) = (;security = Qot_Common.Security(), num = Int32(0))
PB.field_numbers(::Type{C2S}) = (;security = 1, num = 2)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    PB.encode(e, 1, x.security)
    x.num != 0 && PB.encode(e, 2, x.num)
    return position(e.io) - initpos
end

mutable struct S2C
    security::Qot_Common.Security
    name::String
    orderBookAskList::Vector{Qot_Common.OrderBook}
    orderBookBidList::Vector{Qot_Common.OrderBook}
    svrRecvTimeBid::String
    svrRecvTimeBidTimestamp::Float64
    svrRecvTimeAsk::String
    svrRecvTimeAskTimestamp::Float64
end
function S2C(; security = Qot_Common.Security(), name = "", orderBookAskList = Vector{Qot_Common.OrderBook}(), orderBookBidList = Vector{Qot_Common.OrderBook}(), svrRecvTimeBid = "", svrRecvTimeBidTimestamp = 0.0, svrRecvTimeAsk = "", svrRecvTimeAskTimestamp = 0.0)
    return S2C(security, name, orderBookAskList, orderBookBidList, svrRecvTimeBid, svrRecvTimeBidTimestamp, svrRecvTimeAsk, svrRecvTimeAskTimestamp)
end
PB.default_values(::Type{S2C}) = (;security = Qot_Common.Security(), name = "", orderBookAskList = Vector{Qot_Common.OrderBook}(), orderBookBidList = Vector{Qot_Common.OrderBook}(), svrRecvTimeBid = "", svrRecvTimeBidTimestamp = 0.0, svrRecvTimeAsk = "", svrRecvTimeAskTimestamp = 0.0)
PB.field_numbers(::Type{S2C}) = (;security = 1, orderBookAskList = 2, orderBookBidList = 3, svrRecvTimeBid = 4, svrRecvTimeBidTimestamp = 5, svrRecvTimeAsk = 6, svrRecvTimeAskTimestamp = 7, name = 8)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    security = Qot_Common.Security()
    name = ""
    orderBookAskList = Vector{Qot_Common.OrderBook}()
    orderBookBidList = Vector{Qot_Common.OrderBook}()
    svrRecvTimeBid = ""
    svrRecvTimeBidTimestamp = 0.0
    svrRecvTimeAsk = ""
    svrRecvTimeAskTimestamp = 0.0
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            security = PB.decode(d, Ref{Qot_Common.Security})
        elseif field_number == 2
            push!(orderBookAskList, PB.decode(d, Ref{Qot_Common.OrderBook}))
        elseif field_number == 3
            push!(orderBookBidList, PB.decode(d, Ref{Qot_Common.OrderBook}))
        elseif field_number == 4
            svrRecvTimeBid = PB.decode(d, String)
        elseif field_number == 5
            svrRecvTimeBidTimestamp = PB.decode(d, Float64)
        elseif field_number == 6
            svrRecvTimeAsk = PB.decode(d, String)
        elseif field_number == 7
            svrRecvTimeAskTimestamp = PB.decode(d, Float64)
        elseif field_number == 8
            name = PB.decode(d, String)
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(security, name, orderBookAskList, orderBookBidList, svrRecvTimeBid, svrRecvTimeBidTimestamp, svrRecvTimeAsk, svrRecvTimeAskTimestamp)
end

mutable struct Request
    c2s::C2S
end
function Request(; c2s = C2S())
    return Request(c2s)
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
end
function Response(; retType = Int32(Common.RetType.Unknown), retMsg = "", errCode = Int32(0), s2c = S2C())
    return Response(retType, retMsg, errCode, s2c)
end
PB.default_values(::Type{Response}) = (;retType = Int32(Common.RetType.Unknown), retMsg = "", errCode = Int32(0), s2c = S2C())
PB.field_numbers(::Type{Response}) = (;retType = 1, retMsg = 2, errCode = 3, s2c = 4)
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
