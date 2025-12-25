using Test
using Futu

@testset "Futu SDK Tests" begin

    @testset "Module Loading" begin
        # Test that all main modules are loaded
        @test isdefined(Futu, :OpenDClient)
        @test isdefined(Futu, :connect!)
        @test isdefined(Futu, :disconnect!)
        @test isdefined(Futu, :is_connected)
    end

    @testset "Constants" begin
        # Test enum definitions
        @test isdefined(Futu.Constants, :QotMarket)
        @test isdefined(Futu.Constants, :SubType)
        @test isdefined(Futu.Constants, :KLType)
        @test isdefined(Futu.Constants, :TrdEnv)
    end

    @testset "Quote Functions" begin
        # Test that quote functions are exported
        @test isdefined(Futu, :subscribe)
        @test isdefined(Futu, :get_market_snapshot)
        @test isdefined(Futu, :get_kline)
        @test isdefined(Futu, :get_history_kline)
    end

    @testset "Trade Functions" begin
        # Test that trade functions are exported
        @test isdefined(Futu, :get_account_list)
        @test isdefined(Futu, :place_order)
        @test isdefined(Futu, :get_order_list)
        @test isdefined(Futu, :get_position_list)
    end

    @testset "Extended Quote Functions" begin
        # Test extended quote functions
        @test isdefined(Futu, :get_option_chain)
        @test isdefined(Futu, :get_warrant)
        @test isdefined(Futu, :get_plate_set)
        @test isdefined(Futu, :get_ipo_list)
    end

    # Note: Integration tests requiring live OpenD connection
    # are in separate test_*.jl files and should be run manually:
    #   include("test_client.jl")
    #   include("test_quote.jl")
    #   include("test_trade.jl")
    #   etc.

end
