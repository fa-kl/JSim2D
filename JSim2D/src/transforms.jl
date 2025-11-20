istransformmat(T::AbstractMatrix)::Bool = size(T) == (3, 3) && isrotmat(T[1:2, 1:2]) && all(T[3, 1:2] .≈ 0.0) && T[3, 3] ≈ 1.0

function expSE2(θ::Real, r::AbstractVector)::SizedMatrix{3,3,Float64}
    length(r) != 2 && throw(ArgumentError("r must be a 2-dimensional vector"))
    return SizedMatrix{3,3,Float64}([cos(θ) -sin(θ) r[1]; sin(θ) cos(θ) r[2]; 0.0 0.0 1.0])

end

mutable struct Transform <: AbstractMatrix{Real}
    matrix::SizedMatrix{3,3,Float64}

    function Transform(T::AbstractMatrix)
        !istransformmat(T) && throw(ArgumentError("T must be valid member of SE(2)"))
        return new(SizedMatrix{3,3,Float64}(T))
    end

    function Transform(R::Rotation, r::AbstractVector)
        !isrotmat(R.matrix) && throw(ArgumentError("R must be valid member of SO(2)"))
        return new([R.matrix r; 0.0 0.0 1.0])
    end

    function Transform(θ::Real, r::AbstractVector)
        return new(expSE2(θ, r))
    end

    function Transform(q::Configuration)
        return Transform(q[1], q[2:3])
    end

    function Transform()
        return Transform(0.0, Vec2())
    end

end

show(io::IO, mime::MIME{Symbol("text/plain")}, T::Transform) = println(io, "Transform(θ = $(logSO2(rotation(T))), r = Vec2(x = $(translation(T).x), y = $(translation(T).y)))")

size(T::Transform) = size(T.matrix)

getindex(T::Transform, i::Int) = T.matrix[i]

getindex(T::Transform, i::Int, j::Int) = T.matrix[i, j]

IndexStyle(::Type{Transform}) = IndexLinear()

∘(T1::Transform, T2::Transform)::Transform = Transform(T1.matrix * T2.matrix)

function inv(T::Transform)::Transform
    R⁻¹ = inv(rotation(T))
    t = translation(T)
    Transform(R⁻¹, -R⁻¹ * t)
end

*(T::Transform, v::AbstractVector{<:Real})::Vec2 = Vec2(T.matrix * v)

function logSE2(T::Transform)::Tuple{Float64,Vec2}
    return logSO2(rotation(T)), Vec2(translation(T)...)
end

rotation(T::Transform)::Rotation = Rotation(T[1:2, 1:2])

orientation(T::Transform)::Float64 = logSO2(rotation(T))

translation(T::Transform)::Vec2 = Vec2(T[1:2, 3])

configuration(T::Transform)::Configuration = Configuration(logSO2(rotation(T)), T[1:2, 3]...)

∘(T::Transform, R::Rotation)::Transform = Transform(Rotation(rotation(T) * R.matrix), translation(T))

∘(R::Rotation, T::Transform)::Transform = Transform(Rotation(R.matrix * rotation(T)), R.matrix * translation(T))

*(T::Transform, v::Vec2)::Vec2 = rotation(T) * v + translation(T)