using JLD2

function writedata(path, sol; filename::String="data.jld2", savenoise::Bool=false)
    isdir(path) || mkpath(path)
    t, x = sol.t, sol.u
    @save joinpath(path, filename) sol.t sol.u
    # jldopen(joinpath(path, filename), "w") do file
    #     file["sol_t"] = sol.t  
    #     file["sol_x"] = sol.u
    #     if savenoise
    #         file["noise_t"] = sol.W.t
    #         file["noise_u"] = sol.W.u
    #     end
    # end
end
