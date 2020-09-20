# This file computes signal power without noise 

function getsignalpower(net, clargs)
    # Simulate network 
    maxiters  = getindex(clargs, :maxiters)
    nbits     = getindex(clargs, :nbits)
    tbit      = getindex(clargs, :tbit)
    dt        = getindex(clargs, :dt)
    ti = 0. 
    tf = nbits * tbit
    sol = DynamicalNetworks.solvenet(net, ti, dt, tf, maxiters=maxiters)

    # Read simulation data 
    t = sol.t 
    ti = collect(t[1] : dt : t[end]) 
    x = sol.(ti)  # Compute the solution with dense steps. 

    # Compute signal error signal power 
    s = getindex.(x, 4) - getindex.(x, 7)   # The error between nodes 2 and 3 
    sum(s[2:end] .^ 2 .* diff(ti) / (ti[end] - ti[1]))
end