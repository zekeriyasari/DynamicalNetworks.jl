# This includes PCM(Pulse Code Modulator)

struct Falling end 
struct Rising end 
(pulse::Falling)(t, high, low, period, duty) = t % period < period * duty ? high : low
(pulse::Rising)(t, high, low, period, duty) = t % period < period * duty ? low : high

"""
    $(TYPEDEF)

Constructs a Pulse Code Modulator(PCM). `bits` is the vector of randomly constructed bits, `high` and `low` are the high and low level of output waveform. `period` and `duty` is the period and duty cycle of the waveform
"""
Base.@kwdef mutable struct PCM
    bits::Vector{Bool} = rand(Bool, 1)
    pulse::Union{Falling, Rising} = bits[1] ? Rising() : Falling()
    high::Float64 = 1.
    low::Float64 = 0. 
    period::Float64 = 1. 
    duty::Float64 = 0.5
end 
function (pcm::PCM)(t)
    (t >= length(pcm.bits) * pcm.period) && switch!(pcm)
    out = pcm.pulse(t, pcm.high, pcm.low, pcm.period, pcm.duty)
end

"""
    $(SIGNATURES)

Switches the form of the pulse of PCM.
"""
function switch!(pcm::PCM) 
    bit = rand(Bool)
    push!(pcm.bits, bit)
    bit ? (pcm.pulse = Rising()) : (pcm.pulse = Falling())
end

