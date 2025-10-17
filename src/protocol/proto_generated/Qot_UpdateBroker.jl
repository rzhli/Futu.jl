module Qot_UpdateBroker

import ProtoBuf as PB
import ..Common
import ..Qot_Common

mutable struct S2C
    security::Qot_Common.Security
    name::String
    brokerAskList::Vector{Qot_Common.Broker}
    brokerBidList::Vector{Qot_Common.Broker}
    S2C(; security = Qot_Common.Security(), name = "", brokerAskList = Vector{Qot_Common.Broker}(), brokerBidList = Vector{Qot_Common.Broker}()) = new(security, name, brokerAskList, brokerBidList)
end

PB.default_values(::Type{S2C}) = (; security = Qot_Common.Security(), name = "", brokerAskList = Vector{Qot_Common.Broker}(), brokerBidList = Vector{Qot_Common.Broker}())
PB.field_numbers(::Type{S2C}) = (; security = 1, brokerAskList = 2, brokerBidList = 3, name = 4)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    security = Qot_Common.Security()
    name = ""
    brokerAskList = Vector{Qot_Common.Broker}()
    brokerBidList = Vector{Qot_Common.Broker}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            security = PB.decode(d, Ref{Qot_Common.Security})
        elseif field_number == 2
            push!(brokerAskList, PB.decode(d, Ref{Qot_Common.Broker}))
        elseif field_number == 3
            push!(brokerBidList, PB.decode(d, Ref{Qot_Common.Broker}))
        elseif field_number == 4
            name = PB.decode(d, String)
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(; security = security, name = name, brokerAskList = brokerAskList, brokerBidList = brokerBidList)
end

mutable struct Response
    retType::Int32
    retMsg::String
    errCode::Int32
    s2c::S2C
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
    return Response(; retType = retType, retMsg = retMsg, errCode = errCode, s2c = s2c)
end

export S2C, Response

end
