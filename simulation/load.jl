# This file is the load file for parallel simulation 

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
snrdir(simdir, snr) = abspath(only(findall(dir -> split(basename(dir), "dB")[1] == string(snr), readdir(simdir))))
# snrdir(simdir, snr) = abspath(only(findall(dir -> endswith(dir, string(snr)*"dB"), readdir(simdir))))

# Define worker function
function _runsim(simdir, snr, numexp, args...; kwargs...)
    @info "Started for snr=$snr exp=$numexp"
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
    snrpath = snrdir(simdir, snr)
    addnode!(netmodel, Writer(input=Inport(12), path=joinpath(snrpath, "Exp-"*string(numexp))), label=:writer)
    addbranch!(netmodel, :node1 => :writer, 1:3 => 1:3)
    addbranch!(netmodel, :node2 => :writer, 1:3 => 4:6)
    addbranch!(netmodel, :node3 => :writer, 1:3 => 7:9)
    addbranch!(netmodel, :node4 => :writer, 1:3 => 10:12)

    # Simulate the netmodel 
    simulate!(netmodel, ti, dt, tf - dt, args...; simdir=snrpath)

    @info "Done for snr=$snr exp=$numexp"
end

function runsim(simdir, snr, numexps, args...; kwargs...)
    for numexp in numexps
        _runsim(simdir, snr, numexp, args...; kwargs...)
    end
end

println("load.jl is loaded.")
