# This file includes SDP problem to solve Lyapunov stability inequality.

using JuMP
using SCS
using LinearAlgebra 

# Define the system. 
# The problem is to find symmetric positive definte matrix P such that A' * P + P * A > 0 
A = [-0.5 1; 0 -0.3] 
n = size(A,1)
Q = [1 0; 0 1.]

# LMI solution 
model = Model(SCS.Optimizer)
@variable(model, P[1:n, 1:n], PSD)
@SDconstraint(model, P ≥ 0)
@expression(model, ex, A' * P + P * A)
@SDconstraint(model, ex ≤ -Q)
@SDconstraint(model, ex ≥ -Q)
optimize!(model)

# Get optimal value 
P = value.(P)

# Test
A' * P + P * A ≈ -Q

