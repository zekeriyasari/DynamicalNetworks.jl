
function setlogger(level)
    loglevel = getfield(Logging, Symbol(level))
    TeeLogger(
        MinLevelLogger(FileLogger("simlog.log"), loglevel), 
        MinLevelLogger(ConsoleLogger(), loglevel)
    ) |> global_logger
end