"""
    Vec2 <: FieldVector{2,Float64}

A 2-dimensional vector.

# Fields
- `x::Float64`: x-coordinate
- `y::Float64`: y-coordinate
"""
@with_kw mutable struct Vec2 <: FieldVector{2,Float64}
    x::Float64 = 0.0
    y::Float64 = 0.0
end

const x̂ = Vec2(1.0, 0.0)
const ŷ = Vec2(0.0, 1.0)

show(io::IO, mime::MIME{Symbol("text/plain")}, r::Vec2) = println(io, "Vec2(x=$(r.x), y=$(r.y))")

"""
    Configuration <: FieldVector{3,Float64}

A maximal representation of the configuration of an object in 2-dimensional space.

# Fields
- `θ::Float64`: angle of rotation [rad]
- `x::Float64`: x-coordinate [m]
- `y::Float64`: y-coordinate [m]
"""
@with_kw mutable struct Configuration <: FieldVector{3,Float64}
    θ::Float64 = 0.0
    x::Float64 = 0.0
    y::Float64 = 0.0
end

orientation(q::Configuration)::Float64 = q.θ
position(q::Configuration)::Vec2 = Vec2(q.x, q.y)
show(io::IO, mime::MIME{Symbol("text/plain")}, q::Configuration) = println(io, "Configuration(θ=$(q.θ), x=$(q.x), y=$(q.y))")

"""
    Velocity <: FieldVector{3,Float64}

A maximal representation of the velocity of an object in 2-dimensional space.

# Fields
- `ω::Float64`: angular velocity [rad/s]
- `x::Float64`: x-component of the linear velocity [m/s]
- `y::Float64`: y-component of the linear velocity [m/s]
"""
@with_kw mutable struct Velocity <: FieldVector{3,Float64}
    ω::Float64 = 0.0
    x::Float64 = 0.0
    y::Float64 = 0.0
end

angular_velocity(q̇::Configuration)::Float64 = q̇.ω
linear_velocity(q̇::Configuration)::Vec2 = Vec2(q̇.x, q̇.y)
show(io::IO, mime::MIME{Symbol("text/plain")}, v::Velocity) = println(io, "Velocity(ω=$(v.ω), x=$(v.x), y=$(v.y))")

"""
    Acceleration <: FieldVector{3,Float64}

A maximal representation of the acceleration of an object in 2-dimensional space.

# Fields
- `α::Float64`: angular acceleration [rad/s²]
- `x::Float64`: x-component of the linear acceleration [m/s²]
- `y::Float64`: y-component of the linear acceleration [m/s²]
"""
@with_kw mutable struct Acceleration <: FieldVector{3,Float64}
    ω::Float64 = 0.0
    x::Float64 = 0.0
    y::Float64 = 0.0
end

angular_acceleration(q̈::Configuration)::Float64 = q̈.α
linear_acceleration(q̈::Configuration)::Vec2 = Vec2(q̈.x, q̈.y)
show(io::IO, mime::MIME{Symbol("text/plain")}, a::Acceleration) = println(io, "Acceleration(ω=$(a.ω), x=$(a.x), y=$(a.y))")

"""
    Wrench <: FieldVector{3,Float64}

A maximal representation of the torques and forces acting on an object in 2-dimensional space.

# Fields
- `τ::Float64`: torque [N⋅m]
- `x::Float64`: x-component of the force [N]
- `y::Float64`: y-component of the force [N]
"""
@with_kw mutable struct Wrench <: FieldVector{3,Float64}
    τ::Float64 = 0.0
    x::Float64 = 0.0
    y::Float64 = 0.0
end

torque(f::Configuration)::Float64 = f.τ
force(f::Configuration)::Vec2 = Vec2(q.x, q.y)
show(io::IO, mime::MIME{Symbol("text/plain")}, w::Wrench) = println(io, "Wrench(τ=$(w.τ), x=$(w.x), y=$(w.y))")
