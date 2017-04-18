__precompile__(true)

module IdentityRanges

using OffsetArrays

export IdentityRange

"""
    IdentityRange(start, stop) -> idr
    IdentityRange(r::AbstractUnitRange) -> idr

Defines an `AbstractUnitRange` where `idr[i] == i` for any valid `i`,
or equivalently `indices(idr, 1)` returns a range with the same values
as present in `idr`.

These are particularly useful for creating `view`s of arrays that
preserve the supplied indices:
```jldoctest
julia> a = rand(8);

julia> v1 = view(a, 3:5);

julia> indices(v1, 1)
Base.OneTo(3)

julia> idr = IdentityRange(3:5)
IdentityRange(3:5)

julia> v2 = view(a, idr);

julia> indices(v2, 1)
3:5
```
"""
immutable IdentityRange{T<:Integer} <: AbstractUnitRange{T}
    start::T
    stop::T
    (::Type{IdentityRange{T}}){T}(start, stop) = new{T}(start, stop)
end
IdentityRange{T<:Integer}(start::T, stop::T) = IdentityRange{T}(start, stop)

Base.indices(r::IdentityRange) = (r.start:r.stop,)
Base.unsafe_indices(r::IdentityRange) = (r.start:r.stop,)

_length{T}(r::IdentityRange{T}) = max(zero(T), convert(T, r.stop-r.start+1))
Base.length(r::IdentityRange) = _length(r)
Base.length{T<:Union{Int,Int64}}(r::IdentityRange{T}) = _length(r)

let smallint = (Int === Int64 ?
                Union{Int8,UInt8,Int16,UInt16,Int32,UInt32} :
                Union{Int8,UInt8,Int16,UInt16})
    Base.length{T <: smallint}(r::IdentityRange{T}) = Int(_length(r))
    Base.start{T<:smallint}(r::IdentityRange{T}) = Int(r.start)
end

Base.first{T}(r::IdentityRange{T}) = r.start
Base.last{ T}(r::IdentityRange{T}) = r.stop

Base.start{T}(r::IdentityRange{T}) = oftype(one(T)+one(T), first(r))
Base.done{T}(r::IdentityRange{T}, i) = i == oftype(i, last(r)) + 1

@inline function Base.getindex{T}(v::IdentityRange{T}, i::Integer)
    @boundscheck ((i >= first(v)) & (i <= last(v))) || Base.throw_boundserror(v, i)
    convert(T, i)
end

@inline function Base.getindex{R,S<:Integer}(r::IdentityRange{R}, s::AbstractUnitRange{S})
    @boundscheck checkbounds(r, s)
    IdentityRange{R}(first(s), last(s))
end

Base.intersect(r::IdentityRange, s::IdentityRange) = IdentityRange(max(first(r), first(s)),
                                                                   min(last(r), last(s)))

Base.:(==)(r::IdentityRange, s::IdentityRange) = (first(r) == first(s)) & (step(r) == step(s)) & (last(r) == last(s))
Base.:(==)(r::IdentityRange, s::OrdinalRange) = (first(r) == first(s) == 1) & (step(r) == step(s)) & (last(r) == last(s))
Base.:(==)(s::OrdinalRange, r::IdentityRange) = r == s

function Base.:+(r::IdentityRange, s::IdentityRange)
    indsr = indices(r, 1)
    indsr == indices(s, 1) || throw(DimensionMismatch("indices $indsr and $(indices(s, 1)) do not match"))
    OffsetArray(convert(UnitRange, r)+convert(UnitRange, s), indsr)
end
function Base.:-(r::IdentityRange, s::IdentityRange)
    indsr = indices(r, 1)
    indsr == indices(s, 1) || throw(DimensionMismatch("indices $indsr and $(indices(s, 1)) do not match"))
    OffsetArray(fill(first(r)-first(s), length(r)), indsr)
end
function Base.:+(r::IdentityRange, x::Number)
    indsr = indices(r, 1)
    OffsetArray(indsr+x, indsr)
end
Base.:+(x::Real, r::IdentityRange) = r+x
Base.:+(x::Number, r::IdentityRange) = r+x
function Base.:-(r::IdentityRange)
    indsr = indices(r, 1)
    OffsetArray(-indsr, indsr)
end
function Base.:-(r::IdentityRange, x::Number)
    indsr = indices(r, 1)
    OffsetArray(indsr-x, indsr)
end
function Base.:-(x::Number, r::IdentityRange)
    indsr = indices(r, 1)
    OffsetArray(x-indsr, indsr)
end
function Base.:*(r::IdentityRange, x::Number)
    indsr = indices(r, 1)
    OffsetArray(indsr*x, indsr)
end
Base.:*(x::Number, r::IdentityRange) = r*x
function Base.:/(r::IdentityRange, x::Number)
    indsr = indices(r, 1)
    OffsetArray(indsr/x, indsr)
end

Base.collect(r::IdentityRange) = convert(Vector, first(r):last(r))
Base.sortperm(r::IdentityRange) = r
function Base.reverse(r::IdentityRange)
    indsr = indices(r, 1)
    OffsetArray(reverse(indsr), indsr)
end

Base.promote_rule{T1,T2}(::Type{IdentityRange{T1}},::Type{IdentityRange{T2}}) =
    IdentityRange{promote_type(T1,T2)}
Base.convert{T<:Integer}(::Type{IdentityRange{T}}, r::IdentityRange{T}) = r
Base.convert{T<:Integer}(::Type{IdentityRange{T}}, r::AbstractUnitRange) =
    IdentityRange{T}(first(r), last(r))
Base.convert{T<:Integer}(::Type{IdentityRange}, r::AbstractUnitRange{T}) =
    convert(IdentityRange{T}, r)

Base.show(io::IO, r::IdentityRange) = print(io, "IdentityRange(", first(r), ":", last(r), ")")

end
