# This file includes preliminary steps to process simulation files to extract bits

using Jusdl 
using JLD2, FileIO 
using Plots 
using Statistics

# ------------------------------------ Utility Functions -------------------------------- # 

function process_exp(expdir, config)
    @info "\t\tStarted to process $expdir..."

    # Read the states 
    t, states = fread(joinpath(expdir, "states.jld2"), flatten=true)

    # Compute synchronization error 
    error = abs.(states[:, 7] - states[:, 10])

    # Check if elements of error is finite 
    idx = findall(isnan, error)
    isempty(idx) || @warn "Error includes non-finite values. Replacing by zeros."
    error[idx] .= 0.

    # Calculate sample per bits 
    ts = config["sampling-period"]
    tb = config["bit-duration"]
    spb = floor(Int, tb / ts)

    # Divide the error into parts corresponding to each bit 
    parts = collect(Iterators.partition(error, spb))
    csums = cumsum.(parts)
    lines = map(cs -> collect(range(cs[1], cs[end], length=length(cs))), csums)
    extbits = mean.(csums .- lines) .≥ 0.

    # Write extbits to expdir 
    filename = joinpath(expdir, "extbits.jld2")
    jldopen(filename, "w") do file 
        file["bits"] = extbits
    end

    @info "\t\tDone processing $expdir."
end

function process_snr(snrdir, config) 
    @info "\tStarted to process $snrdir..."
    foreach(expdir -> process_exp(expdir, config), readdir(snrdir, join=true))
    @info "\tDone processing $snrdir."
end

function process_sim(simdir)
    @info "Started to process $simdir..."
    config = load(joinpath(simdir, "config.jld2"))
    foreach(snrdir -> process_snr(snrdir, config), filter(isdir, readdir(simdir, join=true)))
    @info "Done processing $simdir."
end

# ---------------------------------------- Main ----------------------------------------------- # 

# Get simulation directory 
simdir = "/home/sari/Desktop/Simulation-2020-06-23T12-21-53/"
process_sim(simdir)

# # Read config 
# config = load(joinpath(simdir, "config.jld2"))

# # Determine an snr
# snr = 18. 
# snrdir = joinpath(simdir, string(snr)*"dB")

# # Determine an experiment number
# numexp = 1
# expdir = joinpath(snrdir, "Exp-"*string(numexp))

# ## Testing 
# process_exp(expdir, config)
# # process_snr(snrdir, config)
# # process_snr(snrdir, config)

# # Read the generated bits 
# genbits = load(joinpath(expdir, "bits.jld2"))["bits"]

# # Read the states 
# t, states = fread(joinpath(expdir, "states.jld2"), flatten=true)

# # Compute synchronization error 
# error = abs.(states[:, 7] - states[:, 10])

# # Calculate sample per bits 
# ts = config["sampling-period"]
# tb = config["bit-duration"]
# spb = floor(Int, tb / ts)

# # Divide the error into parts corresponding to each bit 
# parts = collect(Iterators.partition(error, spb))
# csums = cumsum.(parts)
# lines = map(cs -> collect(range(cs[1], cs[end], length=length(cs))), csums)
# extbits = mean.(csums .- lines) .≥ 0.

# # ---------------------------------- Plots -------------------------- # 
# nbits = 10 
# plt = plot(layout=(floor(Int, nbits/2), 2))
# foreach(i -> plot!(parts[i], title=string(Int(genbits[i])), subplot=i, label=""), 1 : nbits)
# foreach(i -> plot!(csums[i], title=string(Int(genbits[i])), subplot=i, label=""), 1 : nbits)
# foreach(i -> plot!(lines[i], title=string(Int(genbits[i])), subplot=i, label=""), 1 : nbits)
# plt

