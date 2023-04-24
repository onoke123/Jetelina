module SQLSentenceManager
    using DBDataController
    using JetelinaReadConfig, JetelinaLog, JetelinaReadSqlList

    function writeTolist(sql,tablename)
        # get the sequence name then create the sql sentence
        seq_no = DBDataController.getSequenceNumber(1)
        suffix = string()

        if startswith(sql,"insert")
            suffix = "ji"
        elseif startswith(sql,"update")
            suffix = "ju"
        elseif startswith(sql,"select")
            suffix = "js"
        end

#        sqlsentence = """$suffix$seq_no,\"select $sql from $tablename\"\n"""
        sqlsentence = """$suffix$seq_no,\"$sql\"\n"""

        if debugflg
            @info "sql sentence: ", sqlsentence
        end

        # write the sql to the file
        sqlFile = string( joinpath( @__DIR__, "config", "JetelinaSqlList" ))
        f = open( sqlFile, "a" )

        if isfile( sqlFile )
            write(f, sqlsentence)
        else
            write(f,"no,sql")
            write(f,sqlsentence)
        end
        
        close(f)

        JetelinaReadSqlList.readSqlList2DataFrame()
    end
end