"""
module: JSession

Author: Ono keiji

Description:
	manage user session data

functions
    set()
    get()
    clear()
"""
module JSession
using GenieSession, GenieSessionFileSession
export set, get, clear
"""
function __init__()

	this is the session initialize
"""
    function __init__()
        @info "do init()"
        GenieSession.__init__()
    end

    function set()
        @info "do set"
        s = session(params())
        #    if !haskey(s.data, :number)
        GenieSession.set!(s, :uname, "Ono Keiji")
        GenieSession.set!(s, :uid, 111)
        #    end
        @info "set " s.data[:uname] s.data[:uid]
    end

    function get()
        @info "do get"
        s = session(params())
        @info "get " s.data[:uname] s.data[:uid]
    end

    function clear()
        @info "do clear"
        s = session(params())
        s.data = Dict()
        return "cleared"
    end
end
