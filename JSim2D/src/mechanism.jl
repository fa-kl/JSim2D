##########################################################################################
# Mechanism
##########################################################################################

mutable struct Mechanism
    id::Symbol
    bodies::Dict{Symbol,RigidBody}
    joints::Dict{Symbol,Joint}
    q::Vector{Float64}
    q̇::Vector{Float64}

    function Mechanism(
        id::Symbol;
        bodies::Dict{Symbol,RigidBody}=Dict{Symbol,RigidBody}(),
        joints::Dict{Symbol,Joint}=Dict{Symbol,Joint}(),
        q₀::Vector{<:Real}=zeros(length(joints)),
        q̇₀::Vector{<:Real}=zeros(length(joints)))

        length(q₀) == length(joints) || throw(ArgumentError("q must have the same number of elements as joints"))
        length(q̇₀) == length(joints) || throw(ArgumentError("q̇ must have the same number of elements as joints"))
        new(id, bodies, joints, q₀, q̇₀)
    end
end

num_bodies(mech::Mechanism) = length(mech.bodies)
num_joints(mech::Mechanism) = length(mech.joints)

function get_body(mech::Mechanism, bodyid::Symbol)::RigidBody
    body = get(mech.bodies, bodyid, nothing)
    body !== nothing || throw(ArgumentError("body ID $(bodyid) not found"))
    return body
end

function get_joint(mech::Mechanism, jointid::Symbol)::RigidBody
    joint = get(mech.joints, jointid, nothing)
    joint !== nothing || throw(ArgumentError("joint ID $(id) not found"))
    return joint
end

function add_body!(mech::Mechanism, body::RigidBody)
    haskey(mech.bodies, body.id) && throw(ArgumentError("Body $(body.id) already exists in mechanism!"))
    mech.bodies[body.id] = body
    return body
end

function add_joint!(mech::Mechanism, joint::Joint)
    haskey(mech.joints, joint.id) && throw(ArgumentError("Joint $(joint.id) already exists in mechanism!"))
    mech.joints[joint.id] = joint
    return joint
end

function get_joint_coordinates(mech::Mechanism)::Vector{Float64}
    return traverse_mechanism_joints(mech, get_joint_coordinate)
end

function get_joint_velocities(mech::Mechanism)::Vector{Float64}
    return traverse_mechanism_joints(mech, get_joint_velocity)
end

function apply_joint_coordinates!(mech::Mechanism, q::Vector{<:Real})
    length(q) == num_joints(mech) || throw(ArgumentError("q must have the same number of elements as the mechanism $(mech.id) has joints"))
    traverse_mechanism_joints(mech, apply_joint_coordinate!, q)
    update_kinematics!(mech)
end

function apply_joint_velocities!(mech::Mechanism, q̇::Vector{<:Real})
    length(q̇) == num_joints(mech) || throw(ArgumentError("q̇ must have the same number of elements as the mechanism $(mech.id) has joints"))
    traverse_mechanism_joints(mech, apply_joint_velocity!, q̇)
    update_kinematics!(mech)
end

##########################################################################################
# Helper Methods
##########################################################################################

function find_root_body_ids(mech::Mechanism)::Set{Symbol}
    return filter(bid -> mech.bodies[bid].parent === nothing, keys(mech.bodies))
end

function find_root_joint_ids(mech::Mechanism)::Set{Symbol}
    root_bodies = Set([mech.bodies[bid] for bid in find_root_body_ids(mech)])
    return Set([jid for (jid, joint) in mech.joints if joint.parent in root_bodies])
end

function traverse_body(mech::Mechanism, body::RigidBody, visit_body::Function, vals, idx, results)
    if vals === nothing
        result = visit_body(body)
        push!(results, result)
    else
        visit_body(body, vals[idx])
    end
    for joint in values(mech.joints)
        if joint.parent === body
            traverse_joint(mech, joint, visit_body, vals, idx, results)
        end
    end
end

function traverse_joint(mech::Mechanism, joint::Joint, visit_body::Function, vals, idx, results)
    child_body = joint.child
    idx += 1
    traverse_body(mech, child_body, visit_body, vals, idx, results)
end

function traverse_mechanism_bodies(mech::Mechanism, visit_body::Function, vals=nothing)
    results = []
    idx = 1
    for root_id in find_root_body_ids(mech)
        traverse_body(mech, mech.bodies[root_id], visit_body, vals, idx, results)
    end
    return results
end

function traverse_mechanism_joints(mech::Mechanism, visit_joint::Function, vals=nothing)
    results = []
    idx = 1
    for joint_id in find_root_joint_ids(mech)
        traverse_joint_ordered(mech, mech.joints[joint_id], visit_joint, vals, idx, results)
    end
    return results
end

function traverse_joint_ordered(mech::Mechanism, joint::Joint, visit_joint::Function, vals, idx, results)
    if vals === nothing
        result = visit_joint(joint)
        push!(results, result)
    else
        visit_joint(joint, vals[idx])
    end
    child_body = joint.child
    for j in values(mech.joints)
        if j.parent === child_body
            idx += 1
            traverse_joint_ordered(mech, j, visit_joint, vals, idx, results)
        end
    end
end

function find_joint_linking(mech::Mechanism, parent::Symbol, child::Symbol)
    for j in values(mech.joints)
        if j.parent.id == parent && j.child.id == child
            return j
        end
    end
    throw(ArgumentError("No joint links parent $(parent) → child $(child)"))
end

function update_subtree!(mech::Mechanism, bodyid::Symbol, T_parent::Transform)
    body = get_body(mech, bodyid)
    if body.parent === nothing
        T_world = Transform(get_configuration(body))
    else
        joint = find_joint_linking(mech, body.parent, bodyid)
        T_world = T_parent ∘ Transform(0.0, joint.parent_offset) ∘ get_transform(joint) ∘ Transform(0.0, joint.child_offset)
    end
    body.q = configuration(T_world)
    mech.bodies[bodyid] = body
    for child_id in body.children
        update_subtree!(mech, child_id, T_world)
    end
end

function update_kinematics!(mech::Mechanism)
    roots = filter(b -> mech.bodies[b].parent === nothing,
        keys(mech.bodies))
    for rid in roots
        update_subtree!(mech, rid, Transform())
    end
end

function initialize!(mech::Mechanism)
    update_kinematics!(mech)
end