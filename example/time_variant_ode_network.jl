# This file includes an example for the simulation of a network with time varying coupling 

using DynamicalNetworks 
using Plots

# Construct network 
nbits = 5 
tbit = 50.
ϵ = 100.
u = PCM(bits=rand(Bool, nbits), period=tbit, high=ϵ) 
E = [
    t -> -3u(t) t -> 3u(t) t -> -u(t) t -> u(t); 
    t -> 3u(t)  t -> -3u(t) t -> -u(t) t -> u(t); 
    t -> -u(t) t -> u(t) t -> -3u(t) t -> 3u(t); 
    t -> u(t) t -> -u(t) t -> 3u(t) t -> -3u(t)
]
P = [1 0 0; 0 0 0; 0 0 0]
n = size(E, 1) 
d = size(P, 1)
nodes = [Lorenz() for i in 1 : n]
net = ODENetwork(nodes, E, P)

# Simulate network 
ti, dt, tf = 0., 0.01, nbits * tbit 
sim = simulate(net, ti, dt, tf)

# Read the simulation data 
t, x = readsim(sim)

# Plots 
plt = plot(layout=(5,1))
plot!(t, getindex.(x, 1), subplot=1)
plot!(t, abs.(getindex.(x, 1) - getindex.(x, 4)), subplot=2)
plot!(t, abs.(getindex.(x, 4) - getindex.(x, 7)), subplot=3)
plot!(t, abs.(getindex.(x, 7) - getindex.(x, 10)), subplot=4)
plot!(t, u.(t), subplot=5)

for i in 1 : length(plt.subplots)
    vline!(collect(t[1] : tbit : t[end]), subplot=i, ls=:dot)
end
display(plt)