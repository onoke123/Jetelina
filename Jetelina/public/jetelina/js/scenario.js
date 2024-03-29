let scenario = [], userresponse = [];

/* special configuration parameter */
/* urls for condition panel */
scenario["analyzed-data-collect-url"] = ["/gettablecombivsaccessrelationdata", "/getperformancedata_real", "/getperformancedata_test","/chkexistimprapifile","/getsqlaccessdata"];
/* post urls for function panel */
scenario["function-post-url"] = ["/jetelinawords"];
/* get urls for function panel */
scenario["function-get-url"] = ["/getapilist"];
/* null */
scenario["null"] = ["",""];
/* command list order */
scenario["guidance"] = ["what can i","can you","start","manual","guide me","guidance","teach me","tell me"];
scenario["command_list"] = ["how can i","command","commands","commandlist","commandslist"];
scenario["waiting-next"] = ["then?","next please"];
/* opening */
scenario[0] = ["Hi","Hello"];
userresponse[0] = ["hi","hello","hola","good ","sorry","what\"s up","what is up","nice to see you","how are you"];
scenario["bura"] = ["Hi Ho","Fun fun fun","Someone is there?","Waiting for.....","Do you know the meaning of .... love?"];
/* greeting */
scenario[1] = ["Nice to see you", "How are you?"];
scenario["1a"] = ["Nice to hear it", "Wow, super","lucky you","envy you"];
userresponse[1] = ["fine","good","great"];
/* login */
scenario[2] = ["Could you give me your name?","Let me know your name, please","May I ask your name?"];
/* etc */
scenario[3] = ["What?","Are you kidding me?","Never mind"];
/* miss login */
scenario[4] = ["I am sorry, but ", "Something wrong, hum, "];
/* something inprogress */
scenario["inprogress"] = ["I am doing","happy workin","husle hustle","I AM DOING THIS JUST FOR YOU"];
/* refuse any command due to progress something */
scenario["refuse-command"] = ["I am busy now","I cannot do multi task at once","You kill me?","Later..."];
/* greeting to u after successing login */
scenario[5] = ["Welcome ", "I missed you, ","Oh my.. incredible, "];
scenario["5-multi-candidates"] = ["please tell me more detail.","next question.","more..."];
scenario["5-not-registered"] = ["you are not registered, try again.","you are not here yet.","I do not know you, sorry."];
/* after login */
scenario["first-login"] = ["This is your first login to me,{Q}, I would like to ask you something."];
scenario["first-login-ask-firstname"] = ["Thank you. First of all, may I ask your first name?"];
scenario["first-login-ask-lastname"] = ["Thank you. Next, could you give me your last name?"];
scenario["first-login-ask-info"] = ["Thank you so much,{Q}, then what is your favorits?, Whatever."];
scenario["first-login-ask-info-then"] = ["Sounds nice, and more?","Cool, others?","I love it too, and?","Great, you are lucky, and more?"];
scenario["first-login-ask-info-end"] = ["Thank you so much,{Q}. Now you can type 'Guide' or 'Manual' to see what can I do for you."];

scenario[6] = ["How can I help you today?", "What do you do now?"];
scenario["success"] = ["Done","Success","I am so happy","Yes"];
scenario["fail"] = ["Uge","Noooooooo","Sorry something wrong"];
scenario["cancel"] = ["It has been canceld","Has been withdrawn","Canceled","Withdrew","Called off"]
scenario["confirmation-sentences"] = ["yes","sure","why not","do it","do","i want to do it","i wanna do it","kick ass"];
//scenario["6func_in"] = ["Do you wanna open the function panel?"];
//scenario["6func"] = ["Let me your command, if you need"];
scenario["6func-post-err"] = ["Hey, no columns","You should select post data","Boo"];
//scenario["6cond_in"] = ["Do you wanna open the condition panel?"];

//open the function panel
scenario["function_panel"] = ["function panel", "open func","show me func","function"];
//open the condition panel
scenario["condition_panel"] = ["condition panel", "open cond","show me cond","condition"];
//open table list
scenario["6func-show-table-list"] = ["open table","show me table","table list","tables","tablelist","tableslist"];
//open api list
scenario["6func-show-api-list"] = ["open api","show me api","api list","apis list","apis","apilist"];

//scenario["6cond"] = ["Let me your command, if you need"];
scenario["6cond-graph-show"] = ["here you are","tatta laan"];
// Access vs Combination graph 
scenario["6cond-graph-show-keywords"] = ["access numbers","access number","analyzed","report","graph"];
// SQL Exectuon Time graph
scenario["6cond-sql-performance-graph-show-keywords"] = ["your suggestion","suggest","sql test","improved performance"];

scenario["6cond-performance-improve"] = ["There is an improving suggestion.","Do you wanna know my great idea?","Attention please. I have an idea."];
scenario["6cond-no-suggestion"] = ["I do not have any suggestions so far.","No suggestions","I do not give it to you.","Hey, Nothing at all"];

scenario["6a"] = ["OK, here you are","Hey ho","This"];
scenario["6b"] = ["Command me, if you need"];

// basic commands in function panel
scenario["6func-list-cmd"] = ["open","close","select","cancel"];
scenario["6func-list-cmd-select-cmd"] = ["select","choose","pick"];
scenario["6func-selected-column-post-cmd"] = ["post","send","push"];
scenario["6func-cleanup-cmd"] = ["refresh","cleanup","clean"];
scenario["6func-tabledrop-cmd"] = ["drop","drop table","table drop","tabledrop","droptable"];
scenario["6func-tabledrop-msg"] = ["Which table do you want to drop?","correct order is \"droptable <table name>\" and so on"];
scenario["6func-tabledrop-ng-msg"] = ["Hey open the table list first!","Huum?","Check it first","Watch it"];
scenario["6func-tabledrop-confirm"] = ["Sure?","Really?","Won\"t you regret?"];
scenario["6func-tabledrop-cancel-cmd"] = scenario["6func-postcolumn-cancel-cmd"];

scenario["6func-apidelete-cmd"] = ["delete","delete api","api delete","apidelete","deleteapi"];
scenario["6func-apidelete-msg"] = ["Which api do you want to delete?","correct order is \"delete <api name>\" and so on"];
scenario["6func-apidelete-ng-msg"] = ["Hey open the api list first!","Huum?","Check it first","Watch it"];
scenario["6func-apidelete-forbidden-msg"] = ["this api cannot be deleted, sorry"];
scenario["6func-apidelete-confirm"] = scenario["6func-tabledrop-confirm"];

scenario["6func-fileupload-open-cmd"] = ["file open","open file","open filebox","file box","csv file"];
scenario["6func-fileupload-open-msg"] = ["Which file?"];
scenario["6func-fileupload-cmd"] = ["upload","fileup","fileupload","up","csv up"];
scenario["6func-fileupload-msg"] = ["File?"];
scenario["6func-csv-format-error"] = ["CSV format is not good, see the error message","Unacceptable CSV format, see the error message,"];
scenario["6func-postcolumn-where-option-msg"] = ["Wanna set the \"Where\" sentence? This is an option."];
scenario["6func-postcolumn-where-indispensable-msg"] = ["Set the \"Where\" sentence. This is an indispensable."];
scenario["6func-postcolumn-available-msg"] = ["Now you can post them","Do post them","Type \"post\" now"];
scenario["6func-subpanel-open-cmd"] = ["sub please","subquery","sub panel","where panel","sub query"];
scenario["6func-subpanel-opened"] =["Set your sub query in \"Sub Query\" field","Ready to \"Sub Query\" field"];
scenario["6func-postcolumn-cancel-cmd"] = ["cancel","withdraw","abandon","postpone","give up","stop","quit"];
/* log out */
scenario["logout"] = ["logout","exit","log out","out","return","bye","see you","nice day"];
scenario["afterlogout"] = ["Bye", "Have a good day","Hope you will back soon","I am looking forward you"];
/* unknow command */
scenario["unknown-msg"] = ["Hey hey hey","Ah.... what?","Could not catch yours, what?","Oh oh oh, what?"];
/* show or hide error message */
scenario["hide-error-message"] = ["hide error"];
scenario["show-error-message"] = ["show error"];
