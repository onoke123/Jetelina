// table delete button
$("#table_delete").hide();

/* jetelinalib.jsのgetAjaxData()を呼び出して、DB上の全tableリストを取得する
   ajaxのurlは'getalldbtable'
 */
getAjaxData("getalldbtable");

/*
   action by button click, then do fileupload()
 */
$("#upbtn").on("click", function () {
  fileupload();
  // clean up d&d items, selectbox of the table list
  cleanUp();
});

/*
  select DB table then get the columns and be defined SQL(API) list
*/
$("#d_tablelist").on("change", function () {
  let tablename = $("#d_tablelist").val();
  // clean up d&d items
  cleanUp();
  // get the column list
  $("#container .item_area").append(getColumn(tablename));
  // show table delete button
  $("#table_delete").show();

  // get the SQL(API) list
  postAjaxData("/getapi", `{"tablename":"${tablename}"}`);
});
/*
*/
$("#table_delete").on("click", function () {
  let tablename = $("#d_tablelist").val();
  deleteThisTable(tablename);
});
/*
  tooltip for columns list
*/
$(document).on({
  mouseenter: function () {
    let d = $(this).attr("d");

    $('div#pop-up').text(d).show();
  },
  mouseleave: function () {
    $('div#pop-up').hide();
  }
}, ".item");

let moveLeft = 20;
let moveDown = 10;
$(document).on({
  mousemove: function (e) {
    $("div#pop-up").css('top', e.pageY + moveDown).css('left', e.pageX + moveLeft);
  }
}, ".item");
/*
$('.item').mousemove(function (e) {
  $("div#pop-up").css('top', e.pageY + moveDown).css('left', e.pageX + moveLeft);
});
*/
let selectedItemsArr = [];
/*
    cleanUp

    droped items & columns of selecting table
*/
const cleanUp = () => {
    selectedItemsArr.splice(0);
    // clean up d&d items
    $(".item_area .item").remove();
    // clean up sql list
    $("#sqllist .list").remove();
}


/*
    CSV file upload
*/
const fileupload = () => {
    let fd = new FormData($("#my_form").get(0));
    $("#upbtn").prop("disabled", true);

    const uploadFilename = $("input[type=file]").prop("files")[0].name;
    const tablename = uploadFilename.split(".")[0];
    if( debug ) console.log("filename 2 tablename: ", tablename);

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
        if( debug ) console.log("set table to select:", tablename);
        const addop = `<option value=${tablename}>${tablename}</option>`;
        $("#d_tablelist").prepend(addop);
        $("#d_tablelist").val(tablename);
    }).fail(function (result) {
        // something error happened
    });
}

/*
    指定されたtableのcolumnを取得する
*/
$(document).on("click",".table",function(){
  console.log("class: ", $(this).attr("class"));
  $(this).toggleClass("activeTable");
});

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
            if( debug ) console.log("getColumn result: ", result);
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
