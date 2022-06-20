# read the csv file in order to confirm the structure of containing data
using CSV
using DataFrames

#== テストデータがjetelina配下にある場合、@__DIR__でカレントディレクトリを示せる
　　　文字列接続はjoin()又は、string()でやる
==#
#fname = join([@__DIR__,"testdata/test.csv"],"/")
fname = string( @__DIR__,"/","testdata/test.csv")
df = CSV.read( fname, DataFrame )
#show_df( df )

function show_df( df )
    #==
    println( df )
    println( df[!,2], typeof(df[!,2]) )
    println( df[!,3], propertynames(df) )
    println( df[1,2] )
    println( df[2,4] )
    ==#
    last = ncol(df)

    for i = 1:last
        println( typeof(df[!,i]) )
    end

end
