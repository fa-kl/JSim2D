"""
    eye(n::UInt) -> SizedMatrix{n,n,Float64}

An identity matrix of size n×n.
"""
eye(n::UInt)::SizedMatrix{n,n,Float64} = SizedMatrix{n,n,Float64}(I)


"""
    orthogonalize(X::AbstractMatrix{<:Real}) -> AbstractMatrix{<:Real}

Orthogonalize a matrix using Singular Value Decomposition (SVD).
"""
function orthogonalize(X::AbstractMatrix{<:Real})::AbstractMatrix{<:Real}
    isempty(X) && return similar(X)
    U, _, V = svd(X)
    return U * V'
end

"""
    orthogonalize!(X::AbstractMatrix{<:Real}) -> Nothing

Orthogonalize a matrix in-place using Singular Value Decomposition (SVD).
"""
function orthogonalize!(X::AbstractMatrix{<:Real})
    isempty(X) && return nothing
    U, _, V = svd(X)
    X .= U * V'
    return nothing
end

"""
    sat(x::Real, lims::Tuple{<:Real,<:Real}) -> Real

Saturation of a real value.
"""
function sat(x::Real, lims::Tuple{<:Real,<:Real})::Real
    x = x < lims[1] ? lims[1] : x
    x = x > lims[2] ? lims[2] : x
    return x
end

"""
    sat!(x::Real, lims::Tuple{<:Real,<:Real})

In-place saturation of a real value.
"""
function sat!(x::Real, lims::Tuple{<:Real,<:Real})
    x .= x < lims[1] ? lims[1] : x
    x .= x > lims[2] ? lims[2] : x
    return nothing
end