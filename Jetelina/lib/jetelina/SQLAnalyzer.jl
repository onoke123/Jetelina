"""
    module: SQLAnalyzer

    read the log/sql.log file, then analyze the calling column status

    contain functions

"""
module SQLAnalyzer

using CSV
using DataFrames
using Genie, Genie.Renderer, Genie.Renderer.Json
using JSON, LibPQ
using JetelinaReadConfig, JetelinaLog
using ExeSql, DBDataController,PgDBController
using DelimitedFiles
using JetelinaFiles
using TestDBController

const sqljsonfile = getFileNameFromLogPath(JetelinaSQLAnalyzedfile)

"""
    functions
        createAnalyzedJsonFile()
        getAnalyzedDataFromJsonFileToDataFrame()

"""
function createAnalyzedJsonFile()
    """
        read sql.log file
            log/sql.log ex. select ftest2.id,ftest2.name from ftest2
    """
    sqllogfile = getFileNameFromLogPath(JetelinaSQLLogfile)
    df = readdlm(sqllogfile, ' ', String, '\n')

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
    u = unique(df[:, [:2]])

    """
        1.make unique sql statements
        2.pick only the columns part
        3.count the access number in each sql
        4.put it into DataFrame alike
            ex. 
                column_name      access_number
            ftest3.id,ftest2.name    2
    """
    u_size = length(u)
    df_size = length(df[:, [:2]])

    # uにはユニークなSQL文が入っているので、sql.logの中のマッチングでアクセス数を取得する ex. u[i] === ....
    sql_df = DataFrame(column_name=String[], combination=[], access_number=Float64[])

    """
        shape the data
            ex. 
                column    combination         access number
            ftest3.id     ['ftest3','ftest2']      2
            ftest2.name   ['ftest3','ftest2']      2
            ftest3.id     ['ftest4','ftest2']      5
            ftest2.name   ['ftest2']              10

            then 
            ftest3.idが一番呼ばれたのは['ftet4','ftest2']なので、ftest3.idはこれを採用
            ftest2.name        〃      ['ftest2']なので、ftest2.nameはこれを採用→table変更は必要なさそう
    """

    for i = 1:u_size
        ac = 0
        # collect access number for each unique SQL. make "access_number"
        for ii = 1:df_size

            if u[i] == df[:, [:2]][ii]
                ac += 1
            end
        end

        table_arr = String[]
        c = split(u[i], ",")
        # make "column_name" and "combination" 
        for j = 1:length(c)
            """
                cc[1]:table name
                cc[2]:column name 
            """
            cc = split(c[j], ".")
            # table_arrにcc[1]が入っているかどうか見ている。論理否定。これが書きたかったからJulia。
            if cc[1] ∉ table_arr
                push!(table_arr, cc[1])
            end

            push!(sql_df, [c[j], table_arr, ac])
        end

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
    table_df = DBDataController.getTableList("dataframe")

    #===
     by Ph. Kaminski
        table_df.tablenameがユニークだからできる技。
        d("ftest"=>1 "ftest2=>4...と入っている)　を参照してindexを取得し、それをcombinationに当てはめていく
    ===#
    d = Dict(table_df.tablename .=> axes(table_df, 1))
    sql_df.combination = [getindex.(Ref(d), x) for x in sql_df.combination]

    # 一番大きなaccess_numberで各access_numberを正規化する
    sql_df.access_number = sql_df.access_number / maximum(sql_df.access_number)


    #B_len = length.(sql_df.combination)
    #ml = findall(x -> x == (maximum(B_len)), B_len)

    if debugflg
        @info JSON.json(Dict("Jetelina" => copy.(eachrow(sql_df))))
    end

    #===
        後々解析する際にCSV形式で持っていると楽かなぁと思って。
        でも、JSON3を使ってjsonファイルから読み出しができるから不要となりましたとさ。
    ===#
    #sqlcsvfile = getFileNameFromLogPath("sqlcsv.csv")
    #CSV.write(sqlcsvfile, sql_df)

    #===
        でこっちは、JSON形式でファイルに格納しておけば、RestAPIで呼ばれたときにファイル出力してやればいいだけなので楽だろうということで
        JSONにする。が、 Genie.Renderer.Jsonを使うとHTTPプロトコル出力(HTTP 200とか)が付いてしまうので、ここはプレーンなJSON
        モジュールを使うことにする。
    ===#
    open(sqljsonfile, "w") do f
        println(f, JSON.json(Dict("Jetelina" => copy.(eachrow(sql_df)))))
    end

end

"""
    read sqlcsv.json then put it to DataFrame for experimental*()
"""
function getAnalyzedDataFromJsonFileToDataFrame()
    js = read(sqljsonfile, String)
    dic = JSON.parse(js)
    df = DataFrame(dic)

    # <- 現状、JetelinaでDFができているので、中身で展開するようにしないとね
    d_col = df[!, :Jetelina]
    combination_arr = Array[]
    column_name_arr = String[]
    access_number_arr = Float64[]

    for i in eachindex(d_col)
        push!(combination_arr, d_col[i]["combination"])
        push!(column_name_arr, d_col[i]["column_name"])
        push!(access_number_arr, d_col[i]["access_number"])
    end

    #=== 
        combinationにあるindex番号をtable名に変換する。
        130行目Kaminskiさんに教えてもらった方法の逆をやる。
        130行目ではjsonデータとして画面グラフレンダリングが必要だったのでtable名->数字　に変更したが、
        ここでは、table名そのものが欲しいので逆処理をやっている。
    ===#
    if 0 < length(combination_arr)
        table_df = DBDataController.getTableList("dataframe")
        d = Dict(axes(table_df, 1) .=> table_df.tablename)
        combination_arr = [getindex.(Ref(d), x) for x in combination_arr]
    end

    df_arr = DataFrame(:combination => combination_arr, :column_name => column_name_arr, :access_number => access_number_arr)

    #===
        ↑ここまでがデータ解析の準備
        ↓ここからがデータ解析処理
    ===#
    c_len = length.(df_arr.combination)
    hightcomblen = findall(x -> x == (maximum(c_len)), c_len) # このhighcomblenにはmaxのデータのindex番号が入る
    maxaccess_n = maximum(df_arr[!, :access_number]) # 参考までに取得

    if debugflg
        @info "combination max len: " length(hightcomblen) maxaccess_n
    end

    #===
        combination lengthが1であるのは単一table使用の意味になるので、
        ここでは２つ以上のtable使用のモノを対象として調べることにする
    ===#
    if 1 < length(hightcomblen)
        candidate_columns = Dict()
        for i = 1:length(hightcomblen)
            # dict作成処理の変数名が長くなるので、ここで短いヤツにしておく　<-単に見通しを良くするため
            hl = hightcomblen[i]
            acn = df_arr[hl, :access_number]
            #===
                Dict形式 a=>b　でcandidate...に追加している
            ===#
            candidate_columns[df_arr[hl, :column_name]] = acn
        end

        #=== 
            このデータがTableレイアウト変更対象のデータになる
            なぜなら、
            　　1.一番複雑(関連tableが多い)なcombination
            　　2.しかもアクセス数が多い
            から
        ===#
        target_column = findall(x -> x == maximum(values(candidate_columns)), candidate_columns)
        
        if debugflg
            @info "target is  " target_column
        end

        experimentalTableLayoutChange(target_column)
    end
end

"""
    drop testdb
"""
function dropTestDB( conn )
    dbdrop = """drop database if exists $JetelinaTestDBname"""
    return PgDBController.execute(conn, dbdrop)
end

"""
    create testdb by using running db(JetelinaDBname)
"""
function copyTablesToTestdb()
   # @info "status: " status(PgDBController.open_connection())
    #if LibPQ.isopen(PgDBController.open_connection())
    #    LibPQ.reset!(PgDBController.open_connection())
    #end

    if JetelinaDBtype == "postgresql"
        conn = PgDBController.open_connection()
        try
            #===
                copyを実行するまえにtestdbがあればdropしておく。
                postgresqlのcreate databaseにはif exist..句がないため。
            ===#
            dropTestDB( conn )

            dbcopy = """create database $JetelinaTestDBname template $JetelinaDBname"""
            PgDBController.execute(conn, dbcopy)
        catch err
            JetelinaLog.writetoLogfile("SQLAnalyzer.copyTablesToTestdb() error: $err")
        finally
            PgDBController.close_connection(conn)
        end
    
    @info "after: " isopen(conn)

    elseif JetelinaDBtype == "mariadb"
    elseif JetelinaDBtype == "oracle"
    end
end

"""
    Table Layout Change
        analyzeに基づいてTableレイアウト変更を仮実行する。
"""
function experimentalTableLayoutChange(tablecolumn)
    @info "well table layout change with $tablecolumn: " tablecolumn

    d = split(tablecolumn[1],".")

    @info "table and column " d[1] d[2]

    #===
    1.運用中のDBの全tableを解析用DBにコピーする。データ数は全件ではない
    2.該当するtableのレイアウト変更を実行する
    3.sql listの対象となるselect文を実験実行する
    4.性能を比較してどうするか決める
    5.解析用DBを削除することを忘れずに

    1,5は上位でやろう
    ===#

    # JetelinaSQLListfileを開いて対象となるsql文を呼ぶ
    # そのsqlでPgTestDBController.doSelect(sql)　を呼ぶ
    # 実験で得られたdata(max,min,mean)とJetelina..fileにある既存値を比較する　ref. measureSqlPerformance()
    # 全体としてパフォーマンスの改善が見られたらレイアウトを変更する。
end

"""
    Experimental SQL Run
        Table Layout Changeに対してSQLを発行して、処理速度を現状と比べる。
        結果をファイルに格納する。
"""
function experimentalMeasureSqlPerformance()
end

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
function compareThePerformances()
end
function tableReformSuggestion()
end

end