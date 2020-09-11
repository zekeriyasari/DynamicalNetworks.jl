# This file includes methods for a Monte-Carlo simulation of a network.
using Dates

export montecarlo

"""
    $(SIGNATURES)   

Runs a Monte-Carlo simulation for `net` starting from `ti` to `tf` with a time step of `dt`. 
"""
function montecarlo(net::AbstractNetwork, ti=0., dt=0.01, tf=100., args...; snrange=0:3:30, nexp=2, nbits=10, tbit=50., dt=0.01, simpath=tempdir(), simname="Simulation-$(now())"; kwargs...)
    montecarlosimpath = joinpath(simpath, simname)
    for η in snrange, n in 1 : nexp
        simulate(net, path=joinpath(montecarlosimpath,"Exp$n"), simprefix="$(η)dB", simname="")
    end
end
