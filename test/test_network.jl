
@testset "NetworkTestSet" begin 
    # Construct network
    n = 2 
    d = 3 
    ϵ = 10. 
    E = [-1 1; 1 -1]
    P = [1 0 0; 0 0 0; 0 0 0]
    nodes = [Lorenz() for i in 1 : n]
    net = ODENetwork(nodes, E, P)

    # Length
    ti, dt, tf = 0., 0.01, 10.
    sim = simulate(net, ti, dt, tf) 
    @test sim isa Simulation 
    @test sim.retcode == :Success

    # Read simulation 
    t,x  = readsim(sim)
    @test t isa Vector{Float64}
    @test x isa Vector{<:Vector}
end
