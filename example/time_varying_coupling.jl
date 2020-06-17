
# This file illustrates the simulation of time varyingly coupled dynamical systems 

using DynamicalNetworks 
using Plots 

# Construct the netmodel 
n = 4 
d = 3 
T = 200. 
ti = 0. 
dt = 0.01 
tf = 1000.
ε = 10.
η = [1., 0., 0.]
pcm = PCM(high=ε, low=0.01ε, period=T) 

E = [
    t -> -3*pcm(t)  t -> 3*pcm(t)       t -> -ε     t -> ε;
    t -> 3*pcm(t)   t -> -3*pcm(t)      t -> ε      t -> -ε;
    t -> -ε         t -> ε              t -> -3ε    t -> 3ε;
    t -> ε          t -> -ε             t -> 3ε     t -> -3ε
    ]
P = coupling(1, 3)
netmodel = network(ForcedNoisyLorenzSystem, E, P, η=η)

# Add writer to netmodel 
addnode!(netmodel, Writer(input=Inport(12)), label=:writer)
addbranch!(netmodel, :node1 => :writer, 1:3 => 1:3)
addbranch!(netmodel, :node2 => :writer, 1:3 => 4:6)
addbranch!(netmodel, :node3 => :writer, 1:3 => 7:9)
addbranch!(netmodel, :node4 => :writer, 1:3 => 10:12)

# Simulate the netmodel 
sim = simulate!(netmodel, ti, dt, tf - dt)

# Read the simulation data 
t, x = read(getnode(netmodel, :writer).component)

# Plot the results 
plot(layout=(2,2), xticks = ti : T : tf)
plot!(t, x[:, 1],               subplot=1)
plot!(t, x[:, 1] - x[:, 4],     subplot=2)
plot!(t, x[:, 4] - x[:, 7],     subplot=3)
plot!(t, x[:, 7] - x[:, 10],    subplot=4)
