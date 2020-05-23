# This includes PCM(Pulse Code Modulator)

"""
    PCM

Pulse Code modulator
"""
Base.@kwdef struct PCM 
    high::Float64 = 1. 
    low::Float64 = 0.
    period::Float64 = 1.
    duty::Float64 = 0.5 
    delay::Float64 = 0.
end

function (pcm::PCM)(t)
    if t <= pcm.delay
        return pcm.low
    else
        ((t - pcm.delay) % pcm.period <= pcm.duty * pcm.period) ? pcm.high : pcm.low
    end
end
