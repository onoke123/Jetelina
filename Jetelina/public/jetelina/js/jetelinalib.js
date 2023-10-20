/**
    JS library for Jetelina common library
    @author Ono Keiji
    @version 1.0

    This js lib works with dashboard.js, functionpanel.js and conditionpanel.js.
    

    Functions list:
      getdata(o, t) resolve the json object into each data
      getAjaxData(url) general purpose ajax get call function 汎用的なajax getコール関数
      postAjaxData(url,data) general purpose ajax post call function 汎用的なajax postコール関数
      typingControll(m) typing character controller
      authAjax(posturl, chunk, scenarioNumber) Authentication ajax call
      chooseMsg(i,m,p) select a message to show in chat box from js/senario.js チャットに表示するメッセージを js/scenario.jsから選択する
      typing(i,m) show a chat message alike typing style チャットメッセージをタイピング風に表示する
      chkUResponse(n, s) check if the user input message is what is expected in userresponse[] ユーザレスポンスがuserresponse[]に期待されたものであるかチェックする
      chatKeyDown(cmd) behavior of hitting enter key in the chat box by user ユーザが入力するチャットボックス(input tag)でenter keyが押されたときの処理
      openingMessage() Initial chat opening message
      burabura() idling message in the initial screen 初期画面でログイン前に入力待ちの時にブラブラしている感じ
      logoutChk(s) chech the user's intention is to be logout
      logout() logout
      getPreferentPropertie(p) get prior object if there were   優先オブジェクト preferentのプロパティがあれば返す
      cleanupItems4Switching() clear screen in activeItem class when switching table list/api list     table list/api list 表示切り替えに伴い、activeItem Classなんかをクリアする
      cleanupContainers() clear screen in the detail zone showing when switching table list/api list     table list/api list 表示切り替えに伴い、詳細画面をクリアする
      instractionMode(s) confirmation in adding a new scenario        Jetelinaのscenario追加確認 
      commandlistShow(s) show/hide the command list panel
      inScenarioChk(s,sc) check if user input string is in the ordered scenario
*/
/**
    @function getdata
    @param {object} o mostry json data
    @param {integer} t 0->db table list, 1->table columns list or csv file columns 2-> sql list

    resolve the json object into each data
*/
const getdata = (o, t) => {
    if (o != null) {
        Object.keys(o).forEach(function (key) {
            /*
                最初にこのカラムのtable nameを取得する
                table list表示のとき(t=0)は'undefined'になるだけ
            */
            let targetTable = o["tablename"];

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
                                    // column list. jetelina_delete_flgは表示対象外
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
                            str += `<span class="api">${v.apino}</span>`;
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
/**
 * 
 * @function getAjaxData
 * @param {string} url
 * 
 * general purpose ajax get call function. Execute the ordered url.
 */
const getAjaxData = (url) => {
    if (0 < url.length || url != undefined) {
        if (!url.startsWith("/")) url = "/" + url;

        $.ajax({
            url: url,
            type: "GET",
            data: "",
            dataType: "json"
        }).done(function (result, textStatus, jqXHR) {
            // go data parse
            const dataurls = scenario['analyzed-data-collect-url'];
            if (inScenarioChk(url, 'analyzed-data-collect-url')) {
                let type = "";
                if (url == dataurls[0]) {
                    // access vs combination
                    type = "ac";
                } else if (url == dataurls[1]) {
                    // real performance
                    type = "real";
                } else if (url == dataurls[2]) {
                    // test performance
                    type = "test";
                } else if (url == dataurls[4]) {
                    // sql access
                    type = "access";
                } else if (url == dataurls[3]) {
                    /*
                        Tips:
                            dataurls[3] is for checking existing Jetelina's suggestion.
                            resume below if the return were false,meaning no-exsit her one.
                            Once gettablecombivsaccessrelationdata is called, the data has already set in the graph.
                            This data does not change often, that why set 'isSuggestion' flag to use for the decision. 
                    */
                    if (!result) {
                        getAjaxData(dataurls[4]);
                    }else{
                        isSuggestion = true;
                        // relation access & combination
                        getAjaxData(dataurls[0]);
                        // simply sql speed
                        getAjaxData(dataurls[1]);
                        // check existing for improve file
                        getAjaxData(dataurls[2]);
                    }
                }
                /*
                    Tips:
                        drow graphic in condition panel.
                        this setGraphDta() function is defined in conditionpanel.js.
                        acVsCom is defined in dashboard.js as a global variable,this is expected true/false.
                */
                acVscom = setGraphData(result, type);

                if(isSuggestion){
                    /*
                        Tips:
                            isSuggestion = true, the meaning of the file existing is Jetelina wanna put inform you something 'improving suggestion'.
                            the below message is for it.
                    */
                    typingControll(chooseMsg("6cond-performance-improve", "", ""));                    
                }else{
                    typingControll(chooseMsg("success", "", ""));
                }      
            } else if (url == dataurls[3]) {
                /*
                    Tips:
                        dataurls[3] is for checking existing Jetelina's suggestion.
                        resume below if the return were true,meaning exsit her one.
                */
                if(result){
                    // relation access & combination
                    getAjaxData(dataurls[0]);
                    // simply sql speed
                    getAjaxData(dataurls[1]);
                    // sql speed on test db
                    getAjaxData(dataurls[2]);
                }

                /*
                    Tips:
                        dataurls[4] is for sql access count data.
                        this data always is executed.
                */
                getAjaxData(dataurls[4]);
            } else {
                // mainly, data for function panel
                getdata(result, 0);
                typingControll(chooseMsg("success", "", ""));
            }
        }).fail(function (result) {
            console.error("getAjaxData() fail");
            typingControll(chooseMsg("fail", "", ""));
        });
    } else {
        console.error("getAjaxData() ajax url is not defined");
        typingControll(chooseMsg("unknown-msg", "", ""));
    }
}
/**
 * @function postAjaxData
 * @param {string} url execute url
 * @param {object} data json style object 
 * 
 * general purpose ajax post call function. Execute the ordered url with the object.
 */
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
            const posturls = scenario['function-post-url'];
            if (url == posturls[0]) {
                //rendering api list
                preferent.apilist = result;
                getdata(result, 2);
            } else if (url == posturls[1]) {
                // nothing do
            }

            typingControll(chooseMsg("success", "", ""));
        }).fail(function (result) {
            console.error("postAjaxData() fail");
            typingControll(chooseMsg("fail", "", ""));
        });
    } else {
        console.error("postAjaxData() ajax url is not defined");
        typingControll(chooseMsg("unknown-msg", "", ""));
    }
}
/**
 * @function typingControll
 * @param {string} m   showing message in the chat box
 * 
 * typing character controller
 */
const typingControll = (m) => {
    /*
      Tips:
        clear once for priventing duplication.
        and clearing the text in Jetelina's chat box as well.
    */
    if (typingTimeoutID != null){
        clearTimeout(typingTimeoutID);
        $("#jetelina_panel [name='jetelina_tell']").text("");
    }

    if (debug) console.info("typingControll() m:", m);

    typing(0, m);

}
/**
 * @function authAjax
 * @param {string} posturl  execute url 
 * @param {string} chunk    post data as json style
 * @param {string} scenarioNumber  showing message after executing
 * 
 * Authentication ajax call
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
        if (debug) console.info("authAjax() result: ", result);

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
            });
        }
    });
}
/**
 * @function chooseMsg
 * @param {string} i  array number of the scenario message 
 * @param {string} m  adding string to the defined message
 * @param {string} p  position number of adding 'm' to the message  b->before, else->after
 * @returns {string}  displays message in the chat box
 * 
 * select a message to show in chat box from js/senario.js 
 */
const chooseMsg = (i, m, p) => {
    if (debug) console.info("chooseMsg() scenario number: ", i);

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
/**
 * @function typing
 * @param {integer} i  the next character number 
 * @param {string} m  entire message to show
 * @returns nothing if 'm' is empty
 * 
 * show a chat message alike typing style 
 */
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
/**
 * @function chkUResponse
 * @param {string} n  scenario array index number 
 * @param {string} s  user input character
 * @returns {boolean}  true -> as expected  false -> unexpected user response
 * 
 * check if the user input message is what is expected in userresponse[] 
 */
const chkUResponse = (n, s) => {
    if (userresponse[n].includes(s)) {
        return true;
    }

    return false;
}

let enterNumber = 0;
/**
 * function chatKeyDown
 * @param {string} cmd 
 * 
 * behavior of hitting enter key in the chat box by user
 */
const chatKeyDown = (cmd) => {
    /* ut is the input character by user */
    let ut;
    if (cmd == null) {
        ut = $("#jetelina_panel [name='chat_input']").val().toLowerCase();
    } else {
        ut = cmd.toLowerCase();
    }

    let logoutflg = false;

    if (debug) console.info("chatKeyDown() ut: ", ut);

    if (ut != null && 0 < ut.length) {
        ut = $.trim(ut.toLowerCase());
        let m = "";
        /* do it only if there were a input character by user */
        if (0 < ut.length) {
            enterNumber++;
            $("#jetelina_panel [name='jetelina_tell']").text("");
            $("#jetelina_panel [name='chat_input']").val("");
            $("#jetelina_panel [name='your_tell']").text(ut);

            if (debug) console.info("chatKeyDown() stage: ", stage);

            // logout
            if (logoutChk(ut)) {
                logout();
                m = chooseMsg('afterlogout', "", "");
                logoutflg = true;
            }

            // check ordered the command list
            commandlistShow(ut);

            // check the instraction mode that is teaching 'words' to Jetelina or not
            instractionMode(ut);

            /*
                switch 1:between 'before login' and 'at login'
                       login:at login
                       login_success: after login
                       chose_func_or_cond: the stage after 'login_success'
                       func: the stage into function panel
                       cond: the stage into condition panel
                       default:before login
            */
            switch (stage) {
                case 1:
                    if (!chkUResponse(1, ut)) {
                        m = chooseMsg(2, "", "");
                        stage = 'login';
                    } else {
                        /* say 'nice' if a user said 'fine' */
                        m = chooseMsg('1a', "", "");
                    }

                    break;
                case 'login':
                    let chunk = "";
                    scenarioNumber = 4;

                    if (ut.indexOf(" ") != -1) {
                        let p = ut.split(" ");
                        chunk = p[p.length - 1];
                    } else {
                        chunk = ut;
                    }

                    authAjax('/chkacount', chunk, scenarioNumber);
                    m = 'ignore';
                    break;
                case 'login_success':
                    m = chooseMsg(6, "", "");
                    stage = 'chose_func_or_cond';
                    break;
                case 'chose_func_or_cond':
                    let panel;

                    /*
                    if (ut.indexOf('func') != -1) {
                        panel = 'func';
                    } else if (ut.indexOf('cond') != -1) {
                        panel = 'cond';
                    }
                    */

                    if(inScenarioChk(ut,"function_panel")){
                        panel = 'func';
                    }else if(inScenarioChk(ut,"condition_panel")){
                        panel = 'cond';
                    }
                    // move Jetelina Chat panel
                    if (panel == 'func' || panel == 'cond') {
                        const panelTop = window.innerHeight - 110;
                        $("#jetelina_panel").animate({
                            height: "70px",
                            top: `${panelTop}px`,
                            left: "210px"
                        }, animateDuration);
                        m = chooseMsg('6a', "", "");
                    } else {
                        m = chooseMsg(3, "", "");
                    }
                    // show func panel
                    if (panel == 'func') {
                        stage = 'func';
                        $("#condition_panel").hide();
                        $("#function_panel").show().animate({
                            width: window.innerWidth * 0.8,
                            height: window.innerHeight * 0.8,
                            top: "10%",
                            left: "10%"
                        }, animateDuration);

                        if (isVisibleColumns()) {
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
                                bottom: "5%",
                                left: "30%"
                            }, animateDuration);
                        }
                    } else if (panel == 'cond') {
                        stage = 'cond';
                        $("#function_panel").hide().animate({}, animateDuration);
                        $("#condition_panel").show().animate({
                            width: window.innerWidth * 0.8,
                            height: window.innerHeight * 0.8,
                            top: "10%",
                            left: "10%"
                        }, animateDuration);
                        const dataurls = scenario['analyzed-data-collect-url'];
                        /*
                            check for existing Jetelina's suggestion
                        */
                        getAjaxData(dataurls[3]);
                    }
                    break;
                case 'func':
                    // defined in functionpanel.js
                    m = functionPanelFunctions(ut);
                    break;
                case 'cond':
                    // defined in conditionpanel.js
                    m = conditionPanelFunctions(ut);
                    break;
                default:
                    if (ut == "reload") {
                        location.reload();
                    }

                    if (chkUResponse(0, ut)) {
                        // greeting
                        m = chooseMsg(1, "", "");
                        stage = 1;/* into the login stage */
                    } else {
                        if (!logoutflg) {
                            m = chooseMsg(3, "", "");
                        }
                    }

                    break;
            }

            if (0 < enterNumber) {
                $("#jetelina_panel [name='jetelina_tell']").val("");
                enterNumber = 0;
            }

            if (0 < m.length && m != 'ignore') {
                typingControll(m);
            } else if (m == null || m.length == 0) {
                // cannot understand what the user is typing
                typingControll(chooseMsg('unknown-msg', "", ""));
            }

            if (logoutflg) {
                const t = 10000;// switch to the opening screen after 10 sec
                setTimeout(function () {
                    $("#jetelina_panel [name='your_tell']").text("");
                    openingMessage();
                }, t);
            }
        }
    } else {
        $("#jetelina_panel [name='chat_input']").val("");
        enterNumber = 0;
    }

}
/**
 * @function openingMessage
 * 
 * Initial chat opening message
 */
const openingMessage = () => {
    const t = 10000;// into idling mode after 10 sec if nothing input into the chat box
    $("#jetelina_panel [name='jetelina_tell']").text("");
    typing(0, chooseMsg(0, "", ""));

    setTimeout(function () { burabura() }, t);
}
/**
 * @function burabura
 * 
 * idling message in the initial screen
 */
const burabura = () => {
    const t = 20000;// chage the idling message after 20 sec
    timerId = setInterval(function () {
        $("#jetelina_panel [name='jetelina_tell']").text("");
        typing(0, chooseMsg('bura', "", ""))
    }, t);
}
/**
 * @function logoutChk
 * @param {string} s  check the user input message is intend to logout or not 
 * @returns {boolean}  true -> intend to logout  false -> ignore this message
 * 
 * chech the user's intention is to be logout
 */
const logoutChk = (s) => {
//    return scenario['logout'].includes(s);
    return inScenarioChk(s,"logout");
}
/**
 * @function logout
 * 
 * logout
 */
const logout = () => {
    enterNumber = 0;
    stage = 0;
    isSuggestion = false;

    $("#jetelina_panel").animate({
        width: "400px",
        height: "100px",
        top: "40%",
        left: "40%"
    }, animateDuration);

    $("#function_panel").hide();
    $("#condition_panel").hide();
    $("#genelic_panel").hide();
    $("#plot").hide();
    $("#performance_real").hide();
    $("#performance_test").hide();
    $("#command_list").hide();

    // global variables initialize
    stage = 0;
    delete preferent;
    delete plesentaction;

    deleteSelectedItems();
    cleanUp("items");
    cleanUp("tables");
    cleanUp("apis");
}
/**
 * @function getPreferentPropertie
 * @param {string} p  string to point to a prior object 
 * @returns 'cmd' string or ''
 * 
 * get prior object if there were
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
/**
 * @function cleanupItems4Switching
 * 
 * clear screen in activeItem class when switching table list/api list
 */
const cleanupItems4Switching = () => {
    if (isVisibleTableContainer()) {
        $("#table_container span").removeClass("activeItem");
    } else if (isVisibleApiContainer()) {
        $("#api_container span").removeClass("activeItem");
        $("#container span").remove();
    }
}
/**
 * @function cleanupContainers
 * 
 * clear screen in the detail zone showing when switching table list/api list
 */
const cleanupContainers = () => {
    $("#container span,#columns span").remove();
}
/**
 * @function instractionMode
 * @param {string} s  new words for Jetelina scenario
 * 
 * confirmation in adding a new scenario.
 * 
 * Wanna to be 0nly for Jetelina administrator.
 */
const instractionMode = (s) => {
    if (s.indexOf("say:") != -1) {
        let data = `{"sayjetelina":"${s.split("say:")[1]}","arr":"${scenario_name}"}`;
        postAjaxData("/jetelinawords", data);
    }
}
/**
 * @function commandlistShow
 * @param {string} s  user input data
 * 
 * show/hide the command list panel
 * 
 */
const commandlistShow = (s) => {
    if( inScenarioChk(s,"command_list") ){
        $("#command_list").show().animate({
            width: window.innerWidth * 0.8,
            height: window.innerHeight * 0.8,
            top: "10%",
            left: "10%"
        }, animateDuration);
    }else{
        $("#command_list").hide();
    }
}
/**
 * @function inScenarioChk
 * @param {string} s  user input data
 * @param {string} sc scenario data array name 
 * @returns {boolean}  true -> in the list, false -> no
 * 
 * check if user input string is in the ordered scenario
 * 
 */
const inScenarioChk = (s,sc) =>{
    const order = scenario[`${sc}`];
    let ret=false;
    for(key in order){
        if (s.indexOf(order[key]) != -1) {
            ret = true;
        }
    }

    return ret;
}