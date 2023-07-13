module SQLSentenceManager

using Dates, StatsBase, CSV
using DBDataController, JetelinaReadConfig, JetelinaLog, JetelinaReadSqlList, JetelinaFiles

# sqli list file
sqlFile = getFileNameFromConfigPath(JetelinaSQLListfile)
tableapiFile = getFileNameFromConfigPath(JetelinaTableApifile)

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

    sqlsentence = """$suffix$seq_no,\"$sql\""""

    if debugflg
        @info "sql sentence: ", sqlsentence
    end

    # write the sql to the file
    thefirstflg = true
    if !isfile(sqlFile)
        thefirstflg = false
    end

    try
        open(sqlFile, "a") do f
            if !thefirstflg
                println(f, "no,sql")
            end


            println(f, sqlsentence)
        end
    catch err
        JetelinaLog.writetoLogfile("SQLSentenceManager.writeTolist() error: $err")
        return false, nothing
    end

    # write the relation between tables and api to the file
    try
        open(tableapiFile, "a") do ff
            println(ff, string(suffix, seq_no, ":", join(tablename_arr, ",")))
        end
    catch err
        JetelinaLog.writetoLogfile("SQLSentenceManager.writeTolist() error: $err")
        return false, nothing
    end

    # DataFrameを更新する
    JetelinaReadSqlList.readSqlList2DataFrame()

    return true, string(suffix, seq_no)
end

"""
    updateSqlList()

    JetelinaSQLListfileファイルの更新を行う

    Args
        type: v->view tableのSQLなのでappend処理
              c->common 通常のSQLなので上書き処理
        
        dic : 更新対象SQLが、apino=>sql のDict形式
                ex.  js100=>select ....
"""
function updateSqlList(type,dic)
    #===
        SQL ListはDf_JetelinaSqlListでdataframe形式でメモリ展開されている。
        これをDict形式に変換するもよし、元のJetelinaSqlListファイルをCSV.read()してDictにするもよし。
        今回は元ファイルからにしてみる。
    ===#
    orglist = CSV.File(sqlFile) |> Dict
    @info "org list dict type: " println(orglist)

    newlist = merge!(orglist,dic)
    @info "new list dict type: " println(newlist)

    #===
        ファイル書き込みの準備はできた。
        ここで書き込むのは試験用のリストになる。なぜならリストを作成したあとに実行速度の測定をするから。
        なので新しいファイル名が必要になる。
        それをconfファイルに追加しないと。
    ===#
    
end

#===
    drop tableと同時にsql listから対象tableのヤツを消す
===#
function deleteFromlist(tablename)
    sqlTmpFile = getFileNameFromConfigPath("$JetelinaSQLListfile.tmp")
    tableapiTmpFile = getFileNameFromConfigPath("JetelinaTableApi.tmp")

    # 該当tableと関係するApiを取得する
    targetapi = []
    # 対象ファイル類のバックアップをとっておく
#    backupfilesuffix = Dates.format(now(), "yyyymmdd-HHMMSS")
#    cp(tableapiFile, string(tableapiFile, backupfilesuffix), force=true)
#    cp(sqlFile, string(sqlFile, backupfilesuffix), force=true)

    fileBackup(tableapiFile)
    fileBackup(sqlFile)

    try
        open(tableapiTmpFile, "w") do ttaf
            open(tableapiFile, "r") do taf
                # keep=falseにして改行文字を取り除いておく。そしてprintln()する
                for ss in eachline(taf, keep=false)
                    if contains( ss, ':' )
                        p = split(ss, ":") # api_name:table,table,....
                        tmparr = split(p[2], ',')
                        if tablename ∈ tmparr
                            push!(targetapi, p[1]) # ["js1","ji2,.....]
                        else
                            # 対象外はファイルに残す
                            println(ttaf, ss)
                        end
                    end
                end
            end
        end
    catch err
        JetelinaLog.writetoLogfile("SQLSentenceManager.deleteFromlist() error: $err")
        return false
    end

    # targetapiに含まれないSQLだけ残す
    try
        open(sqlTmpFile, "w") do tf
            open(sqlFile, "r") do f
                for ss in eachline(f, keep=false)
                    p = split(ss, "\"") # js1,"select..."
                    if rstrip(p[1], ',') ∈ targetapi # これこれぇ＼(^o^)／
                    # 含まれるのでスキップ
                    else
                        #対象tableを含まないものだけ書き出す
                        println(tf, ss)
                    end
                end
            end
        end
    catch err
        JetelinaLog.writetoLogfile("SQLSentenceManager.deleteFromlist() error: $err")
        return false
    end

    # 全部終わったら scenarioTmpFile->scenarioFileとする
    mv(sqlTmpFile, sqlFile, force=true)
    mv(tableapiTmpFile, tableapiFile, force=true)

    # DataFrameを更新する
    JetelinaReadSqlList.readSqlList2DataFrame()

    return true
end

"""
    fileBackup()

        指定されたファイルのバックアップを行う。
        バックアップファイルはさふぃに"日付時間 yyyymmdd-HHMMSS"が付く。

        Args: file name (full path)
"""
function fileBackup(fname)
    backupfilesuffix = Dates.format(now(), "yyyymmdd-HHMMSS")
    cp(fname, string(fname, backupfilesuffix), force=true)
end

"""
    sqlDuplicationCheck

    引数に設定されたSQLがJetelinaSQLListfileに存在するかどうか確認する。
    比較対象はJetelinaSQLListfileファイルではなく、メモリ展開されているDataFrame形式の、
    Df_JetelinaSqlListとすることで高速化を図る。

    nsql: 引数のSQL句
    return: tabpleで返す 
            存在した場合   -> true と、該当する既存APIのNO ex. js100
            存在しない場合 -> false

"""
function sqlDuplicationCheck(nsql)
    # 一致するものはあるかなぁ？
    for i=1:size(Df_JetelinaSqlList)[1]
        strs = [nsql,Df_JetelinaSqlList[!,:sql][i]]
        process1 = split.(strs,r"\W",keepempty=false)
        process2 = map(x->lowercase.(x),process1)
        process3 = sort.(process2)
        process4 = countmap(process3)
        #===
            ここのprocess4の結果、strs[]の要素が
                一致していたら      -> length(process4)=1
                一致していなかったら-> length(process4)=2
            となる。
            これは、countmap()が同じmapデータをひとまとめにすることによる。                
        ===#
        if length(process4) == 1
            return true, Df_JetelinaSqlList[!,:no][i]
        end

    end

    # 結局、一致するものはなかった
    return false
end

end