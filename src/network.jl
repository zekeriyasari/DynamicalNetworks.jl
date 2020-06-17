# This file includes network functions. 

@def_model struct Network <: AbstractModel
    dynamics::DY 
    conmat::CM 
    cplmat::CP  
end 


"""
    network(dynamics, E, P; nodekwargs...) 

Constructs a network with node dynamics `dynamics` connection matrix E, coupling matric P 
"""
function network(dynamics, E::AbstractMatrix, P::AbstractMatrix; nodekwargs...)
    # Extract network dimensions
    n = size(E, 1) 
    d = size(P, 1) 

    # Construct model 
    model = Model() 

    # Construct the nodes 
    foreach(i -> addnode!(model, dynamics(input=Inport(d),output=Outport(d); nodekwargs...), label=Symbol("node$i")), 
        1 : n)
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

network(dynamics, topology::AbstractGraph, cplmat::AbstractMatrix, weight = 1.; nodekwargs...) = 
    network(dynamics, weight * collect(-laplacian_matrix(topology)), cplmat; nodekwargs...)
