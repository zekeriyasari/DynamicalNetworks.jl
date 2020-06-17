
# This file illustrates the simulation of time varyingly coupled dynamical systems 

using DynamicalNetworks 
using Plots 

#  Construct the netmodel 
n = 4 
d = 3 
ϵ = 10.
pcm = PCM(high=ϵ, low=0.01ϵ, period=50.) 
E = [
    t -> -3*pcm(t) t -> 3*pcm(t) t -> -1*pcm(t) t -> 1*pcm(t);
    t -> 3*pcm(t) t -> -3*pcm(t) t -> 1*pcm(t) t -> -1*pcm(t);
    t -> -1*pcm(t) t -> 1*pcm(t) t -> -3*pcm(t) t -> 3*pcm(t);
    t -> 1*pcm(t) t -> -1*pcm(t) t -> 3*pcm(t) t -> -3*pcm(t)
    ]
P = coupling(1, 3)
netmodel = network(ForcedLorenzSystem, E, P)

# Add writer to netmodel 
addnode!(netmodel, Writer(input=Inport(12)), label=:writer)
addbranch!(netmodel, :node1 => :writer, 1:3 => 1:3)
addbranch!(netmodel, :node2 => :writer, 1:3 => 4:6)
addbranch!(netmodel, :node3 => :writer, 1:3 => 7:9)
addbranch!(netmodel, :node4 => :writer, 1:3 => 10:12)

# Simulate the netmodel 
sim = simulate!(netmodel, 0., 0.01, 250)

# Read the simulation data 
t, x = read(getnode(netmodel, :writer).component)

# Plot the results 
plot(layout=(2,2))
plot!(t, x[:, 1], subplot=1)
plot!(x[:, 1] - x[:, 4], subplot=2)
plot!(x[:, 4] - x[:, 7], subplot=3)
plot!(x[:, 7] - x[:, 10], subplot=4)

