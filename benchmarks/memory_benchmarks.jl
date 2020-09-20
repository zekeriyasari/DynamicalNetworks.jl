# This file includes the benchmark for running simulation 

using BenchmarkTools 
using DynamicalNetworks 
using JSON 
using JLD2

""" Returns a network of four nodes"""
function getnetwork(nbits, tbit, ϵ=10.)
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
    SDENetwork(nodes, E, H, P) 
end

""" Returns average data file size in units of KiB """
function getfilesize(benchpath) 
    filesizes = []
    for simdir in readdir(benchpath, join=true)
        filename = joinpath(simdir, "data.jld2")
        push!(filesizes, filesize(filename))
    end
    round(Int, sum(filesizes) / length(filesizes) / 1024) # Return in units of KiB
end

""" Runs benchmarks """
function runbench(nbits, tbit)
    # Check datadir 
    datadir = joinpath(@__DIR__, "jsons")
    isdir(datadir) || mkpath(datadir)

    benchdir = "/data/benchmarks"
    isdir(benchdir) || mkpath(benchdir)
    
    # Run benchmark
    ti = 0. 
    dt = 0.01 
    for nbit in nbits 
        net = getnetwork(nbit, tbit)
        tf = nbit * tbit
        bench = @benchmark simulate($net, $ti, $dt, $tf, maxiters=typemax(Int), path=$benchdir)

        # Display bechmark
        display(bench)
        
        # Save file size 
        d = Dict("datafilesize" => "$(getfilesize(benchdir)) KiB", "RAM" => "$(round(memory(bench) / 1024 / 1024)) MiB")
        open(joinpath(datadir, "$(nbit)_bits_memory.json"), "w") do file 
            JSON.print(file, d)
        end

        # Save benchmark  
        BenchmarkTools.save(joinpath(datadir, "$(nbit)_bits_benchmark.json"), bench)

        # Delete all simulation files 
        rm(benchdir, recursive=true)
    end
end

nbits = [1, 10, 100, 500] 
tbit = 50. 
runbench(nbits, tbit)
