
#= 
    A simulator for dynamical networks.
=#
module DynamicalNetworks

using UUIDs
using Reexport
using DifferentialEquations
@reexport using Jusdl

# Includes 
include("pcm.jl")
include("network.jl")
include("nodedynamics.jl")

# Exports 
export PCM
export netmodel
export NoisyLorenzSystem

end # module
