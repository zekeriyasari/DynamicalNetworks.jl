# This file inludes the time scaling of dynamical systems.

using DynamicalNetworks 
using Plots 

function getnetwork(nbits, tbit, ϵ=10., η=1.)
    # Construt PCM 
    bits = rand(Bool, nbits) 
    E = [
        PCM(bits=bits, period=tbit, high=-3ϵ) PCM(bits=bits, period=tbit, high=3ϵ)  Constant(level=-ϵ)   Constant(level=ϵ); 
        PCM(bits=bits, period=tbit, high=3ϵ) PCM(bits=bits, period=tbit, high=-3ϵ) Constant(level=ϵ)    Constant(level=-ϵ); 
        Constant(level=-ϵ)                    Constant(level=ϵ)                    Constant(level=-3ϵ)  Constant(level=3ϵ); 
        Constant(level=ϵ)                    Constant(level=-ϵ)                   Constant(level=3ϵ)   Constant(level=-3ϵ); 
    ] 
    H = η * [
        0 0 1 1; 
        0 0 1 1; 
        -1 -1 0 0; 
        -1 -1 0 0.
        ]
    P = [1 0 0; 0 0 0; 0 0 0]
    n = size(E, 1) 
    d = size(P, 1) 
    nodes = [Lorenz(γ=100.) for i  in 1 : n]
    SDENetwork(nodes, E, H, P) 
end

# Construct a network 
nbits = 10
tbit = 1. 
ϵ = 500. 
η = 1. 
net = getnetwork(nbits, tbit, ϵ, η)

# Simulate the network 
ti = 0.
dt = 0.01 
tf  = nbits * tbit 
sim = simulate(net, ti, dt, tf)

# Read the simulation data 
t, x = readsim(sim) 
u = net.E[1, 2]

# Plot the results 
default(:label, "")

plt1 = plot(getindex.(x, 1), getindex.(x, 2))
display(plt1)

plt2 = plot(layout=(4,1))
plot!(t, abs.(getindex.(x, 1) - getindex.(x, 4)), subplot=1)
plot!(t, abs.(getindex.(x, 4) - getindex.(x, 7)), subplot=2)
plot!(t, abs.(getindex.(x, 7) - getindex.(x, 10)), subplot=3)
plot!(t, u.(t), subplot=4)

for i in 1 : length(plt2.subplots) - 1
    vline!(collect(t[1] : tbit : t[end]), subplot=i, linestyle=:dash)
end 
display(plt2)
