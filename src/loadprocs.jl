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
