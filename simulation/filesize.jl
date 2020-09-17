# This script run a MonteCarlo simulation a time varying network .

using DynamicalNetworks 

# STEP: Include methods                                                        

include(joinpath(@__DIR__, "getnetwork.jl"))

# STEP: Get commandline arguments                                              

clargs = Dict(:nbits => 1, :tbit => 50., :strength => 10., :dt => 0.01)

# STEP:  Construct network                                                     

net = getnetwork(clargs)

# STEP: Simulate the network 
nbits = getindex(clargs, :nbits)
tbit  = getindex(clargs, :tbit)
dt    = getindex(clargs, :dt)
tf = nbits * tbit
ti = 0. 

# Simulate 
filesizes = zeros(Int, 100) 
for i in 1 : length(filesizes)
    sim = simulate(net, ti, dt, tf)
    filesizes[i] = filesize(joinpath(sim.path, "data.jld2"))
end

println("Average file size per bit is = ", sum(filesizes) / length(filesizes) / 1024, " KiloBytes")