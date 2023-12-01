"""
module: PgSQLSentenceManager

Author: Ono keiji
Version: 1.0
Description:
    General DB action controller

functions
    writeTolist(sql::String, subquery::String, tablename_arr::Vector{String})  create api no and write it to JetelinaSQLListfile order by SQL sentence.
    deleteFromlist(tablename::String)  delete table name from JetelinaSQLListfile synchronized with dropping table.
    fileBackup(fname::String)  back up the ordered file with date suffix. ex. <file>.txt -> <file>.txt.yyyymmdd-HHMMSS
    sqlDuplicationCheck(nsql::String, subq::String)  confirm duplication, if 'nsql' exists in JetelinaSQLListfile.but checking is in Df_JetelinaSqlList, not the real file, because of execution speed. 
    checkSubQuery(subquery::String) check posted subquery strings wheather exists any illegal strings in it.
    createApiInsertSentence(tn::String,cs::String,ds::String) create sql input sentence by queries.
    createApiUpdateSentence(tn::String,us::Any) create sql update sentence by queries.
    createApiDeleteSentence(tn::String) create sql delete sentence by query.
    createApiSelectSentence(json_d::Dict) create select sentence of SQL from posting data,
    createExecutionSqlSentence(json_dict::Dict, df::DataFrame) create real execution SQL sentence.
"""
module PgSQLSentenceManager

    using Dates, StatsBase, CSV, DataFrames
    using Genie, Genie.Requests, Genie.Renderer.Json
    using DBDataController, JetelinaReadConfig, JetelinaLog, JetelinaReadSqlList, JetelinaFiles

    export writeTolist,deleteFromlist,fileBackup,sqlDuplicationCheck,checkSubQuery,createApiInsertSentence,createApiUpdateSentence,createApiDeleteSentence,createApiSelectSentence,createExecutionSqlSentence
    
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
    function createApiInsertSentence(tn::String,cs::String,ds::String)

        create sql input sentence by queries.
        this function executs when csv file uploaded.

    # Arguments
    - `tn::String`: table name
    - `cs::String`: column name strings
    - `ds::String`: data strings
    - return: String: sql insert sentence
    """
    function createApiInsertSentence(tn::String,cs::String,ds::String)
        return """insert into $tn ($cs) values($ds)"""
    end
    """
    function createApiUpdateSentence(tn::String,us::Any)

        create sql update sentence by queries.
        this function executs when csv file uploaded.

    # Arguments
    - `tn::String`: table name
    - `us::Any`: update strings
    - return: Tuple: (sql update sentence, sub query sentence)
    """
    function createApiUpdateSentence(tn::String,us::Any)
        return """update $tn set $us""", """where jt_id={jt_id}"""
    end
    """
    function createApiDeleteSentence(tn::String)

        create sql delete sentence by query.
        this function executs when csv file uploaded.

    # Arguments
    - `tn::String`: table name
    - return: Tuple: (sql delete sentence, sub query sentence)
    """
    function createApiDeleteSentence(tn::String)
        return  """update $tn set jetelina_delete_flg=1""", """where jt_id={jt_id}"""
    end
    """
    function createApiSelectSentence(json_d::Dict)

        create API and SQL select sentence from posting data,then append it to JetelinaTableApifile.

    # Arguments
    - `json_d::Dict`: json data
    - return: this sql is already existing -> json {"resembled":true}
              new sql then success to append it to  -> json {"apino":"<something no>"}
                           fail to append it to     -> false
    """
    function createApiSelectSentence(json_d)
        @info "creatApi... type: " typeof(json_d)
        item_d = json_d["item"]
        subq_d = json_d["subquery"]

        #==
            Tips:
                item_d:column post data from dashboard.html is expected below json style
                    { 'item'.'["<table name>.<column name>","<table name>.<column name>",...]' }
                then parcing it by jsonpayload("item") 
                    item_d -> ["<table name>.<column name1>","<table name>.<column name2>",...]
 
                then handle it as an array data
                    [1] -> <table name>.<column name1>
                furthermore deviding it to <table name> and <column name> by '.' 
                    table name  -> <table name>
                    column name -> <column name1>
        
                use these to create sql sentence.
        ==#
        if(subq_d != "")
            subq_d = checkSubQuery(subq_d)
        end

        selectSql::String = ""
        tableName::String = ""
        #===
            Tips: 
                put into array to write it to JetelinaTableApifile. 
                This is used in writeTolist().
        ===#
        tablename_arr::Vector{String} = []
        
        for i = 1:length(item_d)
            t = split(item_d[i], ".")
            t1 = strip(t[1])
            t2 = strip(t[2])
            if 0 < length(selectSql)
                #===
                    Tips: 
                        should be justfified this columns line for analyzing in SQLAnalyzer.
                            ex. select ftest.id,ftest.name from.....
                ===#
                selectSql = """$selectSql,$t1.$t2"""
            else
                selectSql = """$t1.$t2"""
            end

            if (0 < length(tableName))
                if (!contains(tableName, t1))
                    tableName = """$tableName,$t1 as $t1"""
                    push!(tablename_arr,t1)
                end
            else
                tableName = """$t1 as $t1"""
                push!(tablename_arr,t1)
            end
        end

        selectSql = """select $selectSql from $tableName"""
        ck = sqlDuplicationCheck(selectSql, subq_d)
        if ck[1] 
            # already exist it. return it and do nothing.
            return json(Dict("result"=>false,"resembled" => ck[2]))
        else
            # yes this is the new
            ret = writeTolist(selectSql, subq_d, tablename_arr)
            #===
                Tips:
                    writeTolist() returns tuple({true/false,apino/null}).
                    return apino in json style if the first in tuple were true.
            ===#
            if ret[1] 
                return json(Dict("result"=>true,"apino" => ret[2]))
            else
                return ret[1]
            end
        end
    end
    """
    function createExecutionSqlSentence(json_dict::Dict, df::DataFrame)

        create real execution SQL sentence.
        using 'ignore' and 'subquery' as keywords to create SQL sentence. 
        These are the 'PROTOCOL' in using DataFrame of SQL list and posting data I/F.
        
        Attention: this select sentence searchs only 'jetelina_delete_flg=0" data.

    # Arguments
    - `item_arr::Vector{String}`: posted column data
    - `df::DataFrame`: dataframe of target api data. a part of Df_JetelinaSqlList 
    - return::String SQL sentence
    """
    function createExecutionSqlSentence(json_dict::Dict, df::DataFrame)
        keyword1::String = "ignore" # protocol
        keyword2::String = "subquery" # protocol
        j_del_flg::String = "jetelina_delete_flg=0" # absolute select condition
        subquery_str::String = "" # contain df.subquery[1]. see Tips
        ret::String = "" # return sql sentence
        json_subquery_dict = Dict()
        execution_sql::String = ""

        function __create_j_del_flg(sql::String)
            del_flg::String = "jetelina_delete_flg=0" # absolute select condition
            
            div_sql = split(sql,"from")
            if !isnothing(div_sql)
                if contains(div_sql[2],',')
                    tables = split(div_sql[2],',')
                    if !isnothing(tables)
                        multi_del_flg::String = ""
                        for i in eachindex(tables)
                            table = split(tables[i],"as")
                            if !isnothing(table)
                                if length(multi_del_flg) == 0
                                    multi_del_flg = string(strip(table[1]),".jetelina_delete_flg=0")
                                else
                                    multi_del_flg = string(multi_del_flg," and ",strip(table[1]),".jetelina_delete_flg=0")
                                end
                            end
                        end

                        del_flg = multi_del_flg
                    end
                end
            end

            return del_flg
        end

        if 0<length(json_dict)
            #===
                Tips:
                    case in 'insert' has a chance of 'missing' in df.subquery[1].
                    
                    Attention: 
                        using 'subquery_str' String type has a benefit rather than using df.subquery[1],
                        because df fiels length are fixed as DataFrame when it was created.
                        I mean using straight as df.* may happen over flow in the case of concate strings.
                            ex. df.subquery[1] -> fixed String(10) in DataFrame
                                     df.subquery[1] = string(df.subquery[1], "AAAAAAAA") -> maybe get over flow 
            ===#
            if !ismissing(df.subquery[1])
                subquery_str = df.subquery[1]
            end

            if contains(json_dict["apino"],"js")
                # select
                if !isnothing(subquery_str) && !contains(subquery_str,keyword1) && !ismissing(subquery_str)
                    #===
                        Tips:
                            set subquery data in json to df.subquery.
                            because it combines later with df.sql.
                            managing df.subquery is very advantageous process at here.
                    ===#
                    if haskey(json_dict,keyword2)
                        sp = split(json_dict[keyword2],",")
                        if !isnothing(sp)
                            for ii in eachindex(sp)
                                if ii == 1 || ii == length(sp)
                                    sp[ii] = replace(sp[ii],"["=>"","]"=>"","\""=>"","'"=>"")
                                end

                                ssp = split(sp[ii],":")
                                json_subquery_dict[ssp[1]] = ssp[2]
                            end
                        end

                        for (k,v) in json_subquery_dict
                            kk = string("{",k,"}")
                            subquery_str = replace(subquery_str,kk=>v)
                        end

                        j_del_flg = __create_j_del_flg(df.sql[1])
                        subquery_str = string(subquery_str," ","and ", j_del_flg)
                    end
                else
                    subquery_str =string("where ", j_del_flg)
                end
            elseif contains(json_dict["apino"],"ju") || contains(json_dict["apino"],"jd")
                # update/delete
                #   json_dict["subquery"] is always point to {jt_id}
                json_dict["jt_id"] = json_dict["subquery"]
            else
                # insert/update
                #   insert always needs to add 'jetelina_delete_flg' as 0.
                json_dict["jetelina_delete_flg"] = 0;
            end

            execution_sql = string(df.sql[1]," ",subquery_str)

            #==
                Tips:
                    json data bind to the sql sentence.
                    Dict() is used alike associative array.
            ===#
            for (k,v) in json_dict
                kk = string("{",k,"}")
                execution_sql = replace(execution_sql,kk=>v)
#                replace!(execution_sql,kk=>v)                 may need julia1.8 over :p
            end
            
            ret = execution_sql
        
        end
@info ret
        return ret
    end
end