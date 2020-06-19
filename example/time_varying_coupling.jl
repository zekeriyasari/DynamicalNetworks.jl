
# This file illustrates the simulation of time varyingly coupled dynamical systems 

using DynamicalNetworks 
using Plots 
using Statistics
using DifferentialEquations

# Construct the netmodel 
n = 4 
d = 3 
T = 100.
ti = 0. 
dt = 0.01 
tf = 1000.
ε = 10.
η = 5.
pcm = PCM(high=ε, low=0.01ε, period=T) 

E = [
    t -> -3*pcm(t)  t -> 3*pcm(t)       t -> -ε     t -> ε;
    t -> 3*pcm(t)   t -> -3*pcm(t)      t -> ε      t -> -ε;
    t -> -ε         t -> ε              t -> -3ε    t -> 3ε;
    t -> ε          t -> -ε             t -> 3ε     t -> -3ε
    ]
P = coupling(1, 3)
noise = WienerProcess(0., zeros(4))
function lorenzdrift(dx, x, u, t, σ=10., β=8/3, ρ=28, cplmat=P)
    dx[1] = σ * (x[2] - x[1])
    dx[2] = x[1] * (ρ - x[3]) - x[2]
    dx[3] = x[1] * x[2] - β * x[3]
    dx .+= cplmat * map(ui -> ui(t), u.itp)   # Couple inputs
end
g1 = [
    η η 0 0; 
    0 0 0 0; 
    0 0 0 0
] 
g2 = [
    0 0 η η; 
    0 0 0 0; 
    0 0 0 0
] 
g3 = [
    -η 0 -η 0; 
    0 0 0 0; 
    0 0 0 0
] 
g4 = [
    0 -η 0 -η; 
    0 0 0 0; 
    0 0 0 0
] 

components = [
    SDESystem(drift=lorenzdrift, diffusion=(dx, x, u, t) -> (dx .= g1), readout=readout, state=rand(3), 
        input=Inport(3), output=Outport(3),  modelkwargs=(noise=noise, noise_rate_prototype=zeros(3,4))) ;
    SDESystem(drift=lorenzdrift, diffusion=(dx, x, u, t) -> (dx .= g2), readout=readout, state=rand(3), 
        input=Inport(3), output=Outport(3),  modelkwargs=(noise=noise, noise_rate_prototype=zeros(3,4))) ;
    SDESystem(drift=lorenzdrift, diffusion=(dx, x, u, t) -> (dx .= g3), readout=readout, state=rand(3), 
        input=Inport(3), output=Outport(3),  modelkwargs=(noise=noise, noise_rate_prototype=zeros(3,4))) ;
    SDESystem(drift=lorenzdrift, diffusion=(dx, x, u, t) -> (dx .= g4), readout=readout, state=rand(3), 
        input=Inport(3), output=Outport(3),  modelkwargs=(noise=noise, noise_rate_prototype=zeros(3,4))) ;
    ]
netmodel = network(components, E, P)

# Add writer to netmodel 
addnode!(netmodel, Writer(input=Inport(12)), label=:writer)
addbranch!(netmodel, :node1 => :writer, 1:3 => 1:3)
addbranch!(netmodel, :node2 => :writer, 1:3 => 4:6)
addbranch!(netmodel, :node3 => :writer, 1:3 => 7:9)
addbranch!(netmodel, :node4 => :writer, 1:3 => 10:12)

# Simulate the netmodel 
sim = simulate!(netmodel, ti, dt, tf - dt)

# Read the simulation data 
t, x = read(getnode(netmodel, :writer).component)

# Plot the results 
plot(layout=(2,2))
plot!(t, x[:, 1],               subplot=1); vline!(ti : T : tf, subplot=1, label="")
plot!(t, x[:, 1] - x[:, 4],     subplot=2); vline!(ti : T : tf, subplot=2, label="")
plot!(t, x[:, 4] - x[:, 7],     subplot=3); vline!(ti : T : tf, subplot=3, label="")
plot!(t, x[:, 7] - x[:, 10],    subplot=4); vline!(ti : T : tf, subplot=4, label="")

# Bit detection 
s = abs.(x[:, 7] - x[:, 10])
plot(t,s); vline!(ti : T : tf, label="")

sample_per_bits = floor(Int, T / dt)
parts = collect(Iterators.partition(s, sample_per_bits))
plt = plot(layout=(5,2))
for (i, part) in enumerate(parts)
    plot!(part, subplot=i)
end
plt

# Take to waveform parts
sp1 = s[1 : sample_per_bits]
cs1 = cumsum(sp1)
l1 = collect(range(cs1[1], stop=cs1[end], step=(cs1[end]-cs1[1]) / (length(cs1) - 1)))
<<<<<<< HEAD
sp2 = s[3 * sample_per_bits + 1 : 4 * sample_per_bits]
=======
sp2 = s[sample_per_bits + 1 : 2 * sample_per_bits]
>>>>>>> 2ee16ebda6a75f929bda6c0e1d960357a81b4328
cs2 = cumsum(sp2)
l2 = collect(range(cs2[1], stop=cs2[end], step=(cs2[end]-cs2[1]) / (length(cs2) - 1)))

# Plot cumsums
plt = plot(layout=(4,1))
plot!(sp1, subplot=1)
plot!(cs1, subplot=2)
plot!(l1, subplot=2)
plot!(sp2, subplot=3)
plot!(cs2, subplot=4)
plot!(l2, subplot=4)

<<<<<<< HEAD
# Check convexity
mean((cs1 - l1))
mean((cs2 - l2))
=======
# Check convexity 
mean((cs1 - l1))
mean((cs2 - l2))


>>>>>>> 2ee16ebda6a75f929bda6c0e1d960357a81b4328
