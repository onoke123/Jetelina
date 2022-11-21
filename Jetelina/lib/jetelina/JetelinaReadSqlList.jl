module JetelinaReadSqlList

    using DataFrames, CSV

    function readSqlList2DataFrame()
        sqlFile = string( joinpath( @__DIR__, "config", "JetelinaSqlList" ))
        df = CSV.read( sqlFile, DataFrame )
        @info "sql list in DataFrame: ", df 
        
    end
end
