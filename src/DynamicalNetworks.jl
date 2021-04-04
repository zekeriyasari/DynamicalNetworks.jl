module DynamicalNetworks 

using BlockArrays
using LinearAlgebra
using DocStringExtensions
using Reexport
@reexport using Causal 

include("dynamics.jl") 
include("netode.jl") 
include("pinning.jl") 

end # module 
