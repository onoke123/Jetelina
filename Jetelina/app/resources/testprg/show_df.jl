# 指定されたDataFrameを表示する
# いろいろやれるハズだけど、今はまだ「表示する」だけ

using DataFrames

function show_df( df )
    println( df )

    #==
    println( df[!,2], typeof(df[!,2]) )
    println( df[!,3], propertynames(df) )
    println( df[1,2] )
    println( df[2,4] )

    last = ncol(df)

    for i = 1:last
        println( typeof(df[!,i]) )
        
        if isvalid( String, df[!,i] )
            println( "String" )
        elseif isvalid( Int,df[!,i] )
            println( "Integer")
        else 
            println( "unknown")
        end
    end
    ===#

end
