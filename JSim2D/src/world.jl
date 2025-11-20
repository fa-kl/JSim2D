##########################################################################################
# Simulation World
##########################################################################################

@with_kw mutable struct SimWorld
    bodies::Dict{Symbol,RigidBody} = Dict()
    joints::Dict{Symbol,Joint} = Dict()
    mechanisms::Dict{Symbol,Mechanism} = Dict()
    gravity::Vec2 = -9.81 * ŷ
end

function add_body!(world::SimWorld, body::RigidBody)
    if haskey(world.bodies, body.id)
        error("Body $(body.id) already exists in world!")
    end
    world.bodies[body.id] = body
    return body
end

function find_joint_linking(world::SimWorld, parent::Symbol, child::Symbol)
    for j in values(world.joints)
        if j.parent.id == parent && j.child.id == child
            return j
        end
    end
    throw(ArgumentError("No joint links parent $(parent) → child $(child)"))
end

function get_body(world::SimWorld, bodyid::Symbol)
    body = get(world.bodies, bodyid, nothing)
    body !== nothing || throw(ArgumentError("body ID $(bodyid) not found"))
    return body
end

function get_joint(world::SimWorld, jointid::Symbol)
    joint = get(world.joints, jointid, nothing)
    joint !== nothing || throw(ArgumentError("joint ID $(id) not found"))
    return joint
end

function get_mechanism(world::SimWorld, mechid::Symbol)
    mech = get(world.mechanisms, mechid, nothing)
    mech !== nothing || throw(ArgumentError("ID $(id) not found"))
    return mech
end

function add_joint!(world::SimWorld, joint::Joint)
    parent = joint.parent
    child = joint.child
    pid = parent.id
    cid = child.id
    if !haskey(world.bodies, pid)
        throw(ArgumentError("Parent body $(pid) not found in world"))
    end
    if !haskey(world.bodies, cid)
        throw(ArgumentError("Child body $(cid) not found in world"))
    end
    # Check tree constraints
    if child.parent !== nothing
        throw(ArgumentError("Body $(cid) already has a parent $(child.parent)"))
    end
    # Register joint
    world.joints[joint.id] = joint
    # Update body tree fields
    child.parent = pid
    push!(parent.children, cid)
    return nothing
end

function add_mechanism!(world::SimWorld, mech::Mechanism)
    if haskey(world.mechanisms, Symbol(mech.id))
        throw(ArgumentError("Mechanism $(mech.id) already exists in world!"))
    end
    # Add all bodies
    for body in values(mech.bodies)
        add_body!(world, body)
    end
    # Add all joints
    for joint in values(mech.joints)
        add_joint!(world, joint)
    end
    # Register mechanism
    world.mechanisms[Symbol(mech.id)] = mech
    return nothing
end