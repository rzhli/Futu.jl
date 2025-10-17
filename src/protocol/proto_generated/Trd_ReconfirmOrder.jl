module Trd_ReconfirmOrder

using ProtoBuf
using ProtoBuf
import ..Common
import ..Trd_Common

mutable struct C2S
    packetID::Common.PacketID
    header::Trd_Common.TrdHeader
    orderID::UInt64
    reconfirmReason::Int32
    C2S(; packetID = Common.PacketID(), header = Trd_Common.TrdHeader(), orderID = 0, reconfirmReason = 0) = new(packetID, header, orderID, reconfirmReason)
end

mutable struct S2C
    header::Trd_Common.TrdHeader
    orderID::UInt64
    S2C(; header = Trd_Common.TrdHeader(), orderID = 0) = new(header, orderID)
end

mutable struct Request
    c2s::C2S
    Request(; c2s = C2S()) = new(c2s)
end

mutable struct Response
    retType::Int32
    retMsg::String
    errCode::Int32
    s2c::S2C
    Response(; retType = -400, retMsg = "", errCode = 0, s2c = S2C()) = new(retType, retMsg, errCode, s2c)
end

export C2S, S2C, Request, Response

end
