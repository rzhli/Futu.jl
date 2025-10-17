module Qot_GetPlateSet

import ProtoBuf as PB
import ..Common
import ..Qot_Common

mutable struct C2S
    market::Int32
    plateSetType::Int32
end
C2S(; market = Int32(0), plateSetType = Int32(0)) = C2S(Int32(market), Int32(plateSetType))

PB.default_values(::Type{C2S}) = (; market = Int32(0), plateSetType = Int32(0))
PB.field_numbers(::Type{C2S}) = (; market = 1, plateSetType = 2)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    PB.encode(e, 1, x.market)
    PB.encode(e, 2, x.plateSetType)
    return position(e.io) - initpos
end

mutable struct S2C
    plateInfoList::Vector{Qot_Common.PlateInfo}
end
S2C(; plateInfoList = Vector{Qot_Common.PlateInfo}()) = S2C(plateInfoList)

PB.default_values(::Type{S2C}) = (; plateInfoList = Vector{Qot_Common.PlateInfo}())
PB.field_numbers(::Type{S2C}) = (; plateInfoList = 1)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    plateInfoList = Vector{Qot_Common.PlateInfo}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            push!(plateInfoList, PB.decode(d, Ref{Qot_Common.PlateInfo}))
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(plateInfoList)
end

mutable struct Request
    c2s::C2S
end
Request(; c2s = C2S()) = Request(c2s)

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
end
Response(; retType = Int32(Common.RetType.Unknown), retMsg = "", errCode = Int32(0), s2c = S2C()) = Response(retType, retMsg, errCode, s2c)

PB.default_values(::Type{Response}) = (; retType = Int32(Common.RetType.Unknown), retMsg = "", errCode = Int32(0), s2c = S2C())
PB.field_numbers(::Type{Response}) = (; retType = 1, retMsg = 2, errCode = 3, s2c = 4)
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
