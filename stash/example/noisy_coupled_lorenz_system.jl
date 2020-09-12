# This file includes the simulation of noisy Lorenz system 

using DynamicalNetworks 
using Plots 

model = Model(clock=Clock(0., 0.01, 100.))
addnode!(model, NoisyLorenzSystem(nothing, Outport(3), eta=5.), label=:ds)
addnode!(model, Writer(Inport(3)), label=:writer) 
addbranch!(model, :ds => :writer) 
simulate!(model) 
t, x = read(getnode(model, :writer).component)
plot(x[:, 1], x[:, 2], lw=2)