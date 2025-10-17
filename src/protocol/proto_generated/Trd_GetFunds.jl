module Trd_GetFunds

import ProtoBuf as PB
using ProtoBuf.EnumX
import ..Common
import ..Trd_Common

mutable struct C2S
    header::Trd_Common.TrdHeader
    refreshCache::Bool
    currency::Int32
    C2S(; header = Trd_Common.TrdHeader(), refreshCache = false, currency = 0) = new(header, refreshCache, currency)
end

PB.default_values(::Type{C2S}) = (;header = Trd_Common.TrdHeader(), refreshCache = false, currency = Int32(0))
PB.field_numbers(::Type{C2S}) = (;header = 1, refreshCache = 2, currency = 3)

function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    PB.encode(e, 1, x.header)
    x.refreshCache != false && PB.encode(e, 2, x.refreshCache)
    x.currency != Int32(0) && PB.encode(e, 3, x.currency)
    return position(e.io) - initpos
end

mutable struct S2C
    header::Trd_Common.TrdHeader
    funds::Trd_Common.Funds
    S2C(; header = Trd_Common.TrdHeader(), funds = Trd_Common.Funds()) = new(header, funds)
end

PB.default_values(::Type{S2C}) = (;header = Trd_Common.TrdHeader(), funds = Trd_Common.Funds())
PB.field_numbers(::Type{S2C}) = (;header = 1, funds = 2)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    header = Trd_Common.TrdHeader()
    funds = Trd_Common.Funds()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            header = PB.decode(d, Ref{Trd_Common.TrdHeader})
        elseif field_number == 2
            funds = PB.decode(d, Ref{Trd_Common.Funds})
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(header = header, funds = funds)
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
