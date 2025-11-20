"""
    Material

A struct providing all properties and constants of a material.

# Fields
- `ρ::Float64`: density [kg/m²] (mass per area in 2D)
- `ϵ::Float64`: coefficient of restitution (0=inelastic, 1=elastic)
- `μₛ::Float64`: linear static friction coefficient, when resting
- `μₖ::Float64`: linear kinetic friction coefficient, when moving
- `color::Symbol`: a color sybmol
"""
@with_kw mutable struct Material
    ρ::Float64 = 7850.0
    ϵ::Float64 = 0.6
    μₛ::Float64 = 0.7
    μₖ::Float64 = 0.5
    color::Symbol = :black
end

const wood = Material(600.0, 0.4, 0.5, 0.3, :brown)
const steel = Material(7850.0, 0.6, 0.7, 0.5, :gray)
const rubber = Material(1100.0, 0.8, 0.9, 0.7, :magenta)
const ice = Material(920.0, 0.05, 0.05, 0.03, :lightblue)