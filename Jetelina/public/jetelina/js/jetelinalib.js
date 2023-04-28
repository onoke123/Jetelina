/*
    引数に渡されたオブジェクトを分解取得する。
    @o: object
    @t: type  0->db table list, 1->table columns list or csv file columns 2-> sql list
*/
const getdata = (o, t) => {
    if (o != null) {
        Object.keys(o).forEach(function (key) {
            /*
                最初にこのカラムのtable nameを取得する
                table list表示のとき(t=0)は'undefined'になるだけ
            */
            const targetTable = o["tablename"];

            //’Jetelina’のvalueはオブジェクトになっているからこうしている  name=>key value=>o[key]
            let row = 1, col = 1;
            if (key == "Jetelina" && o[key].length > 0) {
                $.each(o[key], function (k, v) {
                    if (v != null) {
                        let str = "";
                        if (t < 2) {
                            /*
                              t=0/1即ちtableリストとカラムリストは単純オブジェクトなので、以下のループで
                              データを取得してリスト表示にする。
                           */
                            $.each(v, function (name, value) {
                                if (t == 0) {
                                    // table list
                                    str += `<span class="table">${value}</span>`;
                                } else if (t == 1) {
                                    // column list. jetelina_delte_flgは表示対象外
                                    if (name != "jetelina_delete_flg") {
                                        str += `<span class="item" d=${value}><p>${targetTable}.${name}</p></span>`;
                                    }
                                }
                            });
                        } else {
                            /*
                              t=2即ちSQLリストはオブジェクト内に複数のデータがあり得て且つ、表示上は一行にしたいので
                              こんな感じ。
                            */
                            // api list
                            str += `<span class="api">${v.no}</span>`;
                        }

                        let tagid = "";
                        if (t == 0) {
                            tagid = "#table_container";
                        } else if (t == 1) {
                            //                            tagid = "#container .item_area";
                            tagid = "#columns .item_area";
                        } else if (t == 2) {
                            tagid = "#api_container";
                            //                            tagid = "#sqllist";
                        }

                        $(tagid).append(`${str}`);
                    }
                })
            }
        });

    }
}

// 汎用的なajax getコール関数
const getAjaxData = (url) => {
    if (0 < url.length || url != undefined) {
        if (!url.startsWith("/")) url = "/" + url;

        $.ajax({
            url: url,
            type: "GET",
            data: "",
            dataType: "json"
        }).done(function (result, textStatus, jqXHR) {
            // data parseに行く
            getdata(result, 0);
        }).fail(function (result) {
        });
    } else {
        console.error("ajax url is not defined");
    }
}

// 汎用的なajax postコール関数
const postAjaxData = (url, data) => {
    if (0 < url.length || url != undefined) {
        if (!url.startsWith("/")) url = "/" + url;

        $.ajax({
            url: url,
            type: "post",
            contentType: 'application/json',
            data: data,
            dataType: "json"
        }).done(function (result, textStatus, jqXHR) {
            console.log("getAjaxData result: ", result);
            if (url == "/getapilist") {
                //rendering sql list
                console.log("getapilist: ", result);
                preferent.apilist = result;
                getdata(result, 2);
            } else if (url == "/jetelinawords") {
                // nothing do
            }
        }).fail(function (result) {
        });
    } else {
        console.error("ajax url is not defined");
    }
}

const typingControll = (m) => {
    //keyinputが続くとtyping()処理が重なるので、ここで一度クリアしておく
    if (typingTimeoutID != null) clearTimeout(typingTimeoutID);
    console.log("typingControll():", m);
    typing(0, m);

}
/*
    Authentication ajax call
*/
const authAjax = (posturl, chunk, scenarioNumber) => {
    const data = JSON.stringify({ username: `${chunk}` });

    $.ajax({
        url: posturl,
        type: "post",
        contentType: 'application/json',
        data: data,
        dataType: "json"
    }).done(function (result, textStatus, jqXHR) {
        if (debug) console.log("authAjax() result: ", result);

        scenarioNumber = 4;
        if (result != null) {
            const o = result;
            let m;
            //ユーザが特定できた
            Object.keys(o).forEach(function (key) {
                let sex, firstname;

                if (key == "Jetelina" && o[key].length == 1) {
                    $.each(o[key][0], function (k, v) {

                        if (k == "sex") {
                            if (v == "m") {
                                sex = "Mr. ";
                            } else {
                                sex = "Ms. ";
                            }
                        } else if (k == "firstname") {
                            firstname = v;
                        }
                    });

                    m = sex + firstname;
                    scenarioNumber = 5;
                    stage = 'login_success';
                } else if (1 < o[key].length) {
                    //候補が複数いる
                    m = "please tell me more detail.";
                    stage = 'login';
                } else {
                    //候補がいない
                    m = "you are not registered, try again.";
                    stage = 'login';
                }

                m = chooseMsg(scenarioNumber, m, "a");

                typingControll(m);
                //keyinputが続くとtyping()処理が重なるので、ここで一度クリアしておく
                //                if (typingTimeoutID != null) clearTimeout(typingTimeoutID);
                //                typing(0, m);
            });
        }
    });
}

/* チャットに表示するメッセージを js/scenario.jsから選択する
        i:scenarioの配列番号
        m:メッセージに追加する文字列
        p:選択されたチャットメッセージにmを繋げる位置　 b->before, その他->after
    */
const chooseMsg = (i, m, p) => {
    if (debug) console.log("scenario number: ", i);

    scenario_name = i;// scenario追加に備えて対象番号を控えておく

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
}
/* チャットメッセージをタイピング風に表示する
        i:次に表示する文字番号
        m:表示する文字列
*/
let typingTimeoutID;
const typing = (i, m) => {
    const t = 100; /* typing delay time */
    let ii = i;
    if (m != null && i < m.length) {
        ii++;
        let pm = $("#jetelina_panel [name='jetelina_tell']").text();
        $("#jetelina_panel [name='jetelina_tell']").text(pm + m[i]);
    } else {
        return;
    }

    typingTimeoutID = setTimeout(typing, t, ii, m);
}

/* ユーザレスポンスがuserresponse[]に期待されたものであるかチェックする
    userresponse[]はsenario.jsで定義されている
            true: 期待通り
            false:　意外な答え
*/
const chkUResponse = (n, s) => {
    if (userresponse[n].includes(s)) {
        return true;
    }

    return false;
}

let enterNumber = 0;
/* ユーザが入力するチャットボックス(input tag)でenter keyが押されたときの処理 */
const chatKeyDown = (cmd) => {
    /* userTextはユーザのチャット入力文字列 */
    let ut;
    if (cmd == null) {
        ut = $("#jetelina_panel [name='chat_input']").val().toLowerCase();
    } else {
        ut = cmd.toLowerCase();
    }

    let logoutflg = false;

    if (debug) console.log("ut: ", ut);

    if (ut != null && 0 < ut.length) {
        ut = ut.toLowerCase().trim();
        let m = "";
        /* ユーザのチャット入力文字列がある時だけ処理を実行する　*/
        if (0 < ut.length) {
            enterNumber++;
            $("#jetelina_panel [name='jetelina_tell']").text("");
            $("#jetelina_panel [name='chat_input']").val("");
            $("#jetelina_panel [name='your_tell']").text(ut);

            if (debug) console.info("stage: ", stage, " ", ut);

            // logout
            if (logoutChk(ut)) {
                logout();
                m = chooseMsg('afterlogout', "", "");
                logoutflg = true;
            }

            // Jetelinaに言葉を教えているかどうか調べる
            instractionMode(ut);

            /*
                switch 1:login時のやりとり
                       login:login処理結果のやりとり
                       login_success: after login
                       chose_func_or_cond: login_success後のstage
                       func: function panelのstage
                       cond: condition panelのstage
                       default:before login
            */
            switch (stage) {
                case 1:/*login時のやりとり*/
                    if (!chkUResponse(1, ut)) {
                        m = chooseMsg(2, "", "");
                        stage = 'login';
                    } else {
                        /* 'fine'とか言われたら気持ちよく返そう */
                        m = chooseMsg('1a', "", "");
                    }

                    break;
                case 'login':/*login処理結果のやりとり*/
                    let chunk = "";
                    scenarioNumber = 4;

                    if (ut.indexOf(" ") != -1) {
                        let p = ut.split(" ");
                        chunk = p[p.length - 1];
                    } else {
                        chunk = ut;
                    }

                    authAjax('/chkacount', chunk, scenarioNumber);
                    break;
                case 'login_success':/* after login */
                    m = chooseMsg(6, "", "");
                    stage = 'chose_func_or_cond';
                    break;
                case 'chose_func_or_cond':
                    let panel;

                    if (ut.indexOf('func') != -1) {
                        panel = 'func';
                    } else if (ut.indexOf('cond') != -1) {
                        panel = 'cond';
                    }

                    stage = panel;

                    //move Jetelina Chatpanel
                    if (panel == 'func' || panel == 'cond') {
                        const panelTop = window.innerHeight - 110;
                        $("#jetelina_panel").animate({
                            height: "70px",
                            top: `${panelTop}px`,
                            left: "210px"
                        }, animateDuration);
                        m = chooseMsg('6a', "", "");
                    } else {
                        m = chooseMsg('6b', "", "");
                    }
                    // show func panel
                    if (panel == 'func') {

                        $("#condition_panel").hide();
                        $("#function_panel").show().animate({
                            width: window.innerWidth * 0.8 /*"1000px"*/,
                            height: window.innerHeight * 0.8 /*"800px"*/,
                            top: "10%",
                            left: "10%"
                        }, animateDuration);

                        if ($("#columns").is(":visible")) {
                            $("#fileup").draggable().animate({
                                top: "4%",
                                left: "5%"
                            }, animateDuration);
                            $("#left_panel").draggable().animate({
                                top: "10%",
                                left: "5%"
                            }, animateDuration);
                            $("#columns").draggable().animate({
                                top: "10%",
                                left: "30%"
                            }, animateDuration);
                            $("#container").draggable().animate({
                                bottom: "5%" /*"10%"*/,
                                left: "30%"
                            }, animateDuration);
                        }
                    } else if (panel == 'cond') {
                        $("#function_panel").hide().animate({}, animateDuration);
                        $("#condition_panel").show().animate({
                            width: window.innerWidth * 0.8 /*"1000px"*/,
                            height: window.innerHeight * 0.8 /*"800px"*/,
                            top: "10%",
                            left: "10%"
                        }, animateDuration);;
                    }

                    break;
                case 'func':
                    // defined in functionpanel.js
                    functionPanelFunctions(ut, cmd);
                    break;
                case 'cond':
                    if (ut.indexOf('func') != -1) {
                        delete preferent;
                        delete presentaction;
                        stage = 'chose_func_or_cond';
                        chatKeyDown(ut);
                    }

                    break;
                default:/*before login*/
                    if (chkUResponse(0, ut)) {
                        // greeting
                        m = chooseMsg(1, "", "");
                        stage = 1;/* into the login stage */
                    } else {
                        if (!logoutflg) {
                            m = chooseMsg(3, "", "");
                        }
                    }
            }

            if (0 < enterNumber) {
                $("#jetelina_panel [name='jetelina_tell']").val("");
                enterNumber = 0;
            }

            if (0 < m.length) {
                typingControll(m);
            }
            //keyinputが続くとtyping()処理が重なるので、ここで一度クリアしておく
            //            if (typingTimeoutID != null) clearTimeout(typingTimeoutID);
            //            typing(0, m);
        }
    } else {
        $("#jetelina_panel [name='chat_input']").val("");
        enterNumber = 0;
    }
}
/*
    logout check
*/
const logoutChk = (s) => {
    return scenario['logout'].includes(s);
}
/*
   logout 
*/
const logout = () => {
    enterNumber = 0;
    stage = 0;

    $("#jetelina_panel").animate({
        width: "400px",
        height: "100px",
        top: "40%",
        left: "40%"
    }, animateDuration);

    $("#function_panel").hide();
    $("#condition_panel").hide();

    // global variables initialize
    stage = 0;
    delete preferent;
    delete plesentaction;
}
/*
    優先オブジェクト preferentのプロパティがあれば返す
*/
const getPreferentPropertie = (p) => {
    let c = "";

    switch (p) {
        case 'cmd':
            if (preferent.cmd != null && 0 < preferent.cmd.length) {
                c = preferent.cmd;
            }
            break;
        case 'droptable':// table drop target table name
            //すでにdrop tableが指定されているかもしれない
            if (preferent.droptable != null && 0 < preferent.droptable.length) {
                c = preferent.droptable;
            }
            break;
        default:
            break;
    }

    return c;
}
/*
    table list/api list表示切り替えに伴い、activeItem Classなんかをクリアする
*/
const cleanupItems4Switching = () => {
    if ($("#table_container").is(":visible")) {
        $("#table_container span").removeClass("activeItem");
    } else if ($("#api_container").is(":visible")) {
        $("#api_container span").removeClass("activeItem");
        $("#container span").remove();
    }
}
/*
   table list/api list表示切り替えに伴い、詳細画面をクリアする
*/
const cleanupContainers = () => {
    $("#container span,#columns span").remove();
}
/*
    Jetelinaのscenario追加確認
    俺だけの機能
*/
const instractionMode = (s) => {
    if (s.indexOf("say:") != -1) {
        let data = `{"sayjetelina":"${s.split("say:")[1]}","arr":"${scenario_name}"}`;
        postAjaxData("/jetelinawords", data);
        typingControll(chooseMsg("success", "", ""));
    }
}