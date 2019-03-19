module Checkpoints

export checkpoint, @checkpoint, setdepot, getdepot, clear

# stdlib
using Serialization

const DEPOT = Ref{String}()

"""
    getdepot() -> String

Return the current checkpoint depot.
"""
getdepot() = DEPOT[]

"""
    setdepot(dir)

Set the checkpoint depot to `dir`. Create `dir` if it exists.
"""
function setdepot(dir::String)
    _make(dir)
    DEPOT[] = dir
    return dir
end

_make(dir) = !isdir(dir) && mkpath(dir)
_resolve(file) = joinpath(DEPOT[], file)

"""
    clear()

Clear all checkpoint in the current depot. Depots can be set with [`setdepot`](@ref) and
queried with [`getdepot`](@ref)
"""
function clear() 
    rm(DEPOT[], recursive = true, force = true)
    _make(DEPOT[])
end

"""
    clear(checkpoint::String)

Remove `checkpoint` from the current depot.
"""
clear(file)  = rm(_resolve(file))

function checkpoint(f, file::String)
    path = _resolve(file)
    # Return cached object
    if ispath(path)
        return deserialize(path)
    else
        # Invoke function, save results
        object = f()
        serialize(path, object)
        return object
    end
end

"""
    @checkpoint f(args...; kwargs...) checkpoint

Execute f(args...:kwargs...) and save the results to the file `checkpoint` in the current depot. The
next time this expression is invoked, the results from the previous run will be returned.
"""
macro checkpoint(fn, path)
    return :(checkpoint(() -> $(esc(fn)), $(esc(path))))
end

end # module
