module Trd_GetHistoryOrderList

import ProtoBuf as PB
using ProtoBuf.EnumX
import ..Trd_Common

mutable struct C2S
    header::Trd_Common.TrdHeader
    filterConditions::Trd_Common.TrdFilterConditions
    filterStatusList::Vector{Int32}
    C2S(; header = Trd_Common.TrdHeader(), filterConditions = Trd_Common.TrdFilterConditions(), filterStatusList = Vector{Int32}()) = new(header, filterConditions, filterStatusList)
end

PB.default_values(::Type{C2S}) = (;header = Trd_Common.TrdHeader(), filterConditions = Trd_Common.TrdFilterConditions(), filterStatusList = Vector{Int32}())
PB.field_numbers(::Type{C2S}) = (;header = 1, filterConditions = 2, filterStatusList = 3)

function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    PB.encode(e, 1, x.header)
    PB.encode(e, 2, x.filterConditions)
    foreach(item -> PB.encode(e, 3, item), x.filterStatusList)
    return position(e.io) - initpos
end

mutable struct S2C
    header::Trd_Common.TrdHeader
    orderList::Vector{Trd_Common.Order}
    S2C(; header = Trd_Common.TrdHeader(), orderList = Vector{Trd_Common.Order}()) = new(header, orderList)
end

PB.default_values(::Type{S2C}) = (;header = Trd_Common.TrdHeader(), orderList = Vector{Trd_Common.Order}())
PB.field_numbers(::Type{S2C}) = (;header = 1, orderList = 2)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    header = Trd_Common.TrdHeader()
    orderList = Vector{Trd_Common.Order}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            header = PB.decode(d, Ref{Trd_Common.TrdHeader})
        elseif field_number == 2
            push!(orderList, PB.decode(d, Ref{Trd_Common.Order}))
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(header = header, orderList = orderList)
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
