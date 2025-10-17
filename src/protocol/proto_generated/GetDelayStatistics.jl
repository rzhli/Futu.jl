module GetDelayStatistics

using ProtoBuf
import ProtoBuf as PB
using ProtoBuf.EnumX
using ..Common

@enumx DelayStatisticsType begin
    Unkonw = 0
    QotPush = 1
    ReqReply = 2
    PlaceOrder = 3
end

@enumx QotPushStage begin
    Unkonw = 0
    SR2SS = 1
    SS2CR = 2
    CR2CS = 3
    SS2CS = 4
    SR2CS = 5
end

@enumx QotPushType begin
    Unkonw = 0
    Price = 1
    Ticker = 2
    OrderBook = 3
    Broker = 4
end

function format_qot_push_type(value::Int32)
    try
        enum_value = QotPushType.T(value)
        label = string(Symbol(enum_value))
        return replace(label, "_" => " ")
    catch
        return string(value)
    end
end

mutable struct C2S
    typeList::Vector{Int32}
    qotPushStage::Int32
    segmentList::Vector{Int32}
end
PB.default_values(::Type{C2S}) = (;typeList = Vector{Int32}(), qotPushStage = zero(Int32), segmentList = Vector{Int32}())
PB.field_numbers(::Type{C2S}) = (;typeList = 1, qotPushStage = 2, segmentList = 3)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    !isempty(x.typeList) && PB.encode(e, 1, x.typeList)
    x.qotPushStage != zero(Int32) && PB.encode(e, 2, x.qotPushStage)
    !isempty(x.segmentList) && PB.encode(e, 3, x.segmentList)
    return position(e.io) - initpos
end

mutable struct DelayStatisticsItem
    begin_::Int32
    end_::Int32
    count::Int32
    proportion::Float32
    cumulativeRatio::Float32
end
PB.default_values(::Type{DelayStatisticsItem}) = (;begin_ = zero(Int32), end_ = zero(Int32), count = zero(Int32), proportion = zero(Float32), cumulativeRatio = zero(Float32))
PB.field_numbers(::Type{DelayStatisticsItem}) = (;begin_ = 1, end_ = 2, count = 3, proportion = 4, cumulativeRatio = 5)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:DelayStatisticsItem})
    begin_ = zero(Int32)
    end_ = zero(Int32)
    count = zero(Int32)
    proportion = zero(Float32)
    cumulativeRatio = zero(Float32)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            begin_ = PB.decode(d, Int32)
        elseif field_number == 2
            end_ = PB.decode(d, Int32)
        elseif field_number == 3
            count = PB.decode(d, Int32)
        elseif field_number == 4
            proportion = PB.decode(d, Float32)
        elseif field_number == 5
            cumulativeRatio = PB.decode(d, Float32)
        else
            PB.skip(d, wire_type)
        end
    end
    return DelayStatisticsItem(begin_, end_, count, proportion, cumulativeRatio)
end

mutable struct DelayStatistics
    qotPushType::Int32
    itemList::Vector{DelayStatisticsItem}
    delayAvg::Float32
    count::Int32
end
PB.default_values(::Type{DelayStatistics}) = (;qotPushType = zero(Int32), itemList = Vector{DelayStatisticsItem}(), delayAvg = zero(Float32), count = zero(Int32))
PB.field_numbers(::Type{DelayStatistics}) = (;qotPushType = 1, itemList = 2, delayAvg = 3, count = 4)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:DelayStatistics})
    qotPushType = zero(Int32)
    itemList = Vector{DelayStatisticsItem}()
    delayAvg = zero(Float32)
    count = zero(Int32)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            qotPushType = PB.decode(d, Int32)
        elseif field_number == 2
            PB.decode!(d, itemList)
        elseif field_number == 3
            delayAvg = PB.decode(d, Float32)
        elseif field_number == 4
            count = PB.decode(d, Int32)
        else
            PB.skip(d, wire_type)
        end
    end
    return DelayStatistics(qotPushType, itemList, delayAvg, count)
end

mutable struct ReqReplyStatisticsItem
    protoID::Int32
    count::Int32
    totalCostAvg::Float32
    openDCostAvg::Float32
    netDelayAvg::Float32
    isLocalReply::Bool
end
PB.default_values(::Type{ReqReplyStatisticsItem}) = (;protoID = zero(Int32), count = zero(Int32), totalCostAvg = zero(Float32), openDCostAvg = zero(Float32), netDelayAvg = zero(Float32), isLocalReply = false)
PB.field_numbers(::Type{ReqReplyStatisticsItem}) = (;protoID = 1, count = 2, totalCostAvg = 3, openDCostAvg = 4, netDelayAvg = 5, isLocalReply = 6)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:ReqReplyStatisticsItem})
    protoID = zero(Int32)
    count = zero(Int32)
    totalCostAvg = zero(Float32)
    openDCostAvg = zero(Float32)
    netDelayAvg = zero(Float32)
    isLocalReply = false
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            protoID = PB.decode(d, Int32)
        elseif field_number == 2
            count = PB.decode(d, Int32)
        elseif field_number == 3
            totalCostAvg = PB.decode(d, Float32)
        elseif field_number == 4
            openDCostAvg = PB.decode(d, Float32)
        elseif field_number == 5
            netDelayAvg = PB.decode(d, Float32)
        elseif field_number == 6
            isLocalReply = PB.decode(d, Bool)
        else
            PB.skip(d, wire_type)
        end
    end
    return ReqReplyStatisticsItem(protoID, count, totalCostAvg, openDCostAvg, netDelayAvg, isLocalReply)
end

mutable struct PlaceOrderStatisticsItem
    orderID::String
    totalCost::Float32
    openDCost::Float32
    netDelay::Float32
    updateCost::Float32
end
PB.default_values(::Type{PlaceOrderStatisticsItem}) = (;orderID = "", totalCost = zero(Float32), openDCost = zero(Float32), netDelay = zero(Float32), updateCost = zero(Float32))
PB.field_numbers(::Type{PlaceOrderStatisticsItem}) = (;orderID = 1, totalCost = 2, openDCost = 3, netDelay = 4, updateCost = 5)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:PlaceOrderStatisticsItem})
    orderID = ""
    totalCost = zero(Float32)
    openDCost = zero(Float32)
    netDelay = zero(Float32)
    updateCost = zero(Float32)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            orderID = PB.decode(d, String)
        elseif field_number == 2
            totalCost = PB.decode(d, Float32)
        elseif field_number == 3
            openDCost = PB.decode(d, Float32)
        elseif field_number == 4
            netDelay = PB.decode(d, Float32)
        elseif field_number == 5
            updateCost = PB.decode(d, Float32)
        else
            PB.skip(d, wire_type)
        end
    end
    return PlaceOrderStatisticsItem(orderID, totalCost, openDCost, netDelay, updateCost)
end

mutable struct S2C
    qotPushStatisticsList::Vector{DelayStatistics}
    reqReplyStatisticsList::Vector{ReqReplyStatisticsItem}
    placeOrderStatisticsList::Vector{PlaceOrderStatisticsItem}
end
S2C() = S2C(
    Vector{DelayStatistics}(),
    Vector{ReqReplyStatisticsItem}(),
    Vector{PlaceOrderStatisticsItem}()
)
PB.default_values(::Type{S2C}) = (;qotPushStatisticsList = Vector{DelayStatistics}(), reqReplyStatisticsList = Vector{ReqReplyStatisticsItem}(), placeOrderStatisticsList = Vector{PlaceOrderStatisticsItem}())
PB.field_numbers(::Type{S2C}) = (;qotPushStatisticsList = 1, reqReplyStatisticsList = 2, placeOrderStatisticsList = 3)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    qotPushStatisticsList = Vector{DelayStatistics}()
    reqReplyStatisticsList = Vector{ReqReplyStatisticsItem}()
    placeOrderStatisticsList = Vector{PlaceOrderStatisticsItem}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            PB.decode!(d, qotPushStatisticsList)
        elseif field_number == 2
            PB.decode!(d, reqReplyStatisticsList)
        elseif field_number == 3
            PB.decode!(d, placeOrderStatisticsList)
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(qotPushStatisticsList, reqReplyStatisticsList, placeOrderStatisticsList)
end

mutable struct Request
    c2s::C2S
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

struct DelayStatisticsSegmentSummary
    begin_ms::Int32
    end_ms::Int32
    count::Int32
    proportion::Float32
    cumulative_ratio::Float32
end

struct DelayStatisticsSummary
    push_type::Int32
    push_type_name::String
    delay_avg::Float32
    count::Int32
    segments::Vector{DelayStatisticsSegmentSummary}
end

struct ReqReplyStatisticsSummary
    proto_id::Int32
    count::Int32
    total_cost_avg::Float32
    open_d_cost_avg::Float32
    net_delay_avg::Float32
    is_local_reply::Bool
end

struct PlaceOrderStatisticsSummary
    order_id::String
    total_cost::Float32
    open_d_cost::Float32
    net_delay::Float32
    update_cost::Float32
end

struct DelayStatisticsInfo
    success::Bool
    ret_type::Int32
    ret_msg::String
    err_code::Int32
    qot_push_statistics::Vector{DelayStatisticsSummary}
    req_reply_statistics::Vector{ReqReplyStatisticsSummary}
    place_order_statistics::Vector{PlaceOrderStatisticsSummary}
end

function build_delay_statistics_info(resp::Response)
    success = resp.retType == Int32(Common.RetType.Succeed)

    qot_push_stats = DelayStatisticsSummary[]
    req_reply_stats = ReqReplyStatisticsSummary[]
    place_order_stats = PlaceOrderStatisticsSummary[]

    if success
        qot_push_stats = [DelayStatisticsSummary(
            item.qotPushType,
            format_qot_push_type(item.qotPushType),
            item.delayAvg,
            item.count,
            [DelayStatisticsSegmentSummary(seg.begin_, seg.end_, seg.count, seg.proportion, seg.cumulativeRatio) for seg in item.itemList]
        ) for item in resp.s2c.qotPushStatisticsList]

        req_reply_stats = [ReqReplyStatisticsSummary(
            item.protoID,
            item.count,
            item.totalCostAvg,
            item.openDCostAvg,
            item.netDelayAvg,
            item.isLocalReply
        ) for item in resp.s2c.reqReplyStatisticsList]

        place_order_stats = [PlaceOrderStatisticsSummary(
            item.orderID,
            item.totalCost,
            item.openDCost,
            item.netDelay,
            item.updateCost
        ) for item in resp.s2c.placeOrderStatisticsList]
    end

    return DelayStatisticsInfo(
        success,
        resp.retType,
        resp.retMsg,
        resp.errCode,
        qot_push_stats,
        req_reply_stats,
        place_order_stats
    )
end

export DelayStatisticsType, QotPushStage, QotPushType, format_qot_push_type,
       DelayStatisticsSegmentSummary, DelayStatisticsSummary, ReqReplyStatisticsSummary,
       PlaceOrderStatisticsSummary, DelayStatisticsInfo, build_delay_statistics_info,
       C2S, DelayStatisticsItem, DelayStatistics, ReqReplyStatisticsItem,
       PlaceOrderStatisticsItem, S2C, Request, Response

end
