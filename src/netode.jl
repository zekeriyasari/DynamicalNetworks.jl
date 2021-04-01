# This file includes network ode model 

@def_ode_system mutable struct Network{ND, OM, IM, RH, RO, ST, IP, OP} <: AbstractODESystem
    nodedynamics::ND
    outermat::OM
    innermat::IM 
    righthandside::RH = function (dx, x, u, t, f=nodedynamics, E=outermat, P=innermat)
        n, d = size(E, 1), size(P, 1) 
        for idx in Iterators.partition(1 : n * d, d) 
            f(view(dx, idx), view(x, idx), nothing, t)
        end 
        dx .+= kron(E, P) * x
    end
    readout::RO = (x, u, t) -> x 
    state::ST = rand(size(outermat, 1) * size(innermat, 1)) * 1e-3
    input::IP = nothing 
    output::OP = VectorOutport() 
end 

