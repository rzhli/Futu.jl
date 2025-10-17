module Qot_UpdateOrderBook

import ProtoBuf as PB
import ..Common
import ..Qot_Common

mutable struct S2C
    security::Qot_Common.Security #股票
    name::String #股票名称
    orderBookAskList::Vector{Qot_Common.OrderBook} #卖盘
    orderBookBidList::Vector{Qot_Common.OrderBook} #买盘
    svrRecvTimeBid::String # 富途服务器从交易所收到数据的时间(for bid)部分数据的接收时间为零，例如服务器重启或第一次推送的缓存数据。该字段暂时只支持港股。
    svrRecvTimeBidTimestamp::Float64 # 富途服务器从交易所收到数据的时间戳(for bid)
    svrRecvTimeAsk::String # 富途服务器从交易所收到数据的时间(for ask)
    svrRecvTimeAskTimestamp::Float64 # 富途服务器从交易所收到数据的时间戳(for ask)
    S2C(; security = Qot_Common.Security(), name = "", orderBookAskList = Vector{Qot_Common.OrderBook}(), orderBookBidList = Vector{Qot_Common.OrderBook}(), svrRecvTimeBid = "", svrRecvTimeBidTimestamp = 0.0, svrRecvTimeAsk = "", svrRecvTimeAskTimestamp = 0.0) = new(security, name, orderBookAskList, orderBookBidList, svrRecvTimeBid, svrRecvTimeBidTimestamp, svrRecvTimeAsk, svrRecvTimeAskTimestamp)
end

PB.default_values(::Type{S2C}) = (; security = Qot_Common.Security(), name = "", orderBookAskList = Vector{Qot_Common.OrderBook}(), orderBookBidList = Vector{Qot_Common.OrderBook}(), svrRecvTimeBid = "", svrRecvTimeBidTimestamp = 0.0, svrRecvTimeAsk = "", svrRecvTimeAskTimestamp = 0.0)
PB.field_numbers(::Type{S2C}) = (; security = 1, orderBookAskList = 2, orderBookBidList = 3, svrRecvTimeBid = 4, svrRecvTimeBidTimestamp = 5, svrRecvTimeAsk = 6, svrRecvTimeAskTimestamp = 7, name = 8)
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
    return S2C(; security = security, name = name, orderBookAskList = orderBookAskList, orderBookBidList = orderBookBidList, svrRecvTimeBid = svrRecvTimeBid, svrRecvTimeBidTimestamp = svrRecvTimeBidTimestamp, svrRecvTimeAsk = svrRecvTimeAsk, svrRecvTimeAskTimestamp = svrRecvTimeAskTimestamp)
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
    return Response(; retType = retType, retMsg = retMsg, errCode = errCode, s2c = s2c)
end

export S2C, Response

end
