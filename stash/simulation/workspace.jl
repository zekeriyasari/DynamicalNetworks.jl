# This is file for testing ber calculation. 

# Get simulation directory 
simdir = "/home/sari/Desktop/Simulation-2020-06-23T12-21-53/"
process_sim(simdir)
ber = ber_sim(simdir)
@show ber 

# # Read config 
# config = load(joinpath(simdir, "config.jld2"))

# # Determine an snr
# snr = 0. 
# snrdir = joinpath(simdir, string(snr)*"dB")

# # Determine an experiment number
# numexp = 1
# expdir = joinpath(snrdir, "Exp-"*string(numexp))

# # ## Testing 
# # process_exp(expdir, config)
# # # process_snr(snrdir, config)
# # # process_snr(snrdir, config)
# # ber_exp(expdir)
# # ber_snr(snrdir)
# # ber_sim(simdir)

# # # Read the generated bits 
# # genbits = load(joinpath(expdir, "bits.jld2"))["bits"]

# # # Read the states 
# # t, states = fread(joinpath(expdir, "states.jld2"), flatten=true)

# # # Compute synchronization error 
# # error = abs.(states[:, 7] - states[:, 10])

# # # Calculate sample per bits 
# # ts = config["sampling-period"]
# # tb = config["bit-duration"]
# # spb = floor(Int, tb / ts)

# # # Divide the error into parts corresponding to each bit 
# # parts = collect(Iterators.partition(error, spb))
# # csums = cumsum.(parts)
# # lines = map(cs -> collect(range(cs[1], cs[end], length=length(cs))), csums)
# # extbits = mean.(csums .- lines) .≥ 0.

# # # ---------------------------------- Plots -------------------------- # 
# # nbits = 10 
# # plt = plot(layout=(floor(Int, nbits/2), 2))
# # foreach(i -> plot!(parts[i], title=string(Int(genbits[i])), subplot=i, label=""), 1 : nbits)
# # foreach(i -> plot!(csums[i], title=string(Int(genbits[i])), subplot=i, label=""), 1 : nbits)
# # foreach(i -> plot!(lines[i], title=string(Int(genbits[i])), subplot=i, label=""), 1 : nbits)
# # plt

