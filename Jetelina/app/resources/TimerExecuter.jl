"""
	module: TimerExecuter

	Author: Ono keiji
	Version: 1.0
	Description:
        This module is a tricky program.
        Because Genie does not exectute __init__() as far as not execute include().
        We wanna kick __init__() to start some timer programs.
        The 'TimerExecuter.jl' is for that, thus this JTimer only does include it.
"""
module TimerExecuter

using Jetelina.JMessage

JMessage.showModuleInCompiling(@__MODULE__)

include("SQLAnalyzer.jl")
#include("timertest.jl")

function __init__()
    @info "==============TimerExecuter init==============="
#    timertest.dosomething(10)
    SQLAnalyzer.main()
end

end