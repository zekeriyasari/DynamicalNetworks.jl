
using DynamicalNetworks
using Plots 

# Simulation settings 
nbits = 10 
tbit = 50. 
ϵ = 10. 
γ = 1. 
η = 1. 

# Construct network 
bits = rand(Bool, nbits) 
E = reshape([
    PCM(bits=bits, period=tbit, high=-3ϵ),
    PCM(bits=bits, period=tbit, high=3ϵ),
    Constant(level=-ϵ),
    Constant(level=ϵ),

    PCM(bits=bits, period=tbit, high=3ϵ),
    PCM(bits=bits, period=tbit, high=-3ϵ),
    Constant(level=ϵ),
    Constant(level=-ϵ),
    
    Constant(level=-ϵ),
    Constant(level=ϵ),
    Constant(level=-3ϵ),
    Constant(level=3ϵ),

    Constant(level=ϵ),
    Constant(level=-ϵ),
    Constant(level=3ϵ),
    Constant(level=-3ϵ),
    ], 4, 4)
P = [1 0 0; 0 0 0; 0 0 0]
H = η * [
     1  1  0  0;
     0  0  1  1;
    -1  0 -1  0;
     0 -1  0 -1;
    ]
numnodes = size(E, 1) 
dimnodes = size(P, 1) 
nodes = [Lorenz(γ=γ) for n in 1 : numnodes]
net = SDENetwork(nodes, E, H, P)

# Simulate network 
ti = 0. 
dt = 0.001
tf = nbits * tbit

# Calculate signal power 
sol = solvenet(net, ti, dt, tf, maxiters=typemax(Int))
tv = collect(ti : dt : tf) 
x = sol.(tv) 
s = abs.(getindex.(x, 4) - getindex.(x, 7))
N = length(s) - 1 
power = sum(s[1 : N].^2) / N 

# Run monte carlo simulation 
snr_to_std(snr, power=power) = sqrt(power / (10^(snr / 10)))
name = :H
valrange = map(snr -> net.H * snr_to_std(snr), 0 : 2 : 18)
mc = montecarlo(net, name, valrange, ti=ti, dt=dt, tf=tf, simdir="/data")

