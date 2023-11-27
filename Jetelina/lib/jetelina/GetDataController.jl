"""
module: GetDataController

Author: Ono keiji
Version: 1.0
Description:
    get i/f of ajax

functions
    getTableList() calling DBDataController.getTableList() with json mode. the return is json form naturally.
    getSqlAccessData() get JetelinaSqlAccess data file name. this file  contains access cound data in each sql due to sql.txt log file.
    getTableCombiVsAccessRelationData()  get JetelinaTableCombiVsAccessRelation data file name. this file is analyzed data for table combination.
    getPerformanceRealData()  get JetelinaSqlPerformancefile data file name. this file is analyzed data for real sql execution speed.
    getPerformanceTestData()  get JetelinaSqlPerformancefile data file name but it is '.test' suffix. this file is analyzed data for sql execution speed on test db.
    checkExistImproveApiFile()  get JetelinaImprApis data file name. this file contains an improving suggestion data of a target api. 
"""
module GetDataController

    using Genie, Genie.Requests,Genie.Renderer.Json
    using DBDataController
    using JetelinaReadConfig, JetelinaLog, JetelinaReadSqlList, JetelinaFiles

    export getTableList,getTableCombiVsAccessRelationData,getPerformanceRealData,getPerformanceTestData,checkExistImproveApiFile

    """
    function getTableList()

        calling DBDataController.getTableList() with json mode.
        the return is json form naturally.
    """
    function getTableList()
        DBDataController.getTableList( "json" )
    end
    """
    function getSqlAccessData()

        get JetelinaSqlAccess data file name. this file  contains access numbers data in each sql due to sql.txt log file.

    # Arguments
    - return: JetelinaSqlAccess file name with its path
    """
    function getSqlAccessData()
        f = getFileNameFromLogPath( JetelinaSqlAccess )
        if isfile(f) 
            return readchomp(f)        
        else
            return false
        end
    end
    """
    function getTableCombiVsAccessRelationData()

        get JetelinaTableCombiVsAccessRelation data file name. this file is analyzed data for table combination.

    # Arguments
    - return: JetelinaTableCombiVsAccessRelation file name with its path
    """
    function getTableCombiVsAccessRelationData()        
        f = getFileNameFromLogPath( JetelinaTableCombiVsAccessRelation )
        if isfile(f) 
            return readchomp(f)        
        else
            return false
        end
    end
    """
    function getPerformanceRealData()

        get JetelinaSqlPerformancefile data file name. this file is analyzed data for real sql execution speed.

    # Arguments
    - return: JetelinaSqlPerformancefile of json style with its path
    """
    function getPerformanceRealData()
        f = getFileNameFromLogPath( string(JetelinaSqlPerformancefile,".json") )
        if isfile(f)
            return readchomp(f)
        else
            return false
        end
    end
    """
    function getPerformanceTestData()

        get JetelinaSqlPerformancefile data file name but it is '.test' suffix. this file is analyzed data for sql execution speed on test db.

    # Arguments
    - return: JetelinaSqlPerformancefile of json style with its path
    """
    function getPerformanceTestData()
        f = getFileNameFromLogPath( string(JetelinaSqlPerformancefile,".test.json") )
        if isfile(f)
            return readchomp(f)
        else
            return false
        end
    end
    """
    function checkExistImproveApiFile()

        get JetelinaImprApis data file name. this file contains an improving suggestion data of a target api. 

    # Arguments
    - return: JetelinaImprApis file name with its path    
    """
    function checkExistImproveApiFile()
        f = getFileNameFromLogPath( JetelinaImprApis )
        if isfile(f)
            return isfile(f)
        else
            return false
        end
    end
end