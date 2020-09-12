# This file includes the main script to run  multiple simulations. 
using Distributed 

# Add procs 
numcores = length(Sys.cpu_info()) 
numprocs = nprocs()
numprocs < numcores - 1 && addprocs(numcores - 1 - numprocs)  # Load procs 

# Load code 
@everywhere include(joinpath(@__DIR__, "worker.jl"))

# # Define problems 
# probs = map(α -> ODEProblem((dx, x, α, t) -> (dx .= -α * x), [1.], (0., 1000.), α), 1 : 250.)

# @time @sync @distributed for prob in probs 
#     solve(prob, saveat=0.01)
# end

# @time for prob in probs 
#     solve(prob, saveat=0.01)
# end

# println("Done")
