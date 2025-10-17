module Trd_GetAccList

import ProtoBuf as PB
using ProtoBuf.EnumX
import ..Common
import ..Trd_Common

mutable struct C2S
    userID::UInt64
    trdCategory::Int32
    needGeneralSecAccount::Bool
    C2S(; userID::UInt64 = UInt64(0), trdCategory::Int32 = Int32(0), needGeneralSecAccount::Bool = false) = new(userID, trdCategory, needGeneralSecAccount)
end
PB.default_values(::Type{C2S}) = (; userID = UInt64(0), trdCategory = Int32(0), needGeneralSecAccount = false)
PB.field_numbers(::Type{C2S}) = (; userID = 1, trdCategory = 2, needGeneralSecAccount = 3)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    PB.encode(e, 1, x.userID)  # Always encode userID
    PB.encode(e, 2, x.trdCategory)  # Always encode trdCategory
    x.needGeneralSecAccount != false && PB.encode(e, 3, x.needGeneralSecAccount)
    return position(e.io) - initpos
end

mutable struct S2C
    accList::Vector{Trd_Common.TrdAcc}
    S2C(; accList::Vector{Trd_Common.TrdAcc} = Vector{Trd_Common.TrdAcc}()) = new(accList)
end
PB.default_values(::Type{S2C}) = (; accList = Vector{Trd_Common.TrdAcc}())
PB.field_numbers(::Type{S2C}) = (; accList = 1)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    accList = Vector{Trd_Common.TrdAcc}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            push!(accList, PB.decode(d, Ref{Trd_Common.TrdAcc}))
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(; accList = accList)
end

mutable struct Request
    c2s::C2S
    Request(; c2s::C2S = C2S()) = new(c2s)
end
PB.default_values(::Type{Request}) = (; c2s = C2S())
PB.field_numbers(::Type{Request}) = (; c2s = 1)
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
    Response(; retType::Int32 = Int32(-400), retMsg::String = "", errCode::Int32 = Int32(0), s2c::S2C = S2C()) = new(retType, retMsg, errCode, s2c)
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

export C2S, S2C, Request, Response

end
