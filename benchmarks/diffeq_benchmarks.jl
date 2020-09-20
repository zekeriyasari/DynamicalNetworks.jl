using DifferentialEquations
using JLD2 
using BenchmarkTools 
using LinearAlgebra
using JSON

function lorenz!(dx, x, σ=10., β=8/3, ρ=28.)
    dx[1] = σ * (x[2] - x[1])
    dx[2] = (ρ - x[3]) * x[1] - x[2] 
    dx[3] = x[1] * x[2] - β * x[3]
end

function drift!(dx, x, (E, H, P), t)
    for idx in Iterators.partition(1 : length(x), 3)
        lorenz!(view(dx, idx), view(x, idx))
    end 
    dx .+= kron(E, P) * x
end

function diffusion!(dx, x, (E, H, P), t)
    dx .= kron(H, P)  
end

function getprob(nbits, tbit, ϵ=10.) 
    ti = 0. 
    dt = 0.01 
    tf = nbits * tbit
    E = ϵ * [
        -3 3 -1 1; 
        3 -3 1 -1; 
        -1 1 -3 3; 
        1 -1 3 -3.
    ]
    H = [
        0 0 1 1; 
        0 0 1 1; 
        -1 -1 0 0; 
        -1 -1 0 0
    ]
    P = [1. 0 0; 0 0 0; 0 0 0]
    SDEProblem(drift!, diffusion!, ones(12), (ti, tf), (E, H, P), noise_rate_prototype=zeros(12, 12))
end

function runbench(nbits, tbit)
    for nbit in nbits 
        # Run benchmark 
        prob = getprob(nbit, tbit) 
        bench = @benchmark solve($prob, maxiters=typemax(Int))
        
        # Display benchmark 
        display(bench)
        
        # Save benchmark 
        benchdir = joinpath(@__DIR__, "jsons")
        BenchmarkTools.save(joinpath(benchdir, "$(nbit)_bits_diffeq_benchmark.json"), bench)

        # Save memory usage. 
        d = Dict("RAM" => "$(round(memory(bench) / 1024 / 1024)) MiB")
        open(joinpath(benchdir, "$(nbit)_bits_diffeq_memory.json"), "w") do file 
            JSON.print(file, d)
        end
    end
end

nbits = [1, 10, 100]
tbit = 50. 
runbench(nbits, tbit)
