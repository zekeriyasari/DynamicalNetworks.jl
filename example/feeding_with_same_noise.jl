using Jusdl 
using Plots 
using DifferentialEquations 

# Construct model 
n = 2 
d = 3 
η = 0.25
ε = 10.
E = [-ε ε; ε -ε]
P = [1 0 0;  0 0 0;  0 0 0.]
noise = WienerProcess(0., zeros(d))
@defmodel model begin 
    @nodes begin 
        ds1 = ForcedNoisyLorenzSystem(diffusion=(dx, x, u, t) -> (dx .= η * P), modelkwargs=(noise=noise, noise_rate_prototype=zeros(d,d))) 
        ds2 = ForcedNoisyLorenzSystem(diffusion=(dx, x, u, t) -> (dx .= -η * P), modelkwargs=(noise=noise, noise_rate_prototype=zeros(d,d))) 
        coupler = Coupler(conmat=E, cplmat=P)
        writer = Writer(input=Inport(n * d))
    end 
    @branches begin
        ds1[1:3] => coupler[1:3]
        ds2[1:3] => coupler[4:6]
        coupler[1:3] => ds1[1:3]
        coupler[4:6] => ds2[1:3]
        ds1[1:3] => writer[1:3] 
        ds2[1:3] => writer[4:6]
    end
end

# Simulate the system 
simulate!(model, 0., 0.001, 100.)

# Read the results 
t, x = read(getnode(model, :writer).component)
plt = plot(layout=(3,1))
plot!(t, x[:, 1], subplot=1)
plot!(t, x[:, 4], subplot=2)
plot!(t, abs.(x[:, 1] - x[:, 4]), subplot=3)
