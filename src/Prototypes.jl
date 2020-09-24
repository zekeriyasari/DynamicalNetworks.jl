module Prototypes  

using DifferentialEquations 
using LinearAlgebra
import DynamicalNetworks: Lorenz

export PulseTrain, getprob, solveprob

Base.@kwdef struct PulseTrain{T1, T2, T3, T4}
    period::T1 = 1. 
    duty::T2 = 0.5
    high::T3 = 1. 
    low::T4 = 0. 
end 
function (pulse::PulseTrain)(t)
    t % pulse.period ≤ pulse.period * pulse.duty ? pulse.low : pulse.high 
end

function drift!(dx, x, (node, E, H, P), t)
    for idx in Iterators.partition(1 : length(x), size(P, 1))
        node(view(dx, idx), view(x, idx))
    end
    eltype(E) <: Real ? (dx .+= kron(E, P) * x) : (dx .+= kron(map(ϵ -> ϵ(t), E), P) * x)
end

function diffusion!(dx, x, (node, E, H, P), t)
    dx .= kron(H, P)
end

function getprob(numnodes, nbits, tbit, α, ϵ, η, γ, θ, cplidx)
    if numnodes == 4 
        E = [
            PulseTrain(period=tbit, duty=α, high=-θ * ϵ) PulseTrain(period=tbit, duty=α, high=θ * ϵ) PulseTrain(period=tbit, duty=α, high=-ϵ) PulseTrain(period=tbit, duty=α, high=ϵ);
            PulseTrain(period=tbit, duty=α, high=θ * ϵ) PulseTrain(period=tbit, duty=α, high=-θ * ϵ) PulseTrain(period=tbit, duty=α, high=ϵ) PulseTrain(period=tbit, duty=α, high=-ϵ);
            PulseTrain(period=tbit, duty=α, high=-ϵ) PulseTrain(period=tbit, duty=α, high=ϵ) PulseTrain(period=tbit, duty=α, high=-θ * ϵ) PulseTrain(period=tbit, duty=α, high=θ * ϵ);
            PulseTrain(period=tbit, duty=α, high=ϵ) PulseTrain(period=tbit, duty=α, high=-ϵ) PulseTrain(period=tbit, duty=α, high=θ * ϵ) PulseTrain(period=tbit, duty=α, high=-θ * ϵ)
        ]
        H = η * [
            0 0 1 1; 
            0 0 1 1; 
            -1 -1 0 0; 
            -1 -1 0 0
        ]
        lennoise = 4
    elseif numnodes == 2 
        E = [
            PulseTrain(period=tbit, duty=α, high=-ϵ) PulseTrain(period=tbit, duty=α, high=ϵ);
            PulseTrain(period=tbit, duty=α, high=ϵ) PulseTrain(period=tbit, duty=α, high=-ϵ);
        ]
        H = η * [1, -1]
        lennoise = 1
    end  

    P = (v = zeros(3); v[cplidx] .= 1; diagm(v))
    ti = 0. 
    dt = 0.01 
    tf = nbits * tbit 
    numnodes = size(E, 1)
    dimnodes = size(P, 1) 
    x0 = rand(numnodes * dimnodes)
    noise_rate_prototype = zeros(numnodes * dimnodes, lennoise * dimnodes)
    node = Lorenz(γ=γ)
    SDEProblem(drift!, diffusion!, x0, (ti, tf), (node, E, H, P), noise_rate_prototype=noise_rate_prototype)
end

function solveprob(prob, args...; kwargs...)
    solve(prob, args...; kwargs...)
end 

end # module 