let scenario = [], userresponse = [];

/* null */
scenario['null'] = ['',''];
/* command list order */
scenario['command_list'] = ["show command","what can i","what can you","how start","where can i"];
/* opening */
scenario[0] = ['Hi','Hello'];
userresponse[0] = ['hi','hello','hola','good ','sorry'];
scenario['bura'] = ['Hi Ho','Fun fun fun','Someone is there?','Waiting for.....','Do you know the meaning of .... love?'];
/* greeting */
scenario[1] = ['Nice to see you', 'How are you?'];
scenario['1a'] = ['Nice to hear it', 'Wow, super','lucky you'];
userresponse[1] = ['fine','good','sorry'];
/* login */
scenario[2] = ['Could you give me your name?',"Let me know your name, please","May I ask your name?"];
/* etc */
scenario[3] = ['What?','Are you kidding me?','Never mind'];
/* miss login */
scenario[4] = ['I am sorry, but ', 'Something wrong, hum, '];
/* greeting to u after successing login */
scenario[5] = [`Welcome `, `I missed you, `];
/* after login */
scenario[6] = ['How can I help you today?', 'What do you do now?'];
scenario['success'] = ['Done','Success','I am so happy','Yes'];
scenario['fail'] = ['Uge','Noooooooo','Sorry something wrong'];
scenario['confirmation-sentences'] = ['yes','sure','why not','do it','do','i want to do it','i wanna do it','kick ass'];
//scenario['6func_in'] = ['Do you wanna open the function panel?'];
scenario['6func'] = ['Let me your command, if you need'];
scenario['6func_post_err'] = ['Hey, no columns','You should select post data','Boo'];
//scenario['6cond_in'] = ['Do you wanna open the condition panel?'];
scenario['6cond'] = ['Let me your command, if you need'];
scenario['6cond-graph-show'] = ['here you are','tatta laan'];
scenario['6cond-graph-show-keywords'] = ['graph','graphic','figure','zu'];
scenario['6cond-performance-graph-show-keywords'] = ['performance','suggest','perf','zu'];
scenario['6cond-performance-improve'] = ['There is an improve suggestion.'];
scenario['6a'] = ['OK, here you are'];
scenario['6b'] = ['Command me, if you need'];
scenario['6func-cleanup-cmd'] = ['refresh','cleanup','clean'];
scenario['6func-tabledrop-cmd'] = ['drop','drop table','table drop','tabledrop','droptable'];
scenario['6func-tabledrop-msg'] = ['Which table do you want to drop?'];
scenario['6func-tabledrop-ng-msg'] = ['Hey open the table list first!','Huum?','Check it first','Watch it'];
scenario['6func-tabledrop-confirm'] = ['Sure?'];
scenario['6func-fileupload-open-cmd'] = ['open','file open','open the file box','open file box','open filebox','file box','csv file','csv file select','choose csv file'];
scenario['6func-fileupload-open-msg'] = ['Which file?'];
scenario['6func-fileupload-cmd'] = ['file up','upload','up load','file up load','fileup load','fileupload','up'];
scenario['6func-fileupload-msg'] = ['File?'];
scenario['6func-postcolumn-where-option-msg'] = ['Wanna set the \'Where\' sentence? This is an option.'];
scenario['6func-postcolumn-where-indispensable-msg'] = ['Set the \'Where\' sentence. This is an indispensable.'];
scenario['6func-subpanel-open-cmd'] = ['oepn subquery panel','open sub panel','sub please','subquery panel please','subquery panel','subquery','sub panel','where panel'];

/* log out */
scenario['logout'] = ['logout','exit','log out','out','return','have a nice day', 'bye','see you'];
scenario['afterlogout'] = ['Bye', 'Have a good day','Hope you will back soon','I am looking forward you'];
/* unknow command */
scenario['unknown-msg'] = ['Hey hey hey','Ah.... what?','Could not catch yours, what?','Oh oh oh, what?'];
