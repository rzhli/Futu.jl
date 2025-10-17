module Qot_UpdatePriceReminder

import ProtoBuf as PB
import ..Common
import ..Qot_Common

mutable struct S2C
    security::Qot_Common.Security
    name::String
    price::Float64
    changeRate::Float64
    marketStatus::Int32
    content::String
    note::String
    key::Int64
    _type::Int32
    setValue::Float64
    curValue::Float64
    S2C(; security = Qot_Common.Security(), name = "", price = 0.0, changeRate = 0.0, marketStatus = Int32(0), content = "", note = "", key = Int64(0), _type = Int32(0), setValue = 0.0, curValue = 0.0) = new(security, name, price, changeRate, marketStatus, content, note, key, _type, setValue, curValue)
end

PB.default_values(::Type{S2C}) = (; security = Qot_Common.Security(), name = "", price = 0.0, changeRate = 0.0, marketStatus = Int32(0), content = "", note = "", key = Int64(0), _type = Int32(0), setValue = 0.0, curValue = 0.0)
PB.field_numbers(::Type{S2C}) = (; security = 1, price = 2, changeRate = 3, marketStatus = 4, content = 5, note = 6, key = 7, _type = 8, setValue = 9, curValue = 10, name = 11)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    security = Qot_Common.Security()
    name = ""
    price = 0.0
    changeRate = 0.0
    marketStatus = Int32(0)
    content = ""
    note = ""
    key = Int64(0)
    _type = Int32(0)
    setValue = 0.0
    curValue = 0.0
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            security = PB.decode(d, Ref{Qot_Common.Security})
        elseif field_number == 2
            price = PB.decode(d, Float64)
        elseif field_number == 3
            changeRate = PB.decode(d, Float64)
        elseif field_number == 4
            marketStatus = PB.decode(d, Int32)
        elseif field_number == 5
            content = PB.decode(d, String)
        elseif field_number == 6
            note = PB.decode(d, String)
        elseif field_number == 7
            key = PB.decode(d, Int64)
        elseif field_number == 8
            _type = PB.decode(d, Int32)
        elseif field_number == 9
            setValue = PB.decode(d, Float64)
        elseif field_number == 10
            curValue = PB.decode(d, Float64)
        elseif field_number == 11
            name = PB.decode(d, String)
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(; security = security, name = name, price = price, changeRate = changeRate, marketStatus = marketStatus, content = content, note = note, key = key, _type = _type, setValue = setValue, curValue = curValue)
end

mutable struct Response
    retType::Int32
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
