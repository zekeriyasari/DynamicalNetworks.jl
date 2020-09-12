# This file illustrates the use of PCM signal.

using Plots 
using DynamicalNetworks 

# Test 
p = PCM() 
ti, dt, tf = 0., 0.01, 10.
t = ti : dt : tf - dt 
plot(t, p.(t))
