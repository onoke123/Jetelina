"""
module: JSession

Author: Ono keiji

Description:
	manage user session data

functions
    set(un,id) set ordered session data
	get()  get session data
	clear()  clear session data
"""
module JSession
using Genie, GenieSession, GenieSessionFileSession
export set, get, clear
"""
function __init__()

	this is the session initialize
"""
function __init__()
	@info "do init()"
	GenieSession.__init__()
end
"""
function set(un,id)

    set ordered session data

# Arguments
-un:String  login user name
-id:Int login user id
"""
function set(un,id)
#	@info "set session data with " un id
	s = session(params())
	GenieSession.set!(s, :uname, un)
	GenieSession.set!(s, :uid, id)
end
"""
function get()

    get session data

# Arguments
-return: Tuple: (uname::String,uid::Int)
"""
function get()
	s = session(params())
	return s.data[:uname], s.data[:uid]
end
"""
function clear()

    clear session data
"""
function clear()
	s = session(params())
	s.data = Dict()
end

end
