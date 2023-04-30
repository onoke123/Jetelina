/*
    JS library for Jetelina Function Panel
    ver 1
    Author : Ono Keiji
    
    Functions:
      deleteSelectedItems(p) 選択されているcolumnsを#containerから削除する
      cleanUp(s) cleanUp droped items & columns of selecting table
      fileupload() CSV file upload
      getdataFromJson(o,k) 指定されたJsonデータから指定されたデータを取得する
      listClick(p)   Table list / API listをクリックした時の処理 
      setApiIF_In(t,s) API　IN Json
      setApiIF_Out(t,s) API OUT Json
      buildJetelinaJsonForm(t,s)  API IN/OUT　Json
      getColumn(tablename) 指定されたtableのカラムデータを取得する
      removeColumn(tablename) カラム表示されている要素を指定して表示から削除する
      deleteThisTable(tablename)　指定されたtableをDBから削除する
      postSelectedColumns() post selected columns
      functionPanelFunctions(ut, cmd)　Function Panel 機能操作
      procTableApiList(s) チャットでtable/apiの操作を行う
*/
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
  click:
    function () {
      itemSelect($(this));
    }
}, ".item");

const itemSelect = (p) => {
  let cl = p.attr("class");
  let item = p.text();

  if (p.hasClass("selectedItem")) {
    //削除
    deleteSelectedItems(p);
  } else {
    //追加
    if ($.inArray(item, selectedItemsArr) != -1) {
      p.detach();
    } else {
      p.addClass("selectedItem");
      p.detach().appendTo("#container");
    }

    selectedItemsArr.push(item);
  }
}
/*
  選択されているcolumnsを#containerから削除する
*/
const deleteSelectedItems = (p) => {
  let ret = false;

  if (p != null) {
    //指定項目削除
    let item = $(p).text();
    selectedItemsArr = selectedItemsArr.filter(elm => {
      return elm !== item;
    });

    $(p).removeClass("selectedItem");
    $(p).detach().appendTo("#columns div");
    ret = true;
  } else {
    //全削除
    selectedItemsArr.length = 0;
    $("#container span").removeClass("selectedItem");
    $("#container span").detach().appendTo("#columns div");
    ret = true;
  }

  return ret;
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
  if (debug) console.info("fileupload(): ", tablename);

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

    if (result) {
      $("#my_form label span").text("Upload CSV File");

      //refresh table list 
      if ($("#table_container").is(":visible")) {
        cleanUp("tables");
        getAjaxData("getalldbtable");
      } else {
        typingControll(chooseMsg('success', "", ""));
      }
    } else {
      typingControll(chooseMsg('fail', "", ""));
    }
  }).fail(function (result) {
    // something error happened
    console.error("fileupload() failed");
    typingControll(chooseMsg('fail', "", ""));
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
/*
   Table list / API listをクリックした時の処理 
*/
const listClick = (p) => {
  let t = p.text();
  let c = p.attr("class");

  removeColumn(t);
  if (c.indexOf("activeItem") != -1) {
    //    removeColumn(tn);
    p.toggleClass("activeItem");
    if ($("#api_container").is(":visible")) {
      cleanupContainers();
    }
  } else {
    if (c.indexOf("table") != -1) {
      //get&show table columns
      getColumn(t);
    } else {
      // reset all activeItem class and sql
      cleanupItems4Switching();
      cleanupContainers();

      // API ListはpostAjaxData("/getapilist",...)で取得されてpreferent.apilistにあるので、ここから該当SQLを取得する
      if (preferent.apilist != null && preferent.apilist.length != 0) {
        let s = getdataFromJson(preferent.apilist, t);
        if (0 < s.length) {
          $("#container").append(`<span class="apisql"><p>${s}</p></span>`);
          // api in/out json
          let in_if = setApiIF_In(t, s);
          $("#columns .item_area").append(`<span class="apisql apiin"><bold>IN:</bold>${in_if}</span>`);
          let in_out = setApiIF_Out(t, s);
          $("#columns .item_area").append(`<span class="apisql apiout"><bold>OUT:</bold>${in_out}</span>`);
        }
      }
    }

    //  $(this).toggleClass("activeItem");
    p.toggleClass("activeItem");
  }
}
/*
  API　IN Json
*/
const setApiIF_In = (t, s) => {
  let ta = t.toLowerCase();
  let ret = "";

  if (ta.startsWith("js")) {
    //select
    ret = `{"apino":\"${t}\"}`;
  } else if (ta.startsWith("ji")) {
    //insert
    // insert into table values(a,b,...) -> a,b,...
    let i_sql = s.split("values(");
    i_sql[1] = i_sql[1].slice(0, i_sql[1].length - 1);
    ret = buildJetelinaJsonForm(t, i_sql[1]);
  } else if (ta.startsWith("ju")) {
    //update
    // update table set a=d_a,b=d_b..... -> a=d_a,b=d_b...
    let u_sql = s.split("set");
    ret = buildJetelinaJsonForm(t, u_sql[1]);
  } else if (ta.startsWith("jd")) {
    //delete
    let d_sql = s.split("from");
    ret = buildJetelinaJsonForm(t, d_sql[1]);
  } else {
    // who knows
  }

  return ret;
}
/*
  API OUT Json 
  基本、select文しかOutはない。
*/
const setApiIF_Out = (t, s) => {
  let ret = "";

  if (t.toLowerCase().startsWith("js")) {
    let pb = s.split("select");
    let pf = pb[1].split("from");
    // pf[0]にselect項目があるはず
    if (pf[0] != null && 0 < pf[0].length) {
      ret = buildJetelinaJsonForm(t, pf[0]);
    }
  }

  return ret;
}
/*
  API IN/OUT　Json
*/
const buildJetelinaJsonForm = (t, s) => {
  let ret = "";

  let c = s.split(",");
  for (let i = 0; i < c.length; i++) {
    let cn = c[i].split('.');
    if (ret.length == 0) {
      ret = `{"apino":\"${t}\",`;
    } else {
      let ss = "";
      if (cn[1] != null && 0 < cn[1].length) {
        // select
        ss = cn[1];
      } else {
        //insert update delete
        if (c[i].indexOf("=") != -1) {
          //update
          ss = c[i].split("=")[0];
        } else {
          //insert delte
          ss = c[i];
        }
      }

      if (ss != "jetelina_delete_flg") {
        ret = `${ret}\"${$.trim(ss)}:\"&lt;your data&gt;\",`;
      }
    }
  }

  if (0 < ret.length) {
    ret = ret.slice(0, ret.length - 1);//冗長な最後の","から前を使う
    ret = `${ret}}`;
  }

  return ret;
}
/*
  指定されたtableのカラムデータを取得する
*/
const getColumn = (tablename) => {
  if (0 < tablename.length || tablename != undefined) {
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
      if (debug) console.info("getColumn() result: ", result);
      // data parseに行く
      return getdata(result, 1);
    }).fail(function (result) {
      typingControll(chooseMsg('fail', "", ""));
    });
  } else {
    console.error("getColumn() ajax url is not defined");
  }
}

/*
  カラム表示されている要素を指定して表示から削除する
*/
const removeColumn = (p) => {
  $(".item").not(".selectedItem").remove(`:contains(${p}.)`);
}
/*
  指定されたtableをDBから削除する
*/
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
      $(`#table_container span:contains(${tablename})`).filter(function () {
        if ($(this).text() === tablename) {
          $(this).remove();
          return;
        }
      });

      typingControll(chooseMsg('success', "", ""));
    }).fail(function (result) {
      console.error("deletetable() faild: ", result);
      typingControll(chooseMsg('fail', "", ""));
    }).always(function () {
    });
  } else {
    console.error("deletetable() table is not defined");
  }
}

/*
  post selected columns
*/
const postSelectedColumns = () => {
  let pd = {};
  pd["item"] = selectedItemsArr;
  if (debug) console.info("postSelectedColumns() post data: ", selectedItemsArr, " -> ", pd);
  let dd = JSON.stringify(pd);

  $.ajax({
    url: "/putitems",
    type: "POST",
    data: dd,
    contentType: 'application/json',
    dataType: "json"
  }).done(function (result, textStatus, jqXHR) {
    /*
     本当はここに来るはずなのに、何故かこのajax処理はfail()してしまう。
     サーバサイドのDB処理は一応正常に終了しているので、原因がわかるまでは
     done()の処理をalways()で行うようにしている。
   */
    typingControll(chooseMsg('success', "", ""));
  }).fail(function (result) {
    console.error("postSelectedColumns() fail");
    typingControll(chooseMsg('fail', "", ""));
  }).always(function () {
  });
}
/*
  Function Panel 機能操作
*/
const functionPanelFunctions = (ut, cmd) => {
  let m = "";
  if (presentaction == null || presentaction.length == 0) {
    presentaction.push('func');
  }

  if (ut.indexOf('cond') != -1) {
    delete preferent;
    delete presentaction;
    stage = 'chose_func_or_cond';
    chatKeyDown(ut);
  } else {
    // 優先オブジェクトがあればそれを使う
    let cmd = getPreferentPropertie('cmd');
    //優先されるべきコマンドがないときは入力データが生きる
    if (cmd == null || cmd.length <= 0) {
      if ($.inArray(ut, scenario['6func-fileupload-cmd']) != -1) {
        cmd = 'fileupload';
      } else if ($.inArray(ut, scenario['6func-fileupload-open-cmd']) != -1) {
        //ここではコマンドだけ期待しているので$.inArrayを使う
        cmd = 'fileselectoropen';
      } else if (ut.indexOf('table') != -1) {
        //ここではコマンド+table名の可能性がるのでindexOfを使う　以下そういうこと
        cmd = 'table';
      } else if (ut.indexOf('api') != -1) {
        cmd = 'api';
      } else {
        cmd = ut;
      }
    }

    if (cmd == 'table' || cmd == 'api') {
      presentaction.stage = "func";
      presentaction.cmd = cmd;
    }

    //チャットコマンドでtable/apiを操作する
    /* ちょっと解説
      このprocTableApiList()では画面操作だけ行っていてajaxコールしていない。
       そのため、必ずmが遅滞なく帰ってくるのでOK。
    */
    m = procTableApiList(cmd);
    // drop はちょっと特殊な処理
    let dropTable = getPreferentPropertie('droptable');
    //優先されるべきtable nameがないときは入力データが生きる
    if (dropTable == null || dropTable.length <= 0) {
      for (let i = 0; i < scenario['6func-tabledrop-cmd'].length; i++) {
        if (ut.indexOf(scenario['6func-tabledrop-cmd'][i]) != -1) {
          let dpm = ut.split(scenario['6func-tabledrop-cmd'][i]);
          dropTable = $.trim(dpm[dpm.length - 1]);
          cmd = 'droptable';
        }
      }
    }

    /*
        switch table: table list表示
               api: api list表示
               post: post selected items
               cancel: cancel all selected items
               droptable: drop table(post)
               fileselectoropen: open file selector
               fileupload: csv file upload
               default: non
    */
    switch (cmd) {
      case 'table':
        /* jetelinalib.jsのgetAjaxData()を呼び出して、DB上の全tableリストを取得する
            ajaxのurlは'getalldbtable'
        */
        if ($("#api_container").is(":visible")) {
          //一旦画面をキレイにしてから
          cleanupItems4Switching();
          cleanupContainers();
          $("#api_container").hide();
          //table listを表示する
          $("#panel_left").text("Table List");
          $("#table_container").show();
        }

        cleanUp("tables");
        getAjaxData("getalldbtable");
        //        m = chooseMsg('6a', "", "");
        m = 'ignore';
        break;
      case 'api':
        if ($("#table_container").is(":visible")) {
          //一旦画面をキレイにしてから
          cleanupItems4Switching();
          cleanupContainers();
          $("#table_container").hide();
          //api listを表示する
          $("#panel_left").text("API List");
          $("#api_container").show();
        }

        cleanUp("apis");

        //postAjaxData()でapilistを取得してpreferent.apilistに格納するので、一旦キレイにしておく
        delete preferent.apilist;
        postAjaxData("/getapilist");

        break;
      case 'post':
        if (0 < selectedItemsArr.length) {
          /* postSelectedColumns()はajaxコールするのでmがunknownになる可能性がある。
            このため'ignore'キーワードを設定して、成否のメッセージはpostSele..()内で表示させて、
            この処理以降のtyping()は行わないようにしよう。
          */
          postSelectedColumns();
          m = 'ignore';
        } else {
          m = chooseMsg('6func_post_err', "", "");
        }

        break;
      case 'cancel':
        deleteSelectedItems();
        break;
      case 'droptable':
        if ($("#table_container").is(":visible")) {
          if (dropTable != null && 0 < dropTable.length) {
            //該当table存在確認
            let p = $(`#table_container span:contains(${dropTable})`).filter(function () {
              return $(this).text() === dropTable;
            });


            // 6func-tabledrop-confirmに対して'yes'と言われたら実行される
            if (ut.indexOf('yes') != -1) {
              let t = preferent.droptable;

              delete preferent.cmd;
              delete preferent.droptable;

              deleteThisTable(t);
              m = 'ignore';
            } else {
              if (p != null && 0 < p.length) {
                //あった。よし削除確認メッセージ
                m = chooseMsg('6func-tabledrop-confirm', "", "");
                preferent.cmd = cmd;
                preferent.droptable = dropTable;
              } else {
                //ないぞ。ちゃんとtableを指定して。
                m = chooseMsg('6func-tabledrop-msg', "", "");
                preferent.cmd = cmd;
              }
            }
          } else {
            //table指定催促メッセージ
            m = chooseMsg('6func-tabledrop-msg', "", "");
            preferent.cmd = cmd;
          }
        } else {
          m = chooseMsg('6func-tabledrop-ng-msg', "", "");
        }

        break;
      case 'fileselectoropen'://open file selector
        $("#my_form input[name='upfile']").click();
        m = chooseMsg('6func-fileupload-open-msg', "", "");
        break;
      case 'fileupload'://csv file upload
        const f = $("input[type=file]").prop("files");
        if (f != null && 0 < f.length) {
          m = 'ignore';
          fileupload();
        } else {
          m = chooseMsg('6func-fileupload-msg', "", "");
        }
        break;
      default:
        break;
    }
  }

  return m;
}
/*
  チャットでtable/apiの操作を行う
*/
const procTableApiList = (s) => {
  let m = "";
  let targetlist = "";

  if (presentaction.cmd == 'table') {
    targetlist = "#table_container";
  } else if (presentaction.cmd == 'api') {
    targetlist = "#api_container";
  }

  const cmdlist = ['open', 'close', 'select', 'cancel'];
  s = $.trim(s);
  let t;
  if (s.indexOf(':') != -1) {
    t = s.split(':');
  } else if (s.indexOf(' ') != -1) {
    t = s.split(' ');
  } else {
  }

  if (t != null && 0 < t.length) {
    t[0] = $.trim(t[0]);
    t[1] = $.trim(t[1]);
    if ($.inArray(t[0], cmdlist) != -1) {
      switch (t[0]) {
        case 'open':
        case 'close':
          m = chooseMsg('unknown-msg', "", "");
          $(targetlist).find("span").each(function (i, v) {
            if (v.textContent == t[1]) {
              if ((t[0] == 'close' && $(this).hasClass("activeItem")) ||
                (t[0] == 'open' && !$(this).hasClass("activeItem"))) {
                listClick($(this));
                m = chooseMsg('success', "", "");
                return;
              }
            }
          });
          break;
        case 'select':
          if (presentaction.cmd == 'table') {
            $("#columns").find("span").each(function (i, v) {
              if (v.textContent == t[1]) {
                itemSelect($(this));
                m = chooseMsg('success', "", "");
              }
            });
          }

          if (m.length == 0) {
            m = chooseMsg('unknown-msg', "", "");
          }

          break;
        case 'cancel':
          if (presentaction.cmd == 'table') {
            let p;
            if (t[1] != null && 0 < t[1].length) {
              $("#container").find("span").each(function (i, v) {
                if (v.textContent == t[1]) {
                  p = $(this);
                }
              });
            }

            if (deleteSelectedItems(p)) {
              m = chooseMsg('success', "", "");
            } else {
              m = chooseMsg('unknown-msg', "", "");
            }
          } else {
            m = chooseMsg(3, "", "");
          }

          break;
        default:
          break;
      }
    }
  }

  return m;
}