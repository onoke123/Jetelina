/*
    引数に渡されたオブジェクトを分解取得する。
    @o: object
    @t: type  0->db table list, 1->table columns list or csv file columns
*/
const getdata = (o, t) => {
    if (o != null) {
        Object.keys(o).forEach(function (key) {
            /*
                最初にこのカラムのtable nameを取得する
                table list表示のとき(t=0)は'undefined'になるだけ
            */
            const targetTable = o["tablename"];

            //’Jetelina’のvalueはオブジェクトになっているからこうしている  name=>key value=>o[key]
            if (key == "Jetelina" && o[key].length > 0) {
                $.each(o[key], function (k, v) {
                    if (v != null) {
                        let str = "";
                        $.each(v, function (name, value) {
                            if (t == 0) {
                                str += `<option class="tables" value=${value}>${value}</option>`;
                            } else if (t == 1) {
                                // jetelina_delte_flgは表示対象外
                                if (name != "jetelina_delete_flg") {
                                    str += `<div class="item" d=${value}><p>${targetTable}:${name}</p></div>`;
                                }
                            }
                        });

                        let tagid = "";
                        if (t == 0) {
                            tagid = "#d_tablelist";
                        } else if (t == 1) {
                            tagid = "#container .item_area";
                        }

                        $(tagid).append(`${str}`);
                    }
                })
            }
        });

    }
}

let selectedItemsArr = [];
/*
    cleanUp

    droped items & columns of selecting table
*/
const cleanUp = () => {
    selectedItemsArr.splice(0);
    // clean up d&d items
    $(".item_area .item").remove();
}

// 汎用的なajax getコール関数
const getAjaxData = (url) => {
    if (0 < url.length || url != undefined) {
        if (!url.startsWith("/")) url = "/" + url;

        $.ajax({
            url: url,
            type: "GET",
            data: "",
            dataType: "json"
        }).done(function (result, textStatus, jqXHR) {
            // data parseに行く
            getdata(result, 0);
        }).fail(function (result) {
        });
    } else {
        console.error("ajax url is not defined");
    }
}

// 汎用的なajax postコール関数
const postAjaxData = (url, data) => {
    if (0 < url.length || url != undefined) {
        if (!url.startsWith("/")) url = "/" + url;

        $.ajax({
            url: url,
            type: "post",
            contentType: false,
            data: data,
            dataType: "json"
        }).done(function (result, textStatus, jqXHR) {
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

    const uploadFilename = $("input[type=file]").prop("files")[0].name;
    const tablename = uploadFilename.split(".")[0];
    console.log("filename 2 tablename: ", tablename);

    $.ajax({
        url: "/dofup",
        type: "post",
        data: fd,
        cache: false,
        contentType: false,
        processData: false,
        dataType: "json"
    }).done(function (result) {
        // clean up
        $("input[type=file]").val("");
        $("#upbtn").prop("disabled", false);
        getdata(result, 1);
        // talbe list に追加してfocusを当てる
        console.log("set table to select:", tablename);
        const addop = `<option class="tables" value=${tablename}>${tablename}</option>`;
        $("#d_tablelist").prepend(addop);
        $("#d_tablelist").val(tablename);
    }).fail(function (result) {
        // something error happened
    });
}

/*
    指定されたtableのcolumnを取得する
*/
const getColumn = (tablename) => {
    if (0 < tablename.length || tablename != undefined) {
        //        let data = [];
        //        data.push( $.trim(tablename));

        let pd = {};
        pd["tablename"] = $.trim(tablename);
        let dd = JSON.stringify(pd);

        $.ajax({
            url: "/getcolumns",
            type: "post",
            data: dd,
            contentType: 'application/json',
            dataType: "json"
        }).done(function (result, textStatus, jqXHR) {
            // data parseに行く
            return getdata(result, 1);
        }).fail(function (result) {
        });
    } else {
        console.error("ajax url is not defined");
    }
}

const deleteThisTable = (tablename) => {
    if (0 < tablename.length || tablename != undefined) {
        //        let data = [];
        //        data.push( $.trim(tablename));

        let pd = {};
        pd["tablename"] = $.trim(tablename);
        let dd = JSON.stringify(pd);

        $.ajax({
            url: "/deletetable",
            type: "post",
            data: dd,
            contentType: 'application/json',
            dataType: "json"
        }).done(function (result, textStatus, jqXHR) {
        }).fail(function (result) {
        }).always(function (jqXHR, textStatus) {
            // table list 更新
            // clean up selectbox of the table list
            //$( "#d_tablelist .tables" ).remove();


            // clean up d&d items
            //            $(".item_area .item").remove();
            cleanUp();
            // select から当該tableを削除する
            $("#d_tablelist").children(`option[value=${tablename}]`).remove();
            //            getAjaxData("getalldbtable");
            // deleteボタンを非表示にする
            $("#table_delete").hide();
        });
    } else {
        console.error("ajax url is not defined");
    }
}