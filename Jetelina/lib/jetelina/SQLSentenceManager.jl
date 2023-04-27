module SQLSentenceManager
using DBDataController
using JetelinaReadConfig, JetelinaLog, JetelinaReadSqlList

# sqli list file
sqlFile = string(joinpath(@__DIR__, "config", "JetelinaSqlList"))
tableapiFile = string(joinpath(@__DIR__, "config", "JetelinaTableApi"))

function writeTolist(sql, tablename_arr)
    # get the sequence name then create the sql sentence
    seq_no = DBDataController.getSequenceNumber(1)
    suffix = string()

    if startswith(sql, "insert")
        suffix = "ji"
    elseif startswith(sql, "update")
        suffix = "ju"
    elseif startswith(sql, "select")
        suffix = "js"
    elseif startswith(sql, "delete")
        suffix = "jd"
    end

    #        sqlsentence = """$suffix$seq_no,\"select $sql from $tablename\"\n"""
    sqlsentence = """$suffix$seq_no,\"$sql\""""

    if debugflg
        @info "sql sentence: ", sqlsentence
    end

    # write the sql to the file
    thefirstflg = true
    if !isfile(sqlFile)
        thefirstflg = false
    end

    open(sqlFile, "a") do f
        if !thefirstflg
            println(f, "no,sql")
        end


        println(f, sqlsentence)
    end

    # write the relation between tables and api to the file
    open(tableapiFile, "a") do ff
        println(ff, string(suffix, seq_no, ":", join(tablename_arr, ",")))
    end

    # DataFrameを更新する
    JetelinaReadSqlList.readSqlList2DataFrame()
end

#===
    drop tableと同時にsql listから対象tableのヤツを消す
===#
function deleteFromlist(tablename)
    sqlTmpFile = string(joinpath(@__DIR__, "config", "JetelinaSqlList.tmp"))

    # 該当tableと関係するApiを取得する
    targetapi = []
    open(tableapiFile, "r") do taf
        # keep=falseにして改行文字を取り除いておく。そしてprintln()する
        for ss in eachline(taf, keep=false)
            p = split(ss, ":") # api_name:table,table,....
            tmparr = split(p[2],',')
            if tablename ∈ tmparr
                push!(targetapi, p[1]) # ["js1","ji2,.....]
            end
        end
    end
    # targetapiに含まれないSQLだけ残す
    open(sqlTmpFile, "w") do tf
        open(sqlFile, "r") do f
            for ss in eachline(f, keep=false)
                p = split(ss,"\"") # js1,"select..."
                @info "chk target: " rstrip(p[1],','), targetapi 
                if rstrip(p[1],',') ∈ targetapi # これこれぇ＼(^o^)／
                    # 含まれるのでスキップ
                else
                    @info "hit: " ss
                    #対象tableを含まないものだけ書き出す
                    println(tf, ss)
                end
            end
        end
    end

    # 全部終わったら scenarioTmpFile->scenarioFileとする
    mv( sqlTmpFile,sqlFile,force=true)
    
    # DataFrameを更新する
    JetelinaReadSqlList.readSqlList2DataFrame()
end

end