# This file includes test nodes 

@testset "NodeTestset" begin 
    # Test node construction 
    node = Lorenz() 

    # Test node calling 
    x = ones(3) 
    dx = ones(3) 
    node(dx, x)
end
