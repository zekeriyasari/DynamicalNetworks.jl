
using DynamicalNetworks.Prototypes
using Plots; pyplot()
using DifferentialEquations 

# Get network problem 
nbits = 10
tbit = 50. 
ϵ = 50. 
η = 10. 
γ = 1.
α = 0.5
θ = 3
cplidx = [1]
numnodes = 4
prob = getprob(numnodes, nbits, tbit, α, ϵ, η, γ, θ, cplidx)

# Solve network problem 
dt = 0.01
sol = solveprob(prob, alg=LambaEM(), saveat=dt)
tt, xt = sol.t, sol.u
E = prob.p[2] 

# Plot simulation data 
spb = floor(Int, tbit / dt)
nb = 1
ki = 1
kf = min(nb * spb, length(tt))
t, x = tt[ki : kf], xt[ki : kf]

plt = plot(layout=(5,1), size=(1920, 1000))
plot!(t, abs.(getindex.(x, 1) - getindex.(x, 4)), subplot=1, label="1-2")
plot!(t, abs.(getindex.(x, 1) - getindex.(x, 7)), subplot=2, label="1-3")
plot!(t, abs.(getindex.(x, 1) - getindex.(x, 10)), subplot=3, label="1-4")
plot!(t, abs.(getindex.(x, 7) - getindex.(x, 10)), subplot=4, label="3-4")
plot!(t, E[1, 2].(t), subplot=5)
foreach(i -> vline!(t[1] : tbit : t[end], ls=:dash, subplot=i), 1 : length(plt.subplots))
plt2 = plot(getindex.(x, 1), getindex.(x,2), layout=(2,1), subplot=1, marker=(:circle, 2))
plot!(getindex.(x, 7), getindex.(x, 8), subplot=2,  marker=(:circle, 2))

display(
    plot(plt, plt2)
)
