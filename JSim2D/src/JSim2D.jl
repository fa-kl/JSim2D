module JSim2D

using LinearAlgebra
using StaticArrays
using LaTeXStrings
using CairoMakie: Figure, Axis, lines!, xlims!, ylims!, poly!
using Parameters

import Base.show
import Base.size
import Base.getindex
import Base.IndexStyle
import Base.∘
import Base.inv
import Base.*

include("types.jl")
export Vec2, x̂, ŷ
export Configuration, orientation, position
export Velocity, angular_velocity, linear_velocity
export Acceleration, angular_acceleration, linear_acceleration
export Wrench, torque, force
export show

include("math.jl")
export eye, orthogonalize, orthogonalize!, sat, sat!

include("rotations.jl")
export isrotmat, expSO2, logSO2
export Rotation, orientation
export ∘, *, inv
export show

include("transforms.jl")
export istransformmat, expSE2, logSE2
export Transform, rotation, orientation, translation, configuration
export ∘, *, inv

include("shapes.jl")
export Shape, Circle, Box, Polygon
export area, centroid, inertia, vertices

include("materials.jl")
export Material
export steel, wood, rubber, ice

include("bodies.jl")
export RigidBody

include("joints.jl")
export Joint
export FixedJoint, RevoluteJoint, PrismaticJoint
export get_transform
export get_joint_coordinate, get_joint_velocity

include("mechanism.jl")
export Mechanism
export get_body, get_joint
export add_body!, add_joint!
export get_joint_coordinates, get_joint_velocities
export apply_joint_coordinates!, apply_joint_velocities!

include("world.jl")
export SimWorld
export find_joint_linking
export get_body, get_joint, get_mechanism
export add_body!, add_joint!, add_mechanism!

include("visuals.jl")
export visualize!


end # module JSim2D
