# This script runs the simulation 

using Distributed 
using Dates
using Logging 

# Add workers 
nw = nworkers() 
nc = length(Sys.cpu_info())
nw == nc - 1 || addprocs(nc - nw - 1)

# Code loading  
@everywhere include(joinpath(@__DIR__, "load.jl"))

# Construct simulation directory 
simdir = joinpath(tempdir(), "Simulation-"*string(now()))
ispath(simdir) || mkpath(simdir)

# Start simulation 
ηrange = 0.1 : 0.1 : 1.
@sync @distributed for η in ηrange 
    runsim(η, simdir=simdir, simname=string(η))
end 
