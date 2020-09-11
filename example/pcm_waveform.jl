# This file includes an example file for PCM waveform 

using DynamicalNetworks
using Plots 

pcm = PCM(bits=rand(Bool, 10), period=2.)
ti, dt, tf = 0, 0.01, 10.
tr = collect(ti : dt : tf)
plot(tr, pcm.(tr))
