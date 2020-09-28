using DynamicalNetworks 
using FileIO, JLD2 
using Statistics

function process_montecarlo(path) 
    mc = load(joinpath(path, "report.jld2"))["montecarlo"]
    for dname in readdir(mc.path, join=true) 
        if isdir(dname) 
            process_parameter(dname, mc)
        end
    end
end 


function process_parameter(path, mc)
    for dname in readdir(path, join=true)
        if isdir(dname)
            process_trial(dname, mc)
        end
    end
end


function process_trial(path, mc)
    t, x = readdata(path)
    err = geterror(x)
    sentbits = get_sent_bits(mc)
    spb = get_samples_per_bit(mc, sentbits)
    extbits = extractbits(err, spb)
    write_sent_bits(path, sentbits)
    write_extracted_bits(path, extbits)
    writeber(path, ber(extbits, sentbits))
end

get_sent_bits(mc) = mc.net.E[1, 1].bits

get_samples_per_bit(mc, sentbits) = floor(Int, mc.tf / length(sentbits) / mc.dt)

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
