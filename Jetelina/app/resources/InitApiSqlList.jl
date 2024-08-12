module InitApiSqlList

using Jetelina.JMessage, Jetelina.ApiSqlListManager

JMessage.showModuleInCompiling(@__MODULE__)

function __init__()
	@info "==========InitApiSqlList init================"
    ApiSqlListManager.__init__()
end

end