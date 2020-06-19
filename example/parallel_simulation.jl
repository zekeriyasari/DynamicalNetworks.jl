using Distributed 

# Add workers 
nw = nworkers() 
nc = length(Sys.cpu_info())
nw == nc - 1 || addprocs(nc - nw - 1)

# Code loading  
@everywhere begin 
    # Load packages 
    using Pkg 
    Pkg.activate(joinpath(Pkg.envdir(), "dev-env"))
    using Jusdl

    # Define worker function
    function runsim() 
        model = Model() 
        addnode!(model, LorenzSystem(), label=:ds)
        addnode!(model, Writer(input=Inport(3)), label=:writer)
        addbranch!(model, :ds => :writer)
        simulate!(model, 0., 0.01, 100.) 
    end 
end

# Simulate the models 
@sync @distributed for i in 1 : 100
    runsim()
end
