module PgDataTypeList

    using JetelinaReadConfig
    
    function getDataType( c_type )
        if debugflg
            @info "c_type: ", c_type
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
            # jetelina_idはDataFrameに後付なので"String"にされてしまう。なので、ここは決め打ち。
            "varchar( 256 )"
        end
    end
end