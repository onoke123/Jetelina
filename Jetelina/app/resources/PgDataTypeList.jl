"""
module: PgDataTypeList

Author: Ono keiji
Version: 1.0
Description:
    determaine data type of PostgreSQL

functions
    getDataType(c_type::String)   determaine 'c_type' to PostgreSQL data. ex. c_type=='Int' -> 'Integer'
    getDataTypeInDataFrame(c_type::String)  determaine 'c_type' to DataFrame data. ex. c_type=='Int' -> 'Integer'
"""
module PgDataTypeList

    using JetelinaReadConfig

    export getDataType,getDataTypeInDataFrame

    """
    function getDataType(c_type::String)

        determaine 'c_type' to PostgreSQL data. ex. c_type=='Int' -> 'Integer'.
        It might be able to integrate with getDataTypeInDataFrame(), but should consider.

    # Arguments
    - `c_type::String`:  data type string. ex 'Int'
    """
    function getDataType(c_type::String)
        ret::String = ""

        if debugflg
            @info "PgDataTypeList.getDataType() c_type: ", c_type
        end
        
        c_type = string( c_type )
        if startswith( c_type, "Int" ) 
            ret = "integer"
        elseif startswith( c_type, "Float" )
            ret = "double precision"
        elseif startswith( c_type, "InlineStrings.String" )
#            vc_n = SubString( c_type, length("InlineStrings.String")+1, length(c_type) )
#            "varchar( $vc_n )"
            #==
                did not wanna limit a character number by the initial uploaded csv file 
            ==#
            ret = "varchar"
        elseif startswith( c_type, "String" )
            ret = "varchar"
        elseif startswith( c_type, "Dates" )
            ret = "Date"
        end

        return ret
    end
    """
    function getDataTypeInDataFrame(c_type::String)

        determaine 'c_type' to DataFrame data. ex. c_type=='Int' -> 'Integer'.
        this function has been impremented after being defined getDataType(), because did not want to effect to it.
        c_type is expected 'Union{Missing,String}' then return 'String' and so on.
        this function is used in SQLAnalyzer.jl so far, that mean using to copy table from the real db to the test db.
        
        Caution: This func is not as same as a variable in getDataType().

        2023/12/1 deprecated 

    # Arguments
    - `c_type::String`:  data type string. ex 'Int'
    """
    function getDataTypeInDataFrame(c_type::String) 
        ret::String = ""

        c_type = string( c_type )
        if contains( c_type, "Int" ) 
            ret = "integer"
        elseif contains( c_type, "Float" )
            ret = "double precision"
        elseif contains( c_type, "InlineStrings.String" )
#            vc_n = SubString( c_type, length("InlineStrings.String")+1, length(c_type) )
#            ret = "varchar( $vc_n )"
            #==
                did not wanna be same as the real table
            ==#
            ret = "varchar" 
        elseif contains( c_type, "String" )
            ret = "varchar"
        end

        return ret
    end

end