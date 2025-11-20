isrotmat(R::AbstractMatrix)::Bool = (size(R) == (2, 2)) && (det(R) ≈ 1) && (R' * R ≈ I)

function expSO2(θ::Real)::SizedMatrix{2,2,Float64}
    return SizedMatrix{2,2,Float64}([cos(θ) -sin(θ); sin(θ) cos(θ)])
end

mutable struct Rotation <: AbstractMatrix{Real}
    matrix::SizedMatrix{2,2,Float64}

    function Rotation(R::AbstractMatrix)
        !isrotmat(R) && throw(ArgumentError("R must be valid member of SO(2)"))
        return new(SizedMatrix{2,2,Float64}(R))
    end

    function Rotation(θ::Real)
        return new(expSO2(θ))
    end

    function Rotation()
        return new(expSO2(0.0))
    end
end

show(io::IO, mime::MIME{Symbol("text/plain")}, R::Rotation) = println(io, "Rotation(θ = $(logSO2(R)))")

size(R::Rotation) = size(R.matrix)

getindex(R::Rotation, i::Int) = R.matrix[i]

getindex(R::Rotation, i::Int, j::Int) = R.matrix[i, j]

IndexStyle(::Type{Rotation}) = IndexLinear()

∘(R1::Rotation, R2::Rotation)::Rotation = Rotation(R1.matrix * R2.matrix)

inv(R::Rotation)::Rotation = Rotation(R.matrix')

*(R::Rotation, v::AbstractVector{<:Real})::Vec2 = Vec2(R.matrix * v)

function logSO2(R::Rotation)::Float64
    !isrotmat(R.matrix) && throw(ArgumentError("R must be valid member of SO(2)"))
    return atan(R[2, 1], R[1, 1])
end

orientation(R::Rotation)::Float64 = logSO2(R)