# This file includes methods for a Monte-Carlo simulation of a network.

export MonteCarlo, montecarlo

"""
    $(TYPEDEF) 

# Fields 

    $(TYPEDFIELDS)
"""
struct MonteCarlo{T1, T2} 
    """Path of the simulation direcotry"""
    path::String 
    """Network simulated"""
    net::T1 
    """The name of the variable for which the MonteCarlo simulations is run"""
    varname::Symbol 
    """The values of the variable for which the MonteCarlo simulations is run"""
    vals::T2
    """Number of trials"""
    ntrials::Int 
    """Initial time of the simulation"""
    ti::Float64 
    """Sampling time of the simulation"""
    dt::Float64
    """Final time of the simulation"""
    tf::Float64
    """Number of cores time of the simulation"""
    ncores::Int 
    """Duration of the simulation in seconds"""
    duration::Float64
end 


"""
    $(SIGNATURES)

Perform a Monte-Carlo simulation by simulatin `net` for each value of `vals` by setting the `name` fieldname of `net`. `ntrials` is the number of trials. `simdir` is the simulation directory, `simprefix` is the prefix of the simulation directory and simname is the simulation name.
"""
function montecarlo(net, name::Symbol, vals; ntrials=10, simdir=tempdir(), simprefix="MonteCarlo-", simname=string(now()), 
    ti=0., dt=0.01, tf=100., ncores=numcores() - 1)

    @info "Started simulation...."

    # Determine monte carlo simulation path 
    montesimpath = joinpath(simdir, simprefix * simname) 

    # Load procs and package 
    @info "Addiing processes..."
    loadprocs(ncores)
    @info "Done."
    @info "Loading code to processes..."
    loadpackage()
    @info "Done."


    @info "Running MonteCarlo simulation..."
    # Run simulation 
    tinit = time()
    # NOTE: In using `@showprogress @distributed` implies `@sync `@distributed` 
    @showprogress @distributed for (idx, val) in collect(enumerate(vals))
        setfield!(net, name, val)
        @distributed for i in 1 : ntrials
            simulate(net, ti, dt, tf, path=joinpath(montesimpath, "Param-" * string(idx)), simname="Trial-$i", simprefix="")
        end
    end
    tfinal = time()
    @info "Done."

    # Construct a Monte-Carlo Object 
    mc = MonteCarlo(montesimpath, net, name, vals, ntrials, ti, dt, tf, ncores, tfinal - tinit)

    # Write MonteCarlo simulation info 
    @info "Writing simulation report...."
    jldopen(joinpath(montesimpath, "montecarlo.jld2"), "w") do file 
        file["report"] = mc
    end
    @info "Done."

    @info "Completed simulation."

    # Return MonteCarlo simulation.
    return mc
end

"""
    $(SIGNATURES) 

Add `n` processes. The processes to be added cannot exceeds the number of cores. 
"""
function loadprocs(n)
    na = numcores() - nprocs() - 1
    n ≤ na ? addprocs(n) : addprocs(na)
end

numcores() = length(Sys.cpu_info())

loadpackage() = @everywhere include(joinpath(@__DIR__, "loadprocs.jl"))
