# Dynamical System ODENetwork 
module DynamicalNetworks

using DocStringExtensions
using DifferentialEquations
using LightGraphs, GraphPlot 
using JLD2, FileIO
using Dates 
using Distributed
using Pkg 
using LinearAlgebra

include("nodes.jl")
include("network.jl")
include("simulation.jl")
include("pcm.jl")
include("montecarlo.jl")
include("Prototypes.jl")

end # module
