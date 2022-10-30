$(window).load(function () {
    /* jetelinalib.jsのgetAjaxData()を呼び出して、DB上の全tableリストを取得する
       ajaxのurlは'getalldbtable'
     */
    getAjaxData("getalldbtable");

    /*
       action by button click, then do fileupload()
     */
    $("#upbtn").on("click", function () {
        fileupload();
    });

    /*
      select DB table then get the columns and be defined SQL(API) list
    */
    $( "#d_tablelist" ).change( function(){
        console.log("selected");

        // get the column list
        // get the SQL(API) list
    });
});