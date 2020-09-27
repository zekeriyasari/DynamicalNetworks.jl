
using DynamicalNetworks 
using ArgParse

include(joinpath(@__DIR__, "getnetwork.jl"))
include(joinpath(@__DIR__, "getclargs.jl"))
include(joinpath(@__DIR__, "getpower.jl"))

# Get commandline arguments 
clargs = getclargs() 

# Construct network
net = getnetwork(
    clargs["nbits"], 
    clargs["tbit"],
    clargs["coupling-strength"],
    clargs["noise-strength"],
    clargs["time-scaling"]
)
    
# Compute time settings 
ti = 0. 
dt = clargs["dt"]
tf = clargs["nbits"] * clargs["tbit"]

# Compute signal power
power = getpower(net, ti, dt, tf, maxiters=clargs["maxiters"])

# Run a monte carlo simulation 
snrtostd(snr, power=power) = sqrt(power / (10^(snr / 10)))
name = :H
net.H ./= maximum(net.H) # rescale network noise matrix 
valrange = map(snr -> net.H * snrtostd(snr), 0 : 2 : 18)
mc = montecarlo(net, name, valrange, ti=ti, dt=dt, tf=tf, simdir=clargs["simdir"], maxiters=clargs["maxiters"], saveat=dt)
