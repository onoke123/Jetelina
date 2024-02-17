"""
module: JMessage

Author: Ono keiji
Version: 1.0
Description:
	show some messages order by something.

functions
	showModuleInCompiling(m::Module)  show the module info.SS".
"""
module JMessage

export showModuleInCompiling

"""
function showModuleInCompiling(m::Module)

	show module info.
# Arguments
- `m: Module`: target module.
"""
function showModuleInCompiling(m::Module)
	@info """$m compiling...""" parentmodule(m)
end

# for myself :)
showModuleInCompiling(@__MODULE__)
end
