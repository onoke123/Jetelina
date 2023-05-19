module JetelinaReadSqlList

    using DataFrames, CSV
    using JetelinaReadConfig, JetelinaFiles

    export Df_JetelinaSqlList

    function __init__()
        readSqlList2DataFrame()
    end

    function readSqlList2DataFrame()
        sqlFile = getFileNameFromConfigPath(JetelinaSQLListfile)
        df = CSV.read( sqlFile, DataFrame )
        global Df_JetelinaSqlList = df

        if debugflg
            @info "sql list in DataFrame: ", Df_JetelinaSqlList 
        end
    end
end
