// table delete button
$("#table_delete").hide();
let selectedItemsArr = [];

/*
   action by button click, then do fileupload()
 */
$("#upbtn").on("click", function () {
  fileupload();
  // clean up d&d items, selectbox of the table list
  cleanUp("items");
});

/*
  select DB table then get the columns and be defined SQL(API) list
*/
$("#d_tablelist").on("change", function () {
  let tablename = $("#d_tablelist").val();
  // clean up d&d items
  cleanUp("items");
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
  mouseenter: function (e) {
    let moveLeft = -150/*20*/;
    let moveDown = -90/*10*/;

    $("#pop-up").css('top', e.pageY + moveDown).css('left', e.pageX + moveLeft);

    let d = $(this).attr("d");

    $('div#pop-up').text(d).show();
  },
  mouseleave: function () {
    $('div#pop-up').hide();
  },
  click: function () {
    let cl = $(this).attr("class");
    let item = $(this).text();

    if( $(this).hasClass("selectedItem") ){
      //削除
      deleteSelectedItems(this);
    } else {
      //追加
      if( $.inArray(item,selectedItemsArr) != -1 ){
        $(this).detach();
      }else{
        $(this).addClass("selectedItem");
        $(this).detach().appendTo("#container");
      }

      selectedItemsArr.push(item);
    }
  }
}, ".item");
/*
  選択されているcolumnsを#containerから削除する
*/
const deleteSelectedItems = (p) =>{
  if( p != null ){
    //指定項目削除
    let item = $(p).text();
    selectedItemsArr = selectedItemsArr.filter(elm => {
      return elm !== item;
    });

    $(p).removeClass("selectedItem");
    $(p).detach().appendTo("#columns div");
  }else{
    //全削除
    selectedItemsArr.length = 0;
    $("#container span").removeClass("selectedItem");
    $("#container span").detach().appendTo("#columns div");
  }
}
/*
    cleanUp

    droped items & columns of selecting table
*/
const cleanUp = (s) => {
  selectedItemsArr.splice(0);

  if( s == "items" ){
    // clean up items
    $(".item_area .item").remove();
  }else if( s == "tables" ){
    // clean up tables
    $("#table_container .table").remove();
  }else if( s == "apis" ){
  // clean up API list
  $("#api_container .api").remove();
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
  if (debug) console.log("filename 2 tablename: ", tablename);

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
    if (debug) console.log("set table to select:", tablename);
    const addop = `<option value=${tablename}>${tablename}</option>`;
    $("#d_tablelist").prepend(addop);
    $("#d_tablelist").val(tablename);
  }).fail(function (result) {
    // something error happened
  });
}

/*
    指定されたtableのcolumnを取得する
    一度クリックされると当該tableのclass属性が変わる
    クリック前&２度めのクリック後：table 
    １度目のクリック後　　　　　 ：table activeTable
    この"activeTable"を見てcolumn取得実行の判定を行っている
*/
$(document).on("click", ".table", function () {
  let tn = $(this).text();
  let cl = $(this).attr("class");

  if (debug) {
    console.log("clicked table: ", tn);
    console.log("clicked class: ", cl);
  }

  removeColumn(tn);
  if (cl.indexOf("activeTable") != -1) {
//    removeColumn(tn);
  } else {
    getColumn(tn);
  }

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
      if (debug) console.log("getColumn result: ", result);
      // data parseに行く
      return getdata(result, 1);
    }).fail(function (result) {
    });
  } else {
    console.error("ajax url is not defined");
  }
}

/*
  カラム表示されている要素を指定して表示から削除する
*/
const removeColumn = (tablename) => {
  if (0 < tablename.length || tablename != undefined) {
    $(".item").not(".selectedItem").remove(`:contains(${tablename}.)`);

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
      cleanUp("items");
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

/*
  post selected columns
*/
const postSelectedColumns = () =>{
  let pd = {};
  pd["item"] = selectedItemsArr;
  if( debug ) console.log("post: ", selectedItemsArr, " -> ", pd);
  let dd = JSON.stringify(pd);

  $.ajax({
    url: "/putitems",
    type: "POST",
    data: dd,
    contentType: 'application/json',
    dataType: "json",
    async: false
  }).done(function (result, textStatus, jqXHR) {
    return true;
//    console.log(result);
  }).fail(function (result) {
    return false;
  });
}