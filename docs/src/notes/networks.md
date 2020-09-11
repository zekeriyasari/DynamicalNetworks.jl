# ODE Networks 
Consider the network 
```math 
\dot{\bm{x}}_i = f(\bm{x})_i + \sum_{j = 1}^n \epsilon_{ij} \bm{P} \bm{x}_j \quad i = 1, \ldots, n
```
where ``n`` is the number of nodes,  ``\bm{x} \in \mathbb{R}^d`` is the state vector of the ``i``th node, ``f: \mapsto \mathbb{R}^{d \times d}`` is the function corresponding to individual node dynamics, ``\epsilon_{ij}(t)`` is the coupling strength between node ``i`` and ``j`` at time ``t``. The diagonal matrix ``\bm{P} = diag(p_1, \ldots, p_d)`` determines by which state variables the nodes are coupled. 

The matrix ``\bm{E} = [\epsilon_{ij}]`` determines the network topology and the coupling strength: if there exists a connection between the nodes ``i`` and ``j`` at time ``t``, ``\epsilon_{ij}(t) > ``. Otherwise, ``\epsilon_{ij} = 0``.  The coupling matrix ``E`` is a zero-row-sum matrix
```math 
\sum_{j = 1}^n \epsilon_{ij}(t) = 0 \quad \forall   i = 1, \ldots, n \quad \forall t
```

The network dynamics given above can be written more compactly as,
```math 
    \dot{\bm{X}} = F(\bm{X}) + \left( \bm{E}(t) \otimes \bm{P} \right) \bm{X}
```
where ``\otimes`` is the Kronecker product, ``\bm{X} = [\bm{x}_1, \ldots, \bm{x}_n] \in \mathbb{R}^{nd}``, ``F(\bm{X}) = [f(\bm{x}_1, \ldots, f(\bm{x}_N)``.

Thus the network is constructed by specifying the nodes dynamics, the outer coupling matrix ``\bm{E}`` and the inner couping matrix ``\bm{P}``. See the example below 
```@repl
using DynamicalNetworks
n = 10      # Number of nodes 
d = 3       # Dimension of nodes 
ϵ = 10.     # Coupling strength between nodes
E = ϵ * [-1 1; 1 -1]        # Outer coupling matrix
P = [1 0 0; 0 0 0; 0 0 0]   # Inner couping matrix 
nodes = [Lorenz() for i in 1 : n]   # Nodes in the network.
net = Network(nodes, E, P)
```

# SDE Networks 
When the noise present in the network, the dynamics of the network takes the form,
```math 
d\bm{x}_i = \left( f(\bm{x}_i) + \sum_{j = 1}^n \epsilon_{ij}(t) \bm{P} \bm{x}_j \right) dt + \left( \sum_{k = 1}^l \eta_{k} \bm{P}  \right) d\bm{W}_{k}(t)
```
where ``\eta_{k}`` is the strength on the edge ``k`` connecting the nodes ``i`` and ``j``
  ``\bm{W}_{k}(t) \in \mathbb{R}^d`` is the Wiener process corresponding to the noise on the link ``k``.

This network can be written more compactly as
```math 
d\bm{X} = \left( F(\bm{X}) + \bm{E}(t) \otimes \bm{P} \right) \bm{X} dt + \left( \bm{H}(t) \otimes \bm{P} \right) d\bm{W}
```
where ``\bm{W} = [\bm{W}_k] \in \mathbb{R}^{ld}`` where ``l`` is the number of  edges in the network.
