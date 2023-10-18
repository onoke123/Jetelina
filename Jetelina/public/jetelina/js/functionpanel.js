/**
    JS library for Jetelina Function Panel
    @author Ono Keiji
    @version 1.0

    This js lib works with dashboard.js, functionpanel.js and conditionpanel.js for the Function Panel.
    
    Functions:
      isVisibleTableContainer() checking "#table_container" is visible or not
      isVisibleApiContainer() checking "#api_container" is visible or not
      isVisibleGenelicPanel() checking "#genelic_panel" is visible or not
      isVisibleColumns() checking "#columns" is visible or not
      itemSelect(p) select table column
      deleteSelectedItems(p) delete the selected columns from #container field   選択されているcolumnsを#containerから削除する
      cleanUp(s)  droped items & columns of selecting table
      fileupload() CSV file upload
      getdataFromJson(o,k) aquire the ordered data from the ordered json object  指定されたJsonデータから指定されたデータを取得する
      listClick(p)   do something by clicking tble list or api list items  Table list / API listをクリックした時の処理 
      setApiIF_In(t,s) Show Json of 'API　IN'
      setApiIF_Out(t,s) Show Json of 'API OUT'
      buildJetelinaJsonForm(t,s)  Create display Json form data from a API
      getColumn(tablename) Ajax function for getting the column names of the ordered table  指定されたtableのカラムデータを取得する
      removeColumn(tablename) Delete a column from selected item list on the display カラム表示されている要素を指定して表示から削除する
      deleteThisTable(tablename)　Ajax function for deleting the target table from DataBase. 指定されたtableをDBから削除する
      postSelectedColumns() Ajax function for posting the selected columns.
      functionPanelFunctions(ut)　Exectute some functions ordered by user chat input message    Function Panel 機能操作
      procTableApiList(s) Execute some functions for table list and/or api list order by user chat input commands  チャットでtable/apiの操作を行う
      containsMultiTables() Judge demanding 'where sentence' before post to the server
      showGenelicPanel() genelic panel open. 
      checkGenelicInput() check genelic panel input. caution: will imprement this in V2 if necessary
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
/**
 * @function isVisibleTableContainer
 * @returns {boolean}  true -> visible, false -> invisible
 * 
 * checking "#table_container" is visible or not
 */
const isVisibleTableContainer = () =>{
  let ret = false;
  if ($("#table_container").is(":visible")){
    ret = true;
  }

  return ret;
}
/**
 * @function isVisibleApiContainer
 * @returns {boolean}  true -> visible, false -> invisible
 * 
 * checking "#api_container" is visible or not
 */
const isVisibleApiContainer = () =>{
  let ret = false;
  if ($("#api_container").is(":visible")){
    ret = true;
  }

  return ret;
}
/**
 * @function isVisibleGenelicPanel
 * @returns {boolean}  true -> visible, false -> invisible
 * 
 * checking "#genelic_panel" is visible or not
 */
const isVisibleGenelicPanel = () =>{
  let ret = false;
  if ($("#genelic_panel").is(":visible")){
    ret = true;
  }

  return ret;
}
/**
 * @function isVisibleColumns
 * @returns {boolean}  true -> visible, false -> invisible
 * 
 * checking "#columns" is visible or not
 */
const isVisibleColumns = () =>{
  let ret = false;
  if ($("#columns").is(":visible")){
    ret = true;
  }

  return ret;
}
/**
 * @function itemSelect
 * @param {object} p  jquery tag object
 * 
 * select table column 
 */
const itemSelect = (p) => {
  let cl = p.attr("class");
  let item = p.text();

  // delete the showing because the api no is displayed in there initially.
  if ($("#container span").hasClass('apisql')) {
    $("#container span").remove();
  }

  if (p.hasClass("selectedItem")) {
    // delete
    deleteSelectedItems(p);
  } else {
    // adding
    if ($.inArray(item, selectedItemsArr) != -1) {
      p.detach();
    } else {
      p.addClass("selectedItem");
      p.detach().appendTo("#container");
    }

    selectedItemsArr.push(item);
  }
}
/**
 * @function deleteSelectedItems
 * @param {string} p  jquery tag string 
 * @returns {boolean}  true->success done  false->no action
 * 
 * delete the selected columns from #container field
 */
const deleteSelectedItems = (p) => {
  let ret = false;

  if (p != null) {
    // delete the ordered item
    let item = $(p).text();
    selectedItemsArr = selectedItemsArr.filter(elm => {
      return elm !== item;
    });

    $(p).removeClass("selectedItem");
    $(p).detach().appendTo("#columns div");
    ret = true;
  } else {
    // delete all items
    selectedItemsArr.length = 0;
    $("#container span").removeClass("selectedItem");
    $("#container .apisql").remove();
    $("#container span").detach().appendTo("#columns div");
    ret = true;
  }

  return ret;
}
/**
 * @function cleanUp
 * @param {string} s  point to target : 'items' or 'tables' or 'apis'
 * 
 * droped items & columns of selecting table
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
/**
 * @function fileupload
 * 
 * CSV file upload.
 * The target csv files is ordered in '#my_form'
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
      if (isVisibleTableContainer()) {
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
  get the ordered table column.
  Once clicking it, this table's class attribute has changed
      before clicking & secound time : table
      after the first clicking       : table activeItem

  the excecution of getting column is judged by this 'activeItem' attribute.
*/
$(document).on("click", ".table,.api", function () {
  listClick($(this));
});

/**
 * @function getdataFromJson
 * @param {object} o  json object 
 * @param {string} k  targeted desiring data (json name part)
 * @returns {string}  targeted desiring data (json value part)
 * 
 * aquire the ordered data from the ordered json object.
 */
const getdataFromJson = (o, k) => {
  const Jkey = 'Jetelina';
  let ret = "";
  Object.keys(o).forEach(function (key) {
    // because the value in ’Jetelina’ is an object: name=>key value=>o[key]
    let row = 1, col = 1;
    if (key == Jkey && o[key].length > 0) {
      $.each(o[key], function (n, v) {
        $.each(v, function (name, value) {
          if (value == k) {
            ret = v.sql;
            return false;// loop out
          }
        });
      });
    }
  });

  return ret;
}
/**
 * @function listClick
 * @param {object} p  jquery tag object
 * 
 * do something by clicking tble list or api list items 
 */
const listClick = (p) => {
  let t = p.text();
  let c = p.attr("class");

  removeColumn(t);
  if (c.indexOf("activeItem") != -1) {
    p.toggleClass("activeItem");
    if (isVisibleApiContainer()) {
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

      // showing ordered sql from preferent.apilist that is gotten by postAjaxData("/getapilist",...)
      if (preferent.apilist != null && preferent.apilist.length != 0) {
        let s = getdataFromJson(preferent.apilist, t);
        if (0 < s.length) {
          s = s.replace("<","&lt;");
          s = s.replace(">","&gt;");
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
/**
 * @function setApiIF_In
 * @param {string} t targeted desiring data (json name part)
 * @param {string} s targeted desiring data (json value part)
 * @returns {string} json form string
 * 
 * Show Json of 'API　IN'
 */
const setApiIF_In = (t, s) => {
  let ta = t.toLowerCase();
  let ret = "";

  if (ta.startsWith("js")) {
    //select

    /*
        create sql sentence with 'where sentence'
    */
    let subquery = "\"subquery\":[";
    let qd = s.match(/\?/g);
    if( qd != null ){
      for ( let i=1;i<=qd.length;i++ ) {
        subquery = `${subquery} d${i},`;
      }
      
      subquery = subquery.slice(0,-1);// cut the end of ','
    }

    subquery = `${subquery}]`;
    
    ret = `{"apino":\"${t}\",${subquery}}`;
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
/**
 * @function setApiIF_Out
 * @param {string} t targeted desiring data (json name part)
 * @param {string} s targeted desiring data (json value part)
 * @returns {string} json form string
 *
 * Show Json of 'API OUT'
 * Only select sql  
 */
const setApiIF_Out = (t, s) => {
  let ret = "";

  if (t.toLowerCase().startsWith("js")) {
    let pb = s.split("select");
    let pf = pb[1].split("from");
    // there is the items in pf[0]
    if (pf[0] != null && 0 < pf[0].length) {
      ret = buildJetelinaJsonForm(t, pf[0]);
    }
  }

  return ret;
}
/**
 * @function buildJetelinaJsonForm
 * @param {string} t targeted desiring data (json name part)
 * @param {string} s tables(after 'from' sentence in a sql)
 * @returns {string} Json form string
 * 
 * Create display Json form data from a API
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
/**
 * @function getColumn
 * @param {string} tablename  targeted table name
 * 
 * Ajax function for getting the column names of the ordered table.
 * Then display in the function panel.
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
      // got to data parse
      return getdata(result, 1);
    }).fail(function (result) {
      typingControll(chooseMsg('fail', "", ""));
    });
  } else {
    console.error("getColumn() ajax url is not defined");
  }
}
/**
 * @function removeColumn
 * @param {string} p  target column name
 * 
 * delete a column from selected item list on the display  
 */
const removeColumn = (p) => {
  $(".item").not(".selectedItem").remove(`:contains(${p}.)`);
}
/**
 * @function deleteThisTable
 * @param {string} tablename  target table name
 * 
 * Ajax function for deleting the target table from DataBase. 
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
          removeColumn(tablename);
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
/**
 * @function postSelectedColumns
 * 
 * Ajax function for posting the selected columns.
 */
const postSelectedColumns = () => {
  let pd = {};
  pd["item"] = selectedItemsArr;

  /*
    absolutely something is in 'getelic_input'.
    'ignore' is if nothing done by the user.
  */
  pd["where"] = $("#genelic_panel input[name='genelic_input']").val();
   
  if (debug) console.info("postSelectedColumns() post data: ",  pd);
  let dd = JSON.stringify(pd);

  $.ajax({
    url: "/putitems",
    type: "POST",
    data: dd,
    contentType: 'application/json',
    dataType: "json"
  }).done(function (result, textStatus, jqXHR) {
    /*
      if there is not a quite similar api in there -> return as alike {"apino":"js10"} or false in error.
      if there already is a quite similar api in there -> return api no as alike {"resembled":"js10"}.
    */
    if(result.apino != null && 0<result.apino.length){ 
      $("#container span").remove();
      $("#container").append(`<span class="apisql"><p>api no is ${result.apino}</p></span>`);

      typingControll(chooseMsg('success', "", ""));
    }else if(result.resembled != null && 0<result.resembled.length){
      $("#container").append(`<span class="apisql"><p>there is similar API exist already:  ${result.resembled}</p></span>`);
    }

    if(isVisibleGenelicPanel()){
      $("#genelic_panel").hide();
    }
  }).fail(function (result) {
    console.error("postSelectedColumns() fail");
    typingControll(chooseMsg('fail', "", ""));
  }).always(function () {
    preferent.cmd = "";
    $("#genelic_panel input[name='genelic_input']").val('');
  });
}
/**
 * @function functionPanelFunctions
 * @param {string} ut  chat message by user 
 * @returns {string}  answer chat message by Jetelina
 * 
 * Exectute some functions ordered by user chat input message 
 */
const functionPanelFunctions = (ut) => {
  let m = 'ignore';
  
  if (inScenarioChk(ut,'condition_panel')) {
    delete preferent;
    delete presentaction;
    stage = 'chose_func_or_cond';
    chatKeyDown(ut);
  } else {
    // use the prior command if it were
    let cmd = getPreferentPropertie('cmd');
    // use input data if there were not a prior command 
    if (cmd == null || cmd.length <= 0) {
      if(inScenarioChk(ut,'6func-fileupload-cmd')){
        cmd = 'fileupload';
      } else if (inScenarioChk(ut,'6func-fileupload-open-cmd')){
        // use $.inArray because of expecting only command at here 
        cmd = 'fileselectoropen';
      } else if(inScenarioChk(ut,'6func-show-table-list')){
        // use indexOf() because of 'command + table name' is possible
        cmd = 'table';
      } else if(inScenarioChk(ut,'6func-show-api-list')){
        // same as above
        cmd = 'api';
      } else {
        cmd = ut;
      }
    }

    if (cmd == 'table' || cmd == 'api') {
      presentaction.stage = "func";
      presentaction.cmd = cmd;
    }

    // execute table or api list order the chatting message by the user
    /* Tips:
       ProcTableApiList() handles only on screen, not calling ajax function.
       That why 'm' can be expected without any delay. So this function call is correct.
    */
    m = procTableApiList(cmd);

    // Attention, the drop exection is a little bit special.
    let dropTable = getPreferentPropertie('droptable');
    // the input data is prefered if there were a prior table name.
    if (dropTable == null || dropTable.length <= 0) {
      for (let i = 0; i < scenario['6func-tabledrop-cmd'].length; i++) {
        if (ut.indexOf(scenario['6func-tabledrop-cmd'][i]) != -1) {
          let dpm = ut.split(scenario['6func-tabledrop-cmd'][i]);
          dropTable = $.trim(dpm[dpm.length - 1]);
          cmd = 'droptable';
        }
      }
    }

    // cleanup command of item, selecteditem field
      if(inScenarioChk(ut,'6func-cleanup-cmd')){
      cmd = 'cleanup';
    }

    // genelic panel(subquery panel)
    if(inScenarioChk(ut,'6func-subpanel-open-cmd')){
      cmd = "subquery";
    }

    if (debug) console.info("functionPanelFunctions() cmd: ", cmd);
    /*
        switch table: table list表示
               api: api list表示
               post: post selected items
               cancel: cancel all selected items
               droptable: drop table(post)
               fileselectoropen: open file selector
               fileupload: csv file upload
               creanup: cleanup column/selecteditem field
               subquery: open subquery panel
               default: non
    */
    switch (cmd) {
      case 'table':
        /*  Call getAjaxData() in jetelinalib.js for getting all table list in the Database.
            The url of general ajax call is 'getalldbtable'.
        */
        if (isVisibleApiContainer()) {
          // cleanup the screen
          cleanupItems4Switching();
          cleanupContainers();
          $("#api_container").hide();
          // show the table list
          $("#panel_left").text("Table List");
          $("#table_container").show();
        }

        cleanUp("tables");
        getAjaxData("getalldbtable");
        m = 'ignore';
        break;
      case 'api':
        if (isVisibleTableContainer()) {
          // cleanup the scree 
          cleanupItems4Switching();
          cleanupContainers();
          $("#table_container").hide();
          // show api list
          $("#panel_left").text("API List");
          $("#api_container").show();
        }

        cleanUp("apis");

        // cleanup once because getting apilist and contain to preferent.aplist by calling postAjaxData()
        delete preferent.apilist;
        postAjaxData("/getapilist");
        m = 'ignore';
        break;
      case 'post':
        if (0 < selectedItemsArr.length) {
          /*  call an attentiion for inputting where sentence before posting it.
              confirm if the sql sentence has multi table in 'selectedItemArr'.
              a 'where sentence' is demanded when multi tables are setted.
          */
          // open the box for inputting a 'where sentence'
          let wheresentence = $("#genelic_panel input[name='genelic_input']").val();
          if(wheresentence == null || wheresentence == "" ){
            // arrange the Jetelina message order by demanding 'where sentece' or not
            // check multi table columns in the post data 
            if( containsMultiTables() ){
              // 'where sentence' is demanded if there were multi tables
              m = chooseMsg('6func-postcolumn-where-indispensable-msg', "", "");
              showGenelicPanel();
            }else{
              // 'where sentence' is not demanded but ask it once time
              m = chooseMsg('6func-postcolumn-where-option-msg', "", "");
              // open the getelic_panel(input where sentecen) if the user's answer is 'yes'
              if( $.inArray(ut,scenario['confirmation-sentences'] ) != -1){
                showGenelicPanel();
              }else{
                // contain a dummy data('ignore') if the user's anwer is not 'yes'
                // Attention: should confirm and resolve there.(一発目に ut=postで来るからここが自動的に設定されてしまい、２発目のyesが無視される。そこが問題)
                if( preferent.cmd == "post" ){
                  $("#genelic_panel input[name='genelic_input']").val("ignore");
                }
              }
            }

            preferent.cmd = "post";
          }else{
            // let's check the 'where sentence' before post it to the server
            if( checkGenelicInput(wheresentence) ){
              /* 'm' has a chance to be 'unknown' because postSelectedColumns() is ajax function.
                 So set a keyword 'ignore' then the message of success or fail in postSele..(), 
                 then do not do typing() after this process.
              */
                postSelectedColumns();
                m = 'ignore';
            }else{
              // Hum, it is not a table column of opening the 'where sentence'.
            }
          }        
        } else {
          m = chooseMsg('6func_post_err', "", "");
        }

        break;
      case 'cancel':
        if (deleteSelectedItems()) {
          m = chooseMsg('success', "", "");
        } else {
          m = chooseMsg('unknown-msg', "", "");
        }

        presentaction.cmd = "";
        break;
      case 'droptable':
        if (isVisibleTableContainer()) {
          if (dropTable != null && 0 < dropTable.length) {
            // Hit the table
            let p = $(`#table_container span:contains(${dropTable})`).filter(function () {
              return $(this).text() === dropTable;
            });


            // execute this if 6func-tabledrop-confirm is 'yes'
            if (ut.indexOf('yes') != -1) {
              let t = preferent.droptable;

              delete preferent.cmd;
              delete preferent.droptable;

              deleteThisTable(t);
              m = 'ignore';
            } else {
              if (p != null && 0 < p.length) {
                // Yes there is, show the delete confirmation message.
                m = chooseMsg('6func-tabledrop-confirm', "", "");
                preferent.cmd = cmd;
                preferent.droptable = dropTable;
              } else {
                // Well, there is nothing. Show the message fo '6func-table....'
                m = chooseMsg('6func-tabledrop-msg', "", "");
                preferent.cmd = cmd;
              }
            }
          } else {
            // the request message for ordering table name
            m = chooseMsg('6func-tabledrop-msg', "", "");
            preferent.cmd = cmd;
          }
          // cancel an order of table drop 
          if( ut.indexOf('cancel') != -1){
            preferent.cmd = "";
            m = chooseMsg('cancel', "", "");
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
      case 'cleanup': //clean up the panels
        cleanupItems4Switching();
        deleteSelectedItems();
        cleanUp("items");
        cleanupContainers();
         m = chooseMsg('success','','');
        break;
      case 'subquery': //open subquery panel
        showGenelicPanel();
        m = chooseMsg('success','','');
        break;
      default:
        break;
    }
  }

  return m;
}
/**
 * @function procTableApiList
 * @param {string} s  expect 'open', 'close', 'select', 'cancel' commands for table list and/or api list   
 * 
 * Execute some functions for table list and/or api list order by user chat input commands
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
    // will be implemented anything, anyday. 
  }

  if (t != null && 0 < t.length) {
    t[0] = $.trim(t[0]);
    t[1] = $.trim(t[1]);
    if ($.inArray(t[0], cmdlist) != -1) {
      switch (t[0]) {
        case 'open':
          /* do not break because of open/close are same
             go to 'close' if it were 'open' as well, this is tricky! :-)
          */
        case 'close':
          m = chooseMsg('unknown-msg', "", "");
          $(targetlist).find("span").each(function (i, v) {
            let findselect = false;
            // only the api-number is ok in api list
            if(presentaction.cmd == 'api' ){
              if(v.textContent.indexOf(t[1]) != -1){
                findselect = true;
              }
            }else{
              if (v.textContent == t[1]) {
                findselect = true;
              }
            }

            if (findselect) {
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
              let findselect = false;
              if( $(".activeItem").length == 1 ){
                // can selct by only the column name when opening only one table. I mean 'ftest.id' -> 'id' is OK.
                if(v.textContent.indexOf(t[1]) != -1){
                  findselect = true;
                }
              }else{
                if (v.textContent == t[1]) {
                  findselect = true;
                }
              }

              if(findselect){
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
                }else if( v.textContent.indexOf(t[1]) != -1){
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
/**
 * @function containsMultiTables
 * @returns {boolean}  true->demand false->not demand
 * 
 * Judge demanding 'where sentence' before post to the server
 */
const containsMultiTables = () =>{
  if( 0<selectedItemsArr.length ){
    let tables = [];
    $.each( selectedItemsArr, function(i,v){
      if( 0<v.length && v.indexOf('.') !=-1 ){
        let p = v.split('.');
        if( $.inArray(p[0],tables) === -1 ){
          tables.push(p[0]);
        }
      }
    });

    if( 1<tables.length ){
      return true;
    }else{
      return false;
    }
  }
}
/**
 * @function showGenelicPanel
 * 
 * genelic panel open
 */
const showGenelicPanel = () =>{
  if(!isVisibleGenelicPanel()){
    $("#genelic_panel").show();
    $("#genelic_panel input[name='genelic_input']").focus();
  }
}
/**
 * @function checkGenelicInput
 * @param {string} s  where sentence strings 
 * @returns {boolean}  true->known column as opening  false->unknown column(illegal)
 * 
 * caution: will imprement this in V2 if necessary
 */
const checkGenelicInput = (s) =>{
  return true;
}

// return to the chat box if 'return key' is typed in genelic_panel
$("#genelic_panel input[name='genelic_input']").keypress(function (e) {
  if (e.keyCode == 13) {
    $("#jetelina_panel [name='chat_input']").focus();
  }
});
