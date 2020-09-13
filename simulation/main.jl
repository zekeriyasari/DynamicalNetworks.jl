# This script run a MonteCarlo simulation a time varying network .

using DynamicalNetworks 
using ArgParse 

# STEP: Include methods                                                        

include(joinpath(@__DIR__, "getclargs.jl"))
include(joinpath(@__DIR__, "getnetwork.jl"))

# STEP: Get commandline arguments                                              

clargs = getclargs()
clargs = Dict(Symbol(key) => val for (key, val) in clargs)

# STEP:  Construct network                                                     

net = getnetwork(clargs)

# STEP:  Run MonteCarlo simulation                                             

# TODO: #11 Compute signal power to compute true snr. 

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

# Run the simulation 
vals = map(η -> η * net.H, collect(range(minsnr, maxsnr, length=nsnr)))
tf = nbits * tbit
montecarlo(net, :H, vals, ti=0., dt=dt, tf=tf, ntrials=ntrials, simdir=simdir, simprefix=simprefix, ncores=ncores)
