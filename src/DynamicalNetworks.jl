
#= 
    A simulator for dynamical networks.
=#
module DynamicalNetworks

using Reexport
@reexport using Jusdl

# Includes 
include("pcm.jl")
include("network.jl")

# Exporst 
export PCM
export netmodel

end # module
