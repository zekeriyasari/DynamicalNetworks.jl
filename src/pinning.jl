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


struct UndirectedFull end 
struct UndirectedCluster end 
struct DirectedFull end 
struct DirectedCluster end

function netmodel(node::AbstractNodeDynamics, Ξ::AbstractMatrix, P::AbstractMatrix, cls::Cluster, method::UndirectedFull)
    θ = passivityindex(node) 
    ϵ = couplingthreshold(θ, Ξ, cls) * 2
    α = controlthreshold(ϵ, θ, Ξ, cls) * 2
    A = controlmatrix(α, cls)
    G = augmentcouplingmatrix(Ξ, cls, method)
    H = augmentcontrolmatrix(A, cls, method)
    _netmodel(node, ϵ * (G - H), P)
end 

function netmodel(node::AbstractNodeDynamics, Ξ::AbstractMatrix, P::AbstractMatrix, cls::Cluster, method::UndirectedCluster)
    # TODO: Complete the method 
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

function couplingthreshold(θ::Real, Ξ::AbstractMatrix, cls::Cluster)
    l = length(cls.pinnednodes)
    Ξ22 = Ξ[l + 1 : end, l + 1 : end] 
    ϵ = θ / abs(maximum(eigvals(Ξ22)))
end 

function controlthreshold(ϵ::Real, θ::Real, Ξ::AbstractMatrix, cls::Cluster) 
    n = length(cls.nodes)
    l = length(cls.pinnednodes) 
    Γ = θ * I(n) + ϵ * Ξ
    Γ11, Γ12, Γ21, Γ22 = Γ[1 : l, 1 : l], Γ[1 : l, l + 1 : n], Γ[l + 1 : n, 1 : l], Γ[l + 1 : n, l + 1 : n] 
    α = 1 / ϵ * maximum(eigvals(Γ11 - Γ12 * inv(Γ22) * Γ12'))   # Control gain threshold
end 

function controlmatrix(α::Real, cls::Cluster) 
    n = length(cls.nodes)
    l = length(cls.pinnednodes)
    A = zeros(n, n) 
    A[diagind(A)[1 : l]] .= α
    A
end 

function augmentcouplingmatrix(Ξ::AbstractMatrix,  cls::Cluster, method::UndirectedFull)
    n = length(cls.nodes)
    [zeros(n + 1) vcat(zeros(1, n), Ξ)]
end

function augmentcouplingmatrix(Ξ::AbstractMatrix, cls::Cluster, method::UndirectedCluster) 
    # TODO: Complete the method 
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
    # TODO: Complete the method
end 

function augmentcontrolmatrix(A::AbstractMatrix, cls::Cluster, method::DirectedFull)
    # TODO: Complete the method
end 

function augmentcontrolmatrix(A::AbstractMatrix, cls::Cluster, method::DirectedCluster)
    # TODO: Complete the method
end 
