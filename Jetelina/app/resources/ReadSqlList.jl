"""
module: ReadSqlList

Author: Ono keiji
Version: 1.0
Description:
    determaine the path of Jetelina files

functions
    __init__()   this is the initialize proces for importing registered SQL sentence list in JetelinaSQLListfile to DataFrame.
    readSqlList2DataFrame()   import registered SQL sentence list in JetelinaSQLListfile to DataFrame.
                              this function set the sql list data in the global variable 'Df_JetelinaSqlList' as DataFrame object.
"""
module ReadSqlList

    using DataFrames, CSV
#    using JetelinaReadConfig, JetelinaFiles

    include("ReadConfig.jl")
    include("JFiles.jl")
    
    export Df_JetelinaSqlList, readSqlList2DataFrame

    const j_config = ReadConfig

    """
    function __init__()

        this is the initialize proces for importing registered SQL sentence list in JetelinaSQLListfile to DataFrame.
    """
    function __init__()
        readSqlList2DataFrame()
    end
    """
    function readSqlList2DataFrame()

        import registered SQL sentence list in JetelinaSQLListfile to DataFrame.
        this function set the sql list data in the global variable 'Df_JetelinaSqlList' as DataFrame object.
    """
    function readSqlList2DataFrame()
        sqlFile = JFiles.getFileNameFromConfigPath(j_config.JetelinaSQLListfile)
        if isfile(sqlFile)
            df = CSV.read( sqlFile, DataFrame )
            global Df_JetelinaSqlList = df

            if j_config.debugflg
                @info "ReadSqlList.readSqlList2DataFrame() sql list in DataFrame: ", Df_JetelinaSqlList 
            end
        end
    end
end
