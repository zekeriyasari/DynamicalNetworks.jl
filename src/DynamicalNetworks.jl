
#= 
    A simulator for dynamical networks.
=#
module DynamicalNetworks

using Reexport 
@reexport using Jusdl
using LightGraphs 
using LinearAlgebra

# Includes 
include("pcm.jl")
include("network.jl")

# Exports 
export PCM
export network, coupling

end # module
