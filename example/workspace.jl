using JLD2, FileIO 
using Plots 

function plot_errors(simpath, param_indexes)
    n = length(param_indexes)
    plt = plot(layout=(n,1))
    for (k, param) in enumerate(param_indexes)
        fname = joinpath(simpath, "Param-$param/Trial-1/data.jld2")
        content = load(fname)
        tv, xv = content["sol_t"], content["sol_x"]
        ev = abs.(getindex.(xv, 1) - getindex.(xv, 4))
        plot!(tv, ev, subplot=k)
    end  
    plt
end 
simpath = "/data/MonteCarlo-2020-09-27T18-22-29" 
plot_errors(simpath, [1, 5, 10])
