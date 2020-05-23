# This file includes node dynamics 

import Jusdl: SDEAlg, init_dynamic_system, numtaps


mutable struct NoisyLorenzSystem{SF, OF, ST, T, IN, IB, OB, TR, HS, CB} <: AbstractODESystem
    statefunc::SF 
    outputfunc::OF 
    state::ST 
    t::T 
    integrator::IN
    input::IB 
    output::OB
    trigger::TR 
    handshake::HS 
    callbacks::CB 
    name::Symbol 
    id::UUID
    sigma::Float64
    beta::Float64
    rho::Float64
    gamma::Float64
    function NoisyLorenzSystem(input=nothing, output=Outport(3), modelargs=(), solverargs=(); 
        sigma=10, beta=8/3, rho=28, gamma=1, eta=1., outputfunc=(x,u,t)->x, state=rand(3), t=0.,
        alg=SDEAlg, cplmat=[1 0 0; 0 1 0; 0 0 1], modelkwargs=NamedTuple(), solverkwargs=NamedTuple(), numtaps=numtaps,
        callbacks=nothing, name=Symbol())
        if input === nothing
            statefunc_drift = (dx, x, u, t) -> begin
                dx[1] = sigma * (x[2] - x[1])
                dx[2] = x[1] * (rho - x[3]) - x[2]
                dx[3] = x[1] * x[2] - beta * x[3]
                dx .*= gamma
            end
        else
            statefunc_drift = (dx, x, u, t) -> begin
                dx[1] = sigma * (x[2] - x[1])
                dx[2] = x[1] * (rho - x[3]) - x[2]
                dx[3] = x[1] * x[2] - beta * x[3]
                dx .*= gamma
                dx .+= cplmat * map(ui -> ui(t), u.itp)   # Couple inputs
            end
        end
        statefunc_diffusion(dx, x, u, t, eta=eta) = (dx .= eta)
        statefunc = (statefunc_drift, statefunc_diffusion)
        trigger, handshake, integrator = init_dynamic_system(
                SDEProblem, statefunc, state, t, input, modelargs, solverargs; 
                alg=alg, modelkwargs=modelkwargs, solverkwargs=solverkwargs, numtaps=numtaps
            )
        new{typeof(statefunc), typeof(outputfunc), typeof(state), typeof(t), typeof(integrator), typeof(input), 
            typeof(output), typeof(trigger), typeof(handshake), typeof(callbacks)}(statefunc, outputfunc, state, t, 
            integrator, input, output, trigger, handshake, callbacks, name, uuid4(), sigma, beta, rho, gamma)
    end
end
