using DynamicalNetworks 
using LightGraphs 
using Plots 

# Construct the network 
n = 4
d = 3 
C = [
    -3 3 -1 1;
    3 -3 1 -1;
    -1 1 -3 3;
    1 -1 3 -3;
    ]
ϵ = 10
netmodel = network(ForcedLorenzSystem, ϵ*C, coupling(1, d))

# Construct a writer 
addnode!(netmodel, Writer(input=Inport(12)), label = :writer)
addbranch!(netmodel, :node1 => :writer, 1:3 => 1:3)
addbranch!(netmodel, :node2 => :writer, 1:3 => 4:6)
addbranch!(netmodel, :node3 => :writer, 1:3 => 7:9)
addbranch!(netmodel, :node4 => :writer, 1:3 => 10:12)

# Simulate netmodel 
sim = simulate!(netmodel, 0., 0.01, 100.)

# Read the simulation data 
t, x = read(getnode(netmodel, :writer).component)

# Plot the simulation result 
p = plot(layout=(2,2))
plot!(t, x[:, 1], subplot=1)
plot!(x[:, 1], x[:, 2], subplot=2)
plot!(x[:, 1] - x[:, 4], subplot=3)
plot!(x[:, 1] - x[:, 7], subplot=4)

