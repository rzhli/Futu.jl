module Notify

import ProtoBuf as PB
using ProtoBuf.EnumX
using ..Common

@enumx NotifyType begin
    None = 0
    GtwEvent = 1
    ProgramStatus = 2
    ConnStatus = 3
    QotRight = 4
    APILevel = 5
    APIQuota = 6
    UsedQuota = 7
end

@enumx GtwEventType begin
    None = 0
    LocalCfgLoadFailed = 1
    APISvrRunFailed = 2
    ForceUpdate = 3
    LoginFailed = 4
    UnAgreeDisclaimer = 5
    NetCfgMissing = 6
    KickedOut = 7
    LoginPwdChanged = 8
    BanLogin = 9
    NeedPicVerifyCode = 10
    NeedPhoneVerifyCode = 11
    AppDataNotExist = 12
    NessaryDataMissing = 13
    TradePwdChanged = 14
    EnableDeviceLock = 15
end

mutable struct GtwEvent
    eventType::Int32
    desc::String

    GtwEvent() = new(zero(Int32), "")
    GtwEvent(eventType, desc) = new(eventType, desc)
end
PB.default_values(::Type{GtwEvent}) = (;eventType = zero(Int32), desc = "")
PB.field_numbers(::Type{GtwEvent}) = (;eventType = 1, desc = 2)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:GtwEvent})
    eventType = zero(Int32)
    desc = ""
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            eventType = PB.decode(d, Int32)
        elseif field_number == 2
            desc = PB.decode(d, String)
        else
            PB.skip(d, wire_type)
        end
    end
    return GtwEvent(eventType, desc)
end

mutable struct ProgramStatus
    programStatus::Common.ProgramStatus

    ProgramStatus() = new(Common.ProgramStatus())
    ProgramStatus(programStatus) = new(programStatus)
end
PB.default_values(::Type{ProgramStatus}) = (;programStatus = Common.ProgramStatus())
PB.field_numbers(::Type{ProgramStatus}) = (;programStatus = 1)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:ProgramStatus})
    programStatus = Common.ProgramStatus()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            programStatus = PB.decode(d, Ref{Common.ProgramStatus})
        else
            PB.skip(d, wire_type)
        end
    end
    return ProgramStatus(programStatus)
end

mutable struct ConnectStatus
    qotLogined::Bool
    trdLogined::Bool

    ConnectStatus() = new(false, false)
    ConnectStatus(qotLogined, trdLogined) = new(qotLogined, trdLogined)
end
PB.default_values(::Type{ConnectStatus}) = (;qotLogined = false, trdLogined = false)
PB.field_numbers(::Type{ConnectStatus}) = (;qotLogined = 1, trdLogined = 2)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:ConnectStatus})
    qotLogined = false
    trdLogined = false
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            qotLogined = PB.decode(d, Bool)
        elseif field_number == 2
            trdLogined = PB.decode(d, Bool)
        else
            PB.skip(d, wire_type)
        end
    end
    return ConnectStatus(qotLogined, trdLogined)
end

mutable struct QotRight
    hkQotRight::Int32
    usQotRight::Int32
    cnQotRight::Int32
    hkOptionQotRight::Int32
    hasUSOptionQotRight::Bool
    hkFutureQotRight::Int32
    usFutureQotRight::Int32
    usOptionQotRight::Int32
    usIndexQotRight::Int32
    usOtcQotRight::Int32
    sgFutureQotRight::Int32
    jpFutureQotRight::Int32
    usCMEFutureQotRight::Int32
    usCBOTFutureQotRight::Int32
    usNYMEXFutureQotRight::Int32
    usCOMEXFutureQotRight::Int32
    usCBOEFutureQotRight::Int32
    shQotRight::Int32
    szQotRight::Int32

    QotRight() = new(0, 0, 0, 0, false, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    QotRight(hkQotRight, usQotRight, cnQotRight, hkOptionQotRight, hasUSOptionQotRight,
             hkFutureQotRight, usFutureQotRight, usOptionQotRight, usIndexQotRight, usOtcQotRight,
             sgFutureQotRight, jpFutureQotRight, usCMEFutureQotRight, usCBOTFutureQotRight,
             usNYMEXFutureQotRight, usCOMEXFutureQotRight, usCBOEFutureQotRight, shQotRight, szQotRight) =
        new(hkQotRight, usQotRight, cnQotRight, hkOptionQotRight, hasUSOptionQotRight,
            hkFutureQotRight, usFutureQotRight, usOptionQotRight, usIndexQotRight, usOtcQotRight,
            sgFutureQotRight, jpFutureQotRight, usCMEFutureQotRight, usCBOTFutureQotRight,
            usNYMEXFutureQotRight, usCOMEXFutureQotRight, usCBOEFutureQotRight, shQotRight, szQotRight)
end
PB.default_values(::Type{QotRight}) = (;hkQotRight = zero(Int32), usQotRight = zero(Int32), cnQotRight = zero(Int32), hkOptionQotRight = zero(Int32), hasUSOptionQotRight = false, hkFutureQotRight = zero(Int32), usFutureQotRight = zero(Int32), usOptionQotRight = zero(Int32), usIndexQotRight = zero(Int32), usOtcQotRight = zero(Int32), sgFutureQotRight = zero(Int32), jpFutureQotRight = zero(Int32), usCMEFutureQotRight = zero(Int32), usCBOTFutureQotRight = zero(Int32), usNYMEXFutureQotRight = zero(Int32), usCOMEXFutureQotRight = zero(Int32), usCBOEFutureQotRight = zero(Int32), shQotRight = zero(Int32), szQotRight = zero(Int32))
PB.field_numbers(::Type{QotRight}) = (;hkQotRight = 1, usQotRight = 2, cnQotRight = 3, hkOptionQotRight = 4, hasUSOptionQotRight = 5, hkFutureQotRight = 6, usFutureQotRight = 7, usOptionQotRight = 8, usIndexQotRight = 9, usOtcQotRight = 10, sgFutureQotRight = 11, jpFutureQotRight = 12, usCMEFutureQotRight = 13, usCBOTFutureQotRight = 14, usNYMEXFutureQotRight = 15, usCOMEXFutureQotRight = 16, usCBOEFutureQotRight = 17, shQotRight = 18, szQotRight = 19)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:QotRight})
    hkQotRight = zero(Int32)
    usQotRight = zero(Int32)
    cnQotRight = zero(Int32)
    hkOptionQotRight = zero(Int32)
    hasUSOptionQotRight = false
    hkFutureQotRight = zero(Int32)
    usFutureQotRight = zero(Int32)
    usOptionQotRight = zero(Int32)
    usIndexQotRight = zero(Int32)
    usOtcQotRight = zero(Int32)
    sgFutureQotRight = zero(Int32)
    jpFutureQotRight = zero(Int32)
    usCMEFutureQotRight = zero(Int32)
    usCBOTFutureQotRight = zero(Int32)
    usNYMEXFutureQotRight = zero(Int32)
    usCOMEXFutureQotRight = zero(Int32)
    usCBOEFutureQotRight = zero(Int32)
    shQotRight = zero(Int32)
    szQotRight = zero(Int32)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            hkQotRight = PB.decode(d, Int32)
        elseif field_number == 2
            usQotRight = PB.decode(d, Int32)
        elseif field_number == 3
            cnQotRight = PB.decode(d, Int32)
        elseif field_number == 4
            hkOptionQotRight = PB.decode(d, Int32)
        elseif field_number == 5
            hasUSOptionQotRight = PB.decode(d, Bool)
        elseif field_number == 6
            hkFutureQotRight = PB.decode(d, Int32)
        elseif field_number == 7
            usFutureQotRight = PB.decode(d, Int32)
        elseif field_number == 8
            usOptionQotRight = PB.decode(d, Int32)
        elseif field_number == 9
            usIndexQotRight = PB.decode(d, Int32)
        elseif field_number == 10
            usOtcQotRight = PB.decode(d, Int32)
        elseif field_number == 11
            sgFutureQotRight = PB.decode(d, Int32)
        elseif field_number == 12
            jpFutureQotRight = PB.decode(d, Int32)
        elseif field_number == 13
            usCMEFutureQotRight = PB.decode(d, Int32)
        elseif field_number == 14
            usCBOTFutureQotRight = PB.decode(d, Int32)
        elseif field_number == 15
            usNYMEXFutureQotRight = PB.decode(d, Int32)
        elseif field_number == 16
            usCOMEXFutureQotRight = PB.decode(d, Int32)
        elseif field_number == 17
            usCBOEFutureQotRight = PB.decode(d, Int32)
        elseif field_number == 18
            shQotRight = PB.decode(d, Int32)
        elseif field_number == 19
            szQotRight = PB.decode(d, Int32)
        else
            PB.skip(d, wire_type)
        end
    end
    return QotRight(hkQotRight, usQotRight, cnQotRight, hkOptionQotRight, hasUSOptionQotRight, hkFutureQotRight, usFutureQotRight, usOptionQotRight, usIndexQotRight, usOtcQotRight, sgFutureQotRight, jpFutureQotRight, usCMEFutureQotRight, usCBOTFutureQotRight, usNYMEXFutureQotRight, usCOMEXFutureQotRight, usCBOEFutureQotRight, shQotRight, szQotRight)
end

mutable struct APILevel
    apiLevel::String

    APILevel() = new("")
    APILevel(apiLevel) = new(apiLevel)
end
PB.default_values(::Type{APILevel}) = (;apiLevel = "")
PB.field_numbers(::Type{APILevel}) = (;apiLevel = 1)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:APILevel})
    apiLevel = ""
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            apiLevel = PB.decode(d, String)
        else
            PB.skip(d, wire_type)
        end
    end
    return APILevel(apiLevel)
end

mutable struct APIQuota
    subQuota::Int32
    historyKLQuota::Int32

    APIQuota() = new(zero(Int32), zero(Int32))
    APIQuota(subQuota, historyKLQuota) = new(subQuota, historyKLQuota)
end
PB.default_values(::Type{APIQuota}) = (;subQuota = zero(Int32), historyKLQuota = zero(Int32))
PB.field_numbers(::Type{APIQuota}) = (;subQuota = 1, historyKLQuota = 2)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:APIQuota})
    subQuota = zero(Int32)
    historyKLQuota = zero(Int32)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            subQuota = PB.decode(d, Int32)
        elseif field_number == 2
            historyKLQuota = PB.decode(d, Int32)
        else
            PB.skip(d, wire_type)
        end
    end
    return APIQuota(subQuota, historyKLQuota)
end

mutable struct UsedQuota
    usedSubQuota::Int32
    usedKLineQuota::Int32
    UsedQuota() = new(zero(Int32), zero(Int32))
    UsedQuota(usedSubQuota, usedKLineQuota) = new(usedSubQuota, usedKLineQuota)
end
PB.default_values(::Type{UsedQuota}) = (;usedSubQuota = zero(Int32), usedKLineQuota = zero(Int32))
PB.field_numbers(::Type{UsedQuota}) = (;usedSubQuota = 1, usedKLineQuota = 2)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:UsedQuota})
    usedSubQuota = zero(Int32)
    usedKLineQuota = zero(Int32)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            usedSubQuota = PB.decode(d, Int32)
        elseif field_number == 2
            usedKLineQuota = PB.decode(d, Int32)
        else
            PB.skip(d, wire_type)
        end
    end
    return UsedQuota(usedSubQuota, usedKLineQuota)
end

mutable struct S2C
    type::Int32
    event::GtwEvent
    programStatus::ProgramStatus
    connectStatus::ConnectStatus
    qotRight::QotRight
    apiLevel::APILevel
    apiQuota::APIQuota
    usedQuota::UsedQuota

    S2C() = new(0, GtwEvent(), ProgramStatus(), ConnectStatus(), QotRight(), APILevel(), APIQuota(), UsedQuota())
    S2C(type, event, programStatus, connectStatus, qotRight, apiLevel, apiQuota, usedQuota) =
        new(type, event, programStatus, connectStatus, qotRight, apiLevel, apiQuota, usedQuota)
end
PB.default_values(::Type{S2C}) = (;type = 0, event = GtwEvent(), programStatus = ProgramStatus(), connectStatus = ConnectStatus(), qotRight = QotRight(), apiLevel = APILevel(), apiQuota = APIQuota(), usedQuota = UsedQuota())
PB.field_numbers(::Type{S2C}) = (;type = 1, event = 2, programStatus = 3, connectStatus = 4, qotRight = 5, apiLevel = 6, apiQuota = 7, usedQuota = 8)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    type = 0
    event = GtwEvent()
    programStatus = ProgramStatus()
    connectStatus = ConnectStatus()
    qotRight = QotRight()
    apiLevel = APILevel()
    apiQuota = APIQuota()
    usedQuota = UsedQuota()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            type = PB.decode(d, Int32)
        elseif field_number == 2
            event = PB.decode(d, Ref{GtwEvent})
        elseif field_number == 3
            programStatus = PB.decode(d, Ref{ProgramStatus})
        elseif field_number == 4
            connectStatus = PB.decode(d, Ref{ConnectStatus})
        elseif field_number == 5
            qotRight = PB.decode(d, Ref{QotRight})
        elseif field_number == 6
            apiLevel = PB.decode(d, Ref{APILevel})
        elseif field_number == 7
            apiQuota = PB.decode(d, Ref{APIQuota})
        elseif field_number == 8
            usedQuota = PB.decode(d, Ref{UsedQuota})
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(type, event, programStatus, connectStatus, qotRight, apiLevel, apiQuota, usedQuota)
end

mutable struct Response
    retType::Int32
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
    return Response(retType, retMsg, errCode, s2c)
end

export NotifyType, GtwEventType, GtwEvent, ProgramStatus, ConnectStatus, QotRight, APILevel, APIQuota, UsedQuota, S2C, Response

end
