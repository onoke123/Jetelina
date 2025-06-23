You may imagine or expect me to be like Tomcat and/or Rails that can manage Databases and Web APIs.
Well, it does not hit the center, but OK, let’s start there. Indeed, I am in there.　This video may help you understand me quickly, and some videos are as well.

Who am I
What am I
Where am I
When I am
How I am
Which I am
JSON! JSON! JSON!
Who am I
I am a server-side program that is written in Julia. I am very friendly, but not AI.
2. What am I
I can handle multiple databases, such as PostgreSQL, MySQL, Redis, and MongoDB, simultaneously. Simultaneously means ‘coexistence’. Of course, you can choose only one database as usual.
‘handle’ meaning is ‘create table’, ‘create DBI’, ‘publish the DBI as WebApi’, and of course, can execute the DBI/WebApi both in real and in testing.

3. Where am I
I work between the HTTPD server and the Database, as shown in the figure below. I pass the data from a database to the httpd. The data form is in JSON format, and the data depends on the DBI that you and I created.

4. When I am
Oops, this isn’t easy to answer. You use me when you need to create a new DBI/WebApi, table, add new data, and so on. And may you sometime want to see my conditions: WebApi execution speed, access numbers, or when you are down. (^o^)v

5. How am I
Yes, I can explain this clearly. The details are in ‘How to use …’ for (1)-(3) and ‘How to call …’ for (2).
(1) Create a table on the database by uploading a CSV file to me.
(2)create DBI: you can create ‘select’ and ‘update’ DBIs by selecting table columns, ‘insert’ and ‘delete’ DBIs are under my control.
(3) Publish the DBI as a Web API: Each DBI has its unique API name, which is to be the Web API name; you call this name.
(4) Execute the DBI/WebApi: order me with typing ‘test api’…. then I will guide you

6. Which I am
I know every present application, no matter which client side or server side, is operated by ‘click icons’ and/or ‘entering commands on a screen’.
These are developed in progressing computer systems. ‘Icons’ are friendly, imagable, the functions, ‘commands’ are known by describing them in many blogs. However, you must learn their meaning and location on the screen each time you start using them. This ‘knowledge’ is called ‘skill’ and ‘experience’. Is that true? Knowing them or not makes a hierarchy between a beginner and an expert.
However, you may have had an experience where you shouted, ‘I just wanna upload this file there, but can’t find a proper function in icons, or do not know the command to run it.’ You may think “do everything if i asked ‘upload’”. This is very natural.
In my case, you can type ‘wanna upload file’ or just ‘file upload’. Adding ‘please’ is more friendly, e.g., ‘file upload please’.＼(^o^)／
That way, you don’t need to study how to do something anymore; ask me what you want to do in our chatbox.

7.JSON! JSON! JSON!
All data is passed in JSON. I mean, no matter which Plan A or Plan B, please refer to the form in ‘How to call…’.

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
