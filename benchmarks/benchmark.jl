using Distributed 
using BenchmarkTools

addprocs(length(Sys.cpu_info()) - 1 - nprocs())
@everywhere begin 
    using Pkg 
    Pkg.activate(joinpath(Pkg.envdir(), "dev-env"))
    using DifferentialEquations
    drift!(dx, x, u, t) = (dx .= -x)
    diffusion!(dx, x, u, t) = (dx .= -1)
    function pmapworker(i, prob)
        sol = solve(prob, saveat=0.01, maxiters=typemax(Int))
        nothing
    end 
end 

function sequential(probs, ntrials)
    for prob in probs 
        for i in 1 : ntrials 
            solve(prob, saveat=0.01, maxiters=typemax(Int)) 
        end
    end 
end

function distributed(probs, ntrials)
    for prob in probs 
        @sync @distributed for prob in probs 
            solve(prob, saveat=0.01, maxiters=typemax(Int)) 
        end
    end 
end

function threaded(probs, ntrials)
    for prob in probs 
        Threads.@threads for i in 1 : ntrials
            solve(prob, saveat=0.01, maxiters=typemax(Int))
        end
    end
end

function pmapped(probs, ntrials)
    for prob in probs 
        pmap(i -> pmapworker(i, prob), 1 : ntrials)
    end
end

function runbench()
    nprobs = 1
    ntrials = 10
    probs = [SDEProblem(drift!, diffusion!, rand(12), (0., 5000.)) for i in 1 : nprobs]
    sequential_bench = @benchmark sequential($probs, $ntrials)
    @info "sequential_bench"
    display(sequential_bench)
    distributed_bench = @benchmark distributed($probs, $ntrials)
    @info "distributed_bench"
    display(distributed_bench)
    pmapped_bench = @benchmark pmapped($probs, $ntrials)
    @info "pmapped_bench" 
    display(pmapped_bench)
    threaded_bench = @benchmark threaded($probs, $ntrials)
    @info "threaded_bench" 
    display(threaded_bench)
end

# runbench()

nprobs = 1
ntrials = 7
probs = [SDEProblem(drift!, diffusion!, rand(12), (0., 50000.)) for i in 1 : nprobs]
pmapped(probs, ntrials)
