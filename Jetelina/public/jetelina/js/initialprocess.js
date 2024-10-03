/**
 * JS library for Jetelina initialization
 * @author Ono Keiji
 * 
 * This js lib is for initializing Jetelina database at the very first season.
 * I mean the first user who is trying to start Jetelina must decide the initial database
 * that contains jetelina user table. This determined database is the primary database in Jetelina.
 * 
 * Functions:
 *      jetelinaInitialize() initialize the primary database that is selected by the first user(it's me)
 */
const initialparams = {};
const INITIALIZEPANEL = "#initialize";
const POSTGREINITIALIZE = `${INITIALIZEPANEL} [name='params4postgres']`;
const MYSQLINITIALIZE = `${INITIALIZEPANEL} [name='params4mysql']`;
const SETBUTTON = `${INITIALIZEPANEL} [name='paramsetbutton']`;
/**
 * @function jetelinaInitialize
 * 
 * initialize the primary database that is selected by the first user(it's me)
 * 
 */
const jetelinaInitialize = () =>{
    /*
        1.display database selection panel
        2.display database connection parameters that is selected database
        3.post these parameter to update
        4.connection check and create jetelina_user_table
        5.generation '0' user register
        6.switch to the normal login screen 
    */
   $(`${INITIALIZEPANEL}`).show();
}

$("#initialize input[name='primarydb']").on("click",function(){
    initialparams.db = $(this).val();
    $(SETBUTTON).show();

    if(initialparams.db == "postgresql"){
        $(POSTGREINITIALIZE).show();
        $(MYSQLINITIALIZE).hide();
    }else{
        $(POSTGREINITIALIZE).hide();
        $(MYSQLINITIALIZE).show();
    }    
});

$(SETBUTTON).on('click',function(){
    let data = {};

    if(initialparams.db == "postgresql"){
        let host = $(`${POSTGREINITIALIZE} input[name='pg_host']`).val();
        let port = $(`${POSTGREINITIALIZE} input[name='pg_port']`).val();
        let user = $(`${POSTGREINITIALIZE} input[name='pg_user']`).val();
        let pw = $(`${POSTGREINITIALIZE} input[name='pg_password']`).val();
        let dbname = $(`${POSTGREINITIALIZE} input[name='pg_dbname']`).val();

        data = `{"jetelinadb":"${initialparams.db}","dbtype":"${initialparams.db}","pg_work":"true","pg_host":"${host}","pg_port":"${port}","pg_user":"${user}","pg_password":"${pw}","pg_dbname":"${dbname}"}`;
    }else{
        let host = $(`${MYSQLINITIALIZE} input[name='my_host']`).val();
        let port = $(`${MYSQLINITIALIZE} input[name='my_port']`).val();
        let user = $(`${MYSQLINITIALIZE} input[name='my_user']`).val();
        let pw = $(`${MYSQLINITIALIZE} input[name='my_password']`).val();
        let dbname = $(`${MYSQLINITIALIZE} input[name='my_dbname']`).val();
        let unix_socket = $(`${MYSQLINITIALIZE} input[name='my_unix_socket']`).val();

        data = `{"jetelinadb":"${initialparams.db}","dbtype":"${initialparams.db}","my_work":"true","my_host":"${host}","my_port":"${port}","my_user":"${user}","my_password":"${pw}","my_dbname":"${dbname}","my_unix_socket":"${unix_socket}"}`;
    }

    initialAjax(data);
});

const initializeMsg = (s) =>{
    $(`${INITIALIZEPANEL} [name='message']`).text(s);
}

const initialAjax = (data) =>{
    $.ajax({
        url: "/initial",
        type: "post",
        contentType: 'application/json',
        data: data,
        async:false,
        dataType: "json",
    }).done(function (result, textStatus, jqXHR) {
        if(result.result){
            initializeMsg("Done, congra ＼(^o^)／, clike 'GO..' next");
            $(`${INITIALIZEPANEL} [name='paramsetbutton']`).hide();
            $(`${INITIALIZEPANEL} [name='gologinbutton']`).show();
        }else{
            initializeMsg("Fail to connect, review the parameters once more.");
        }
    }).fail(function (result) {
        console.error("initialAjax() fail");
    }).always(function () {
    });
}