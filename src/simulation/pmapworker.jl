
function pmapworker(i, net, snr, snrpath, ti, dt, tf, power, simpath, savenoise, maxiters)
    net.H = sqrt(power / (10^(snr / 10))) * H0
    sol = solvenet(net, (ti, tf), maxiters=maxiters, saveat=dt)
    @show (snr, i, sol.retcode)
    trialpath = joinpath(snrpath, "Trial-$i")
    writedata(trialpath, sol, savenoise=savenoise)
    writebits(trialpath, net.E[1,1].bits)
end
