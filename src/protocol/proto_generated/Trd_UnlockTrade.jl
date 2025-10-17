module Trd_UnlockTrade

import ProtoBuf as PB
using ProtoBuf.EnumX
using ..Common

mutable struct C2S
    unlock::Bool    # true解锁交易，false锁定交易
    pwdMD5::String  # 交易密码的MD5转16进制(全小写)，解锁交易必须要填密码，锁定交易不需要验证密码，可不填
    securityFirm::Int32 # 券商标识，取值见Trd_Common.SecurityFirm
    C2S(; unlock = false, pwdMD5 = "", securityFirm = 0) = new(unlock, pwdMD5, securityFirm)
end

PB.default_values(::Type{C2S}) = (;unlock = false, pwdMD5 = "", securityFirm = Int32(0))
PB.field_numbers(::Type{C2S}) = (;unlock = 1, pwdMD5 = 2, securityFirm = 3)

function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    PB.encode(e, 1, x.unlock)  # Always encode unlock field
    x.pwdMD5 != "" && PB.encode(e, 2, x.pwdMD5)
    x.securityFirm != Int32(0) && PB.encode(e, 3, x.securityFirm)
    return position(e.io) - initpos
end

mutable struct S2C
    S2C() = new()
end

PB.default_values(::Type{S2C}) = NamedTuple()
PB.field_numbers(::Type{S2C}) = NamedTuple()

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        PB.skip(d, wire_type)
    end
    return S2C()
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
