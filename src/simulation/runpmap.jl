using ProgressMeter

function runpmap(net, minsnr, stepsnr, maxsnr, ntrials, ti, dt, tf, power, simpath, savenoise, maxiters)
    H0 = copy(net.H)
    @showprogress for snr in minsnr : stepsnr : maxsnr 
        snrpath = joinpath(simpath, "$snr-dB")
        pmap(i -> pmapworker(i, net, snr, snrpath, ti, dt, tf, power, H0, simpath, savenoise, maxiters), 1 : ntrials)
    end
end
