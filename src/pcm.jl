# This file includes pulse code modulation type 

export PCM 

struct Rising end 
struct Falling end 
pulse(::Type{Rising}, t, high, low, period, duty) = t % period ≤ duty * period ? low : high 
pulse(::Type{Falling}, t, high, low, period, duty) = t % period ≤ duty * period ? high : low 

Base.@kwdef struct PCM{T}
    bits::Vector{Bool} 
    high::T = 1.
    low::T  = 0. 
    period::T = 1. 
    duty::T = 0.5
end 

function (pcm::PCM)(t) 
    n = length(pcm.bits)
    T = pcm.period
    tf = n * T 
    idx = t == tf ? n : findlast(t .≥  (0 : n) * T)
    pType = pcm.bits[idx] ? Rising : Falling 
    pulse(pType, t, pcm.high, pcm.low, pcm.period, pcm.duty)
end
