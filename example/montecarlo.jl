# This file include a Monte-Carlo simulation of network. 

using DynamicalNetworks

# Contruct a network 
E = [-1 1; 1 -1] 
H = [0 1; -1 0]
P = [1 0 0; 0 0 0; 0 0 0]
n = size(E, 1) 
d = size(P, 1) 
nodes = [Lorenz() for i  in 1 : n]
net = SDENetwork(nodes, E, H, P)

# Run a monte carlo simulation 
vals = map(η -> η * H, 1 : 10)
mc = montecarlo(net, :H, vals)

# Print the content of the simulation directory 
foreach(println, readlines(`tree $(mc.path)`))
