# This file include a Monte-Carlo simulation of network. 

using DynamicalNetworks

# Contruct a network 
nbits = 10 
tbit = 50.
ϵ = 10.
bits = rand(Bool, nbits)
u = PCM(bits=bits, period=tbit, high=ϵ)
E = [
    PCM(bits=bits, period=tbit, high=-3ϵ) PCM(bits=bits, period=tbit, high=3ϵ)  Constant(level=-ϵ)   Constant(level=ϵ); 
    PCM(bits=bits, period=tbit, high=3ϵ) PCM(bits=bits, period=tbit, high=-3ϵ) Constant(level=ϵ)    Constant(level=-ϵ); 
    Constant(level=-ϵ)                    Constant(level=ϵ)                    Constant(level=-3ϵ)  Constant(level=3ϵ); 
    Constant(level=ϵ)                    Constant(level=-ϵ)                   Constant(level=3ϵ)   Constant(level=-3ϵ); 
] 
H = [
    0 0 1 1; 
    0 0 1 1; 
    -1 -1 0 0; 
    -1 -1 0 0
    ]
P = [1 0 0; 0 0 0; 0 0 0]
n = size(E, 1) 
d = size(P, 1) 
nodes = [Lorenz() for i  in 1 : n]
net = SDENetwork(nodes, E, H, P)

# Run a monte carlo simulation 
vals = map(η -> η * net.H, 1 : 10)
ti, dt, tf = 0., 0.01, nbits * tbit
mc = montecarlo(net, :H, vals, ti=ti, dt=dt, tf=tf)

# Print the content of the simulation directory 
foreach(println, readlines(`tree $(mc.path)`))
