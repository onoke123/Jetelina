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
      dropThisTable(tables)　Ajax function for deleting the target table from DataBase. 
      postSelectedColumns(mode) Ajax function for posting the selected columns.
      functionPanelFunctions(ut)　Exectute some functions ordered by user chat input message    
      containsMultiTables() Judge demanding 'where sentence' before post to the server
      showGenelicPanel(b) genelic panel open or close. 
      checkGenelicInput() check genelic panel input. caution: will imprement this in V2 if necessary
      deleteThisApi() Ajax function for deleting the target api from api list doc.
*/
let selectedItemsArr = [];
const MYFORM = "#my_form";
const UPFILE = `${MYFORM} input[name='upfile']`;
const leftPanel = "#panel_left";
const GENELICPANELINPUT = `${GENELICPANEL} input[name='genelic_input']`;
const GENELICPANELTEXT = `${GENELICPANEL} text[name='genelic_text']`;

/*
   change label when selected a file
*/
$(UPFILE).on("change", function () {
  let fullfilename = $(this).val();
  if (fullfilename != null && 0 < fullfilename.length) {
    let p = fullfilename.split("\\");
    let filename = p[p.length - 1];
    $(`${MYFORM} label span`).text(filename);
    $(FILEUP).addClass("genelic_panel"); // blinking panel border but not fire immediately
    cancelableCmdList.push(FILESELECTOROPEN);
    typingControll(chooseMsg("func-fileupload-upload-msg", filename, "r"));
  } else {
    if ($(this).hasClass("genelic_panel")) {
      $(this).removeClass("genelic_panel");
    }
  }
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
    $(CONDITIONPANEL).hide();
  }

  $(FUNCTIONPANEL).show().animate({
    width: window.innerWidth * 0.8,
    height: window.innerHeight * 0.8,
    top: "10%",
    left: "10%"
  }, ANIMATEDURATION);

  if (isVisibleColumns()) {
    $(FILEUP).draggable().animate({
      top: "4%",
      left: "5%"
    }, ANIMATEDURATION);
    $("#left_panel").draggable().animate({
      top: "10%",
      left: "5%"
    }, ANIMATEDURATION);
    $(COLUMNSPANEL).draggable().animate({
      top: "10%",
      left: "30%"
    }, ANIMATEDURATION);
    $(CONTAINERPANEL).draggable().animate({
      bottom: "5%",
      left: "30%"
    }, ANIMATEDURATION);
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
  if ($(TABLECONTAINER).is(":visible")) {
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
  if ($(APICONTAINER).is(":visible")) {
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
  if ($(GENELICPANEL).is(":visible")) {
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
  if ($(COLUMNSPANEL).is(":visible")) {
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
  //  let item = p.text();
  let item = p.attr("colname");

  // delete the showing because the api no is displayed in there initially.
  if ($(`${CONTAINERPANEL} span`).hasClass('apisql')) {
    $(`${CONTAINERPANEL} span`).remove();
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
      p.detach().appendTo(CONTAINERPANEL);
    }

    cancelableCmdList.push(SELECTITEM);
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
    $(p).detach().appendTo(`${COLUMNSPANEL} div`);
    ret = true;
  } else {
    // delete all items
    selectedItemsArr.length = 0;
    $(`${CONTAINERPANEL} span`).removeClass("selectedItem");
    $(`${CONTAINERPANEL} .apisql`).remove();
    $(`${COLUMNSPANEL} .apisql`).remove();
    $(`${CONTAINERPANEL} span`).detach().appendTo(`${COLUMNSPANEL} div`);
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
    $(".item_area .item,.apisql").remove();
  } else if (s == "tables") {
    // clean up tables
    $(`${TABLECONTAINER} .table`).remove();
  } else if (s == "apis") {
    // clean up API list
    $(`${APICONTAINER} .api`).remove();
  }
}
/**
 * @function cleanupItems4Switching
 * 
 * clear screen in activeItem class when switching table list/api list
 */
const cleanupItems4Switching = () => {
  cleanUp("items");
  if (isVisibleTableContainer()) {
    $(`${TABLECONTAINER} span`).removeClass("activeItem");
  } else if (isVisibleApiContainer()) {
    $(`${APICONTAINER} span`).removeClass("activeItem");
    $(`${CONTAINERPANEL} span`).remove();
  }
}
/**
* @function cleanupContainers
* 
* clear screen in the detail zone showing when switching table list/api list
*/
const cleanupContainers = () => {
  $(`${CONTAINERPANEL} span,${CONDITIONPANEL} span`).remove();
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
  let fd = new FormData($(MYFORM).get(0));
  $("#upbtn").prop("disabled", true);

  //  const uploadFilename = $("input[type=file]").prop("files")[0].name;
  const uploadFilename = $(UPFILE).prop("files")[0].name;
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
    //    $("input[type=file]").val("");
    $(UPFILE).val("");
    $("#upbtn").prop("disabled", false);

    if (checkResult(result)) {
      $(`${MYFORM} label span`).text("Upload CSV File");

      //refresh table list 
      if (isVisibleTableContainer()) {
        cleanUp("tables");
        getAjaxData(scenario["function-get-url"][1]);
      } else {
        typingControll(chooseMsg('success-msg', "", ""));
      }

      if (isVisibleApiContainer()) {
        chatKeyDown(scenario["func-show-table-list-cmd"][0]);
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
    $(FILEUP).removeClass("genelic_panel");
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
            return false;
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
      cleanUp("items");
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
          $(`${COLUMNSPANEL} .item_area`).append(`<span class="apisql apiin"><bold>IN:</bold>${setApiIF_In(t, s)}</span>`);
          $(`${COLUMNSPANEL} .item_area`).append(`<span class="apisql apiout"><bold>OUT:</bold>${setApiIF_Out(t, s)}</span>`);
          // sample execution sql
          $(CONTAINERPANEL).append(`<span class="apisql"><p>${setApiIF_Sql(s)}</p></span>`);
        }
      }
    }

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
    if (s.subquery != null && 0 < s.subquery.length && s.subquery != IGNORE) {
      let s_subquery = s.subquery;
      let subquery_str = "";
      let isCurry = s_subquery.indexOf('{');
      while (-1 < isCurry) {
        let sp = s_subquery.indexOf('{');
        let ep = s_subquery.indexOf('}');
        if (sp != -1 && ep != -1) {
          let cd = s_subquery.substring(sp + 1, ep);
          subquery_str += `'${cd}': `;
          if (s_subquery[sp - 1] == "\'") {
            subquery_str += `'{${cd}}', `;
          } else {
            subquery_str += `{ ${cd}}, `;
          }

          s_subquery = s_subquery.substring(ep + 1, s_subquery.length);
        }
        isCurry = s_subquery.indexOf('{');
      }

      subquery_str = subquery_str.slice(0, -1);
      ret = `{"apino": \"${t}\","subquery":\"[${subquery_str}]\"}`;
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
  if (s.subquery != null && s.subquery != IGNORE) {
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
  $(`${COLUMNSPANEL} .item, ${CONTAINERPANEL} .item`).remove(`:contains(${p}_)`);
}
/**
 * @function dropThisTable
 * @param {Array} tables  target tables name
 * 
 * Ajax function for deleting the target tables from DataBase. 
 */
const dropThisTable = (tables) => {
  //  if (0 < tablename.length || tablename != undefined) {
  let pd = {};
  //    pd["tablename"] = $.trim(tablename);
  pd["tablename"] = tables;
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
    for (let i = 0; i < tables.length; i++) {
      $(`${TABLECONTAINER} span`).filter(function () {
        if ($(this).text() === tables[i]) {
          $(this).remove();
          removeColumn(tables[i]);
          cleanupContainers();
          return;
        }
      });
    }

    typingControll(chooseMsg('success-msg', "", ""));
  }).fail(function (result) {
    checkResult(result);
    console.error("dropThisTable() faild: ", result);
    typingControll(chooseMsg('fail-msg', "", ""));
  }).always(function () {
    // release it for allowing to input new command in the chatbox 
    inprogress = false;
    // delete from the list
    rejectCancelableCmdList(TABLEAPIDELETE);

  });
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
  let subq = $(GENELICPANELINPUT).val();
  if ((subq != IGNORE && subq != "") && subq.indexOf("where") == -1) {
    subq = `where ${subq}`;
  }

  pd["subquery"] = subq;

  let dd = JSON.stringify(pd);
  let posturl = scenario["function-post-url"][4];
  if (mode == "pre") {
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

        $(CONTAINERPANEL).append(`<span class="newapino"><p>api no is ${result.apino}</p></span>`);
        typingControll(chooseMsg('success-msg', "", ""));
      } else if (result.resembled != null && 0 < result.resembled.length) {
        $(CONTAINERPANEL).append(`<span class="newapino"><p>there is similar API already exist:  ${result.resembled}</p></span>`);
      }

      if (isVisibleGenelicPanel()) {
        $(GENELICPANEL).hide();
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
      $(GENELICPANELINPUT).val('');
      $(`${CONTAINERPANEL} .selectedItem`).remove();
//      cleanUp("items");
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
  // default return chat message
  let m = IGNORE;
  let cmd = "";

  /*
    Tips:
      'cancel' and 'cleanup' commands are be prioritized.
      the next is preferent.cmd
      then other commands
  */
  if (inScenarioChk(ut, 'common-cancel-cmd')) {
    cmd = 'cancel';
    preferent.cmd = "";
  } else if (inScenarioChk(ut, 'func-cleanup-cmd')) {
    cmd = 'cleanup';
  } else if (inScenarioChk(ut, 'func-fileupload-open-cmd')) {
    cmd = FILESELECTOROPEN;
  } else if (inScenarioChk(ut, 'func-fileupload-cmd')) {
    cmd = 'fileupload';
  } else if (inScenarioChk(ut, 'func-show-table-list-cmd') ||
    inScenarioChk(ut, 'func-show-api-list-cmd')) {
    cmd = TABLEAPILISTOPEN;
  } else if (inScenarioChk(ut, 'func-table-api-open-close-cmd') ||
    inScenarioChk(ut, 'func-item-select-cmd') ||
    inScenarioChk(ut, "func-item-select-all-cmd")) {
    cmd = SELECTITEM;
  } else if (inScenarioChk(ut, 'func-tabledrop-cmd') ||
    inScenarioChk(ut, 'func-apidelete-cmd')) {
    cmd = TABLEAPIDELETE;
  } else if (inScenarioChk(ut, 'common-post-cmd')) {
    cmd = 'post';
  } else if (inScenarioChk(ut, 'func-subpanel-open-cmd')) {
    cmd = "subquery";
  } else if (inScenarioChk(ut, 'func-api-test-cmd')) {
    cmd = "apitest";
  } else if (inScenarioChk(ut, 'func-api-test-panel-show-cmd')) {
    showApiTestPanel(true);
  } else if (inScenarioChk(ut, 'func-api-test-panel-hide-cmd')) {
    showApiTestPanel(false);
  } else if (inScenarioChk(ut, 'func-subpanel-close-cmd')) {
    showGenelicPanel(false);
  } else {
    cmd = getPreferentPropertie('cmd');
  }

  if (cmd.length < 0) {
    cmd = ut;
  }
  /*
      this 'swich' commands manipulates 'table' and 'csv file upload'.
      capitalized 'cmd' are defined as 'const' because these are cancelable commands. 
      
      'cmd'
        1.FILESELECTOROPEN: open file selector
        2.fileupload: csv file upload
        3.TABLEAPILISTOPEN: handle table list and/or api list
        4.SELECTITEM: select columns from opening tables
        5.TABLEAPIDELETE: drop table in the table list and/or delete api in the api list
        6.post: post selected columns 
        7.cancel: cancel all selected columns
        8.creanup: cleanup column/selecteditem field
        9.subquery: open subquery panel
        10.apitest: api test before registring
        default: non
  */
  if (-1 < $.inArray(cmd, [TABLEAPILISTOPEN, FILESELECTOROPEN])) {
    openFunctionPanel();
  } else {
    // nothing happens without opening function panel :P
  }

  switch (cmd) {
    case FILESELECTOROPEN://open file selector
      $(UPFILE).click();
      m = chooseMsg('func-fileupload-open-msg', "", "");
      break;
    case 'fileupload'://csv file upload
      const f = $(UPFILE).prop("files");
      if (f != null && 0 < f.length) {
        m = IGNORE;
        fileupload();
      } else {
        m = chooseMsg('func-fileupload-msg', "", "");
      }

      break;
    case TABLEAPILISTOPEN:
      // these defaults are for table list
      let hidepanel = APICONTAINER;
      let showpanel = TABLECONTAINER;
      let paneltitle = "Table List";
      let cleanup = "tables";
      let geturl = scenario["function-get-url"][1];

      // cleanup the screen first 
      cleanupItems4Switching();
      cleanupContainers();
//      cleanUp("items");

      if (inScenarioChk(ut, 'func-show-table-list-cmd')) {
        if (isVisibleApiContainer()) {
          showApiTestPanel(false);
        }
      } else if (inScenarioChk(ut, 'func-show-api-list-cmd')) {
        if (isVisibleTableContainer()) {
          hidepanel = TABLECONTAINER;
          showpanel = APICONTAINER;
          paneltitle = "API List";
          $(GENELICPANEL).hide();
        }

        cleanup = "apis";
        geturl = scenario["function-get-url"][0];
        // cleanup once because getting apilist and contain to preferent.aplist by calling getAjaxData()
        delete preferent.apilist;
      }

      cleanUp(cleanup);
      $(hidepanel).hide();
      $(leftPanel).text(paneltitle);
      $(showpanel).show();

      if ((showpanel == TABLECONTAINER) && !$(`${TABLECONTAINER} span`).hasClass('table')) {
        getAjaxData(geturl);
      } else if ((showpanel == APICONTAINER) && !$(`${APICONTAINER} span`).hasClass('api')) {
        getAjaxData(geturl);
      }

      m = IGNORE;
      break;
    case SELECTITEM:
      let findflg = false;
      let t = ut.split(' ');

      // for opening table 
      if (isVisibleTableContainer()) {
        $(`${CONTAINERNEWAPINO}`).remove();
        for (let n = 0; n < t.length; n++) {
          $(`${TABLECONTAINER} span`).each(function (i, v) {
            if (v.textContent == t[n]) {
              $(this).hasClass("activeItem");
              listClick($(this));
              m = chooseMsg('success-msg', "", "");
              findflg = true;
            }
          });
        }
      }

      // for openging api, because possible opening both table/api list
      if (!findflg && isVisibleApiContainer()) {
        for (let n = 0; n < t.length; n++) {
          $(`${APICONTAINER} span`).each(function (i, v) {
            if (v.textContent == t[n]) {
              $(this).hasClass("activeItem");
              listClick($(this));
              m = chooseMsg('success-msg', "", "");
              findflg = true;
            }
          });
        }
      }

      // !findlg meaning is not for openging table or api, this time is for selecting columns in opening tables
      if (!findflg) {
        if (inScenarioChk(ut, "func-item-select-all-cmd")) {
          // select all items
          $(COLUMNSPANEL).find("span").each(function () {
            itemSelect($(this));
          });
        } else {
          // ordered item
          for (let n = 0; n < t.length; n++) {
            $(COLUMNSPANEL).find("span").each(function (i, v) {
              if (v.textContent.indexOf(t[n]) != -1) {
                itemSelect($(this));
                m = chooseMsg('success-msg', "", "");
              }
            });
          }
        }
      }

      if (m.length == 0) {
        m = chooseMsg('unknown-msg', "", "");
      }

      break;
    case TABLEAPIDELETE:
      let utarray = ut.split(' ');

      if (inScenarioChk(ut, 'confirmation-sentences-cmd')) {
        // execution drop table and/or delete api
        if (isVisibleTableContainer) {
          let droptables = [];
          $(`${TABLECONTAINER} span`).filter('.deleteItem').each(function () {
            droptables.push($(this).text());
          });

          if (0 < droptables.length) {
            preferent.cmd = "";
            dropThisTable(droptables);
          }
        }

        if (isVisibleApiContainer) {
          let deleteapis = [];
          $(`${APICONTAINER} span`).filter('.deleteItem').each(function () {
            deleteapis.push($(this).text());
          });

          if (0 < deleteapis.length) {
            preferent.cmd = "";
            deleteThisApi(deleteapis);
          }
        }

        m = IGNORE;
      } else {
        preferent.cmd = TABLEAPIDELETE;
        cancelableCmdList.push(TABLEAPIDELETE);
        /*
          Tips:
            searching for all tables and apis order by utarray.
  
            ex. ut->"delete js156 api" utarray->[delete,js156,api]
                js156 found in APICONTAINER
                ut ->"drop usertable" utarray->[drop,usertable]
                usertable found in TABLECONTAINER
  
          Attention:
            only 'js*' api can be deleted.
        */
        for (let i = 0; i < utarray.length; i++) {
          $(`${TABLECONTAINER}`).find("span").each(function () {
            if ($(this).text() == utarray[i]) {
              $(this).addClass("deleteItem");
              m = chooseMsg("common-confirm-msg", "", "");
            }
          });

          let jijujdexist = false;
          $(`${APICONTAINER}`).find("span").each(function () {
            if (utarray[i].startsWith(('js')) && ($(this).text() == utarray[i])) {
              $(this).addClass("deleteItem");
              m = chooseMsg("common-confirm-msg", "", "");
            } else if (utarray[i].startsWith('ji') || utarray[i].startsWith('ju') || utarray[i].startsWith('jd')) {
              jijujdexist = true;
            }
          });

          if (jijujdexist) {
            m = chooseMsg("func-apidelete-forbidden-msg", "", "");
          }
        }
      }

      if (m.length == 0) {
        m = chooseMsg("common-alert-msg", "", "");
      }


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
      let subquerysentence = $(GENELICPANELINPUT).val();
      if (0 < selectedItemsArr.length) {
        if (ut == cmd) {
          // the first calling            
          if (containsMultiTables()) {
            // 'where sentence' is demanded if there were multi tables
            showGenelicPanel(true);
            m = chooseMsg('func-postcolumn-where-indispensable-msg', "", "");
          } else {
            // 'where sentence' is not demanded but ask it once time
            if (subquerysentence != IGNORE) {
              m = chooseMsg('func-postcolumn-where-option-msg', "", "");
            } else {

            }
          }
          if (checkGenelicInput(subquerysentence)) {
            postSelectedColumns("");
            m = IGNORE;
          }
        } else {
          // the secound calling, sub query open or not
          if (inScenarioChk(ut, 'confirmation-sentences-cmd')) {
            showGenelicPanel(true);
            m = chooseMsg('func-subpanel-opened-msg', "", "");
          } else {
            $(GENELICPANELINPUT).val(IGNORE);
          }

          // use $(..).val() because this may was set 'ignore' just above.
          if ($(GENELICPANELINPUT).val() != "") {
            m = chooseMsg('func-postcolumn-available-msg', "", "");
          }

        }

        // important
        preferent.cmd = cmd;
      } else {
        m = chooseMsg('func-post-err-msg', "", "");
      }

      break;
    case 'cancel': case 'withdraw':
      /*
        Tips:
          'cancel' may happen here and there, this cancel routine is for 'cancel selected item', 'cancel file upload' ....
          also it may happen in file up loading
  
          Attention:
            in the case of cancel 'drop table' and 'delete api' are be canceld every selected tables and apis.
            in the case of cancel 'itme(column)' is able to be canceled selectively: each 'cancel <column name>'.
      */
      // cancel table drop and/or api delete
      if (inCancelableCmdList(TABLEAPIDELETE)) {
        // if api test result panel is openend yet
        if (isVisibleApiContainer()) {
          showApiTestPanel(false);
        }

        if (isVisibleApiContainer()) {
          // cleanup the screen
          cleanupItems4Switching();
          cleanupContainers();
          rejectCancelableCmdList(TABLEAPIDELETE);
          m = chooseMsg('cancel-msg', "", "");
        } else {
          // table list
          if (deleteSelectedItems()) {
            showGenelicPanel(false);
            rejectCancelableCmdList(TABLEAPIDELETE);
            m = chooseMsg('cancel-msg', "", "");
          } else {
            m = chooseMsg('unknown-msg', "", "");
          }
        }

        $(`${TABLECONTAINER} span`).removeClass('deleteItem');
        $(`${APICONTAINER} span`).removeClass('deleteItem');
      } else if (inCancelableCmdList(FILESELECTOROPEN)) {
        $(UPFILE).val("");
        $(`${MYFORM} label span`).text("Upload CSV File");
        $(FILEUP).removeClass("genelic_panel");
        rejectCancelableCmdList(FILESELECTOROPEN);
        m = chooseMsg("cancel-msg", "", "");
      } else if (inCancelableCmdList(SELECTITEM)) {
        let t = ut.split(' ');
        // cancel selected columns
        if (inScenarioChk(ut, "func-selecteditem-all-cancel-cmd")) {
          // cancel all items
          $(CONTAINERPANEL).find("span").each(function (i, v) {
            itemSelect($(this));
          });

          if (isVisibleGenelicPanel()) {
            showGenelicPanel(false);
          }

          selectedItemsArr = [];
          m = chooseMsg('cancel-msg', "", "");
        } else {
          // cancel each item
          $(CONTAINERPANEL).find("span").each(function (i, v) {
            if (v.textContent.indexOf(t[1]) != -1) {
              itemSelect($(this));
              rejectSelectedItemsArr(v.textContent);
              m = chooseMsg('cancel-msg', "", "");
            }
          });
        }

        if (!$(`${CONTAINERPANEL} span`).hasClass("selectedItem")) {
          rejectCancelableCmdList(SELECTITEM);
        }

      }

      break;
    case 'cleanup': //clean up the panels
      cleanupItems4Switching();
      deleteSelectedItems();
//      cleanUp("items");
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
      $(GENELICPANELTEXT).text("Sub Query:");
      $(GENELICPANELINPUT).attr('placeholder', 'where .....');
    }

    $(GENELICPANEL).show();
    $(GENELICPANELINPUT).focus();
  } else {
    $(GENELICPANEL).hide();
    $(GENELICPANELINPUT).val("");
    focusonJetelinaPanel();
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
  } else if (s != IGNORE) {
    // sub query check
    /*
      Tips:
        check this sub query strings with #container->span text is in selected items,
        check this string is collect,
        check this string has its post query parameter, like '{parameter}',
                                                                           etc...
        well, there are a lot of tasks in here, therefore wanna set them beside now,
        writing the sub query is on your own responsibility. :)
    */
  }

  return ret;
}
/**
 * @function deleteThisApi
 * @param {Array} apis  target api name
 * 
 * Ajax function for deleting the target api from api list doc. 
 */
const deleteThisApi = (apis) => {
  //  if (0 < apino.length || apino != undefined) {
  let pd = {};
  //   pd["apino"] = $.trim(apino);
  pd["apino"] = apis;
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
    for (let i = 0; i < apis.length; i++) {
      $(`${APICONTAINER} span`).filter(function () {
        if ($(this).text() === apis[i]) {
          $(this).remove();
          removeColumn(apis[i]);
          cleanupContainers();
          return;
        }
      });
    }

    typingControll(chooseMsg('success-msg', "", ""));
  }).fail(function (result) {
    checkResult(result);
    console.error("deleteThisApi() faild: ", result);
    typingControll(chooseMsg('fail-msg', "", ""));
  }).always(function () {
    // release it for allowing to input new command in the chatbox 
    inprogress = false;
    // delete from the list
    rejectCancelableCmdList(TABLEAPIDELETE);
  });
}

// return to the chat box if 'return key' is typed in genelic_panel
$(document).on("keydown", GENELICPANELINPUT, function (e) {
  if (e.keyCode == 13) {
    focusonJetelinaPanel()
  }
});