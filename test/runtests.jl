using Checkpoints
using Test

setdepot(joinpath(@__DIR__, "checkpoints"))
clear()
f(x) = (sleep(x); return x^2)

@testset "Testing Checkpoint" begin

    sleeptime = 3
    file = "test1.checkpoint"
    path = joinpath(@__DIR__, "checkpoints", file)
    @test !ispath(path)
    runtime = @elapsed( result = checkpoint(() -> f(sleeptime), file) )

    @test runtime > sleeptime
    @test result == sleeptime^2
    @test ispath(path)

    # Run the function again, verify that it takes very little time and returns the same
    # result.
    runtime = @elapsed( result = checkpoint(() -> f(2 * sleeptime), file) )    
    @test runtime < 1    

    # Note - the results should be the same as the last invocation because we cached the
    # results. To recompute the function, we need to clean the file
    @test result == sleeptime^2

    # Test cleaning
    Checkpoints.clear(file)
    @test !ispath(path)

    runtime = @elapsed( result = checkpoint(() ->f(2 * sleeptime), file) )    
    @test runtime > 2 * sleeptime
    @test result == f( 2 * sleeptime )
end

@testset "Testing Macro" begin
    sleeptime = 3
    file = "test2.checkpoint"
    path = joinpath(@__DIR__, "checkpoints", file)
    @test !ispath(path)

    runtime = @elapsed begin
        result = @checkpoint f(sleeptime) file
    end

    @test runtime > sleeptime
    @test result == f(sleeptime)
    @test ispath(path)

    runtime = @elapsed begin
        result = @checkpoint f(2 * sleeptime) file
    end

    @test runtime < 1
    @test result == f(sleeptime)

    # Test the "begin -> end" syntax
    runtime = @elapsed begin
        y = @checkpoint begin
            sleep(10)
            return 10
        end "test3.checkpoint"
    end

    @test runtime > 10
    @test y == 10

    # Use the same checkpoint directory.
    runtime = @elapsed begin
        x = @checkpoint begin
            sleep(10)
            return 20
       end "test3.checkpoint"
    end

    @test runtime < 1
    @test x == 10
end

@testset "Testing Keyword" begin
    # Test function with just keyword arguments
    f(;a = 1, b = 2, c = 3) = (a, b, c)

    x = @checkpoint f(;a = 2) "test4.checkpoint"
    @test x == (2, 2, 3)

    x = @checkpoint f(;a = 2) "test4.checkpoint"
    @test x == (2, 2, 3)

    y = @checkpoint f(;b = 4) "test5.checkpoint"
    @test y == (1,4,3)

    y = @checkpoint f(;b = 4) "test5.checkpoint"
    @test y == (1,4,3)

    z = @checkpoint f(;a = 2, c = 1) "test6.checkpoint"
    @test z == (2,2,1)

    z = @checkpoint f(;a = 2, c = 1) "test6.checkpoint"
    @test z == (2,2,1)
    clear()
end
