using Plots 
using LightGraphs 
using LinearAlgebra

n = 50 
graph = path_graph(n) 
Ξ = -collect(laplacian_matrix(SimpleGraph(graph)))

lr = 1 : n - 2
vals = map(lr) do l 
    m = n - l 
    eigvals(Ξ[1 : m, 1 : m]) |> maximum |> abs 
end 

plt = plot(lr, vals, marker=(:dot, 3), label="|λ(Ξ[2,2])|", xlabel="Number of Pins")
hline!([0.], linestyle=:dash, linewidth=2, label="Zero Level")
