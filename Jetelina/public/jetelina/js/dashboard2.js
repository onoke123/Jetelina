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
        /* チャットに表示するメッセージを js/scenario.jsから選択する
                i:scenarioの配列番号
                m:メッセージに追加する文字列
                p:選択されたチャットメッセージにmを繋げる位置　 b->before, その他->after
            */
        chooseMsg: function (i, m, p) {
            const n = Math.floor(Math.random() * scenario[i].length);
            let s = scenario[i][n];
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
        typing: function (i, m) {
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
        chkUResponse: function(n,s){
            for( let i=0; i<userresponse[n].length; i++ ){
                if( userresponse[n][i] == s.toLowerCase() ){
                    return true;
                }
            }
            
            return false;
        },

        /* ユーザが入力するチャットボックス(input tag)でenter keyが押されたときの処理 */
        onKeyDown: function () {
            let ut = this.userText;

            if (ut != null && 0 < ut.length) {
                ut = ut.trim();
                let m = "";
                if ( 0 < ut.length ) {
                    this.enterNumber++;
                    this.jetelinamessage = "";
                    this.yourchat = ut;

                    console.log("stage: ", this.stage);

                    switch (this.stage){
                        case 1:/*login*/
                            m = this.chooseMsg(2,"","");
                            this.stage = 2;
                            break;
                        case 2:/*success to login*/
                            let chunk = "";
                            if (ut.indexOf(" ") != -1) {
                                let p = ut.split(" ");
                                chunk = p[p.length - 1];
                            } else {
                                chunk = ut;
                            }
                            m = this.chooseMsg(4, chunk, "a");
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
    },
}).mount(
    "#jetelina"
); /* 実行タイミングの問題か、mount()はここでやるべきらしい */
