using DynamicalNetworks
using Plots 

# Simulation setttings 
nbits = 5 
tbit = 100. 
ϵ = 10. 
η = 20. 
γ = 1. 
bits = rand(Bool, nbits) 
E = reshape([
    PCM(bits=bits, period=tbit, high=-3ϵ),
    PCM(bits=bits, period=tbit, high=3ϵ),
    PCM(bits=bits, period=tbit, high=-ϵ),
    PCM(bits=bits, period=tbit, high=ϵ),

    PCM(bits=bits, period=tbit, high=3ϵ),
    PCM(bits=bits, period=tbit, high=-3ϵ),
    PCM(bits=bits, period=tbit, high=ϵ),
    PCM(bits=bits, period=tbit, high=-ϵ),
    
    PCM(bits=bits, period=tbit, high=-ϵ),
    PCM(bits=bits, period=tbit, high=ϵ),
    PCM(bits=bits, period=tbit, high=-3ϵ),
    PCM(bits=bits, period=tbit, high=3ϵ),

    PCM(bits=bits, period=tbit, high=ϵ),
    PCM(bits=bits, period=tbit, high=-ϵ),
    PCM(bits=bits, period=tbit, high=3ϵ),
    PCM(bits=bits, period=tbit, high=-3ϵ),
    ], 4, 4)
P = [1 0 0; 0 0 0; 0 0 0]
H = η * [
     1  1  0  0;
     0  0  1  1;
    -1  0 -1  0;
     0 -1  0 -1;
    ]
numnodes = size(E, 1) 
dimnodes = size(P, 1) 
nodes = [Lorenz(γ=γ) for n in 1 : numnodes]
net = SDENetwork(nodes, E, H, P)

# Solve network 
ti, dt, tf = 0., 0.01, nbits * tbit
sol = solvenet(net, ti, dt, tf, saveat=dt)

# Plots the solution 
t, x = sol.t, sol.u 
plt = plot(layout=(5,1), size=(700, 800))
plot!(getindex.(x, 7), getindex.(x, 8), subplot=1)
plot!(t, abs.(getindex.(x, 1) - getindex.(x, 4)), subplot=2)
plot!(t, abs.(getindex.(x, 4) - getindex.(x, 7)), subplot=3)
plot!(t, abs.(getindex.(x, 7) - getindex.(x, 10)), subplot=4)
plot!(t, net.E[1,2].(t), subplot=5)
foreach(i -> vline!(collect(ti : tbit : tf), ls=:dash, subplot=i), 2 : 5)
display(plt)
