module Verification

using ProtoBuf
import ProtoBuf as PB
using ProtoBuf.EnumX
using ..Common

@enumx VerificationType begin
    Unknow = 0
    Picture = 1
    Phone = 2
end

@enumx VerificationOp begin
    Unknow = 0
    Request = 1
    InputAndLogin = 2
end

mutable struct C2S
    type::Int32
    op::Int32
    code::String
end
PB.default_values(::Type{C2S}) = (;type = zero(Int32), op = zero(Int32), code = "")
PB.field_numbers(::Type{C2S}) = (;type = 1, op = 2, code = 3)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    x.type != zero(Int32) && PB.encode(e, 1, x.type)
    x.op != zero(Int32) && PB.encode(e, 2, x.op)
    x.code != "" && PB.encode(e, 3, x.code)
    return position(e.io) - initpos
end

mutable struct S2C
end
PB.default_values(::Type{S2C}) = (;)
PB.field_numbers(::Type{S2C}) = (;)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        PB.skip(d, wire_type)
    end
    return S2C()
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

export VerificationType, VerificationOp, C2S, S2C, Request, Response

end
