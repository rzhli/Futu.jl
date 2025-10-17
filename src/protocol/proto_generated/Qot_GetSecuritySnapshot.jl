module Qot_GetSecuritySnapshot

import ProtoBuf as PB
import ..Common
import ..Qot_Common

mutable struct C2S
    securityList::Vector{Qot_Common.Security}
    C2S(; securityList = Vector{Qot_Common.Security}()) = new(securityList)
end
PB.default_values(::Type{C2S}) = (; securityList = Vector{Qot_Common.Security}())
PB.field_numbers(::Type{C2S}) = (; securityList = 1)
function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
    initpos = position(e.io)
    for security in x.securityList
        PB.encode(e, 1, security)
    end
    return position(e.io) - initpos
end

mutable struct EquitySnapshotExData
    issuedShares::Int64
    issuedMarketVal::Float64
    netAsset::Float64
    netProfit::Float64
    earningsPershare::Float64
    outstandingShares::Int64
    outstandingMarketVal::Float64
    netAssetPershare::Float64
    eyRate::Float64
    peRate::Float64
    pbRate::Float64
    peTTMRate::Float64
    dividendTTM::Float64
    dividendRatioTTM::Float64
    dividendLFY::Float64
    dividendLFYRatio::Float64
end
EquitySnapshotExData(; 
issuedShares = Int64(0), issuedMarketVal = 0.0, netAsset = 0.0, netProfit = 0.0, earningsPershare = 0.0, 
outstandingShares = Int64(0), outstandingMarketVal = 0.0, netAssetPershare = 0.0, eyRate = 0.0, peRate = 0.0, 
pbRate = 0.0, peTTMRate = 0.0, dividendTTM = 0.0, dividendRatioTTM = 0.0, dividendLFY = 0.0, dividendLFYRatio = 0.0
) = EquitySnapshotExData(issuedShares, issuedMarketVal, netAsset, netProfit, earningsPershare, outstandingShares, 
outstandingMarketVal, netAssetPershare, eyRate, peRate, pbRate, peTTMRate, dividendTTM, dividendRatioTTM, dividendLFY, dividendLFYRatio
)

PB.default_values(::Type{EquitySnapshotExData}) = (; issuedShares = Int64(0), issuedMarketVal = 0.0, netAsset = 0.0, netProfit = 0.0, earningsPershare = 0.0, outstandingShares = Int64(0), outstandingMarketVal = 0.0, netAssetPershare = 0.0, eyRate = 0.0, peRate = 0.0, pbRate = 0.0, peTTMRate = 0.0, dividendTTM = 0.0, dividendRatioTTM = 0.0, dividendLFY = 0.0, dividendLFYRatio = 0.0)
PB.field_numbers(::Type{EquitySnapshotExData}) = (issuedShares = 1, issuedMarketVal = 2, netAsset = 3, netProfit = 4, earningsPershare = 5, outstandingShares = 6, outstandingMarketVal = 7, netAssetPershare = 8, eyRate = 9, peRate = 10, pbRate = 11, peTTMRate = 12, dividendTTM = 13, dividendRatioTTM = 14, dividendLFY = 15, dividendLFYRatio = 16)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{EquitySnapshotExData})
    issuedShares = Int64(0)
    issuedMarketVal = 0.0
    netAsset = 0.0
    netProfit = 0.0
    earningsPershare = 0.0
    outstandingShares = Int64(0)
    outstandingMarketVal = 0.0
    netAssetPershare = 0.0
    eyRate = 0.0
    peRate = 0.0
    pbRate = 0.0
    peTTMRate = 0.0
    dividendTTM = 0.0
    dividendRatioTTM = 0.0
    dividendLFY = 0.0
    dividendLFYRatio = 0.0
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            issuedShares = PB.decode(d, Int64)
        elseif field_number == 2
            issuedMarketVal = PB.decode(d, Float64)
        elseif field_number == 3
            netAsset = PB.decode(d, Float64)
        elseif field_number == 4
            netProfit = PB.decode(d, Float64)
        elseif field_number == 5
            earningsPershare = PB.decode(d, Float64)
        elseif field_number == 6
            outstandingShares = PB.decode(d, Int64)
        elseif field_number == 7
            outstandingMarketVal = PB.decode(d, Float64)
        elseif field_number == 8
            netAssetPershare = PB.decode(d, Float64)
        elseif field_number == 9
            eyRate = PB.decode(d, Float64)
        elseif field_number == 10
            peRate = PB.decode(d, Float64)
        elseif field_number == 11
            pbRate = PB.decode(d, Float64)
        elseif field_number == 12
            peTTMRate = PB.decode(d, Float64)
        elseif field_number == 13
            dividendTTM = PB.decode(d, Float64)
        elseif field_number == 14
            dividendRatioTTM = PB.decode(d, Float64)
        elseif field_number == 15
            dividendLFY = PB.decode(d, Float64)
        elseif field_number == 16
            dividendLFYRatio = PB.decode(d, Float64)
        else
            PB.skip(d, wire_type)
        end
    end
    return EquitySnapshotExData(issuedShares, issuedMarketVal, netAsset, netProfit, earningsPershare, outstandingShares, outstandingMarketVal, 
    netAssetPershare, eyRate, peRate, pbRate, peTTMRate, dividendTTM, dividendRatioTTM, dividendLFY, dividendLFYRatio
    )
end
mutable struct WarrantSnapshotExData
    conversionRate::Float64
    warrantType::Int32
    strikePrice::Float64
    maturityTime::String
    endTradeTime::String
    owner::Qot_Common.Security
    recoveryPrice::Float64
    streetVolumn::Int64
    issueVolumn::Int64
    streetRate::Float64
    delta::Float64
    impliedVolatility::Float64
    premium::Float64
    maturityTimestamp::Float64
    endTradeTimestamp::Float64
    leverage::Float64
    ipop::Float64
    breakEvenPoint::Float64
    conversionPrice::Float64
    priceRecoveryRatio::Float64
    score::Float64
    upperStrikePrice::Float64
    lowerStrikePrice::Float64
    inLinePriceStatus::Int32
    issuerCode::String
    WarrantSnapshotExData(; conversionRate = 0, warrantType = 0, strikePrice = 0, maturityTime = "", endTradeTime = "", owner = Qot_Common.Security(), 
    recoveryPrice = 0, streetVolumn = 0, issueVolumn = 0, streetRate = 0, delta = 0, impliedVolatility = 0, premium = 0, maturityTimestamp = 0, endTradeTimestamp = 0, 
    leverage = 0, ipop = 0, breakEvenPoint = 0, conversionPrice = 0, priceRecoveryRatio = 0, score = 0, upperStrikePrice = 0, lowerStrikePrice = 0, inLinePriceStatus = 0, issuerCode = ""
    ) = new(conversionRate, warrantType, strikePrice, maturityTime, endTradeTime, owner, recoveryPrice, streetVolumn, issueVolumn, streetRate, delta, impliedVolatility, premium, 
    maturityTimestamp, endTradeTimestamp, leverage, ipop, breakEvenPoint, conversionPrice, priceRecoveryRatio, score, upperStrikePrice, lowerStrikePrice, inLinePriceStatus, issuerCode
    )
end
PB.field_numbers(::Type{WarrantSnapshotExData}) = (conversionRate = 1, warrantType = 2, strikePrice = 3, maturityTime = 4, endTradeTime = 5, owner = 6, recoveryPrice = 7, streetVolumn = 8, 
issueVolumn = 9, streetRate = 10, delta = 11, impliedVolatility = 12, premium = 13, maturityTimestamp = 14, endTradeTimestamp = 15, leverage = 16, ipop = 17, breakEvenPoint = 18, conversionPrice = 19, 
priceRecoveryRatio = 20, score = 21, upperStrikePrice = 22, lowerStrikePrice = 23, inLinePriceStatus = 24, issuerCode = 25
)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{WarrantSnapshotExData})
    conversionRate = 0.0
    warrantType = Int32(0)
    strikePrice = 0.0
    maturityTime = ""
    endTradeTime = ""
    owner = Qot_Common.Security()
    recoveryPrice = 0.0
    streetVolumn = Int64(0)
    issueVolumn = Int64(0)
    streetRate = 0.0
    delta = 0.0
    impliedVolatility = 0.0
    premium = 0.0
    maturityTimestamp = 0.0
    endTradeTimestamp = 0.0
    leverage = 0.0
    ipop = 0.0
    breakEvenPoint = 0.0
    conversionPrice = 0.0
    priceRecoveryRatio = 0.0
    score = 0.0
    upperStrikePrice = 0.0
    lowerStrikePrice = 0.0
    inLinePriceStatus = Int32(0)
    issuerCode = ""
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            conversionRate = PB.decode(d, Float64)
        elseif field_number == 2
            warrantType = PB.decode(d, Int32)
        elseif field_number == 3
            strikePrice = PB.decode(d, Float64)
        elseif field_number == 4
            maturityTime = PB.decode(d, String)
        elseif field_number == 5
            endTradeTime = PB.decode(d, String)
        elseif field_number == 6
            owner = PB.decode(d, Ref{Qot_Common.Security})
        elseif field_number == 7
            recoveryPrice = PB.decode(d, Float64)
        elseif field_number == 8
            streetVolumn = PB.decode(d, Int64)
        elseif field_number == 9
            issueVolumn = PB.decode(d, Int64)
        elseif field_number == 10
            streetRate = PB.decode(d, Float64)
        elseif field_number == 11
            delta = PB.decode(d, Float64)
        elseif field_number == 12
            impliedVolatility = PB.decode(d, Float64)
        elseif field_number == 13
            premium = PB.decode(d, Float64)
        elseif field_number == 14
            maturityTimestamp = PB.decode(d, Float64)
        elseif field_number == 15
            endTradeTimestamp = PB.decode(d, Float64)
        elseif field_number == 16
            leverage = PB.decode(d, Float64)
        elseif field_number == 17
            ipop = PB.decode(d, Float64)
        elseif field_number == 18
            breakEvenPoint = PB.decode(d, Float64)
        elseif field_number == 19
            conversionPrice = PB.decode(d, Float64)
        elseif field_number == 20
            priceRecoveryRatio = PB.decode(d, Float64)
        elseif field_number == 21
            score = PB.decode(d, Float64)
        elseif field_number == 22
            upperStrikePrice = PB.decode(d, Float64)
        elseif field_number == 23
            lowerStrikePrice = PB.decode(d, Float64)
        elseif field_number == 24
            inLinePriceStatus = PB.decode(d, Int32)
        elseif field_number == 25
            issuerCode = PB.decode(d, String)
        else
            PB.skip(d, wire_type)
        end
    end
    return WarrantSnapshotExData(; conversionRate = conversionRate, warrantType = warrantType, strikePrice = strikePrice, maturityTime = maturityTime,
        endTradeTime = endTradeTime, owner = owner, recoveryPrice = recoveryPrice, streetVolumn = streetVolumn, issueVolumn = issueVolumn,
        streetRate = streetRate, delta = delta, impliedVolatility = impliedVolatility, premium = premium, maturityTimestamp = maturityTimestamp,
        endTradeTimestamp = endTradeTimestamp, leverage = leverage, ipop = ipop, breakEvenPoint = breakEvenPoint, conversionPrice = conversionPrice,
        priceRecoveryRatio = priceRecoveryRatio, score = score, upperStrikePrice = upperStrikePrice, lowerStrikePrice = lowerStrikePrice,
        inLinePriceStatus = inLinePriceStatus, issuerCode = issuerCode
    )
end


mutable struct OptionSnapshotExData
    type::Int32
    owner::Qot_Common.Security
    strikeTime::String
    strikePrice::Float64
    contractSize::Int32
    contractSizeFloat::Float64
    openInterest::Int32
    impliedVolatility::Float64
    premium::Float64
    delta::Float64
    gamma::Float64
    vega::Float64
    theta::Float64
    rho::Float64
    strikeTimestamp::Float64
    indexOptionType::Int32
    netOpenInterest::Int32
    expiryDateDistance::Int32
    contractNominalValue::Float64
    ownerLotMultiplier::Float64
    optionAreaType::Int32
    contractMultiplier::Float64
    OptionSnapshotExData(; type = 0, owner = Qot_Common.Security(), strikeTime = "", strikePrice = 0, contractSize = 0, contractSizeFloat = 0, 
    openInterest = 0, impliedVolatility = 0, premium = 0, delta = 0, gamma = 0, vega = 0, theta = 0, rho = 0, strikeTimestamp = 0, indexOptionType = 0, 
    netOpenInterest = 0, expiryDateDistance = 0, contractNominalValue = 0, ownerLotMultiplier = 0, optionAreaType = 0, contractMultiplier = 0
    ) = new(type, owner, strikeTime, strikePrice, contractSize, contractSizeFloat, openInterest, impliedVolatility, premium, delta, gamma, vega, 
    theta, rho, strikeTimestamp, indexOptionType, netOpenInterest, expiryDateDistance, contractNominalValue, ownerLotMultiplier, optionAreaType, contractMultiplier
    )
end
PB.field_numbers(::Type{OptionSnapshotExData}) = (type = 1, owner = 2, strikeTime = 3, strikePrice = 4, contractSize = 5, openInterest = 6, impliedVolatility = 7, 
premium = 8, delta = 9, gamma = 10, vega = 11, theta = 12, rho = 13, strikeTimestamp = 14, indexOptionType = 15, netOpenInterest = 16, expiryDateDistance = 17, 
contractNominalValue = 18, ownerLotMultiplier = 19, optionAreaType = 20, contractMultiplier = 21, contractSizeFloat = 22
)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{OptionSnapshotExData})
    type = Int32(0)
    owner = Qot_Common.Security()
    strikeTime = ""
    strikePrice = 0.0
    contractSize = Int32(0)
    contractSizeFloat = 0.0
    openInterest = Int32(0)
    impliedVolatility = 0.0
    premium = 0.0
    delta = 0.0
    gamma = 0.0
    vega = 0.0
    theta = 0.0
    rho = 0.0
    strikeTimestamp = 0.0
    indexOptionType = Int32(0)
    netOpenInterest = Int32(0)
    expiryDateDistance = Int32(0)
    contractNominalValue = 0.0
    ownerLotMultiplier = 0.0
    optionAreaType = Int32(0)
    contractMultiplier = 0.0
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            type = PB.decode(d, Int32)
        elseif field_number == 2
            owner = PB.decode(d, Ref{Qot_Common.Security})
        elseif field_number == 3
            strikeTime = PB.decode(d, String)
        elseif field_number == 4
            strikePrice = PB.decode(d, Float64)
        elseif field_number == 5
            contractSize = PB.decode(d, Int32)
        elseif field_number == 6
            openInterest = PB.decode(d, Int32)
        elseif field_number == 7
            impliedVolatility = PB.decode(d, Float64)
        elseif field_number == 8
            premium = PB.decode(d, Float64)
        elseif field_number == 9
            delta = PB.decode(d, Float64)
        elseif field_number == 10
            gamma = PB.decode(d, Float64)
        elseif field_number == 11
            vega = PB.decode(d, Float64)
        elseif field_number == 12
            theta = PB.decode(d, Float64)
        elseif field_number == 13
            rho = PB.decode(d, Float64)
        elseif field_number == 14
            strikeTimestamp = PB.decode(d, Float64)
        elseif field_number == 15
            indexOptionType = PB.decode(d, Int32)
        elseif field_number == 16
            netOpenInterest = PB.decode(d, Int32)
        elseif field_number == 17
            expiryDateDistance = PB.decode(d, Int32)
        elseif field_number == 18
            contractNominalValue = PB.decode(d, Float64)
        elseif field_number == 19
            ownerLotMultiplier = PB.decode(d, Float64)
        elseif field_number == 20
            optionAreaType = PB.decode(d, Int32)
        elseif field_number == 21
            contractMultiplier = PB.decode(d, Float64)
        elseif field_number == 22
            contractSizeFloat = PB.decode(d, Float64)
        else
            PB.skip(d, wire_type)
        end
    end
    return OptionSnapshotExData(; type = type, owner = owner, strikeTime = strikeTime, strikePrice = strikePrice, contractSize = contractSize,
        contractSizeFloat = contractSizeFloat, openInterest = openInterest, impliedVolatility = impliedVolatility, premium = premium,
        delta = delta, gamma = gamma, vega = vega, theta = theta, rho = rho, strikeTimestamp = strikeTimestamp, indexOptionType = indexOptionType,
        netOpenInterest = netOpenInterest, expiryDateDistance = expiryDateDistance, contractNominalValue = contractNominalValue,
        ownerLotMultiplier = ownerLotMultiplier, optionAreaType = optionAreaType, contractMultiplier = contractMultiplier
    )
end

mutable struct IndexSnapshotExData
    raiseCount::Int32
    fallCount::Int32
    equalCount::Int32
end
IndexSnapshotExData() = IndexSnapshotExData(Int32(0), Int32(0), Int32(0))
PB.field_numbers(::Type{IndexSnapshotExData}) = (raiseCount = 1, fallCount = 2, equalCount = 3)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{IndexSnapshotExData})
    raiseCount = Int32(0)
    fallCount = Int32(0)
    equalCount = Int32(0)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            raiseCount = PB.decode(d, Int32)
        elseif field_number == 2
            fallCount = PB.decode(d, Int32)
        elseif field_number == 3
            equalCount = PB.decode(d, Int32)
        else
            PB.skip(d, wire_type)
        end
    end
    return IndexSnapshotExData(raiseCount, fallCount, equalCount)
end

mutable struct PlateSnapshotExData
    raiseCount::Int32
    fallCount::Int32
    equalCount::Int32
end
PlateSnapshotExData() = PlateSnapshotExData(Int32(0), Int32(0), Int32(0))
PB.field_numbers(::Type{PlateSnapshotExData}) = (raiseCount = 1, fallCount = 2, equalCount = 3)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{PlateSnapshotExData})
    raiseCount = Int32(0)
    fallCount = Int32(0)
    equalCount = Int32(0)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            raiseCount = PB.decode(d, Int32)
        elseif field_number == 2
            fallCount = PB.decode(d, Int32)
        elseif field_number == 3
            equalCount = PB.decode(d, Int32)
        else
            PB.skip(d, wire_type)
        end
    end
    return PlateSnapshotExData(raiseCount, fallCount, equalCount)
end

mutable struct FutureSnapshotExData
    lastSettlePrice::Float64
    position::Int32
    positionChange::Int32
    lastTradeTime::String
    lastTradeTimestamp::Float64
    isMainContract::Bool
end
FutureSnapshotExData() = FutureSnapshotExData(0.0, Int32(0), Int32(0), "", 0.0, false)
PB.field_numbers(::Type{FutureSnapshotExData}) = (lastSettlePrice = 1, position = 2, positionChange = 3, lastTradeTime = 4, lastTradeTimestamp = 5, isMainContract = 6)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{FutureSnapshotExData})
    lastSettlePrice = 0.0
    position = Int32(0)
    positionChange = Int32(0)
    lastTradeTime = ""
    lastTradeTimestamp = 0.0
    isMainContract = false
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            lastSettlePrice = PB.decode(d, Float64)
        elseif field_number == 2
            position = PB.decode(d, Int32)
        elseif field_number == 3
            positionChange = PB.decode(d, Int32)
        elseif field_number == 4
            lastTradeTime = PB.decode(d, String)
        elseif field_number == 5
            lastTradeTimestamp = PB.decode(d, Float64)
        elseif field_number == 6
            isMainContract = PB.decode(d, Bool)
        else
            PB.skip(d, wire_type)
        end
    end
    return FutureSnapshotExData(lastSettlePrice, position, positionChange, lastTradeTime, lastTradeTimestamp, isMainContract)
end

mutable struct TrustSnapshotExData
    dividendYield::Float64
    aum::Float64
    outstandingUnits::Int64
    netAssetValue::Float64
    premium::Float64
    assetClass::Int32
end
TrustSnapshotExData() = TrustSnapshotExData(0.0, 0.0, Int64(0), 0.0, 0.0, Int32(0))
PB.field_numbers(::Type{TrustSnapshotExData}) = (dividendYield = 1, aum = 2, outstandingUnits = 3, netAssetValue = 4, premium = 5, assetClass = 6)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{TrustSnapshotExData})
    dividendYield = 0.0
    aum = 0.0
    outstandingUnits = Int64(0)
    netAssetValue = 0.0
    premium = 0.0
    assetClass = Int32(0)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            dividendYield = PB.decode(d, Float64)
        elseif field_number == 2
            aum = PB.decode(d, Float64)
        elseif field_number == 3
            outstandingUnits = PB.decode(d, Int64)
        elseif field_number == 4
            netAssetValue = PB.decode(d, Float64)
        elseif field_number == 5
            premium = PB.decode(d, Float64)
        elseif field_number == 6
            assetClass = PB.decode(d, Int32)
        else
            PB.skip(d, wire_type)
        end
    end
    return TrustSnapshotExData(dividendYield, aum, outstandingUnits, netAssetValue, premium, assetClass)
end

mutable struct SnapshotBasicData
    security::Qot_Common.Security
    name::String
    type::Int32
    isSuspend::Bool
    listTime::String
    lotSize::Int32
    priceSpread::Float64
    updateTime::String
    highPrice::Float64
    openPrice::Float64
    lowPrice::Float64
    lastClosePrice::Float64
    curPrice::Float64
    volume::Int64
    turnover::Float64
    turnoverRate::Float64
    listTimestamp::Float64
    updateTimestamp::Float64
    askPrice::Float64
    bidPrice::Float64
    askVol::Int64
    bidVol::Int64
    enableMargin::Bool
    mortgageRatio::Float64
    longMarginInitialRatio::Float64
    enableShortSell::Bool
    shortSellRate::Float64
    shortAvailableVolume::Int64
    shortMarginInitialRatio::Float64
    amplitude::Float64
    avgPrice::Float64
    bidAskRatio::Float64
    volumeRatio::Float64
    highest52WeeksPrice::Float64
    lowest52WeeksPrice::Float64
    highestHistoryPrice::Float64
    lowestHistoryPrice::Float64
    preMarket::Qot_Common.PreAfterMarketData
    afterMarket::Qot_Common.PreAfterMarketData
    secStatus::Int32
    closePrice5Minute::Float64
    overnight::Qot_Common.PreAfterMarketData
    SnapshotBasicData(; security = Qot_Common.Security(), name = "", type = Int32(0), isSuspend = false, listTime = "", lotSize = Int32(0),
        priceSpread = 0.0, updateTime = "", highPrice = 0.0, openPrice = 0.0, lowPrice = 0.0, lastClosePrice = 0.0, curPrice = 0.0,
        volume = Int64(0), turnover = 0.0, turnoverRate = 0.0, listTimestamp = 0.0, updateTimestamp = 0.0, askPrice = 0.0,
        bidPrice = 0.0, askVol = Int64(0), bidVol = Int64(0), enableMargin = false, mortgageRatio = 0.0,
        longMarginInitialRatio = 0.0, enableShortSell = false, shortSellRate = 0.0, shortAvailableVolume = Int64(0),
        shortMarginInitialRatio = 0.0, amplitude = 0.0, avgPrice = 0.0, bidAskRatio = 0.0, volumeRatio = 0.0,
        highest52WeeksPrice = 0.0, lowest52WeeksPrice = 0.0, highestHistoryPrice = 0.0, lowestHistoryPrice = 0.0,
        preMarket = Qot_Common.PreAfterMarketData(), afterMarket = Qot_Common.PreAfterMarketData(), secStatus = Int32(0),
        closePrice5Minute = 0.0, overnight = Qot_Common.PreAfterMarketData()
    ) = new(security, name, type, isSuspend, listTime, lotSize, priceSpread, updateTime, highPrice, openPrice, lowPrice,
        lastClosePrice, curPrice, volume, turnover, turnoverRate, listTimestamp, updateTimestamp, askPrice, bidPrice, askVol, bidVol,
        enableMargin, mortgageRatio, longMarginInitialRatio, enableShortSell, shortSellRate, shortAvailableVolume, shortMarginInitialRatio,
        amplitude, avgPrice, bidAskRatio, volumeRatio, highest52WeeksPrice, lowest52WeeksPrice, highestHistoryPrice, lowestHistoryPrice,
        preMarket, afterMarket, secStatus, closePrice5Minute, overnight
    )
end
PB.default_values(::Type{SnapshotBasicData}) = (; 
security = Qot_Common.Security(), name = "", type = 0, isSuspend = false, listTime = "", lotSize = 0, priceSpread = 0.0, 
updateTime = "", highPrice = 0.0, openPrice = 0.0, lowPrice = 0.0, lastClosePrice = 0.0, curPrice = 0.0, volume = 0, 
turnover = 0.0, turnoverRate = 0.0, listTimestamp = 0.0, updateTimestamp = 0.0, askPrice = 0.0, bidPrice = 0.0, askVol = 0, 
bidVol = 0, enableMargin = false, mortgageRatio = 0.0, longMarginInitialRatio = 0.0, enableShortSell = false, shortSellRate = 0.0, 
shortAvailableVolume = 0, shortMarginInitialRatio = 0.0, amplitude = 0.0, avgPrice = 0.0, bidAskRatio = 0.0, volumeRatio = 0.0, 
highest52WeeksPrice = 0.0, lowest52WeeksPrice = 0.0, highestHistoryPrice = 0.0, lowestHistoryPrice = 0.0, preMarket = Qot_Common.PreAfterMarketData(), 
afterMarket = Qot_Common.PreAfterMarketData(), secStatus = 0, closePrice5Minute = 0.0, overnight = Qot_Common.PreAfterMarketData()
)
PB.field_numbers(::Type{SnapshotBasicData}) = (security = 1, type = 2, isSuspend = 3, listTime = 4, lotSize = 5, priceSpread = 6,
updateTime = 7, highPrice = 8, openPrice = 9, lowPrice = 10, lastClosePrice = 11, curPrice = 12, volume = 13, turnover = 14, turnoverRate = 15,
listTimestamp = 16, updateTimestamp = 17, askPrice = 18, bidPrice = 19, askVol = 20, bidVol = 21, enableMargin = 22, mortgageRatio = 23,
longMarginInitialRatio = 24, enableShortSell = 25, shortSellRate = 26, shortAvailableVolume = 27, shortMarginInitialRatio = 28, amplitude = 29,
avgPrice = 30, bidAskRatio = 31, volumeRatio = 32, highest52WeeksPrice = 33, lowest52WeeksPrice = 34, highestHistoryPrice = 35, lowestHistoryPrice = 36,
preMarket = 37, afterMarket = 38, secStatus = 39, closePrice5Minute = 40, name = 41, overnight = 42)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{SnapshotBasicData})
    security = Qot_Common.Security()
    name = ""
    type = Int32(0)
    isSuspend = false
    listTime = ""
    lotSize = Int32(0)
    priceSpread = 0.0
    updateTime = ""
    highPrice = 0.0
    openPrice = 0.0
    lowPrice = 0.0
    lastClosePrice = 0.0
    curPrice = 0.0
    volume = Int64(0)
    turnover = 0.0
    turnoverRate = 0.0
    listTimestamp = 0.0
    updateTimestamp = 0.0
    askPrice = 0.0
    bidPrice = 0.0
    askVol = Int64(0)
    bidVol = Int64(0)
    enableMargin = false
    mortgageRatio = 0.0
    longMarginInitialRatio = 0.0
    enableShortSell = false
    shortSellRate = 0.0
    shortAvailableVolume = Int64(0)
    shortMarginInitialRatio = 0.0
    amplitude = 0.0
    avgPrice = 0.0
    bidAskRatio = 0.0
    volumeRatio = 0.0
    highest52WeeksPrice = 0.0
    lowest52WeeksPrice = 0.0
    highestHistoryPrice = 0.0
    lowestHistoryPrice = 0.0
    preMarket = Qot_Common.PreAfterMarketData()
    afterMarket = Qot_Common.PreAfterMarketData()
    secStatus = Int32(0)
    closePrice5Minute = 0.0
    overnight = Qot_Common.PreAfterMarketData()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            security = PB.decode(d, Ref{Qot_Common.Security})
        elseif field_number == 2
            type = PB.decode(d, Int32)
        elseif field_number == 3
            isSuspend = PB.decode(d, Bool)
        elseif field_number == 4
            listTime = PB.decode(d, String)
        elseif field_number == 5
            lotSize = PB.decode(d, Int32)
        elseif field_number == 6
            priceSpread = PB.decode(d, Float64)
        elseif field_number == 7
            updateTime = PB.decode(d, String)
        elseif field_number == 8
            highPrice = PB.decode(d, Float64)
        elseif field_number == 9
            openPrice = PB.decode(d, Float64)
        elseif field_number == 10
            lowPrice = PB.decode(d, Float64)
        elseif field_number == 11
            lastClosePrice = PB.decode(d, Float64)
        elseif field_number == 12
            curPrice = PB.decode(d, Float64)
        elseif field_number == 13
            volume = PB.decode(d, Int64)
        elseif field_number == 14
            turnover = PB.decode(d, Float64)
        elseif field_number == 15
            turnoverRate = PB.decode(d, Float64)
        elseif field_number == 16
            listTimestamp = PB.decode(d, Float64)
        elseif field_number == 17
            updateTimestamp = PB.decode(d, Float64)
        elseif field_number == 18
            askPrice = PB.decode(d, Float64)
        elseif field_number == 19
            bidPrice = PB.decode(d, Float64)
        elseif field_number == 20
            askVol = PB.decode(d, Int64)
        elseif field_number == 21
            bidVol = PB.decode(d, Int64)
        elseif field_number == 22
            enableMargin = PB.decode(d, Bool)
        elseif field_number == 23
            mortgageRatio = PB.decode(d, Float64)
        elseif field_number == 24
            longMarginInitialRatio = PB.decode(d, Float64)
        elseif field_number == 25
            enableShortSell = PB.decode(d, Bool)
        elseif field_number == 26
            shortSellRate = PB.decode(d, Float64)
        elseif field_number == 27
            shortAvailableVolume = PB.decode(d, Int64)
        elseif field_number == 28
            shortMarginInitialRatio = PB.decode(d, Float64)
        elseif field_number == 29
            amplitude = PB.decode(d, Float64)
        elseif field_number == 30
            avgPrice = PB.decode(d, Float64)
        elseif field_number == 31
            bidAskRatio = PB.decode(d, Float64)
        elseif field_number == 32
            volumeRatio = PB.decode(d, Float64)
        elseif field_number == 33
            highest52WeeksPrice = PB.decode(d, Float64)
        elseif field_number == 34
            lowest52WeeksPrice = PB.decode(d, Float64)
        elseif field_number == 35
            highestHistoryPrice = PB.decode(d, Float64)
        elseif field_number == 36
            lowestHistoryPrice = PB.decode(d, Float64)
        elseif field_number == 37
            preMarket = PB.decode(d, Ref{Qot_Common.PreAfterMarketData})
        elseif field_number == 38
            afterMarket = PB.decode(d, Ref{Qot_Common.PreAfterMarketData})
        elseif field_number == 39
            secStatus = PB.decode(d, Int32)
        elseif field_number == 40
            closePrice5Minute = PB.decode(d, Float64)
        elseif field_number == 41
            name = PB.decode(d, String)
        elseif field_number == 42
            overnight = PB.decode(d, Ref{Qot_Common.PreAfterMarketData})
        else
            PB.skip(d, wire_type)
        end
    end
    return SnapshotBasicData(security = security, name = name, type = type, isSuspend = isSuspend, listTime = listTime, lotSize = lotSize,
        priceSpread = priceSpread, updateTime = updateTime, highPrice = highPrice, openPrice = openPrice, lowPrice = lowPrice, lastClosePrice = lastClosePrice,
        curPrice = curPrice, volume = volume, turnover = turnover, turnoverRate = turnoverRate, listTimestamp = listTimestamp, updateTimestamp = updateTimestamp,
        askPrice = askPrice, bidPrice = bidPrice, askVol = askVol, bidVol = bidVol, enableMargin = enableMargin, mortgageRatio = mortgageRatio, longMarginInitialRatio = longMarginInitialRatio,
        enableShortSell = enableShortSell, shortSellRate = shortSellRate, shortAvailableVolume = shortAvailableVolume, shortMarginInitialRatio = shortMarginInitialRatio,
        amplitude = amplitude, avgPrice = avgPrice, bidAskRatio = bidAskRatio, volumeRatio = volumeRatio, highest52WeeksPrice = highest52WeeksPrice,
        lowest52WeeksPrice = lowest52WeeksPrice, highestHistoryPrice = highestHistoryPrice, lowestHistoryPrice = lowestHistoryPrice, preMarket = preMarket,
        afterMarket = afterMarket, secStatus = secStatus, closePrice5Minute = closePrice5Minute, overnight = overnight
    )
end

mutable struct Snapshot
    basic::SnapshotBasicData
    equityExData::EquitySnapshotExData
    warrantExData::WarrantSnapshotExData
    optionExData::OptionSnapshotExData
    indexExData::IndexSnapshotExData
    plateExData::PlateSnapshotExData
    futureExData::FutureSnapshotExData
    trustExData::TrustSnapshotExData
    Snapshot(; 
    basic = SnapshotBasicData(), equityExData = EquitySnapshotExData(), warrantExData = WarrantSnapshotExData(), 
    optionExData = OptionSnapshotExData(), indexExData = IndexSnapshotExData(), plateExData = PlateSnapshotExData(), 
    futureExData = FutureSnapshotExData(), trustExData = TrustSnapshotExData()) = new(basic, equityExData, warrantExData, 
    optionExData, indexExData, plateExData, futureExData, trustExData
    )
end
PB.default_values(::Type{Snapshot}) = (; basic = SnapshotBasicData(), equityExData = EquitySnapshotExData(), warrantExData = WarrantSnapshotExData(), optionExData = OptionSnapshotExData(), indexExData = IndexSnapshotExData(), plateExData = PlateSnapshotExData(), futureExData = FutureSnapshotExData(), trustExData = TrustSnapshotExData())
PB.field_numbers(::Type{Snapshot}) = (basic = 1, equityExData = 2, warrantExData = 3, optionExData = 4, indexExData = 5, plateExData = 6, futureExData = 7, trustExData = 8)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{Snapshot})
    basic = SnapshotBasicData()
    equityExData = EquitySnapshotExData()
    warrantExData = WarrantSnapshotExData()
    optionExData = OptionSnapshotExData()
    indexExData = IndexSnapshotExData()
    plateExData = PlateSnapshotExData()
    futureExData = FutureSnapshotExData()
    trustExData = TrustSnapshotExData()
    equity_set = false
    warrant_set = false
    option_set = false
    index_set = false
    plate_set = false
    future_set = false
    trust_set = false
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            basic = PB.decode(d, Ref{SnapshotBasicData})
        elseif field_number == 2
            equityExData = PB.decode(d, Ref{EquitySnapshotExData})
            equity_set = true
        elseif field_number == 3
            warrantExData = PB.decode(d, Ref{WarrantSnapshotExData})
            warrant_set = true
        elseif field_number == 4
            optionExData = PB.decode(d, Ref{OptionSnapshotExData})
            option_set = true
        elseif field_number == 5
            indexExData = PB.decode(d, Ref{IndexSnapshotExData})
            index_set = true
        elseif field_number == 6
            plateExData = PB.decode(d, Ref{PlateSnapshotExData})
            plate_set = true
        elseif field_number == 7
            futureExData = PB.decode(d, Ref{FutureSnapshotExData})
            future_set = true
        elseif field_number == 8
            trustExData = PB.decode(d, Ref{TrustSnapshotExData})
            trust_set = true
        else
            PB.skip(d, wire_type)
        end
    end
    equityExData_final = equity_set ? equityExData : EquitySnapshotExData()
    warrantExData_final = warrant_set ? warrantExData : WarrantSnapshotExData()
    optionExData_final = option_set ? optionExData : OptionSnapshotExData()
    indexExData_final = index_set ? indexExData : IndexSnapshotExData()
    plateExData_final = plate_set ? plateExData : PlateSnapshotExData()
    futureExData_final = future_set ? futureExData : FutureSnapshotExData()
    trustExData_final = trust_set ? trustExData : TrustSnapshotExData()
    return Snapshot(basic = basic, equityExData = equityExData_final, warrantExData = warrantExData_final, optionExData = optionExData_final, indexExData = indexExData_final, plateExData = plateExData_final, futureExData = futureExData_final, trustExData = trustExData_final)
end

mutable struct S2C
    snapshotList::Vector{Snapshot}
    S2C(; snapshotList = Vector{Snapshot}()) = new(snapshotList)
end
PB.default_values(::Type{S2C}) = (; snapshotList = Vector{Snapshot}())
PB.field_numbers(::Type{S2C}) = (; snapshotList = 1)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{S2C})
    snapshotList = Vector{Snapshot}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            push!(snapshotList, PB.decode(d, Ref{Snapshot}))
        else
            PB.skip(d, wire_type)
        end
    end
    return S2C(; snapshotList = snapshotList)
end

mutable struct Request
    c2s::C2S
    Request(; c2s = C2S()) = new(c2s)
end
PB.default_values(::Type{Request}) = (; c2s = C2S())
PB.field_numbers(::Type{Request}) = (; c2s = 1)
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
    Response(; retType = -400, retMsg = "", errCode = 0, s2c = S2C()) = new(retType, retMsg, errCode, s2c)
end
PB.default_values(::Type{Response}) = (; retType = -400, retMsg = "", errCode = 0, s2c = S2C())
PB.field_numbers(::Type{Response}) = (; retType = 1, retMsg = 2, errCode = 3, s2c = 4)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{Response})
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

export C2S, EquitySnapshotExData, WarrantSnapshotExData, OptionSnapshotExData, IndexSnapshotExData, PlateSnapshotExData, FutureSnapshotExData, TrustSnapshotExData, SnapshotBasicData, Snapshot, S2C, Request, Response

end
