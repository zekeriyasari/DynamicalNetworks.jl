using FileIO, JLD2 
using Statistics
using ArgParse
using Statistics

function get_commandline_arguments()
    settings = ArgParseSettings()

    @add_arg_table! settings begin
        "simdir"
            help = "path of the directory to be processed"
            required = true
    end

    return parse_args(settings)
end

function process_montecarlo(path) 
    report = load(joinpath(path, "report.jld2"))
    snrber = Dict{String, Float64}() 
    for dname in readdir(path, join=true) 
        if isdir(dname) 
            avgberval = process_snr(dname, report)
            snrber[basename(dname)] = avgberval
        end
    end
    @save joinpath(path, "snrber.jld2") snrber
    open(joinpath(path, "snrber.txt"), "w") do file 
        for (k, v) in sort(collect(snrber), by=x->x[1])
            write(file, "$k = $v\n")
        end
    end
    snrber
end 

function process_snr(path, report)
    bervals = map(readdir(path, join=true)) do dname 
        if isdir(dname)
            process_trial(dname, report)
        end
    end
    @show bervals
    avgberval = mean(bervals)
    @save joinpath(path, "avgberval.jld2") avgberval
    open(joinpath(path, "avgberval.txt"), "w") do file 
        write(file, "avgberval = $avgberval")
    end
    avgberval
end


function process_trial(path, report)
    t, x = readdata(path)
    err = geterror(x)
    sentbits = get_sent_bits(path)
    spb = get_samples_per_bit(report)
    extbits = extractbits(err, spb)
    write_extracted_bits(path, extbits)
    berval = ber(extbits, sentbits)
    writeber(path, berval)
    berval
end

function get_sent_bits(path)
    @load joinpath(path, "sentbits.jld2") sentbits 
    sentbits
end

function get_samples_per_bit(report)
    floor(Int, report["tbit"] / report["dt"])
end

function readdata(path)
    data = load(joinpath(path, "data.jld2"))
    data["sol_t"], data["sol_x"]
end

geterror(x) = abs.(getindex.(x, 7) - getindex.(x, 10))

function extractbits(err, spb)
    parts = collect(Iterators.partition(err, spb))
    length(last(parts)) == spb || pop!(parts)  # Truncate the last part if  its length is not spb
    csums = cumsum.(parts)
    lines = map(cs -> collect(range(cs[1], cs[end], length=length(cs))), csums)
    mean.(csums .- lines) .≥ 0.
end

function write_sent_bits(path, sentbits)
    filename = joinpath(path, "sentbits.jld2")
    jldopen(filename, "w") do file 
        file["sentbits"] = sentbits
    end
end

function write_extracted_bits(path, extbits)
    filename = joinpath(path, "extbits.jld2")
    jldopen(filename, "w") do file 
        file["extbits"] = extbits
    end
end

ber(extbits, sentbits) = length(findall(extbits .== sentbits)) / length(sentbits)

function writeber(path, berval)
    filename = joinpath(path, "ber.jld2")
    jldopen(filename, "w") do file 
        file["ber"] = berval
    end
end

commandline_arguments = get_commandline_arguments()
process_montecarlo(commandline_arguments["simdir"])
