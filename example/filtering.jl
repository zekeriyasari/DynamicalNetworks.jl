using DSP 
using AbstractFFTs
using Plots 

# Generate a signal made up of 10 Hz and 20 Hz sampled at 1kHz

fs = 1000 
ts = 1 / fs 
t = 0 : ts : 1
s = sin.(2π * 10 * t) + sin.(2π * 20 * t)

# Design a high pass filter 
responsetype = Highpass(15, fs=fs)
designmethod = Butterworth(10)
filter = digitalfilter(responsetype, designmethod)

# Apply the filter the signal 
sf = filt(filter, s)

h = freqz(filter)

# Plot the results 
p = plot(layout=(3,1))
plot!(t, s, subplot=1)
plot!(t, sf, subplot=2)
plot!(range(0, stop=π, length=250), abs.(h), subplot=3)

# FFT analysis 
n = length(s) 
HS = fftshift(fft(s))
freq = (-n/2 : n/2 - 1) * (fs / n)
plot(freq, abs.(HS / n))

