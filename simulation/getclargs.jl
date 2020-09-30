
function getclargs()
    settings = ArgParseSettings()

    @add_arg_table! settings begin
        "--ncores"
            help = "number of cores"
            arg_type = Int 
            default = numcores() - 2
        "--nbits"
            help = "number of bits"
            arg_type = Int
            default = 10
        "--tbit"
            help = "bit duration"
            arg_type = Float64
            default = 50.
        "--ntrials"
            help = "number of trials"
            arg_type = Int
            default = 10
        "--coupling-strength"
            help = "coupling strength between the nodes"
            arg_type = Float64
            default = 10.
        "--time-scaling"
            help = "time scaling used to scale network dynamics"
            arg_type = Float64
            default = 1.
        "--dt"
            help = "sampling period"
            arg_type = Float64
            default = 0.01
        "--minsnr"
            help = "minimum snr level"
            arg_type = Int
            default = 0
        "--maxsnr"
            help = "maximum snr level"
            arg_type = Int
            default = 18
        "--stepsnr"
            help = "number of snr level"
            arg_type = Int
            default = 2
        "--simdir"
            help = "simulation directory"
            arg_type = String
            default = "/data"
        "--maxiters"
            help = "maximum number of iterations of solver"
            arg_type = Int
            default = typemax(Int)
        "--simprefix"
            help = "simulation prefix"
            arg_type = String
            default = "MonteCarlo-"
        "--savenoise"
            help = "if true noise is saved in data files"
            action = :store_true
        "--sequential"
            help = "if true simulation is ran sequentially"
            action = :store_true
        "--loglevel"
            help = "logging level"
            arg_type = String
            default = "Info"
    end

    return parse_args(settings)
end
