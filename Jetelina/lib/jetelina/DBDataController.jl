"""
    module: DBDataController

    Author: Ono keiji
    Version: 1.0
    Description:
        General DB action controller

    functions
        __init__() Initial action. Execute init_Jetelina_table()
        init_Jetelina_table() Execute *.create_jetelina_table() depend on DB type.Execute *.readJetelinatable() depend on DB type.
        dataInsertFromCSV(csvfname::String) CSV data inserts into DB. It executes in *.dataInsertFromCSV depend on DB type.
        getTableList(s::String) Get the ordered table list by executing *.getTable() depend on DB type
        getSequenceNumber(t::Integer) Get seaquence number from jetelina_id table depend on DB type.
        dropTable(tableName::String) Drop the table and delete its related data from jetelina_table_manager table
        getColumns(tableName::String) Get columns of ordered table name depend on DB type.
        doSelect(sql::String,mode::String)
        executeApi(json_d) Execute SQL sentence order by json_d: json raw data.
        userRegist(username::String) register a new user
        chkUserExistence(s::String) pre login, check the ordered user in jetelina_user_table or not
        getUserInfoKeys(uid::Integer) get "user_info" column key data.
        refUserAttribute(uid::Integer,key::String,val) inquiring user_info data 
        updateUserInfo(uid::Integer,key::String,value) update user data (jetelina_user_table.user_info)
        updateUserData(uid::Integer,key::String,value) update user data, exept jsonb column
        updateUserLoginData(uid::Integer) update user login data if it succeeded to login
        deleteUserAccount(uid::Integer) user delete, but not physical deleting, set jetelina_delete_flg to 1. 
"""

module DBDataController

    using DataFrames, Genie, Genie.Renderer, Genie.Renderer.Json
    using JetelinaLog, JetelinaReadConfig, JetelinaFiles, JetelinaReadSqlList, PgDBController, PgSQLSentenceManager

    export init_Jetelina_table, dataInsertFromCSV, getTableList, getSequenceNumber, dropTable, getColumns, doSelect,
        executeApi, userRegist, chkUserExistence, getUserInfoKeys,refUserAttribute, updateUserInfo, updateUserData, deleteUserAccount

    """
    function __init__()
        Initial action. Execute init_Jetelina_table()
    """
    function __init__()
        init_Jetelina_table()
    end
    """
    function init_Jetelina_table()
        Execute *.create_jetelina_table() depend on DB type.
        Execute *.readJetelinatable() depend on DB type.
    """
    function init_Jetelina_table()
        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            PgDBController.create_jetelina_id_sequence()
            PgDBController.create_jetelina_table()
            PgDBController.readJetelinatable()
        elseif JetelinaDBtype == "mariadb"
        elseif JetelinaDBtype == "oracle"
        end

    end
    """
    function dataInsertFromCSV(csvfname::String)

        CSV data inserts into DB. It executes in *.dataInsertFromCSV depend on DB type.

    # Arguments
    - `csvfname: String`: csv file name. Expect string data of JetelinaFileUploadPath + <csv file name>.
    """
    function dataInsertFromCSV(csvfname::String)
        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            PgDBController.dataInsertFromCSV(csvfname)
        elseif JetelinaDBtype == "mariadb"
        elseif JetelinaDBtype == "oracle"
        end
    end
    """
    function getTableList(s::String)

        Get the ordered table list by executing *.getTable() depend on DB type

    # Arguments
    - `s::String`:  return data type. Typically 'json'.
    """
    function getTableList(s::String)
        if isnothing(s)
            s = "json"
        end

        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            PgDBController.getTableList(s)
        elseif JetelinaDBtype == "mariadb"
        elseif JetelinaDBtype == "oracle"
        end
    end
    """
    function getSequenceNumber(t::Integer)

        Get seaquence number from jetelina_id table depend on DB type.

    # Arguments
    - `t: Integer`  : type order  0-> jetelina_id, 1-> jetelian_sql_sequence        
    """
    function getSequenceNumber(t::Integer)
        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            PgDBController.getJetelinaSequenceNumber(t)
        elseif JetelinaDBtype == "mariadb"
        elseif JetelinaDBtype == "oracle"
        end
    end
    """
    function dropTable(tableName::String)
            
        Drop the table and delete its related data from jetelina_table_manager table

    # Arguments
    - `tableName: String`: name of the table
    """
    function dropTable(tableName::String)
        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            PgDBController.dropTable(tableName)
        elseif JetelinaDBtype == "mariadb"
        elseif JetelinaDBtype == "oracle"
        end
    end
    """
    function getColumns(tableName::String)

        Get columns of ordered table name depend on DB type.

    # Arguments
    - `tableName: String`: DB table name
    """
    function getColumns(tableName::String)
        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            PgDBController.getColumns(tableName)
        elseif JetelinaDBtype == "mariadb"
        elseif JetelinaDBtype == "oracle"
        end
    end
    """
    function doSelect(sql::String,mode::String)

        execute select sentence depend on DB type.

    # Arguments
    - `sql: String`: execute sql sentense
    - `mode: String`: "run"->running mode  "measure"->measure speed. only called by measureSqlPerformance()        
    """
    function doSelect(sql::String, mode::String)
        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            PgDBController.doSelect(sql.mode)
        elseif JetelinaDBtype == "mariadb"
        elseif JetelinaDBtype == "oracle"
        end
    end
    """
    function executeApi(json_d)

        Execute SQL sentence order by d: json raw data.
        
    # Arguments
    - `json_d`:  json raw data, uncertain data type        
    """
    function executeApi(json_d::Dict)
        ret = ""
        sql_str = ""
        #===
            Tips:
                Steps
                    1.search sql in Df_JetelinaSqlList with d["apino"]
                    ex. ji1 -> update <table> set name='{name}', age={age} where jt_id={jt_id}
                    2.json data bind to the sql sentence
                    3.execute the binded sql sentence
        ===#
        # Step1
        #===
            Tips:
                use subset() here, because Df_JetelinaSqlList may have missing data.
                subset() supports 'skipmissing', but filter() does not.
        ===#
        target_api = subset(Df_JetelinaSqlList, :apino => ByRow(==(json_d["apino"])), skipmissing=true)
        if 0 < nrow(target_api)
            # Step2:
            if JetelinaDBtype == "postgresql"
                # Case in PostgreSQL
                sql_str = PgSQLSentenceManager.createExecutionSqlSentence(json_d, target_api)
                if 0 < length(sql_str)
                    # Step3:
                    ret = PgDBController.executeApi(json_d["apino"], sql_str)
                end
            end
        elseif JetelinaDBtype == "mariadb"
        elseif JetelinaDBtype == "oracle"
        end

        # write execution sql to log file
        JetelinaLog.writetoSQLLogfile(json_d["apino"], sql_str)

        return ret
    end
    """
    function userRegist()

        register a new user

    # Arguments
    - `username::String`:  user name. this data sets in as 'login','firstname' and 'lastname' at once.
    - return::boolean: success->true  fail->false
    """
    function userRegist(username::String)
        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            PgDBController.userRegist(s)
        elseif JetelinaDBtype == "mariadb"
        elseif JetelinaDBtype == "oracle"
        end
    end
    """
    function chkUserExistence(s::String)

        pre login, check the ordered user in jetelina_user_table or not
        search only alive user (jetelina_delete_flg=0)
        resume to refUserAttribute() if existed
        
    # Arguments
    - `s::String`:  user information. login account or first name or last name.
    - return: success -> user data in json, fail -> ""
    """
    function chkUserExistence(s::String)
        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            PgDBController.chkUserExistence(s)
        elseif JetelinaDBtype == "mariadb"
        elseif JetelinaDBtype == "oracle"
        end
    end
    """
    function getUserInfoKeys(uid::Integer)

        get "user_info" column key data.

    # Arguments
    - `uid::Integer`: expect user_id
    - return: success -> user data in json or DataFrame, fail -> ""
    """
    function getUserInfoKeys(uid::Integer)
        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            PgDBController.getUserInfoKeys(uid)
        elseif JetelinaDBtype == "mariadb"
        elseif JetelinaDBtype == "oracle"
        end
    end
    """
    function refUserAttribute(uid::Integer,key::String,val)

        inquiring user_info data 
        
    # Arguments
    - `uid::Integer`: expect user_id
    - `key::String`: key name in user_info json data
    - `val`:  user input data. not sure the data type. String or Integer or something else
    - return: success -> user data in json or DataFrame, fail -> ""
    """
    function refUserAttribute(uid::Integer,key::String,val)
        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            rettype::Integer = 0 # because wanna the return as json type
            PgDBController.refUserAttribute(uid,key,val,rettype)
        elseif JetelinaDBtype == "mariadb"
        elseif JetelinaDBtype == "oracle"
        end
    end
    """
    function updateUserInfo(uid::Integer,key::String,value)

        update user data (jetelina_user_table.user_info)

    # Arguments
    - `uid::Integer`: expect user_id
    - `key::String`: key name in user_info json data
    - `val`:  user input data. not sure the data type. String or Integer or something else
    - return: success -> true, fail -> error message
    """
    function updateUserInfo(uid::Integer,key::String,value)
        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            PgDBController.updateUserInfo(uid,key,val)
        elseif JetelinaDBtype == "mariadb"
        elseif JetelinaDBtype == "oracle"
        end
    end
    """
    function updateUserData(uid::Integer,key::String,value)

        update user data, exept jsonb column
        this function can use for simple columns.

    # Arguments
    - `uid::Integer`: expect user_id
    - `key::String`: name of countable columns. ex. logincount,user_level...
    - `val::Integer`: data to set the ordered column  
    - return: success -> true, fail -> error message
    """
    function updateUserData(uid::Integer,key::String,value)
        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            PgDBController.updateUserData(uid,key,val)
        elseif JetelinaDBtype == "mariadb"
        elseif JetelinaDBtype == "oracle"
        end
    end
    """
    function updateUserLoginData(uid::Integer)

        update user login data if it succeeded to login

    # Arguments
    - `uid::Integer`: expect user_id
    - return: success -> true, fail -> error message
    """
    function updateUserLoginData(uid::Integer)
        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            PgDBController.updateUserLoginData(uid)
        elseif JetelinaDBtype == "mariadb"
        elseif JetelinaDBtype == "oracle"
        end
    end
    """
    function deleteUserAccount(uid::Integer)

        user delete, but not physical deleting, set jetelina_delete_flg to 1. 

    # Arguments
    - `uid::Integer`: expect user_id
    - return: success -> true, fail -> error message
    """
    function deleteUserAccount(uid::Integer)
        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            PgDBController.deleteUserAccount(uid)
        elseif JetelinaDBtype == "mariadb"
        elseif JetelinaDBtype == "oracle"
        end
    end
end