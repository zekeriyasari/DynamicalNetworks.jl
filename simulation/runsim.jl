# This file includes methods for a Monte-Carlo simulation of a network.

function runsim(clargs) 
    # Extract simulation parameters 
    simdir     = clargs["simdir"]
    simprefix  = clargs["simprefix"]
    minsnr     = clargs["minsnr"]
    maxsnr     = clargs["maxsnr"]
    stepsnr    = clargs["stepsnr"]
    sequential = clargs["sequential"] 
    dt         = clargs["dt"]
    nbits      = clargs["nbits"]
    tbit       = clargs["tbit"]
    savenoise  = clargs["savenoise"]
    maxiters   = clargs["maxiters"]
    ntrials    = clargs["ntrials"]
    ncores     = clargs["ncores"]
    loglevel   = clargs["loglevel"]

    # Construct monte carlo simulation path 
    simname = replace(split(string(now()), ".")[1], ":" => "-")
    montesimpath = joinpath(simdir, simprefix * simname) 
    isdir(montesimpath) || mkpath(montesimpath)

    # Set the logger
    logger = setlogger(montesimpath, loglevel)

    # Start simulation
    tinit = time()
    @info "Started simulation with settings" clargs

    # Construct network 
    @info "Constructing network..."
    net = getnetwork(clargs)
    @info "Done."

    # Computer signal power 
    @info "Computing signal power..."
    power = getpower(net, clargs, maxiters=maxiters)
    @info "Done."

    # Simulation time settings
    ti = 0. 
    tf = nbits * tbit

    # Determine snr range 
    @info "Running simulation..."
    if sequential
        runsequential(net, minsnr:stepsnr:maxsnr, ntrials, ti, dt, tf, power, montesimpath, savenoise, maxiters)
    else
        runparallel(net, minsnr:stepsnr:maxsnr, ntrials, ti, dt, tf, power, montesimpath, savenoise, maxiters, ncores)
    end
    @info "Done."
    tfinal = time()
    clargs["duration"] = tfinal - tinit

    # Write simulation report.
    @info "Writing simulation report..."
    writereport(montesimpath, clargs)
    @info "Done"
    
    # Close logger
    close(logger.stream)
end

function runparallel(net, snrrange, ntrials, ti, dt, tf, power, montesimpath, savenoise, maxiters, ncores)
    loadprocs(ncores) 
    loadpackage()
    H0 = copy(net.H)
    @showprogress for snr in snrrange
        @sync @distributed for i in 1 : ntrials
            net.H = H0 * snr_to_std(snr, power)
            worker(net, ti, dt, tf, path=joinpath(montesimpath, "$snr-dB"), simname="Trial-$i", simprefix="", 
                savenoise=savenoise, maxiters=maxiters)
        end
    end
end

function runsequential(net, snrrange, ntrials, ti, dt, tf, power, montesimpath, savenoise, maxiters)
    include(joinpath(@__DIR__, "loadprocs.jl"))
    @showprogress for snr in snrrange
        for i in 1 : ntrials
            net.H .*= snr_to_std(snr, power)
            worker(net, ti, dt, tf, path=joinpath(montesimpath, "$idx-dB"), simname="Trial-$i", simprefix="",     
                savenoise=savenoise, maxiters=maxiters)
        end
    end
end

numcores() = length(Sys.cpu_info())

loadpackage() = @everywhere include(joinpath(@__DIR__, "loadprocs.jl"))

function loadprocs(n)
    na = numcores() - nprocs() - 1
    n ≤ na ? addprocs(n) : addprocs(na)
end
