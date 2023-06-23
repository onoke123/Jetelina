"""
    module: SQLAnalyzer

    read the log/sql.log file, then analyze the calling column status

    contain functions

"""
module SQLAnalyzer

using CSV
using DataFrames
using Genie, Genie.Renderer, Genie.Renderer.Json
using JSON, LibPQ, Tables
using JetelinaReadConfig, JetelinaLog
using ExeSql, DBDataController, PgDBController
using DelimitedFiles
using JetelinaFiles
using TestDBController, PgDataTypeList

const sqljsonfile = getFileNameFromLogPath(JetelinaSQLAnalyzedfile)

"""
    functions
        createAnalyzedJsonFile()
        _exeSQLAnalyze()

"""
function createAnalyzedJsonFile()
    """
        read sql.log file
            log/sql.log ex. select ftest2.id,ftest2.name from ftest2

        delimiteを' 'にしているのでselect文のカラム表示はちゃんと詰めて書かれることを期待する。
            ex.    select ftest2.id,ftest2.name from ...     OK
                   select ftest2.id, ftest2.name from ....   NG
                                    ^^
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
            #===
                 該当tableがmaster系でなければ処理する。
                 master系tableには"master"がtable名に入っているのがプロトコル。
            ===#
            if !contains( cc[1], "master" )
                # table_arrにcc[1]が入っているかどうか見ている。論理否定。これが書きたかったからJulia。
                if cc[1] ∉ table_arr
                    push!(table_arr, cc[1])
                end

                push!(sql_df, [c[j], table_arr, ac])
           end
        end

    end

    #===
        解析処理のルーチンに入る
    ===#
    _exeSQLAnalyze(sql_df)

    #===
        ここから下は、Jetelinaのconditional panelでグラフを書くための処理。
        統計処理自体は↑で終わっている。
    ===#

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
        master系tableを対象外とするために、table_dfにfilter処理をして"master"を含むtableを除外している。
        ここの処理はちょっと重要。( ｰ`дｰ´)ｷﾘｯ
    ===#
    filter!(:tablename=>x->!contains(x,"master"),table_df)
    
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
function _exeSQLAnalyze(df::DataFrame)
    @info "in the.. df " df

 #===   
    js = read(sqljsonfile, String)
    dic = JSON.parse(js)
    df = DataFrame(dic)

    @info "old df " df

    # <- 現状、JetelinaでDFができているので、中身で展開するようにしないとね
    d_col = df[!, :Jetelina]
===#
    combination_arr = Array{String,1}
    column_name_arr = String[]
    access_number_arr = Float64[]
#===
    for i in eachindex(d_col)
        push!(combination_arr, d_col[i]["combination"])
        push!(column_name_arr, d_col[i]["column_name"])
        push!(access_number_arr, d_col[i]["access_number"])
    end
===#
    combination_arr = df[!,:combination]
    column_name_arr = df[!,:column_name]
    access_number_arr = df[!,:access_number]

    @info "combination arr " combination_arr
    @info "column_name arr " column_name_arr
    @info "access_number arr " access_number_arr

    #=== 
        combinationにあるindex番号をtable名に変換する。
        130行目Kaminskiさんに教えてもらった方法の逆をやる。
        130行目ではjsonデータとして画面グラフレンダリングが必要だったのでtable名->数字　に変更したが、
        ここでは、table名そのものが欲しいので逆処理をやっている。
    ===#
    #===
    if 0 < length(combination_arr)
        table_df = DBDataController.getTableList("dataframe")
        d = Dict(axes(table_df, 1) .=> table_df.tablename)
        combination_arr = [getindex.(Ref(d), x) for x in combination_arr]
    end
    ===#
    
    df_arr = DataFrame(:combination => combination_arr, :column_name => column_name_arr, :access_number => access_number_arr)
    #===
        ↑ここまでがデータ解析の準備
        ↓ここからがデータ解析処理
    ===#
    c_len = length.(df_arr.combination) # length処理に'.'が付いているからね😁
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
        candidate_tables = Dict()
#        real_target_column = Dict()
        candidate_combination =[]
        
        for i = 1:length(hightcomblen)
            # dict作成処理の変数名が長くなるので、ここで短いヤツにしておく　<-単に見通しを良くするため
            hl = hightcomblen[i]
            acn = df_arr[hl, :access_number]
            #===
                Dict形式 a=>b　でcandidate...に追加している
            ===#
            candidate_columns[df_arr[hl, :column_name]] = acn
            push!( candidate_combination, df_arr[hl, :combination])

#            println("hightco...:",df_arr[hl, :column_name],"->",acn,"->",df_arr[hl, :combination])
        end

        #=== 
            このデータがTableレイアウト変更対象のデータになる
            なぜなら、
            　　1.一番複雑(関連tableが多い)なcombination
            　　2.しかもアクセス数が多い
            から
        ===#
        target_column = findall(x -> x == maximum(values(candidate_columns)), candidate_columns)

        println("candidate_columns: ", candidate_columns)
        println("target_column: ", target_column)

        #===
            レイアウト変更対象のデータを「どのtable」に移動したらいいかを判定する
        ===#
        if 0<length(target_column) && 0<length(candidate_combination)
            for i=1:length(target_column)
                for ii=1:length(candidate_combination)
                    #=== 
                        target_column[i]とcandidate_combination[i][ii]の組合せでdf_arrを検索し、ヒットしたaccess_numberの総和を求める。
                        1.target_columnでfilter()を使い、target_columnだけのDataFrameを作成する
                        　　ex. df_a = filter(:column_name => n -> n == target_column[i], df_arr)
                        2.1で作成されたDataFrameの:combinationにcandidate_combination[ii]が含まれることを確認する
                          occursin()もcontains()もvector stringを引数にとらないので、combinationをstringに変換してから比較する
                            ex.  p = df_a[!,:combination]
                                 if contains(string(p),string(candidate_combination))..
                                    含む(true)なら:access_numberの総和を計算する
                    ===#
                    df_a = filter(:column_name => n -> n == target_column[i], df_arr)
#                    @info "df_a is " df_a

                    p = df_a[1,:combination]
                    @info "compare: " p candidate_combination[ii]
                    if contains(string(p), string(candidate_combination[ii]))
                        #===
                            Dict形式 a=>b　でcandidate...に追加している
                        ===#
                        #### なんかこの辺が変だなぁ。思ったようなdataが入っていない気がする
                        candidate_tables[candidate_combination[ii]] = df_a[1,:access_number]

                        println(string("Hit :",candidate_combination[ii], "->", df_a[1,:access_number]))
                    end

                end

                #=== 
                    このデータがTableレイアウト変更移行先のTableになる
                    なぜなら、
                    　　1.一番一緒に使われている回数が多い
                    から
                ===#
#                @info "target_table : " target_table = findall(x -> x == maximum(values(candidate_tables)), candidate_tables)

        #                real_target_column[i] = foreach((x,y) -> _determineTheTable(x,y),target_column, candidate_combination)
            end
        end

        if debugflg
 #           @info "targets are  " target_column length(unique(target_column)) candidate_combination
 #           @info "then the target is " real_target_column

#                println("""$target_column  $candidate_combination""")
#            @info "pick up sample: " target_column[1] candidate_combination[1][1]
        end

        #===
            レイアウト変更対象カラムtarget_columnは取得できた。
            このデータで本当にいいかどうか判断しよう。

            まずは、どのtableに移動すればいいか判断する
            1.combinationが2つなら「もう一方の」tableにいどうすればいい　-> 簡単な話
            2.combinationが3つ以上のとき「どのtableとの相関が一番強いか」見よう
            　　(1)対象カラムを含むtableとcombination tableが他のSQLでどの程度組み合わされているか　->　一番組み合わせ頻度の多いtableが移動先対象になる
            　　(2)(1)で判断がつかない(同数になる)なら、実行されたSQL回数を見てみる　->　一番実行されたものが優先される
            　　(3)(2)でも判断つかない((1)(2)も同数になる)なら、どれでもいいやってことになる
            3.但し、target_columnが2で決定されたtable以外と他のSQLで組み合わせがあったら、これはもうtarget_columnではなくなる　->　将来的にはなんか考えるとして、現状は「制約」としておく
        ===#

        #===
            上やってから下をやる。今はちょっとコメントアウトしておく。下が動くのはわかっている。

        # まずはtestdb作成
        creatTestDB()

        # そのtestdbで操作するぜ
        experimentalTableLayoutChange(target_column)
        ===#
    end
end

"""
    レイアウト変更候補のカラムと、それらが関連するtableを突き合わせ、
    1.sql実行回数が一番多いモノを候補とする
    2.1の結果が複数ある場合は、SQL文として一番多いモノを候補とする
    3.2でも複数ある場合は、レイアウト変更しない(ver.1ではね)

    x:レイアウト変更候補カラム配列   ex. ["ftest.name","ftest2.age"]
    y:xに対応したtableカラム         ex. ["ftest","ftest2],["ftest2","ftest3"]
    return (colulmn name, table name) のtuple  ex. ("ftest.name","ftest2")
"""
function _determineTheTable(x,y)
end

"""
    dropTestDB()

    drop testdb
"""
function dropTestDB(conn)
    dbdrop = """drop database if exists $JetelinaTestDBname"""
    return PgDBController.execute(conn, dbdrop)
end

"""
    creatTestDB()

    create testdb by using running db(JetelinaDBname)
"""
function creatTestDB()
    if JetelinaDBtype == "postgresql"
        conn = PgDBController.open_connection()

        try
            #===
                copyを実行するまえにtestdbがあればdropしておく。
                postgresqlのcreate databaseにはif exist..句がないため。
            ===#
            dropTestDB(conn)

            dbcopy = """create database $JetelinaTestDBname"""
            execute(conn, dbcopy)

            #===
                testdb作成成功なら運用DBのtableリストを取得する。
                別関数にするのがきっとキレイなんだけど、DB毎の処理をこの関数で行っているので、
                なるべくまとめておきて、あちらこちらでif postgresql　と書かないで済むようにと。
            ===#
            return DBDataController.getTableList("dataframe")
        catch err
            JetelinaLog.writetoLogfile("SQLAnalyzer.creatTestDB() error: $err")
        finally
            PgDBController.close_connection(conn)
        end

    elseif JetelinaDBtype == "mariadb"
    elseif JetelinaDBtype == "oracle"
    end
end

"""
    tableCopy()

    運用DBにあるtableをtestdbにも作り、指定されたデータ件数だけinsert(copy)する。
    DBによってはcopy処理コマンドがあったりするけど、ないものもあるので
          1.table作成
          2.データブッコミ
    の手順を取ることにした。
    ブッコミデータ数は任意だけどconfigで可変にして大域変数JetelinaTestDBDataLimitNumberとしている。
    table処理の実態は_load_table!()にまかせている。
"""
function tableCopy(df)
    tconn = TestDBController.open_connection()
    conn = PgDBController.open_connection()

    try
        for i = 1:size(df)[1]
            tn = df[!, :tablename][i]
            selectsql = """select * from $tn limit $JetelinaTestDBDataLimitNumber"""
            altdf = DataFrame(columntable(LibPQ.execute(conn, selectsql)))
            _load_table!(tconn, altdf, tn)
        end
    catch err
        JetelinaLog.writetoLogfile("SQLAnalyzer.tableCopy() error: $err")
    finally
        PgDBController.close_connection(conn)
        TestDBController.close_connection(tconn)
    end
end

"""
    _load_table!()

    ref. https://discourse.julialang.org/t/how-to-create-a-table-in-a-database-using-dataframes/75759/2
"""
function _load_table!(conn, df, tablename, columns=names(df))
    # columnのタイプをarray取得しておく
    column_type = eltype.(eachcol(df))
    # DataFramesのカラムはこんな感じのデータになるので宣言しておく
    column_type_string = Array{Union{Nothing,String}}(nothing, length(columns))
    # create tableする時のcolumn文字列(id,name,sex,....)
    column_str = string()

    for i = 1:length(columns)
        column_type_string[i] = PgDataTypeList.getDataTypeInDataFrame(column_type[i])
        column_str = string(column_str, " ", columns[i], " ", column_type_string[i], ",")
    end

    # 最後に","が余分に付いちゃうのでここで切っておく
    column_str = chop(column_str)

    # create table 実行文組み立て
    create_table_str = """create table if not exists $tablename ( $column_str );"""
 
    # data insert文の組み立てやらなんやかや準備
    table_column_names = join(string.(columns), ", ")
    placeholders = join(("\$$num" for num in 1:length(columns)), ", ")
    data = select(df, columns)

    try
        execute(conn, "BEGIN;")
        # create table実行
        execute(conn, create_table_str)
        # load!()はexportされていないらしいので、あえてLibPG.をつけてdata insert実行
        LibPQ.load!(
            data,
            conn,
            "INSERT INTO $tablename ($(table_column_names)) VALUES ($placeholders)"
        )

        execute(conn, "COMMIT;")
    catch err
        JetelinaLog.writetoLogfile("SQLAnalyzer.load_table!() error: $err")
        execute(conn, "ROLLBACK;")
    end
end

"""
    Table Layout Change
        analyzeに基づいてTableレイアウト変更を仮実行する。
"""
function experimentalTableLayoutChange(tablecolumn)
    @info "well table layout change with $tablecolumn: " tablecolumn

    d = split(tablecolumn[1], ".")

    @info "table and column " d[1] d[2]

    #===
    1.運用中のDBの全tableを解析用DBにコピーする。データ数は全件ではない
    2.該当するtableのレイアウト変更を実行する
    3.sql listの対象となるselect文を実験実行する
    4.性能を比較してどうするか決める
    5.解析用DBを削除することを忘れずに

    1,5は上位でやろう
    ===#

    #1
    table_df = creatTestDB()
    tableCopy(table_df)

    #2


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