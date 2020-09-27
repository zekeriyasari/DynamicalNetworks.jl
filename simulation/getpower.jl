
function getpower(net, ti, dt, tf, solargs...; solkwargs...)
    netc = deepcopy(net)
    netc.H .= 0. 
    sol = solvenet(netc, ti, dt, tf, solargs...; solkwargs...)

    t = collect(ti : dt : tf - dt) 
    x = sol.(t)

    s = abs.(getindex.(x, 4) - getindex.(x, 7))

    N = length(s) - 1
    sum(s[1 : N] .^ 2) / N
end
