module JetelinaReadSqlList

    using DataFrames, CSV
    using JetelinaReadConfig, JetelinaFiles

    export Df_JetelinaSqlList

    function __init__()
        readSqlList2DataFrame()
    end

    function readSqlList2DataFrame()
        sqlFile = getFileNameFromConfigPath(JetelinaSQLListfile)
#        sqlFile = string( joinpath( @__DIR__, "config", JetelinaSQLListfile ))
        df = CSV.read( sqlFile, DataFrame )
        #Df_JetelinaSqlList = Ref(df)
        global Df_JetelinaSqlList = df
        @info "sql list in DataFrame: ", Df_JetelinaSqlList 
        
    end
end
