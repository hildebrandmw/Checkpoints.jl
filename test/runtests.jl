using Checkpoints
using Test

Checkpoints.depot(joinpath(@__DIR__, "checkpoints"))
Checkpoints.clear()
f(x) = (sleep(x); return x^2)

@testset "Testing Checkpoint" begin

    sleeptime = 3
    file = "test1.checkpoint"
    path = joinpath(@__DIR__, "checkpoints", file)
    @test !ispath(path)
    runtime = @elapsed( result = checkpoint(f, (sleeptime,), file) )

    @test runtime > sleeptime
    @test result == sleeptime^2
    @test ispath(path)

    # Run the function again, verify that it takes very little time and returns the same
    # result.
    runtime = @elapsed( result = checkpoint(f, (2 * sleeptime,), file) )    
    @test runtime < 1    

    # Note - the results should be the same as the last invocation because we cached the
    # results. To recompute the function, we need to clean the file
    @test result == sleeptime^2

    # Test cleaning
    Checkpoints.clear(file)
    @test !ispath(path)

    runtime = @elapsed( result = checkpoint(f, (2 * sleeptime,), file) )    
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
end
