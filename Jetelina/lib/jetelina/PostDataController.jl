"""
module: PostDataController

Author: Ono keiji
Version: 1.0
Description:
    all controll for poting data from clients

functions
    createSelectSentence()  create select sentence of SQL from posting data,then append it to JetelinaTableApifile.
    getColumns()  get ordered tables's columns with json style.ordered table name is posted as the name 'tablename' in jsonpayload().
    getApiList()  get registering api list in json style.api list is refered in Df_JetelinaSqlList.
    deleteTable()  delete table by ordering. this function calls DBDataController.dropTable(tableName), so 'delete' meaning is really 'drop'.ordered table name is posted as the name 'tablename' in jsonpayload().
    login()  login procedure.user's login account is posted as the name 'username' in jsonpayload().
    deleteApi()  delete api by ordering from JetelinaSQLListfile file, then refresh the DataFrame.
"""
module PostDataController

    using Genie, Genie.Requests, Genie.Renderer.Json
    using DBDataController
    using JetelinaReadConfig, JetelinaLog, JetelinaReadSqlList
    using PgSQLSentenceManager,JetelinaFiles

    export createSelectSentence,getColumns,getApiList,deleteTable,login,deleteApi
    
    """
    for test
    """
    function handlepostdata()
        d = rawpayload()
        @info "post data all: " d
    end

    """
    function createSelectSentence()

        create select sentence of SQL from posting data,then append it to JetelinaTableApifile.

    # Arguments
    - return: this sql is already existing -> json {"resembled":true}
              new sql then success to append it to  -> json {"apino":"<something no>"}
                           fail to append it to     -> false
    """
    function createSelectSentence()
        #==
            Tips:
                column post data from dashboard.html is expected below json style
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
        item_d = jsonpayload("item")
        subq_d = jsonpayload("subquery")
        
        if(subq_d != "")
            subq_d = PgSQLSentenceManager.checkSubQuery(subq_d)
        end

        if debugflg
            @info "PostDataController.createSelectSentence() post data: " item_d, length(item_d), subq_d, length(subq_d)
        end

        selectSql::String = ""
        tableName::String = ""
        tablename_arr::Vector{String} = [] # Tips: put into array for writing it to JetelinaTableApifile. This is used in PgSQLSentenceManager.writeTolist().
        subquerysentence::String = ""
        
        for i = 1:length(item_d)
            t = split(item_d[i], ".")
            t1 = strip(t[1])
            t2 = strip(t[2])
            if 0 < length(selectSql)
                # Tips: should be justfified this columns line for analyzing in SQLAnalyzer。 ex. select ftest.id,ftest.name from.....
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

        if !isnothing(subq_d) && 0<length(subq_d) && subq_d != "ignore"
            subquerysentence = """jetelina_subquery={$subq_d}"""
        end

        selectSql = """select $selectSql from $tableName $subquerysentence"""

        ck = PgSQLSentenceManager.sqlDuplicationCheck(selectSql)

        if ck[1] 
            # already exist it. return it and do nothing.
            return json(Dict("resembled" => ck[2]))
        else
            # yes this is the new
            ret = PgSQLSentenceManager.writeTolist(selectSql, tablename_arr)
            #===
                Tips:
                    PgSQLSente..() returns tuple({true/false,apino/null}).
                    return apino in json style if the first in tuple were true.
            ===#
            if ret[1] 
                return json(Dict("apino" => ret[2]))
            else
                return ret[1]
            end
        end

    end
    """
    function getColumns()

        get ordered tables's columns with json style.
        ordered table name is posted as the name 'tablename' in jsonpayload().
    """
    function getColumns()
        tableName = jsonpayload("tablename")
        if debugflg
            @info "PostDataController.getColumns(): " tableName
        end

        DBDataController.getColumns(tableName)
    end

    #==
        This comment out is for future requests.

        tableを指定してそれに関連するapiを返す関数。
        なにかに使いそうなのでコメントアウトして残しておく。
        function getApiList()
            tableName = jsonpayload( "tablename" )
            @info "getApiList: " tableName
            target = contains( tableName )
            #===
            DataFrame Df_JetelinaSqlListから、指定したtableNameが含まれる"sql"カラムを
            filter()で絞り込んでいる。
            次は絞り込みをVectorにしてJson化したい。
            Caution: filter!()は使わない。なぜならDf_Jete...はそのままにしておくから。
            ===#
            sql_list = filter( :sql => target, Df_JetelinaSqlList )
            @info "sql_list: " sql_list
            ret = json( Dict( "Jetelina" => copy.( eachrow( sql_list ))))
            @info "sql list ret: " ret
            return ret
        end
    ==#
    """
    function getApiList()

        get registering api list in json style.
        api list is refered in Df_JetelinaSqlList.
    """
    function getApiList()
        return json(Dict("Jetelina" => copy.(eachrow(Df_JetelinaSqlList))))
    end
    """
    function deleteTable()

        delete table by ordering. this function calls DBDataController.dropTable(tableName), so 'delete' meaning is really 'drop'.
        ordered table name is posted as the name 'tablename' in jsonpayload().
    """
    function deleteTable()
        tableName = jsonpayload("tablename")
        if debugflg
            @info "PostDataController.deleteTable() dropTable: " tableName
        end

        DBDataController.dropTable(tableName)
    end
    """
    function login()

        login procedure.
        user's login account is posted as the name 'username' in jsonpayload().
    """
    function login()
        userName = jsonpayload("username")
        if debugflg
            @info "PostDataController.login(): " userName
        end

        DBDataController.getUserAccount(userName)
    end
    """
    function _addJetelinaWords()

        expected keeping a private func.
        this should not open to all users.
    """
    function _addJetelinaWords()
        newwords = jsonpayload("sayjetelina")
        arr = jsonpayload("arr")

        # adding scenario
        #        scenarioFile = string( joinpath( "..","..","public","jetelina","js","scenario.js" ))
        scenarioFile = getJsFileNameFromPublicPath("scenario.js")
        scenarioTmpFile = getJsFileNameFromPublicPath("scenario.tmp")
        if debugflg
            @info "PostDataController._addJetelinaWords(): " newwords, arr
            @info "scenario path: " scenarioFile
        end

        target_scenario = "scenario['$arr']"
        rewritestring = ""

        open(scenarioTmpFile, "w") do tf
            open(scenarioFile, "r") do f
                # keep=falseにして改行文字を取り除いておく。そしてprintln()する
                for ss in eachline(f, keep=false)
                    if startswith(ss, target_scenario)
                        #ここで入れ替える
                        ss = ss[1:length(ss)-2] * ",'$newwords'];"                    
                    end

                    println(tf, ss)
                end
            end
        end

        #全部終わったら scenarioTmpFile->scenarioFileとする
        mv( scenarioTmpFile,scenarioFile,force=true)
    end
    """
    function deleteApi()

        delete api by ordering from JetelinaSQLListfile file, then refresh the DataFrame.
    """
    function deleteApi()
        targetapi = jsonpayload("apino")

        if debugflg
            @info "PostDataController.deleteApi() target api: " targetapi
        end
    
        apiFile = getFileNameFromConfigPath(JetelinaSQLListfile)
        apiFile_tmp = getFileNameFromConfigPath(string(JetelinaSQLListfile,".tmp"))

        try
            open(apiFile_tmp, "w") do tio
                # write header first
                println(tio,string("$JetelinaFileColumnApino,$JetelinaFileColumnSql"))
                open(apiFile, "r") do io
                    for ss in eachline(io,keep=false)
                        if contains( ss, '\"' )
                            p = split(ss, "\"")
                            if !contains(p[1],targetapi)
                                # remain others in the file
                                println(tio, ss)
                            end
                        end
                    end
                end
            end
        catch err
            JetelinaLog.writetoLogfile("PgSQLSentenceManager.deleteApi() error: $err")
            return false
        end

        # change the file name.
        mv(apiFile_tmp, apiFile, force=true)

        # update DataFrame
        JetelinaReadSqlList.readSqlList2DataFrame()

        return true
    end  
end