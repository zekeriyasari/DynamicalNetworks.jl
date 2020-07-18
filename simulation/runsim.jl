
# Load the code 
include("/home/sari/.julia/dev/DynamicalNetworks/simulation/load.jl")

# Define parameters 
simdir = "/tmp/Simulation-test"
snr = 0
numexp = 1 
ti = 0. 
dt = 0.01  
tb = 25 
duty = 0.5 
numbits = 50
tf = numbits * tb 
_runsim(simdir, snr, numexp, ti, dt, tf, tb, duty, logtofile=false, withbar=true)
# for numbits in 10 : 10 : 100  
#     tf = numbits * tb 
#     _runsim(simdir, snr, numexp, ti, dt, tf, tb, duty, logtofile=false, withbar=true)
#     @info "\nDone for $numbits bits"
# end 


