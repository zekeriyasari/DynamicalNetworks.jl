using JLD2

function writebits(path, bits; filename::String="sentbits.jld2")
    isdir(path) || mkpath(path)
    jldopen(joinpath(path, filename), "w") do file 
        file["sentbits"] = bits
    end
end