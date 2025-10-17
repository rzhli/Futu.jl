module Common

import ProtoBuf as PB
using ProtoBuf.EnumX

@enumx RetType begin
    Succeed = 0
    Failed = -1
    TimeOut = -100
    DisConnect = -200
    Unknown = -400
    Invalid = -500
end

@enumx PacketEncAlgo begin
    FTAES_ECB = 0
    None = -1
    AES_ECB = 1
    AES_CBC = 2
end

@enumx ProtoFmt begin
    Protobuf = 0
    Json = 1
end

@enumx UserAttribution begin
    Unknown = 0
    NN = 1
    MM = 2
    SG = 3
    AU = 4
    JP = 5
    HK = 6
end

@enumx ProgramStatusType begin
    None = 0
    Loaded = 1
    Loging = 2
    NeedPicVerifyCode = 3
    NeedPhoneVerifyCode = 4
    LoginFailed = 5
    ForceUpdate = 6
    NessaryDataPreparing = 7
    NessaryDataMissing = 8
    UnAgreeDisclaimer = 9
    Ready = 10
    ForceLogout = 11
    DisclaimerPullFailed = 12
end

@enumx Session begin
    NONE = 0
    RTH = 1
    ETH = 2
    ALL = 3
    OVERNIGHT = 4
end

struct PacketID
    connID::UInt64
    serialNo::UInt32
end
PacketID() = PacketID(zero(UInt64), zero(UInt32))
PB.default_values(::Type{PacketID}) = (;connID = zero(UInt64), serialNo = zero(UInt32))
PB.field_numbers(::Type{PacketID}) = (;connID = 1, serialNo = 2)
function PB.encode(e::PB.AbstractProtoEncoder, x::PacketID)
    initpos = position(e.io)
    PB.encode(e, 1, x.connID)
    PB.encode(e, 2, x.serialNo)
    return position(e.io) - initpos
end

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:PacketID})
    connID = zero(UInt64)
    serialNo = zero(UInt32)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            connID = PB.decode(d, UInt64)
        elseif field_number == 2
            serialNo = PB.decode(d, UInt32)
        else
            PB.skip(d, wire_type)
        end
    end
    return PacketID(connID, serialNo)
end

struct ProgramStatus
    type::ProgramStatusType.T
    strExtDesc::String
end
ProgramStatus() = ProgramStatus(ProgramStatusType.None, "")
PB.default_values(::Type{ProgramStatus}) = (;type = ProgramStatusType.None, strExtDesc = "")
PB.field_numbers(::Type{ProgramStatus}) = (;type = 1, strExtDesc = 2)
function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:ProgramStatus})
    type = ProgramStatusType.None
    strExtDesc = ""
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            type = PB.decode(d, ProgramStatusType.T)
        elseif field_number == 2
            strExtDesc = PB.decode(d, String)
        else
            PB.skip(d, wire_type)
        end
    end
    return ProgramStatus(type, strExtDesc)
end

# Custom display methods
function Base.show(io::IO, ps::ProgramStatus)
    type_str = string(ps.type)
    # Remove the module prefix for cleaner display
    type_str = replace(type_str, "ProgramStatusType." => "")
    if isempty(ps.strExtDesc)
        print(io, "ProgramStatus(", type_str, ")")
    else
        print(io, "ProgramStatus(", type_str, ", \"", ps.strExtDesc, "\")")
    end
end

# Format program status for user-friendly display
function format_program_status(ps::ProgramStatus)
    # Use EnumX's symbol function to get the enum name
    label = string(Symbol(ps.type))
    # Remove the prefix for cleaner display
    label = replace(label, "ProgramStatusType_" => "")
    # Convert to more readable format (e.g., "NeedPicVerifyCode" -> "Need Pic Verify Code")
    label = replace(label, r"([a-z])([A-Z])" => s"\1 \2")
    return isempty(ps.strExtDesc) ? label : string(label, " (", ps.strExtDesc, ")")
end

export RetType, PacketEncAlgo, ProtoFmt, UserAttribution, ProgramStatusType, Session, PacketID, ProgramStatus, format_program_status

end
