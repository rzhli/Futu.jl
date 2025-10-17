module KeepAlive

using ProtoBuf
import ProtoBuf as PB
using ..Common

mutable struct C2S
    time::Int64
end
C2S() = C2S(zero(Int64))
PB.default_values(::Type{C2S}) = (;time = zero(Int64))
PB.field_numbers(::Type{C2S}) = (;time = 1)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    x.time != zero(Int64) && PB.encode(e, 1, x.time)
    return position(e.io) - initpos
end

mutable struct S2C
    time::Int64
end
S2C() = S2C(zero(Int64))
PB.default_values(::Type{S2C}) = (;time = zero(Int64))
PB.field_numbers(::Type{S2C}) = (;time = 1)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    time = zero(Int64)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            time = PB.decode(d, Int64)
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(time)
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

export C2S, S2C, Request, Response

end
