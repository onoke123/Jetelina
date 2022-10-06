/*
    use in fileupload.html
*/
$(function () {
    /*
        body of real file upload
    */
    const fileupload = () => {
        let fd = new FormData( $( "#my_form" ).get(0) );

        $.ajax({
            url: "/dofup",
            type: "post",
            data: fd,
            cache: false,
            contentType: false,
            processData: false,
            dataType: "html",
        }).done(function (result) {
            console.log("upload success:" + result);
        }).fail(function (result) {
            // something error happened
        });
    }

    /*
       action by button click, then do fileupload()
    */
    $("#upbtn").on("click", function () {
        fileupload();
    });
});
