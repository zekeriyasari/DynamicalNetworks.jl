# This file illustrates the simulation of a network coupled by time-invariant coupling. 

using DynamicalNetworks 
using Plots 

# Construct network 
ϵ = 10. 
η = 5.
E = ϵ * [
    -1 1; 
    1 -1
    ]
H = η * [
    0 1; 
    -1 0
]
P = [1 0 0; 0 0 0; 0 0 0]
n = size(E, 1) 
d = size(P, 1)
nodes = [Lorenz() for i in 1 : n]
net = SDENetwork(nodes, E, H, P)

# Simulate network 
ti, dt, tf = 0., 0.01, 100.
sim = simulate(net, ti, dt, tf, solkwargs=(save_noise=true,))

# Read simulation data 
t, x, nt, nx = readsim(sim)

# Plots 
plt = plot(layout=(3,1))
plot!(t, getindex.(x, 1), subplot=1)
plot!(getindex.(x, 1), getindex.(x, 2), subplot=2)
plot!(t, abs.(getindex.(x, 1) - getindex.(x, 2)), subplot=3)
