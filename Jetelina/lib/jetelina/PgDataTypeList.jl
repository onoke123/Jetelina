module PgDataTypeList

    using JetelinaReadConfig

    #===
        当初、csv->dbを想定してdata typeを設定したもの。
        getDataTypeInDataFrame()は後から追加したものだけど、ひょっとしたらそちらに
        統合できるのかなぁなんて思ったりもしている。
    ===#
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
            "varchar"
        end
    end

    #===
        DataFrameのdata typeを判別するためのもの。
        getDataType()の後、しばらく経ってから追加したもので、getDataType()に影響を及ぼしたくなかった
        ので追加しました。けど、ひょっとしたら統合できるのかなぁなんて思ってたりする。
        想定されるc_typeは Union{Missing,String}とかで、getDataType()のモノとは形が違うので、判別の
        startswithとcontainsの違いになっています。
    ===#
    function getDataTypeInDataFrame( c_type )        
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