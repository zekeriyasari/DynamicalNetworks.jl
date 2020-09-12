# This file is to simulate time-variant dynamical network.

using DynamicalNetworks
using Plots 
using LightGraphs 
using LinearAlgebra

# Construct the model 
n = 4
d = 3 
ε = 20. 
T = 50.
E = [
    PCM(low=-(n-1) * ε, high=0., period=T) PCM(low=ε, high=0., period=T) PCM(low=ε, high=0., period=T) PCM(low=ε, high=0., period=T); 
    PCM(low=ε, high=0., period=T) PCM(low=-ε, high=0., period=T) PCM(low=0, high=0., period=T) PCM(low=0, high=0., period=T); 
    PCM(low=ε, high=0., period=T) PCM(low=0, high=0., period=T) PCM(low=-ε, high=0., period=T) PCM(low=0, high=0., period=T); 
    PCM(low=ε, high=0., period=T) PCM(low=0, high=0., period=T) PCM(low=0, high=0., period=T) PCM(low=-ε, high=0., period=T); 
]
P = diagm([1, 0, 0]) 
model = netmodel(NoisyLorenzSystem, E, P, nodekwargs=(eta=0.,), clock=Clock(0, 0.01, 100))

# Simulate the model
sim = simulate!(model)
t, x = read(getnode(model, :writer).component)

# Plot the results
plt = plot(layout=(2,2))
plot!(t, x[:, 1], label="node1", subplot=1)
plot!(t, x[:, 4], label="node2", subplot=2)
plot!(x[:, 1], x[:, 4], label="phase", subplot=3)
plot!(t, abs.(x[:, 1] - x[:, 4]), label="error", subplot=4)
plot!(t, E[1,2].(t), label="coupling", subplot=4)
display(plt)
