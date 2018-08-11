VERSION < v"0.7.0-beta2.199" && __precompile__()

module IdentityRanges

using OffsetArrays

export IdentityRange

"""
    IdentityRange(start, stop) -> idr
    IdentityRange(r::AbstractUnitRange) -> idr

Defines an `AbstractUnitRange` where `idr[i] == i` for any valid `i`,
or equivalently `axes(idr, 1)` returns a range with the same values
as present in `idr`.

These are particularly useful for creating `view`s of arrays that
preserve the supplied axes:
```jldoctest
julia> a = rand(8);

julia> v1 = view(a, 3:5);

julia> axes(v1, 1)
Base.OneTo(3)

julia> idr = IdentityRange(3:5)
IdentityRange(3:5)

julia> v2 = view(a, idr);

julia> axes(v2, 1)
3:5
```
"""
struct IdentityRange{T<:Integer} <: AbstractUnitRange{T}
    start::T
    stop::T
    IdentityRange{T}(start, stop) where {T} = new{T}(start, stop)
end
IdentityRange(start::T, stop::T) where {T<:Integer} = IdentityRange{T}(start, stop)

Base.axes(r::IdentityRange) = (r.start:r.stop,)
Base.unsafe_indices(r::IdentityRange) = (r.start:r.stop,)

_length(r::IdentityRange{T}) where {T} = max(zero(T), convert(T, r.stop-r.start+1))
Base.length(r::IdentityRange) = _length(r)
Base.length(r::IdentityRange{T}) where {T<:Union{Int,Int64}} = _length(r)

let smallint = (Int === Int64 ?
                Union{Int8,UInt8,Int16,UInt16,Int32,UInt32} :
                Union{Int8,UInt8,Int16,UInt16})
    Base.length(r::IdentityRange{T}) where {T<:smallint} = Int(_length(r))
end

Base.first(r::IdentityRange) = r.start
Base.last(r::IdentityRange) = r.stop

Base.eltype(r::IdentityRange{T}) where {T} = typeof(one(T) + one(T))
function Base.iterate(r::IdentityRange{T}) where {T}
    last(r) < first(r) && return nothing
    x = oftype(one(T) + one(T), first(r))
    return (x,x)
end
function Base.iterate(r::IdentityRange{T}, i) where T
    x = i + one(T)
    return (x > oftype(x,last(r)) ? nothing : (x,x))
end

@inline function Base.getindex(v::IdentityRange{T}, i::Integer) where T
    @boundscheck ((i >= first(v)) & (i <= last(v))) || Base.throw_boundserror(v, i)
    convert(T, i)
end

@inline function Base.getindex(r::IdentityRange{R}, s::AbstractUnitRange{S}) where {R,S<:Integer}
    @boundscheck checkbounds(r, s)
    IdentityRange{R}(first(s), last(s))
end
Base.firstindex(r::IdentityRange) = r.start
Base.lastindex(r::IdentityRange) = r.stop

Base.intersect(r::IdentityRange, s::IdentityRange) = IdentityRange(max(first(r), first(s)),
                                                                   min(last(r), last(s)))

Base.:(==)(r::IdentityRange, s::IdentityRange) = (first(r) == first(s)) & (step(r) == step(s)) & (last(r) == last(s))
Base.:(==)(r::IdentityRange, s::OrdinalRange) = (first(r) == first(s) == 1) & (step(r) == step(s)) & (last(r) == last(s))
Base.:(==)(s::OrdinalRange, r::IdentityRange) = r == s

function Base.:+(r::IdentityRange, s::IdentityRange)
    indsr = axes(r, 1)
    indsr == axes(s, 1) || throw(DimensionMismatch("axes $indsr and $(axes(s, 1)) do not match"))
    OffsetArray(convert(UnitRange, r)+convert(UnitRange, s), indsr)
end
function Base.:-(r::IdentityRange, s::IdentityRange)
    indsr = axes(r, 1)
    indsr == axes(s, 1) || throw(DimensionMismatch("axes $indsr and $(axes(s, 1)) do not match"))
    OffsetArray(fill(first(r)-first(s), length(r)), indsr)
end
function Base.:+(r::IdentityRange, x::Number)
    indsr = axes(r, 1)
    OffsetArray(indsr.+x, indsr)
end
Base.:+(x::Real, r::IdentityRange) = r+x
Base.:+(x::Number, r::IdentityRange) = r+x
function Base.:-(r::IdentityRange)
    indsr = axes(r, 1)
    OffsetArray(-indsr, indsr)
end
function Base.:-(r::IdentityRange, x::Number)
    indsr = axes(r, 1)
    OffsetArray(indsr.-x, indsr)
end
function Base.:-(x::Number, r::IdentityRange)
    indsr = axes(r, 1)
    OffsetArray(x.-indsr, indsr)
end
function Base.:*(r::IdentityRange, x::Number)
    indsr = axes(r, 1)
    OffsetArray(indsr.*x, indsr)
end
Base.:*(x::Number, r::IdentityRange) = r*x
function Base.:/(r::IdentityRange, x::Number)
    indsr = axes(r, 1)
    OffsetArray(indsr./x, indsr)
end

Base.collect(r::IdentityRange) = convert(Vector, first(r):last(r))
Base.sortperm(r::IdentityRange) = r
function Base.reverse(r::IdentityRange)
    indsr = axes(r, 1)
    OffsetArray(reverse(indsr), indsr)
end

Base.promote_rule(::Type{IdentityRange{T1}},::Type{IdentityRange{T2}}) where {T1,T2} =
    IdentityRange{promote_type(T1,T2)}
Base.convert(::Type{IdentityRange{T}}, r::IdentityRange{T}) where {T<:Integer} = r
Base.convert(::Type{IdentityRange{T}}, r::AbstractUnitRange) where {T<:Integer} =
    IdentityRange{T}(first(r), last(r))
Base.convert(::Type{IdentityRange}, r::AbstractUnitRange{T}) where {T<:Integer} =
    convert(IdentityRange{T}, r)

Base.show(io::IO, r::IdentityRange) = print(io, "IdentityRange(", first(r), ":", last(r), ")")

IdentityRange{R}(r::AbstractUnitRange{T}) where {R,T} = convert(IdentityRange{R}, r)
IdentityRange(r::AbstractUnitRange{T}) where {T} = convert(IdentityRange, r)

end
