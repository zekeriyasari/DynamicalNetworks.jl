# This file is an example file 

using DynamicalNetworks
using LightGraphs
using Plots

# Construct the model 
numnodes = 6 
dimnodes = 3 
node = Chua()
# Ξ = -collect(laplacian_matrix(star_graph(numnodes)))
Ξ = [
    -1  1   0   0   0   0; 
    1  -3   1   1   0   0; 
    0  1   -1   0   0   0; 
    0  1   0   -3   1   1; 
    0  0   0   1   -1   0; 
    0  0   0   1   0   -1
]
graph = SimpleGraph(Ξ)
gplot(graph, nodelabel=1 : nv(graph))
P = [1. 0 0; 0 0 0; 0 0 0]
cls = Cluster(1 : numnodes, 1 : numnodes ÷ 2)
model = netmodel(node, Ξ, P, cls, UndirectedFull())

# Simulate model 
ti, dt, tf = 0., 0.01, 100.
simulate!(model, ti, dt, tf)  

# Plot simulation data 
t, x = getcomponent(model, :writer) |> read 
plot(t,  abs.(getindex.(x, 1) - getindex.(x, 4)))
