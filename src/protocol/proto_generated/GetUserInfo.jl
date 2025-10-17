module GetUserInfo

import ProtoBuf as PB
using ProtoBuf.EnumX
using ..Common

@enumx UpdateType begin
    None = 0            # 无需升级
    Advice = 1          # 建议升级
    Force = 2           # 强制升级
end

@enumx UserInfoField begin
    Basic = 1           # 昵称，用户头像，牛牛号
    API = 2             # API权限信息
    QotRight = 4        # 市场的行情权限
    Disclaimer = 8      # 免责声明
    Update = 16         # 升级类型
    WebKey = 2048       # WebKey
end

mutable struct C2S
    flag::Int32
end
PB.default_values(::Type{C2S}) = (;flag = zero(Int32))
PB.field_numbers(::Type{C2S}) = (;flag = 2)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    x.flag != zero(Int32) && PB.encode(e, 2, x.flag)
    return position(e.io) - initpos
end

mutable struct S2C
    nickName::String                    # 用户昵称      
    avatarUrl::String                   # 用户头像url
    apiLevel::String                    # api用户等级描述, 已在2.10版本之后废弃
    hkQotRight::Int32                   # 港股行情权限, QotRight
    usQotRight::Int32                   # 美股行情权限, QotRight
    cnQotRight::Int32                   # A股行情权限, QotRight // 废弃，使用shQotRight和szQotRight
    isNeedAgreeDisclaimer::Bool         # 已开户用户需要同意免责声明，未开户或已同意的用户返回false
    userID::Int64                       # 用户牛牛号
    updateType::Int32                   # 升级类型，UpdateType
    webKey::String                      # WebKey
    webJumpUrlHead::String
    hkOptionQotRight::Int32             # 港股期权行情权限, Qot_Common.QotRight
    hasUSOptionQotRight::Bool           # 是否有美股期权行情权限
    hkFutureQotRight::Int32             # 港股期货行情权限, Qot_Common.QotRight
    subQuota::Int32                     # 订阅额度
    historyKLQuota::Int32               # 历史K线额度
    usFutureQotRight::Int32             # 美股期货行情权限, Qot_Common.QotRight
    usOptionQotRight::Int32             # 美股期权行情权限, Qot_Common.QotRight
    userAttribution::Int32              # 用户注册归属地, Common.UserAttribution
    updateWhatsNew::String              # 升级提示
    usIndexQotRight::Int32              # 美股指数行情权限, Qot_Common.QotRight
    usOtcQotRight::Int32                # 美股OTC市场行情权限, Qot_Common.QotRight
    usCMEFutureQotRight::Int32          # 美股CME期货行情权限, Qot_Common.QotRight
    usCBOTFutureQotRight::Int32         # 美股CBOT期货行情权限, Qot_Common.QotRight
    usNYMEXFutureQotRight::Int32        # 美股NYMEX期货行情权限, Qot_Common.QotRight
    usCOMEXFutureQotRight::Int32        # 美股COMEX期货行情权限, Qot_Common.QotRight
    usCBOEFutureQotRight::Int32         # 美股CBOE期货行情权限, Qot_Common.QotRight
    sgFutureQotRight::Int32             # 新加坡市场期货行情权限, Qot_Common.QotRight
    jpFutureQotRight::Int32             # 日本市场期货行情权限, Qot_Common.QotRight
    isAppNNOrMM::Bool                   # true:NN false:MM
    shQotRight::Int32                   # 上海市场行情权限, Qot_Common.QotRight
    szQotRight::Int32                   # 深圳市场行情权限, Qot_Common.QotRight
end
S2C() = S2C("", "", "", zero(Int32), zero(Int32), zero(Int32), false, zero(Int64), zero(Int32),
    "", "", zero(Int32), false, zero(Int32), zero(Int32), zero(Int32), zero(Int32), zero(Int32), zero(Int32),
    "", zero(Int32), zero(Int32), zero(Int32), zero(Int32), zero(Int32), zero(Int32), zero(Int32),
    zero(Int32), zero(Int32), false, zero(Int32), zero(Int32)
)
PB.default_values(::Type{S2C}) = (;
nickName = "", avatarUrl = "", apiLevel = "", hkQotRight = zero(Int32), 
usQotRight = zero(Int32), cnQotRight = zero(Int32), isNeedAgreeDisclaimer = false, userID = zero(Int64), 
updateType = zero(Int32), webKey = "", webJumpUrlHead = "", hkOptionQotRight = zero(Int32), hasUSOptionQotRight = false, 
hkFutureQotRight = zero(Int32), subQuota = zero(Int32), historyKLQuota = zero(Int32), usFutureQotRight = zero(Int32), 
usOptionQotRight = zero(Int32), userAttribution = zero(Int32), updateWhatsNew = "", usIndexQotRight = zero(Int32), 
usOtcQotRight = zero(Int32), usCMEFutureQotRight = zero(Int32), usCBOTFutureQotRight = zero(Int32), usNYMEXFutureQotRight = zero(Int32), 
usCOMEXFutureQotRight = zero(Int32), usCBOEFutureQotRight = zero(Int32), sgFutureQotRight = zero(Int32), jpFutureQotRight = zero(Int32), 
isAppNNOrMM = false, shQotRight = zero(Int32), szQotRight = zero(Int32)
)
PB.field_numbers(::Type{S2C}) = (;
nickName = 1, avatarUrl = 2, apiLevel = 3, hkQotRight = 4, usQotRight = 5, cnQotRight = 6, isNeedAgreeDisclaimer = 7, userID = 8,
updateType = 9, webKey = 10, hkOptionQotRight = 11, hasUSOptionQotRight = 12, hkFutureQotRight = 13, subQuota = 14,
historyKLQuota = 15, usFutureQotRight = 16, usOptionQotRight = 17, webJumpUrlHead = 18, userAttribution = 19, updateWhatsNew = 20,
usIndexQotRight = 21, usOtcQotRight = 22, usCMEFutureQotRight = 23, usCBOTFutureQotRight = 24, usNYMEXFutureQotRight = 25,
usCOMEXFutureQotRight = 26, usCBOEFutureQotRight = 27, sgFutureQotRight = 28, jpFutureQotRight = 29, isAppNNOrMM = 30,
shQotRight = 31, szQotRight = 32
)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:S2C})
    nickName = ""
    avatarUrl = ""
    apiLevel = ""
    hkQotRight = zero(Int32)
    usQotRight = zero(Int32)
    cnQotRight = zero(Int32)
    isNeedAgreeDisclaimer = false
    userID = zero(Int64)
    updateType = zero(Int32)
    webKey = ""
    webJumpUrlHead = ""
    hkOptionQotRight = zero(Int32)
    hasUSOptionQotRight = false
    hkFutureQotRight = zero(Int32)
    subQuota = zero(Int32)
    historyKLQuota = zero(Int32)
    usFutureQotRight = zero(Int32)
    usOptionQotRight = zero(Int32)
    userAttribution = zero(Int32)
    updateWhatsNew = ""
    usIndexQotRight = zero(Int32)
    usOtcQotRight = zero(Int32)
    usCMEFutureQotRight = zero(Int32)
    usCBOTFutureQotRight = zero(Int32)
    usNYMEXFutureQotRight = zero(Int32)
    usCOMEXFutureQotRight = zero(Int32)
    usCBOEFutureQotRight = zero(Int32)
    sgFutureQotRight = zero(Int32)
    jpFutureQotRight = zero(Int32)
    isAppNNOrMM = false
    shQotRight = zero(Int32)
    szQotRight = zero(Int32)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            nickName = PB.decode(d, String)
        elseif field_number == 2
            avatarUrl = PB.decode(d, String)
        elseif field_number == 3
            apiLevel = PB.decode(d, String)
        elseif field_number == 4
            hkQotRight = PB.decode(d, Int32)
        elseif field_number == 5
            usQotRight = PB.decode(d, Int32)
        elseif field_number == 6
            cnQotRight = PB.decode(d, Int32)
        elseif field_number == 7
            isNeedAgreeDisclaimer = PB.decode(d, Bool)
        elseif field_number == 8
            userID = PB.decode(d, Int64)
        elseif field_number == 9
            updateType = PB.decode(d, Int32)
        elseif field_number == 10
            webKey = PB.decode(d, String)
        elseif field_number == 11
            hkOptionQotRight = PB.decode(d, Int32)
        elseif field_number == 12
            hasUSOptionQotRight = PB.decode(d, Bool)
        elseif field_number == 13
            hkFutureQotRight = PB.decode(d, Int32)
        elseif field_number == 14
            subQuota = PB.decode(d, Int32)
        elseif field_number == 15
            historyKLQuota = PB.decode(d, Int32)
        elseif field_number == 16
            usFutureQotRight = PB.decode(d, Int32)
        elseif field_number == 17
            usOptionQotRight = PB.decode(d, Int32)
        elseif field_number == 18
            webJumpUrlHead = PB.decode(d, String)
        elseif field_number == 19
            userAttribution = PB.decode(d, Int32)
        elseif field_number == 20
            updateWhatsNew = PB.decode(d, String)
        elseif field_number == 21
            usIndexQotRight = PB.decode(d, Int32)
        elseif field_number == 22
            usOtcQotRight = PB.decode(d, Int32)
        elseif field_number == 23
            usCMEFutureQotRight = PB.decode(d, Int32)
        elseif field_number == 24
            usCBOTFutureQotRight = PB.decode(d, Int32)
        elseif field_number == 25
            usNYMEXFutureQotRight = PB.decode(d, Int32)
        elseif field_number == 26
            usCOMEXFutureQotRight = PB.decode(d, Int32)
        elseif field_number == 27
            usCBOEFutureQotRight = PB.decode(d, Int32)
        elseif field_number == 28
            sgFutureQotRight = PB.decode(d, Int32)
        elseif field_number == 29
            jpFutureQotRight = PB.decode(d, Int32)
        elseif field_number == 30
            isAppNNOrMM = PB.decode(d, Bool)
        elseif field_number == 31
            shQotRight = PB.decode(d, Int32)
        elseif field_number == 32
            szQotRight = PB.decode(d, Int32)
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(nickName, avatarUrl, apiLevel, hkQotRight, usQotRight, cnQotRight, isNeedAgreeDisclaimer, userID, updateType, webKey, webJumpUrlHead, hkOptionQotRight, hasUSOptionQotRight, hkFutureQotRight, subQuota, historyKLQuota, usFutureQotRight, usOptionQotRight, userAttribution, updateWhatsNew, usIndexQotRight, usOtcQotRight, usCMEFutureQotRight, usCBOTFutureQotRight, usNYMEXFutureQotRight, usCOMEXFutureQotRight, usCBOEFutureQotRight, sgFutureQotRight, jpFutureQotRight, isAppNNOrMM, shQotRight, szQotRight)
end

mutable struct Request
    c2s::C2S
end
PB.default_values(::Type{Request}) = (;c2s = C2S())
PB.field_numbers(::Type{Request}) = (;c2s = 1)
function PB.encode(e::PB.AbstractProtoEncoder, x::Request)
    initpos = position(e.io)
    PB.encode(e, 1, x.c2s)
    return position(e.io) - initpos
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

struct QuoteRight
    name::String
    enabled::Bool
end

struct UserInfoSummary
    success::Bool
    ret_type::Int32
    ret_msg::String
    err_code::Int32
    nick_name::String
    avatar_url::String
    user_id::Int64
    api_level::String
    quote_rights::Vector{QuoteRight}
    flags::Vector{Pair{String,String}}
end

requested(mask::Int32, field::UserInfoField.T) = mask == 0 || (mask & Int32(field)) != 0

function build_user_info_summary(resp::Response, mask::Int32 = Int32(0))
    success = resp.retType == Int32(Common.RetType.Succeed)
    if !success
        return UserInfoSummary(false, resp.retType, resp.retMsg, resp.errCode, "", "", 0, "", QuoteRight[], Pair{String,String}[])
    end

    s2c = resp.s2c
    
    # Only populate fields that were requested
    nick_name = requested(mask, UserInfoField.Basic) ? s2c.nickName : ""
    avatar_url = requested(mask, UserInfoField.Basic) ? s2c.avatarUrl : ""
    user_id = requested(mask, UserInfoField.Basic) ? s2c.userID : zero(Int64)
    api_level = requested(mask, UserInfoField.API) ? s2c.apiLevel : ""
    
    quote_rights = requested(mask, UserInfoField.QotRight) ? QuoteRight[
        QuoteRight("HK", s2c.hkQotRight > 0),
        QuoteRight("US", s2c.usQotRight > 0),
        QuoteRight("CN", s2c.cnQotRight > 0),
        QuoteRight("HK Option", s2c.hkOptionQotRight > 0),
        QuoteRight("US Option", s2c.hasUSOptionQotRight),
        QuoteRight("HK Future", s2c.hkFutureQotRight > 0),
        QuoteRight("US Future", s2c.usFutureQotRight > 0),
        QuoteRight("US Index", s2c.usIndexQotRight > 0),
        QuoteRight("US OTC", s2c.usOtcQotRight > 0),
        QuoteRight("SG Future", s2c.sgFutureQotRight > 0),
        QuoteRight("JP Future", s2c.jpFutureQotRight > 0),
        QuoteRight("SH", s2c.shQotRight > 0),
        QuoteRight("SZ", s2c.szQotRight > 0)
    ] : QuoteRight[]

    flags = Pair{String,String}[]
    if requested(mask, UserInfoField.Disclaimer)
        push!(flags, "Need Disclaimer" => (s2c.isNeedAgreeDisclaimer ? "Yes" : "No"))
    end
    if requested(mask, UserInfoField.API)
        push!(flags, "User Attribution" => string(s2c.userAttribution))
        push!(flags, "Is App NN/MM" => (s2c.isAppNNOrMM ? "Yes" : "No"))
    end
    if requested(mask, UserInfoField.Update)
        push!(flags, "Update Type" => string(UpdateType.T(s2c.updateType)))
        push!(flags, "Update What's New" => (isempty(s2c.updateWhatsNew) ? "-" : s2c.updateWhatsNew))
    end
    if requested(mask, UserInfoField.WebKey)
        push!(flags, "Web Key" => (isempty(s2c.webKey) ? "-" : s2c.webKey))
        push!(flags, "Web Jump URL" => (isempty(s2c.webJumpUrlHead) ? "-" : s2c.webJumpUrlHead))
    end

    return UserInfoSummary(true, resp.retType, resp.retMsg, resp.errCode, nick_name, avatar_url, user_id, api_level, quote_rights, flags)
end

# Bitwise operators for combining UserInfoField flags
Base.:|(a::UserInfoField.T, b::UserInfoField.T) = Int32(a) | Int32(b)
Base.:|(a::UserInfoField.T, b::Integer) = Int32(a) | Int32(b)
Base.:|(a::Integer, b::UserInfoField.T) = Int32(a) | Int32(b)

export UpdateType, UserInfoField, C2S, S2C, Request, Response, QuoteRight, UserInfoSummary, build_user_info_summary

end
