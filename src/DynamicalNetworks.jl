# Dynamical System Network 
module DynamicalNetworks

using DocStringExtensions
using DifferentialEquations
using LightGraphs, GraphPlot 
using JLD2, FileIO
using Dates 

include("nodes.jl")
include("network.jl")
include("simulation.jl")
include("pcm.jl")

end # module
