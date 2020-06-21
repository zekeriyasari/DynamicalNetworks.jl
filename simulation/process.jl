# This file includes the code to process simulation data files to calculate the ber performance of cluster synchronization communication 

using Jusdl 

# TODO: Simulation directory must recorded 

# --------------------------------- Utility functions -------------------------- # 

""" Process simulation data file """
function process_file(filepath)
    t, x = fread(filepath) 
    s = abs.(x[:, 7] - x[:, 10])
end

""" Process all the files in snr directory """
function process_snrdir(snrdir) end

""" Process all the files in simulation directory """
function process_simulation(snrdir) end

# ----------------------------------- Main ------------------------------------- # 

# Read all simulation data files 
simdir = "/home/sari/Desktop/Simulation-2020-06-21T16-02-05/"
filetree = walkdir(simdir)
take!(filetree) # Pop the root directory `test` in which `runtests.jl` is.
for (snrdir, _, datafiles) in filetree
    @show (snrdir, datafiles)
end

