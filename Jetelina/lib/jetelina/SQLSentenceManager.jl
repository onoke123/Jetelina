module SQLSentenceManager
    using DBDataController
    using JetelinaReadConfig, JetelinaLog, JetelinaReadSqlList

    # sqli list file
    sqlFile = string( joinpath( @__DIR__, "config", "JetelinaSqlList" ))

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
        elseif startswith(sql,"delete")
            suffix = "jd"
        end

#        sqlsentence = """$suffix$seq_no,\"select $sql from $tablename\"\n"""
        sqlsentence = """$suffix$seq_no,\"$sql\"\n"""

        if debugflg
            @info "sql sentence: ", sqlsentence
        end

        # write the sql to the file
        f = open( sqlFile, "a" )

        if isfile( sqlFile )
            write(f, sqlsentence)
        else
            write(f,"no,sql")
            write(f,sqlsentence)
        end
        
        close(f)

        # DataFrameを更新する
        JetelinaReadSqlList.readSqlList2DataFrame()
    end

    #===
        drop tableと同時にsql listから対象tableのヤツを消す
    ===#
    function deleteFromlist(tablename)
        sqlTmpFile = string( joinpath( @__DIR__, "config", "JetelinaSqlList.tmp" ))

        open(sqlTmpFile, "w") do tf
            open(sqlFile, "r") do f
                # keep=falseにして改行文字を取り除いておく。そしてprintln()する
                for ss in eachline(f, keep=false)
                    if !occursin(tablename,ss)
                        @info "hit: " ss
                        #対象tableを含まないものだけ書き出す
                        println(tf, ss)
                    end
                end
            end
        end

        # 全部終わったら scenarioTmpFile->scenarioFileとする
        #mv( sqlTmpFile,sqlFile,force=true)
        # DataFrameを更新する
        #JetelinaReadSqlList.readSqlList2DataFrame()
    end
end