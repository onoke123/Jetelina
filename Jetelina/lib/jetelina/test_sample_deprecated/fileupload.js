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
            dataType: "json",
        }).done(function (result) {
            console.log("upload success:" + result);
            let o = result;
            let str = "";

            Object.keys( o ).forEach( function( key ) {
                //’Jetelina’をシンボルにしているからこうしている
                if( key == "Jetelina" && o[key].length > 0 ){
                    $.each( o[key], function(k,v){
                        if( v != null ){
                            /* オブジェクトを配列にしているのでここまでやって
                            　　初めてname/valueのデータが取得できる。
                            */
                            let str = "";
                            $.each( v, function( name, value ){
                                str += `<div class="item"><p>${name}</p></div>`;
                            });

                            // data bind into drag&drop area
                            $( "#container .item_area" ).append( `${str}` );
                        }
                    })
                }
            });
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
