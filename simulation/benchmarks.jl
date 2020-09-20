# Thsi file includes the benchmarks of running simulations 

using BenchmarkTools 
using DynamicalNetworks 

function getnet(nbits, tbit, ϵ=10.)
    # Time settings 
    ti = 0.
    dt = 0.01
    tf = nbits * tbit

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
    net = SDENetwork(nodes, E, H, P) 
end 

function runbench(nbits)
    tbit = 50.
    ti = 0.
    dt = 0.01 
    for nbit in nbits
        tf = nbit * tbit
        net = getnet(nbit, tbit)
        @show nbit
        display(
            @benchmark simulate($net, $ti, $dt, $tf, maxiters=typemax(Int))
            )
    end 
end

runbench([1, 10])

