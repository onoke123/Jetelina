/**
    JS library for Jetelina common library
    @author Ono Keiji
    @version 1.0

    This js lib works with dashboard.js, functionpanel.js and conditionpanel.js.
    

    Functions list:
      getScenarioFile(l) read scenario.js file from server order by 'l' is language
      checkResult(o) check the 'return' field in the object
      getdata(o, t) resolve the json object into each data
      getAjaxData(url) general purpose ajax get call function 
      postAjaxData(url,data) general purpose ajax post call function 
      typingControll(m) typing character controller
      authAjax(posturl, chunk, scenarioNumber) Authentication ajax call
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
      getRandomNumber(i) create random number. the range is 0 to i.
      isVisibleFunctionPanel() check the function panel is visible or not
      isVIsibleConditionPanel() check the condition panel is visible or not
*/
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
    
    switch (l){
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
 *    @returns {boolean} true/false
 * 
 *   check the 'return' field in the object
 */
const checkResult = (o) =>{
    let ret = true;

    if (o != null) {
        /*
            Tips:
                remove 'jetelina_suggestion' class if it is.
                it does not need to confirm its existence.
        */
        $("#something_msg [name='jetelina_message']").removeClass("jetelina_suggestion");

        if(!o.result){
            let em = "";
            let errmsg = o["errmsg"];
            let error = o["error"];
            if(errmsg != null ){
                em = errmsg;
            }else if(error != null ){
                em = "Oh my, something server error happened ";
            }

            $("#something_msg [name='jetelina_message']").text(em);
            $("#something_msg").show();

            ret = false;
        }else{
            $("#something_msg [name='jetelina_message']").text("");
            $("#something_msg").hide();
        }
    }

    return ret;
}
/**
 *  @function getdata
 *  @param {object} o mostry json data
 *  @param {integer} t 0->db table list, 1->table columns list or csv file columns 2-> sql list
 *
 *  resolve the json object into each data
*/
const getdata = (o, t) => {
    if (o != null) {
        checkResult(o);
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
                                if ($.type(value) === "string"){
                                    if(value.endsWith("/")){
                                        value = value.slice(0,-1);
                                    }
                                }

                                if (t == 0) {
                                    // table list
                                    str += `<span class="table">${value}</span>`;
                                } else if (t == 1) {
                                    // jetelina_delete_flg should not show in the column list
                                    if (name != "jetelina_delete_flg") {
                                        str += `<span class="item" d=${value}><p>${targetTable}.${name}</p></span>`;
                                    }
                                }
                            });
                        } else {
                            /*
                                Tips:
                                    case t=2: wanna show it in one line
                                    this is the api list.
                            */
                            str += `<span class="api">${v.apino}</span>`;
                        }

                        let tagid = "";
                        if (t == 0) {
                            tagid = "#table_container";
                        } else if (t == 1) {
                            tagid = "#columns .item_area";
                        } else if (t == 2) {
                            tagid = "#api_container";
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
            dataType: "json",
            xhr:function(){
                ret = $.ajaxSettings.xhr();
                inprogress=true;// in progress. for priventing accept a new command.
                typingControll(chooseMsg('inprogress', "", ""));
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
                if(result){
                    // set suggestion existing flag to display my message
                    isSuggestion = true;
                    // set my suggestion
                    $("#something_msg [name='jetelina_message']").addClass("jetelina_suggestion");
                    $("#something_msg [name='jetelina_message']").text(`${result.Jetelina.apino}:${result.Jetelina.suggestion}`);
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

            }else if (inScenarioChk(url, 'analyzed-data-collect-url')) {
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
            } else {
                const geturl = scenario['function-get-url'];
                if(url == geturl[0]){
                    //rendering api list
                    preferent.apilist = result;
                    getdata(result, 2);
                }else{
                    // mainly, data for function panel
                    getdata(result, 0);
                    typingControll(chooseMsg("success", "", ""));
                }
            }
        }).fail(function (result) {
            checkResult(result);
            console.error("getAjaxData() fail");
            typingControll(chooseMsg("fail", "", ""));
        }).always(function () {
            // release it for allowing to input new command in the chatbox 
            inprogress=false;
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
            xhr:function(){
                ret = $.ajaxSettings.xhr();
                inprogress=true;// in progress. for priventing accept a new command.
                typingControll(chooseMsg('inprogress', "", ""));
                return ret;
            }
        }).done(function (result, textStatus, jqXHR) {
            const posturls = scenario['function-post-url'];
            if (url == posturls[0]) {
                // jetelinawords -> nothing do
            }else if(url == posturls[1]){
                // get a configuration parameter, then show it in there
                let configMsg = "Oh oh, I do not know it, another one plz.";
                $.each(result,function(name,value){
                    if( name != "result" ){
                       configMsg = `${name} is '${value}' so far`;
                    }
                });

                $("#something_msg [name='jetelina_message']").text(configMsg);
                $("#something_msg").show();
            }

            typingControll(chooseMsg("success", "", ""));
        }).fail(function (result) {
            checkResult(result);
            console.error("postAjaxData() fail");
            typingControll(chooseMsg("fail", "", ""));
        }).always(function(){
            // release it for allowing to input new command in the chatbox 
            inprogress=false;
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
        dataType: "json",
        xhr:function(){
            ret = $.ajaxSettings.xhr();
            inprogress=true;// in progress. for priventing accept a new command.
            typingControll(chooseMsg('inprogress', "", ""));
            return ret;
        }
    }).done(function (result, textStatus, jqXHR) {
        scenarioNumber = 4;
        if (result != null) {
            const o = result;
            let m = "";
            // found user
            Object.keys(o).some(function (key) {
                if (key == "Jetelina" && o[key].length == 1) {
                    $.each(o[key][0], function (k, v) {
                        if (k == "user_id"){
                            loginuser.user_id = v;
                            localStorage[localparam] = true;
                        }else if (k == "login"){
                            loginuser.login = v;
                        }else if (k == "firstname") {
                            loginuser.firstname = v;
                        }else if (k == "lastname"){
                            loginuser.lastname = v;
                            m = v;
                        }else if (k == "nickname"){
                            loginuser.nickname = v; 
                        }else if (k == "logincount"){
                            loginuser.logincount = v;
                        }else if (k == "logindate" ){
                            loginuser.lastlogin = v;
                        }else if (k == "user_level"){
                            loginuser.user_level = v;
                        }else if (k == "familiar_index"){
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
                            can move from 'login"success' to 'chose_func_or_cond' stage.

                            loginuser and authcount are defined in dashboard.js as global.
                    */
                    loginuser.c = 0;
                    authcount = getRandomNumber(3) + 1;

                    scenarioNumber = 5;
                    stage = 'login_success';
                } else if (1 < o[key].length) {
                        // some candidates
                        scenarioNumber = "multi-candidates";
                        stage = 'login';
                } else {
                    // no user
                    scenarioNumber = "not-registered";
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
        typingControll(chooseMsg(fail, "", ""));
    }).always(function(){
        // release it for allowing to input new command in the chatbox 
        inprogress=false;
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

    const n = getRandomNumber(scenario[i].length);
    let s = scenario[`${i}`][n];
    if (0 < m.length) {
        if (p == "b") {
            s = `${m} ${s}`;
        } else if(p=="a"){
            s = `${s} ${m}`;
        }else{
            s = s.replaceAll("{Q}",m);
        }
    }

    return s;
}

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
 * check if the user input message is what is expected in scenario[] or config[]
 */
const chkUResponse = (n, s) => {
    /*
        Tips:
            privent to display the opening messages are dublicated.
            logouttimeId is set at logout process for returning to the inital screen in openingMessage().
    */
    if(logouttimerId){
        clearTimeout(logouttimerId);
    }

    if ((scenario[n] != null && scenario[n].includes(s)) ||
        (config[n] != null && config[n].includes(s))){
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

    if (ut != null && 0 < ut.length) {
        ut = $.trim(ut.toLowerCase());
        let m = "";
        /* do it only if there were a input character by user */
        if (0 < ut.length) {
            enterNumber++;
            $("#jetelina_panel [name='jetelina_tell']").text("");
            $("#jetelina_panel [name='chat_input']").val("");
            $("#jetelina_panel [name='your_tell']").text(ut);

            // logout
            if (logoutChk(ut)) {
                logout();
                m = chooseMsg('afterlogout', "", "");
                logoutflg = true;
            }

            /*
                Tips:
                    may, 'm' has already been set in logout process.
            */
            if ( m.length == 0 ){
                // check ordered the command list
                m= showManualCommandList(ut);
            }

            // check the instraction mode that is teaching 'words' to Jetelina or not
            instractionMode(ut);

            // check the error message panel hide or not
            if(inScenarioChk(ut,'hide-error-message')){
                $("#something_msg").hide();
                m = 'ignore';
            }else if(inScenarioChk(ut,'show-error-message')){
                $("#something_msg").show();
                m = 'ignore';
            }

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
                    if (!chkUResponse("1r", ut)) {
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
                        m = chooseMsg(6, "", "");
                        stage = 'chose_func_or_cond';
//                    }

                    break;
                case 'chose_func_or_cond':
                    const panelTop = window.innerHeight - 110;
                    $("#jetelina_panel").animate({
                        height: "70px",
                        top: `${panelTop}px`,
                        left: "210px"
                    }, animateDuration);

                    // if 'ut' is a command for driving function
                    m = functionPanelFunctions(ut);
                    if (0 < m.length && m != 'ignore') {
                    }else{
                        // if 'ut' is a command for driving condition
                        m = conditionPanelFunctions(ut);
                        if (0 < m.length && m != 'ignore') {
                        }else{
                            /*
                                if 'ut' is a command for driving configuration
                                localStrage checking is for secure reason
                            */
                           let multi=0;
                           let multiscript = [];
                            if ( localStorage[localparam] == "true" ){
                                for (zzz in config){
                                    /*
                                        Tips:
                                            in the case of vague inputing, may have multi candidates.
                                            but after showing them to user, may the right one inputing.
                                            the first 'if' is maybe not hit, but secondly inputing may kit it.
                                    */
                                    if(ut == zzz){
                                        /*
                                            Tips:
                                                there is possilbility someting in multiscript[] yet.
                                                needs to clear it before pushing the right one.
                                        */
                                        multiscript = [];
                                        multiscript.push(zzz);
                                        break;
                                    }else{
                                        if(inScenarioChk(ut,zzz,'config')){
                                            let r = countCandidates(ut,zzz,'config');
                                            multi += r[0];
                                            multiscript.push(zzz);
                                        }
                                    }
                                }
                            }

                            // right message should be displayed if there were any candidates.
                            let configMsg = "";
                            if(1<multi){
                                // pick candidates up
                                m = chooseMsg('multi-candidates', "", "");
                                let multimsg = "there are multi candidates ";
                                for(i=0;i<multi;i++){
                                    multimsg += `'${multiscript[i]}',`; 
                                }

                                configMsg = multimsg;                    
                            }else{
                                // here you are, this,.... and so on
                                m = chooseMsg('6a', "", "");
                                if(multiscript[0] != null && multiscript[0] != undefined){
                                    let data = `{"param":"${multiscript[0]}"}`;
                                    postAjaxData("/getconfigdata", data);
                                }
                            }

                            if(0<configMsg.length){
                                $("#something_msg [name='jetelina_message']").text(configMsg);
                                $("#something_msg").show();
                            }
                        }
                    }

                    break;
                case 'func':
                    $("#something_msg").hide();
                    // defined in functionpanel.js
                    m = functionPanelFunctions(ut);
                    break;
                case 'cond':
                    $("#something_msg").hide();
                    // defined in conditionpanel.js
                    m = conditionPanelFunctions(ut);
                    break;
                default:
                    if (ut == "reload") {
                        location.reload();
                    }

                    if (chkUResponse("0r", ut)) {
                        // greeting
                        m = chooseMsg(1, "", "");
                        stage = 1;/* into the login stage */
                    } else {
                        if (!logoutflg && m.length == 0) {
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
            }else if ( m == 'ignore' && stage != 'login'){
                typingControll(chooseMsg('waiting-next',"",""));
            }else if (m == null || m.length == 0) {
                // cannot understand what the user is typing
                typingControll(chooseMsg('unknown-msg', "", ""));
            }
            

            if (logoutflg) {
                const t = 10000;// switch to the opening screen after 10 sec
                logouttimerId = setTimeout(function () {
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
    $("#jetelina_panel [name='your_tell']").text("");
    typing(0, chooseMsg(0, "", ""));

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
        $("#jetelina_panel [name='jetelina_tell']").text("");
        $("#jetelina_panel [name='your_tell']").text("");
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
    localStorage[localparam] = false;

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
    $("#api_access").hide();
    $("#performance_real").hide();
    $("#performance_test").hide();
    $("#command_list").hide();
    $("#something_msg").hide();

    // global variables initialize
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
        case 'droptable':// table drop target table name
            // take the table name from preferent
            if (preferent.droptable != null && 0 < preferent.droptable.length) {
                c = preferent.droptable;
            }
            break;
        case 'deleteapi':// delete target api name
            // take the api name from preferent
            if ( preferent.deleteapi != null && 0<preferent.deleteapi.length ){
                c = preferent.deleteapi;
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
 */
const instractionMode = (s) => {
    if (s.indexOf("say:") != -1) {
        let newword = s.split("say:");
        if(newword[1] != null && 0<newword[1].length ){
            newword[1] = newword[1].replaceAll("\"","'");
            let data = `{"sayjetelina":"${newword[1]}","arr":"${scenario_name}"}`;
            postAjaxData("/jetelinawords", data);
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
    let ret = "ignore";
    let tagid1 = "";
    let showflg = true;

    if( inScenarioChk(s,'guidance') ){
        tagid = 'guidance';
    }else if(inScenarioChk(s,'command_list')){
        tagid = 'command_list';
    }else{
        showflg = false;
    }

    if(showflg){
        $(`#${tagid}`).show().animate({
            width: window.innerWidth * 0.8,
            height: window.innerHeight * 0.8,
            top: "10%",
            left: "10%"
        }, animateDuration).draggable();

        ret = chooseMsg('6a',"","");
    }else{
        $("#guidance").hide();
        $("#command_list").hide();
        ret = chooseMsg('waiting-next',"","");
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
 * 
 */
const inScenarioChk = (s,sc, type) =>{
    let order;
    if(type == null){
        order = scenario[`${sc}`];
    }else if(type == "config"){
        order = config[`${sc}`];
    }

    let ret=false;
    for(key in order){
        /*
          Tips:
             order[] has multiple sentence as in the array.
             this 'if' sentence compares s(user input sentence) with the scenario array sentences.
             then possible multi candidates because of realizing vague cpmparing.
        */
        if (s.indexOf(order[key]) != -1) {
            return true;
        }
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
const countCandidates = (s,sc,type) =>{
    let order;
    let c=0;
    let candidate = "";

    if(type == null){
        order = scenario[`${sc}`];
    }else if(type == "config"){
        order = config[`${sc}`];
    }

    for(key in order){
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

    return [c,candidate];
}
/**
 * @function checkNewCommer
 * @param {string} s  user input data
 * @returns {array[boolean,string]}  [true -> yes a newcommer, false -> an expert, "scenario message"]
 * 
 *  check the login user is a newcommer or not.
 *  ask some attribute if a newcommer.
 */
const checkNewCommer = (s) =>{
    if (loginuser.logincount==0){
        let data;
        let m;
        if (usetcount<3){
            // set user's firstname and lastname, these are mandatory.
            switch(authcount){
                case 0: // anyhow the first access
                    m = chooseMsg('first-login', loginuser.login, "");
                    break;
                case 1: // set 'fiestname'
                    data = `{"uid":${loginuser.user_id},"key":"firstname","val":"${s}"}`;
                    m = chooseMsg('first-login-ask-lastname', "", "");
                    break;
                case 2: // set 'lastname'
                    data = `{"uid":${loginuser.user_id},"key":"lastname","val":"${s}"}`;
                    m = chooseMsg('first-login-ask-info', loginuser.login, "");
                    break;
                default:
                    m = chooseMsg('first-login-ask-firstname', "", "");
                    break;
            }

            postAjaxData("/updateuserdata",data);
        }else{
            // set user's info, these are using for authentication.
            if (usetcount < usetcountmax){
                m = chooseMsg('first-login-ask-info-then', "", "");
                data = `{"uid":${loginuser.user_id},"key":"lastname","val":"${s}"}`;
            }else{
                m = chooseMsg('first-login-ask-info-end', "", "");
            }
        }

        usetcount++;
        return [true,m];
    }
    if(loginuser.login==loginuser.fistname && loginuser.login==loginuser.lastname){
        m = chooseMsg('first-login',loginuser.login,"");
        authcount++;
    }
}
/**
 * @function checkBeginner
 * @returns {boolean}  true -> yes a beginner, false -> an expert
 * 
 * check the login user is a beginner or not.
 */
const checkBeginner = () =>{
    if(loginuser.logincount<3){

    }else if(10<loginuser.logincount){

    }else{
    }
}
/**
 * @function getRandomNumber
 * @param {integer} ordered random range
 * @returns {boolean}  true -> yes a beginner, false -> an expert
 * 
 * create random number. the range is 0 to i.
 */
const getRandomNumber = (i) =>{
    return Math.floor(Math.random() * i);
}
/**
 * @function isVisibleFunctionPanel
 * @returns {boolean}  true -> visible, false -> invisible
 * 
 * checking "#function_panel" is visible or not
 */
const isVisibleFunctionPanel = () => {
    let ret = false;
    if ($("#function_panel").is(":visible")) {
      ret = true;
    }
  
    return ret;
  }
  /**
 * @function isVIsibleConditionPanel
 * @returns {boolean}  true -> visible, false -> invisible
 * 
 * checking "#condition_panel" is visible or not
 */
const isVIsibleConditionPanel = () => {
    let ret = false;
    if ($("#condition_panel").is(":visible")) {
      ret = true;
    }
  
    return ret;
  }  