module Qot_GetOwnerPlate

import ProtoBuf as PB
import ..Common
import ..Qot_Common

mutable struct C2S
    securityList::Vector{Qot_Common.Security}
    C2S(; securityList = Vector{Qot_Common.Security}()) = new(securityList)
end
PB.default_values(::Type{C2S}) = (; securityList = Vector{Qot_Common.Security}())
PB.field_numbers(::Type{C2S}) = (; securityList = 1)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    for security in x.securityList
        PB.encode(e, 1, security)
    end
    return position(e.io) - initpos
end

mutable struct SecurityOwnerPlate
    security::Qot_Common.Security
    name::String
    plateInfoList::Vector{Qot_Common.PlateInfo}
    SecurityOwnerPlate(; security = Qot_Common.Security(), name = "", plateInfoList = Vector{Qot_Common.PlateInfo}()) = new(security, name, plateInfoList)
end
PB.default_values(::Type{SecurityOwnerPlate}) = (; security = Qot_Common.Security(), name = "", plateInfoList = Vector{Qot_Common.PlateInfo}())
PB.field_numbers(::Type{SecurityOwnerPlate}) = (; security = 1, plateInfoList = 2, name = 3)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:SecurityOwnerPlate})
    security = Qot_Common.Security()
    name = ""
    plateInfoList = Vector{Qot_Common.PlateInfo}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            security = PB.decode(d, Ref{Qot_Common.Security})
        elseif field_number == 2
            push!(plateInfoList, PB.decode(d, Ref{Qot_Common.PlateInfo}))
        elseif field_number == 3
            name = PB.decode(d, String)
        else
            PB.skip(d, wire_type)
        end
    end
    return SecurityOwnerPlate(; security, name, plateInfoList)
end

mutable struct S2C
    ownerPlateList::Vector{SecurityOwnerPlate}
    S2C(; ownerPlateList = Vector{SecurityOwnerPlate}()) = new(ownerPlateList)
end
PB.default_values(::Type{S2C}) = (; ownerPlateList = Vector{SecurityOwnerPlate}())
PB.field_numbers(::Type{S2C}) = (; ownerPlateList = 1)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    ownerPlateList = Vector{SecurityOwnerPlate}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            push!(ownerPlateList, PB.decode(d, Ref{SecurityOwnerPlate}))
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(; ownerPlateList)
end

mutable struct Request
    c2s::C2S
    Request(; c2s = C2S()) = new(c2s)
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
    return Response(; retType, retMsg, errCode, s2c)
end

export C2S, SecurityOwnerPlate, S2C, Request, Response

end
