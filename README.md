# IdentityRanges

[![Build Status](https://travis-ci.org/JuliaArrays/IdentityRanges.jl.svg?branch=master)](https://travis-ci.org/JuliaArrays/IdentityRanges.jl)

[![codecov.io](http://codecov.io/github/JuliaArrays/IdentityRanges.jl/coverage.svg?branch=master)](http://codecov.io/github/JuliaArrays/IdentityRanges.jl?branch=master)

IdentityRanges are Julia-language a helper type for creating "views"
of arrays. They are a custom type of `AbstractUnitRange` that makes it
easy to preserve the indices of array views. The key property of an
`IdentityRange` `r` is that `r[i] == i` (hence the name of the
type/package), and that they support arbitrary start/stop indices
(i.e., not just starting at 1).

```julia
julia> A = reshape(1:24, 4, 6)
4×6 Base.ReshapedArray{Int64,2,UnitRange{Int64},Tuple{}}:
 1  5   9  13  17  21
 2  6  10  14  18  22
 3  7  11  15  19  23
 4  8  12  16  20  24

julia> V = view(A, 2:3, 3:5)
2×3 SubArray{Int64,2,Base.ReshapedArray{Int64,2,UnitRange{Int64},Tuple{}},Tuple{UnitRange{Int64},UnitRange{Int64}},false}:
 10  14  18
 11  15  19

julia> indices(V)
(Base.OneTo(2),Base.OneTo(3))

julia> V[1,1]
10

julia> using IdentityRanges

julia> Vp = view(A, IdentityRange(2:3), IdentityRange(3:5))
SubArray{Int64,2,Base.ReshapedArray{Int64,2,UnitRange{Int64},Tuple{}},Tuple{IdentityRanges.IdentityRange{Int64},IdentityRanges.IdentityRange{Int64}},false} with indices 2:3×3:5:
 10  14  18
 11  15  19

julia> indices(Vp)
(2:3,3:5)

julia> Vp[1,1]
ERROR: BoundsError: attempt to access SubArray{Int64,2,Base.ReshapedArray{Int64,2,UnitRange{Int64},Tuple{}},Tuple{IdentityRanges.IdentityRange{Int64},IdentityRanges.IdentityRange{Int64}},false} with indices 2:3×3:5 at index [1,1]
 in throw_boundserror(::SubArray{Int64,2,Base.ReshapedArray{Int64,2,UnitRange{Int64},Tuple{}},Tuple{IdentityRanges.IdentityRange{Int64},IdentityRanges.IdentityRange{Int64}},false}, ::Tuple{Int64,Int64}) at ./abstractarray.jl:363
 in checkbounds at ./abstractarray.jl:292 [inlined]
 in getindex(::SubArray{Int64,2,Base.ReshapedArray{Int64,2,UnitRange{Int64},Tuple{}},Tuple{IdentityRanges.IdentityRange{Int64},IdentityRanges.IdentityRange{Int64}},false}, ::Int64, ::Int64) at ./subarray.jl:133

julia> Vp[2,3]
10

julia> A[2,3]
10
```
