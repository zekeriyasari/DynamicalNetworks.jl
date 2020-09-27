using DynamicalNetworks
using Plots 

# Simulation setttings 
nbits = 10 
tbit = 100. 
ϵ = 10. 
η = 1. 
γ = 1. 
bits = rand(Bool, nbits) 
E = [
    PCM(bits=bits, period=tbit, high=-3ϵ) PCM(bits=bits, period=tbit, high=3ϵ);
    PCM(bits=bits, period=tbit, high=3ϵ)  PCM(bits=bits, period=tbit, high=-3ϵ)
]
P = [1 0 0; 0 0 0; 0 0 0]
H = η * [1, -1]
numnodes = size(E, 1) 
dimnodes = size(P, 1) 
nodes = [Lorenz(γ=γ) for n in 1 : numnodes]
net = SDENetwork(nodes, E, H, P)

# Solve network 
ti, dt, tf = 0., 0.01, nbits * tbit
sol = solvenet(net, ti, dt, tf)

# Plots the solution 
t, x = sol.t, sol.u 
plt = plot(layout=(5,1), size=(750, 800))
plot!(t, getindex.(x, 1), subplot=1)
plot!(getindex.(x, 1), getindex.(x, 2), subplot=2)
plot!(getindex.(x, 4), getindex.(x, 5), subplot=3)
plot!(t, abs.(getindex.(x, 1) - getindex.(x, 4)), subplot=4)
plot!(t, net.E[1,2].(t), subplot=5)
vline!(collect(ti : tbit : tf), ls=:dash, subplot=4)
display(plt)
