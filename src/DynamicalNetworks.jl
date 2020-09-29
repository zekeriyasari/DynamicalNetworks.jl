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

const SIMDIR = "/data"

include("nodes.jl")
include("network.jl")
include("simulation.jl")
include("pcm.jl")

end # module
