module Trd_Notify

using ProtoBuf
using ProtoBuf
import ..Trd_Common

mutable struct S2C
    header::Trd_Common.TrdHeader
    type::Int32
    S2C(; header = Trd_Common.TrdHeader(), type = 0) = new(header, type)
end

mutable struct Response
    retType::Int32
    retMsg::String
    errCode::Int32
    s2c::S2C
    Response(; retType = -400, retMsg = "", errCode = 0, s2c = S2C()) = new(retType, retMsg, errCode, s2c)
end

export S2C, Response

end
