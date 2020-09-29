
function getnetwork(clargs)
    # Extract parameters 
    nbits = clargs["nbits"]
    tbit  = clargs["tbit"]
    ϵ     = clargs["coupling-strength"]
    γ     = clargs["time-scaling"]

    # Construct network 
    bits  = rand(Bool, nbits) 
    E = reshape([
        PCM(bits=bits, period=tbit, high=-3ϵ),
        PCM(bits=bits, period=tbit, high=3ϵ),
        Constant(level=-ϵ),
        Constant(level=ϵ),

        PCM(bits=bits, period=tbit, high=3ϵ),
        PCM(bits=bits, period=tbit, high=-3ϵ),
        Constant(level=ϵ),
        Constant(level=-ϵ),
        
        Constant(level=-ϵ),
        Constant(level=ϵ),
        Constant(level=-3ϵ),
        Constant(level=3ϵ),

        Constant(level=ϵ),
        Constant(level=-ϵ),
        Constant(level=3ϵ),
        Constant(level=-3ϵ),
        ], 4, 4)
    P = [1 0 0; 0 0 0; 0 0 0]
    H = [
         1  1  0  0;
         0  0  1  1;
        -1  0 -1  0;
         0 -1  0 -1.;
        ]
    numnodes = size(E, 1) 
    dimnodes = size(P, 1) 
    nodes = [Lorenz(γ=γ) for n in 1 : numnodes]
    SDENetwork(nodes, E, H, P)
end

