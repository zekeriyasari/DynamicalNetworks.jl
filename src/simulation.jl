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
function simulate(net::Network, ti=0., dt=0.01, tf=100., 
    solargs=(); solkwargs=(;), path=tempdir(), simprefix="Simulation-", simname=split(string(now()), ".")[1]) 
    # Solve network
    sol = solve(getprob(net, (ti, tf)), solargs...,  saveat=dt, solkwargs...)
    sol.t, sol.u 

    # Construct simulation directory 
    simpath = joinpath(path, simprefix * simname) 
    isdir(simpath) || mkpath(simpath)

    # Write simulation data  
    datafilepath = joinpath(simpath, "data.jld2") 
    jldopen(datafilepath, "w") do file 
        file["t"] = sol.t 
        file["x"] = sol.u 
    end

    # Write network and simulation settings  
    logfilepath = joinpath(simpath, "log.jld2") 
    jldopen(logfilepath, "w") do file 
        file["net"] = net 
        file["timings"] = ti : dt : tf
    end

    # Return simulation directory 
    Simulation(simpath, sol.retcode)
end 

"""
    $(SIGNATURES) 

Returns an ODE problem for a time span of `tspan`. 
"""
function getprob(net::Network, tspan::Tuple)
    function netfunc(dx, x, net, t)
        kernel!(dx, x, net, t)
        addinput!(dx, x, net, t)
    end
    x0 = vcat([vcat(node.x) for node in net.nodes]...)
    ODEProblem(netfunc, x0, tspan, net)
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

"""
    $(SIGNATURES) 

Reads the simulation data and returns a tuple of simulation time and simulation data.
"""
function readsim(sim::Simulation) 
    data = load(joinpath(sim.path, "data.jld2"))
    data["t"], data["x"]
end
