using Distributed

# Include files 
include(joinpath(@__DIR__, "network.jl"))
include(joinpath(@__DIR__, "setlogger.jl"))
include(joinpath(@__DIR__, "getclargs.jl"))
include(joinpath(@__DIR__, "getnetwork.jl"))
include(joinpath(@__DIR__, "getpower.jl"))
include(joinpath(@__DIR__, "runsequential.jl"))
include(joinpath(@__DIR__, "rundistributed.jl"))
include(joinpath(@__DIR__, "runthreaded.jl"))
include(joinpath(@__DIR__, "runpmap.jl"))
include(joinpath(@__DIR__, "writedata.jl"))
include(joinpath(@__DIR__, "writebits.jl"))
include(joinpath(@__DIR__, "writesimreport.jl"))

# Read simulation settings
clargs = getclargs()

# Extract simulation parameters 
simdir     = clargs["simdir"]
simprefix  = clargs["simprefix"]
minsnr     = clargs["minsnr"]
maxsnr     = clargs["maxsnr"]
stepsnr    = clargs["stepsnr"]
mode       = clargs["mode"] 
dt         = clargs["dt"]
nbits      = clargs["nbits"]
tbit       = clargs["tbit"]
savenoise  = clargs["savenoise"]
maxiters   = clargs["maxiters"]
ntrials    = clargs["ntrials"]
ncores     = clargs["ncores"]
loglevel   = clargs["loglevel"]

# Construct simulation path 
simpath = joinpath(simdir, simprefix * string(Dates.format(now(), "yy-mm-dd-HH-MM-SS")))
isdir(simpath) || mkpath(simpath)

# Set the logger
logger = setlogger(simpath, loglevel)

# Start simulation
tinit = time()
@info "Started simulation with settings" clargs

# Construct network 
@info "Constructing network..."
net = getnetwork(clargs)
@info "Done."

# Computer signal power 
@info "Computing signal power..."
power = getpower(net, clargs, maxiters=maxiters, saveat=dt)
@info "Done."

# Simulation time settings
ti = 0. 
tf = nbits * tbit

# Determine snr range 
@info "Running simulation..."
if mode == "sequential"
    runsequential(net, minsnr, stepsnr, maxsnr, ntrials, ti, dt, tf, power, simpath, savenoise, maxiters)
elseif mode == "threaded"
    runthreaded(net, minsnr, stepsnr, maxsnr, ntrials, ti, dt, tf, power, simpath, savenoise, maxiters)
elseif mode == "distributed"
    na = length(Sys.cpu_info()) - 1 - nprocs()
    ncores ≤ na ? addprocs(ncores) : addprocs(na)
    @everywhere begin
        using Pkg 
        dev_env_path = joinpath(Pkg.envdir(), "dev-env")
        dirname(Pkg.project().path) == dev_env_path || Pkg.activate(dev_env_path) 
        include(joinpath(@__DIR__, "network.jl"))
        include(joinpath(@__DIR__, "writedata.jl"))
        include(joinpath(@__DIR__, "writebits.jl"))
    end
    rundistributed(net, minsnr, stepsnr, maxsnr, ntrials, ti, dt, tf, power, simpath, savenoise, maxiters)
elseif mode == "pmap"
    na = length(Sys.cpu_info()) - 1 - nprocs()
    ncores ≤ na ? addprocs(ncores) : addprocs(na)
    @everywhere begin
        using Pkg 
        dev_env_path = joinpath(Pkg.envdir(), "dev-env")
        dirname(Pkg.project().path) == dev_env_path || Pkg.activate(dev_env_path) 
        include(joinpath(@__DIR__, "pmapworker.jl"))
        include(joinpath(@__DIR__, "network.jl"))
        include(joinpath(@__DIR__, "writedata.jl"))
        include(joinpath(@__DIR__, "writebits.jl"))
    end
    runpmap(net, minsnr, stepsnr, maxsnr, ntrials, ti, dt, tf, power, simpath, savenoise, maxiters)
end
@info "Done."
tfinal = time()
clargs["duration"] = tfinal - tinit

# Write simulation report.
@info "Writing simulation report..."
writesimreport(simpath, clargs)
@info "Done"

