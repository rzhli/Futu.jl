module Qot_GetSuspend

using ProtoBuf
using ProtoBuf
import ..Common
import ..Qot_Common

mutable struct C2S
    securityList::Vector{Qot_Common.Security}  # 股票
    beginTime::String                          # 开始时间字符串
    endTime::String                            # 结束时间字符串
    C2S(; securityList = Vector{Qot_Common.Security}(), beginTime = "", endTime = "") = new(securityList, beginTime, endTime)
end

mutable struct Suspend
    time::String      # 时间字符串
    timestamp::Float64 # 时间戳
end

mutable struct SecuritySuspend
    security::Qot_Common.Security # 股票
    suspendList::Vector{Suspend}  # 交易日
    SecuritySuspend(; security = Qot_Common.Security(), suspendList = Vector{Suspend}()) = new(security, suspendList)
end

mutable struct S2C
    SecuritySuspendList::Vector{SecuritySuspend} # 多支股票的交易日
    S2C(; SecuritySuspendList = Vector{SecuritySuspend}()) = new(SecuritySuspendList)
end

mutable struct Request
    c2s::C2S
    Request(; c2s = C2S()) = new(c2s)
end

mutable struct Response
    retType::Int32    # RetType,返回结果
    retMsg::String
    errCode::Int32
    s2c::S2C
    Response(; retType = -400, retMsg = "", errCode = 0, s2c = S2C()) = new(retType, retMsg, errCode, s2c)
end

export C2S, Suspend, SecuritySuspend, S2C, Request, Response

end
