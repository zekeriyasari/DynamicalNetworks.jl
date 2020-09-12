# This file includes ber calculation 

function ber_exp(expdir)
    genbits = load(joinpath(expdir, "bits.jld2"))["bits"]
    extbits = load(joinpath(expdir, "extbits.jld2"))["bits"]
    length(findall(genbits .== extbits)) / length(genbits) 
end
ber_snr(snrdir) = mean(ber_exp.(readdir(snrdir, join=true)))
ber_sim(simdir) = ber_snr.(filter(isdir, readdir(simdir, join=true)))
