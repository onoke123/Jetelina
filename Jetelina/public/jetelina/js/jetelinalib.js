/**
    JS library for Jetelina common library
    @author Ono Keiji
    @version 1.0

    This js lib works with dashboard.js, functionpanel.js and conditionpanel.js.
    

    Functions list:
      getScenarioFile(l) read scenario.js file from server order by 'l' is language
      checkResult(o) check the 'return' field in the object when post/get ajax failed
      getdata(o, t) resolve the json object into each data
      getAjaxData(url) general purpose ajax get call function 
      postAjaxData(url,data) general purpose ajax post call function 
      typingControll(m) typing character controller
      authAjax(chunk) Authentication ajax call
      chooseMsg(i,m,p) select a message to show in chat box from js/senario.js 
      typing(i,m) show a chat message alike typing style 
      chkUResponse(n, s) check if the user input message is what is expected in scenario[] or config[]
      chatKeyDown(cmd) behavior of hitting enter key in the chat box by user 
      openingMessage() Initial chat opening message
      burabura() idling message in the initial screen 
      logoutChk(s) chech the user's intention is to be logout
      logout() logout
      getPreferentPropertie(p) get prior object if there were
      instractionMode(s) confirmation in adding a new scenario
      showManualCommandList(s) show/hide manual and/or command list panel
      inScenarioChk(s,sc,type) check if user input string is in the ordered scenario
      countCandidates(s,sc,type) count config/scenario candidates
      checkNewCommer(s) check the login user is a newcommer or not.
      checkBeginner() check the login user is a beginner or not.
      isVisibleFunctionPanel() check the function panel is visible or not
      inVisibleConditionPanel() check the condition panel is visible or not
      isVisibleSomethingMsgPanel() checking "#something_msg" is visible or not
      showSomethingInputField(b) "#something_input_field" show or hide
      showSomethingMsgPanel(b) "#something_msg" show or hide
      isVisibleApiTestPanel() checking "#apitest" is visible or not
      showApiTestPanel(b) "#apitest" show or hide
      inCancelableCmdList(cmd) check the ordered command is in cancelableCmdList or not
      rejectCancelableCmdList(cmd) reject command from cancelableCmdList
      rejectSelectedItemsArr(item) reject selected item from selectedItemsArr
      checkBandA(o,p) check the target sting is effective or not in the array string.
*/
const JETELINACHATTELL = `${JETELINAPANEL} [name='jetelina_tell']`;
const SOMETHINGMSGPANEL = "#something_msg";
const SOMETHINGMSGPANELMSG = `${SOMETHINGMSGPANEL} [name='jetelina_message']`;
const CONTAINERNEWAPINO = `${CONTAINERPANEL} .newapino`;
const CHATBOXYOURTELL = `${JETELINAPANEL} [name='your_tell']`;
const SOMETHINGINPUTFIELD = "#something_input_field";
const SOMETHINGINPUT = `${SOMETHINGINPUTFIELD} input[name='something_input']`;
const SOMETHINGTEXT = `${SOMETHINGINPUTFIELD} text[name='something_text']`;
const FILEUP = "#fileup";
const TABLECONTAINER = "#table_container";
const APICONTAINER = "#api_container";
const GENELICPANEL = "#genelic_panel";
const APITESTPANEL = "#apitest";
const CONFIGCHANGE = "config-change";// command in cancelable command list 
const TABLEAPILISTOPEN = "table-api-open";// command in cancelable command list
const SELECTITEM = "select-item";// command in cancelable command list
const TABLEAPIDELETE = "table-api-delete";// command in cancelable command list
const FILESELECTOROPEN = "files-elector-open"; // command in cancelable command list
const LOCALPARAM = "login2jetelina"; // local strage parameter
const USETCOUNTMAX = getRandomNumber(4) + 1; // only use for the first login in checkNewCommer

//let enterNumber = 0;
let typingTimeoutID;

/**
 * 
 * @function getScenarioFile
 * @param {l}  language
 * 
 * read scenario.js file order by 'l'. 
 * 'l' is expected, for example 'spanish', 'german.... default is 'english'
 * 
 * Caution: does not work yet on  BBM 2023/11/23
 */
const getScenarioFile = (l) => {
    let scenariofile;

    switch (l) {
        case 'spanish':
            scenariofile = "spanish_scenario.js";
            break;
        default:
            scenariofile = "english_scenario.js";
            break;
    }

    let url = `jetelina/js/${scenariofile}`;

    $.ajax({
        url: url,
        type: "GET",
        dataType: "script",
    }).done(function (result, textStatus, jqXHR) {
    });
}
/**
 *    @function checkResult
 *    @param {object} o mostry json data
 *    @returns {boolean} true  -> object o is not null and it contains 'return=true'
 *                       false -> object o is null or it contains 'return=false' 
 * 
 *   check the 'return' field in the object when post/get ajax failed.
 *   this function is used for getting error messages.
 */
const checkResult = (o) => {
    let ret = true;
    const msglength = 500; // displayed string length. over 500 is cut out.
    const response = "responseJSON";// common json response data key name
    const errMsg = "errmsg"; // this is the protocol in jl file
    const errorStr = "error";// this is the protocol in jl file

    if (o != null) {
        /*
            Tips:
                remove 'jetelina_suggestion' class if it is.
                it does not need to confirm its existence.
        */
        $(SOMETHINGMSGPANELMSG).removeClass("jetelina_suggestion");
        if (!o.result) {
            let em = "";
            let errmsg;
            let error;
            if (o[response] != null) {
                errmsg = o[response][errMsg];
                error = o[response][errorStr];
            } else {
                errmsg = o.errmsg;
                error = o.error;
            }

            if (errmsg != null && 0 < errmsg.length) {
                if (msglength < errmsg.length) {
                    errmsg = errmsg.substr(0, msglength);
                }
                /*
                    Tips:
                        because "errmsg" is cordinated message
                */
                em = errmsg;
            } else if (error != null && 0 < error.length) {
                if (msglength < error.length) {
                    error = error.substr(0, msglength);
                }
                /*
                    Tips:
                        because "error" is raw error message
                */
                em = chooseMsg("common-ajax-error-msg", error, "a");
            }

            $(SOMETHINGMSGPANELMSG).text(em);
            showSomethingMsgPanel(true);

            ret = false;
        } else {
            $(SOMETHINGMSGPANELMSG).text("");
            showSomethingMsgPanel(false);
            /*
                Tips:
                    in the case of a configuration parameter is called, set null all for 
                    preventing its unexpected updating 
            */
            if (presentaction.config_name != null) {
                presentaction.config_name = null;
                presentaction.config_data = null;
            }
        }
    } else {
        ret = false;
    }

    return ret;
}
/**
 *  @function getdata
 *  @param {object} o mostry json data
 *  @param {integer} t 0->db table list
 *                     1->table columns list or csv file columns 
 *                     2->api(sql) list 
 *                     3->conifguration changing history
 *                     4->api(sql) test before registring 
 *  @returns {object} only in the case of t=3, conifguration changing history object
 *
 *  resolve the json object into each data
*/
const getdata = (o, t) => {
    if (o != null) {
        let configChangeHistoryStr = "";

        if (checkResult(o)) {// check the result for sure
            Object.keys(o).forEach(function (key) {
                /*
                    Tips:
                        get the table name of this column at first.
                        it is to be 'undefined' in the case of showing table list(t=0)
                */
                let targetTable = o["tablename"];
                /*
                    Tips:
                        because Jetelina's value is object.  name=>key value=>o[key]
                */
                let row = 1, col = 1;
                if (key == "Jetelina" && o[key].length > 0) {
                    $.each(o[key], function (k, v) {
                        if (v != null) {
                            let str = "";
                            if (t < 2) {
                                /*
                                    Tips:
                                        get data then show as the list in below loop as t=0/1(table list and column list) is simply object.
                               */
                                $.each(v, function (name, value) {
                                    /*
                                        Tips:
                                            in the case of value is url. ex. http://aaaa.com/  
                                                <- this last '/' is be interfered its rendering.
                                    */
                                    if ($.type(value) === "string") {
                                        if (value.endsWith("/")) {
                                            value = value.slice(0, -1);
                                        }
                                    }

                                    if (t == 0) {
                                        // table list
                                        str += `<span class="table">${value}</span>`;
                                    } else if (t == 1) {
                                        // jetelina_delete_flg should not show in the column list
                                        if (name != "jetelina_delete_flg") {
                                            /*
                                                Tips:
                                                    may ${name} is be long, because it is combined "<table name>_<column_name>" in uploading csv file.
                                                    in Ver.1, selected table name has same color, may it has unique color later, then these column has each color and 
                                                    could be shorten the display name, who knows. :)
                                            */
                                            str += `<span class="item" d=${value} colname=${targetTable}.${name}><p>${targetTable}.${name}</p></span>`;
                                        }
                                    }
                                });
                            } else if (t == 2) {
                                /*
                                    Tips:
                                        case t=2: wanna show it in one line
                                        this is the api list.
                                */
                                str += `<span class="api">${v.apino}</span>`;
                            } else if (t == 3) {
                                if (v.date != null) {
                                    configChangeHistoryStr += `[${v.date}] `;
                                }

                                if (v.previous != null) {
                                    $.each(v.previous, function (kk, vv) {
                                        configChangeHistoryStr += `${kk}=${vv} `;
                                    });

                                    configChangeHistoryStr += " → ";
                                }

                                if (v.latest != null) {
                                    $.each(v.latest, function (kk, vv) {
                                        configChangeHistoryStr += `${kk}=${vv} `;
                                    });

                                    configChangeHistoryStr += "<br>";
                                }
                            }

                            let tagid = "";
                            if (t == 0) {
                                tagid = TABLECONTAINER;
                            } else if (t == 1) {
                                tagid = `${COLUMNSPANEL} .item_area`;
                            } else if (t == 2) {
                                tagid = APICONTAINER;
                            }

                            $(tagid).append(`${str}`);
                        }
                    });

                    if (t == 4) {
                        // initialize the field before it's desplayed
                        $(`${APITESTPANEL} span`).remove();
                        showApiTestPanel(true);

                        let datanumber = o[key].length;
                        let jetelinamessage = o["message from Jetelina"];
                        let testmsg = "<span class='jetelina_suggestion'><p>Conguraturation, well done.</p></span>";
                        let aquisition_nubmer = `<span class='apitestresult'><p>-aquaiable data number is ${datanumber}</p></span>`;
                        let testdata = JSON.stringify(o[key]);
                        $(`${APITESTPANEL} [name='api-test-msg']`).append(`${testmsg}<br>${aquisition_nubmer}`);
                        $(`${APITESTPANEL} [name='api-test-data'`).append(`<span class='apitestresult'><p>-return JSON data are</p><p>${testdata}</p></span>`);
                        if (0 < jetelinamessage.length) {
                            $("#apitest [name='api-test-msg']").append(`<span class='apitestresult'><p>Attention: ${jetelinamessage}</p></span>`);
                        }
                    }
                }
            });

            if (t == 3) {
                $(SOMETHINGMSGPANEL).addClass("config_history");
                $(SOMETHINGMSGPANELMSG).addClass("config_history_text").append(configChangeHistoryStr);
                showSomethingMsgPanel(true);
            }
        }
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
            dataType: "json",
            xhr: function () {
                ret = $.ajaxSettings.xhr();
                inprogress = true;// in progress. for priventing accept a new command.
                typingControll(chooseMsg('inprogress-msg', "", ""));
                return ret;
            }
        }).done(function (result, textStatus, jqXHR) {
            // go data parse
            const dataurls = scenario['analyzed-data-collect-url'];

            if (url == dataurls[3]) {
                /*
                    Tips:
                        dataurls[3] is for checking existing Jetelina's suggestion.
                        resume below if the return were true,meaning exsit her one.
                */
                if (result) {
                    // set suggestion existing flag to display my message
                    isSuggestion = true;
                    // set my suggestion
                    $(SOMETHINGMSGPANELMSG).addClass("jetelina_suggestion");
                    $(SOMETHINGMSGPANELMSG).text(`${result.Jetelina.apino}:${result.Jetelina.suggestion}`);
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

            } else if (inScenarioChk(url, 'analyzed-data-collect-url')) {
                let type = "";
                if (url == dataurls[0]) {
                    // access vs combination
                    type = "ac";
                } else if (url == dataurls[1]) {
                    // real performance. execute sql on the DB. considering needs or not, 2023/11/25
                    type = "real";
                } else if (url == dataurls[2]) {
                    // test performance. execute sql on test DB
                    type = "test";
                } else if (url == dataurls[4]) {
                    // sql access
                    type = "access";
                }
                /*
                    Tips:
                        drow graphic in condition panel.
                        this setGraphDta() function is defined in conditionpanel.js.
                */
                let acVscom = setGraphData(result, type);

                if (isSuggestion) {
                    /*
                        Tips:
                            isSuggestion = true, the meaning of the file existing is Jetelina wanna put inform you something 'improving suggestion'.
                            the below message is for it.
                            but abandon any 'suggestion" in Ver.1
                    */
                    typingControll(chooseMsg("cond-performance-improve-msg", "", ""));
                } else {
                    typingControll(chooseMsg("success-msg", "", ""));
                }
            } else {
                const geturl = scenario['function-get-url'];
                if (url == geturl[0]) {
                    //rendering api list
                    preferent.apilist = result;
                    getdata(result, 2);
                    /*
                        Tips:
                            ②
                            in the case of calling to show the newest api in table list panel,
                            in fact it maybe called in chatKeyDonw() first (at ①), 
                            it has a process as showing api-list then pointing the newest one.
                            this process is executed by a chat word in chatKeyDown().
                            the newest api no is set in presentaction.orderapino at the early line of chatKeyDown(). 
                    */
                    if (isVisibleApiContainer() && presentaction.orderapino != null) {
                        let orderdapino = presentaction.orderapino;
                        presentaction.orderapino = null;
                        chatKeyDown(`open ${orderdapino}`);
                    }
                } else if (url == geturl[1]) {
                    // get db table list
                    getdata(result, 0);
                } else if (url == geturl[2]) {
                    // configuration change history
                    getdata(result, 3);
                }

                typingControll(chooseMsg("success-msg", "", ""));
            }
        }).fail(function (result) {
            checkResult(result);
            console.error("getAjaxData() fail");
            typingControll(chooseMsg("fail-msg", "", ""));
        }).always(function () {
            // release it for allowing to input new command in the chatbox 
            inprogress = false;
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
            dataType: "json",
            xhr: function () {
                ret = $.ajaxSettings.xhr();
                inprogress = true;// in progress. for priventing accept a new command.
                typingControll(chooseMsg('inprogress-msg', "", ""));
                return ret;
            }
        }).done(function (result, textStatus, jqXHR) {
            const posturls = scenario['function-post-url'];
            if (url == posturls[0]) {
                // userdata update
            } else if (url == posturls[1]) {
                // jetelinawords -> nothing do
            } else if (url == posturls[2]) {
                // get a configuration parameter, then show it in there
                let configMsg = "Oh oh, I do not know it, another one plz.";
                $.each(result, function (name, value) {
                    if (name != "result") {
                        presentaction.config_data = value;
                        configMsg = `${name} is '${value}' so far`;
                    }
                });

                $(SOMETHINGMSGPANELMSG).text(configMsg);
                showSomethingMsgPanel(true);
            } else if (url == posturls[3]) {
                // configuration parameter change success then cleanup the "#something_msg"
                presentaction.cmd = null;
                showSomethingInputField(false);
            }

            typingControll(chooseMsg("success-msg", "", ""));
        }).fail(function (result) {
            checkResult(result);
            console.error("postAjaxData() fail");
            typingControll(chooseMsg("fail-msg", "", ""));
        }).always(function () {
            // release it for allowing to input new command in the chatbox 
            inprogress = false;
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
    if (typingTimeoutID != null) {
        clearTimeout(typingTimeoutID);
        $(JETELINACHATTELL).text("");
    }

    typing(0, m);
}
/**
 * @function authAjax
 * @param {string} un    user account
 * 
 * Authentication ajax call
 */
const authAjax = (un) => {
    const data = JSON.stringify({ username: `${un}` });
    const posturl = scenario["function-post-url"][6];

    $.ajax({
        url: posturl,
        type: "post",
        contentType: 'application/json',
        data: data,
        dataType: "json",
        xhr: function () {
            ret = $.ajaxSettings.xhr();
            inprogress = true;// in progress. for priventing accept a new command.
            typingControll(chooseMsg('inprogress-msg', "", ""));
            return ret;
        }
    }).done(function (result, textStatus, jqXHR) {
        let scenarioNumber = "starting-4-msg";
        if (result != null) {
            const o = result;
            let m = "";
            // found user
            Object.keys(o).some(function (key) {
                if (key == "Jetelina" && o[key].length == 1) {
                    $.each(o[key][0], function (k, v) {
                        if (k == "user_id") {
                            loginuser.user_id = v;
                            localStorage[LOCALPARAM] = true;
                        } else if (k == "login") {
                            loginuser.login = v;
                        } else if (k == "firstname") {
                            loginuser.firstname = v;
                        } else if (k == "lastname") {
                            loginuser.lastname = v;
                            m = v;
                        } else if (k == "nickname") {
                            loginuser.nickname = v;
                        } else if (k == "logincount") {
                            loginuser.logincount = v;
                        } else if (k == "logindate") {
                            loginuser.lastlogin = v;
                        } else if (k == "user_level") {
                            loginuser.user_level = v;
                        } else if (k == "familiar_index") {
                            loginuser.familiar_index = v;
                        }
                    });

                    // nickname has a priority
                    if (loginuser.nickname != null) {
                        m = loginuser.nickname;
                    }
                    /*
                        Tips:
                            authentiaction count. this is the key to get auth in Jetelina.
                            Jetelina asks some questions in order to user info, ex. hobby, living....
                            these info are inquired to DB, then count up if it matched.
                            after around 1 to 4 counted up, the user has been authenticated, then
                            can move from 'login"success' to 'lets_do_something' stage.

                            loginuser and authcount are defined in dashboard.js as global.
                    */
                    loginuser.c = 0;
                    authcount = getRandomNumber(3) + 1;

                    scenarioNumber = "starting-5-msg";
                    stage = 'login_success';
                } else if (1 < o[key].length) {
                    // some candidates
                    scenarioNumber = "multi-candidates-msg";
                    stage = 'login';
                } else {
                    // no user
                    scenarioNumber = "not-registered-msg";
                    stage = 'login';
                }

                m = chooseMsg(scenarioNumber, m, "a");

                typingControll(m);
                return true;
            });
        }
    }).fail(function (result) {
        checkResult(result);
        // something error happened
        console.error("authAjax(): unexpected error");
        typingControll(chooseMsg("fail-msg", "", ""));
    }).always(function () {
        // release it for allowing to input new command in the chatbox 
        inprogress = false;
    });
}
/**
 * @function chooseMsg
 * @param {string} i  array number of the scenario message 
 * @param {string} m  adding string to the defined message
 * @param {string} p  position number of adding 'm' to the message  b->before, a->after, else->replace with {Q}
 * @returns {string}  displays message in the chat box
 * 
 * select a message to show in chat box from js/senario.js 
 */
const chooseMsg = (i, m, p) => {
    /*
        Tips:
            copy the array number of the scenario message 
            in order to add a new sentence.
            this adding is realized by using instractionMode(),
            but this function is just for a developer, basically.
    */
    scenario_name = i;
    let ret = "";
    if (scenario[i] != null && 0 < scenario[i].length) {
        const n = getRandomNumber(scenario[i].length);
        let s = scenario[`${i}`][n];
        if (0 < m.length) {
            if (p == "b") {
                s = `${m} ${s}`;
            } else if (p == "a") {
                s = `${s} ${m}`;
            } else {
                s = s.replaceAll("{Q}", m);
            }
        }

        ret = s;
    } else {
        console.info(`scenario -> ${i} is null`);
    }

    return ret;
}
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
        let pm = $(JETELINACHATTELL).text();
        $(JETELINACHATTELL).text(pm + m[i]);
    } else {
        return;
    }

    typingTimeoutID = setTimeout(typing, t, ii, m);
}
/**
 * @function chkUResponse
 * @param {string} n  scenario array index
 * @param {string} s  user input character
 * @returns {boolean}  true -> as expected  false -> unexpected user response
 * 
 * check if the user input message is what is expected in scenario[] or config[]
 * deprecated
 */
const chkUResponse = (n, s) => {
    /*
        Tips:
            privent to display the opening messages are dublicated.
            logouttimeId is set at logout process for returning to the inital screen in openingMessage().
    */
    if (logouttimerId) {
        clearTimeout(logouttimerId);
    }

    if ((scenario[n] != null && scenario[n].includes(s)) ||
        (config[n] != null && config[n].includes(s))) {
        return true;
    }

    return false;
}
/**
 * function chatKeyDown
 * @param {string} cmd  something ordered string. ex. user key input, scenario[] command .... etc 
 * 
 * behavior of hitting enter key in the chat box by user
 */
const chatKeyDown = (cmd) => {
    /* ut is the input character by user */
    let ut;
    let m = ""; // chatbox message string by Jetelina.

    if (cmd == null) {
        ut = $(JETELINACHATBOX).val().toLowerCase();
        ut = ut.replaceAll(',', ' ').replaceAll(':', ' ').replaceAll(';', ' ');
    } else {
        ut = cmd.toLowerCase();
    }

    let logoutflg = false;

    if (ut != null && 0 < ut.length) {
        ut = $.trim(ut.toLowerCase());
        /*
            Tips:
                After registring a new api, maybe called it to open.
                the opening command will be duplicated with table opening one, 
                therefore some conditions are there for judging them which one is. 
        */
        if ($(CONTAINERNEWAPINO).text() != null && 0 < $(CONTAINERNEWAPINO).text().length) {
            let newapinostr = $(CONTAINERNEWAPINO).text();
            let s = newapinostr.split("js");
            let apino = `js${s[s.length - 1]}`;
            if (ut.indexOf(apino) != -1) {
                presentaction.orderapino = apino;
                $(CONTAINERNEWAPINO).text("");
                /*
                    Tips:
                        ①
                        this execution of chatKeyDown() is series to getAjaxData().done() at ②
                */
                chatKeyDown(scenario["func-show-api-list-cmd"][0]);
            }
        }

        /* do it only if there were a input character by user */
        if (0 < ut.length) {
            //            enterNumber++;
            $(JETELINACHATTELL).text("");
            $(JETELINACHATBOX).val("");
            $(CHATBOXYOURTELL).text(ut);

            // logout
            if (logoutChk(ut)) {
                logout();
                m = chooseMsg('afterlogout-msg', "", "");
                logoutflg = true;
            }

            /*
                Tips:
                    may, 'm' already has been set in logout process.
            */
            if (m.length == 0) {
                // check ordered the command list
                m = showManualCommandList(ut);
            }

            // check the instraction mode that is teaching 'words' to Jetelina or not
            // but deprecated in Ver.1
            //instractionMode(ut);

            // check the error message panel hide or not
            if (inScenarioChk(ut, 'hide-something-msg-cmd')) {
                showSomethingMsgPanel(false);
            } else if (inScenarioChk(ut, 'show-something-msg-cmd')) {
                showSomethingMsgPanel(true);
            }

            /*
                switch 1:between 'before login' and 'at login'
                       login:at login
                       login_success: after login
                       lets_do_something: the stage after 'login_success'
                       default:before login
            */
            switch (stage) {
                case 1:
//                    if (!chkUResponse("greeting-1-cmd", ut)) {
/*
                    if(!inScenarioChk(ut,"greeting-1-cmd")){
                        m = chooseMsg("starting-2-msg", "", "");
                        stage = 'login';
                    } else {
                        / say 'nice' if a user said 'fine' /
                        m = chooseMsg('greeting-1a-msg', "", "");
                    }
*/

                    if(inScenarioChk(ut,'greeting-1-cmd')){
                        /* say 'nice' if a user said 'fine' */
                        m = chooseMsg('greeting-1a-msg', "", "");
                    }else if(inScenarioChk(ut,'greeting-2-cmd')){
                        /* reply something your mood if a uer asks you 'how about you' */
                        m = chooseMsg('greeting-2-msg', "", "");
                    }else{
                        /* lead to login with 'can I ask your name?' */
                        m = chooseMsg("starting-2-msg", "", "");
                        stage = 'login';
                    }

                    break;
                case 'login':
                    let chunk = "";

                    if (ut.indexOf(" ") != -1) {
                        let p = ut.split(" ");
                        chunk = p[p.length - 1];
                    } else {
                        chunk = ut;
                    }

                    authAjax(chunk);
                    m = IGNORE;
                    break;
                case 'login_success':
                    /*
                        Tips:
                            login user's info has been contained in loginuser object. see authAjax().
                            then take action in order to the user level.

                            ask "firstname", "lastname" if these are as same as "login", because this person is a newcommer.
                            show a guidance if "logincount" is less than 3, because this person is a beginner.
                            count up "user_level" if "logincount" is over 10, these attribute should send to server to update user's attribute.
                            and ask "nickname" if "familiar_level" is being 2. Jetelina can speak slang to a user who is "familiar_level" 3, in future.

                            anyhow give greeting order to "lastlogin".
                    */
                    /* the authentication process has been postphoned in BBM.  2023/11/24
                    let cnc = checkNewCommer(ut)
                    if (cnc[0]){
                        // set user's firstname,lastname and info
                        m = cnc[1];
                    }else if (checkBeginner()){
                        // count up user level
                    }else{
                        // true authentication process
                        loginuser.c++;
                    }
                    */
                    //                    if(authcount<loginuser.c){
                    m = chooseMsg("starting-6-msg", "", "");
                    stage = 'lets_do_something';
                    //                    }

                    break;
                case 'lets_do_something':
                    // chatbox moves to below
                    const panelTop = window.innerHeight - 110;
                    $(JETELINAPANEL).animate({
                        height: "70px",
                        top: `${panelTop}px`,
                        left: "210px"
                    }, ANIMATEDURATION);
                    /*
                        Tips:
                            if 'ut' is a command for driving configuration
                            localStrage checking is for secure reason
                    */
                    if (localStorage[LOCALPARAM] == "true") {
                        let multi = 0;
                        let multiscript = [];
                        // configuration parameter updating
                        if (inScenarioChk(ut, 'common-cancel-cmd') && inCancelableCmdList("CONFIGCHANGE")) {
                            preferent.cmd = null;
                            presentaction.config_name = null;
                            presentaction.config_data = null;
                            showSomethingInputField(false);
                            m = chooseMsg("cancel-msg", "", "");
                        }

                        if (presentaction.cmd != null && presentaction.cmd == "CONFIGCHANGE") {
                            if (presentaction.config_name != null) {
                                if ($(SOMETHINGINPUT).is(":visible")) {
                                    if (inScenarioChk(ut, 'common-post-cmd')) {
                                        let new_param = $(SOMETHINGINPUT).val();
                                        if (0 < new_param.length) {
                                            let data = `{"${presentaction.config_name}":"${new_param}"}`;
                                            postAjaxData(scenario["function-post-url"][3], data);
                                        } else {
                                            m = chooseMsg("config-update-alert-message","","");;
                                        }
                                    }
                                }
                            } else {
                                m = chooseMsg("config-update-error-message","","");
                            }
                        }

                        if (inScenarioChk(ut, "config-update-cmd")) {
                            presentaction.cmd = CONFIGCHANGE;
                            cancelableCmdList.push(presentaction.cmd);
                            if (presentaction.config_name != null && presentaction.config_data != null) {
                                showSomethingInputField(true);
                                m = chooseMsg("config-update-simple-message","","");
                            } else {
                                m = chooseMsg("config-update-plural-message","","");
                            }

                            for (zzz in config) {
                                /*
                                    Tips:
                                        in the case of vague inputing, may have multi candidates.
                                        but after showing them to user, may the right one inputing.
                                        the first 'if' is maybe not hit, but secondly inputing may kit it.
                                */
                                if (ut == zzz) {
                                    /*
                                        Tips:
                                            there is possilbility someting in multiscript[] yet.
                                            needs to clear it before pushing the right one.
                                    */
                                    multiscript = [];
                                    multiscript.push(zzz);
                                    break;
                                } else {
                                    if (inScenarioChk(ut, zzz, 'config')) {
                                        let r = countCandidates(ut, zzz, 'config');
                                        multi += r[0];
                                        multiscript.push(zzz);
                                    }
                                }
                            }

                            // right message should be displayed if there were any candidates.
                            let configMsg = "";
                            if (1 < multi) {
                                // pick candidates up
                                m = chooseMsg('multi-candidates-msg', "", "");// this 'm' is displayed in chatbox
                                let multimsg = chooseMsg("config-update-plural-candidates-message","","");// this 'multimsg' is displayed in SOMETHINGMSGPANEL
                                for (i = 0; i < multi; i++) {
                                    multimsg += `'${multiscript[i]}',`;
                                }

                                configMsg = multimsg;
                            } else {
                                // here you are, this,.... and so on
                                if (m.length == 0) {
                                    m = chooseMsg("starting-6a-msg", "", "");
                                }

                                if (multiscript[0] != null && multiscript[0] != undefined) {
                                    presentaction.config_name = multiscript[0];
                                    let data = `{"param":"${multiscript[0]}"}`;
                                    postAjaxData(scenario["function-post-url"][2], data);
                                }
                            }

                            if (0 < configMsg.length) {
                                $(SOMETHINGMSGPANELMSG).text(configMsg);
                                showSomethingMsgPanel(true);
                            }
                        } else if (inScenarioChk(ut, "get-config-change-history")) {
                            getAjaxData(scenario["function-get-url"][2]);
                        }
                    }

                    if (!$(SOMETHINGINPUT).is(":visible")) {
                        // if 'ut' is a command for driving function
                        m = functionPanelFunctions(ut);
                        if (m.length == 0 || m == IGNORE) {
                            // if 'ut' is a command for driving condition
                            m = conditionPanelFunctions(ut);
                        }
                    }

                    break;
                default:
                    if (ut == "reload") {
                        location.reload();
                    }

                    if (logouttimerId) {
                        clearTimeout(logouttimerId);
                    }
                

//                    if (chkUResponse("greeting-0r-cmd", ut)) {
                    if(inScenarioChk(ut,"greeting-0r-cmd")){
                        // greeting
                        m = chooseMsg("greeting-1-msg", "", "");
                        stage = 1;/* into the login stage */
                    } else {
                        if (!logoutflg && m.length == 0) {
                            m = chooseMsg("starting-3-msg", "", "");
                        }
                    }

                    break;
            }

            if (0 < m.length && m != IGNORE) {
                typingControll(m);
            } else if (m == IGNORE && stage != 'login') {
                typingControll(chooseMsg('waiting-next-msg', "", ""));
            } else if (m == null || m.length == 0) {
                // cannot understand what the user is typing
                typingControll(chooseMsg('unknown-msg', "", ""));
            }


            if (logoutflg) {
                const t = 10000;// switch to the opening screen after 10 sec
                logouttimerId = setTimeout(function () {
                    $(CHATBOXYOURTELL).text("");
                    openingMessage();
                }, t);
            }
        }
    } else {
        $(JETELINACHATBOX).val("");
    }

}
/**
 * @function openingMessage
 * 
 * Initial chat opening message
 */
const openingMessage = () => {
    const t = 10000;// into idling mode after 10 sec if nothing input into the chat box
    $(JETELINACHATTELL).text("");
    $(CHATBOXYOURTELL).text("");
    typingControll(chooseMsg("greeting-0-msg", "", ""));

    setTimeout(function () { burabura() }, t);
}
/**
 * @function burabura
 * 
 * idling message in the initial screen
 */
const burabura = () => {
    const t = 30000;// chage the idling message after 20 sec
    timerId = setInterval(function () {
        $(JETELINACHATTELL).text("");
        $(CHATBOXYOURTELL).text("");
        typingControll(chooseMsg('bura-msg', "", ""))
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
    let logoutcmds = scenario["logout-cmd"];
    for(key in logoutcmds){
        if( logoutcmds[key] == s ){
            return true;
        }
    }

    return false;
}
/**
 * @function logout
 * 
 * logout
 */
const logout = () => {
    $(JETELINAPANEL).animate({
        width: "400px",
        height: "100px",
        top: "40%",
        left: "40%"
    }, ANIMATEDURATION);

    $(FUNCTIONPANEL).hide();
    $(CONDITIONPANEL).hide();
    $(GENELICPANEL).hide();
    $(CHARTPANEL).hide();
    $("#api_access").hide();
    $("#performance_real").hide();
    $("#performance_test").hide();
    $("#command_list").hide();
    showSomethingMsgPanel(false);

    // global variables initialize
    isSuggestion = false;
    localStorage[LOCALPARAM] = false;
    stage = 0;
    preferent = {};
    presentaction = {};
    loginuser = {};

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
        default:
            break;
    }

    return c;
}
/**
 * @function instractionMode
 * @param {string} s  new words for Jetelina scenario
 * 
 * confirmation in adding a new scenario.
 * 
 * Wanna to be 0nly for Jetelina administrator.
 * deprecated in Ver.1, but may will revival in future, who knows :P
 */
const instractionMode = (s) => {
    if (s.indexOf("say:") != -1) {
        let newword = s.split("say:");
        if (newword[1] != null && 0 < newword[1].length) {
            newword[1] = newword[1].replaceAll("\"", "'");
            let data = `{"sayjetelina":"${newword[1]}","arr":"${scenario_name}"}`;
            postAjaxData(scenario["function-post-url"][1], data);
        }
    }
}
/**
 * @function showManualCommandList
 * @param {string} s  user input data
 * 
 * show/hide manual and/or command list panel
 * 
 */
const showManualCommandList = (s) => {
    let ret = IGNORE;
    let tagid1 = "";
    let showflg = true;

    if (inScenarioChk(s, 'guidance-cmd')) {
        tagid = 'guidance';
    } else if (inScenarioChk(s, 'command_list-cmd')) {
        tagid = 'command_list';
    } else {
        showflg = false;
    }

    if (showflg) {
        $(`#${tagid}`).show().animate({
            width: window.innerWidth * 0.8,
            height: window.innerHeight * 0.8,
            top: "10%",
            left: "10%"
        }, ANIMATEDURATION).draggable();

        ret = chooseMsg("starting-6a-msg", "", "");
    } else {
        $("#guidance").hide();
        $("#command_list").hide();
        ret = chooseMsg('waiting-next-msg', "", "");
    }

    return ret;
}
/**
 * @function inScenarioChk
 * @param {string} s  user input data
 * @param {string} sc scenario data array name 
 * @param {string} type type=null -> searching 'scenario[]', type='config' -> searching 'config[]'
 * @returns {boolean}  true -> in the list, false -> no
 * 
 * check if user input string is in the ordered scenario
 */
const inScenarioChk = (s, sc, type) => {
    let order;
    if (type == null) {
        order = scenario[`${sc}`];
    } else if (type == "config") {
        order = config[`${sc}`];
    }

    for (key in order) {
        /*
          Tips:
             order[] has multiple sentence as in the array.
             this 'if' sentence compares s(user input sentence) with the scenario array sentences.
             then possible multi candidates because of realizing vague cpmparing.
             indeed using $.inArray() makes this judge strict, but remains a vagueness. 
        */
        if( s.indexOf(order[key]) != -1) {
            return true;
        }
    }

    return false;
}
/**
 * @function checkBandA
 * @param {string} o target string
 * @param {string} p found position in an array 
 * @returns {boolean}  true -> ok, false -> no good
 * 
 * check the target sting is effective or not in the array string.
 *     ex. wanna check 'open' in o->"ftestopen"  p->10 then true is " open","open ","'open",",open","open'","open,"
 *         i mean 'topen' is NG.
 */
const checkBandA = (o,p) =>{
    let ret = false;
    let c = [' ',',','\'','\"'];
    if(( p==0 )||((o[p-1] != null && o[p-1].includes(c)) && (o[p+o.length+1] != null && o[p+o.length+1].includes(c)))){
        ret = true;
    }

    return ret;
}
/**
 * @function countCandidates
 * @param {string} s  user input data
 * @param {string} sc scenario data array name 
 * @param {string} type type=null -> searching 'scenario[]', type='config' -> searching 'config[]'
 * @returns {integer}  candidates number
 * 
 * count config/scenario candidates
 * 
 */
const countCandidates = (s, sc, type) => {
    let order;
    let c = 0;
    let candidate = "";

    if (type == null) {
        order = scenario[`${sc}`];
    } else if (type == "config") {
        order = config[`${sc}`];
    }

    for (key in order) {
        /*
          Tips:
             order[] has multiple sentence as in the array.
             this 'if' sentence compares s(user input sentence) with the scenario array sentences.
             then possible multi candidates because of realizing vague cpmparing.
        */
        if (s.indexOf(order[key]) != -1) {
            c++;
            candidate = order[key];
        }
    }

    return [c, candidate];
}
/**
 * @function checkNewCommer
 * @param {string} s  user input data
 * @returns {array[boolean,string]}  [true -> yes a newcommer, false -> an expert, "scenario message"]
 * 
 *  check the login user is a newcommer or not.
 *  ask some attribute if a newcommer.
 */
const checkNewCommer = (s) => {
    if (loginuser.logincount == 0) {
        let data;
        let m;
        if (usetcount < 3) {
            // set user's firstname and lastname, these are mandatory.
            switch (authcount) {
                case 0: // anyhow the first access
                    m = chooseMsg('first-login-msg', loginuser.login, "");
                    break;
                case 1: // set 'fiestname'
                    data = `{"uid":${loginuser.user_id},"key":"firstname","val":"${s}"}`;
                    m = chooseMsg('first-login-ask-lastname-msg', "", "");
                    break;
                case 2: // set 'lastname'
                    data = `{"uid":${loginuser.user_id},"key":"lastname","val":"${s}"}`;
                    m = chooseMsg('first-login-ask-info-msg', loginuser.login, "");
                    break;
                default:
                    m = chooseMsg('first-login-ask-firstname-msg', "", "");
                    break;
            }

            postAjaxData(scenario["function-post-url"][0], data);
        } else {
            // set user's info, these are using for authentication.
            if (usetcount < USETCOUNTMAX) {
                m = chooseMsg('first-login-ask-info-then-msg', "", "");
                data = `{"uid":${loginuser.user_id},"key":"lastname","val":"${s}"}`;
            } else {
                m = chooseMsg('first-login-ask-info-end-msg', "", "");
            }
        }

        usetcount++;
        return [true, m];
    }
    if (loginuser.login == loginuser.fistname && loginuser.login == loginuser.lastname) {
        m = chooseMsg('first-login', loginuser.login, "");
        authcount++;
    }
}
/**
 * @function checkBeginner
 * @returns {boolean}  true -> yes a beginner, false -> an expert
 * 
 * check the login user is a beginner or not.
 */
const checkBeginner = () => {
    if (loginuser.logincount < 3) {

    } else if (10 < loginuser.logincount) {

    } else {
    }
}
/**
 * @function isVisibleFunctionPanel
 * @returns {boolean}  true -> visible, false -> invisible
 * 
 * checking "#function_panel" is visible or not
 */
const isVisibleFunctionPanel = () => {
    let ret = false;
    if ($(FUNCTIONPANEL).is(":visible")) {
        ret = true;
    }

    return ret;
}
/**
* @function inVisibleConditionPanel
* @returns {boolean}  true -> visible, false -> invisible
* 
* checking "#condition_panel" is visible or not
*/
const inVisibleConditionPanel = () => {
    let ret = false;
    if ($(CONDITIONPANEL).is(":visible")) {
        ret = true;
    }

    return ret;
}
/**
* @function isVisibleSomethingMsgPanel
* @returns {boolean}  true -> visible, false -> invisible
* 
* checking "#something_msg" is visible or not
*/
const isVisibleSomethingMsgPanel = () => {
    let ret = false;
    if ($(SOMETHINGMSGPANEL).is(":visible")) {
        ret = true;
    }

    return ret;
}
/**
 * @function showSomethingInputField
 *
 * @param {boolean} true -> show, false -> hide
 *  
 * "#something_input_field" show or hide
 */
const showSomethingInputField = (b) => {
    if (b) {
        if (isVisibleSomethingMsgPanel()) {
            $("SOMETHINGTEXT").text("Change this to =>");
            $(SOMETHINGINPUT).attr('placeholder', 'new parameter...');
        }

        $("SOMETHINGINPUTFIELD").show();
        $(SOMETHINGINPUT).focus();
    } else {
        $(SOMETHINGMSGPANELMSG).text("");
        $("SOMETHINGTEXT").text("");
        $(SOMETHINGINPUT).val("");
        $("SOMETHINGINPUTFIELD").hide();
        showSomethingMsgPanel(false);
    }
}
/**
 * @function showSomethingMsgPanel
 *
 * @param {boolean} true -> show, false -> hide
 *  
 * "#something_msg" show or hide
 */
const showSomethingMsgPanel = (b) => {
    if (b) {
        $(SOMETHINGMSGPANEL).show();
    } else {
        // these classes are for configuration changing history message
        $(SOMETHINGMSGPANEL).removeClass("config_history");
        $(SOMETHINGMSGPANELMSG).removeClass("config_history_text");
        $(SOMETHINGMSGPANELMSG).text("");

        $(SOMETHINGMSGPANEL).hide();
    }
}
/**
* @function isVisibleApiTestPanel
* @returns {boolean}  true -> visible, false -> invisible
* 
* checking "#apitest" is visible or not
*/
const isVisibleApiTestPanel = () => {
    let ret = false;
    if ($(APITESTPANEL).is(":visible")) {
        ret = true;
    }

    return ret;
}
/**
 * @function showApiTestPanel
 *
 * @param {boolean} true -> show, false -> hide
 *  
 * "#apitest" show or hide
 */
const showApiTestPanel = (b) => {
    if (b) {
        $(APITESTPANEL).show().draggable();
        $(APITESTPANEL).animate({top:"300px"},ANIMATEDURATION);
    } else {
        // delete all test results
        $(APITESTPANEL).hide();
    }
}
/**
 * @function inCancelableCmdList
 *
 * @param {string} command name ex.CONFIGCHANGE..
 * @preturn {boolean} true -> is in the list  false -> no
 *  
 * check the ordered command is in cancelableCmdList or not
 */
const inCancelableCmdList = (cmd) =>{
    let ret = false;
    if(-1<$.inArray(cmd,cancelableCmdList)){
        ret = true;
    }

    return ret;
}
/**
 * @function rejectCancelableCmdList
 *
 * @param {string} command name ex.CONFIGCHANGE..
 *  
 * reject command from cancelableCmdList
 */
const rejectCancelableCmdList = (cmd) =>{
    cancelableCmdList = cancelableCmdList.filter(function(d){
        return d != cmd;
    });
}
/**
 * @function rejectSelectedItemsArr
 *
 * @param {string} item selectd item name
 *  
 * reject selected item from selectedItemsArr
 */
const rejectSelectedItemsArr = (item) =>{
    selectedItemsArr = selectedItemsArr.filter(function(d){
        if(d.indexOf(item) < 0){
            return d;
        }
    });
}

// return to the chat box if 'return key' is typed in something_input_field
$(document).on("keydown", SOMETHINGINPUT, function (e) {
    if (e.keyCode == 13) {
        focusonJetelinaPanel()
    }
});