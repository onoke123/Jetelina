"""
    module: DBDataCOntroller

DB controller

contain functions
    init_Jetelina_table()
    dataInsertFromCSV()
    getTableList()
    doInsert()
    doSelect()
    doUpdate()
    doDelete()
"""
module DBDataController

    using DataFrames, Genie, Genie.Renderer, Genie.Renderer.Json
    using JetelinaLog, JetelinaReadConfig
    using PgDBController

    function init_Jetelina_table()
        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            PgDBController.create_jetelina_table()
        elseif JetelinaDBtype == "mariadb"
        elseif JetelinaDBtype == "oracle"
        end
    end

    function dataInsertFromCSV( csvfname )
        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            PgDBController.dataInsertFromCSV( csvfname )
        elseif JetelinaDBtype == "mariadb"
        elseif JetelinaDBtype == "oracle"
        end
    end

    function getTableList()
        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            PgDBController.getTableList()
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
end