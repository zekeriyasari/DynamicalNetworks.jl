# This file includes the code to process simulation data files to calculate the ber performance of cluster synchronization communication 

using Jusdl 
using JLD2, FileIO

# --------------------------------- Utility functions -------------------------- # 

""" Reads simuation config file """
read_config(simdir) = load(joinpath(simdir, "config.jld2"))

""" Calculates sample per bits """
calculate_sample_per_bits(config) = floor(Int, config["bit-duration"] / config["sampling-period"])

function extractbits(error, config)
    sample_per_bits = calculate_sample_per_bits(config)
end

""" Process simulation data file """
function process_experiment(exppath)
    filepath = joinpath(exppath, "states.jld2")
    t, states = fread(filepath, flatten=true) 
    error = abs.(states[:, 7] - states[:, 10])
    extractedbits = extractbits(error)
end

""" Process all the files in snr directory """
function process_snrdir(snrdir) end

""" Process all the files in simulation directory """
function process_simulation(snrdir) end

# # ----------------------------------- Main ------------------------------------- # 

# simdir = "/home/sari/Desktop/Simulation-2020-06-21T16-02-05/"

# # Read all simulation data files 
# filetree = walkdir(simdir)
# take!(filetree) # Pop the root directory `test` in which `runtests.jl` is.
# for (snrdir, _, datafiles) in filetree
#     @show (snrdir, datafiles)
# end

