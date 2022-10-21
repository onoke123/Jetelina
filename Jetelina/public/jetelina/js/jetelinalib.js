/*
引数に渡されたオブジェクトを分解取得する。
*/
const getdata = (o) => {
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
                            str += `${name}:${value}`;

                        });

                        // d_tablelistにデータをバインドする
                        $("#d_tablelist").append(`${str}<br>`);
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
            getdata(result);
        }).fail(function (result) {
        });
    } else {
        console.error("ajax url is not defined");
    }
}


const fileupload = () => {
    let fd = new FormData($("#my_form").get(0));
    $("#upbtn").prop("disabled",true);

    $.ajax({
        url: "/dofup",
        type: "post",
        data: fd,
        cache: false,
        contentType: false,
        processData: false,
        dataType: "json",
    }).done(function (result) {
        $("#upbtn").prop("disabled",false);
        let o = result;
        let str = "";

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
                            str += `<div class="item"><p>${name}</p></div>`;
                        });

                        // data bind into drag&drop area
                        $("#container .item_area").append(`${str}`);
                    }
                })
            }
        });
    }).fail(function (result) {
        // something error happened
    });
}

