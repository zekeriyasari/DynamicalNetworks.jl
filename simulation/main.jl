
using DynamicalNetworks 
using ArgParse
using Dates 
using Logging, LoggingExtras

# Include functions 
include(joinpath(@__DIR__, "getlogger.jl"))
include(joinpath(@__DIR__, "getnetwork.jl"))
include(joinpath(@__DIR__, "getclargs.jl"))
include(joinpath(@__DIR__, "getpower.jl"))
include(joinpath(@__DIR__, "runsim.jl"))
include(joinpath(@__DIR__, "writereport.jl"))

# Run the simulation 
with_logger(getlogger()) do 
    runsim(getclargs())
end 
