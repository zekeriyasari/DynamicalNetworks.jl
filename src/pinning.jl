# This file includes pinning control methods 

export Cluster, pinningratio, pinnednodes, unpinnednodes, UndirectedFull, UndirectedCluster, DirectedFull, DirectedCluster, 
    netmodel 


struct Cluster 
    nodes::Vector{Int}          # Total node index vector 
    pinnednodes::Vector{Int}    # Pinned node index vector
end 

pinningratio(cls::Cluster) = length(cls.pinnednodes) / length(cls.nodes)
pinnednodes(cls::Cluster) = cls.pinnednodes
unpinnednodes(cls::Cluster) = filter(node -> node ∉ cls.pinnednodes, cls.nodes)
function clusterindex(cls::Cluster) 
    n = length(cls.nodes)
    idx = diff(cls.pinnednodes) 
    pushfirst!(idx, n - sum(idx))
    idx
end 

struct UndirectedFull end 
struct UndirectedCluster end 
struct DirectedFull end 
struct DirectedCluster end

function netmodel(node::AbstractNodeDynamics, Ξ::AbstractMatrix, P::AbstractMatrix, cls::Cluster, method::UndirectedFull)
    θ = passivityindex(node) 
    ϵ = couplingthreshold(θ, Ξ, cls, method) |> ceil 
    α = controlthreshold(ϵ, θ, Ξ, cls, method) |> ceil
    A = controlmatrix(α, cls, method)
    G = augmentcouplingmatrix(Ξ, cls, method)
    H = augmentcontrolmatrix(A, cls, method)
    _netmodel(node, ϵ * (G - H), P)
end 

function netmodel(node::AbstractNodeDynamics, Φ::AbstractMatrix, γ::AbstractVector, P::AbstractMatrix, cls::Cluster, 
                  method::UndirectedCluster)
    # Construct QUAD matrices 
    @assert P == I(size(P, 1)) "Expected identity matrix for P"

    θ = ceil(DynamicalNetworks.passivityindex(node))
    β = controlthreshold(θ, Φ, γ, cls, method) |> ceil
    A = controlmatix(γ, β, cls, method)
    E = couplingmatrix(Φ, β, cls, method) 
    G = augmentcouplingmatrix(E, cls, method) 
    H = augmentcontrolmatrix(A, cls, method) 
    _netmodel(node, G - H, P)
end 

function netmodel(node::AbstractNodeDynamics, Ξ::AbstractMatrix, P::AbstractMatrix, cls::Cluster, method::DirectedFull)
    # TODO: Complete the method 
end 

function netmodel(node::AbstractNodeDynamics, Ξ::AbstractMatrix, P::AbstractMatrix, cls::Cluster, method::DirectedCluster)
    # TODO: Complete the method 
end 

function _netmodel(node::AbstractNodeDynamics, E::AbstractMatrix, P::AbstractMatrix)
    model = Model() 
    addnode!(model, Network(nodedynamics=node, outermat=E, innermat=P), label=:net)
    addnode!(model, Writer(input=VectorInport()), label=:writer)
    addbranch!(model, :net => :writer)
    model 
end 

# TODO:Implement computation of passivity index for other node types.
passivityindex(node::T) where {T} = error("Computation of passivity index is not implemeted for type of $T")
function passivityindex(node::Chua) 
    α, β, a = node.α, node.β, node.a
    A = [-α α 0; 1 -1 1; 0 -β 0]  
    Atilde = A + diagm([abs(a * α), 0, 0])
    θ = 1 / 2 * maximum(eigvals(Atilde + Atilde'))      # Passivity index 
end 

function couplingthreshold(θ::Real, Ξ::AbstractMatrix, cls::Cluster, method::UndirectedFull)
    l = length(cls.pinnednodes)
    Ξ22 = Ξ[l + 1 : end, l + 1 : end] 
    ϵ = θ / abs(maximum(eigvals(Ξ22)))
end 

function controlthreshold(ϵ::Real, θ::Real, Ξ::AbstractMatrix, cls::Cluster, method::UndirectedFull) 
    n = length(cls.nodes)
    l = length(cls.pinnednodes) 
    Γ = θ * I(n) + ϵ * Ξ
    Γ11, Γ12, Γ21, Γ22 = Γ[1 : l, 1 : l], Γ[1 : l, l + 1 : n], Γ[l + 1 : n, 1 : l], Γ[l + 1 : n, l + 1 : n] 
    α = 1 / ϵ * maximum(eigvals(Γ11 - Γ12 * inv(Γ22) * Γ12'))   # Control gain threshold
end 

function controlthreshold(θ::Real, Φ::AbstractMatrix, γ::AbstractVector, cls::Cluster, method::UndirectedCluster) 
    l = length(cls.pinnednodes)
    num = θ + 2 * (l - 1) * maximum([measure(getblock(Φ, i, j)) for i in 1 : l, j in 1 : l if i ≠ j])
    denum = map(1 : l) do i 
        bmat = getblock(Φ, i, i) 
        bmat[end] -= γ[i] 
        -maximum(eigvals(bmat))
    end |> maximum 
    β = num / denum
end 

measure(mat::AbstractMatrix) = 1 / 2 * maximum(size(mat)) * maximum(abs.(mat))

couplingmatrix(ϵ::Real, Ξ::AbstractMatrix, method::UndirectedFull) = ϵ * Ξ

function couplingmatrix(Φ::AbstractMatrix, β::Real, cls::Cluster,  method::UndirectedCluster)
    l = length(cls.pinnednodes)
    E = copy(Φ) 
    for i in 1 : l 
        setblock!(E, β * getblock(E, i, i), i, i)
    end 
    E 
end

function controlmatrix(α::Real, cls::Cluster, method::UndirectedFull) 
    n = length(cls.nodes)
    l = length(cls.pinnednodes)
    A = zeros(n, n) 
    A[diagind(A)[1 : l]] .= α
    A
end 

function controlmatix(γ::AbstractVector, β::Real, cls::Cluster, method::UndirectedCluster)
    l = length(cls.pinnednodes) 
    k = clusterindex(cls)
    α = β * γ
    A = diagm(vcat([setindex!(zeros(k[i]), α[i], k[i]) for i in 1 : l]...))    
end

function augmentcouplingmatrix(Ξ::AbstractMatrix,  cls::Cluster, method::UndirectedFull)
    n = length(cls.nodes)
    [zeros(n + 1) vcat(zeros(1, n), Ξ)]
end

function augmentcouplingmatrix(E::AbstractMatrix, cls::Cluster, method::UndirectedCluster)
    n = length(cls.nodes) 
    l = length(cls.pinnednodes)  
    G = [zeros(l, l) zeros(l, n); zeros(n, l) E]
end 

function augmentcouplingmatrix(Ξ::AbstractMatrix, cls::Cluster, method::DirectedFull) 
    # TODO: Complete the method 
end 

function augmentcouplingmatrix(Ξ::AbstractMatrix, cls::Cluster, method::DirectedCluster) 
    # TODO: Complete the method 
end 

function augmentcontrolmatrix(A::AbstractMatrix, cls::Cluster, method::UndirectedFull)
    n = length(cls.nodes)
    [zeros(1, n + 1); diagm(diag(A))' * [-ones(n) diagm(ones(n))]]
end 

function augmentcontrolmatrix(A::AbstractMatrix, cls::Cluster, method::UndirectedCluster)
    n = length(cls.nodes) 
    l = length(cls.pinnednodes)
    J = cls.pinnednodes
    α = filter(!iszero, diag(A))
    H1 = zeros(n, l)
    for (ki, (j, αi)) in zip(J, enumerate(α))
        H1[ki, j] = -αi
    end
    H2 = zeros(n, n)
    for (ki, αi) in zip(J, α)
        H2[ki, ki] = αi
    end
    H = [zeros(l, l + n); [H1 H2]]
end 

function augmentcontrolmatrix(A::AbstractMatrix, cls::Cluster, method::DirectedFull)
    # TODO: Complete the method
end 

function augmentcontrolmatrix(A::AbstractMatrix, cls::Cluster, method::DirectedCluster)
    # TODO: Complete the method
end 
