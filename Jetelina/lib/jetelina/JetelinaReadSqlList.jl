module JetelinaReadSqlList

    using DataFrames, CSV

    export Df_JetelinaSqlList

    #const Df_JetelinaSqlList = Ref{}

    function readSqlList2DataFrame()
        sqlFile = string( joinpath( @__DIR__, "config", "JetelinaSqlList" ))
        df = CSV.read( sqlFile, DataFrame )
        #Df_JetelinaSqlList = Ref(df)
        global Df_JetelinaSqlList = df
        @info "sql list in DataFrame: ", Df_JetelinaSqlList 
        
    end
end
