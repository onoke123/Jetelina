You may imagine or expect to me as alike Tomcat and/or Rails that are able to manage Databases and WebAPIs.
Well, it does not hit the center, but OK, let’s start to there. You see what I am in my video(https://jetelina.org/im-happy-you-wanna-know-me-more/)

1.Who I am

2.What I am

3.Where I am

4.When I am

5.How I am

6.Which I am

7.JSON! JSON! JSON!

1.Who I am

I am a server side program ‘who’ is written in Julia. I am very friendly, but not AI.

2.What I am

I can handle some data base, PostgreSQL/MySQL/Redis/MongoDB, at once. ‘at once’ meaning is ‘coexistence’. Of course you can choose only one data base as usal.
‘handle’ meaning is ‘create table’, ‘create DBI’, ‘publish the DBI as WebApi’, and of course can execute the DBI/WebApi both in real and in testing.

3.Where I am

I work between HTTPD server and Data Base, see below figure. Simply I pass the data from a data base to the httpd. The data form is JSON and the data are depend on the DBI that is created by you and me.

4.When I am

Oops, this is a difficult to answer. You touch me when you need to create a new DBI/WebApi, table, add new data….. and so on. And may you sometime wann see my conditions: WebApi execution speed, access numbers….. Or when you are in down. (^o^)v

5.How I am

Yes, I can explain this clearly. The details are in ‘How to use(https://jetelina.org/how-to-use-me/)‘ for (1)-(3) and ‘How to call()https://jetelina.org/how-to-call-your-created-webapis/‘ for (2).

(1)create table on database: by uploading a csv file to me.

(2)create DBI: you can create ‘select’ and ‘update’ DBIs by selecting table columns, ‘insert’ and ‘delete’ DBIs are under my control.

(3)publish the DBI as WebApi: each DBI has its unique api name, this is to be the WebApi name, you just call the name.

(4)execute the DBI/WebApi: order me with typing ‘test api’…. then i guide you

6.Which I am

I know every present applications, no matter which client side or server side, are operated by ‘click icons’ and/or ‘entering commands on a screen’.
These are developed in progressing computer systems. ‘Icons’ are be friendly, imagiable the functions, ‘commands’ are be known by dectating in many blogs. But you have to learn their meaning, location on the screen everytimes when you start to use them. These ‘knowladge’ is called ‘skill’ and ‘experience’. Is that true? Know them or not makes a hierarchy as a beginner or an expert.
However, you may had an experience in shouting, ‘I just wanna upload this file to there, but can’t find a proper function in icons, or do not know the command to run it’. You may think “do everything if i asked ‘upload’”. This is very natural.
In my case, you just type ‘wanna upload file’ or just ‘file uplaod’, adding ‘please’ is more friendly to me, e.g ‘file uplaod please’.＼(^o^)／
Like that, you do not need to study how to do something anymore, just ask me what you wanna do in our chatbox.

7.JSON! JSON! JSON!

Every data is passed in JSON. I mean no matter which Plan A and Plan B, Please refer the form in ‘How to call(https://jetelina.org/how-to-call-your-created-webapis/)‘.

--------------------------------------------------------------------------------------------------------------------
Installing 

You can see how to install me into your server on the video(https://jetelina.org/im-happy-you-wanna-know-me-more/).

1.insall julia

The first of all, you must install julia(10<=) into yours. Here is the dl site.

2.install database which you wanna use

May you already have it, but if not yet, I can handle PostgreSQL/MySql/Redis/MongoDB.
I do not guide you about them because you can find numerous information on the net.

3.install Jetelina

(1) down load me from this site.

(2) defrost me at your favorite path.

(3) go to my ‘../Jetelina/bin‘ path and type ‘repl‘ command in your console.

(4) at the very first time, you will see I’m fetching some libs to fit me with your environment.

(5) and finally I am ready to start.

(6) type ‘up()‘ to start Genie httpd. Indeed I work on it.

(7) type ‘exit()‘ is to stop Genie httpd, meaning me, and go out from the ‘>julia‘ env.

You may noticed ‘repl -> up()‘ is for interactive server running, I mean the server is halted if you closed the console.
The ‘bin/server‘ is for runing it as a background process, but as you know some system call ‘hup‘ signal when you close the console, in that case this may will help you.

(a) install ‘nohup‘ into you system. Google how to do it. :p

(b) use ‘bin/jetelina_kickstart‘ instead of ‘bin/server‘

This ‘bin/jetelina_kickstart‘ script command is calling ‘bin/server‘ with ‘nohup‘.
Attention: expect ‘nohup’ in ‘/usr/bin/nohup’, you should change in ‘jetelina_kickstart’ file with your env.
Initialize me
Access to me: e.g http://localhost:8000/jetelina, to initialize me, after raising ‘up()’.

--------------------------------------------------------------------------------------------------------------------

Initialize Jetelina

The procedure is shown in here(https://jetelina.org/initialize-me/) with some screen shots. Please refer it as well.

After successing to kick start to me, let initialize me.
No matter which type database you use, one RDBMS is necessary to manage in me. You can select PostgreSQL or MySql. And users information who play with me are stocked in the RDBMS.

1.login to me with the initial account

2.select your primary RDBMS
3.register the generation ‘0’ users

1.login to me with the initial account

Before ‘3’, no one can access to me because there are not any users. The users are registered in PostgreSQL or MySQL. Therefore you have to start to initialize me at first.
Let’s login to me with ‘it is me‘ that is the initial login acount. You type this in our chatbox when I ask you your name.

2.select your primary RDBMS

I show you the connection parameters in order to your selection.
In case of PostgreSQL. You can see the basic parameters in there, and set your own parameters. Attention, the ‘dbname’ must exist.
In case of MySQL. Set your own params in there as well, but attentions,

a) the ‘dbname’ must exist

b) the ‘unix_socket’ is different on Linux and Mac

Set all and click ‘SET & Try to connect’, then transfer to ‘2’, but if faild, you may should change some parameters then try again.
If the errors make you confuse adn lost the way,

i ) clean up your selected RDBMS

・PostgreSQL: drop tables in ‘postgres’ database

・MySQL: drop database ‘jetelina’ if has been created

ii ) initialize ~/Jetelina/app/resources/config/JetelinaConfig.cnf by using the download file

i mean swap the file.

3.register the generation ‘0’ users

The user register is displayed after successing to connect your RDBMS, then input your generation ‘0’ users, ref the meaning ‘user generation’.

Click ‘Register Users’ after filling them.
This is the successing screen, then let’s play with me by clickin’ ‘GO LOGIN’.
