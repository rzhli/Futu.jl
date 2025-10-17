module Qot_UpdateBasicQot

import ProtoBuf as PB
import ..Common
import ..Qot_Common

mutable struct S2C
    basicQotList::Vector{Qot_Common.BasicQot} #股票基本行情
    S2C(; basicQotList = Vector{Qot_Common.BasicQot}()) = new(basicQotList)
end

PB.default_values(::Type{S2C}) = (; basicQotList = Vector{Qot_Common.BasicQot}())
PB.field_numbers(::Type{S2C}) = (; basicQotList = 1)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    basicQotList = Vector{Qot_Common.BasicQot}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            push!(basicQotList, PB.decode(d, Ref{Qot_Common.BasicQot}))
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(; basicQotList = basicQotList)
end

mutable struct Response
    retType::Int32    # RetType,返回结果
    retMsg::String
    errCode::Int32
    s2c::S2C
    Response(; retType = -400, retMsg = "", errCode = 0, s2c = S2C()) = new(retType, retMsg, errCode, s2c)
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
