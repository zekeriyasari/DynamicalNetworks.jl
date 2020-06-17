using DynamicalNetworks 
using LightGraphs 
using Plots 

# Construct the network 
n = 4
d = 3 
ϵ = 0.1
netmodel = network(ForcedLorenzSystem, star_graph(n), coupling(1, d), weight=ϵ)

# Construct a writer 
addnode!(netmodel, Writer(input=Inport(6)), label = :writer)
addbranch!(netmodel, :node1 => :writer, 1:3 => 1:3)
addbranch!(netmodel, :node2 => :writer, 1:3 => 4:6)

# Simulate netmodel 
sim = simulate!(netmodel, 0., 0.01, 100.)

# Read the simulation data 
t, x = read(getnode(netmodel, :writer).component)

# Plot the simulation result 
layout = @layout [
    a 
    b 
    c]
p = plot(layout=layout)
plot!(t, x[:, 1], subplot=1)
plot!(x[:, 1], x[:, 2], subplot=2)
plot!(x[:, 1] - x[:, 4], subplot=3)

