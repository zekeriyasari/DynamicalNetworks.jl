
# This file includes the codes to run on all the processes 

using Pkg 
dev_env_path = joinpath(Pkg.envdir(), "dev-env")
dirname(Pkg.project().path) == dev_env_path || Pkg.activate(dev_env_path) 

using DynamicalNetworks

println("Loaded")
