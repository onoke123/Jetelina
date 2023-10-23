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
        if debugflg
            @info "PgDataTypeList.getDataType() c_type: ", c_type
        end
        
        c_type = string( c_type )
        if startswith( c_type, "Int" ) 
            "integer"
        elseif startswith( c_type, "Float" )
            "double precision"
        elseif startswith( c_type, "InlineStrings.String" )
            vc_n = SubString( c_type, length("InlineStrings.String")+1, length(c_type) )
            "varchar( $vc_n )"
        elseif startswith( c_type, "String" )
            "varchar"
        end
    end
    """
    function getDataTypeInDataFrame(c_type::String)

        determaine 'c_type' to DataFrame data. ex. c_type=='Int' -> 'Integer'.
        this function has been impremented after being defined getDataType(), because did not want to effect to it.
        c_type is expected Union{Missing,String} and so on, and it is not as same as a variable in getDataType().

    # Arguments
    - `c_type::String`:  data type string. ex 'Int'
    """
      function getDataTypeInDataFrame(c_type::String) 
        c_type = string( c_type )
        if contains( c_type, "Int" ) 
            "integer"
        elseif contains( c_type, "Float" )
            "double precision"
        elseif contains( c_type, "InlineStrings.String" )
            vc_n = SubString( c_type, length("InlineStrings.String")+1, length(c_type) )
            "varchar( $vc_n )"
        elseif contains( c_type, "String" )
            "varchar"
        end
    end

end