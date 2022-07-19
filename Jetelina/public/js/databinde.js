$( function(){
    /*
       引数に渡されたオブジェクトを分解取得する。
    */
    const getdata = ( o ) => {
        if( o != null ){
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
                                console.log( name, value );
                                str += `${name}:${value}`;

                            });

                            // showdbdata.htmlのd_dataにデータをバインドする
                            $( "#d_data" ).append( `${str}<br>` );
                        }
                    })
                }

            });
        }
    }

    /*
        ajaxコールしてDBデータをサーバから呼び出す。
        呼び出しに成功したらgetdata()でオブジェクト分解する。
    */
    const getAjaxData = () => {
        $.ajax( {
            url: "/getalldbdata",
            type: "GET",
            data: "",
            dataType: "json",
        }).done(function(result, textStatus, jqXHR) {
            // data parseに行く
            getdata( result );
        }).fail( function( result ){
        });
    }

    getAjaxData();

});
