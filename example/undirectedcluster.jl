using LightGraphs 
using LinearAlgebra
using BlockArrays
using DynamicalNetworks 
using Plots 

# Settings 
n = 6  # Number of nodes 
d = 3   # Dimension of nodes 
cls = Cluster(1 : n, [n ÷ 2, n])   # Clusters 
k = DynamicalNetworks.clusterindex(cls)
l = length(cls.pinnednodes)
γ = 200 * ones(l)
node = Chua() 
# Φ = initmat(cls, UndirectedCluster())
Φ = BlockArray([
    -1. 1 0 0 0 0;
    1 -2 1 0 -1 1;
    0 1 -1 0 1 -1;
    0 0 0 -1 1 0;
    0 -1 1 1 -2 1;
    0 1 -1 0 1 -1
    ], k, k)
P = I(d)

# Construct the network model 
model = netmodel(node, Φ, γ, P, cls, UndirectedCluster())

# Simulate model 
ti, dt, tf = 0., 0.01, 100.
simulate!(model, ti, dt, tf)  

# Plot simulation data 
t, x = getcomponent(model, :writer) |> read 
plot(t,  abs.(getindex.(x, 1) - getindex.(x, 7)))


# # Construc QUAD matrices 
# θ = ceil(DynamicalNetworks.passivityindex(node))
# Δ = θ * I(d) 
# P = I(d) 

# # Compute threshold 
# δm = maximum(diag(Δ))
# μ(mat) = 1 / 2 * maximum(size(mat)) * maximum(abs.(mat))
# μm =  maximum([μ(getblock(Φ, i, j)) for i in 1 : l, j in 1 : l if i ≠ j])
# num = δm + 2 * (l - 1) * μm 
# denum = map(1 : l) do i 
#     bmat = copy(getblock(Φ, i, i))
#     bmat[end] -= γ[i] 
#     -maximum(eigvals(bmat))
# end |> maximum
# β = num / denum |> ceil

# # Construct the matrices 
# E = copy(Φ) 
# for i in 1 : l 
#     setblock!(E, β * getblock(E, i, i), i, i)
# end 
# α = β * γ
# A =  diagm(vcat([setindex!(zeros(k[i]), α[i], k[i]) for i in 1 : l]...))

# G = [zeros(l, l) zeros(l, n); zeros(n, l) E]
# H1 = zeros(n, l)
# for (ki, (j, αi)) in zip(J, enumerate(α))
#     H1[ki, j] = -αi
# end
# H2 = zeros(n, n)
# for (ki, αi) in zip(J, α)
#     H2[ki, ki] = αi
# end
# H = [zeros(l, l + n); [H1 H2]]

# Construct a model 
