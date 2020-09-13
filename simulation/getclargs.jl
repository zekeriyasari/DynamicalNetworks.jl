
function getclargs()
    settings = ArgParseSettings()

    @add_arg_table! settings begin
        "--ncores"
            help = "number of cores"
            arg_type = Int 
            default = numcores() - 1
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
        "--strength"
            help = "coupling strength between the nodes"
            arg_type = Float64
            default = 10.
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
        "--nsnr"
            help = "number of snr level"
            arg_type = Int
            default = 11
        "--simdir"
            help = "simulation directory"
            arg_type = String
            default = tempdir()
        "--simprefix"
            help = "simulation prefix"
            arg_type = String
            default = "MonteCarlo-"
    end

    return parse_args(settings)
end
