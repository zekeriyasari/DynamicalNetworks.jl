# This file includes the code to be loaded on all process during a ber-simulation of cluster synchronnization communication

# Activate dev-env
using Pkg 
Pkg.activate(joinpath(Pkg.envdir(), "dev-env"))

# Load packages 
using DifferentialEquations 
using DynamicalNetworks 
using LinearAlgebra
using Logging
 
# Convert snr to noise strength
to_noise_strength(snr) = sqrt(10^(snr / 10))

# Find the directory corresponding to snr
snrdir(simdir, snr) = joinpath(simdir, only(filter(dir -> split(basename(dir), "dB")[1] == string(snr), readdir(simdir))))

# Define worker function
function _runsim(simdir, snr, numexp, ti, dt, tf, simargs...; simkwargs...)
    # Check snr path 
    simpath = simdir 
    simname = string(snr)*"dB"
    snrpath = joinpath(simpath, simname)
    isdir(snrpath) || mkpath(snrpath)

    η = to_noise_strength(snr)
    n = 4           # Number of nodes 
    d = 3           # Dimensio of nodes 
    T = 100.        # Bit duration 
    ti = 0.         # Initial time 
    dt = 0.01       # Sampling period 
    tf = 1000.      # Final time 
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
    addnode!(netmodel, Writer(input=Inport(12), path=joinpath(snrpath, "Exp-"*string(numexp))), label=:writer)
    addbranch!(netmodel, :node1 => :writer, 1:3 => 1:3)
    addbranch!(netmodel, :node2 => :writer, 1:3 => 4:6)
    addbranch!(netmodel, :node3 => :writer, 1:3 => 7:9)
    addbranch!(netmodel, :node4 => :writer, 1:3 => 10:12)

    # Simulate the netmodel 
    simulate!(netmodel, ti, dt, tf - dt, simdir=simdir, simname=simname, simprefix=""; simkwargs...)
end

function runsim(simdir, snr, ti, dt, tf, numexps, simargs...; simkwargs...)
    for numexp in 1 : numexps
        _runsim(simdir, snr, numexp, ti, dt, tf, simargs...; simkwargs...)
    end
end

println("load.jl is loaded.") 
