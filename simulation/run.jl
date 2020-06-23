# This file includes the script to run a parallel ber-simulation of a cluster synchronization communication.

using Distributed 
using Dates
using Logging 
using ArgParse
using JLD2, FileIO

# Parse commandline arguments
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
    end

    return parse_args(s)
end

# ----------------------------------------------- Main ----------------------------------------- #

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

# Construct simulation directory
@info "Constructing simulation directories..."
simdir = joinpath(clargs["simulation-directory"], 
    clargs["experiment-prefix"] * "-" * replace(split(string(now()), ".")[1], ":" => "-"))
ispath(simdir) || mkpath(simdir)
snr_range = collect(range(clargs["minimum-snr"], stop=clargs["maximum-snr"], length=clargs["number-of-snr"]))
for snr in snr_range
    mkpath(joinpath(simdir, string(snr) * "dB"))
end
@info "Done."

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

# Code loading  
@info "Loading code to all processors..."
@everywhere include(joinpath(@__DIR__, "load.jl"))
@info "Done."

# Run simulation
@info "Running simulation..."
@sync @distributed for snr in snr_range
    runsim(
        simdir, snr, ti, dt, tf, tb, duty, numexps,
        reportsim=reportsim,
        loglevel=loglevel,
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
