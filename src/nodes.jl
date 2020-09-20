# This file include different node dynamical systems 

export NodeDynamics, Lorenz

abstract type NodeDynamics end

"""
    $(TYPEDEF) 

Lorenz dynamics that evolves by 
```math 
\\dot{x}_{1} = \\sigma (x_2 - x_1) \\
\\dot{x}_{2} = x_1 (\\rho - x_3) - x_2 \\
\\dot{x}_{3} = x_1 x_2 - \\beta x_3
```
where ``\\sigma, \\beta, \\rho`` are system parameters.


# Fields 

    $(TYPEDFIELDS)
"""
Base.@kwdef struct Lorenz{T1, T2, T3, T4, T5} <: NodeDynamics
    σ::T1 = 10.
    β::T2 = 8 / 3. 
    ρ::T3 = 28
    γ::T4 = 1. 
    x::T5 = rand(3)
end
function (node::Lorenz)(dx, x)
    dx[1] = node.σ * (x[2] - x[1]) 
    dx[2] = x[1] * (node.ρ - x[3]) - x[2]
    dx[3] = x[1] * x[2] - node.β * x[3]
    dx .*= node.γ
end