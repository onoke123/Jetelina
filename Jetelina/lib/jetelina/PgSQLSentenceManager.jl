"""
module: PgSQLSentenceManager

Author: Ono keiji
Version: 1.0
Description:
    General DB action controller

functions
    writeTolist(sql::String, subquery::String, tablename_arr::Vector{String})  create api no and write it to JetelinaSQLListfile order by SQL sentence.
    updateSqlList(dic::Dict)  update JetelinaSQLListfile file
    deleteFromlist(tablename::String)  delete table name from JetelinaSQLListfile synchronized with dropping table.
    fileBackup(fname::String)  back up the ordered file with date suffix. ex. <file>.txt -> <file>.txt.yyyymmdd-HHMMSS
    sqlDuplicationCheck(nsql::String, subq::String)  confirm duplication, if 'nsql' exists in JetelinaSQLListfile.but checking is in Df_JetelinaSqlList, not the real file, because of execution speed. 
    checkSubQuery(subquery::String) check posted subquery strings wheather exists any illegal strings in it.
    createInsertSentence(tn::String,cs::String,ds::String) create sql input sentence by queries.
    createUpdateSentence(tn::String,us::String) create sql update sentence by queries.
    createDeleteSentence(tn::String) create sql delete sentence by query.
"""
module PgSQLSentenceManager

    using Dates, StatsBase, CSV, DataFrames
    using DBDataController, JetelinaReadConfig, JetelinaLog, JetelinaReadSqlList, JetelinaFiles

    export writeTolist,updateSqlList,deleteFromlist,fileBackup,sqlDuplicationCheck
    
    # sqli list file
    sqlFile = getFileNameFromConfigPath(JetelinaSQLListfile)
    tableapiFile = getFileNameFromConfigPath(JetelinaTableApifile)

    """
    function writeTolist(sql::String, tablename_arr::Vector{String})

        create api no and write it to JetelinaSQLListfile order by SQL sentence.
        
    # Arguments
    - `sql::String`: sql sentence
    - `subquery::String`: sub query sentence
    - `tablename_arr::Vector{String}`: table name list that are used in 'sql'
    """
    function writeTolist(sql::String, subquery::String, tablename_arr::Vector{String})
        # get the sequence name then create the sql sentence
        seq_no = DBDataController.getSequenceNumber(1)
        suffix = string()

        if startswith(sql, "insert")
            suffix = "ji"
        elseif startswith(sql,"update") && contains(sql,"jetelina_delete_flg=1")
            suffix = "jd"
        elseif startswith(sql, "update")
            suffix = "ju"
        elseif startswith(sql, "select")
            suffix = "js"
#        elseif startswith(sql, "delete")
#            suffix = "jd"
        end

        sql = strip(sql)
        sqlsentence = """$suffix$seq_no,\"$sql\",\"$subquery\""""

        if debugflg
            @info "PgSQLSentenceManager.writeTolist() sql sentence: ", sqlsentence
        end

        # write the sql to the file
        thefirstflg = true
        if !isfile(sqlFile)
            thefirstflg = false
        end

        try
            open(sqlFile, "a") do f
                if !thefirstflg
                    println(f, string(JetelinaFileColumnApino,',',JetelinaFileColumnSql,',',JetelinaFileColumnSubQuery))
                end


                println(f, sqlsentence)
            end
        catch err
            JetelinaLog.writetoLogfile("PgSQLSentenceManager.writeTolist() error: $err")
            return false, nothing
        end

        # write the relation between tables and api to the file
        try
            open(tableapiFile, "a") do ff
                println(ff, string(suffix, seq_no, ":", join(tablename_arr, ",")))
            end
        catch err
            JetelinaLog.writetoLogfile("PgSQLSentenceManager.writeTolist() error: $err")
            return false, nothing
        end

        # update DataFrame
        JetelinaReadSqlList.readSqlList2DataFrame()

        return true, string(suffix, seq_no)
    end

    """
    function updateSqlList(dic::Dict)

        update JetelinaSQLListfile file

    # Arguments
    - `dic::Dict`: target sql for updating. ex.  js100=>select ....
    - return: false -> if got something error.
    """
    function updateSqlList(dic::Dict)
        #===
            Tips:
                SQL list is in Df_JetelinaSqlList as DataFrame type.
                Both are OK as it transfers to Dict type and read original JetelinaSQLListfile with CSV.read() to transfer to Dict type.
                This time hires reading original file.
        ===#
        orglist = CSV.File(sqlFile) |> Dict
        newlist = merge!(orglist,dic)

        experimentFile = getFileNameFromConfigPath(JetelinaExperimentSqlList)
        # delete this file if it exists, becaus this file is always fresh.
        rm(experimentFile, force=true)
        #===
            Tips:
                ready for writing to files.
                this writing file is to be for test list because of mesuring the execution speed.
                use 'header' in CSV.write() because 'first','secound'... headers are put automatically without this parameter.
                'header' is for customizing the file headers.
        ===#
        try
            CSV.write( experimentFile, newlist, header=[JetelinaFileColumnApino,JetelinaFileColumnSql,JetelinaFileColumnSubQuery] )
        catch err
            println(err)
            JetelinaLog.writetoLogfile("PgSQLSentenceManager.updateSqlList() error: $err")
            return false
        end
        
    end
    """
    function deleteFromlist(tablename::String)

        delete table name from JetelinaSQLListfile synchronized with dropping table.

    # Arguments
    - `tablename::String`: target table name
    - return: boolean: true -> all done ,  false -> something failed
    """
    function deleteFromlist(tablename::String)
        sqlTmpFile = getFileNameFromConfigPath("$JetelinaSQLListfile.tmp")
        tableapiTmpFile = getFileNameFromConfigPath("JetelinaTableApi.tmp")

        targetapi = []
        # take the backup file
        fileBackup(tableapiFile)
        fileBackup(sqlFile)

        try
            open(tableapiTmpFile, "w") do ttaf
                open(tableapiFile, "r") do taf
                    # Tips: delete line feed by 'keep=false', then do println()
                    for ss in eachline(taf, keep=false)
                        if contains( ss, ':' )
                            p = split(ss, ":") # api_name:table,table,....
                            tmparr = split(p[2], ',')
                            if tablename ∈ tmparr
                                push!(targetapi, p[1]) # ["js1","ji2,.....]
                            else
                                # remain others in the file
                                println(ttaf, ss)
                            end
                        end
                    end
                end
            end
        catch err
            JetelinaLog.writetoLogfile("PgSQLSentenceManager.deleteFromlist() error: $err")
            return false
        end

        # remain SQL sentence not include in the target api
        try
            open(sqlTmpFile, "w") do tf
                open(sqlFile, "r") do f
                    for ss in eachline(f, keep=false)
                        p = split(ss, "\"") # js1,"select..."
                        if rstrip(p[1], ',') ∈ targetapi # yes, this is＼(^o^)／
                        # skip it because of including in it
                        else
                            # write out sql that does not contain the target table
                            println(tf, ss)
                        end
                    end
                end
            end
        catch err
            JetelinaLog.writetoLogfile("PgSQLSentenceManager.deleteFromlist() error: $err")
            return false
        end

        # change the file name
        mv(sqlTmpFile, sqlFile, force=true)
        mv(tableapiTmpFile, tableapiFile, force=true)

        # update DataFrame
        JetelinaReadSqlList.readSqlList2DataFrame()

        return true
    end

    """
    function fileBackup(fname::String)

        back up the ordered file with date suffix. ex. <file>.txt -> <file>.txt.yyyymmdd-HHMMSS

    # Arguments
    - `fname::String`: target file name
    """
    function fileBackup(fname::String)
        backupfilesuffix = Dates.format(now(), "yyyymmdd-HHMMSS")
        cp(fname, string(fname, backupfilesuffix), force=true)
    end

    """
    function sqlDuplicationCheck(nsql::String, subq::String)

        confirm duplication, if 'nsql' exists in JetelinaSQLListfile.
        but checking is in Df_JetelinaSqlList, not the real file, because of execution speed. 

    # Arguments
    - `nsql::String`: sql sentence
    - `subq::String`: sub query string for 'nsql'
    - return:  tuple style
               exist     -> ture, api no(ex.js100)
               not exist -> false
    """
    function sqlDuplicationCheck(nsql::String, subq::String)
        # already exist?
        for i=1:nrow(Df_JetelinaSqlList)
            #===
                Tips:
                    the result in process4 will be
                        exist -> length(process4)=1
                        not exist -> length(process4)=2
                    because coutmap() do group together.
            ===#
            # duplication check for SQL
            strs = [nsql,Df_JetelinaSqlList[!,:sql][i]]
            @info "strs" strs
            process1 = split.(strs,r"\W",keepempty=false)
            process2 = map(x->lowercase.(x),process1)
            process3 = sort.(process2)
            process4 = countmap(process3)
            # duplication check for Sub query
            sq = Df_JetelinaSqlList[!,:subquery][i]
            if !ismissing(sq)
                s_strs = [subq,sq]
                @info "s_strs" s_strs
                s_process1 = split.(s_strs,r"\W",keepempty=false)
                s_process2 = map(y->lowercase.(y),s_process1)
                s_process3 = sort.(s_process2)
                s_process4 = countmap(s_process3)
            else
                # in the case of all were 'missing',be length(s_prrocess4)=1, anyhow :p
                s_process4 = ["dummy"];
            end

            if length(process4) == 1 && length(s_process4) == 1
                return true, Df_JetelinaSqlList[!,:apino][i]
            end

        end

        # consequently, not exist.
        return false
    end
    """
    function checkSubQuery(subquery::String)

        check posted subquery strings wheather exists any illegal strings in it.
        because subquery is free format posting data by user. 

    # Arguments
    - `subquery::String`: posted subquery
    - return:  subquery string after processing
    """
    function checkSubQuery(subquery::String)
        return replace(subquery,";"=>"")
    end
    """
    function createInsertSentence(tn::String,cs::String,ds::String)

        create sql input sentence by queries.
        this function executs when csv file uploaded.

    # Arguments
    - `tn::String`: table name
    - `cs::String`: column name strings
    - `ds::String`: data strings
    - return: String: sql insert sentence
    """
    function createInsertSentence(tn::String,cs::String,ds::String)
        return """insert into $tn ($cs) values($ds)"""
    end
    """
    function createUpdateSentence(tn::String,us::String)

        create sql update sentence by queries.
        this function executs when csv file uploaded.

    # Arguments
    - `tn::String`: table name
    - `us::String`: update strings
    - return: Tuple: (sql update sentence, sub query sentence)
    """
    function createUpdateSentence(tn::String,us::String)
        return """update $tn set $us""", """where jt_id={jt_id}"""
    end
    """
    function createDeleteSentence(tn::String)

        create sql delete sentence by query.
        this function executs when csv file uploaded.

    # Arguments
    - `tn::String`: table name
    - return: Tuple: (sql delete sentence, sub query sentence)
    """
    function createDeleteSentence(tn::String)
        return  """update $tn set jetelina_delete_flg=1""", """where jt_id={jt_id}"""
    end

end