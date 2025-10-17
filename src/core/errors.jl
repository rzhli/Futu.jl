module Errors

export FutuAPIError, ConnectionError, ProtocolError, QuoteError, TradeError

# Base error type
struct FutuAPIError <: Exception
    code::Int
    message::String
end

Base.showerror(io::IO, e::FutuAPIError) = print(io, "FutuAPIError($(e.code)): $(e.message)")

# Connection related errors
struct ConnectionError <: Exception
    message::String
end

Base.showerror(io::IO, e::ConnectionError) = print(io, "ConnectionError: $(e.message)")

# Protocol related errors
struct ProtocolError <: Exception
    message::String
end

Base.showerror(io::IO, e::ProtocolError) = print(io, "ProtocolError: $(e.message)")

# Quote related errors
struct QuoteError <: Exception
    code::Int
    message::String
end

Base.showerror(io::IO, e::QuoteError) = print(io, "QuoteError($(e.code)): $(e.message)")

# Trade related errors
struct TradeError <: Exception
    code::Int
    message::String
end

Base.showerror(io::IO, e::TradeError) = print(io, "TradeError($(e.code)): $(e.message)")

end # module Errors