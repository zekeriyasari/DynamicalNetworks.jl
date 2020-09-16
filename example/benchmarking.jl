using DynamicalNetworks 
using BenchmarkTools 

# Define functions 

function run_distributed(net, name, vals, ti, dt, tf, ntrials)
    montecarlo(net, name, vals, ti=ti, dt=dt, tf=tf, ntrials=ntrials)
end

function run_serial(net, name, vals, ti, dt, tf, ntrials)
    for val in vals 
        setfield!(net, name, val)
        for n in 1 : ntrials
            simulate(net, ti, dt, tf)
        end
    end
end

# ---------------------------------- Benchmark ----------------------------------- # 

# Construct a network 
net = ODENetwork([Lorenz() for i in 1 : 2], [-1. 1; 1 -1], [1. 0 0; 0 0 0; 0 0 0])

# Simulation settings 
ti, dt, tf  = 0., 0.01, 10.
ntrials = 100 
Es = map(ϵ -> ϵ * net.E, 1 : 10)

# Run to compile the functions 
@info "Calling functions for compilation"
run_serial(net, :E, Es, ti, dt, tf, ntrials)
run_distributed(net, :E, Es, ti, dt, tf, ntrials)
@info "Done."

# Run benchmark 
@info "Running benchmarking..."
@benchmark run_serial($net, :E, $Es, ti, dt, tf, ntrials)
@benchmark run_distributed($net, :E, $Es, ti, dt, tf, ntrials)
@info "Done."
