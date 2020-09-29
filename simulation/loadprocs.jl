# This file includes the codes to be loaded on all the processes.

# Activate dev-env and load `DynamicalNetworks` package 
using Pkg 

try
    using DynamicalNetworks
catch ex 
    try 
        dev_env_path = joinpath(Pkg.envdir(), "dev-env")
        dirname(Pkg.project().path) == dev_env_path || Pkg.activate(dev_env_path) 
        using DynamicalNetworks
    catch ex2 
        Pkg.add(url="https://github.com/zekeriyasari/DynamicalNetworks.jl")
        using DynamicalNetworks
    end
end 

try 
    using JLD2
catch ex 
    Pkg.add("JLD2")
    using JLD2
end 

snr_to_std(snr, power) = sqrt(power / (10^(snr / 10)))

sentbits(net) = net.E[1,1].bits

function worker(net, ti, dt, tf; path="", simname="", simprefix="", savenoise=false, maxiters=typemax(Int))
    sim = simulate(net, ti, dt, tf, path=path, simname=simname, simprefix=simprefix, savenoise=savenoise, 
        maxiters=maxiters)
    write_sentbits(sim.path, sentbits(net))
end 

function write_sentbits(path, sentbits)
    filename = joinpath(path, "sentbits.jld2")
    jldopen(filename, "w") do file 
        file["bits"] = sentbits
    end
end
