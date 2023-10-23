"""
module: SQLSentenceManager

Author: Ono keiji
Version: 1.0
Description:
    General DB action controller

functions
    writeTolist(sql::String, tablename_arr::Vector{String})  create api no and write it to JetelinaSQLListfile order by SQL sentence.
    updateSqlList(dic::Dict)  update JetelinaSQLListfile file
    deleteFromlist(tablename::String)  delete table name from JetelinaSQLListfile synchronized with dropping table.
    fileBackup(fname::String)  back up the ordered file with date suffix. ex. <file>.txt -> <file>.txt.yyyymmdd-HHMMSS
    sqlDuplicationCheck(nsql::String)  confirm duplication, if 'nsql' exists in JetelinaSQLListfile.but checking is in Df_JetelinaSqlList, not the real file, because of execution speed. 
"""
module SQLSentenceManager

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
    - `tablename_arr::Vector{String}`: table name list that are used in 'sql'
    """
    function writeTolist(sql::String, tablename_arr::Vector{String})
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
            @info "SQLSentenceManager.writeTolist() sql sentence: ", sqlsentence
        end

        # write the sql to the file
        thefirstflg = true
        if !isfile(sqlFile)
            thefirstflg = false
        end

        try
            open(sqlFile, "a") do f
                if !thefirstflg
                    println(f, string(JetelinaFileColumnApino,',',JetelinaFileColumnSql))
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
            CSV.write( experimentFile, newlist, header=[JetelinaFileColumnApino,JetelinaFileColumnSql] )
        catch err
            println(err)
            JetelinaLog.writetoLogfile("SQLSentenceManager.updateSqlList() error: $err")
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
            JetelinaLog.writetoLogfile("SQLSentenceManager.deleteFromlist() error: $err")
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
            JetelinaLog.writetoLogfile("SQLSentenceManager.deleteFromlist() error: $err")
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
    function sqlDuplicationCheck(nsql::String)

        confirm duplication, if 'nsql' exists in JetelinaSQLListfile.
        but checking is in Df_JetelinaSqlList, not the real file, because of execution speed. 

    # Arguments
    - `nsql::String`: sql sentence
    - return:  tuple style
               exist     -> ture, api no(ex.js100)
               not exist -> false
    """
    function sqlDuplicationCheck(nsql::String)
        # exist?
        for i=1:nrow(Df_JetelinaSqlList)
            strs = [nsql,Df_JetelinaSqlList[!,:sql][i]]
            process1 = split.(strs,r"\W",keepempty=false)
            process2 = map(x->lowercase.(x),process1)
            process3 = sort.(process2)
            process4 = countmap(process3)
            #===
                Tips:
                    the result in process4 will be
                        exist -> length(process4)=1
                        not exist -> length(process4)=2
                    because coutmap() do group together.
            ===#
            if length(process4) == 1
                return true, Df_JetelinaSqlList[!,:apino][i]
            end

        end

        # consequently, not exist.
        return false
    end

end