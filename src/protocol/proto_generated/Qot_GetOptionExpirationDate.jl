module Qot_GetOptionExpirationDate

import ProtoBuf as PB
import ..Common
import ..Qot_Common

mutable struct C2S
    owner::Qot_Common.Security #期权标的股，目前仅支持传入港美正股以及恒指国指
    indexOptionType::Int32     #Qot_Common.IndexOptionType，指数期权的类型，仅用于恒指国指
    C2S(; owner = Qot_Common.Security(), indexOptionType = 0) = new(owner, indexOptionType)
end
PB.default_values(::Type{C2S}) = (;owner = Qot_Common.Security(), indexOptionType = zero(Int32))
PB.field_numbers(::Type{C2S}) = (;owner = 1, indexOptionType = 2)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    PB.encode(e, 1, x.owner)
    x.indexOptionType != zero(Int32) && PB.encode(e, 2, x.indexOptionType)
    return position(e.io) - initpos
end

mutable struct OptionExpirationDate
    strikeTime::String                  # 期权链行权日（港股和 A 股市场默认是北京时间，美股市场默认是美东时间）
    strikeTimestamp::Float64            # 行权日时间戳
    optionExpiryDateDistance::Int32     # 距离到期日天数，负数表示已过期
    cycle::Int32                        # Qot_Common.ExpirationCycle,交割周期（仅用于香港指数期权）
end
PB.default_values(::Type{OptionExpirationDate}) = (;strikeTime = "", strikeTimestamp = zero(Float64), optionExpiryDateDistance = zero(Int32), cycle = zero(Int32))
PB.field_numbers(::Type{OptionExpirationDate}) = (;strikeTime = 1, strikeTimestamp = 2, optionExpiryDateDistance = 3, cycle = 4)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:OptionExpirationDate})
    strikeTime = ""
    strikeTimestamp = zero(Float64)
    optionExpiryDateDistance = zero(Int32)
    cycle = zero(Int32)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            strikeTime = PB.decode(d, String)
        elseif field_number == 2
            strikeTimestamp = PB.decode(d, Float64)
        elseif field_number == 3
            optionExpiryDateDistance = PB.decode(d, Int32)
        elseif field_number == 4
            cycle = PB.decode(d, Int32)
        else
            PB.skip(d, wire_type)
        end
    end
    return OptionExpirationDate(strikeTime, strikeTimestamp, optionExpiryDateDistance, cycle)
end
 
mutable struct S2C
    dateList::Vector{OptionExpirationDate} #期权链行权日
    S2C(; dateList = Vector{OptionExpirationDate}()) = new(dateList)
end
PB.default_values(::Type{S2C}) = (;dateList = Vector{OptionExpirationDate}())
PB.field_numbers(::Type{S2C}) = (;dateList = 1)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    dateList = PB.BufferedVector{OptionExpirationDate}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            PB.decode!(d, dateList)
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(dateList=dateList[])
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
    retType::Int32    # RetType,返回结果
    retMsg::String
    errCode::Int32
    s2c::S2C
    Response(; retType = -400, retMsg = "", errCode = 0, s2c = S2C()) = new(retType, retMsg, errCode, s2c)
end
PB.default_values(::Type{Response}) = (;retType = -400, retMsg = "", errCode = 0, s2c = S2C())
PB.field_numbers(::Type{Response}) = (;retType = 1, retMsg = 2, errCode = 3, s2c = 4)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:Response})
    retType = -400
    retMsg = ""
    errCode = 0
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

export C2S, OptionExpirationDate, S2C, Request, Response

end
