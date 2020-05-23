

"""
    netmodel(dynamics, E, P)

Returns a ready-to-be-simulated network model. The nodes of network evolves by `dynamics`. `E` determines the topology and `P` determines the nodes are connected. `model_args` and `model_kwargs` are passed to `Model`.
"""
function netmodel(dynamics, E, P; clock=Clock(0., 0.01, 1.))
    # Construct the model 
    model = Model(clock=clock)

    # Construct the coupler 
    n = size(E)[1] 
    d = size(P)[1] 

    # Construct the nodes 
    foreach(i -> addnode!(model, dynamics(Inport(d), Outport(d)), label=Symbol("node$i")), 1 : n)
    addnode!(model, Coupler(E, P), label=Symbol("coupler"))
    addnode!(model, Writer(Inport(n * d)), label=Symbol("writer"))

    # Add branches to the model 
    cidx, widx = n + 1, n + 2
    for (j, k) in zip(1 : n, map(i -> i : i + d - 1, 1 : d : n * d))
        addbranch!(model, j => cidx, 1 : d => k)
        addbranch!(model, cidx => j, k => 1 : d)
        addbranch!(model, j => widx, 1 : d => k)
    end

    # Return the model 
    model 
end

function outer_matrix end 
function inner_matrix end 