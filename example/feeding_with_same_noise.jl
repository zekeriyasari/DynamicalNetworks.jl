# This file includes an example of feeding SDESystems with the same noise.

using DynamicalNetworks 
using Plots 
using DifferentialEquations


# Define components 
drift(dx, x, u, t) = (dx .= x) 
diffusion(dx, x, u, t, η=[1., 0., 0.]) = (dx .= [η η]) 
noise = WienerProcess(0., ones(2))
readout(x, u, t) = x 
ds1 = SDESystem(drift=drift, diffusion=diffusion, readout=readout, state=ones(3), input=nothing, output=Outport(3),  modelkwargs=(noise=noise, noise_rate_prototype=zeros(3,2))) 
ds2 = SDESystem(drift=drift, diffusion=diffusion, readout=readout, state=ones(3), input=nothing, output=Outport(3),  modelkwargs=(noise=noise, noise_rate_prototype=zeros(3,2))) 
writer = Writer(input=Inport(6))

# Define model 
@defmodel model begin 
    @nodes begin 
        ds1 = ds1 
        ds2 = ds2 
        writer = writer
    end 
    @branches begin 
        ds1[1:3] => writer[1:3]
        ds2[1:3] => writer[4:6]
    end 
end

# Simulate the model 
simulate!(model)

# Read and plot simulation data 
t, x = read(getnode(model, :writer).component)
plt = plot(layout=(3,2))
plot!(t, x[:, 1], subplot=1)
plot!(t, x[:, 2], subplot=3)
plot!(t, x[:, 3], subplot=5)
plot!(t, x[:, 4], subplot=2)
plot!(t, x[:, 5], subplot=4)
plot!(t, x[:, 6], subplot=6)
