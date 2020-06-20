# This script runs the simulation 

using Distributed 
using Dates
using Logging 
using ArgParse

# Parse commandline arguments
function parse_commandline_args()
    s = ArgParseSettings()

    @add_arg_table! s begin
        "--simulation-directory", "-o"
            help = "The directory that the simulation output will be written"
            arg_type = String 
            default = tempdir()
        "--experiment-prefix", "-r"
            help = "Prefix for the experiment name. A directory with the name EXPERIMENT-PREFIX_YYYYMMDDHHMM will be created."
            arg_type = String 
            default = "Simulation"
        "--number-of-processors", "-p"
            help = "Number of processors to use"
            arg_type = Int 
            default = length(Sys.cpu_info()) - 3
        "--number-of-experiments", "-e"
            help = "Number of processors to use"
            arg_type = Int 
            default = 10
        "--number-of-bits", "-b"
            help = "Number of bits to generate"
            arg_type = Int 
            default = 50
        "--minimum-snr", "-m"
            help = "Minimum snr value (dB)"
            arg_type = Int 
            default = 0
        "--maximum-snr", "-M"
            help = "Maximum snr value (dB)"
            arg_type = Int 
            default = 18
        "--number-of-snr", "-n"
            help = "Number of snr values"
            arg_type = Int 
            default = 10
        "--bit-duration", "-d"
            help = "Bit duration"
            arg_type = Float64 
            default = 10.
        "--sampling-period", "-s"
            help = "Sampling period"
            arg_type = Float64 
            default = 0.01
    end

    return parse_args(s)
end


# ----------------------------------------------- Main ----------------------------------------- #

# Get commandline arguments 
@info "Parsing commandline arguments..."
clargs = parse_commandline_args()
@info "Done."

# Add workers 
@info "Loading processors..."
nw = nworkers() 
np = clargs["number-of-processors"]
nw == np - 1 || addprocs(np - nw)
@info "Done."

# Construct simulation directory
@info "Constructing simulation directories..."
simdir = joinpath(clargs["simulation-directory"], 
    clargs["experiment-prefix"] * replace(split(string(now()), ".")[1], ":" => "-"))
ispath(simdir) || mkpath(simdir)
snr_range = collect(range(clargs["minimum-snr"], stop=clargs["maximum-snr"], length=clargs["number-of-snr"]))
for snr in snr_range
    mkpath(joinpath(simdir, string(snr) * "dB"))
end
@info "Done."

# Code loading  
@info "Loadin code to all processors..."
@everywhere include(joinpath(@__DIR__, "load.jl"))
@info "Done."

# Start simulation 
@info "Running simulation..."
@sync @distributed for snr in snr_range
    runsim(simdir, snr, clargs["number-of-experiments"])
end 
@info "Done."
