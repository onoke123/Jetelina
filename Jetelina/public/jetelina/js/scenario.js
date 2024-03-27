let scenario = []; let config = [];
scenario["analyzed-data-collect-url"]=["/gettablecombivsaccessrelationdata", "/getperformancedata_real", "/getperformancedata_test","/chkexistimprapifile","/getsqlaccessdata"];
scenario["function-post-url"]=["/updateuserdata","/jetelinawords","/getconfigdata","/changeconfigdata","/createapi","/testapi"];
scenario["function-get-url"]=["/getapilist","/getalldbtable","/getconfigchangehistory"];
scenario["null-msg"]=["",""];
scenario["guidance-cmd"]=["what can i","can you","start","manual","guide me","guidance","teach me","tell me"];
scenario["command_list-cmd"]=["how can i","command","commands","commandlist","commandslist"];
scenario["waiting-next-msg"]=["then?","next please"];
scenario["starting-0-msg"]=["Hi","Hello"];
scenario["starting-0r-cmd"]=["hi","hello","hola","good ","sorry","what\"s up","what is up","nice to see you","how are you"];
scenario["bura-msg"]=["Hi Ho","Fun fun fun","Someone is there?","Waiting for.....","Do you know the meaning of .... love?"];
scenario["starting-1-msg"]=["Nice to see you", "How are you?"];
scenario["starting-1r-cmd"]=["fine","good","great"];
scenario["starting-1a-msg"]=["Nice to hear it", "Wow, super","lucky you","envy you"];
scenario["starting-2-msg"]=["Could you give me your name?","Let me know your name, please","May I ask your name?"];
scenario["starting-3-msg"]=["What?","Are you kidding me?","Never mind"];
scenario["starting-4-msg"]=["I am sorry, but ", "Something wrong, hum, "];
scenario["inprogress-msg"]=["I am doing","happy workin","husle hustle","I AM DOING THIS JUST FOR YOU"];
scenario["refuse-command-msg"]=["I am busy now","I cannot do multi task at once","You kill me?","Later..."];
scenario["starting-5-msg"]=["Welcome ", "I missed you, ","Oh my.. incredible, "];
scenario["multi-candidates-msg"]=["there are a few candidates as your order","which is your order?","may you should say more detail","please tell me more detail.","next question.","more..."];
scenario["not-registered-msg"]=["you are not registered, try again.","you are not here yet.","I do not know you, sorry."];
scenario["first-login-msg"]=["This is your first login to me,{Q}, I would like to ask you something."];
scenario["first-login-ask-firstname-msg"]=["Thank you. First of all, may I ask your first name?"];
scenario["first-login-ask-lastname-msg"]=["Thank you. Next, could you give me your last name?"];
scenario["first-login-ask-info-msg"]=["Thank you so much,{Q}, then what is your favorits?, Whatever."];
scenario["first-login-ask-info-then-msg"]=["Sounds nice, and more?","Cool, others?","I love it too, and?","Great, you are lucky, and more?"];
scenario["first-login-ask-info-end-msg"]=["Thank you so much,{Q}. Now you can type 'Guide' or 'Manual' to see what can I do for you."];
scenario["starting-6-msg"]=["How can I help you today?", "What do you do now?"];
scenario["success-msg"]=["Done","Success","I am so happy","Yes"];
scenario["fail-msg"]=["Uge","Noooooooo","Sorry something wrong"];
scenario["cancel-msg"]=["It has been canceld","Has been withdrawn","Canceled","Withdrew","Called off"];
scenario["confirmation-sentences-cmd"]=["yes","sure","why not","do it","do","i want to do it","i wanna do it","kick ass"];
scenario["func-post-err-msg"]=["Hey, no columns","You should select post data","Boo"];
scenario["config-update-cmd"]=["change parameter","parameter change","configuration change","change configuration","update configuration","configuration update","update parameter","parameter update","config change","change config","update config","config update"];
scenario["get-config-change-history"]=["configuration history", "change history","update history"];
scenario["function_panel-cmd"]=["function panel", "open func","show me func","function"];
scenario["condition_panel-cmd"]=["condition panel", "open cond","show me cond","condition"];
scenario["func-show-table-list-cmd"]=["open table","show me table","table list","tables","tablelist","tableslist"];
scenario["func-show-api-list-cmd"]=["open api","show me api","api list","apis list","apis","apilist"];
scenario["cond-graph-show-msg"]=["here you are","tatta laan"];
scenario["cond-graph-show-cmd"]=["access numbers","access number","analyzed","report","graph"];
scenario["cond-sql-performance-graph-show-cmd"]=["your suggestion","suggest","improved performance"];
scenario["cond-performance-improve-msg"]=["There is an improving suggestion.","Do you wanna know my great idea?","Attention please. I have an idea."];
scenario["cond-no-suggestion-msg"]=["I do not have any suggestions so far.","No suggestions","I do not give it to you.","Hey, Nothing at all"];
scenario["starting-6a-msg"]=["OK, here you are","Hey ho","This"];
scenario["starting-6b-msg"]=["Command me, if you need"];
scenario["func-list-cmd"]=["open","close","select","cancel"];
scenario["func-item-select-cmd"]=["select","choose","pick"];
scenario["func-item-select-all-cmd"]=["select all", "select every", "choose all","choose every","pick all","pick every"];
scenario["func-selecteditem-cancel-cmd"]=["cancel","remove","reject","withdraw"];
scenario["func-selecteditem-all-cancel-cmd"]=["cancel all","remove all","reject all","withdraw all"];
scenario["common-post-cmd"]=["post","send","push"];
scenario["func-cleanup-cmd"]=["refresh","cleanup","clean"];
scenario["func-tabledrop-cmd"]=["drop","drop table","table drop","tabledrop","droptable"];
scenario["func-tabledrop-msg"]=["Which table do you want to drop?","correct order is \"droptable <table name>\" and so on"];
scenario["func-tabledrop-ng-msg"]=["Hey open the table list first!","Huum?","Check it first","Watch it"];
scenario["func-tabledrop-confirm-msg"]=["Sure?","Really?","Won't you regret?"];
scenario["func-apidelete-cmd"]=["delete","delete api","api delete","apidelete","deleteapi","remove","reject"];
scenario["func-apidelete-msg"]=["Which api do you want to delete?","correct order is \"delete <api name>\" and so on"];
scenario["func-apidelete-ng-msg"]=["Hey open the api list first!","Huum?","Check it first","Watch it"];
scenario["func-apidelete-forbidden-msg"]=["this api cannot be deleted, sorry"];
scenario["func-apidelete-confirm-msg"]=["Sure?","Really?","Won\"t you regret?"];
scenario["func-fileupload-open-cmd"]=["file open","open file","open filebox","file box","csv file"];
scenario["func-fileupload-open-msg"]=["Which file?"];
scenario["func-fileupload-cmd"]=["upload","fileup","fileupload","up","csv up"];
scenario["func-fileupload-msg"]=["File?"];
scenario["func-csv-format-error-msg"]=["CSV format is not good, see the error message","Unacceptable CSV format, see the error message,"];
scenario["func-postcolumn-where-option-msg"]=["Wanna set the \"Where\" sentence? This is an option."];
scenario["func-postcolumn-where-indispensable-msg"]=["Set the \"Where\" sentence. This is an indispensable."];
scenario["func-postcolumn-available-msg"]=["Now you can post them","Do post them","Type \"post\" now"];
scenario["func-subpanel-open-cmd"]=["sub please","subquery","sub panel","where panel","sub query"];
scenario["func-subpanel-opened-msg"]=["Set your sub query in \"Sub Query\" field","Ready to \"Sub Query\" field"];
scenario["func-api-test-msg"]=["Why do not you try it, type \"sql test\" to execute this SQL","Let's check it with typing \"sql check\""];
scenario["func-api-test-cmd"]=["sql test","api test","test sql","test api","sql check","api check","check sql","check api"];
scenario["common-cancel-cmd"]=["cancel","withdraw","abandon","postpone","give up","stop","quit"];
scenario["logout-cmd"]=["logout","exit","log out","out","return","bye","see you","nice day"];
scenario["afterlogout-msg"]=["Bye", "Have a good day","Hope you will back soon","I am looking forward you"];
scenario["unknown-msg"]=["Hey hey hey","Ah.... what?","Could not catch yours, what?","Oh oh oh, what?"];
scenario["hide-something-msg-cmd"]=["hide error","close error","delete error","hide message","close message","delete message"];
scenario["show-something-msg-cmd"]=["show error","open error", "display error","show message","open message","display message"];
config["fileuploadpath"]=["upload file path","up load file","file path","repository"];
config["pg_password"]=["postgres password","database password","password in postgres","password in database"];
config["pg_port"]=["port"];
config["sqllogfile"]=["sql log file","sql log name","sql-name","sql-log"];
config["pg_sslmode"]=["sslmode","ssl mode","ssl"];
config["pg_testdbname"]=["test database"];
config["logfilesize"]=["log file size","log size","log-size"];
config["debug"]=["debug"];
config["pg_user"]=["user","login"];
config["dbtype"]=["db","database","data base"];
config["reading_max_lines"]=["read line numbers for analyzing","analyzing lines","analyzing line numbers","analyzing line number"];
config["logfile"]=["log name","log file name","log-name"];
config["sqllogfilesize"]=["sql log file size","sqllog file size","sql log size","sql log size","sqllog-size"];
config["analyze_interval"]=["analyze interval","analyzing interval"];
config["selectlimit"]=["limit"];
config["pg_dbname"]=["database name","db name","dbname"];
config["pg_host"]=["host"];
config["logfile_rotation_close"]=["rotation end","rotation close"];
config["logfile_rotation_open"]=["rotation start","rotation open"];
