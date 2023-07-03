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
using JetelinaFiles, JetelinaReadSqlList
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
#    sql_df = DataFrame(column_name=String[], combination=[], access_number=Float64[])
    sql_df = DataFrame(column_name=String[], combination=Vector{String}[], access_number=Float64[])

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
#=== ちょっとコメントアウトしておく 6/23
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
ここまで===#
end

"""
    read sqlcsv.json then put it to DataFrame for experimental*()

    引数のdfはSQL実行履歴
"""
function _exeSQLAnalyze(df::DataFrame)
    @info "df: " df eltype(eachcol(df))

    c_len = length.(df.combination) # length処理に'.'が付いているからね😁
    hightcomblen = findall(x -> x == (maximum(c_len)), c_len) # このhighcomblenにはmaxのデータのindex番号が入る
    maxaccess_n = maximum(df[!, :access_number]) # 参考までに取得

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
        candidate_combination =[]
        
        for i = 1:length(hightcomblen)
            # dict作成処理の変数名が長くなるので、ここで短いヤツにしておく　<-単に見通しを良くするため
            hl = hightcomblen[i]
            acn = df[hl, :access_number]
            #===
                Dict形式 a=>b　でcandidate...に追加している
            ===#
            candidate_columns[df[hl, :column_name]] = acn
            push!( candidate_combination, df[hl, :combination])
        end

        #=== 
            このデータがTableレイアウト変更対象のデータになる
            なぜなら、
            　　1.一番複雑(関連tableが多い)なcombination
            　　2.しかもアクセス数が多い
            から
        ===#
        target_column = findall(x -> x == maximum(values(candidate_columns)), candidate_columns)

        @info "target_column: " target_column
        @info "candidate_combination: " candidate_combination

        #===
            レイアウト変更対象のデータを「どのtable」に移動したらいいかを判定する
            target_columnとcandidate_combinationの組合せを作って、どの組合せが一番多いかSQLリストを検索する
            検索対象はJetelinareadSqlList.readSqlList2DataFrame()で作成されているDataFrame Df_JetelinaSqlList

            Df_JetelinaSqlList
                Row |  no    | sql
            |-------|--------|----------------------
            |      1| ji293  | insert into masterftest values(id,'name','sex',age,ave,jetelina_delete_flg)
            |      2| ju294  | update masterftest set id=d_id,name='d_name',sex='d_sex',age=d_age,ave=d_ave,jetelina_delete_flg=d_jetelina_delete_flg
                  .      .                 .
                  .      .                 .

            select文だけを対象とするので、startswith(df[!,:no],"js") かな
        ===#
        if 0<length(target_column) && 0<length(candidate_combination)
            #===
                target_column[i] と candidate_combination[i] は対になっているから、
                (target_column[i],candidate_combination[i][ii])の組合せを作ってDf_JetelinaSqlList.sqlを検索する

                select t1.a,t2.b,t3.c from t1,t2,t3
            　　　このSQLの実行回数が一番多くて且つ、combinationも多いとなると、
            　　　対象はt1.a,t2.b,t3.cの3つになる。
            　　　
            　　　[t1.a + t2] [t1.a + t3]
                 [t2.b + t1] [t2.b + t3]
                 [t3.c + t1] [t3.c + t2]
            　　　の組合せで
            　　　1.静的比較：SQL文としてはどの組合せが一番多いか
            　　　2.動的比較：SQL文としてはどの組合せの実行回数が多いか

            　　　2->1　の順で比較する：1->2だと使われていないSQLの影響が最初に大きく出てしまうから

                JSON Analyze file
                    t1.a,[t1,t2,t3],10     <-①
            　 　　 t1.a,[t1,t2], 3        <-②
                    t1.a,[t1,t3],5         <-③

                    ①+②　or ①+③ のどちらか大きい方をとる
            ===#

            #== 
                Df_JetelinaSqlListはJenie空間にあるため、もしかしたらSQLAnalyzerを単独実行すると
                使えないかもしれない。そんな時は以下が実行されてDf_JetelinaS...を作る。
            ===#
            if( Df_JetelinaSqlList === nothing )
                JetelinareadSqlList.readSqlList2DataFrame()
            end

#            println(Df_JetelinaSqlList)
            # 1.静的比較            
            for i=1:length(target_column)
                for ii=1:length(candidate_combination[i])
                    p = split( target_column[i], '.' ) # ex. ftest.name -> [1]: ftest [2]:name
                    if candidate_combination[i][ii] != p[1]
                        p = nrow(filter([:no,:sql] => (n,s) -> startswith(n,"js") && contains(s,target_column[i]) && contains(s,candidate_combination[i][ii]),Df_JetelinaSqlList))
                        #===
                            Dict形式 (column,table) => 2
                            という風に"target column","target table"のtupleにSQL句の関連数を格納している
                        ===#
                        candidate_tables[(target_column[i],candidate_combination[i][ii])] = p
                    end
                end

            end
        end

        #===
            target_dataに(column,table)のtupleで入っているので、取り出し方は
                target_column = target_data[1][1]
                target_table  = target_data[1][2]

            となるので、target_column -> target_table　にレイアウト変更することを考える
        ===#
        target_data = findall(x -> x == maximum(values(candidate_tables)), candidate_tables)

        @info "target_data : " target_data target_data[1][1] target_data[1][2]

        # testdbで操作するぜ
        experimentalTableLayoutChange(target_data)
    end
end

"""
    Table Layout Change
        analyzeに基づいてTableレイアウト変更を仮実行する。

        Args: target tuple data (column,table) ex. (ftest.name, ftest2)  <- meaning: name in ftest table try to moves to ftest2 table
"""
function experimentalTableLayoutChange(target)
    @info "column move to table: " target[1][1] target[1][2]

    #===
    1.運用中のDBの全tableを解析用DBにコピーする。データ数は全件ではない
    2.該当するtableのレイアウト変更を実行する
    3.sql listの対象となるselect文を実験実行する
    4.性能を比較してどうするか決める
    5.解析用DBを削除することを忘れずに

    1,5は上位でやろう
    ===#

    #1
#    table_df = creatTestDB()
#    tableCopy(table_df)

    #2
    tableAlter(target)

    # JetelinaSQLListfileを開いて対象となるsql文を呼ぶ
    # そのsqlでPgTestDBController.doSelect(sql)　を呼ぶ
    # 実験で得られたdata(max,min,mean)とJetelina..fileにある既存値を比較する　ref. measureSqlPerformance()
    # 全体としてパフォーマンスの改善が見られたらレイアウトを変更する。
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
    指定されたカラムデータを、指定されたテーブルに移動するべく、alterでカラムを作成する

    Args: target tuple data (column,table) ex. (ftest.name, ftest2)  <- meaning: name in ftest table try to moves to ftest2 table

"""
function tableAlter(target)
    tconn = TestDBController.open_connection()

    #===
        target[1][1]には元カラム名として table.column(ex. ftest.name)で入っている。
        このcolumnをtarget[1][2]にaddしてやる。つまり、
        ex.
           ftest.name -> ftest, name の"name”をtarget[1][2]にalter add columnしてやる。
    ===#
    origin  = split(target[1][1],'.')
    origin_table = origin[1]
    origin_column = origin[2]
    moveto_table = target[1][2]

    #===
        移動対象となる元カラムデータのデータタイプを取得しておく。
        他でやっておくところがなかったのでここでやっておく。alterする時の移動先のカラムのデータタイプとして使用する。🙄
    ===#
    origin_column_datatype = """select pg_typeof($origin_column) from $origin_table;"""

    try
        #===
            どうやらcolumn_types()は指定されたカラムデータのデータタイプをArrayで返してくるらしい。
            つまり、ex.  id, name, sex とかのカラムデータを取ろうと思ったら　Type[Int64,String,String]　という風に。
            なので、今回はorigin_columnは一つだけ指定しているのでType[..]で返ってくるので、これをPostgreのデータタイプに
            するためにPgDataTypeList.getDataType()にType[..][1]を渡してやれば、それなりのデータタイプが得られると。
        ===#
        dtyp = LibPQ.column_types(execute(tconn, origin_column_datatype))
        # dtype -> Type[String]とかで返ってくるので　dtyp[1] -> String　となる :o
        dt = PgDataTypeList.getDataType(dtyp[1])

        # add先のtableに同名があることもあるので、追加するcolumn名はオリジナル名(ex. ftest.age)を残すことにする(ex. ftest_age)。
        add_column = replace(target[1][1], "." => "_", count=1)

        # create table 実行文組み立て
        table_alter_str = """alter table $moveto_table add column $add_column $dt;"""

        if debugflg
            @info "alter str: " table_alter_str
        end

        execute(tconn, table_alter_str)
    catch err
        println(err)
        JetelinaLog.writetoLogfile("SQLAnalyzer.tableCopy() error: $err")
    finally
        TestDBController.close_connection(tconn)
    end
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