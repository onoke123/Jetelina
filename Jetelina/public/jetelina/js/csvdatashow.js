$( function(){
    /*
       引数に渡されたオブジェクトを分解取得する。
    */
    const getdata = ( o ) => {
        if( o != null ){
            Object.keys( o ).forEach( function( key ) {
                //’Jetelina’をシンボルにしているからこうしている
                if( key == "Jetelina" && o[key].length > 0 ){
                    let str = "";
                    $.each( o[key], function(k,v){
                        if( v != null ){
                            /* オブジェクトを配列にしているのでここまでやって
                            　　初めてname/valueのデータが取得できる。
                            */
                            $.each( v, function( name, value ){
                                //str += `${name}:${value}`;
                                str += `<div class="item"><p>${name}</p></div>`;
                            });

                            // data_edit.htmlに表示するが、1行だけあればいいのでここでブレイク
                            return false;
                        }
                    })

                    //csvファイルの「項目」を表示する
                    $( "#container .item_area" ).append( `${str}`);
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
            url: "/getcsvdata",
            type: "GET",
            data: "",
            dataType: "json",
        }).done(function(result, textStatus, jqXHR) {
            console.log( result );
            // data parseに行く
            getdata( result );
        }).fail( function( result ){
        });
    }

    getAjaxData();

});
