# This file is used to test DifferentialEquations with Distributed 

using Distributed 

# Load processes 
numcores = length(Sys.cpu_info())
numprocs = nprocs() 
numprocs ==  numcores - 1 || addprocs(numcores - 1 - numprocs) 

# Load the packages 
@everywhere begin 
    using Pkg 
    Pkg.activate(joinpath(Pkg.envdir(), "dev-env"))
    using DifferentialEquations 

    function solved_in(prob)
        println("$(prob.u0) in $(myid())")
        solve(prob)
    end 
end 

# Define problems 
probs = map(i -> ODEProblem((dx, x, u, t) -> (dx .= -x), Float64[i], (0., 1.)), 1 : 100)

# Solve the problems 
@sync @distributed for prob in probs 
    solved_in(prob) 
end 
