##########################################################################################
# Visualizations
##########################################################################################

function visualize!(ax::Axis, points::Vector{Vec2}; color=:black)
    poly!(ax, [p.x for p ∈ points], [p.y for p ∈ points], color=color, strokecolor=:black, strokewidth=1)
end

function visualize!(ax::Axis, T::Transform; len::Float64=0.2)
    R, t = rotation(T), translation(T)
    lines!(ax, [t.x, t.x + len * R[1, 1]], [t.y, t.y + len * R[2, 1]], color=:blue)
    lines!(ax, [t.x, t.x + len * R[1, 2]], [t.y, t.y + len * R[2, 2]], color=:red)
    return nothing
end

function visualize!(ax::Axis, body::RigidBody)
    T = Transform(body.q)
    visualize!(ax, [T * v for v ∈ vertices(body.shape)]; color=body.material.color)
    visualize!(ax, T)
    return nothing
end

function visualize!(ax::Axis, joint::Joint; radius::Real=0.05, color=:black, Δϕ::Real=π / 8)
    T = Transform(joint.parent.q) ∘ Transform(0.0, joint.parent_offset) ∘ get_transform(joint)
    visualize!(ax, [T * Vec2(radius * cos(ϕ), radius * sin(ϕ)) for ϕ ∈ 0:Δϕ:(2*π)]; color=color)
    visualize!(ax, T)
    return nothing
end

function visualize!(ax::Axis, mech::Mechanism)
    T = Transform()
    traverse_mechanism_bodies(mech, body -> visualize!(ax, body))
    traverse_mechanism_joints(mech, joint -> visualize!(ax, joint))
    return nothing
end
