module JetelinaReadSqlList

    using DataFrames, CSV

    const Df_JetelinaSqlList = Ref{}

    function readSqlList2DataFrame()
        sqlFile = string( joinpath( @__DIR__, "config", "JetelinaSqlList" ))
        df = CSV.read( sqlFile, DataFrame )
        Df_JetelinaSqlList = Ref(df)
        @info "sql list in DataFrame: ", Df_JetelinaSqlList 
        
    end
end
