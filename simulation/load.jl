# This file is the load file for parallel simulation 

# Activate dev-env
using Pkg 
Pkg.activate(joinpath(Pkg.envdir(), "dev-env"))

# Load packages 
using DifferentialEquations 
using DynamicalNetworks 

# Define worker function
function runsim(η=1., args...; kwargs...)
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
    
    noise = WienerProcess(0., zeros(4))     # Sytem noise 

    function lorenzdrift(dx, x, u, t, σ=10., β=8/3, ρ=28, cplmat=P)  # Drift function
        dx[1] = σ * (x[2] - x[1])
        dx[2] = x[1] * (ρ - x[3]) - x[2]
        dx[3] = x[1] * x[2] - β * x[3]
        dx .+= cplmat * map(ui -> ui(t), u.itp)
    end

    function diffusion1(dx, x, u, t)    # Diffusion function of node1
        dx .= [
            η η 0 0; 
            0 0 0 0; 
            0 0 0 0
            ] 
    end
    function diffusion2(dx, x, u, t)    # Diffusion fucntion of node2
        dx .= [
            0 0 η η; 
            0 0 0 0; 
            0 0 0 0
            ] 
    end
    function diffusion3(dx, x, u, t)    # Diffusion function of node3
        dx .= [
            -η 0 -η 0; 
            0 0 0 0; 
            0 0 0 0
            ] 
    end
    function diffusion4(dx, x, u, t)    # Diffusion function of node4
        dx .= [
            0 -η 0 -η; 
            0 0 0 0; 
            0 0 0 0
            ] 
    end

    readout(x, u, t) = x        # Readout function of all nodes

    components = [      # Components 
        SDESystem(drift=lorenzdrift, diffusion=diffusion1, readout=readout, state=rand(3), 
            input=Inport(3), output=Outport(3),  modelkwargs=(noise=noise, noise_rate_prototype=zeros(3,4))) ;
        SDESystem(drift=lorenzdrift, diffusion=diffusion2, readout=readout, state=rand(3), 
            input=Inport(3), output=Outport(3),  modelkwargs=(noise=noise, noise_rate_prototype=zeros(3,4))) ;
        SDESystem(drift=lorenzdrift, diffusion=diffusion3, readout=readout, state=rand(3), 
            input=Inport(3), output=Outport(3),  modelkwargs=(noise=noise, noise_rate_prototype=zeros(3,4))) ;
        SDESystem(drift=lorenzdrift, diffusion=diffusion4, readout=readout, state=rand(3), 
            input=Inport(3), output=Outport(3),  modelkwargs=(noise=noise, noise_rate_prototype=zeros(3,4))) ;
        ]

    netmodel = network(components, E, P)    # Network model 

    # Add writer to netmodel 
    addnode!(netmodel, Writer(input=Inport(12)), label=:writer)
    addbranch!(netmodel, :node1 => :writer, 1:3 => 1:3)
    addbranch!(netmodel, :node2 => :writer, 1:3 => 4:6)
    addbranch!(netmodel, :node3 => :writer, 1:3 => 7:9)
    addbranch!(netmodel, :node4 => :writer, 1:3 => 10:12)

    # Simulate the netmodel 
    simulate!(netmodel, ti, dt, tf - dt, args...; kwargs...)
end

println("load.jl is loaded.")
