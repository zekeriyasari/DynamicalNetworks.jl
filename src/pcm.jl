# This file includes pulse code modulation type 

export PCM, Constant

abstract type AbstractPCM end
struct Rising end 
struct Falling end 
pulse(::Type{Rising}, t, high, low, period, duty) = t % period ≤ duty * period ? low : high 
pulse(::Type{Falling}, t, high, low, period, duty) = t % period ≤ duty * period ? high : low 

"""
    $(TYPEDEF) 

Pulse Code Modulator that modulates input bit sequence to time waveform. 

# Fields
 
    $(TYPEDFIELDS)
"""
Base.@kwdef struct PCM{T1, T2, T3, T4} <: AbstractPCM
    bits::Vector{Bool} 
    high::T1 = 1.
    low::T2  = 0. 
    period::T3 = 1. 
    duty::T4 = 0.5
end 

function (pcm::PCM)(t) 
    n = length(pcm.bits)
    T = pcm.period
    tf = n * T 
    idx = t == tf ? n : findlast(t .≥  (0 : n) * T)
    pType = pcm.bits[idx] ? Rising : Falling 
    pulse(pType, t, pcm.high, pcm.low, pcm.period, pcm.duty)
end

"""
    $(TYPEDEF)

Constant generator 

# Fields 

    $(TYPEDFIELDS)
"""
Base.@kwdef struct Constant{T} <: AbstractPCM
    level::T 
end 
(con::Constant)(t) = con.level
