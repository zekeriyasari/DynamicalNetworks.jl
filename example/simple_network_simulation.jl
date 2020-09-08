# This file includes a simple simulation 

using DynamicalNetworks
using Plots 
using LightGraphs

# Construct network 
n = 10 
d = 3 
ϵ = 10.
E = ϵ * collect(-laplacian_matrix(star_graph(n))) 
P = [1 0 0; 0 0 0; 0 0 0]
nodes = [Lorenz() for i in 1 : n]
net = Network(nodes, E, P)

# Simulate network 
ti, dt, tf = 0., 0.01, 100.
sim = simulate(net, ti, dt, tf)


# Read simulation data 
t, x = readsim(sim)

# Plot simulation 
signalflow(net)
plt = plot(layout=(floor(Int, n / 2) + 1, 2))
for i in 1 : n 
    plot!(t, getindex.(x, 1 + (i - 1) * d), subplot=i, label="")
end
plot!(t, abs.(getindex.(x, 1) - getindex.(x, 4)), subplot=n + 1)
