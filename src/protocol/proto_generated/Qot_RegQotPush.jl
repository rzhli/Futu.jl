module Qot_RegQotPush

using ProtoBuf
using ..Common
using ..Qot_Common

mutable struct C2S
    securityList::Vector{Qot_Common.Security}
    subTypeList::Vector{Int32}
    rehabTypeList::Vector{Int32}
    isRegOrUnReg::Bool
    isFirstPush::Bool
    C2S(; securityList = Vector{Qot_Common.Security}(), subTypeList = Vector{Int32}(), rehabTypeList = Vector{Int32}(), isRegOrUnReg = false, isFirstPush = false) = new(securityList, subTypeList, rehabTypeList, isRegOrUnReg, isFirstPush)
end

mutable struct S2C
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
    Response(; retType = Common.RetType.Unknown, retMsg = "", errCode = 0, s2c = S2C()) = new(retType, retMsg, errCode, s2c)
end

export C2S, S2C, Request, Response

end
