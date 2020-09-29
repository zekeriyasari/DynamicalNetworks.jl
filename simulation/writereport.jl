
function writereport(path, clargs) 
    # Writer into jld file 
    filename = joinpath(path, "report.jld2")
    jldopen(filename, "w") do file 
        for (key, val) in clargs
            file[key] = val
        end
    end
    # Write into text file 
    filename = joinpath(path , "report.txt")
    open(filename,"w") do file 
        for (key, val) in clargs 
            write(file, "$key = $val\n")
        end
    end
end