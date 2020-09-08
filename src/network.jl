# This file includes to construct network models

export Network, signalflow

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
struct Network{T1, T2, T3}
    nodes::T1
    E::T2 
    P::T3
end

"""
    $(SIGNATURES)
    
Plots signal flow graph. 
"""
function signalflow(net::Network)
    E = net.E
    graph = SimpleGraph(E)
    gplot(graph, nodelabel=1 : size(E, 1))
end
