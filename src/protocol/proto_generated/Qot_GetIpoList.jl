module Qot_GetIpoList

import ProtoBuf as PB
import ..Common
import ..Qot_Common

# IPO基本数据
mutable struct BasicIpoData
    security::Qot_Common.Security  # 股票市场，支持港股、美股和A股
    name::String                   # 股票名称
    listTime::String               # 上市日期字符串
    listTimestamp::Float64         # 上市日期时间戳
end
BasicIpoData(; security = Qot_Common.Security(), name = "", listTime = "", listTimestamp = 0.0) = BasicIpoData(security, name, listTime, listTimestamp)

PB.default_values(::Type{BasicIpoData}) = (; security = Qot_Common.Security(), name = "", listTime = "", listTimestamp = 0.0)
PB.field_numbers(::Type{BasicIpoData}) = (; security = 1, name = 2, listTime = 3, listTimestamp = 4)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{BasicIpoData})
    security = Qot_Common.Security()
    name = ""
    listTime = ""
    listTimestamp = 0.0
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            security = PB.decode(d, Ref{Qot_Common.Security})
        elseif field_number == 2
            name = PB.decode(d, String)
        elseif field_number == 3
            listTime = PB.decode(d, String)
        elseif field_number == 4
            listTimestamp = PB.decode(d, Float64)
        else
            PB.skip(d, wire_type)
        end
    end
    return BasicIpoData(security, name, listTime, listTimestamp)
end

# 中签号数据
mutable struct WinningNumData
    winningName::String   # 分组名
    winningInfo::String   # 中签号信息
end
WinningNumData(; winningName = "", winningInfo = "") = WinningNumData(winningName, winningInfo)

PB.default_values(::Type{WinningNumData}) = (; winningName = "", winningInfo = "")
PB.field_numbers(::Type{WinningNumData}) = (; winningName = 1, winningInfo = 2)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{WinningNumData})
    winningName = ""
    winningInfo = ""
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            winningName = PB.decode(d, String)
        elseif field_number == 2
            winningInfo = PB.decode(d, String)
        else
            PB.skip(d, wire_type)
        end
    end
    return WinningNumData(winningName, winningInfo)
end

# A股IPO列表额外数据
mutable struct CNIpoExData
    applyCode::String              # 申购代码
    issueSize::Int64               # 发行总数
    onlineIssueSize::Int64         # 网上发行量
    applyUpperLimit::Int64         # 申购上限
    applyLimitMarketValue::Int64   # 顶格申购需配市值
    isEstimateIpoPrice::Bool       # 是否预估发行价
    ipoPrice::Float64              # 发行价
    industryPeRate::Float64        # 行业市盈率
    isEstimateWinningRatio::Bool   # 是否预估中签率
    winningRatio::Float64          # 中签率
    issuePeRate::Float64           # 发行市盈率
    applyTime::String              # 申购日期字符串
    applyTimestamp::Float64        # 申购日期时间戳
    winningTime::String            # 公布中签日期字符串
    winningTimestamp::Float64      # 公布中签日期时间戳
    isHasWon::Bool                 # 是否已经公布中签号
    winningNumData::Vector{WinningNumData}  # 中签号数据
end
CNIpoExData(; applyCode = "", issueSize = 0, onlineIssueSize = 0, applyUpperLimit = 0, applyLimitMarketValue = 0, isEstimateIpoPrice = false, ipoPrice = 0.0, industryPeRate = 0.0, isEstimateWinningRatio = false, winningRatio = 0.0, issuePeRate = 0.0, applyTime = "", applyTimestamp = 0.0, winningTime = "", winningTimestamp = 0.0, isHasWon = false, winningNumData = Vector{WinningNumData}()) = CNIpoExData(applyCode, issueSize, onlineIssueSize, applyUpperLimit, applyLimitMarketValue, isEstimateIpoPrice, ipoPrice, industryPeRate, isEstimateWinningRatio, winningRatio, issuePeRate, applyTime, applyTimestamp, winningTime, winningTimestamp, isHasWon, winningNumData)

PB.default_values(::Type{CNIpoExData}) = (; applyCode = "", issueSize = 0, onlineIssueSize = 0, applyUpperLimit = 0, applyLimitMarketValue = 0, isEstimateIpoPrice = false, ipoPrice = 0.0, industryPeRate = 0.0, isEstimateWinningRatio = false, winningRatio = 0.0, issuePeRate = 0.0, applyTime = "", applyTimestamp = 0.0, winningTime = "", winningTimestamp = 0.0, isHasWon = false, winningNumData = Vector{WinningNumData}())
PB.field_numbers(::Type{CNIpoExData}) = (; applyCode = 1, issueSize = 2, onlineIssueSize = 3, applyUpperLimit = 4, applyLimitMarketValue = 5, isEstimateIpoPrice = 6, ipoPrice = 7, industryPeRate = 8, isEstimateWinningRatio = 9, winningRatio = 10, issuePeRate = 11, applyTime = 12, applyTimestamp = 13, winningTime = 14, winningTimestamp = 15, isHasWon = 16, winningNumData = 17)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{CNIpoExData})
    applyCode = ""
    issueSize = 0
    onlineIssueSize = 0
    applyUpperLimit = 0
    applyLimitMarketValue = 0
    isEstimateIpoPrice = false
    ipoPrice = 0.0
    industryPeRate = 0.0
    isEstimateWinningRatio = false
    winningRatio = 0.0
    issuePeRate = 0.0
    applyTime = ""
    applyTimestamp = 0.0
    winningTime = ""
    winningTimestamp = 0.0
    isHasWon = false
    winningNumData = PB.BufferedVector{WinningNumData}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            applyCode = PB.decode(d, String)
        elseif field_number == 2
            issueSize = PB.decode(d, Int64)
        elseif field_number == 3
            onlineIssueSize = PB.decode(d, Int64)
        elseif field_number == 4
            applyUpperLimit = PB.decode(d, Int64)
        elseif field_number == 5
            applyLimitMarketValue = PB.decode(d, Int64)
        elseif field_number == 6
            isEstimateIpoPrice = PB.decode(d, Bool)
        elseif field_number == 7
            ipoPrice = PB.decode(d, Float64)
        elseif field_number == 8
            industryPeRate = PB.decode(d, Float64)
        elseif field_number == 9
            isEstimateWinningRatio = PB.decode(d, Bool)
        elseif field_number == 10
            winningRatio = PB.decode(d, Float64)
        elseif field_number == 11
            issuePeRate = PB.decode(d, Float64)
        elseif field_number == 12
            applyTime = PB.decode(d, String)
        elseif field_number == 13
            applyTimestamp = PB.decode(d, Float64)
        elseif field_number == 14
            winningTime = PB.decode(d, String)
        elseif field_number == 15
            winningTimestamp = PB.decode(d, Float64)
        elseif field_number == 16
            isHasWon = PB.decode(d, Bool)
        elseif field_number == 17
            PB.decode!(d, winningNumData)
        else
            PB.skip(d, wire_type)
        end
    end
    return CNIpoExData(applyCode, issueSize, onlineIssueSize, applyUpperLimit, applyLimitMarketValue, isEstimateIpoPrice, ipoPrice, industryPeRate, isEstimateWinningRatio, winningRatio, issuePeRate, applyTime, applyTimestamp, winningTime, winningTimestamp, isHasWon, winningNumData[])
end

# 港股IPO列表额外数据
mutable struct HKIpoExData
    ipoPriceMin::Float64      # 最低发售价
    ipoPriceMax::Float64      # 最高发售价
    listPrice::Float64        # 上市价
    lotSize::Int32            # 每手股数
    entrancePrice::Float64    # 入场费
    isSubscribeStatus::Bool   # 是否为认购状态
    applyEndTime::String      # 截止认购日期字符串
    applyEndTimestamp::Float64 # 截止认购日期时间戳
end
HKIpoExData(; ipoPriceMin = 0.0, ipoPriceMax = 0.0, listPrice = 0.0, lotSize = 0, entrancePrice = 0.0, isSubscribeStatus = false, applyEndTime = "", applyEndTimestamp = 0.0) = HKIpoExData(ipoPriceMin, ipoPriceMax, listPrice, lotSize, entrancePrice, isSubscribeStatus, applyEndTime, applyEndTimestamp)

PB.default_values(::Type{HKIpoExData}) = (; ipoPriceMin = 0.0, ipoPriceMax = 0.0, listPrice = 0.0, lotSize = 0, entrancePrice = 0.0, isSubscribeStatus = false, applyEndTime = "", applyEndTimestamp = 0.0)
PB.field_numbers(::Type{HKIpoExData}) = (; ipoPriceMin = 1, ipoPriceMax = 2, listPrice = 3, lotSize = 4, entrancePrice = 5, isSubscribeStatus = 6, applyEndTime = 7, applyEndTimestamp = 8)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{HKIpoExData})
    ipoPriceMin = 0.0
    ipoPriceMax = 0.0
    listPrice = 0.0
    lotSize = 0
    entrancePrice = 0.0
    isSubscribeStatus = false
    applyEndTime = ""
    applyEndTimestamp = 0.0
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            ipoPriceMin = PB.decode(d, Float64)
        elseif field_number == 2
            ipoPriceMax = PB.decode(d, Float64)
        elseif field_number == 3
            listPrice = PB.decode(d, Float64)
        elseif field_number == 4
            lotSize = PB.decode(d, Int32)
        elseif field_number == 5
            entrancePrice = PB.decode(d, Float64)
        elseif field_number == 6
            isSubscribeStatus = PB.decode(d, Bool)
        elseif field_number == 7
            applyEndTime = PB.decode(d, String)
        elseif field_number == 8
            applyEndTimestamp = PB.decode(d, Float64)
        else
            PB.skip(d, wire_type)
        end
    end
    return HKIpoExData(ipoPriceMin, ipoPriceMax, listPrice, lotSize, entrancePrice, isSubscribeStatus, applyEndTime, applyEndTimestamp)
end

# 美股IPO列表额外数据
mutable struct USIpoExData
    ipoPriceMin::Float64  # 最低发行价
    ipoPriceMax::Float64  # 最高发行价
    issueSize::Int64      # 发行量
end
USIpoExData(; ipoPriceMin = 0.0, ipoPriceMax = 0.0, issueSize = 0) = USIpoExData(ipoPriceMin, ipoPriceMax, issueSize)

PB.default_values(::Type{USIpoExData}) = (; ipoPriceMin = 0.0, ipoPriceMax = 0.0, issueSize = 0)
PB.field_numbers(::Type{USIpoExData}) = (; ipoPriceMin = 1, ipoPriceMax = 2, issueSize = 3)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{USIpoExData})
    ipoPriceMin = 0.0
    ipoPriceMax = 0.0
    issueSize = 0
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            ipoPriceMin = PB.decode(d, Float64)
        elseif field_number == 2
            ipoPriceMax = PB.decode(d, Float64)
        elseif field_number == 3
            issueSize = PB.decode(d, Int64)
        else
            PB.skip(d, wire_type)
        end
    end
    return USIpoExData(ipoPriceMin, ipoPriceMax, issueSize)
end

# 新股IPO数据
mutable struct IpoData
    basic::BasicIpoData        # IPO基本数据
    cnExData::CNIpoExData      # A股IPO额外数据
    hkExData::HKIpoExData      # 港股IPO额外数据
    usExData::USIpoExData      # 美股IPO额外数据
end
IpoData(; basic = BasicIpoData(), cnExData = CNIpoExData(), hkExData = HKIpoExData(), usExData = USIpoExData()) = IpoData(basic, cnExData, hkExData, usExData)

PB.default_values(::Type{IpoData}) = (; basic = BasicIpoData(), cnExData = CNIpoExData(), hkExData = HKIpoExData(), usExData = USIpoExData())
PB.field_numbers(::Type{IpoData}) = (; basic = 1, cnExData = 2, hkExData = 3, usExData = 4)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{IpoData})
    basic = BasicIpoData()
    cnExData = CNIpoExData()
    hkExData = HKIpoExData()
    usExData = USIpoExData()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            basic = PB.decode(d, Ref{BasicIpoData})
        elseif field_number == 2
            cnExData = PB.decode(d, Ref{CNIpoExData})
        elseif field_number == 3
            hkExData = PB.decode(d, Ref{HKIpoExData})
        elseif field_number == 4
            usExData = PB.decode(d, Ref{USIpoExData})
        else
            PB.skip(d, wire_type)
        end
    end
    return IpoData(basic, cnExData, hkExData, usExData)
end

# 客户端到服务端请求消息
mutable struct C2S
    market::Int32  # 股票市场，支持沪股和深股，且沪股和深股不做区分都代表A股市场
end
C2S(; market = Int32(0)) = C2S(Int32(market))

PB.default_values(::Type{C2S}) = (; market = Int32(0))
PB.field_numbers(::Type{C2S}) = (; market = 1)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    x.market != Int32(0) && PB.encode(e, 1, x.market)
    return position(e.io) - initpos
end

# 服务端到客户端响应消息
mutable struct S2C
    ipoList::Vector{IpoData}  # 新股IPO数据
end
S2C(; ipoList = Vector{IpoData}()) = S2C(ipoList)

PB.default_values(::Type{S2C}) = (; ipoList = Vector{IpoData}())
PB.field_numbers(::Type{S2C}) = (; ipoList = 1)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{S2C})
    ipoList = PB.BufferedVector{IpoData}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            PB.decode!(d, ipoList)
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(ipoList[])
end

# 请求消息
mutable struct Request
    c2s::C2S  # 客户端到服务端请求
end
Request(; c2s = C2S()) = Request(c2s)

PB.default_values(::Type{Request}) = (; c2s = C2S())
PB.field_numbers(::Type{Request}) = (; c2s = 1)
function PB.encode(e::PB.AbstractProtoEncoder, x::Request)
    initpos = position(e.io)
    PB.encode(e, 1, x.c2s)
    return position(e.io) - initpos
end

# 响应消息
mutable struct Response
    retType::Int32    # RetType,返回结果
    retMsg::String    # 返回消息
    errCode::Int32    # 错误码
    s2c::S2C          # 服务端到客户端响应
end
Response(; retType = Int32(Common.RetType.Unknown), retMsg = "", errCode = Int32(0), s2c = S2C()) = Response(retType, retMsg, errCode, s2c)

PB.default_values(::Type{Response}) = (; retType = Int32(Common.RetType.Unknown), retMsg = "", errCode = Int32(0), s2c = S2C())
PB.field_numbers(::Type{Response}) = (; retType = 1, retMsg = 2, errCode = 3, s2c = 4)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{Response})
    retType = Int32(Common.RetType.Unknown)
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
    return Response(retType, retMsg, errCode, s2c)
end

export BasicIpoData, WinningNumData, CNIpoExData, HKIpoExData, USIpoExData, IpoData, C2S, S2C, Request, Response

end
