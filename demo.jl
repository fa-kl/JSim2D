using Pkg
Pkg.develop(path="JSim2D/")
Pkg.activate(".")

using JSim2D
using LinearAlgebra
using StaticArrays
using LaTeXStrings
using CairoMakie: Figure, Axis, lines!, xlims!, ylims!, poly!
using Parameters

world = SimWorld()
mech = Mechanism(:mech)

w0, h0 = 1, 0.5
w1, h1 = 2, 0.25
w2, h2 = 2, 0.25
d = 0.125

po1, co1 = Vec2(0.0, 0.0), Vec2(w1 / 2 - d, 0.0)
po2, co2 = Vec2(w1 / 2 - d, 0.0), Vec2(w2 / 2 - d, 0.0)

link1 = RigidBody(:link1, Box(w0, h0), Material(color=:grey))
link2 = RigidBody(:link2, Box(w1, h1), Material(color=:grey))
link3 = RigidBody(:link3, Box(w2, h2), Material(color=:grey))
add_body!(mech, link1)
add_body!(mech, link2)
add_body!(mech, link3)


joint1 = RevoluteJoint(id=:joint1; parent=link1, parent_offset=po1, child=link2, child_offset=co1)
joint2 = RevoluteJoint(id=:joint2; parent=link2, parent_offset=po2, child=link3, child_offset=co2)
add_joint!(mech, joint1)
add_joint!(mech, joint2)

add_mechanism!(world, mech)

fig = Figure(size=(700, 700))
ax11 = Axis(fig[1, 1], aspect=1.0)
ax12 = Axis(fig[1, 2], aspect=1.0)
ax21 = Axis(fig[2, 1], aspect=1.0)
ax22 = Axis(fig[2, 2], aspect=1.0)

initialize!(mech)
visualize!(ax11, mech)
xlims!(ax11, (-4, 4))
ylims!(ax11, (-4, 4))

apply_joint_coordinates!(mech, [0.0, π / 2])
visualize!(ax12, mech)
xlims!(ax12, (-4, 4))
ylims!(ax12, (-4, 4))

apply_joint_coordinates!(mech, [π / 2, 0.0])
visualize!(ax21, mech)
xlims!(ax21, (-4, 4))
ylims!(ax21, (-4, 4))

apply_joint_coordinates!(mech, [π / 2, π / 2])
visualize!(ax22, mech)
xlims!(ax22, (-4, 4))
ylims!(ax22, (-4, 4))

display(fig)