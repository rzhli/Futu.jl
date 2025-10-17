module Trd_FlowSummary

import ProtoBuf as PB
using ProtoBuf.EnumX
import ..Trd_Common

@enumx TrdCashFlowDirection begin
    TrdCashFlowDirection_Unknown = 0
    TrdCashFlowDirection_In = 1
    TrdCashFlowDirection_Out = 2
end

mutable struct FlowSummaryInfo
    clearingDate::String
    settlementDate::String
    currency::Int32
    cashFlowType::String
    cashFlowDirection::Int32
    cashFlowAmount::Float64
    cashFlowRemark::String
    cashFlowID::UInt64
    FlowSummaryInfo(; clearingDate = "", settlementDate = "", currency = 0, cashFlowType = "", cashFlowDirection = 0, cashFlowAmount = 0.0, cashFlowRemark = "", cashFlowID = 0) = new(clearingDate, settlementDate, currency, cashFlowType, cashFlowDirection, cashFlowAmount, cashFlowRemark, cashFlowID)
end

mutable struct C2S
    header::Trd_Common.TrdHeader
    clearingDate::String
    cashFlowDirection::Int32
    C2S(; header = Trd_Common.TrdHeader(), clearingDate = "", cashFlowDirection = 0) = new(header, clearingDate, cashFlowDirection)
end

PB.default_values(::Type{C2S}) = (;header = Trd_Common.TrdHeader(), clearingDate = "", cashFlowDirection = Int32(0))
PB.field_numbers(::Type{C2S}) = (;header = 1, clearingDate = 2, cashFlowDirection = 3)

function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    PB.encode(e, 1, x.header)
    x.clearingDate != "" && PB.encode(e, 2, x.clearingDate)
    x.cashFlowDirection != Int32(0) && PB.encode(e, 3, x.cashFlowDirection)
    return position(e.io) - initpos
end

mutable struct S2C
    header::Trd_Common.TrdHeader
    flowSummaryInfoList::Vector{FlowSummaryInfo}
    S2C(; header = Trd_Common.TrdHeader(), flowSummaryInfoList = Vector{FlowSummaryInfo}()) = new(header, flowSummaryInfoList)
end

PB.default_values(::Type{S2C}) = (;header = Trd_Common.TrdHeader(), flowSummaryInfoList = Vector{FlowSummaryInfo}())
PB.field_numbers(::Type{S2C}) = (;header = 1, flowSummaryInfoList = 2)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    header = Trd_Common.TrdHeader()
    flowSummaryInfoList = Vector{FlowSummaryInfo}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            header = PB.decode(d, Ref{Trd_Common.TrdHeader})
        elseif field_number == 2
            push!(flowSummaryInfoList, PB.decode(d, Ref{FlowSummaryInfo}))
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(header = header, flowSummaryInfoList = flowSummaryInfoList)
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

export TrdCashFlowDirection, FlowSummaryInfo, C2S, S2C, Request, Response

end
