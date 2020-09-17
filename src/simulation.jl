# This file includes the tools for network simulation 

export Simulation, simulate, readsim

""" 
    $(TYPEDEF)

A simlation object that containining simulation info such as the path of the simulation data file and simulation status.

# Fields 

    $(TYPEDFIELDS)
"""
struct Simulation
    path::String 
    retcode::Symbol
end 


"""
    $(SIGNATURES) 

Simulates net from `ti` to `tf with a step size of `dt`.
"""
function simulate(net::AbstractNetwork, ti=0., dt=0.01, tf=100., solargs=(); solkwargs=NamedTuple(), path=tempdir(), 
    simprefix="Simulation-", simname=replace(split(string(now()), ".")[1], ":" => "-")) 
    # Solve network
    sol = solvenet(net, ti, dt, tf, solargs...; solkwargs...)

    # Construct simulation directory 
    simpath = joinpath(path, simprefix * simname) 
    isdir(simpath) || mkpath(simpath)

    # Write simulation data  
    writedata(simpath, sol)
    writelog(simpath, net, ti, dt, tf)

    # Return simulation directory 
    Simulation(simpath, sol.retcode)
end 

solvenet(net, ti, dt, tf, solargs...; solkwargs...) = solve(getprob(net, (ti, tf)), solargs...; solkwargs...)

"""
    $(SIGNATURES) 

Returns an ODE problem for a time span of `tspan`. 
"""
function getprob(net::ODENetwork, tspan::Tuple)
    function netfunc(dx, x, net, t)
        kernel!(dx, x, net, t)
        addinput!(dx, x, net, t)
    end
    x0 = vcat([vcat(node.x) for node in net.nodes]...)
    ODEProblem(netfunc, x0, tspan, net)
end

function getprob(net::SDENetwork, tspan::Tuple)
    function netdrift(dx, x, net, t)
        kernel!(dx, x, net, t) 
        addinput!(dx, x, net, t)
    end
    function netdiffusion(dx, x, net, t)
        dx .= ⊗(net.H, net.P, t)
    end
    x0 = vcat([vcat(node.x) for node in net.nodes]...)
    n = length(x0)
    SDEProblem(netdrift, netdiffusion, x0, tspan, net, noise_rate_prototype=zeros(n, n))
end

function kernel!(dx, x, net, t)
    n = size(net.E, 1) 
    d = size(net.P, 1) 
    for (node, idx) in zip(net.nodes,  (1 + (i - 1) * d : i * d for i in 1 : n))
        node(view(dx, idx), view(x, idx))
    end
end

addinput!(dx, x, net, t) = (dx .+= ⊗(net.E, net.P, t) * x)
⊗(E, P, t) = eltype(E) <: Number ? kron(E, P) : kron(map(ϵ -> ϵ(t), E), P)

function writedata(simpath, sol::DiffEqBase.AbstractRODESolution)
    datafilepath = joinpath(simpath, "data.jld2") 
    jldopen(datafilepath, "w") do file 
        file["sol_t"] = sol.t 
        file["sol_x"] = sol.u 
        file["noise_t"] = sol.W.t 
        file["noise_x"] = sol.W.u 
    end
end

function writedata(simpath, sol::DiffEqBase.AbstractODESolution)
    datafilepath = joinpath(simpath, "data.jld2") 
    jldopen(datafilepath, "w") do file 
        file["sol_t"] = sol.t 
        file["sol_x"] = sol.u 
    end
end

function writelog(simpath, net, ti, dt, tf)
    logfilepath = joinpath(simpath, "log.jld2") 
    jldopen(logfilepath, "w") do file 
        file["net"] = net 
        file["ti"] = ti
        file["dt"] = dt
        file["tf"] = tf
    end
end

"""
    $(SIGNATURES) 

Reads the simulation data and returns a tuple of simulation time and simulation data.
"""
function readsim(sim::Simulation) 
    log = load(joinpath(sim.path, "log.jld2"))
    data = load(joinpath(sim.path, "data.jld2"))
    net = log["net"] 
    if net isa SDENetwork
        data["sol_t"], data["sol_x"], data["noise_t"], data["noise_x"]
    else
        data["sol_t"], data["sol_x"]
    end
end
