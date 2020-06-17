
#= 
    A simulator for dynamical networks.
=#
module DynamicalNetworks

using DocStringExtensions
using Reexport 
@reexport using Jusdl
using LightGraphs 
using LinearAlgebra

# Includes 
include("pcm.jl")
include("network.jl")

# Exports 
export PCM, Falling, Rising, switch!
export network, coupling

end # module
