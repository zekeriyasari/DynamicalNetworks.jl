# This file includes to construct network models

export AbstractNetwork, ODENetwork, SDENetwork, signalflow

abstract type AbstractNetwork end

"""
    $(TYPEDEF)

A network consisting of dynamical systems. The dynamics of the network evolves by, 
```math 
    \\dot{x}_i = f_i(x_i) + \\sum_{j = 1}^{n} \\epsilon_{ij} P x_j \\quad i = 1, \\ldots, n
```
where ``x_i`` is the state vector of node ``i``,  ``f_i'' is the individual node dynamics, ``\\epsilon_{ỉj} \\geq 0`` is the coupling strength between the nodes ``i`` and ``j``. ``P = diag(p_1, \\ldots, p_d)`` determines the state variables by which the nodes are coupled. 

# Fields 

    $(TYPEDFIELDS)
"""
mutable struct ODENetwork{T1, T2, T3} <: AbstractNetwork
    nodes::T1
    E::T2 
    P::T3
end


"""
    $(TYPEDEF) 

A network whose dynamics is given by 
```mat
dx_i = \\left( f(x_i) + \\sum_{j = 1}^n \\epsilon_{ij} P x_j \\right) dt + \\left( \\sum_{k=1}^l \\eta_k P \\right) dW_k
```
where `n` is the number of nodes `l` is the number of edges in the network. ``W_k`` is the Wiener process corresponding to the noise on the edge `k' connecting the nodes `i` and `j`. 

# Fields

    $(TYPEDFIELDS)
"""
mutable struct SDENetwork{T1, T2, T3, T4} <: AbstractNetwork 
    nodes::T1 
    E::T2 
    H::T3 
    P::T4
end

"""
    $(SIGNATURES)
    
Plots signal flow graph of `net`.
"""
signalflow(net::ODENetwork) = plotgraph(net.E)

"""
    $(SIGNATURES) 

Plots signal flow graph of `net` at time `t`.
"""
signalflow(net::ODENetwork, t) =  plotgraph(map(ϵ -> ϵ, net.E))
plotgraph(E) = gplot(SimpleGraph(E), nodelabel=1:size(E,1))

