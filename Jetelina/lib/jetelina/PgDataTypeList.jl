module PgDataTypeList

    function getDataType( c_type )
        c_type = string( c_type )
        if startswith( c_type, "Int" ) 
            "integer"
        elseif startswith( c_type, "Float" )
            "double precision"
        elseif startswith( c_type, "InlineStrings.String" )
            vc_n = SubString( c_type, length("InlineStrings.String")+1, length(c_type) )
            "varchar( $vc_n )"
        end
    end
end