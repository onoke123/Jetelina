const { createApp } = Vue;

const app = createApp({
    data() {
        return {
            enterNumber: 0 /* enter keyを押した回数 */,
            jetelinamessage: "" /* ユーザに表示するチャットメッセージ */,
            yourchat: "" /* ユーザが入力したチャットメッセージ text*/,
            userText: "" /* ユーザが入力したチャットメッセージ input*/,
            /* 現状の作業ステージ
                     0:ログイン前
                     1:ログイン直後
            */
            stage: 0,
            isTelling: true,
            isTopView: false,
        };
    },
    mounted() {
        /* 全体が読み込まれるのを待って実行 */
        window.onload = () => {
            /* input tagにフォーカスを当てる */
            this.$refs.userInput.focus();
            /* 最初のチャットメッセージを表示する
               大体が"Hi"で始める
            */
            this.typing(0, this.chooseMsg(0, "", ""));
        };
    },
    methods: {
        /* true:debug mode false:real mode */
        debug(){
            return true;
        },

        /* チャットに表示するメッセージを js/scenario.jsから選択する
                i:scenarioの配列番号
                m:メッセージに追加する文字列
                p:選択されたチャットメッセージにmを繋げる位置　 b->before, その他->after
            */
        chooseMsg(i, m, p) {
            const n = Math.floor(Math.random() * scenario[i].length);
            let s = scenario[`${i}`][n];
            if (0 < m.length) {
                if (p == "b") {
                    s = `${m} ${s}`;
                } else {
                    s = `${s} ${m}`;
                }
            }

            return s;
        },

        /* チャットメッセージをタイピング風に表示する
                i:次に表示する文字番号
                m:表示する文字列
            */
        typing(i, m) {
            const t = 100; /* typing delay time */
            let ii = i;
            if (m != null && i < m.length) {
                ii++;
                this.jetelinamessage = this.jetelinamessage + m[i];
            } else {
                return;
            }

            setTimeout(this.typing, t, ii, m);
        },

        /* ユーザレスポンスがuserresponse[]に期待されたものであるかチェックする
            true: 期待通り
            false:　意外な答え
        */
        chkUResponse(n,s){
                if( userresponse[n].includes(s) ){
                return true;
            }
            
            return false;
        },

        /* ユーザが入力するチャットボックス(input tag)でenter keyが押されたときの処理 */
        onKeyDown() {
            /* userTextはユーザのチャット入力文字列 */
            let ut = this.userText;

            if (ut != null && 0 < ut.length) {
                ut = ut.trim();
                let m = "";
                /* ユーザのチャット入力文字列がある時だけ処理を実行する　*/
                if ( 0 < ut.length ) {
                    this.enterNumber++;
                    this.jetelinamessage = "";
                    this.yourchat = ut;

                    console.info("stage: ", this.stage, " ", ut );

                    switch (this.stage){
                        case 1:/*login時のやりとり*/
                            if( !this.chkUResponse(1, ut ) ){
                                m = this.chooseMsg(2,"","");
                                this.stage = 'login';
                            }else{
                                /* 'fine'とか言われたら気持ちよく返そう */
                                m = this.chooseMsg('1a',"","");
                            }
                            break;
                        case 'login':/*login処理結果のやりとり*/
                            let chunk = "";
                            this.scenarioNumber = 4;

                            if (ut.indexOf(" ") != -1) {
                                let p = ut.split(" ");
                                chunk = p[p.length - 1];
                            } else {
                                chunk = ut;
                            }

                            this.ajaxpost( '/chkacount', chunk, this.scenarioNumber );
                            break;
                        case 'login_success':/* after login */
                        m = this.chooseMsg(6, "","");

                            if ( ut.indexOf('csv') != -1 ){
                                this.stage = 'csv';
                            }else if( ut.indexOf( 'api' ) != -1 ){
                                this.stage = 'api';
                            }
                            break;
                        case 'csv':/* csv */
                            m = this.chooseMsg('6csv', "","");
                            if( ut.indexOf('yes') != -1 ){
                                console.log("start csv menu please");
                                this.isTopView = true;
                            }
                            break;
                        case 'api':/* api */
                            m = this.chooseMsg('6api', "","");
                            break;
                        default:/*before login*/
                            if( this.chkUResponse(0,ut) ){
                                // greeting
                                m = this.chooseMsg(1, "","");
                                this.stage = 1;/* into the login stage */
                            }else{
                                m = this.chooseMsg(3, "","");
                            }
                    }

                    if( 0<this.enterNumber ){
                        this.userText = "";
                        this.enterNumber = 0;
                    }

                    this.typing(0, m);
                }
            } else {
                this.$refs["userInput"].value = "";
                this.enterNumber = 0;
            }
        },

        ajaxpost: function( posturl, chunk, scenarioNumber ){
            const un = JSON.stringify({username:`${chunk}`});
            const customConfig = {
                headers: {
                'Content-Type': 'application/json'
                }
            };

            axios.post(
                posturl, un, customConfig 
                ).then(function(result){
                    if( app.debug ) console.log("result: ", result.data, result.data.Jetelina, result.data.Jetelina.length);

                    const o = result.data.Jetelina;
                    app.scenarioNumber = 4;
                    if( o.length == 1 ){
                        //ユーザが特定できた
                        const oo = o[0];
                        Object.keys(oo).forEach(function (key) {
                            
                            if( app.debug ) console.log("key:", key, oo[key]);
                            
                            if( oo['sex'] == "m" ){
                                m = "Mr. ";
                            }else{
                                m = "Ms. ";
                            }

                            m += o[0]['firstname'];
                            app.scenarioNumber = 5;
                            app.stage = 'login_success';
                        });
                    }else if( 1<o.length ){
                        //候補が複数いる
                        m = "please tell me more detail.";
                    }else{
                        //候補がいない
                        m = "you are not registered, try again.";
                    }

                    m = app.chooseMsg(app.scenarioNumber, m, "a");
                    app.typing(0, m);
                });

        }
    },
}).mount(
    "#jetelina"
); /* 実行タイミングの問題か、mount()はここでやるべきらしい */
