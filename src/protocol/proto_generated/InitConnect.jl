module InitConnect

using ProtoBuf
import ProtoBuf as PB
using ..Common

mutable struct C2S
    clientVer::Int32
    clientID::String
    recvNotify::Bool
    packetEncAlgo::Common.PacketEncAlgo.T
    pushProtoFmt::Common.ProtoFmt.T
    programmingLanguage::String
end
C2S() = C2S(zero(Int32), "", false, Common.PacketEncAlgo.None, Common.ProtoFmt.Protobuf, "")
PB.default_values(::Type{C2S}) = (;clientVer = zero(Int32), clientID = "", recvNotify = false, packetEncAlgo = Common.PacketEncAlgo.FTAES_ECB, pushProtoFmt = Common.ProtoFmt.Protobuf, programmingLanguage = "")
PB.field_numbers(::Type{C2S}) = (;clientVer = 1, clientID = 2, recvNotify = 3, packetEncAlgo = 4, pushProtoFmt = 5, programmingLanguage = 6)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    x.clientVer != zero(Int32) && PB.encode(e, 1, x.clientVer)
    x.clientID != "" && PB.encode(e, 2, x.clientID)
    x.recvNotify != false && PB.encode(e, 3, x.recvNotify)
    x.packetEncAlgo != Common.PacketEncAlgo.None && PB.encode(e, 4, x.packetEncAlgo)
    x.pushProtoFmt != Common.ProtoFmt.Protobuf && PB.encode(e, 5, x.pushProtoFmt)
    x.programmingLanguage != "" && PB.encode(e, 6, x.programmingLanguage)
    return position(e.io) - initpos
end

mutable struct S2C
    serverVer::Int32
    loginUserID::UInt64
    connID::UInt64
    connAESKey::String
    keepAliveInterval::Int32
    aesCBCiv::String
    userAttribution::Common.UserAttribution.T
end
S2C() = S2C(zero(Int32), zero(UInt64), zero(UInt64), "", zero(Int32), "", Common.UserAttribution.Unknown)
PB.default_values(::Type{S2C}) = (;serverVer = zero(Int32), loginUserID = zero(UInt64), connID = zero(UInt64), connAESKey = "", keepAliveInterval = zero(Int32), aesCBCiv = "", userAttribution = Common.UserAttribution.Unknown)
PB.field_numbers(::Type{S2C}) = (;serverVer = 1, loginUserID = 2, connID = 3, connAESKey = 4, keepAliveInterval = 5, aesCBCiv = 6, userAttribution = 7)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    serverVer = zero(Int32)
    loginUserID = zero(UInt64)
    connID = zero(UInt64)
    connAESKey = ""
    keepAliveInterval = zero(Int32)
    aesCBCiv = ""
    userAttribution = Common.UserAttribution.Unknown
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            serverVer = PB.decode(d, Int32)
        elseif field_number == 2
            loginUserID = PB.decode(d, UInt64)
        elseif field_number == 3
            connID = PB.decode(d, UInt64)
        elseif field_number == 4
            connAESKey = PB.decode(d, String)
        elseif field_number == 5
            keepAliveInterval = PB.decode(d, Int32)
        elseif field_number == 6
            aesCBCiv = PB.decode(d, String)
        elseif field_number == 7
            userAttribution = PB.decode(d, Common.UserAttribution.T)
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(serverVer, loginUserID, connID, connAESKey, keepAliveInterval, aesCBCiv, userAttribution)
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
    retType::Common.RetType.T
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
            retType = PB.decode(d, Common.RetType.T)
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
