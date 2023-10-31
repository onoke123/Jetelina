"""
    module: DBDataCOntroller

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
        doInsert()
        doSelect(sql::String,mode::String)
        doUpdate()
        doDelete()
        getUserAccount(s::String) Get user account for authentication.
        executeApi(d) Execute SQL sentence order by d: json raw data.
"""

module DBDataController

    using DataFrames, Genie, Genie.Renderer, Genie.Renderer.Json
    using JetelinaLog, JetelinaReadConfig
    using PgDBController, JetelinaFiles

    export init_Jetelina_table,dataInsertFromCSV,getTableList,getSequenceNumber,dropTable,getColumns,doInsert,doSelect,doUpdate,
    doDelete,getUserAccount,executeApi

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
            PgDBController.dataInsertFromCSV( csvfname )
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
            PgDBController.getTableList( s )
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
            PgDBController.dropTable( tableName )
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
    function getColumns( tableName::String )
        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            PgDBController.getColumns( tableName )
        elseif JetelinaDBtype == "mariadb"
        elseif JetelinaDBtype == "oracle"
        end
    end
    """
    function doInsert()

        insert json data into table depend on DB type, but not imprement yet.
    """
    function doInsert()
        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            PgDBController.doInsert()
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
    function doSelect(sql::String,mode::String)
        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            PgDBController.doSelect(sql.mode)
        elseif JetelinaDBtype == "mariadb"
        elseif JetelinaDBtype == "oracle"
        end
    end
    """
    function doUpdate()

        update ordered table by json data, but not imprement yet.
    """
    function doUpdate()
        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            PgDBController.doUpdate()
        elseif JetelinaDBtype == "mariadb"
        elseif JetelinaDBtype == "oracle"
        end
    end
    """
    function doDelete()

        delete data ordered table, but not imprement yet.
    """
    function doDelete()
        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            PgDBController.doDelete()
        elseif JetelinaDBtype == "mariadb"
        elseif JetelinaDBtype == "oracle"
        end
    end
    """
    function getUserAccount(s::String)

        Get user account for authentication.
        
    # Arguments
    - `s::String`:  user information. login account or first name or last name.        
    """
    function getUserAccount(s::String)
        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            PgDBController.getUserAccount(s)
        elseif JetelinaDBtype == "mariadb"
        elseif JetelinaDBtype == "oracle"
        end
    end

    """
    function executeApi(d)

        Execute SQL sentence order by d: json raw data.
        
    # Arguments
    - `d`:  json raw data, uncertain data type        
    """
    function executeApi(d)
        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            PgDBController.executeApi(d)
        elseif JetelinaDBtype == "mariadb"
        elseif JetelinaDBtype == "oracle"
        end
    end
end