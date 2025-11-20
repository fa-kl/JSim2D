##########################################################################################
# Joints
##########################################################################################


abstract type Joint end

##########################################################################################
# FixedJoint
##########################################################################################


@with_kw mutable struct FixedJoint <: Joint
    id::Symbol
    parent::RigidBody
    child::RigidBody
    parent_offset::Vec2
    child_offset::Vec2
end

# just so each joint has the same API
get_transform(j::FixedJoint)::Transform = Transform()
get_joint_coordinate(j::FixedJoint)::Float64 = 0.0
get_joint_velocity(j::FixedJoint)::Float64 = 0.0
apply_joint_coordinate!(j::FixedJoint, x::Float64) = nothing
apply_joint_velocity!(j::FixedJoint, x::Float64) = nothing

##########################################################################################
# RevoluteJoint
##########################################################################################


@with_kw mutable struct RevoluteJoint <: Joint
    id::Symbol
    parent::RigidBody
    child::RigidBody
    parent_offset::Vec2
    child_offset::Vec2
    θ::Float64 = 0.0            # angle
    ω::Float64 = 0.0            # angular velocity
end

get_transform(j::RevoluteJoint)::Transform = Transform(j.θ, Vec2(0.0, 0.0))
get_joint_coordinate(j::RevoluteJoint)::Float64 = j.θ
get_joint_velocity(j::RevoluteJoint)::Float64 = j.ω
apply_joint_coordinate!(j::RevoluteJoint, θ::Float64) = j.θ = θ
apply_joint_velocity!(j::RevoluteJoint, ω::Float64) = j.ω = ω

##########################################################################################
# PrismaticJoint
##########################################################################################


@with_kw mutable struct PrismaticJoint <: Joint
    id::Symbol
    parent::RigidBody
    child::RigidBody
    parent_offset::Vec2
    child_offset::Vec2
    p::Float64 = 0.0            # linear displacement
    ṗ::Float64 = 0.0            # linear velocity
end

get_transform(j::PrismaticJoint)::Transform = Transform(eye(2), j.child_offset + j.p * x̂)
get_joint_coordinate(j::PrismaticJoint)::Float64 = j.p
get_joint_velocity(j::PrismaticJoint)::Float64 = j.ṗ
apply_joint_coordinate!(j::PrismaticJoint, p::Float64) = j.p = p
apply_joint_velocity!(j::PrismaticJoint, ṗ::Float64) = j.ṗ = ṗ

