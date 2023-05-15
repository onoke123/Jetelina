module GetDataController

    using Genie, Genie.Requests,Genie.Renderer.Json
    using DBDataController
    using JetelinaReadConfig, JetelinaLog, JetelinaReadSqlList, JetelinaFiles

    function getTableList()
        DBDataController.getTableList( "json" )
    end


    function getSqlAnalyzerData()
        sqljsonfile = getFileNameFromLogPath( JetelinaSQLAnalyzedfile )
        return readchomp(sqljsonfile)        
    end
end