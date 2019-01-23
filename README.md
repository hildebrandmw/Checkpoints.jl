# Checkpoints

![Lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)
[![Build Status](https://travis-ci.org/hildebrandmw/Checkpoints.jl.svg?branch=master)](https://travis-ci.org/hildebrandmw/Checkpoints.jl)
[![codecov.io](http://codecov.io/github/hildebrandmw/Checkpoints.jl/coverage.svg?branch=master)](http://codecov.io/github/hildebrandmw/Checkpoints.jl?branch=master)

Checkpointing functionality for running Jupyter notebooks where certain cells contain long
running processes that you don't necessarily want to recalculate every time. Simply set
a depot for the checkpoints (i.e. a directory where the serialized checkpoint objects will
be stored) via
```julia
setdepot("depot_path")
```
Then, use the `@checkpoint` macro to save the results of a function call into a file under
the depot path. The second time this line is invoked (such as if the kernel of a Jupyter 
notebook was restarted), the previous results will be returned. See the example below for
how this is used.

Checkpoints can be cleared with the `clear("checkpoint_file")` function.

## Exmaple

```julia
julia> using Checkpoints

# Set the directory where checkpoints will be saved
julia> setdepot("./checkpoints")
"./checkpoints"

julia> f(x) = (sleep(10); return x)
f (generic function with 1 method)

# Run the function for the first time - note that the elapsed time is about what we would
# expect since the `f` sleeps for 10 seconds.
julia> @elapsed(x = @checkpoint f(10) "test.checkpoint")
10.244815612

# Also note the result for `x` is `10` like we would expect
julia> x
10

# You can see the checkpoint saved in `./checkpoints`
shell> ls ./checkpoints
test.checkpoint

# When we run the `@checkpoint` macro with the same checkpoint, the previous results are
# returned, saving the need to rerun the function
julia> @elapsed(x = @checkpoint f(20) "test.checkpoint")
0.200006799

# However, if the arguments or definition of `f` have changed, these changes will not be
# reflected in the returned results
julia> x
10

# We can clear a checkpoint with the `clear` function.
julia> clear("test.checkpoint")

# Now, when we run the checkpointed function again, the results are updated.
julia> @elapsed(x = @checkpoint f(20) "test.checkpoint")
10.004619423

julia> x
20

# Finally, all checkpoints in the current depot can be cleared.
# julia> clear()
# 
# julia> rm("./checkpoints", recursive = true)
```
