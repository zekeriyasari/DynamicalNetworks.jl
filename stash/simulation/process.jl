# This file includes preliminary steps to process simulation files to extract bits




# ------------------------------------ Process Functions -------------------------------- # 

function process_exp(expdir, config)
    @info "\t\tStarted to process $expdir..."

    # Read the states 
    t, states = fread(joinpath(expdir, "states.jld2"), flatten=true)

    # Compute synchronization error 
    error = abs.(states[:, 7] - states[:, 10])

    # Check if elements of error is finite 
    idx = findall(isnan, error)
    isempty(idx) || @warn "Error includes non-finite values. Replacing by zeros."
    error[idx] .= 0.

    # Calculate sample per bits 
    ts = config["sampling-period"]
    tb = config["bit-duration"]
    spb = floor(Int, tb / ts)

    # Divide the error into parts corresponding to each bit 
    parts = collect(Iterators.partition(error, spb))
    csums = cumsum.(parts)
    lines = map(cs -> collect(range(cs[1], cs[end], length=length(cs))), csums)
    extbits = mean.(csums .- lines) .≥ 0.

    # Write extbits to expdir 
    filename = joinpath(expdir, "extbits.jld2")
    jldopen(filename, "w") do file 
        file["bits"] = extbits
    end

    @info "\t\tDone processing $expdir."
end

function process_snr(snrdir, config) 
    @info "\tStarted to process $snrdir..."
    foreach(expdir -> process_exp(expdir, config), readdir(snrdir, join=true))
    @info "\tDone processing $snrdir."
end

function process_sim(simdir)
    @info "Started to process $simdir..."
    config = load(joinpath(simdir, "config.jld2"))
    foreach(snrdir -> process_snr(snrdir, config), filter(isdir, readdir(simdir, join=true)))
    @info "Done processing $simdir."
end

