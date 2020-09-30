using ProgressMeter

function runthreaded(net, minsnr, stepsnr, maxsnr, ntrials, ti, dt, tf, power, simpath, savenoise, maxiters)
    H0 = copy(net.H)
    @showprogress for snr in minsnr : stepsnr : maxsnr 
        snrpath = joinpath(simpath, "$snr-dB")
        Threads.@threads for i in 1 : ntrials
            net.H = sqrt(power / (10^(snr / 10))) * H0
            sol = solvenet(net, (ti, tf), maxiters=maxiters, saveat=dt)
            @show (snr, i, sol.retcode)
            trialpath = joinpath(snrpath, "Trial-$i")
            # writedata(trialpath, sol, savenoise=savenoise)
            writebits(trialpath, net.E[1,1].bits)
        end
    end
end

