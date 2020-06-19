using Distributed 

# Add procs 
numworkers = nworkers() 
numprocs = length(Sys.cpu_info())
numworkers == numprocs - 1 || addprocs(numprocs - numworkers - 2)

# Activate dev-env and load packages
@everywhere begin 
    using Pkg 
    Pkg.activate(joinpath(Pkg.envdir(), "dev-env"))
    using DifferentialEquations
    defprob() = ODEProblem((dx, x, u, t) -> (dx .= x), rand(1), (0., 1.))
    solve(defprob())
end

probs = [defprob() for i in 1  : 1000]

@info "parallel"
@time pmap(solve, probs)

@info "distributed"
@time @sync @distributed for prob in probs 
    solve(prob) 
end

@info "sequential"
@time for prob in probs 
    solve(prob) 
end

