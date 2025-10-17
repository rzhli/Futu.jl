module Qot_GetBasicQot

    using ProtoBuf
    import ProtoBuf as PB
    using ..Common
    using ..Qot_Common

    mutable struct C2S
        securityList::Vector{Qot_Common.Security}
    end
    PB.default_values(::Type{C2S}) = (;securityList = Vector{Qot_Common.Security}())
    PB.field_numbers(::Type{C2S}) = (;securityList = 1)
    function PB.encode(e::PB.AbstractProtoEncoder, x::C2S)
        initpos = position(e.io)
        for item in x.securityList
            PB.encode(e, 1, item)
        end
        return position(e.io) - initpos
    end

    mutable struct S2C
        basicQotList::Vector{Qot_Common.BasicQot}
        S2C(basicQotList::Vector{Qot_Common.BasicQot}) = new(basicQotList)
        S2C(; basicQotList = Vector{Qot_Common.BasicQot}()) = new(basicQotList)
    end
    PB.default_values(::Type{S2C}) = (;basicQotList = Vector{Qot_Common.BasicQot}())
    PB.field_numbers(::Type{S2C}) = (;basicQotList = 1)
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
        retType::Int32
        retMsg::String
        errCode::Int32
        s2c::S2C
        Response(retType::Int32, retMsg::String, errCode::Int32, s2c::S2C) = new(retType, retMsg, errCode, s2c)
        Response(; retType = Common.RetType.Unknown, retMsg = "", errCode = 0, s2c = S2C()) = new(retType, retMsg, errCode, s2c)
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

    export C2S, S2C, Request, Response

end
