
function getnetwork(clargs)
    # Unpack clargs 
    nbits = getindex(clargs, :nbits)
    tbit = getindex(clargs, :tbit) 
    ϵ = getindex(clargs, :strength)

    # Construt PCM 
    bits = rand(Bool, nbits) 
    E = [
        PCM(bits=bits, period=tbit, high=-3ϵ) PCM(bits=bits, period=tbit, high=3ϵ)  Constant(level=-ϵ)   Constant(level=ϵ); 
        PCM(bits=bits, period=tbit, high=3ϵ) PCM(bits=bits, period=tbit, high=-3ϵ) Constant(level=ϵ)    Constant(level=-ϵ); 
        Constant(level=-ϵ)                    Constant(level=ϵ)                    Constant(level=-3ϵ)  Constant(level=3ϵ); 
        Constant(level=ϵ)                    Constant(level=-ϵ)                   Constant(level=3ϵ)   Constant(level=-3ϵ); 
    ] 
    H = [
        0 0 1 1; 
        0 0 1 1; 
        -1 -1 0 0; 
        -1 -1 0 0.
        ]
    P = [1 0 0; 0 0 0; 0 0 0]
    n = size(E, 1) 
    d = size(P, 1) 
    nodes = [Lorenz() for i  in 1 : n]
    return SDENetwork(nodes, E, H, P) 
end