
function getpower(net, clargs, solargs...; solkwargs...)
    # Simulation settings 
    ti = 0. 
    dt = clargs["dt"]
    tf = clargs["nbits"] * clargs["tbit"]

    # Solve network 
    netc = deepcopy(net)
    netc.H .= 0. 
    sol = solvenet(netc, (ti, tf), solargs...; solkwargs...)

    # Sample the solution with a samling period of dt
    t = collect(ti : dt : tf - dt) 
    x = sol.(t)

    # Compute error signal  power 
    s = abs.(getindex.(x, 4) - getindex.(x, 7))
    N = length(s) - 1
    clargs["power"] = sum(s[1 : N] .^ 2) / N
end
