#

# Fallback
"""
    cache=alloc_mem(A,method)

Pre-allocates memory associated with matrix exponential function `method` and matrix `A`. To be used in combination with [`exponential!`](@ref).
"""
function alloc_mem(A, method)
    return nothing
end

@deprecate _exp! exponential!
@deprecate exp_generic exponential!
exponential!(A) = exponential!(A, ExpMethodHigham2005(A));

## The diagonalization based
"""
    ExpMethodDiagonalization(enforce_real=true)

Matrix exponential method corresponding to the diagonalization with `eigen` possibly by removing imaginary part introduced by the numerical approximation.

"""
struct ExpMethodDiagonalization
    enforce_real::Bool
end
ExpMethodDiagonalization() = ExpMethodDiagonalization(true);

"""
    E=exponential!(A,[method [cache]])

Computes the matrix exponential with method specified in `method`. The contents of `A` is modified allowing for less allocations. The `method` parameter specifies the implementation and implementation parameters, e.g. [`ExpMethodNative`](@ref), [`ExpMethodDiagonalization`](@ref), [`ExpMethodGeneric`](@ref), [`ExpMethodHigham2005`](@ref). Memory
needed can be preallocated and provided in parameter `cache` such that the memory can recycled when calling `exponential!` several times. The preallocation is done with the command [`alloc_mem`](@ref): `cache=alloc_mem(A,method)`.

Example
```julia-repl
julia> A=randn(50,50);
julia> Acopy=B*2;
julia> method=ExpMethodHigham2005();
julia> cache=alloc_mem(A,method); # Main allocation done here
julia> E1=exponential!(A,method,cache) # Very little allocation here
julia> E2=exponential!(B,method,cache) # Very little allocation here
```

"""
function exponential!(A, method::ExpMethodDiagonalization, cache = nothing)
    F = eigen!(A)
    E = F.vectors * Diagonal(exp.(F.values)) / F.vectors
    if (method.enforce_real && isreal(A))
        E = real.(E)
    end
    copyto!(A, E)
    return A
end

"""
    ExpMethodNative()

Matrix exponential method corresponding to calling `Base.exp`.

"""
struct ExpMethodNative end
function exponential!(A, method::ExpMethodNative, cache = nothing)
    return exp(A)
end
