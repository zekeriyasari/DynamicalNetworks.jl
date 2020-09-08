# This file includes the tools for network simulation 

export Simulation, simulate, readsim

""" 
    $(TYPEDEF)

A simlation object that containining simulation info such as the path of the simulation data file and simulation status.

# Fields 

    $(TYPEDFIELDS)
"""
struct Simulation
    filepath::String 
    retcode::Symbol
end 


"""
    $(SIGNATURES) 

Simulates net from `ti` to `tf with a step size of `dt`.
"""
function simulate(net::Network, ti=0., dt=0.01, tf=100., 
    solargs=(); solkwargs=(;), path=tempdir(), filename=split(string(now()), ".")[1]) 
    # Solve network
    sol = solve(getprob(net, (ti, tf)), solargs...,  saveat=dt, solkwargs...)
    sol.t, sol.u 

    # Write simulation data  
    filepath = joinpath(path, filename * ".jld2") 
    jldopen(filepath, "w") do file 
        file["t"] = sol.t 
        file["x"] = sol.u 
    end

    # Return simulation directory 
    Simulation(filepath, sol.retcode)
end 

"""
    $(SIGNATURES) 

Returns an ODE problem for a time span of `tspan`. 
"""
function getprob(net::Network, tspan::Tuple)
    function netfunc(dx, x, (E, P), t)
        n = size(E, 1)
        d = size(P, 1)
        nodes = net.nodes
        # Update individual nodes 
        for (node, idx) in zip(nodes,  (1 + (i - 1) * d : i * d for i in 1 : n))
            node(view(dx, idx), view(x, idx))
        end
        # Sum coupling terms.
        dx .+= kron(E, P) * x 
    end
    x0 = vcat([vcat(node.x) for node in net.nodes]...)
    ODEProblem(netfunc, x0, tspan, (net.E, net.P))
end

"""
    $(SIGNATURES) 

Reads the simulation data and returns a tuple of simulation time and simulation data.
"""
function readsim(sim::Simulation) 
    data = load(sim.filepath)
    data["t"], data["x"]
end
