
using DynamicalNetworks.Prototypes
using Plots; pyplot()

# Get network problem 
nbits = 100
tbit = 50. 
ϵ = 10. 
η = 10. 
γ = 1.
α = 0.5
θ = 3
cplidx = [1]
numnodes = 2
prob = getprob(numnodes, nbits, tbit, α, ϵ, η, γ, θ)

# Solve network problem 
sol = solveprob(prob, saveat=0.01)
tt, xt = sol.t, sol.u
E = prob.p[2] 

# Plot simulation data 
ki = 1
kf = min(20000, length(tt))
t, x = tt[ki : kf], xt[ki : kf]

plt = plot(layout=(2,1), size=(1900, 1000))
plot!(t, abs.(getindex.(x, 1) - getindex.(x, 4)), subplot=1)
plot!(t, E[1, 2].(t), subplot=2)
foreach(i -> vline!(t[1] : tbit : t[end], ls=:dash, subplot=i), 1 : length(plt.subplots))
plt2 = plot(getindex.(x, 1), getindex.(x,2), layout=(2,1), label="1-2", subplot=1)
plot!(getindex.(x, 2), getindex.(x, 3), label="2-3", subplot=2)
display(
    plot(plt, plt2)
)
