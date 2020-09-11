# This file includes an example for the simulation nondiagonal noise 

using DifferentialEquations 
using Plots 

function drift(dx, x, u, t)
    dx .= -x 
end

function diffusion(dx, x, u, t, η=1.)
    dx .= -η
end
x0 = rand(3)
tspan = (0., 100.)
prob = SDEProblem(drift, diffusion, x0, tspan, noise_rate_prototype=zeros(3, 3))
sol = solve(prob, saveat=0.01, save_noise=true)