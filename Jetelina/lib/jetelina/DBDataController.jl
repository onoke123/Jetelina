"""
    module: DBDataCOntroller

DB controller

contain functions
    init_Jetelina_table()
    dataInsertFromCSV()
    dropTable()
    getTableList(s)
    getSequenceNumber(t)
    doInsert()
    doSelect()
    doUpdate()
    doDelete()
    getUserAccount(s)
"""
module DBDataController

    using DataFrames, Genie, Genie.Renderer, Genie.Renderer.Json
    using JetelinaLog, JetelinaReadConfig
    using PgDBController

#    export Df_JetelinaTableManager

    function init_Jetelina_table()
        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            PgDBController.create_jetelina_table()
#            PgDBController.create_jetelina_id_sequence()
            PgDBController.readJetelinatable()
        elseif JetelinaDBtype == "mariadb"
        elseif JetelinaDBtype == "oracle"
        end

    end

    function dataInsertFromCSV( csvfname )
        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            PgDBController.dataInsertFromCSV( csvfname )
            tableName = splitext( splitdir( csvfname )[2] )[1]
             
            return PgDBController.getColumns( tableName)
        elseif JetelinaDBtype == "mariadb"
        elseif JetelinaDBtype == "oracle"
        end
    end

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

    function getSequenceNumber(t)
        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            PgDBController.getJetelinaSequenceNumber(t)
        elseif JetelinaDBtype == "mariadb"
        elseif JetelinaDBtype == "oracle"
        end
    end

    function dropTable( tableName )
        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            PgDBController.dropTable( tableName )
        elseif JetelinaDBtype == "mariadb"
        elseif JetelinaDBtype == "oracle"
        end
    end

    function getColumns( tableName )
        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            PgDBController.getColumns( tableName )
        elseif JetelinaDBtype == "mariadb"
        elseif JetelinaDBtype == "oracle"
        end
    end

    function doInsert()
        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            PgDBController.doInsert()
        elseif JetelinaDBtype == "mariadb"
        elseif JetelinaDBtype == "oracle"
        end
    end
    
    function doSelect()
        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            PgDBController.doSelect()
        elseif JetelinaDBtype == "mariadb"
        elseif JetelinaDBtype == "oracle"
        end
    end
    
    function doUpdate()
        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            PgDBController.doUpdate()
        elseif JetelinaDBtype == "mariadb"
        elseif JetelinaDBtype == "oracle"
        end
    end
    
    function doDelete()
        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            PgDBController.doDelete()
        elseif JetelinaDBtype == "mariadb"
        elseif JetelinaDBtype == "oracle"
        end
    end

    function getUserAccount( s )
        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            PgDBController.getUserAccount(s)
        elseif JetelinaDBtype == "mariadb"
        elseif JetelinaDBtype == "oracle"
        end
    end
end