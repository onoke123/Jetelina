"""
module: GetDataController

Author: Ono keiji
Version: 1.0
Description:
    get i/f of ajax

functions
    getTableList()
    getSqlAnalyzerData()
    getPerformanceRealData()
    getPerformanceTestData()
    checkExistImproveFile()
"""
module GetDataController

    using Genie, Genie.Requests,Genie.Renderer.Json
    using DBDataController
    using JetelinaReadConfig, JetelinaLog, JetelinaReadSqlList, JetelinaFiles

    """
    function getTableList()

        calling DBDataController.getTableList() with json mode.
        the return is json form naturally.
    """
    function getTableList()
        DBDataController.getTableList( "json" )
    end
    """
    function getSqlAnalyzerData()

        get JetelinaSQLAnalyzedfile data file name

    # Arguments
    - return: JetelinaSQLAnalyzedfile file name with its path
    """
    function getSqlAnalyzerData()
        sqljsonfile = getFileNameFromLogPath( JetelinaSQLAnalyzedfile )
        return readchomp(sqljsonfile)        
    end
    """
    function getPerformanceRealData()

        get JetelinaSqlPerformancefile data file name

    # Arguments
    - return: JetelinaSqlPerformancefile of json style with its path
    """
    function getPerformanceRealData()
        performancefile = getFileNameFromLogPath( string(JetelinaSqlPerformancefile,".json") )
        return readchomp(performancefile)        
    end
    """
    function getPerformanceTestData()

        get JetelinaSqlPerformancefile data file name but it is '.test' suffix

    # Arguments
    - return: JetelinaSqlPerformancefile of json style with its path
    """
    function getPerformanceTestData()
        performancefile = getFileNameFromLogPath( string(JetelinaSqlPerformancefile,".test.json") )
        return readchomp(performancefile)        
    end
    """
    function checkExistImproveFile()

        get JetelinaImprApis data file name

    # Arguments
    - return: JetelinaImprApis file name with its path    
    """
    function checkExistImproveFile()
        performancefile = getFileNameFromLogPath( JetelinaImprApis )
        return isfile(performancefile)
    end
end