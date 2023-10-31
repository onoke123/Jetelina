"""
module: PostDataController

Author: Ono keiji
Version: 1.0
Description:
    all controll for poting data from clients

functions
    createApi()  create API and SQL select sentence from posting data.
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

    export createApi,getColumns,getApiList,deleteTable,login,deleteApi
    
    """
    for test
    """
    function handlepostdata()
        d = rawpayload()
        @info "post data all: " d
    end

    """
    function createApi()

        create API and SQL select sentence from posting data.

    # Arguments
    - return: this sql is already existing -> json {"resembled":true}
              new sql then success to append it to  -> json {"apino":"<something no>"}
                           fail to append it to     -> false
    """
    function createApi()
        item_d = jsonpayload("item")
        subq_d = jsonpayload("subquery")
        
        return PgSQLSentenceManager.createApiSelectSentence(item_d,subq_d)
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
                println(tio,string("$JetelinaFileColumnApino,$JetelinaFileColumnSql,$JetelinaFileColumnSubQuery"))
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