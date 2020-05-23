# This file includes the simulation of time-varying network.

using DynamicalNetworks 
using Plots 

# Construct the network
n = 2 
d = 3 
ε = 10. 
T = 50.
E = [
    PCM(low=-ε, high=0., period=T) PCM(low=ε, high=0., period=T);
    PCM(low=ε, high=0., period=T)  PCM(low=-ε, high=0., period=T)
    ]
P = [1 0 0; 0 0 0; 0 0 0]
model = netmodel(LorenzSystem, E, P, clock=Clock(0., 0.01, 100.))
sim = simulate!(model)

# Read simuation data 
t, x = read(getnode(model, :writer).component)
u = E[1, 2].(t)

# Plot the results 
plt = plot(layout=(3,1))
plot!(t, x[:, 1], label="node1", subplot=1)
plot!(t, x[:, 4], label="node2", subplot=2)
plot!(t, abs.(x[:, 1] - x[:, 4]), label="error", subplot=3)
plot!(t, u, label="coupling", subplot=3, lw=2)
display(plt)