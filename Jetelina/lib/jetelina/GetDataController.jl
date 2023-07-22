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

    function getPerformanceRealData()
        performancefile = getFileNameFromLogPath( string(JetelinaSqlPerformancefile,".json") )
        return readchomp(performancefile)        
    end

    function getPerformanceTestData()
        performancefile = getFileNameFromLogPath( string(JetelinaSqlPerformancefile,".test.json") )
        return readchomp(performancefile)        
    end

    function checkExistImproveFile()
        performancefile = getFileNameFromLogPath( JetelinaImprApis )
        return isfile(performancefile)
    end
end