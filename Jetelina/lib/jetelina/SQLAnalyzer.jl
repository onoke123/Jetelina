"""
    module: SQLAnalyzer

    Author: Ono keiji
    Version: 1.0
    Description:
        Analyze execution speed of all SQL sentences. 
    
    functions
        main() this function set as for kicking createAna..() from outer function.
        createAnalyzedJsonFile() create json file for result of sql execution speed analyze data.
        extractColumnsFromSql(s::String)  pick up columns data from 's'.
        experimentalCreateView(df::DataFrame)  create view tables for test and execute all sql sentences for analyzing.
        createView(df::DataFrame)  create view table from a sql sentence that has multi tables and hight use in the running db.
        dropTestDB(conn)  drop testdb. doubtfull. :-p
        creatTestDB()    create testdb by using running db(JetelinaDBname). only postgresql now. other db should be impremented later.
        tableCopy(df::DataFrame) copy some data from the running db to the test db. the number of copy data are ordered in JetelinaTestDBDataLimitNumber.
"""
module SQLAnalyzer

    using CSV
    using DataFrames
    using Genie, Genie.Renderer, Genie.Renderer.Json
    using JSON, LibPQ, Tables
    using StatsBase
    using JetelinaReadConfig, JetelinaLog
    using DBDataController, PgDBController
    using DelimitedFiles
    using JetelinaFiles, JetelinaReadSqlList, SQLSentenceManager
    using TestDBController, PgDataTypeList

    const sqljsonfile = getFileNameFromLogPath(JetelinaSQLAnalyzedfile)

    """
    function main()

        rap function for executing createAnalyzedJsonFile() that is the real analyzing function.
        this function set as for kicking createAna..() from outer function.

    # Arguments

    """
    function main()
        createAnalyzedJsonFile();
    end

    """
    function createAnalyzedJsonFile()

        create json file for result of sql execution speed analyze data.

    # Arguments

    """
    function createAnalyzedJsonFile()
        #===
            Tips:
                read sql.log file
                    log/sql.log ex. js314,"select ftest.sex,ftest.age,ftest.name from ftest as ftest "

                the delimite of this file is ' ', that why expect right justify in select sentences.
                    ex.    select ftest2.id,ftest2.name from ...     OK
                        select ftest2.id, ftest2.name from ....   NG
                                            ^^

                wondering is it ok if sql.log has more than one milion lines.
                maybe should consider to rotate sql.log files. this is in #ticket 1254 
        ===#
        sqllogfile = getFileNameFromLogPath(JetelinaSQLLogfile)
        maxrow::Int = JetelinaReadingLogMaxLine
        df = CSV.read( sqllogfile, DataFrame, limit=maxrow )
        #===
            Tips:
                get uniqeness
                    ex. 
                    "js312,"  "select ftest.name,ftest.age,ftest2.name,ftest2.age,ftest3.age,ftest3.dumy from ftest as ftest,ftest2 as ftest2,ftest3 as ftest3 where ftest.id=ftest2.id and ftest.id=ftest3.id"  ""
                    "js312,"  "select ftest.name,ftest.age,ftest2.name,ftest2.age,ftest3.age,ftest3.dumy from ftest as ftest,ftest2 as ftest2,ftest3 as ftest3 where ftest.id=ftest2.id and ftest.id=ftest3.id"  ""

                    -->
                    "js312,"  "select ftest.name,ftest.age,ftest2.name,ftest2.age,ftest3.age,ftest3.dumy from ftest as ftest,ftest2 as ftest2,ftest3 as ftest3 where ftest.id=ftest2.id and ftest.id=ftest3.id"  ""

                do uniqueness with 'apino' because of difference 'where' sentences, maybe.
        ===#
        u = unique(df[:, :apino])
        #===
            Tips:
                steps for analyzing
                    1.make unique sql statements
                    2.pick only the columns part
                    3.count the access number in each sql
                    4.write them out to analyzing files
        ===#
        u_size = length(u)
        df_size = nrow(df) # all line number
        # step1: unique 'apino' in 'u', then count access number in sql.log.  ex. u[i] === ....
        sql_df = DataFrame(apino=String[], sql=String[], combination=Vector{String}[], access_number=Float64[])

        #===
            Tips:
                shape the data
                    ex. 
                    apino      sql         combination         access number
                    js10    select ....  ['ftest3','ftest2']      2
                    js22    select ....  ['ftest4','ftest2']      5
                    js30    select ....  ['ftest2']              10

                hire js22 because it is the highest access number among higher combination number(js10,js22) to create a client view graph 'condition panel'.
                js30 may does not need to be created in 'condition panel' so that it is the best number but it has low combination number. 
        ===#

        for i = 1:u_size
            ac = 0
            # collect access numbers for each unique SQL. make "access_number"
            dd = filter(:apino=>x->x==u[i],df)
            ac = nrow(dd)
            table_arr = String[]
            tables = String[]

            #==
                step2:
                    pick up columns from sql sentence. the columns are between 'select' and 'from'.
                        ex. select <columns> from <tables> where ...  -> <columns> 

                    this can do because of unified sql sentence by Jetelina created.  <-- importance!
            ==#
            cols = extractColumnsFromSql(df[:,:sql][i])
            c = split(cols[1], ",")

            for j = 1:length(c)
                #===
                    Tips:
                        c[j] -> <table name>.<column name>
                        then spliting to
                        cc[1]:table name
                        cc[2]:column name 
                ===#
                cc = split(c[j], ".")
                
                #===
                    Tips:
                        reject master tables.
                        master tables has 'master' in their own name. this is the protocol. <-- importance!
                ===#
                if !contains( cc[1], "master" )
                    # logical NOT in Julia, yes.
                    if cc[1] ∉ table_arr
                        push!(table_arr, cc[1]) # push except master table without duplication.
                    end

                    push!(tables,cc[1])  # collect table names used in the sql sentence, whatever.
                end
            end

            #===
                Tips:
                    push the best number of table in tables[] as 'basic table' to the head of table_arr.
                    in the case of multi candidates in 'basic table', they are ordered in Ascii.
                        ex. there are candidates as 'a','b'(they are same number), will hire 'a'. hum.. alright. 

                    this 'basic table' is to be x-axis order in 'Access vs Combination' graph in the conditon panel, that is drwawn by Plotly.js.
                        
                    mode() is included in StatsBase.jl to return the mode of tables array.

                    then sql_df will be alike below, you can see 'basic table' is in the head of 'combination' array data,

                        Row │ apino   sql                                    combination                        access_number 
                            │ String  String                                 Array…                             Float64       
                  ─────┼───────────────────────────────────────────────────
                          1 │ js312   select ftest.name,ftest.age,ftes…  ["ftest", "ftest", "ftest2", "ft…            5.0
                          2 │ js313   select ftest.name,ftest.age,ftes…  ["ftest", "ftest", "ftest2", "ft…            3.0
                          3 │ js314   select ftest.name,ftest.age,ftes…  ["ftest", "ftest", "ftest2", "ft…            1.0
            ===#
            pushfirst!(table_arr,mode(tables))
            # move it to here becase it has changed each column name to each sql name.
            push!(sql_df, [u[i], df[:,:sql][i],table_arr, ac])
        end
        #===
            ↑ preparation.
            ↓ analyzing.
        ===#

        # find the sql that is the longest combination number
        c_len = length.(sql_df.combination)
        p = findall(x->x==maximum(c_len),c_len) # 'p' has the index number of the max data

        # step3. find the max access number among the longest combination number sql sentence.
        accn = sql_df[p,:access_number]
        pp =  findall(x->x==maximum(accn),accn)

        # then the target sql sentence is this.
        target = sql_df[pp,:]
        
        # step4: good!. let's analyze it in testdb.
        experimentalCreateView(target)

        #===
            Tips:
                from here for showing the anlyzed graph in conditional pane.
                the analyzing has been done above.
        ===#
        # delete ':sql' column from 'sql_df', because it is unnecessary in the json file.
        select!(sql_df,:apino,:combination,:access_number)
        #===
            Tips:
                this tips is complicated, that why still in Japanese.
                what here is doing, 
                    ex.
                        replace 'combination' with 'Row No.' of each table.

                        Row │ apino          combination                    access_number 
                            │ String           Array…                         Float64       
                        ──┼────────────────────────────────
                        1   │ js312  ["ftest", "ftest2", "ftest3"]            5.0
                        2   │ js313  ["ftest", "ftest2", "ftest3"]            5.0
                        3   │ js314  ["ftest", "ftest2", "ftest3"]            5.0

                        ftest3.idはftest3にあるので→x座標:3(ftest3)
                        ftest3.idはftest4+ftest2が代表値なので → (3+4)/2(tableが2つだから)=3.5 ←y座標になる
                        よって、ftest3.idの座標は(3,3.5)

                        ”access number”はk-means法の"重み"として考えているけど、上記座標取得方法なら不要になる、が一応保持しておく、念のため。


                    最終的に、カラム名とカラム座標値のMatrixをファイルに格納する(一旦ね)。
        ===#
        table_df = DBDataController.getTableList("dataframe")

        #===
            rejecting 'master' tables. master tables names 'master' in their own table name.
            here is important .( ｰ`дｰ´)ｷﾘｯ
        ===#
        filter!(:tablename=>x->!contains(x,"master"),table_df)
        
        #===
            Tips:
            by Ph. Kaminski
                this is able to do because 'table_df.tablename' is unique.
                refer d("ftest"=>1 "ftest2=>4...) to get the index, then put them into combination.
        ===#
        d = Dict(table_df.tablename .=> axes(table_df, 1))
        sql_df.combination = [getindex.(Ref(d), x) for x in sql_df.combination]

        # normalize all access number by the biggest 'access_number'
        sql_df.access_number = sql_df.access_number / maximum(sql_df.access_number)

        if debugflg
            @info JSON.json(Dict("Jetelina" => copy.(eachrow(sql_df))))
        end
        #===
            Tips:
                use plain JSON module insted of Genie.Renderer.Json module, because Genie's module put http protocol header(ex. HTTP 200) in the output.
                the conditional panel will call this as a plain file in being called RestAPI. 
        ===#
        open(sqljsonfile, "w") do f
            println(f, JSON.json(Dict("Jetelina" => copy.(eachrow(sql_df)))))
        end
    end

    """
    function  extractColumnsFromSql(s::String)

        pick up columns data from 's'.

    # Arguments
    -`s::String`: expected sql sentence. ex. select .... from .....
    - return: tuple   column strngs, select or from strings
    """
    function extractColumnsFromSql(s::String)
        ad::String = ""
        cs::String = ""
        if contains(s,"select")
            ss = split(s,"select ")
            cs = string(ss[2])
            ad = "select"
            if contains(cs,"from")
                ss = split(cs," from")
                cs = string(ss[1])
                ad = string("from",ss[2])
            end
        end

        return cs, ad
    end

    #=== create view方式になったのでこの関数は使わない
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
            experimentalCreateView(target_data)
        end
    end
    ===#
    """
    function experimentalCreateView(df::DataFrame)

        create view tables for test and execute all sql sentences for analyzing.

    # Arguments
    - `df::DataFrame`: target dataframe data
    """
    function experimentalCreateView(df::DataFrame)

        #===
            Tips:
                1.ready test db
                2.copy all table in running to test db, but not all line
                3.execute 'create view' in order to sql sentence, the api are changed order by it
                4.execute all api in create view in 3 on test db, and compare with the latest data. then write them out to 'report file' for viewing condition panel
                5.do not forget to delete the test db after analyzing
        ===#

        #1
        table_df = creatTestDB()
        #2
        tableCopy(table_df)
        #3
        dict = createView(df)
        dict_apino_arr = []
        if 0<length(dict)
            for i in keys(dict)
                #===
                    Tips:
                        i->key, dict[i]->value
                        ex. i->js101, dict[i]->select ....
                ===#
                push!(dict_apino_arr,i)
            end
        end

        #===
            Tips:
                open JetelinaSQLListfile and call sql sentences.
                execute PgTestDBController.doSelect(sql) with the 'sql'.
                compare the experiment data(max,min,mean) with the latest data in Jetelina..file. ref: measureSqlPerformance()
                change table layout if its performance has been improved. this is the Jetelina!
        ===#

        #4
        TestDBController.measureSqlPerformance()
        #===
            Tips: Attention.
                compare the each api performance between JetelinaSqlPerformancefile(running db) and ..test(test db).
                each data(max/min/mean) are normalized by the max data.
                each data in test db are normalized by the real db max data.

                be a json file
                    be DataFrame Jeteli..file(①),Jeteli..file.test(②).
                    normalize each number of each api no by the max number of ①.
                    normalize each number of each api no of ② by the max number of ①.
                    put something mark on the target api no in ① and ②.

                then rely on js code in conditional panel after all.
        ===#
        sqlPerformanceFile_real = getFileNameFromConfigPath(JetelinaSqlPerformancefile)
        sqlPerformanceFile_test = getFileNameFromConfigPath(string(JetelinaSqlPerformancefile,".test"))

        df_real = CSV.read(sqlPerformanceFile_real,DataFrame)
        df_test = CSV.read(sqlPerformanceFile_test,DataFrame)

        if debugflg
            println("before normalize df_real", df_real)
            println("before normalize df_test", df_test)
        end
        #===
            Tips:
              df_real contains the real sql execution speed on the real db
              df_test contains the experimental sql exectution speed on the test db.

              here, define standard speed data due to df_real.
              then normalize both df_real and df_test data by this standard data for being able to compare the both speed data.

              Attention: std_max is due to minimum(). std_mean is calculated by sum() divide the row number of df_real.
        ===#
        std_max = minimum(df_real.max)
        std_min = maximum(df_real.min)
        std_mean = sum(df_real.mean) / size(df_real)[1]

        df_real.max  = df_real.max / std_max
        df_real.min  = df_real.min / std_min
        df_real.mean = df_real.mean / std_mean

        df_test.max  = df_test.max / std_max
        df_test.min  = df_test.min / std_min
        df_test.mean = df_test.mean / std_mean

        if debugflg
            println("after normalize df_real", df_real)
            println("std_max:", std_max, " std_min:", std_min, " std_mean:", std_mean )
            println("df_real.max:", df_real.max, " df_real.min:", df_real.min, " df_real.mean:", df_real.mean )
            println("after normalize df_test", df_test)
            println("df_test.max:", df_test.max, " df_test.min:", df_test.min, " df_test.mean:", df_test.mean )
        end

        sqlPerformanceFile_real_json = getFileNameFromLogPath(string(JetelinaSqlPerformancefile,".json"))
        sqlPerformanceFile_test_json = getFileNameFromLogPath(string(JetelinaSqlPerformancefile,".test.json"))
        improveApisFile = getFileNameFromLogPath(string(JetelinaImprApis))

        # delete impr.. file if it exists
        rm(improveApisFile, force=true)

        #===
            Tips:
                find each 'apino' in df_real/df_test exists in dict_apino_arr.
                capitalize the 'apino' if existed.
                this capitalized 'apino' will be highlighted on the graph in conditional panel by js program.
        ===#
        improve_apis = Dict()

        for i=1:length(dict_apino_arr)
            #===
                Tips:
                    'p' returns Vector{Int64} type.
                    using the index number with Int type should be p[1], because 'p' is Array type.
                    the row index of df_real/df_test are p[1]. hum, troublesome.^_^
            ===#
            p = findall( x->x==dict_apino_arr[i],df_real.apino)
            df_real[p[1],:apino] = uppercase(dict_apino_arr[i])
            df_test[p[1],:apino] = uppercase(dict_apino_arr[i])

            diff_speed = df_test[p[1],:mean] / df_real[p[1],:mean]

            if debugflg
                println("diff_speed:", dict_apino_arr[i], " -> ",diff_speed)
            end
            #===
                Tips:
                    propose 'do?' if sql execution speed were improved over 25%.
                    '25%' is provisionally.
            ===#
            if diff_speed<0.75
                improve_apis = (dict_apino_arr[i],diff_speed)
            end

        end
        
        open(sqlPerformanceFile_real_json, "w") do f
            println(f, JSON.json(Dict("Jetelina" => copy.(eachrow(df_real)))))
        end

        open(sqlPerformanceFile_test_json, "w") do f
            println(f, JSON.json(Dict("Jetelina" => copy.(eachrow(df_test)))))
        end

        if 0<length(improve_apis)
            open(improveApisFile, "w") do f
                println(f, JSON.json("Jetelina" => improve_apis))
            end    
        end

    end

    """
    function  createView(df::DataFrame)

        create view table from a sql sentence that has multi tables and hight use in the running db.

    # Arguments
    -`df::DataFrame`: DataFrames object. contains sql list.
    - return: Dict:  
        return: Dict() create viewしたことにより更新されたapinoとsql
    """
    function createView(df::DataFrame)
        # not only one target
        create_view_str = String[]
        newapilist = Dict()

        for i=1:nrow(df)
            viewtable = string(df.apino[i],"_view")
            targetsql = df.sql[i]

            #===
                Tips:
                    adding 'as' sentence for preventing happening 'Duplication column error'.😁めんどくせー
                        ex.
                            select ftest.name,ftest2.name,.....
                            ->
                            select ftest.name as ftest_name,ftest2.name as ftest2_name,.....

                extractColumnsFromSql() funciton returns as tuple,
                    [1]:column strings
                    [2]:'select' or strings after 'from' 

                at the same time, have to update the original api.
                colulmn name of creating view table is 'pp' below. Let's create it in the loop.
                api for creating view is going to update to the api file. may easy to handle later if it were Dict() type:'<api name>=><new sql>'.
            ===#
            columns_str = extractColumnsFromSql(targetsql)
            editedtargetsql = ""
            newapisql = ""
            if 0<length(columns_str[1])
                c = split(columns_str[1],',')
                for ii=1:length(c)
                    p = c[ii]
                    pp = replace(p,'.'=>'_')
                    c[ii] = """$p as $pp"""

                    if 0<length(editedtargetsql)
                        editedtargetsql = string(editedtargetsql,',',c[ii])
                        newapisql = string(newapisql,',',pp)
                    else
                        editedtargetsql = string("select",' ',c[ii])
                        newapisql = string("select",' ',pp)
                    end
                end
            end

            # expecting column_str[2] is the strings after 'from'. it does not may betrayed.
            targetsql = string(editedtargetsql,' ', columns_str[2])
            newapisql = string(newapisql," from ", viewtable)
            newapilist[df.apino[i]] = newapisql
            cvs = """create view $viewtable as $targetsql;"""
            push!(create_view_str,cvs)
        end

        tconn = TestDBController.open_connection()

        try
            for i=1:length(create_view_str)
                execute(tconn, create_view_str[i])

                # SQL update to JetelinaSQLListfile
                SQLSentenceManager.updateSqlList(newapilist)
            end
        catch err
            println(err)
            JetelinaLog.writetoLogfile("SQLAnalyzer.createView() error: $err")
        finally
            TestDBController.close_connection(tconn)

            return newapilist
        end
    end

    """
    function dropTestDB(conn)

        drop testdb. doubtfull. :-p

    # Arguments
    - `conn`: db connection object
    - return: 
    """
    function dropTestDB(conn)
        dbdrop = """drop database if exists $JetelinaTestDBname"""
        return PgDBController.execute(conn, dbdrop)
    end

    """
    function creatTestDB()

        create testdb by using running db(JetelinaDBname).
        
        only postgresql now. other db should be impremented later.
    """
    function creatTestDB()
        if JetelinaDBtype == "postgresql"
            conn = PgDBController.open_connection()

            try
                #===
                    Tips:
                        drop testdb before copying if it were.
                        postgresql does not have 'if exist' term in its 'create database' sentence.
                ===#
                dropTestDB(conn)

                dbcopy = """create database $JetelinaTestDBname"""
                execute(conn, dbcopy)

                #===
                    Tips:
                        acquire table list in the running db after successing create test database.
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
    function tableCopy(df::DataFrame)

        copy some data from the running db to the test db. the number of copy data are ordered in JetelinaTestDBDataLimitNumber.
        has taken 2 steps,
            1.create table
            2.copy data
        
        because some database does not have 'copy' command in it.
        the copy execution rely on _load_table!().

    # Arguments
    - `df::DataFrame`: DataFrame object.
    """
    function tableCopy(df::DataFrame)
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
    function _load_table!(conn, df::DataFrame, tablename::Vector{String}, columns=names(df))

        hopefully private function.

        ref. https://discourse.julialang.org/t/how-to-create-a-table-in-a-database-using-dataframes/75759/2

    # Arguments
    - `conn`: database connection object. it depend on database lib.
    - `df::DataFrame`:: dataframe object
    - `tablename::String`: ordered table name
    - `columns=..`: this is the optional value. to make table columns name as dataframe's one. 
    """
    function _load_table!(conn, df::DataFrame, tablename::String, columns=names(df))
        # acquire columns type to array
        column_type = nonmissingtype.(eltype.(eachcol(df)))
        # define DataFrame column
        column_type_string = Array{Union{Nothing,String}}(nothing, length(columns))
        # columns(id,name,sex,....) in creating table
        column_str = string()

        for i = 1:length(columns)
            #===
                Tips:
                    'column_type[i]' are 'DataType' due to eltype().
                    need to change the data type to 'String' to call getDataTypeInDataFrame().
            ===#
            column_type_string[i] = PgDataTypeList.getDataTypeInDataFrame(string(column_type[i]))
            column_str = string(column_str, " ", columns[i], " ", column_type_string[i], ",")
        end

        # reject the last ','
        column_str = chop(column_str)

        # build 'create table' sentence
        create_table_str = """create table if not exists $tablename ( $column_str );"""
        # build 'insert' sentence
        table_column_names = join(string.(columns), ", ")
        placeholders = join(("\$$num" for num in 1:length(columns)), ", ")
        data = select(df, columns)

        try
            execute(conn, "BEGIN;")
            # execute 'create table'
            execute(conn, create_table_str)
            # execute 'insert'. load!() may not be exported in LibPQ module.
            LibPQ.load!(
                data,
                conn,
                "INSERT INTO $tablename ($(table_column_names)) VALUES ($placeholders)"
            )

            execute(conn, "COMMIT;")
        catch err
            JetelinaLog.writetoLogfile("SQLAnalyzer._load_table!() error: $err")
            execute(conn, "ROLLBACK;")
        end
    end

    #===
    """
        tableAlter()

        指定されたカラムデータを、指定されたテーブルに移動するべく、alterでカラムを作成する
        ver1ではcreate viewにすることにしたので、このfunctionは使われていない

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
            JetelinaLog.writetoLogfile("SQLAnalyzer.tableAlter() error: $err")
        finally
            TestDBController.close_connection(tconn)
        end
    end
    ===#

end