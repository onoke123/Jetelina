"""
    module: SQLAnalyzer

    read the log/sql.log file, then analyze the calling column status

    contain functions

"""
module SQLAnalyzer

    using CSV
    using DataFrames
    using Genie, Genie.Renderer, Genie.Renderer.Json
    using JetelinaReadConfig, JetelinaLog
    using ExeSql, DBDataController
    using DelimitedFiles

    """
        read sql.log file
            log/sql.log ex. select ftest2.id,ftest2.name from ftest2
    """
    sqllogfile = string( joinpath( @__DIR__, "log", JetelinaSQLLogfile ) )
    df = readdlm( sqllogfile, ' ', String, '\n')

    """
        get uniqeness
            ex. 
                select ftest2.id,ftest2.name from ftest2
                select ftest2.id,ftest2.name from ftest2
                select ftest.id,ftest.name from ftest
                
                -->
                select ftest2.id,ftest2.name from ftest2
                select ftest.id,ftest.name from ftest
    """
    u = unique( df[:,[:2]] )

    """
        1.make unique sql statements
        2.pick only the columns part
        3.count the access number in each sql
        4.put it into DataFrame alike
            ex. 
                column_name      access_number
            ftest3.id,ftest2.name    2
    """
    u_size = size( u )[1]
    df_size = size(df[:,[:2]])[1]

    # uにはユニークなSQL文が入っているので、sql.logの中のマッチングでアクセス数を取得する ex. u[i] === ....
    sql_df = DataFrame( column_name=String[], combination=[], access_number=Float64[] )

    """
        shape the data
            ex. 
                column    combination    access number
            ftest3.id     ftest3+ftest2      2
            ftest2.name   ftest3+ftest2      2
            ftest3.id     ftest4+ftest2      5
            ftest2.name   ftest2            10

            then 
            ftest3.idが一番呼ばれたのはftet4+ftest2なので、ftest3.idはこれを採用
            ftest2.name        〃      ftestなので、ftest2.nameはこれを採用→table変更は必要なさそう
    """

    for i = 1:u_size
        ac = 0
        # collect access number for each unique SQL. make "access_number"
        for ii = 1:df_size

            if u[i] == df[:,[:2]][ii]
                ac += 1
            end
        end

        table_arr = String[]
        c = split( u[i], "," )
        # make "column_name" and "combination" 
        for j = 1:size(c)[1]
            """
                cc[1]//table name
                cc[2]//column name 
            """
            cc = split( c[j], "." )
            # table_arrにcc[1]が入っているかどうか見ている。論理否定。これが書きたかったからJulia。
            if cc[1] ∉ table_arr
                push!( table_arr, cc[1] )
            end

            push!( sql_df,[c[j], table_arr, ac] )
        end
        
        @info sql_df
    end

    """
        analyze
            ex.
                各tableのRow No.でcombinationを置き換える
                     Row │ column_name  combination  access_number
            │           │ String       Array…       Float64
            │ ─────┼─────────────────────────────────────────
            │    1 │ ftest2.id          [4]            2
            │    2 │ ftest2.name        [4]            2
            │    3 │ ftest.id           [1]            1
            │    4 │ ftest3.id          [3, 4]         1
            └    5 │ ftest2.name        [3, 4]         2

                    ftest3.idはftest3にあるので→x座標:3(ftest3)
                    ftest3.idはftest4+ftest2が代表値なので → (3+4)/2(tableが2つだから)=3.5 ←y座標になる
                    よって、ftest3.idの座標は(3,3.5)

                    ”access number”はk-means法の"重み"として考えているけど、上記座標取得方法なら不要になる、が一応保持しておく、念のため。


                最終的に、カラム名とカラム座標値のMatrixをファイルに格納する(一旦ね)。

    """
    table_df = DBDataController.getTableList( "dataframe" )#この処理は上の処理に含めよう

    @info table_df

    # by Ph. Kaminski
    # table_df.tablenameがユニークだからできる技。
    d = Dict( table_df.tablename .=> axes( table_df, 1 ) )
    # d("ftest"=>1 "ftest2=>4...と入っている)　を参照してindexを取得し、それをcombinationに当てはめていく
    sql_df.combination = [getindex.(Ref(d),x) for x in sql_df.combination]
    @info sql_df
 #   @info sql_df.combination
    @info sql_df.access_number
    @info "max access no: " findmax(sql_df.access_number )[1]
    @info "max combination: " findmax(sql_df.combination)[1]
 #   @info "min combination: " findmin(sql_df.combination[1])

    sql_df.access_number .*= inv(findmax(sql_df.access_number)[1])
    sql_df.combination .*= inv(findmax(sql_df.combination)[1])

    @info sql_df


#    @info json( Dict( "Jetelina" => copy.( eachrow( sql_df ))))
    """
        json or csv形式にする前に、データのnormalizeを行いたい。
        combination:[x,y] -> x=当該table NO/全table数　y=y/max(y)
        access_number: c=c/max(c)
    """

    """
        Table Layout Change
            analyzeに基づいてTableレイアウト変更を仮実行する。
    """

    """
        Experimental SQL Run
            Table Layout Changeに対してSQLを発行して、処理速度を現状と比べる。
            結果をファイルに格納する。
    """

    """
        Suggestion
            Table Layout ChangeによるSQL実行がヨサゲなら
              1.analyze結果をグラフ化
              2.Experimental SQL Run結果をグラフ化
              3.count the access number in each sql
              4.shape the data

            するために、JSON形式にしてfunction panelに渡す。
            function panelのajaxはこの関数を呼び出すので、解析結果で変更が不要の時には
            1,2では”状態OK”を返し、3,4のみのデータを返す。
    """

end