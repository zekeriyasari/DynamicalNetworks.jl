# This file includes memory comparison of time scaled networks.

using DifferentialEquations
using JLD2 
using BenchmarkTools 
using LinearAlgebra
using JSON

Base.@kwdef struct LorenzSystem{T1, T2, T3, T4}
    σ::T1 = 10. 
    β::T2 = 8/3
    ρ::T3 = 28. 
    γ::T4 = 1.
end 

function (node::LorenzSystem)(dx, x)
    dx[1] = node.σ * (x[2] - x[1])
    dx[2] = (node.ρ - x[3]) * x[1] - x[2] 
    dx[3] = x[1] * x[2] - node.β * x[3]
    dx .*= node.γ
end

function drift!(dx, x, (node, E, H, P), t)
    for idx in Iterators.partition(1 : length(x), 3)
        node(view(dx, idx), view(x, idx))
    end 
    dx .+= kron(E, P) * x
end

function diffusion!(dx, x, (node, E, H, P), t)
    dx .= kron(H, P)  
end

function getprob(nbits, tbit, ϵ, node) 
    ti = 0. 
    dt = 0.01 
    tf = nbits * tbit
    E = ϵ * [
        -3 3 -1 1; 
        3 -3 1 -1; 
        -1 1 -3 3; 
        1 -1 3 -3.
    ]
    H = [
        0 0 1 1; 
        0 0 1 1; 
        -1 -1 0 0; 
        -1 -1 0 0
    ]
    P = [1. 0 0; 0 0 0; 0 0 0]
    SDEProblem(drift!, diffusion!, ones(12), (ti, tf), (node, E, H, P), noise_rate_prototype=zeros(12, 12))
end

nbit1 = 10. 
tbit1 = 1. 
ϵ1 = 500.
node1 = LorenzSystem(γ=100.)
prob1 = getprob(nbit1, tbit1, ϵ1, node1)

nbit2 = 10. 
tbit2 = 50. 
ϵ2 = 10.
node2 = LorenzSystem(γ=1.)
prob2 = getprob(nbit2, tbit2, ϵ2, node2)

display(@benchmark solve($prob1, maxiters=typemax(Int)))
display(@benchmark solve($prob2, maxiters=typemax(Int)))
