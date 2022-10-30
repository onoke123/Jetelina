/*
    引数に渡されたオブジェクトを分解取得する。
    @o: object
    @t: type  0->db table list, 1->table columns list or csv file columns
*/
const getdata = (o, t) => {
    if (o != null) {
        Object.keys(o).forEach(function (key) {
            //’Jetelina’をシンボルにしているからこうしている
            if (key == "Jetelina" && o[key].length > 0) {
                $.each(o[key], function (k, v) {
                    if (v != null) {
                        /* オブジェクトを配列にしているのでここまでやって
                          初めてname/valueのデータが取得できる。
                        */
                        let str = "";
                        $.each(v, function (name, value) {
                            if( t == 0 ){
                                str += `<option value=${value}>${value}</option>`;
                            }else if( t == 1 ){
                                str += `<div class="item"><p>${value}</p></div>`;
                            }
                        });

                        let tagid = "";
                        if (t == 0) {
                            tagid = "#d_tablelist";
                        } else if (t == 1) {
                            tagid = "#container .item_area";
                        }

                        $( tagid ).append(`${str}`);
                    }
                })
            }

        });
    }
}

// 画面起動時にDBのtableリストを取得する
const getAjaxData = (url) => {
    if (0 < url.length || url != undefined) {
        if (!url.startsWith("/")) url = "/" + url;

        $.ajax({
            url: url,
            type: "GET",
            data: "",
            dataType: "json",
        }).done(function (result, textStatus, jqXHR) {
            // data parseに行く
            getdata(result, 0);
        }).fail(function (result) {
        });
    } else {
        console.error("ajax url is not defined");
    }
}

/*
    CSV file upload
*/
const fileupload = () => {
    let fd = new FormData($("#my_form").get(0));
    $("#upbtn").prop("disabled", true);

    $.ajax({
        url: "/dofup",
        type: "post",
        data: fd,
        cache: false,
        contentType: false,
        processData: false,
        dataType: "json",
    }).done(function (result) {
        $("#upbtn").prop("disabled", false);
        getdata( result, 1 );
        /*
        let o = result;
        let str = "";

        Object.keys(o).forEach(function (key) {
            //’Jetelina’をシンボルにしているからこうしている
            if (key == "Jetelina" && o[key].length > 0) {
                $.each(o[key], function (k, v) {
                    if (v != null) {
                        // オブジェクトを配列にしているのでここまでやって
                        //  初めてname/valueのデータが取得できる。
                        //
                        let str = "";
                        $.each(v, function (name, value) {
                            str += `<div class="item"><p>${name}</p></div>`;
                        });

                        // data bind into drag&drop area
                        $("#container .item_area").append(`${str}`);
                    }
                })
            }
        });*/
    }).fail(function (result) {
        // something error happened
    });
}

/*
    指定されたtableのcolumnを取得する
*/
const getColumn = (tablename) => {
    if (0 < tablename.length || tablename != undefined) {
        tablename = trim(tablename);

        $.ajax({
            url: "/getColumn",
            type: "post",
            data: "",
            dataType: "json",
        }).done(function (result, textStatus, jqXHR) {
            // data parseに行く
            getdata(result, 1);
        }).fail(function (result) {
        });
    } else {
        console.error("ajax url is not defined");
    }
}