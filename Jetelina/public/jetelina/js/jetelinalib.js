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
            let row=1,col=1;
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
                                    str += `<button onclick="getColumn('${value}')">${value}</button><br><br>`;
                                } else if (t == 1) {
                                    // jetelina_delte_flgは表示対象外
                                    if (name != "jetelina_delete_flg") {
                                        str += `<div class="item" d=${value}><p>${targetTable}.${name}</p></div>`;
                                    }
                                }
                            });
                        } else {
                            /*
                              t=2即ちSQLリストはオブジェクト内に複数のデータがあり得て且つ、表示上は一行にしたいので
                              こんな感じ。
                            */
                            str += `<div class="sqllist"><p>${v.no}:${v.sql}</p></div>`;
                        }

                        let tagid = "";
                        if (t == 0) {
                            tagid = "#table_container";
                        } else if (t == 1) {
                            tagid = "#container .item_area";
                        } else if (t == 2) {
                            tagid = "#sqllist";
                        }

                        $(tagid).append(`${str}`);
                    }
                })
            }
        });

    }
}

let selectedItemsArr = [];
/*
    cleanUp

    droped items & columns of selecting table
*/
const cleanUp = () => {
    selectedItemsArr.splice(0);
    // clean up d&d items
    $(".item_area .item").remove();
    // clean up sql list
    $("#sqllist .list").remove();
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
            if (url == "/getapi") {
                //rendering sql list
                getdata(result, 2);
            }
        }).fail(function (result) {
        });
    } else {
        console.error("ajax url is not defined");
    }
}

const typingControll = (m) =>{
                //keyinputが続くとtyping()処理が重なるので、ここで一度クリアしておく
                if (typingTimeoutID != null) clearTimeout(typingTimeoutID);
                console.log("m:", m);
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
        console.log("result: ", result);

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

/*
    CSV file upload
*/
const fileupload = () => {
    let fd = new FormData($("#my_form").get(0));
    $("#upbtn").prop("disabled", true);

    const uploadFilename = $("input[type=file]").prop("files")[0].name;
    const tablename = uploadFilename.split(".")[0];
    console.log("filename 2 tablename: ", tablename);

    $.ajax({
        url: "/dofup",
        type: "post",
        data: fd,
        cache: false,
        contentType: false,
        processData: false,
        dataType: "json"
    }).done(function (result) {
        // clean up
        $("input[type=file]").val("");
        $("#upbtn").prop("disabled", false);
        getdata(result, 1);
        // talbe list に追加してfocusを当てる
        console.log("set table to select:", tablename);
        const addop = `<option value=${tablename}>${tablename}</option>`;
        $("#d_tablelist").prepend(addop);
        $("#d_tablelist").val(tablename);
    }).fail(function (result) {
        // something error happened
    });
}

/*
    指定されたtableのcolumnを取得する
*/
const getColumn = (tablename) => {
    if (0 < tablename.length || tablename != undefined) {
        //        let data = [];
        //        data.push( $.trim(tablename));

        let pd = {};
        pd["tablename"] = $.trim(tablename);
        let dd = JSON.stringify(pd);

        $.ajax({
            url: "/getcolumns",
            type: "post",
            data: dd,
            contentType: 'application/json',
            dataType: "json"
        }).done(function (result, textStatus, jqXHR) {
            console.log("getColumn result: ", result);
            // data parseに行く
            return getdata(result, 1);
        }).fail(function (result) {
        });
    } else {
        console.error("ajax url is not defined");
    }
}

const deleteThisTable = (tablename) => {
    if (0 < tablename.length || tablename != undefined) {
        //        let data = [];
        //        data.push( $.trim(tablename));

        let pd = {};
        pd["tablename"] = $.trim(tablename);
        let dd = JSON.stringify(pd);

        $.ajax({
            url: "/deletetable",
            type: "post",
            data: dd,
            contentType: 'application/json',
            dataType: "json"
        }).done(function (result, textStatus, jqXHR) {
        }).fail(function (result) {
        }).always(function (jqXHR, textStatus) {
            // table list 更新
            // clean up selectbox of the table list
            //$( "#d_tablelist .tables" ).remove();


            // clean up d&d items
            //            $(".item_area .item").remove();
            cleanUp();
            // select から当該tableを削除する
            $("#d_tablelist").children(`option[value=${tablename}]`).remove();
            //            getAjaxData("getalldbtable");
            // deleteボタンを非表示にする
            $("#table_delete").hide();
        });
    } else {
        console.error("ajax url is not defined");
    }
}

/* チャットに表示するメッセージを js/scenario.jsから選択する
        i:scenarioの配列番号
        m:メッセージに追加する文字列
        p:選択されたチャットメッセージにmを繋げる位置　 b->before, その他->after
    */
const chooseMsg = (i, m, p) => {
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
const chatKeyDown = () => {
    /* userTextはユーザのチャット入力文字列 */
    let ut = $("#jetelina_panel [name='chat_input']").val();

    if (debug) console.log("ut: ", ut);

    if (ut != null && 0 < ut.length) {
        ut = ut.trim();
        let m = "";
        /* ユーザのチャット入力文字列がある時だけ処理を実行する　*/
        if (0 < ut.length) {
            enterNumber++;
            $("#jetelina_panel [name='jetelina_tell']").text("");
            $("#jetelina_panel [name='chat_input']").val("");
            $("#jetelina_panel [name='your_tell']").text(ut);

            if (debug) console.info("stage: ", stage, " ", ut);

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

                    if (ut.indexOf('func') != -1) {
                        stage = 'into_function_panel';
                    } else if (ut.indexOf('cond') != -1) {
                        stage = 'into_condition_panel';
                    }

                    if (stage == 'into_function_panel' || stage == 'into_condition_panel') {
                        const panelTop = window.innerHeight - 110;
                        $("#jetelina_panel").animate({
                            height: "70px",
                            top: `${panelTop}px`,
                            left: "210px"
                        }, animateDuration);
                    }

                    break;
                case 'into_function_panel':/* into function panel */
                    m = chooseMsg('6func_in', "", "");
                    if (ut.indexOf('yes') != -1) {
                        if(debug) console.log("start function panel please");
                        $("#condition_panel").hide();
                        $("#function_panel").show().animate({
                            width: "1000px",
                            height: "800px",
                            top: "10%",
                            left: "10%"
                        }, animateDuration);

                        stage = "function_panel";
                    }


                    break;
                case 'function_panel':/* function panel */
                    m = chooseMsg('6func', "", "");

                    break;
                case 'into_condition_panel':/* into condition panel */
                    m = chooseMsg('6cond_in', "", "");
                    if (ut.indexOf('yes') != -1) {
                        $("#function_panel").hide();
                        $("#condition_panel").show();
                    }
                    break;
                default:/*before login*/
                    if (chkUResponse(0, ut)) {
                        // greeting
                        m = chooseMsg(1, "", "");
                        stage = 1;/* into the login stage */
                    } else {
                        m = chooseMsg(3, "", "");
                    }
            }

            if (0 < enterNumber) {
                $("#jetelina_panel [name='jetelina_tell']").val("");
                enterNumber = 0;
            }

            typingControll(m);
            //keyinputが続くとtyping()処理が重なるので、ここで一度クリアしておく
//            if (typingTimeoutID != null) clearTimeout(typingTimeoutID);
//            typing(0, m);
        }
    } else {
        $("#jetelina_panel [name='chat_input']").val("");
        enterNumber = 0;
    }
}