module Qot_GetPlateSecurity

import ProtoBuf as PB
import ..Common
import ..Qot_Common

mutable struct C2S
    plate::Qot_Common.Security
    sortField::Int32
    ascend::Bool
end
C2S(; plate = Qot_Common.Security(), sortField = Int32(0), ascend = false) = C2S(plate, Int32(sortField), ascend)

PB.default_values(::Type{C2S}) = (;plate = Qot_Common.Security(), sortField = Int32(0), ascend = false)
PB.field_numbers(::Type{C2S}) = (;plate = 1, sortField = 2, ascend = 3)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    PB.encode(e, 1, x.plate)
    x.sortField != 0 && PB.encode(e, 2, x.sortField)
    x.ascend != false && PB.encode(e, 3, x.ascend)
    return position(e.io) - initpos
end

mutable struct S2C
    staticInfoList::Vector{Qot_Common.SecurityStaticInfo}
end
S2C(; staticInfoList = Vector{Qot_Common.SecurityStaticInfo}()) = S2C(staticInfoList)

PB.default_values(::Type{S2C}) = (;staticInfoList = Vector{Qot_Common.SecurityStaticInfo}())
PB.field_numbers(::Type{S2C}) = (;staticInfoList = 1)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    staticInfoList = Vector{Qot_Common.SecurityStaticInfo}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            push!(staticInfoList, PB.decode(d, Ref{Qot_Common.SecurityStaticInfo}))
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(staticInfoList)
end

mutable struct Request
    c2s::C2S
end
Request(; c2s = C2S()) = Request(c2s)
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
Response(; retType = Int32(Common.RetType.Unknown), retMsg = "", errCode = Int32(0), s2c = S2C()) = Response(retType, retMsg, errCode, s2c)
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
