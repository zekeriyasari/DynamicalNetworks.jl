
function setlogger(path, level)
    filepath = joinpath(path, "simlog.log")
    loglevel = getfield(Logging, Symbol(level))
    TeeLogger(
        MinLevelLogger(FileLogger(filepath), loglevel), 
        MinLevelLogger(ConsoleLogger(), loglevel)
    ) |> global_logger
end