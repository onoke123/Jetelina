let scenario = [], userresponse = [];

/* null */
scenario['null'] = ['',''];
/* opening */
scenario[0] = ['Hi','Hola'];
userresponse[0] = ['hi','hello','hola','good ','sorry'];
/* greeting */
scenario[1] = ['Nice to see you', 'How are you?'];
scenario['1a'] = ['Nice to hear it', 'Wow, super'];
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
scenario['success'] = ['Done','Success'];
//scenario['6func_in'] = ['Do you wanna open the function panel?'];
scenario['6func'] = ['Let me your command, if you need'];
scenario['6func_post_err'] = ['Hey, no columns','You should select post data','Boo'];
//scenario['6cond_in'] = ['Do you wanna open the condition panel?'];
scenario['6cond'] = ['Let me your command, if you need'];
scenario['6a'] = ['OK, here you are'];
scenario['6b'] = ['Command me, if you need'];
scenario['6func-tabledrop'] = ['drop','drop table','table drop','tabledrop','droptable'];
scenario['6func-tabledrop-msg'] = ['Which table do you want to drop?'];
scenario['6func-tabledrop-confirm'] = ['Sure?'];
scenario['6func-fileupload'] = ['file up','upload','up load','file up load','fileup load','fileupload','up'];
scenario['6func-fileupload-msg'] = ['File?'];
/* log out */
scenario['logout'] = ['logout','exit','log out','out','return'];
scenario['afterlogout'] = ['Bye', 'Have a good day','Hope you will back soon','I am looking forward you'];
