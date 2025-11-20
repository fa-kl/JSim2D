##########################################################################################
# Rigid Body
##########################################################################################

mutable struct RigidBody
    id::Symbol
    parent::Union{Symbol,Nothing}
    children::Vector{Symbol}
    shape::Shape
    material::Material
    m::Float64
    I::Float64
    q::Configuration
    q̇::Velocity
    F::Wrench

    function RigidBody(id::Symbol, shape::Shape, material::Material; parent::Union{Symbol,Nothing}=nothing, children::Vector{Symbol}=Symbol[])
        A = area(shape)
        m = material.ρ * A
        I = inertia(shape, material.ρ)
        q₀ = Configuration()
        q̇₀ = Velocity()
        F₀ = Wrench()
        return new(id, parent, children, shape, material, m, I, q₀, q̇₀, F₀)
    end
end

##########################################################################################
# Rigid Body Properties
##########################################################################################

"""
Get the mass matrix M(q) of a rigid body.
"""
function get_mass_matrix(body::RigidBody)::Matrix{<:Real}
    return diagm([body.I, body.m, body.m])
end

"""
Get the generalized forces vector h(q, q̇) of a rigid body.
"""
function get_generalized_forces_vector(body::RigidBody)::Vector{<:Real}
    return body.F
end

##########################################################################################
# Rigid Body Getters & Setters
##########################################################################################

"""
Get the configuration q of a rigid body.
"""
function get_configuration(body::RigidBody)::Configuration
    return body.q
end

"""
Get the velocity ̇q of a rigid body.
"""
function get_velocity(body::RigidBody)::Velocity
    return body.q̇
end

"""
Get the 6-dimensional state vector x of a rigid body.

`x = [θ, x, y, ω, ẋ, ẏ]`
"""
function get_state_vector(body::RigidBody)::Vector{Float64}
    return [body.q..., body.q̇...]
end

"""
Set the configuration q of a rigid body.
"""
function set_configuration!(body::RigidBody, q::Configuration)
    body.q = q
    return nothing
end

"""
Set the velocity ̇q of a rigid body.
"""
function set_velocity!(body::RigidBody, q̇::Velocity)
    body.q̇ = q̇
    return nothing
end

"""
Set the state x of a rigid body.

`x = [θ, x, y, ω, ẋ, ẏ]`
"""
function set_state!(body::RigidBody, x::AbstractVector{<:Real})
    length(x) == 6 || throw(ArgumentError("x must be a 6-dimensional vector"))
    body.q = x[1:3]
    body.q̇ = x[4:6]
    return nothing
end

##########################################################################################
# Rigid Body Energy Calculations
##########################################################################################

"""
Compute the kinetic energy of the rigid body.
KE = (1/2) * m * v² + (1/2) * I * ω²
"""
function kinetic_energy(body::RigidBody)::Float64
    ω, v = angular_velocity(get_velocity(body)), linear_velocity(get_velocity(body))
    return 0.5 * body.m * dot(v, v) + 0.5 * body.I * ω^2
end

"""
Compute the gravitational potential energy.
PE = m * g * h (height of center of mass)
"""
function potential_energy(body::RigidBody, g::Float64=9.81)::Float64
    y = position(get_configuration(body)).y
    return body.m * g * y
end

"""
Compute total mechanical energy (kinetic + potential).
"""
function energy(body::RigidBody, g::Float64=9.81)::Float64
    return kinetic_energy(body) + potential_energy(body, g)
end

