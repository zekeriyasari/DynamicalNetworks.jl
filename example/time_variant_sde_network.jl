# This file illustrates the simulation of a network with time variant network under noise 

using DynamicalNetworks 
using Plots 

# Construct a PCM
nbits = 10 
tbit = 50. 
ϵ = 10.
u = PCM(bits = rand(Bool, nbits), period=tbit, high = ϵ)

# Construct network 
η = 10.
E = [
    t -> -3u(t)  t -> 3u(t)   t -> -ϵ   t -> ϵ; 
    t -> 3u(t)   t -> -3u(t)  t -> ϵ    t -> -ϵ; 
    t -> -ϵ     t -> ϵ      t -> -3ϵ  t -> 3ϵ; 
    t -> ϵ      t -> -ϵ     t -> 3ϵ   t -> -3ϵ; 
    ]
H = η * [
     0   0  1   1; 
     0   0  1   1; 
    -1  -1  0   0; 
    -1  -1  0   0; 
]
P = [1 0 0; 0 0 0; 0 0 0]
n = size(E, 1) 
d = size(P, 1)
nodes = [Lorenz() for i in 1 : n]
net = SDENetwork(nodes, E, H, P)

# Simulate network 
ti, dt, tf = 0., 0.01, nbits * tbit
sim = simulate(net, ti, dt, tf, solkwargs=(save_noise=true,))

# Read simulation data 
t, x, nt, nx = readsim(sim)

# Plots 
plt = plot(layout=(5,1))
plot!(getindex.(x, 1), getindex.(x, 2), subplot=1)
plot!(t, abs.(getindex.(x, 1) - getindex.(x, 4)), subplot=2)
plot!(t, abs.(getindex.(x, 4) - getindex.(x, 7)), subplot=3)
plot!(t, abs.(getindex.(x, 7) - getindex.(x, 10)), subplot=4)
plot!(t, u.(t), subplot=5)

for i in 2 : length(plt.subplots)
    vline!(t[1] : tbit : t[end], ls=:dot, subplot=i)
end 
display(plt)
