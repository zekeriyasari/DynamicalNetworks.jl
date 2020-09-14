using Distributed 

# Add one single worker process to solve ODEProblem 
addprocs(1)

# Load DifferentialEquations package to all process 
@everywhere begin 
    # Activate the environment in which DifferentialEquations is added.
    using Pkg 
    Pkg.activate(joinpath(Pkg.envdir(), "dev-env"))

    # Now load DifferentialEquations
    using DifferentialEquations 

    # Define worker function to solve ODEProblem 
    function worker_func(prob_channel)
        while true 
            prob = take!(prob_channel) 
            @show "Took $(prob.u0)"
            sol = solve(prob) 
            @show sol.retcode
        end
    end
end

# Construct a remote channel in the main process 
const prob_channel = RemoteChannel(() -> Channel())

# Start the tasks in the remote worker process, The process is of the worker process is 2. 
remote_do(worker_func, 2, prob_channel)

# Define some ODEProblems 
probs = map(n -> ODEProblem((dx, x, u, t) -> (dx .= -x), [n], (0., 1.)), 1 : 100)

# Send the first problem to solve. 
# NOTE: When the line below is executed, we get an error. 
put!(prob_channel, probs[1])

