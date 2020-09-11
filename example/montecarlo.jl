using Distributed 

# Add processess
numcores = length(Sys.cpu_info())
numworkers = nworkers()
numworkers < numcores - 1 && addprocs(numcores - numworkers - 1)

# Activate dev-env in all proceses  
@everywhere begin 
    using Pkg
    Pkg.activate(joinpath(Pkg.envdir(), "dev-env"))
    using DynamicalNetworks 
end
