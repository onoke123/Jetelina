/**
    JS library for Jetelina Function Panel
    @author Ono Keiji
    @version 1.0

    This js lib works with dashboard.js, functionpanel.js and conditionpanel.js for the Function Panel.
    
    Functions:
      openFunctionPanel() open and visible "#function_panel"
      isVisibleTableContainer() checking "#table_container" is visible or not
      isVisibleApiContainer() checking "#api_container" is visible or not
      isVisibleGenelicPanel() checking "#genelic_panel" is visible or not
      isVisibleColumns() checking "#columns" is visible or not
      itemSelect(p) select table column
      deleteSelectedItems(p) delete the selected columns from #container field
      cleanUp(s)  droped items & columns of selecting table
      cleanupItems4Switching() clear screen in activeItem class when switching table list/api list 
      cleanupContainers() clear screen in the detail zone showing when switching table list/api list 
      fileupload() CSV file upload
      getdataFromJson(o,k) aquire the ordered data from the ordered json object
      listClick(p)   do something by clicking tble list or api list items  
      setApiIF_In(t,s) Show Json of 'API　IN'
      setApiIF_Out(t,s) Show Json of 'API OUT'
      setApiIF_Sql(s) Show sample execution sql sentence
      buildJetelinaJsonForm(t,s)  Create display Json form data from a API
      buildJetelinaOutJsonForm(t, s) Create display 'OUT' Json form data from a API. mainly using in 'select' API.
      getColumn(tablename) Ajax function for getting the column names of the ordered table 
      removeColumn(tablename) Delete a column from selected item list on the display 
      deleteThisTable(tablename)　Ajax function for deleting the target table from DataBase. 
      postSelectedColumns(mode) Ajax function for posting the selected columns.
      functionPanelFunctions(ut)　Exectute some functions ordered by user chat input message    
      procTableApiList(s) Execute some functions for table list and/or api list order by user chat input commands  
      containsMultiTables() Judge demanding 'where sentence' before post to the server
      showGenelicPanel(b) genelic panel open or close. 
      checkGenelicInput() check genelic panel input. caution: will imprement this in V2 if necessary
      deleteThisApi() Ajax function for deleting the target api from api list doc.
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
 * @function openFunctionPanel
 * 
 * open and visible "#function_panel"
 * hide "#condition_panel" at the same time if it is visible
 */
const openFunctionPanel = () => {
  if (inVisibleConditionPanel()) {
    $("#condition_panel").hide();
  }

  $("#function_panel").show().animate({
    width: window.innerWidth * 0.8,
    height: window.innerHeight * 0.8,
    top: "10%",
    left: "10%"
  }, animateDuration);

  if (isVisibleColumns()) {
    $("#fileup").draggable().animate({
      top: "4%",
      left: "5%"
    }, animateDuration);
    $("#left_panel").draggable().animate({
      top: "10%",
      left: "5%"
    }, animateDuration);
    $("#columns").draggable().animate({
      top: "10%",
      left: "30%"
    }, animateDuration);
    $("#container").draggable().animate({
      bottom: "5%",
      left: "30%"
    }, animateDuration);
  }
}
/**
 * @function isVisibleTableContainer
 * @returns {boolean}  true -> visible, false -> invisible
 * 
 * checking "#table_container" is visible or not
 */
const isVisibleTableContainer = () => {
  let ret = false;
  if ($("#table_container").is(":visible")) {
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
const isVisibleApiContainer = () => {
  let ret = false;
  if ($("#api_container").is(":visible")) {
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
const isVisibleGenelicPanel = () => {
  let ret = false;
  if ($("#genelic_panel").is(":visible")) {
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
const isVisibleColumns = () => {
  let ret = false;
  if ($("#columns").is(":visible")) {
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
    $("#columns .apisql").remove();
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
 * @function cleanupItems4Switching
 * 
 * clear screen in activeItem class when switching table list/api list
 */
const cleanupItems4Switching = () => {
  if (isVisibleTableContainer()) {
    $("#table_container span").removeClass("activeItem");
  } else if (isVisibleApiContainer()) {
    $("#api_container span").removeClass("activeItem");
    $("#container span").remove();
  }
}
/**
* @function cleanupContainers
* 
* clear screen in the detail zone showing when switching table list/api list
*/
const cleanupContainers = () => {
  $("#container span,#columns span").remove();
  // if api test result panel is openend yet
  if (isVisibleApiContainer()) {
    showApiTestPanel(false);
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

  $.ajax({
    url: "/postcsvfile",
    type: "post",
    data: fd,
    cache: false,
    contentType: false,
    processData: false,
    dataType: "json",
    xhr: function () {
      ret = $.ajaxSettings.xhr();
      inprogress = true;// in progress. for priventing accept a new command.
      typingControll(chooseMsg('inprogress-msg', "", ""));
      return ret;
    }
  }).done(function (result, textStatus, jqXHR) {
    // clean up
    $("input[type=file]").val("");
    $("#upbtn").prop("disabled", false);

    if (checkResult(result)) {
      $("#my_form label span").text("Upload CSV File");

      //refresh table list 
      if (isVisibleTableContainer()) {
        cleanUp("tables");
        getAjaxData(scenario["function-get-url"][1]);
      } else {
        typingControll(chooseMsg('success-msg', "", ""));
      }
    } else {
      // csv file format error
      typingControll(chooseMsg('func-csv-format-error-msg', "", ""));
    }
  }).fail(function (result) {
    checkResult(result);
    // something error happened
    console.error("fileupload(): unexpected error");
    typingControll(chooseMsg(fail - msg, "", ""));
  }).always(function () {
    // release it for allowing to input new command in the chatbox 
    inprogress = false;
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
 * @returns {object}  targeted desiring data (apino, sql, subquery)
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
            ret = v;
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

      // showing ordered sql from preferent.apilist that is gotten by getAjaxData("/getapilist",...)
      if (preferent.apilist != null && preferent.apilist.length != 0) {
        let s = getdataFromJson(preferent.apilist, t);
        if (0 < s.sql.length) {
          // api in/out json
          $("#columns .item_area").append(`<span class="apisql apiin"><bold>IN:</bold>${setApiIF_In(t, s)}</span>`);
          $("#columns .item_area").append(`<span class="apisql apiout"><bold>OUT:</bold>${setApiIF_Out(t, s)}</span>`);
          // sample execution sql
          $("#container").append(`<span class="apisql"><p>${setApiIF_Sql(s)}</p></span>`);
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
 * @param {object} s targeted desiring data object(apino, sql, subquery)
 * @returns {string} json form string
 * 
 * Show Json of 'API　IN'
 */
const setApiIF_In = (t, s) => {
  let ta = t.toLowerCase();
  let ret = "";

  if (ta.startsWith("js")) {
    //select. 'ignore' -> no sub query
    if (s.subquery != null && 0 < s.subquery.length && s.subquery != "ignore") {
      let s_subquery = s.subquery;
      let subquery_str = "";
      let isCurry = s_subquery.indexOf('{');
      while (-1 < isCurry) {
        let sp = s_subquery.indexOf('{');
        let ep = s_subquery.indexOf('}');
        if (sp != -1 && ep != -1) {
          let cd = s_subquery.substring(sp + 1, ep);
          subquery_str += `'${cd}':`;
          if (s_subquery[sp - 1] == "\'") {
            subquery_str += `'{${cd}}',`;
          } else {
            subquery_str += `{${cd}},`;
          }

          s_subquery = s_subquery.substring(ep + 1, s_subquery.length);
        }
        isCurry = s_subquery.indexOf('{');
      }

      subquery_str = subquery_str.slice(0, -1);
      ret = `{"apino":\"${t}\","subquery":\"[${subquery_str}]\"}`;
      //      ret = `{"apino":\"${t}\","subquery":\"${s.subquery}\"}`;
    } else {
      ret = `{"apino":\"${t}\"}`;

    }
  } else if (ta.startsWith("ji")) {
    /*
      insert
        a,b,... in insert into table values(a,b,...) 
    */
    let i_sql = s.sql.split("values(");
    i_sql[1] = i_sql[1].slice(0, i_sql[1].length - 1).replaceAll('\'', '').replaceAll('{', '').replaceAll('}', '');
    ret = buildJetelinaJsonForm(ta, i_sql[1]);
  } else if (ta.startsWith("ju") || ta.startsWith("jd")) {
    /*
      update and delete(the true color is update)
        a=d_a,b=d_b... in update table set a=d_a,b=d_b..... 
    */
    let u_sql = s.sql.split("set");
    ret = buildJetelinaJsonForm(ta, u_sql[1]);
    /*
      special for 'ju and 'jd'
         because the subquery in update/delete is executed with jt_id in 'where' sentence.
         this is the protocol so far.
    */
    ret = ret.slice(0, ret.length - 1) + `,\"subquery\":\"{jt_id}\"` + ret.slice(ret.length - 1, ret.length);

    /*
    if (s.subquery != null && 0 < s.subquery.length && s.subquery != "ignore") {
      ret = ret.slice(0, ret.length - 1) + `,\"subquery\":\"${s.subquery}\"` + ret.slice(ret.length - 1, ret.length);
    }*/
  } else {
    // who knows
  }

  return ret;
}
/**
 * @function setApiIF_Out
 * @param {string} t targeted desiring data (json name part)
 * @param {object} s targeted desiring data object(apino, sql, subquery)
 * @returns {string} json form string in select sentece, other true/false
 *
 * Show Json of 'API OUT'
 * Only select sql  
 */
const setApiIF_Out = (t, s) => {
  let ret = "true or false";
  let ta = t.toLowerCase();

  if (ta.startsWith("js")) {
    let pb = s.sql.split("select");
    let pf = pb[1].split("from");
    // there is the items in pf[0]
    if (pf[0] != null && 0 < pf[0].length) {
      ret = buildJetelinaOutJsonForm(ta, pf[0]);
    }
  } else {
    // insert, update, delete
    ret = '{"result":true or false,"Jetelina":"[{\"message from Jetelina\":\".....\"}]"}';
  }

  return ret;
}
/**
 * @function setApiIF_Sql
 * @param {object} s targeted desiring data object(apino, sql, subquery)
 * @returns {string} sample execution sql sentence
 *
 * Show sample execution sql sentence
 */
const setApiIF_Sql = (s) => {
  let ret = "";

  // possibly s.subquery is null. 'ignore' -> no sub query
  if (s.subquery != null && s.subquery != "ignore") {
    ret = `${s.sql} ${s.subquery};`;
  } else {
    ret = `${s.sql};`;
  }

  let reject_jetelina_delete_flg = "jetelina_delete_flg";
  if (ret.startsWith("insert")) {
    ret = ret.replaceAll(`,{${reject_jetelina_delete_flg}}`, '').replaceAll(`,${reject_jetelina_delete_flg}`);
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
    }

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
        //insert delete
        ss = c[i];
      }
    }

    if (ss.indexOf("jetelina_delete_flg") < 0) {
      ret = `${ret}\"${$.trim(ss)}\":\"{${$.trim(ss)}}\",`;
    }
  }

  if (0 < ret.length) {
    ret = ret.slice(0, ret.length - 1);// reject ',' from the tail
    ret = `${ret}}`; // caution: the last '}' is necessary
  }

  return ret;
}

/**
 * @function buildJetelinaOutJsonForm
 * @param {string} t targeted desiring data (json name part)
 * @param {string} s tables(after 'from' sentence in a sql)
 * @returns {string} Json form string
 * 
 * Create display 'OUT' Json form data from a API
 * mainly using in 'select' API.
 */
const buildJetelinaOutJsonForm = (t, s) => {
  let ret = "";

  let c = s.split(",");
  for (let i = 0; i < c.length; i++) {
    let cn = c[i].split('.');
    if (ret.length == 0) {
      ret = `{"result":true or false,"Jetelina":"[{`;
    }

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
        //insert delete
        ss = c[i];
      }
    }

    if (ss.indexOf("jetelina_delete_flg") < 0) {
      ret = `${ret}\"${$.trim(ss)}\":\"{${$.trim(ss)}}\",`;
    }
  }

  if (0 < ret.length) {
    ret = ret.slice(0, ret.length - 1);// reject ',' from the tail
    ret = `${ret}]"}`; // caution: the last '}' is necessary
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
      dataType: "json",
      xhr: function () {
        ret = $.ajaxSettings.xhr();
        inprogress = true;// in progress. for priventing accept a new command.
        typingControll(chooseMsg('inprogress-msg', "", ""));
        return ret;
      }
    }).done(function (result, textStatus, jqXHR) {
      // got to data parse
      return getdata(result, 1);
    }).fail(function (result) {
      checkResult(result);
      typingControll(chooseMsg('fail-msg', "", ""));
    }).always(function () {
      // release it for allowing to input new command in the chatbox 
      inprogress = false;
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
      dataType: "json",
      xhr: function () {
        ret = $.ajaxSettings.xhr();
        inprogress = true;// in progress. for priventing accept a new command.
        typingControll(chooseMsg('inprogress-msg', "", ""));
        return ret;
      }
    }).done(function (result, textStatus, jqXHR) {
      $(`#table_container span:contains(${tablename})`).filter(function () {
        if ($(this).text() === tablename) {
          $(this).remove();
          removeColumn(tablename);
          return;
        }
      });

      typingControll(chooseMsg('success-msg', "", ""));
    }).fail(function (result) {
      checkResult(result);
      console.error("deleteThisTable() faild: ", result);
      typingControll(chooseMsg('fail-msg', "", ""));
    }).always(function () {
      // release it for allowing to input new command in the chatbox 
      inprogress = false;
    });
  } else {
    console.error("deleteThisTable() table is not defined");
  }
}
/**
 * @function postSelectedColumns
 * @param {string} mode  null->API registration  "pre"-> only test execution
 * 
 * Ajax function for posting the selected columns.
 * in the case of mode is "pre", this post procedure executes API test.
 * in the case of mode is null, this post executes API registration.
 */
const postSelectedColumns = (mode) => {
  let pd = {};

  pd["item"] = selectedItemsArr;
  pd["mode"] = mode;

  /*
    absolutely something is in 'getelic_input'.
    'ignore' is if nothing done by the user.
    'where' is mandatory
  */
  let subq = $("#genelic_panel input[name='genelic_input']").val();
  if((subq != "ignore" && subq != "") && subq.indexOf("where") == -1){
    subq = `where ${subq}`;
  }

  pd["subquery"] = subq;

  let dd = JSON.stringify(pd);
  let posturl = scenario["function-post-url"][4];
  if(mode=="pre"){
    posturl = scenario["function-post-url"][5];    
  }

  $.ajax({
    url: posturl,
    type: "POST",
    data: dd,
    contentType: 'application/json',
    dataType: "json",
    xhr: function () {
      ret = $.ajaxSettings.xhr();
      inprogress = true;// in progress. for priventing accept a new command.
      typingControll(chooseMsg('inprogress-msg', "", ""));
      return ret;
    }
  }).done(function (result, textStatus, jqXHR) {
    if (mode != "pre") {
      /*
        if there is not a quite similar api in there -> return as alike {"apino":"js10"} or false in error.
        if there already is a quite similar api in there -> return api no as alike {"resembled":"js10"}.
      */
      if (result.apino != null && 0 < result.apino.length) {
        // hide api test panel if it is desplayed
        if (isVisibleApiTestPanel()) {
          showApiTestPanel(false);
        }

        $("#container").append(`<span class="newapino"><p>api no is ${result.apino}</p></span>`);
        typingControll(chooseMsg('success-msg', "", ""));
      } else if (result.resembled != null && 0 < result.resembled.length) {
        $("#container").append(`<span class="newapino"><p>there is similar API already exist:  ${result.resembled}</p></span>`);
      }

      if (isVisibleGenelicPanel()) {
        $("#genelic_panel").hide();
      }
    } else {
      /* API test mode */
      getdata(result, 4);
    }

    typingControll(chooseMsg("success-msg", "", ""));
  }).fail(function (result) {
    checkResult(result);
    console.error("postSelectedColumns() fail");
    typingControll(chooseMsg('fail-msg', "", ""));
  }).always(function () {
    // release it for allowing to input new command in the chatbox 
    inprogress = false;

    if (mode != "pre") {
      // initializing
      preferent.cmd = "";
      $("#genelic_panel input[name='genelic_input']").val('');
      $("#container .selectedItem").remove();
      cleanUp("items");
      cleanupItems4Switching();// clear(=close) opened table items. defined in jetelinalib.js
    }
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

  if (inScenarioChk(ut, 'condition_panel-cmd')) {
    delete preferent;
    delete presentaction;
    stage = 'lets_do_something';
    chatKeyDown(ut);
  } else {
    // use the prior command if it were
    let cmd = getPreferentPropertie('cmd');
    // use input data if there were not a prior command 
    if (cmd == null || cmd.length <= 0) {
      if (inScenarioChk(ut, 'func-fileupload-cmd')) {
        cmd = 'fileupload';
      } else if (inScenarioChk(ut, 'func-fileupload-open-cmd')) {
        cmd = 'fileselectoropen';
      } else if (inScenarioChk(ut, 'func-show-table-list-cmd')) {
        cmd = 'table';
      } else if (inScenarioChk(ut, 'func-show-api-list-cmd')) {
        // same as above
        cmd = 'api';
      } else if (inScenarioChk(ut, 'common-post-cmd')) {
        cmd = 'post';
      } else {
        cmd = ut;
      }
    }

    if (cmd == 'table' || cmd == 'api') {
      //      presentaction.stage = "func";
      presentaction.cmd = cmd;
    }

    /*
      ProcTableApiList() handles only on screen, not calling ajax function.
      That why 'm' can be expected without any delay. So this function call is correct.
      
      Attention:
        these 'cmd' have to be difference within below swithc/case sentence, you may think these are able to combine,
        yes it is, but I did not want to make long switch/case sentence.
        if these 'cmd' will duplicate, you know what will happen. :-p
    */
    m = procTableApiList(cmd);

    /*
      Attention:
        the drop execution is a little bit special.
    */
    let dropTable = getPreferentPropertie('droptable');
    // the input data is prefered if there were a prior table name.
    if (dropTable == null || dropTable.length <= 0) {
      for (let i = 0; i < scenario['func-tabledrop-cmd'].length; i++) {
        if (ut.indexOf(scenario['func-tabledrop-cmd'][i]) != -1) {
          let dpm = ut.split(scenario['func-tabledrop-cmd'][i]);
          dropTable = $.trim(dpm[dpm.length - 1]);
          cmd = 'droptable';
        }
      }
    }

    /*
      Attention:
        the api deleting execution is a little bit special as well.
    */
    let deleteApi = getPreferentPropertie('deleteapi');
    // the input data is prefered if there were a prior api name.
    if (deleteApi == null || deleteApi.length <= 0) {
      if (inScenarioChk(ut, 'func-apidelete-cmd')) {
        for (let i = 0; i < scenario['func-apidelete-cmd'].length; i++) {
          if (ut.indexOf(scenario['func-apidelete-cmd'][i]) != -1) {
            let dam = ut.split(scenario['func-apidelete-cmd'][i]);
            deleteApi = $.trim(dam[dam.length - 1]);
            if (deleteApi.startsWith('js')) {
              cmd = 'deleteapi';
              break;
            } else {
              // jd,ju,ji are forbidden to delete
              m = chooseMsg("func-apidelete-forbidden-msg", "", "");
            }
          }
        }
      }
    }

    // cleanup command of item, selecteditem field
    if (inScenarioChk(ut, 'func-cleanup-cmd')) {
      cmd = 'cleanup';
    }

    // genelic panel(subquery panel)
    if (inScenarioChk(ut, 'func-subpanel-open-cmd')) {
      cmd = "subquery";
    }

    if (inScenarioChk(ut, 'func-api-test-cmd')) {
      cmd = "apitest";
    }

    /*
        this 'swich' commands manipulates 'table' and 'csv file upload' 
        
        'cmd'
          1.table: show table list
          2.api: switch to show api list
          3.post: post selected columns 
          4.cancel: cancel all selected columns
          5.droptable: drop table(post)
          6.deleteapi: delete api(post)
          7.fileselectoropen: open file selector
          8.fileupload: csv file upload
          9.creanup: cleanup column/selecteditem field
          10.subquery: open subquery panel
          11.apitest: api test before registring
          default: non
 
        Attention:
          these 'cmd' have to be difference within above procTableApiList(), you may think these are able to combine,
          yes it is, but I did not want to make long switch/case sentence.
          if these 'cmd' will duplicate, you know what will happen. :-p
    */
    if (-1 < $.inArray(cmd, ['table', 'api', 'fileselectoropen'])) {
      openFunctionPanel();
    }

    switch (cmd) {
      case 'table':
        // if api test result panel is openend yet
        if (isVisibleApiContainer()) {
          showApiTestPanel(false);
        }
        /*  
          Call getAjaxData() in jetelinalib.js for getting all table list in the Database.
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
        getAjaxData(scenario["function-get-url"][1]);
        m = 'ignore';
        break;
      case 'api':
        if (isVisibleTableContainer()) {
          // cleanup the scree 
          cleanupItems4Switching();
          cleanupContainers();
          $("#table_container").hide();
          $("#genelic_panel").hide();
          // show api list
          $("#panel_left").text("API List");
          $("#api_container").show();
        }

        cleanUp("apis");

        // cleanup once because getting apilist and contain to preferent.aplist by calling getAjaxData()
        delete preferent.apilist;
        getAjaxData(scenario["function-get-url"][0]);
        m = 'ignore';
        break;
      case 'post':
        // if api test result panel is openend yet
        if (isVisibleApiContainer()) {
          showApiTestPanel(false);
        }
        /*
          Tips:
            the first 'post' is ut=cmd for asking 'sub query' sentnece.
            then if ut is positive answer alike 'yes' -> showGenelicPanel(true).
            'sub query' is mandatory if its contains multi tables, it is optional if it is single table.
            'ignore' is set in 'genelic_input' field if does not set the sub query.
 
            the secound post is ut!=cmd for execution of postion, maybe.
        */
        let subquerysentence = $("#genelic_panel input[name='genelic_input']").val();
        if (0 < selectedItemsArr.length) {
          if (ut == cmd) {
            // the first calling            
            if (containsMultiTables()) {
              // 'where sentence' is demanded if there were multi tables
              showGenelicPanel(true);
              m = chooseMsg('func-postcolumn-where-indispensable-msg', "", "");
            } else {
              // 'where sentence' is not demanded but ask it once time
              if (subquerysentence != "ignore") {
                m = chooseMsg('func-postcolumn-where-option-msg', "", "");
              } else {

              }
            }
            if (checkGenelicInput(subquerysentence)) {
              postSelectedColumns("");
              m = 'ignore';
            }

            //}
          } else if (inScenarioChk(ut, 'common-cancel-cmd')) {
            preferent.cmd = "cancel";
            //          } else if (inScenarioChk(ut, 'func-api-test-cmd')) {
            // API test mode before registering
            // before hitting this command, should desplya 'func-api-test-msg' in anywhere.
            //           postSelectedColumns("pre");
          } else {
            // the secound calling, sub query open or not
            if (inScenarioChk(ut, 'confirmation-sentences-cmd')) {
              showGenelicPanel(true);
              m = chooseMsg('func-subpanel-opened-msg', "", "");
            } else {
              $("#genelic_panel input[name='genelic_input']").val("ignore");
            }

            // use $(..).val() because this may was set 'ignore' just above.
            if ($("#genelic_panel input[name='genelic_input']").val() != "") {
              m = chooseMsg('func-postcolumn-available-msg', "", "");
            }

          }

          // important
          if (preferent.cmd != 'cancel') {
            preferent.cmd = cmd;
          }
        } else {
          m = chooseMsg('func-post-err-msg', "", "");
        }

        break;
      case 'cancel': case 'withdraw':
        // if api test result panel is openend yet
        if (isVisibleApiContainer()) {
          showApiTestPanel(false);
        }

        if (isVisibleApiContainer()) {
          // cleanup the screen
          cleanupItems4Switching();
          cleanupContainers();
          m = chooseMsg('cancel-msg', "", "");
        } else {
          // table list
          if (deleteSelectedItems()) {
            showGenelicPanel(false);
            m = chooseMsg('cancel-msg', "", "");
          } else {
            m = chooseMsg('unknown-msg', "", "");
          }
        }
        /* 
        18th Oct 
          comment outed below, but not sure it was OK or not. 
        */
        preferent.cmd = "";

        break;
      case 'droptable':
        // if api test result panel is openend yet
        if (isVisibleApiContainer()) {
          showApiTestPanel(false);
        }

        if (isVisibleTableContainer()) {
          if (dropTable != null && 0 < dropTable.length) {
            // Hit the table
            let p = $(`#table_container span:contains(${dropTable})`).filter(function () {
              return $(this).text() === dropTable;
            });

            // execute this if func-tabledrop-confirm is 'yes'
            if (inScenarioChk(ut, 'confirmation-sentences-cmd')) {
              let t = preferent.droptable;

              delete preferent.cmd;
              delete preferent.droptable;

              deleteThisTable(t);
              m = 'ignore';
            } else {
              if (p != null && 0 < p.length) {
                // Yes there is, show the delete confirmation message.
                m = chooseMsg('func-tabledrop-confirm-msg', "", "");
                preferent.cmd = cmd;
                preferent.droptable = dropTable;
              } else {
                // Well, there is nothing. Show the message fo 'func-table....'
                m = chooseMsg('func-tabledrop-msg', "", "");
                preferent.cmd = cmd;
              }
            }
          } else {
            // the request message for ordering table name
            m = chooseMsg('func-tabledrop-msg', "", "");
            preferent.cmd = cmd;
          }
          // cancel an order of table drop 
          if (inScenarioChk(ut, 'common-cancel-cmd')) {
            preferent.cmd = "";
            m = chooseMsg('cancel-msg', "", "");
          }
        } else {
          m = chooseMsg('func-tabledrop-ng-msg', "", "");
        }

        break;
      case 'deleteapi':
        if (isVisibleApiContainer()) {
          if (deleteApi != null && 0 < deleteApi.length) {
            // Hit the table
            let p = $(`#api_container span:contains(${deleteApi})`).filter(function () {
              return $(this).text() === deleteApi;
            });


            // execute this if func-tabledrop-confirm is 'yes'
            if (inScenarioChk(ut, 'confirmation-sentences-cmd')) {
              let t = preferent.deleteapi;

              delete preferent.cmd;
              delete preferent.deleteapi;

              deleteThisApi(t);
              m = 'ignore';
            } else {
              if (p != null && 0 < p.length) {
                // Yes there is, show the delete confirmation message.
                m = chooseMsg('func-apidelete-confirm-msg', "", "");
                preferent.cmd = cmd;
                preferent.deleteapi = deleteApi;
              } else {
                // Well, there is nothing. Show the message fo 'func-table....'
                m = chooseMsg('func-apidelete-msg', "", "");
                preferent.cmd = cmd;
              }
            }
          } else {
            // the request message for ordering table name
            m = chooseMsg('func-apidelete-msg', "", "");
            preferent.cmd = cmd;
          }
          // cancel an order of table drop 
          if (inScenarioChk(ut, 'common-cancel-cmd')) {
            preferent.cmd = "";
            m = chooseMsg('cancel-msg', "", "");
          }
        } else {
          m = chooseMsg('func-apidelete-ng-msg', "", "");
        }

        break;
      case 'fileselectoropen'://open file selector
        // if api test result panel is openend yet
        if (isVisibleApiContainer()) {
          showApiTestPanel(false);
        }

        $("#my_form input[name='upfile']").click();
        m = chooseMsg('func-fileupload-open-msg', "", "");
        break;
      case 'fileupload'://csv file upload
        const f = $("input[type=file]").prop("files");
        if (f != null && 0 < f.length) {
          m = 'ignore';
          fileupload();
        } else {
          m = chooseMsg('func-fileupload-msg', "", "");
        }

        break;
      case 'cleanup': //clean up the panels
        cleanupItems4Switching();
        deleteSelectedItems();
        cleanUp("items");
        cleanupContainers();
        m = chooseMsg('success-msg', '', '');
        break;
      case 'subquery': //open subquery panel
        // if api test result panel is openend yet
        if (isVisibleApiContainer()) {
          showApiTestPanel(false);
        }

        showGenelicPanel(true);
        m = chooseMsg('func-subpanel-opened-msg', '', '');
        break;
      case 'apitest':
        if (0 < selectedItemsArr.length) {
          // API test mode before registering
          // before hitting this command, should desplay 'func-api-test-msg' in anywhere.
          postSelectedColumns("pre");
        }
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
  let m = "ignore";
  let targetlist = "";

  if (presentaction.cmd == 'table') {
    targetlist = "#table_container";
  } else if (presentaction.cmd == 'api') {
    targetlist = "#api_container";
  }

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

    /*
      Tips:
        there are some candidates command to select column.
        these are unified to 'select'.
    */
    if (inScenarioChk(t[0], 'func-item-select-cmd')) {
      t[0] = 'select';
    }

    if (inScenarioChk(t[0], 'func-selecteditem-cancel-cmd')) {
      t[0] = 'cancel';
    }

    if (inScenarioChk(t[0], 'func-list-cmd')) {
      switch (t[0]) {
        case 'open': case 'close':
          /* 
            Caution:
              do not break because of open/close are same
              go to 'close' if it were 'open' as well, this is tricky! :-)
          */
          m = chooseMsg('unknown-msg', "", "");
          $(targetlist).find("span").each(function (i, v) {
            let findselect = false;
            // only the api-number is ok in api list
            if (presentaction.cmd == 'api') {
              if (v.textContent.indexOf(t[1]) != -1) {
                findselect = true;
              }
            } else {
              if (v.textContent == t[1]) {
                findselect = true;
              }
            }

            if (findselect) {
              if ((t[0] == 'close' && $(this).hasClass("activeItem")) ||
                (t[0] == 'open' && !$(this).hasClass("activeItem"))) {
                listClick($(this));
                m = chooseMsg('success-msg', "", "");
                return;
              }
            }
          });

          /*
            Tips:
              whichever table or api, this field should be initialized if there were.
          */
          if ($("#container .newapino").text() != null && 0 < $("#container .newapino").text().length) {
            $("#container .newapino").remove();
          }

          break;
        case 'select':
          if (presentaction.cmd == 'table') {
            $("#columns").find("span").each(function (i, v) {
              let findselect = false;
              if ($(".activeItem").length == 1) {
                /*
                  Tips:
                    can selct by only the column name when opening only one table. 
                    I mean 'ftest.id' -> 'id' is OK.
                */
                if (v.textContent.indexOf(t[1]) != -1) {
                  findselect = true;
                }
              } else {
                /*
                  Tips:
                    must match in full name when multi tables open
                */
                if (v.textContent == t[1]) {
                  findselect = true;
                }
              }

              if (findselect) {
                itemSelect($(this));
                m = chooseMsg('success-msg', "", "");
              }
            });
          }

          if (m.length == 0) {
            m = chooseMsg('unknown-msg', "", "");
          }

          break;
        case 'cancel':
          if (presentaction.cmd == 'table') {
            $("#container").find("span").each(function (i, v) {
              let findselect = false;
              /*
                Tips:
                  same logic as case 'select'
              */
              if ($(".activeItem").length == 1) {
                if (v.textContent.indexOf(t[1]) != -1) {
                  findselect = true;
                }
              } else {
                if (v.textContent == t[1]) {
                  findselect = true;
                }
              }

              if (findselect) {
                itemSelect($(this));
                m = chooseMsg('success-msg', "", "");
              }
            });
          }

          if (m.length == 0) {
            m = chooseMsg('unknown-msg', "", "");
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
const containsMultiTables = () => {
  if (0 < selectedItemsArr.length) {
    let tables = [];
    $.each(selectedItemsArr, function (i, v) {
      if (0 < v.length && v.indexOf('.') != -1) {
        let p = v.split('.');
        if ($.inArray(p[0], tables) === -1) {
          tables.push(p[0]);
        }
      }
    });

    if (1 < tables.length) {
      return true;
    } else {
      return false;
    }
  }
}
/**
 * @function showGenelicPanel
 *
 * @param {boolean} true -> show, false -> hide
 *  
 * genelic panel open or close
 */
const showGenelicPanel = (b) => {
  if (b) {
    if (isVisibleTableContainer()) {
      /*
        in the case of showing table list, this field is for expecting 'Sub Query'
      */
      $("#genelic_panel text[name='genelic_text']").text("Sub Query:");
      $("#genelic_panel input[name='genelic_input']").attr('placeholder', 'where .....');
    }

    $("#genelic_panel").show();
    $("#genelic_panel input[name='genelic_input']").focus();
  } else {
    $("#genelic_panel").hide();
    $("#genelic_panel text[name='genelic_text']").text("");
    $("#jetelina_panel [name='chat_input']").focus();
  }
}
/**
 * @function checkGenelicInput
 * @param {string} s  sub query sentence strings 
 * @returns {boolean}  true->acceptable  false->something suspect
 * 
 * check sub query sentence. 'ignore' is always acceptable.
 */
const checkGenelicInput = (s) => {
  let ret = true;

  if (s == "") {
    ret = false;
  } else if (s != "ignore") {
    // sub query check
  }

  return ret;
}
/**
 * @function deleteThisApi
 * @param {string} apino  target api name
 * 
 * Ajax function for deleting the target api from api list doc. 
 */
const deleteThisApi = (apino) => {
  if (0 < apino.length || apino != undefined) {
    let pd = {};
    pd["apino"] = $.trim(apino);
    let dd = JSON.stringify(pd);

    $.ajax({
      url: "/deleteapi",
      type: "post",
      data: dd,
      contentType: 'application/json',
      dataType: "json",
      xhr: function () {
        ret = $.ajaxSettings.xhr();
        inprogress = true;// in progress. for priventing accept a new command.
        typingControll(chooseMsg('inprogress-msg', "", ""));
        return ret;
      }
    }).done(function (result, textStatus, jqXHR) {
      $(`#api_container span:contains(${apino})`).filter(function () {
        if ($(this).text() === apino) {
          $(this).remove();
          removeColumn(apino);
          return;
        }
      });

      typingControll(chooseMsg('success-msg', "", ""));
    }).fail(function (result) {
      checkResult(result);
      console.error("deleteThisApi() faild: ", result);
      typingControll(chooseMsg('fail-msg', "", ""));
    }).always(function () {
      // release it for allowing to input new command in the chatbox 
      inprogress = false;
    });
  } else {
    console.error("deleteThisApi() apino is not defined");
  }
}

// return to the chat box if 'return key' is typed in genelic_panel
$(document).on("keydown", "#genelic_panel input[name='genelic_input']", function (e) {
  if (e.keyCode == 13) {
    $("#jetelina_panel [name='chat_input']").focus();
  }
});
