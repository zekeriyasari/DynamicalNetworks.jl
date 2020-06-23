# This file includes the script to run a parallel ber-simulation of a cluster synchronization communication.

using Distributed 
using Dates
using Logging 
using ArgParse
using JLD2, FileIO
using Jusdl 
using Statistics

# ----------------------------------- Commandline Argument Parsing Functions ---------------------------- #  

function parse_commandline_args()
    s = ArgParseSettings()

    @add_arg_table! s begin
        "--simulation-directory"
            help = "The directory that the simulation output will be written"
            arg_type = String 
            default = tempdir()
        "--experiment-prefix"
            help = "Prefix for the experiment name. A directory with the name EXPERIMENT-PREFIX_YYYYMMDDHHMM will be created."
            arg_type = String 
            default = "Simulation"
        "--number-of-processors"
            help = "Number of processors to use"
            arg_type = Int 
            default = length(Sys.cpu_info()) - 3
        "--number-of-experiments"
            help = "Number of processors to use"
            arg_type = Int 
            default = 1
        "--number-of-bits"
            help = "Number of bits to generate"
            arg_type = Int 
            default = 5
        "--minimum-snr"
            help = "Minimum snr value (dB)"
            arg_type = Int 
            default = 0
        "--maximum-snr"
            help = "Maximum snr value (dB)"
            arg_type = Int 
            default = 18
        "--number-of-snr"
            help = "Number of snr values"
            arg_type = Int 
            default = 10
        "--bit-duration"
            help = "Bit duration"
            arg_type = Float64 
            default = 10.
        "--sampling-period"
            help = "Sampling period"
            arg_type = Float64 
            default = 0.01
        "--pcm-duty-cycle"
            help = "Pulse Code Modulation(PCM) duty cycle"
            arg_type = Float64
            default = 0.5
        "--report-simulation"
            help = "Report simulation"
            action = :store_true
        "--withbar"
            help = "Run simulation with progress bar and console log."
            action = :store_true
        "--log-to-file"
            help = "Save simulation runs log to a file."
            action = :store_true
        "--log-level"
            arg_type = String 
            default = "info"
        "--simulate"
            help = "Simulates to generate data files"
            action = :store_true
        "--process"
            help = "Process simulation files after simulation"
            action = :store_true
        "--ber"
            help = "Calculate ber after simulation"
            action = :store_true
    end

    return parse_args(s)
end

# ----------------------------------------------- Simulate functions ----------------------------------------- #

function simulate(simdir, snr_range, ti, dt, tf, tb, duty, numexps, 
    reportsim=false, logtofile=true, loglevel=Logging.Info, withbar=false, clargs=nothing) 

    # Configure simulation settings 
    ti = 0.
    dt = clargs["sampling-period"]
    tf = clargs["number-of-bits"] * clargs["bit-duration"]
    tb = clargs["bit-duration"]
    _loglevel = clargs["log-level"]
    loglevel = 
        _loglevel == "info"  ? Logging.Info : 
        _loglevel == "warn"  ? Logging.Warn : 
        _loglevel == "debug" ? Logging.Debug : 
        _loglevel == "error" ? Logging.Error : 
        error("Unknown log level. Choose from `debug`, `info`, `warn`, `error`")
    numexps = clargs["number-of-experiments"]
    reportsim = clargs["report-simulation"]
    logtofile = clargs["log-to-file"]
    withbar = clargs["withbar"]
    duty = clargs["pcm-duty-cycle"]

    # Run simulation
    @info "Running simulation..."
    @sync @distributed for snr in snr_range
        runsim(
            simdir, snr, ti, dt, tf, tb, duty, numexps,
            reportsim=reportsim,
            loglevel=loglevel,
            logtofile=logtofile,
            withbar=withbar
            )
    end 
    @info "Done."

    # Record simulation configuration in a text file.
    @info "Writing simulation configuration text file"
    open(joinpath(simdir, "config.txt"), "w") do io
    for (arg,val) in clargs
        write(io, "  $arg  =>  $val\n")
    end
    end
    @info "Done."

    # Record simulation in a data file. 
    @info "Writing simulation configuration data file"
    jldopen(joinpath(simdir, "config.jld2"), "w") do file
    for (arg, val) in clargs
        file[arg] =  val
    end
    end
    @info "Done."
end 

# --------------------------------------- Process fucntions --------------------------------------- # 

function process_exp(expdir, config)
    @info "\t\tStarted to process $expdir..."

    # Read the states 
    t, states = fread(joinpath(expdir, "states.jld2"), flatten=true)

    # Compute synchronization error 
    error = abs.(states[:, 7] - states[:, 10])

    # Check if elements of error is finite 
    idx = findall(isnan, error)
    isempty(idx) || @warn "Error includes non-finite values. Replacing by zeros."
    error[idx] .= 0.

    # Calculate sample per bits 
    ts = config["sampling-period"]
    tb = config["bit-duration"]
    spb = floor(Int, tb / ts)

    # Divide the error into parts corresponding to each bit 
    parts = collect(Iterators.partition(error, spb))
    csums = cumsum.(parts)
    lines = map(cs -> collect(range(cs[1], cs[end], length=length(cs))), csums)
    extbits = mean.(csums .- lines) .≥ 0.

    # Write extbits to expdir 
    filename = joinpath(expdir, "extbits.jld2")
    jldopen(filename, "w") do file 
        file["bits"] = extbits
    end

    @info "\t\tDone processing $expdir."
end

function process_snr(snrdir, config) 
    @info "\tStarted to process $snrdir..."
    foreach(expdir -> process_exp(expdir, config), readdir(snrdir, join=true))
    @info "\tDone processing $snrdir."
end

function process_sim(simdir)
    @info "Started to process $simdir..."
    config = load(joinpath(simdir, "config.jld2"))
    foreach(snrdir -> process_snr(snrdir, config), filter(isdir, readdir(simdir, join=true)))
    @info "Done processing $simdir."
end

# --------------------------------- Ber Calculation Functions ------------------------------------ # 

function ber_exp(expdir)
    genbits = load(joinpath(expdir, "bits.jld2"))["bits"]
    extbits = load(joinpath(expdir, "extbits.jld2"))["bits"]
    length(findall(genbits .== extbits)) / length(genbits) 
end

ber_snr(snrdir) = mean(ber_exp.(readdir(snrdir, join=true)))

function ber_sim(simdir) 
    @info "Calculating ber for $simdir..."
    ber = ber_snr.(filter(isdir, readdir(simdir, join=true)))
    open(joinpath(simdir, "ber.txt"), "w") do file 
        write(file, "ber = $ber")
    end
    @info "Done calculating ber for $simdir. ber = $ber"
    return ber
end

# ------------------------------------- Main ---------------------------------------------------------- # 

# Get commandline arguments 
@info "Parsing commandline arguments..."
clargs = parse_commandline_args()
@info "Done."

@info "Simulation configuration"
for (arg,val) in clargs
    println("  $arg  =>  $val")
end

# Add workers 
@info "Loading processors..."
nw = nworkers() 
np = clargs["number-of-processors"]
nw == np - 1 || addprocs(np - nw)
@info "Done."

# Code loading  
@info "Loading code to all processors..."
@everywhere include(joinpath(@__DIR__, "load.jl"))
@info "Done."


# Simulate the system 
clargs["simulate"]  && simulate(simdir, snr_range, ti, dt, tf, tb, duty, numexps, 
    reportsim=reportsim, logtofile=logtofile, loglevel=loglevel, withbar=withbar, clargs=clargs)

# Process the simulation files 
clargs["process"]  && process_sim(simdir)

# Process the simulation files 
clargs["ber"]  && ber_sim(simdir)

