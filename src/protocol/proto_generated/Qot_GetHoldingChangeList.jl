module Qot_GetHoldingChangeList

using ProtoBuf
using ProtoBuf
import ..Common
import ..Qot_Common

mutable struct C2S
    security::Qot_Common.Security
    holderCategory::Int32
    beginTime::String
    endTime::String
    C2S(; security = Qot_Common.Security(), holderCategory = 0, beginTime = "", endTime = "") = new(security, holderCategory, beginTime, endTime)
end

mutable struct S2C
    security::Qot_Common.Security
    holdingChangeList::Vector{Qot_Common.ShareHoldingChange}
    S2C(; security = Qot_Common.Security(), holdingChangeList = Vector{Qot_Common.ShareHoldingChange}()) = new(security, holdingChangeList)
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
