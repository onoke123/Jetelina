const { createApp } = Vue;

const app = createApp({
    data() {
        return {
            enterNumber: 0 /* enter keyを押した回数 */,
            jetelinamessage: "" /* ユーザに表示するチャットメッセージ */,
            yourchat: "" /* ユーザが入力したチャットメッセージ text*/,
            userText: "" /* ユーザが入力したチャットメッセージ input*/,
            /* 現状の作業ステージ
                     0:ログイン前 */
            stage: 0,
        };
    },
    mounted() {
        /* 全体が読み込まれるのを待って実行 */
        window.onload = () => {
            /* input tagにフォーカスを当てる */
            this.$refs.userInput.focus();
            /* 最初のチャットメッセージを表示する　*/
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
            if (0 < m.legnth) {
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

        /* ユーザが入力するチャットボックス(input tag)でenter keyが押されたときの処理 */
        onKeyDown: function () {
            let ut = this.userText;

            if (ut != null && 0 < ut.length) {
                ut = ut.trim();
                if (0 < ut.length) {
                    this.enterNumber++;
                    this.jetelinamessage = "";
                    this.yourchat = ut;
                    let chunk = "";
                    let m = "";
                    if (0 < ut.length) {
                        if (ut.indexOf(" ") != -1) {
                            let p = ut.split(" ");
                            chunk = p[p.length - 1];
                        } else {
                            chunk = ut;
                        }
                    }

                    if (this.stage == 0) {
                        m = this.chooseMsg(1, "", "");
                        if (0 < chunk.length) {
                            m = this.chooseMsg(2, chunk, "b");
                        }
                    } else {
                        m = this.chooseMsg(2, "", "");
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
