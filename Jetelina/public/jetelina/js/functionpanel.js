// table delete button
$("#table_delete").hide();
let selectedItemsArr = [];

/*
   change label when selected a file
*/
$("input[name='upfile']").on("change", function () {
  $("#my_form label span").text($("input[type=file]").prop("files")[0].name);
});
/*
  select DB table then get the columns and be defined SQL(API) list

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
*/
/*

$("#table_delete").on("click", function () {
  let tablename = $("#d_tablelist").val();
  deleteThisTable(tablename);
});
*/
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

    if ($(this).hasClass("selectedItem")) {
      //削除
      deleteSelectedItems(this);
    } else {
      //追加
      if ($.inArray(item, selectedItemsArr) != -1) {
        $(this).detach();
      } else {
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
const deleteSelectedItems = (p) => {
  if (p != null) {
    //指定項目削除
    let item = $(p).text();
    selectedItemsArr = selectedItemsArr.filter(elm => {
      return elm !== item;
    });

    $(p).removeClass("selectedItem");
    $(p).detach().appendTo("#columns div");
  } else {
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

  if (s == "items") {
    // clean up items
    $(".item_area .item").remove();
  } else if (s == "tables") {
    // clean up tables
    $("#table_container .table").remove();
  } else if (s == "apis") {
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
  if (debug) console.log("fileupload(): ", tablename);

  $.ajax({
    url: "/dofup",
    type: "post",
    data: fd,
    cache: false,
    contentType: false,
    processData: false,
    dataType: "json"
  }).done(function (result, textStatus, jqXHR) {
    // clean up
    $("input[type=file]").val("");
    $("#upbtn").prop("disabled", false);

    if (result.length != 0) {
      $("#my_form label span").text("Upload CSV File");

      //refresh table list 
      if ($("#table_container").is(":visible")) {
        cleanUp("tables");
        getAjaxData("getalldbtable");
      }

      typingControll(chooseMsg('success', "", ""));
    } else {
      console.log("fup here");
    }
  }).fail(function (result) {
    // something error happened
    console.error("fileupload() failed");
  });
}

/*
    指定されたtableのcolumnを取得する
    一度クリックされると当該tableのclass属性が変わる
    クリック前&２度めのクリック後：table 
    １度目のクリック後　　　　　 ：table activeItem
    この"activeItem"を見てcolumn取得実行の判定を行っている
*/
$(document).on("click", ".table,.api", function () {
  listClick($(this));
  /*  let tn = $(this).text();
    let cl = $(this).attr("class");
  
    if (debug) {
      console.log("clicked table: ", tn);
      console.log("clicked class: ", cl);
    }
  */
});

/*
  指定されたJsonデータから指定されたデータを取得する
  o:Json object
  k:取得対象データ

  return　対象データ
*/
const getdataFromJson = (o, k) => {
  const Jkey = 'Jetelina';
  let ret = "";
  Object.keys(o).forEach(function (key) {
    //’Jetelina’のvalueはオブジェクトになっているからこうしている  name=>key value=>o[key]
    let row = 1, col = 1;
    if (key == Jkey && o[key].length > 0) {
      $.each(o[key], function (n, v) {
        $.each(v, function (name, value) {
          if (value == k) {
            ret = v.sql;
            return false;
          }
        });
      });
    }
  });

  return ret;
}

const listClick = (p) => {
  let t = p.text();
  let c = p.attr("class");

  removeColumn(t);
  if (c.indexOf("activeItem") != -1) {
    //    removeColumn(tn);
    p.toggleClass("activeItem");
  } else {
    if (c.indexOf("table") != -1) {
      //get&show table columns
      getColumn(t);
    } else {
      // reset all activeItem class and sql
      cleanupItems4Switching();
      cleanupContainers();
//      $("#api_container span").removeClass("activeItem"); 
//      $("#container span").remove();

      // API ListはpostAjaxData("/getapilist",...)で取得されてpreferent.apilistにあるので、ここから該当SQLを取得する
      if (preferent.apilist != null && preferent.apilist.length != 0) {
        let s = getdataFromJson(preferent.apilist, t);
        if( 0<s.length ){
          $("#container").append(`<span class="apisql"><p>${s}</p></span>`);
          // api in/out json
          let in_if = setApiIF_In(t,s);
          $("#columns .item_area").append(`<span class="apisql apiin"><bold>IN:</bold>${in_if}</span>`);
          let in_out = setApiIF_Out(t,s);
          $("#columns .item_area").append(`<span class="apisql apiout"><bold>OUT:</bold>${in_out}</span>`);
        }
      }
    }

    //  $(this).toggleClass("activeItem");
    p.toggleClass("activeItem");
  }
}

const setApiIF_In =(t,s) =>{
  return "AAA";
}
/*
   基本、select文しかOutはない。
*/
const setApiIF_Out =(t,s) =>{
  let ret = "";

  if( t.toLowerCase().startsWith("js") ){
    let pb = s.split("select");
    let pf = pb[1].split("from");
    // pf[0]にselect項目があるはず
    if( pf[0] != null && 0<pf[0].length ){
      let c = pf[0].split(",");
      for( let i=0; i< c.length; i++ ){
        let cn = c[i].split('.');
        if(ret.length == 0 ){
          ret = "{Jetelina:[{";
        }else{
          ret = `${ret}\"${cn[1].trim()}:\"&lt;your data&gt;\",`;
        }
      }
    }
  }

  if( 0<ret.length ){
    ret = ret.slice(0,ret.length-1);//冗長な最後の","から前を使う
    ret = `${ret}]}`;
  }

  return ret;
}

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
      /*
        本当はここに来るはずなのに、何故かこのajax処理はfail()してしまう。
        サーバサイドのDB処理は一応正常に終了しているので、原因がわかるまでは
        done()の処理をalways()で行うようにしている。
      */
      console.log("deleteThisTable: tablename result -> ", result);
    }).fail(function (result) {
      console.error("deletetable() faild: ", result);
    }).always(function () {
      $(`#table_container span:contains(${tablename})`).filter(function () {
        if ($(this).text() === tablename) {
          $(this).remove();
          return;
        }
      });

      typingControll(chooseMsg('success', "", ""));
    });
  } else {
    console.error("deletetable: table is not defined");
  }
}

/*
  post selected columns
*/
const postSelectedColumns = () => {
  let pd = {};
  pd["item"] = selectedItemsArr;
  if (debug) console.log("post: ", selectedItemsArr, " -> ", pd);
  let dd = JSON.stringify(pd);

  $.ajax({
    url: "/putitems",
    type: "POST",
    data: dd,
    contentType: 'application/json',
    dataType: "json",
    async: false
  }).done(function (result, textStatus, jqXHR) {
    /*
     本当はここに来るはずなのに、何故かこのajax処理はfail()してしまう。
     サーバサイドのDB処理は一応正常に終了しているので、原因がわかるまでは
     done()の処理をalways()で行うようにしている。
   */
    console.log("postSele... :", result);
  }).fail(function (result) {
    console.log("postSele... fail");
  }).always(function () {
    typingControll(chooseMsg('success', "", ""));
  });
}