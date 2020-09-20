# This script run a MonteCarlo simulation a time varying network .

using DynamicalNetworks 
using ArgParse 
using JLD2

# STEP: Include methods                                                        

include(joinpath(@__DIR__, "getclargs.jl"))
include(joinpath(@__DIR__, "getnetwork.jl"))
include(joinpath(@__DIR__, "getsignalpower.jl"))

# STEP: Get commandline arguments                                              

clargs = getclargs()
clargs = Dict(Symbol(key) => val for (key, val) in clargs)

# STEP:  Construct network                                                     

net = getnetwork(clargs)

# STEP:  Run MonteCarlo simulation                                             
signal_power = getsignalpower(net, clargs)

# Unwrap commandline arguments 
dt         = getindex(clargs, :dt)
tbit       = getindex(clargs, :tbit)
minsnr     = getindex(clargs, :minsnr)
maxsnr     = getindex(clargs, :maxsnr)
nsnr       = getindex(clargs, :nsnr)
ntrials    = getindex(clargs, :ntrials)
simdir     = getindex(clargs, :simdir)
simprefix  = getindex(clargs, :simprefix)
ncores     = getindex(clargs, :ncores)
nbits      = getindex(clargs, :nbits)
maxiters   = getindex(clargs, :maxiters)

# Run the simulation 
snr_to_noise(snr, signal_power) = sqrt(signal_power / 10^(snr / 10))
vals = map(snr -> snr_to_noise(snr, signal_power) * net.H, range(minsnr, maxsnr, length=nsnr))
tf = nbits * tbit
mc = montecarlo(net, :H, vals, ti=0., dt=dt, tf=tf, ntrials=ntrials, simdir=simdir, simprefix=simprefix, ncores=ncores, 
    maxiters=maxiters)

# Write clargs 
jldopen(joinpath(mc.path, "clargs.jld2"), "w") do file 
    file["clargs"] = clargs
end 
