module Qot_UpdateRT

import ProtoBuf as PB
import ..Common
import ..Qot_Common

mutable struct S2C
    security::Qot_Common.Security
    name::String #股票名称
    rtList::Vector{Qot_Common.TimeShare} #推送的分时点
    S2C(; security = Qot_Common.Security(), name = "", rtList = Vector{Qot_Common.TimeShare}()) = new(security, name, rtList)
end

PB.default_values(::Type{S2C}) = (; security = Qot_Common.Security(), name = "", rtList = Vector{Qot_Common.TimeShare}())
PB.field_numbers(::Type{S2C}) = (; security = 1, rtList = 2, name = 3)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    security = Qot_Common.Security()
    name = ""
    rtList = Vector{Qot_Common.TimeShare}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            security = PB.decode(d, Ref{Qot_Common.Security})
        elseif field_number == 2
            push!(rtList, PB.decode(d, Ref{Qot_Common.TimeShare}))
        elseif field_number == 3
            name = PB.decode(d, String)
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(; security = security, name = name, rtList = rtList)
end

mutable struct Response
    retType::Int32    # RetType,返回结果
    retMsg::String
    errCode::Int32
    s2c::S2C
    Response(; retType = Int32(-400), retMsg = "", errCode = Int32(0), s2c = S2C()) = new(retType, retMsg, errCode, s2c)
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
    return Response(; retType = retType, retMsg = retMsg, errCode = errCode, s2c = s2c)
end

export S2C, Response

end
