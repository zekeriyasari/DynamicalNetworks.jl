# This file includes network functions. 

function network(components::AbstractVector{<:AbstractDynamicSystem}, E::AbstractMatrix, P::AbstractMatrix)
    # Extract network dimensions
    n = size(E, 1) 
    d = size(P, 1) 

    # Construct model 
    model = Model() 

    # Construct the components 
    for (i, component) in enumerate(components)
        addnode!(model, component, label=Symbol("node$i"))
    end
    addnode!(model, Coupler(conmat=E, cplmat=P), label=Symbol("coupler"))

    # Add branches to the model 
    coupleridx = n + 1
    for (j, k) in zip(1 : n, map(i -> i : i + d - 1, 1 : d : n * d))
        addbranch!(model, j => coupleridx, 1 : d => k)
        addbranch!(model, coupleridx => j, k => 1 : d)
    end

    # Return the model 
    model
end

function network(dynamics::Type{<:AbstractDynamicSystem}, E::AbstractMatrix, P::AbstractMatrix; kwargs...)
    n = size(E, 1)
    d = size(P, 1)
    components = [dynamics(input=Inport(d),output=Outport(d); kwargs...) for i in 1 : n]
    network(components, E, P)
end

network(components::AbstractVector{<:AbstractDynamicSystem}, topology::AbstractGraph, P::AbstractMatrix; 
    weight=1., kwargs...) = network(components,  weight * collect(-laplacian_matrix(topology)), P)
network(dynamics::Type{<:AbstractDynamicSystem}, topology::AbstractGraph, P::AbstractMatrix; weight=1., kwargs...) = 
    network(dynamics,  weight * collect(-laplacian_matrix(topology)), P; weight = 1., kwargs...)


"""
    coupling(n, d)

Returns 
"""
function coupling(n::Int, d::Int)
    v = zeros(d)
    v[n] = 1.
    diagm(v)
end

function coupling(n::AbstractVector, d::Int)
    v = zeros(d)
    v[n] .= 1.
    diagm(v)
end
