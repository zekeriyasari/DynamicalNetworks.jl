# This file includes some nodes dynamics 

export Lorenz, Chua, Chen 

#------------------------------- Node dynamics -------------------------------------- #

abstract type AbstractNodeDynamics end

Base.@kwdef struct Lorenz <: AbstractNodeDynamics
    σ::Float64 = 10
    β::Float64 = 8 / 3 
    ρ::Float64 = 28
end 
function (node::Lorenz)(dx, x, u, t)
    dx[1] = node.σ * (x[2] - x[1])
    dx[2] = x[1] * (node.ρ - x[3]) - x[2]
    dx[3] = x[1] * x[2] - node.β * x[3]
end

Base.@kwdef struct Chen <: AbstractNodeDynamics
    a::Float64 = 35 
    b::Float64 = 3
    c::Float64 = 28
end 
function (node::Chen)(dx, x, u, t)
    dx[1] = node.a * (x[2] - x[1])
    dx[2] = (node.c - node.a) * x[1] + node.c * x[2] - x[1] * x[3]
    dx[3] = x[1] * x[2] - node.b * x[3]
end

Base.@kwdef struct Chua <: AbstractNodeDynamics
    α::Float64 = 10 
    β::Float64 = 14.87
    a::Float64 = -1.27
    b::Float64 = -0.68
end 
function (node::Chua)(dx, x, u, t)
    hval = node.b * x[1] + 1 / 2 * (node.a - node.b) * (abs(x[1] + 1) - abs(x[1] - 1))
    dx[1] = node.α * (x[2] - x[1] - hval)
    dx[2] = x[1] - x[2] + x[3]
    dx[3] = -node.β * x[2]  
end
