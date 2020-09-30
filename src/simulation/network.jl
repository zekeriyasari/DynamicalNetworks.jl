using DifferentialEquations
using Dates
using JLD2

# -------------------------------------- Network ------------------------------------------------- #

mutable struct Network{T1, T2, T3, T4}
    nodes::T1
    E::T2 
    H::T3 
    P::T4 
end

function drift!(dx, x, net, t)
    for (node, idx) in zip(net.nodes, Iterators.partition(1 : length(x), size(net.P, 1)))
        node(view(dx, idx), view(x, idx), nothing, t)
    end
    E0 = eltype(net.E) <: Real ? net.E : map(ϵ -> ϵ(t), net.E)
    dx .+= kron(E0, net.P) * x
end

function diffusion!(dx, x, net, t)
    dx .= kron(net.H, net.P)  
end

function getnetprob(net, tspan)
    n, d, l = size(net.E, 1), size(net.P, 1), size(net.H, 2)
    x0 = vcat([node.x0 for node in net.nodes]...)
    noise_rate_prototype = zeros(n*d, l*d)
    SDEProblem(drift!, diffusion!, x0, tspan, net, noise_rate_prototype=noise_rate_prototype)
end

function solvenet(net, tspan, solargs...; solkwargs...)
    prob = getnetprob(net, tspan)
    sol = solve(prob, solargs...; solkwargs...)
end

# -------------------------------------- Nodes ------------------------------------------------- #

Base.@kwdef struct Lorenz 
    σ::Float64 = 10. 
    β::Float64 = 8/3
    ρ::Float64 = 28.
    γ::Float64 = 1.
    x0::Vector{Float64} = rand(3)
end 
function (node::Lorenz)(dx, x, u, t)
    dx[1] = node.σ * (x[2] - x[1])
    dx[2] = (node.ρ - x[3]) * x[1] - x[2]
    dx[3] = x[1] * x[2] - node.β * x[3] 
    dx .*= node.γ
end

# -------------------------------------- PCM ------------------------------------------------- #

struct Rising end 
struct Falling end 
pulse(::Type{Rising}, t, high, low, period, duty) = t % period ≤ duty * period ? low : high 
pulse(::Type{Falling}, t, high, low, period, duty) = t % period ≤ duty * period ? high : low 

Base.@kwdef struct PCM{T1, T2, T3, T4}
    bits::Vector{Bool} 
    high::T1 = 1.
    low::T2  = 0. 
    period::T3 = 1. 
    duty::T4 = 0.5
end 
function (pcm::PCM)(t) 
    n = length(pcm.bits)
    T = pcm.period
    tf = n * T 
    idx = t == tf ? n : findlast(t .≥  (0 : n) * T)
    pType = pcm.bits[idx] ? Rising : Falling 
    pulse(pType, t, pcm.high, pcm.low, pcm.period, pcm.duty)
end

Base.@kwdef struct Constant{T} 
    level::T 
end 
(con::Constant)(t) = con.level

