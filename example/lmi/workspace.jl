# This file includes an example for finding control matrix A given the outer coupling matrix. 

using LightGraphs
using JuMP 
using SCS
using LinearAlgebra
using Test 

# Network settings 
numnodes = 10 
dimnodes = 3
numpins = 8
θ = 10. 
ϵ = 1. 
graph = star_graph(numnodes)
Ξ = -collect(-laplacian_matrix(graph))
Γ = θ * I(numnodes) - ϵ * Ξ

# LMI solution 
model = Model(SCS.Optimizer) 
set_silent(model)
@variable(model, A[1 : numnodes, 1 : numnodes], PSD) 
@SDconstraint(model, Γ - A ≤ 0)    # Ω = Γ - A ≤ 0
@SDconstraint(model, A ≥ 0 )    # A ≥ 0 
# for i in numpins + 1 : numnodes 
#     @constraint(model, A[i, i] == 0)
# end 
for i = 1 : numnodes
    for j in 1 : numnodes 
        if i ≠ j 
            # Off diagonal elements are zero.
            @constraint(model, A[i, j] == 0)
        end 
    end
end
optimize!(model)
A = value.(A)
@show termination_status(model)

# # Check if Ω is negative definite
# Ω = Γ - A 
# @test issymmetric(Ω)
# @test all(eigvals(Ω) .< 0)

