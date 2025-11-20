##########################################################################################
# Abstract Shape Type
##########################################################################################

"""
    Shape

Abstract type for all  geometric shapes.

All concrete shapes must implement:
- `area(s::Shape)` - Compute the area
- `centroid(s::Shape)` - Compute the centroid (center of mass for uniform density)
- `inertia(s::Shape, ρ::Real)` - Compute moment of inertia about centroid for density ρ
"""
abstract type Shape end


##########################################################################################
# Circle
##########################################################################################

"""
    Circle <: Shape

A circle shape defined by its radius.

# Fields
- `radius::Float64`: Radius of the circle (must be > 0)
"""
struct Circle <: Shape
    radius::Float64

    function Circle(radius::Real)
        radius > 0 || throw(ArgumentError("Radius must be positive"))
        new(Float64(radius))
    end
end

"""
    area(c::Circle) -> Float64

Compute the area of a circle: A = πr²
"""
area(c::Circle)::Float64 = π * c.radius^2

"""
    centroid(c::Circle) -> Vec2

Compute the centroid of a circle (always at origin for shape-local coordinates).
"""
centroid(c::Circle)::Vec2 = Vec2(0.0, 0.0)

"""
    inertia(c::Circle, ρ::Real) -> Float64

Compute the moment of inertia of a circle about its centroid.
For a circle: I = (1/2) * m * r² where m = ρ * A

# Arguments
- `c::Circle`: The circle shape
- `ρ::Real`: Material density (mass per unit area)

# Returns
- `I::Float64`: Moment of inertia about the z-axis through centroid
"""
function inertia(c::Circle, ρ::Real)::Float64
    ρ > 0 || throw(ArgumentError("Density must be positive"))
    m = ρ * area(c)
    return 0.5 * m * c.radius^2
end

"""
    vertices(c::Circle) -> Vector{Vec2}

Get the vertices of a polygon approximation of a circle in local coordinates.
Returns vertices in counter-clockwise order starting from the most right corner.
"""
function vertices(c::Circle, Δϕ::Real=π / 8)::Vector{Vec2}
    return [c.radius * Rotation(ϕ) * x̂ for ϕ ∈ 0:Δϕ:(2*π-Δϕ)]
end

##########################################################################################
# Box (Rectangle)
##########################################################################################

"""
    Box <: Shape

A rectangular box shape defined by width and height.

# Fields
- `width::Float64`: Width of the box (along x-axis, must be > 0)
- `height::Float64`: Height of the box (along y-axis, must be > 0)
"""
struct Box <: Shape
    width::Float64
    height::Float64

    function Box(width::Real, height::Real)
        width > 0 || throw(ArgumentError("Width must be positive"))
        height > 0 || throw(ArgumentError("Height must be positive"))
        new(Float64(width), Float64(height))
    end
end

"""
    Box(size::Real)

Create a square box with equal width and height.
"""
Box(size::Real) = Box(size, size)

"""
    area(b::Box) -> Float64

Compute the area of a box: A = width * height
"""
area(b::Box)::Float64 = b.width * b.height

"""
    centroid(b::Box) -> Vec2

Compute the centroid of a box (always at origin for shape-local coordinates).
"""
centroid(b::Box)::Vec2 = Vec2(0.0, 0.0)

"""
    inertia(b::Box, ρ::Real) -> Float64

Compute the moment of inertia of a box about its centroid.
For a rectangle: I = (1/12) * m * (w² + h²) where m = ρ * A

# Arguments
- `b::Box`: The box shape
- `ρ::Real`: Material density (mass per unit area)

# Returns
- `I::Float64`: Moment of inertia about the z-axis through centroid
"""
function inertia(b::Box, ρ::Real)::Float64
    ρ > 0 || throw(ArgumentError("Density must be positive"))
    m = ρ * area(b)
    return (m / 12) * (b.width^2 + b.height^2)
end

"""
    vertices(b::Box) -> Vector{Vec2}

Get the four corner vertices of a box in local coordinates.
Returns vertices in counter-clockwise order starting from bottom-left.
"""
function vertices(b::Box)::Vector{Vec2}
    hw, hh = b.width / 2, b.height / 2
    return [
        Vec2(-hw, -hh),  # Bottom-left
        Vec2(hw, -hh),   # Bottom-right
        Vec2(hw, hh),    # Top-right
        Vec2(-hw, hh)    # Top-left
    ]
end

##########################################################################################
# Polygon (Convex)
##########################################################################################

"""
    Polygon <: Shape

A convex polygon shape defined by vertices.

# Fields
- `vertices::Vector{Vec2}`: Vertices in counter-clockwise order (must be ≥ 3)

Note: The polygon is assumed to be convex. Centroid and inertia calculations
are only valid for convex polygons.
"""
struct Polygon <: Shape
    vertices::Vector{Vec2}

    function Polygon(vertices::Vector{Vec2})
        length(vertices) >= 3 || throw(ArgumentError("Polygon must have at least 3 vertices"))
        new(vertices)
    end
end

"""
    Polygon(vertices::Vector{<:AbstractVector{<:Real}})

Create a polygon from a vector of numeric vectors.
"""
function Polygon(vertices::Vector{<:AbstractVector{<:Real}})
    v = [Vec2(v[1], v[2]) for v in vertices]
    return Polygon(v)
end

"""
    area(p::Polygon) -> Float64

Compute the signed area of a polygon using the shoelace formula.
Returns positive area for counter-clockwise vertex ordering.

Area = (1/2) * |∑(xᵢ * yᵢ₊₁ - xᵢ₊₁ * yᵢ)|
"""
function area(p::Polygon)::Float64
    n = length(p.vertices)
    A = 0.0
    for i in 1:n
        j = mod1(i + 1, n)
        A += p.vertices[i].x * p.vertices[j].y
        A -= p.vertices[j].x * p.vertices[i].y
    end
    return abs(A) / 2
end

"""
    centroid(p::Polygon) -> Vec2

Compute the centroid of a polygon.

For a polygon with vertices (xᵢ, yᵢ):
- Cₓ = (1/6A) * ∑(xᵢ + xᵢ₊₁)(xᵢyᵢ₊₁ - xᵢ₊₁yᵢ)
- Cᵧ = (1/6A) * ∑(yᵢ + yᵢ₊₁)(xᵢyᵢ₊₁ - xᵢ₊₁yᵢ)
"""
function centroid(p::Polygon)::Vec2
    n = length(p.vertices)
    A = area(p)
    cx, cy = 0.0, 0.0

    for i in 1:n
        j = mod1(i + 1, n)
        cross = p.vertices[i].x * p.vertices[j].y - p.vertices[j].x * p.vertices[i].y
        cx += (p.vertices[i].x + p.vertices[j].x) * cross
        cy += (p.vertices[i].y + p.vertices[j].y) * cross
    end

    return Vec2(cx / (6 * A), cy / (6 * A))
end

"""
    inertia(p::Polygon, ρ::Real) -> Float64

Compute the moment of inertia of a polygon about its centroid.

Uses the formula:
I = ρ * ∑[(xᵢyᵢ₊₁ - xᵢ₊₁yᵢ) * (xᵢ² + xᵢxᵢ₊₁ + xᵢ₊₁² + yᵢ² + yᵢyᵢ₊₁ + yᵢ₊₁²)] / 12

Then applies parallel axis theorem to shift to centroid.

# Arguments
- `p::Polygon`: The polygon shape
- `ρ::Real`: Material density (mass per unit area)

# Returns
- `I::Float64`: Moment of inertia about the z-axis through centroid
"""
function inertia(p::Polygon, ρ::Real)::Float64
    ρ > 0 || throw(ArgumentError("Density must be positive"))

    n = length(p.vertices)
    c = centroid(p)

    # Translate vertices to centroid frame
    v_centered = [v - c for v in p.vertices]

    # Compute inertia about centroid
    I = 0.0
    for i in 1:n
        j = mod1(i + 1, n)
        v1, v2 = v_centered[i], v_centered[j]

        cross = v1.x * v2.y - v2.x * v1.y
        term = v1.x^2 + v1.x * v2.x + v2.x^2 + v1.y^2 + v1.y * v2.y + v2.y^2
        I += cross * term
    end

    m = ρ * area(p)
    return ρ * abs(I) / 12
end