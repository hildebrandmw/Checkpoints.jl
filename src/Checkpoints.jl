module Checkpoints

export checkpoint, @checkpoint

# stdlib
using Serialization

# dependencies
using MacroTools

const DEPOT = Ref{String}()

function depot(dir::String)
    _make(dir)
    DEPOT[] = dir
    return dir
end

_make(dir) = !isdir(dir) && mkpath(dir)
_resolve(file) = joinpath(DEPOT[], file)

function clear() 
    rm(DEPOT[], recursive = true, force = true)
    _make(DEPOT[])
end
clear(file)  = rm(_resolve(file))

# TODO: Automatic rerun on function recompilation?
function checkpoint(f, args::Tuple, file)
    path = _resolve(file)
    # Return cached object
    if ispath(path)
        return deserialize(path)
    else
        # Invoke function, save results
        object = f(args...)
        serialize(path, object)
        return object
    end
end

macro checkpoint(fn, path)
    # Split apart the function definition
    @capture(fn, f_(args__))
    args_tuple = Expr(:tuple, args...)

    return :(checkpoint($(esc(f)), $(esc(args_tuple)), $(esc(path))))
end

end # module
