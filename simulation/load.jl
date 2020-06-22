# This file includes the code to be loaded on all process during a ber-simulation of cluster synchronnization communication

# Activate dev-env
using Pkg 
Pkg.activate(joinpath(Pkg.envdir(), "dev-env"))

# Load packages 
using DifferentialEquations 
using DynamicalNetworks 
using LinearAlgebra
using Logging
using JLD2
 
# Convert snr to noise strength
to_noise_strength(snr) = sqrt(10^(snr / 10))

# Find the directory corresponding to snr
snrdir(simdir, snr) = joinpath(simdir, only(filter(dir -> split(basename(dir), "dB")[1] == string(snr), readdir(simdir))))

# Define worker function
function _runsim(simdir, snr, numexp, ti, dt, tf; reportsim=false, loglevel=Logging.Info, withbar=false)
    # Check snr path 
    simpath = joinpath(simdir, string(snr)*"dB") 
    isdir(simpath) || mkpath(simpath)

    simname = "Exp-"*string(numexp)
    exppath = joinpath(simpath, simname)
    isdir(exppath) || mkpath(exppath)

    η = to_noise_strength(snr)
    n = 4           # Number of nodes 
    d = 3           # Dimensio of nodes 
    T = 100.        # Bit duration 
    ε = 10.         # Couping strength
    
    pcm = PCM(high=ε, low=0.01ε, period=T)      # Pulse code modulation.

    E = [       # Connection matrix
        t -> -3*pcm(t)  t -> 3*pcm(t)       t -> -ε     t -> ε;
        t -> 3*pcm(t)   t -> -3*pcm(t)      t -> ε      t -> -ε;
        t -> -ε         t -> ε              t -> -3ε    t -> 3ε;
        t -> ε          t -> -ε             t -> 3ε     t -> -3ε
        ]
    
    P = coupling(1, 3)      # Coupling matrix 
    
    noise = WienerProcess(0., zeros(n*d))     # System noise 

    readout(x, u, t) = x        # Readout function of all nodes

    netmodel = network([
        ForcedNoisyLorenzSystem(diffusion=(dx, x, u, t) -> (dx .= η * kron([1 1 0 0], P)), modelkwargs=(noise=noise, noise_rate_prototype=zeros(d, n*d))), 
        ForcedNoisyLorenzSystem(diffusion=(dx, x, u, t) -> (dx .= η * kron([0 0 1 1], P)), modelkwargs=(noise=noise, noise_rate_prototype=zeros(d, n*d))), 
        ForcedNoisyLorenzSystem(diffusion=(dx, x, u, t) -> (dx .= η * kron([-1 0 -1 0], P)), modelkwargs=(noise=noise, noise_rate_prototype=zeros(d, n*d))), 
        ForcedNoisyLorenzSystem(diffusion=(dx, x, u, t) -> (dx .= η * kron([0 -1 0 -1], P)), modelkwargs=(noise=noise, noise_rate_prototype=zeros(d, n*d)))], 
        E, P)   

    # Add writer to netmodel 
    exppath = joinpath(simpath, simname)
    addnode!(netmodel, Writer(input=Inport(12), path=joinpath(exppath, "states.jld2")), label=:writer)
    addbranch!(netmodel, :node1 => :writer, 1:3 => 1:3)
    addbranch!(netmodel, :node2 => :writer, 1:3 => 4:6)
    addbranch!(netmodel, :node3 => :writer, 1:3 => 7:9)
    addbranch!(netmodel, :node4 => :writer, 1:3 => 10:12)

    # Simulate the netmodel 
    simulate!(netmodel, ti, dt, tf - dt, simdir=simpath, simname=simname, simprefix="", 
        reportsim=reportsim, loglevel=loglevel, withbar=withbar)

    # Record generated bits 
    jldopen(joinpath(exppath, "bits.jld2"), "w") do file 
        file["bits"] = pcm.bits
    end
end

function runsim(simdir, snr, ti, dt, tf, numexps; reportsim=false, loglevel=Logging.Info, withbar=false)
    for numexp in 1 : numexps
        _runsim(simdir, snr, numexp, ti, dt, tf, reportsim=reportsim, loglevel=loglevel, withbar=withbar)
    end
end

println("load.jl is loaded.") 
