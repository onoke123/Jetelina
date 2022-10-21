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

});