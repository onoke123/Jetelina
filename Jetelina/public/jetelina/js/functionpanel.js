/**
    JS library for Jetelina Function Panel
    @author Ono Keiji

    This js lib works with dashboard.js and jetelinalib.js for the Function Panel.
    
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
      cleanupContainers(s) clear screen in the detail zone showing when switching table list/api list 
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
      whichCommandsInOrders(s) match with user input in cmdCandidates
      cleanupRelatedList(b) clear screen in api_container panel and/or relatedDataList object
      displayTablesAndApis() display table list and api list
      refreshApiList() refresh displaying of api list
      refreshTableList() refresh displaying of table list
      tidyupcmdCandidates(targetcmd) reject 'targetcmd' from cmdCandidates
*/
let selectedItemsArr = [];
let cmdCandidates = [];// ordered commands for checking duplication 

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
    let moveLeft = -10/*-150/*20*/;
    let moveDown = -10 /*-90/*10*/;

    $("#pop-up").css('top', e.pageY + moveDown).css('left', e.pageX + moveLeft);

    let d = $(this).attr("d");

    $('div#pop-up').text(`e.g. ${d}`).show();
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
    width: window.innerWidth * 0.92,
    height: window.innerHeight * 0.92,
    top: "2%",
    left: "2%"
  }, ANIMATEDURATION);

  if (isVisibleColumns()) {
    $(FILEUP).draggable().animate({
      top: "4%",
      left: "1%" //"5%"
    }, ANIMATEDURATION);
    $("#left_panel").draggable().animate({
      top: "10%",
      left: "1%" //"5%"
    }, ANIMATEDURATION);
    $(COLUMNSPANEL).draggable().animate({
      top: "10%",
      left: "19%" //"30%"
    }, ANIMATEDURATION);
    $(CONTAINERPANEL).draggable().animate({
      bottom: "6%",
      left: "19%" //"30%"
    }, ANIMATEDURATION);

    $(RELATEDTABLESAPIS).draggable().animate({
      top: "10%",
      left: "82%"
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
//  if ($(`${CONTAINERPANEL} span`).hasClass('apisql')) {
//    $(`${CONTAINERPANEL} span`).remove();
//  }

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

    cmdCandidates = [];
    cancelableCmdList.push(SELECTITEM);
    selectedItemsArr.push(item);
  }

  // open subquery input field anyhow
  showGenelicPanel(true);
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
    $(p).detach().appendTo(`${COLUMNSPANEL} div[name='columns_area']`);
    ret = true;
  } else {
    // delete all items
    selectedItemsArr = [];
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
  /*
    Tips:
      be empty selectedItemArr, 
      .... but i forgot why it did here... 
      leave it as a good luck charm  :P
  */
  selectedItemsArr.splice(0);

  $("#columns_title").text("");

  if (s == "items") {
    // clean up items
    /*
      Attention:
        remove targets are
          '.item' at '.item_area'
          and all '.apisql'
    */
    $(".item_area > .item, .apisql, .selectedItem").remove();
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
  //  if (isVisibleTableContainer()) {
  $("#columns_title").text("");
  $(`${TABLECONTAINER} span`).removeClass("activeItem");
  //  } else if (isVisibleApiContainer()) {
  $(`${APICONTAINER} span`).removeClass("activeItem");
  $(`${CONTAINERPANEL} span`).remove();
  //  }
}
/**
* @function cleanupContainers
* @param {string} s  point to target : 'api' or null
*
* clear screen in the detail zone showing when switching table list/api list
*/
const cleanupContainers = (s) => {
  if( s == null || s == "" ){
    s = "all";
  }

  showApiTestPanel(false);

  if( s == "api" ){
    if( selectedItemsArr != null && selectedItemsArr.length == 0 ){
      showGenelicPanel(false);
    }

    $(`${CONTAINERPANEL} span, ${COLUMNSPANEL} span`).filter(".apisql").remove();
  }else{
    showGenelicPanel(false);
    $(`${CONTAINERPANEL} span,${CONDITIONPANEL} span`).remove();
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
    if (checkResult(result)) {
      // clean up
      $(UPFILE).val("");
      $("#upbtn").prop("disabled", false);
      $(`${MYFORM} label span`).text("Upload CSV File");

      //refresh table list 
      cleanupRelatedList(true);
      typingControll(chooseMsg('refreshing-msg', '', ''));

      chatKeyDown(scenario["func-show-table-list-cmd"][0]);
    } else {
      // csv file format error
      typingControll(chooseMsg('func-csv-format-error-msg', "", ""));
    }
  }).fail(function (result) {
    checkResult(result);
    // something error happened
    console.error("fileupload(): unexpected error");
    typingControll(chooseMsg("fail-msg", "", ""));
  }).always(function () {
    // release it for allowing to input new command in the chatbox 
    inprogress = false;
    $(FILEUP).removeClass("genelic_panel");
    rejectCancelableCmdList(FILESELECTOROPEN);
    return true;
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
  cmdCandidates = [];
  /*
    Tips:
        in case of clicking 'table', relatedDataList.type = "api", because the server returns the related api list
        opposit in case of 'api'
  */
  relatedDataList.type = "api";
  if (p.hasClass("api")) {
    relatedDataList.type = "table";
  }

  let sourcePanel = TABLECONTAINER; // the 'p' is in here
  let relatedPanel = APICONTAINER;// the related items are in there
  if (relatedDataList.type == "table") {
    sourcePanel = APICONTAINER;
    relatedPanel = TABLECONTAINER;
  }

  if (p.hasClass("activeItem") || p.hasClass("activeandrelatedItem")) {
    /*
      in case to turn p to 'INACTIVE'
    */
    if (p.hasClass("api")) {
      cleanupContainers("api");
    } else {

    }
    /* 
        Tips:
          clean up in the relation data list.
          a little bit complex.
          only unique api in target table removes from the related list.
          i mean
            relatedDataList["table1"] = ["ju1","jd2","ji3","js4","js5"]
            relatedDataList["table2"] = ["ju11","jd12","ji13","js14","js5"]
  
            "ju1","jd2","ji3","js4" should be removed when "table1" has been inactive.
            "js5" should be remained in the list, because it is duplicated with "table2".

          in the case of 'api', '.activeItem' or '.activeandrelatedItem' allows to exists only one,
          therefore it can use the below codes as well because it's simple logic.
    */
    let activeArr = [];
    if (relatedDataList[t] != null) {
      /*
        gather 'activeItem' items in the list

        Attention:
          'sourcePanel' vs activeArr
            in case APICONTAINER, activeArr.length = 1.
            in case TABLECONTAINER, activeArr.length >= 1.
      */
      $(`${sourcePanel} span`).filter('.activeItem, .activeandrelatedItem').each(function () {
        activeArr.push($(this).text());
      });

      if (1 < activeArr.length) {
        $(`${relatedPanel} span`).filter('.relatedItem, .activeandrelatedItem').each(function (i, v) {
          if ($.inArray(v.textContent, relatedDataList[t]) != -1) {
            if (p.hasClass("activeandrelatedItem")) {
              p.removeClass("activeandrelatedItem");
              p.addClass("activeItem");
            }

            if (v.textContent.startsWith('js')) {
              for (let i in activeArr) {
                if ($.inArray(v.textContent, relatedDataList[activeArr[i]]) != -1) {
                }else{
                  $(this).removeClass("relatedItem");
                }
              }
            }else{
              $(this).removeClass("relatedItem");
            }
          }
        });
      } else {
        $(`${relatedPanel} span`).filter('.relatedItem, .activeandrelatedItem').each(function (i, v) {
          if (p.hasClass("activeandrelatedItem")) {
            p.removeClass("activeandrelatedItem");
            p.addClass("activeItem");
          }
          
          $(this).removeClass("relatedItem");
        });
      }

      p.toggleClass("activeItem");
    } else {
      // delete target 
      //        cleanupRelatedList(true);
      $(`${relatedPanel} span, ${relatedPanel} span`).filter('.relatedItem').each(function () {
        $(this).removeClass("relatedItem");
      });
    }
  } else {
    /*
      in case to turn p to 'ACTIVE'
    */
    let related_table = "";
    let related_api = "";

    if (c.indexOf("table") != -1) {
      related_table = t;
      // get&show table columns
      getColumn(t);
    } else {
      /*
        Tips:
          only one can be selected in API list
      */
      $(`${APICONTAINER} span`).filter(".relatedItem, .activeItem, .activeandrelatedItem").each(function () {
        if (t != $(this).text()) {
          if ($(this).hasClass("activeandrelatedItem")) {
            $(this).addClass("relatedItem");
          }

          $(this).removeClass("activeItem activeandrelatedItem");
          $(`${TABLECONTAINER} span`).removeClass("relatedItem");
        }
      });

      // reset all activeItem class and sql
      cleanupContainers("api");

      // showing ordered sql from preferent.apilist that is gotten by getAjaxData("/getapilist",...)
      if (preferent.apilist != null && preferent.apilist.length != 0) {
        let s = getdataFromJson(preferent.apilist, t);
        if (0 < s.sql.length) {
          $(`${COLUMNSPANEL} span`).filter(".apisql").remove();
          related_api = s.apino;
          // api in/out json
          $(`${COLUMNSPANEL} .item_area`).append(`<span class="apisql apiin"><bold>IN:</bold><div name="apiin" >${setApiIF_In(t, s)}</div></span>`);
          $(`${COLUMNSPANEL} .item_area`).append(`<span class="apisql apiout"><bold>OUT:</bold><div name="apiout" style="height:100px;" class="right_left_panel_scroll">${setApiIF_Out(t, s)}</div></span>`);
          // sample execution sql
          $(CONTAINERPANEL).append(`<span class="apisql"><p>${setApiIF_Sql(s)}</p></span>`);
        }
      }
    }

    let data = `{"table":"${related_table}","api":"${related_api}"}`;
    postAjaxData(scenario["function-post-url"][8], data);

    if (p.hasClass("relatedItem")) {
      p.addClass("activeandrelatedItem");
    } else {
      p.toggleClass("activeItem");
    }
  }

  // set the panel title
  let label2columns = "";
  $(`${TABLECONTAINER} span, ${APICONTAINER} span`).filter('.activeItem, .activeandrelatedItem').each(function () {
    let tn = $(this).text();
    if (label2columns.length == 0) {
      label2columns = tn;
    } else {
      label2columns += " & " + tn;
    }
  });

  if (0 < label2columns.length) {
    if (sourcePanel == TABLECONTAINER) {
      label2columns = `Registered columns in ${label2columns}`;
    } else {
      label2columns = `IN/OUT interface of ${label2columns}`;
    }
  }

  $("#columns_title").text(label2columns);
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

  /*
    Tips:
      for api test, each json parameter's name are contained in this array.
      pushing is executed in buildJetelinaJsonForm() mostly, except somes e.g. case in redis
  */
  preferent.apitestparams = [];

  if (ta.startsWith("js")) {
    //select. 'ignore' -> no sub query
    if (s.subquery != null && 0 < s.subquery.length && s.subquery != IGNORE) {
      let s_subquery = s.subquery;
      let subquery_str = "";
      let isCurry = s_subquery.indexOf('{');
      while (-1 < isCurry) {
        if(0<subquery_str.length){
          subquery_str += ',';
        }

        let sp = s_subquery.indexOf('{');
        let ep = s_subquery.indexOf('}');
        if (sp != -1 && ep != -1) {
          let cd = s_subquery.substring(sp + 1, ep);
          subquery_str += `'${cd}': `;
          if (s_subquery[sp - 1] == "\'") {
            subquery_str += `'{${cd}}'`;
          } else {
            subquery_str += `{${cd}}`;
          }

          preferent.apitestparams.push(cd);
          s_subquery = s_subquery.substring(ep + 1, s_subquery.length);
        }

        isCurry = s_subquery.indexOf('{');
      }

      ret = `{"apino": \"${t}\","subquery":\"[${subquery_str}]\"}`;
    } else {
      ret = `{"apino":\"${t}\"}`;
    }
  } else if (ta.startsWith("ji")) {
    if (loginuser.dbtype != "redis") {
      /*
        insert
          a,b,... in insert into table values(a,b,...) 
      */
      let i_sql = s.sql.split("values(");
      i_sql[1] = i_sql[1].slice(0, i_sql[1].length - 1).replaceAll('\'', '').replaceAll('{', '').replaceAll('}', '');
      ret = buildJetelinaJsonForm(ta, i_sql[1]);
    } else {
      let i_sql = s.sql.split(":");
      ret = `{"apino":\"${t}\","key1":"{your key data}","key2":"{your value data}"}`;
      preferent.apitestparams.push("your key data");
      preferent.apitestparams.push("your value data");
    }
  } else if (ta.startsWith("ju") || ta.startsWith("jd")) {
    if (loginuser.dbtype != "redis") {
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
      preferent.apitestparams.push("jt_id");
      ret = ret.slice(0, ret.length - 1) + `,\"subquery\":\"{jt_id}\"` + ret.slice(ret.length - 1, ret.length);
    } else {
      let u_sql = s.sql.split(":");
      ret = `{"apino":\"${t}\","key":"{your value data}"}`;
      preferent.apitestparams.push("your value data");
    }
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
    if (loginuser.dbtype != "redis") {
      let pb = s.sql.split("select");
      let pf = pb[1].split("from");
      // there is the items in pf[0]
      if (pf[0] != null && 0 < pf[0].length) {
        ret = buildJetelinaOutJsonForm(ta, pf[0]);
      }
    } else {
      let pb = s.sql.split(":");
      if (pb[1] != null && 0 < pb[1].length) {
        ret = `{"result":true or false,"Jetelina":"[{\"${pb[1]}\":\"{${pb[1]}}\"}]","message from Jetelina":"\".....\""}`;
      }
    }
  } else {
    // insert, update, delete
    ret = '{"result":true or false,"Jetelina":"[{}]","message from Jetelina":"\".....\""}';
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

  if (loginuser.dbtype != "redis") {
    // possibly s.subquery is null. 'ignore' -> no sub query
    if (s.subquery != null && s.subquery != IGNORE) {
      ret = `${s.sql} ${s.subquery};`;
    } else {
      ret = `${s.sql};`;
    }

    let reject_jetelina_delete_flg = "jetelina_delete_flg";
    if (ret.startsWith("insert")) {
      ret = ret.replaceAll(`,{${reject_jetelina_delete_flg}}`, '').replaceAll(`,${reject_jetelina_delete_flg}`, '');
    }
  } else {
    let d = s.sql.split(":");
    if (s.apino.startsWith("ji")) {
      ret = `${d[0]} {your key data} {your value data}`;
    } else if (s.apino.startsWith("ju")) {
      ret = `${d[0]} ${d[1]} {your value data}`;
    } else if (s.apino.startsWith("js")) {
      ret = `${d[0]} ${d[1]}`;
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
      ss = $.trim(ss);
      preferent.apitestparams.push(ss);
      ret = `${ret}\"${ss}\":\"{${ss}}\",`;
      //      ret = `${ret}\"${$.trim(ss)}\":\"{${$.trim(ss)}}\",`;
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
    ret = `${ret}]","message from Jetelina":"\".....\""}`; // caution: the last '}' is necessary
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
      if (checkResult(result)) {
        // got to data parse
        return getdata(result, 1);
      } else {
        typingControll(chooseMsg('fail-msg', "", ""));
      }
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
  $(`${COLUMNSPANEL} .item, ${CONTAINERPANEL} .item`).not('.selectedItem').remove(`:contains(${p}_)`);
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

  if (loginuser.sw == null || loginuser.sw == "") {
    pd["pass"] = $(SOMETHINGINPUT).val();
  } else {
    pd["pass"] = loginuser.sw;
  }

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
    let m = "";
    if (checkResult(result)) {
//      for (let i = 0; i < tables.length; i++) {
//        $(`${TABLECONTAINER} span`).filter(function () {
//          if ($(this).text() === tables[i]) {
            cleanUp("items");
            //$(this).remove();
            //removeColumn(tables[i]);
            //cleanupContainers();
//            return;
//          }
//        });
//      }

      // 'pass' is authorized by Jetelina
      loginuser.sw = pd["pass"];
      showSomethingInputField(false);
      showSomethingMsgPanel(false);
      showGenelicPanel(false);
      rejectCancelableCmdList(TABLEAPIDELETE);
      preferent.cmd = "";
      refreshApiList();
      refreshTableList();
      m = chooseMsg('refreshing-msg', '', '');
    } else {
      m = result["message from Jetelina"];
      if (m == null || m == "") {
        m = chooseMsg('fail-msg', '', '');
      }
      // try again
      //$(SOMETHINGINPUT).focus();
    }

    typingControll(m);
  }).fail(function (result) {
    checkResult(result);
    console.error("dropThisTable() faild: ", result);
    typingControll(chooseMsg('fail-msg', "", ""));
  }).always(function () {
    // release it for allowing to input new command in the chatbox 
    inprogress = false;
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
    'where' is mandatory <- ??? yet?
  */
  let subq = $.trim($(GENELICPANELINPUT).val()).replace(/\r?\n/g,'');
  if(subq == "" || subq == "where"){
    subq = IGNORE;
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
    let m = "";
    $(".newapino").remove();

    if (checkResult(result)) {
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

          selectedItemsArr = [];
          rejectCancelableCmdList(SELECTITEM);
          cleanUp("items");
//          $(CONTAINERPANEL).append(`<span class="newapino"><p>api no is ${result.apino}</p></span>`);
          refreshApiList();
          refreshTableList();
          m = chooseMsg('refreshing-msg', '', '');    
        }

        if (isVisibleGenelicPanel()) {
          $(GENELICPANEL).hide();
        }

        m = `new api no is ${result.apino}`;
        $(CHATBOXYOURTELL).text(m);
        $(".yourText").mouseover();
      } else {
        /* API test mode */
        getdata(result, 4);
        if (!isVisibleApiTestPanel()) {
          $(`${APITESTPANEL} span`).remove();
          showApiTestPanel(true);
          let testmsg = "<span class='jetelina_suggestion'><p>Oh oh, no data. Try again with other params</p></span>";
          $(`${APITESTPANEL} [name='api-test-msg']`).append(`${testmsg}`);
        }

        m = chooseMsg('success-msg','','');
      }

    } else {
      m = chooseMsg('fail-msg','','');
      if (result.resembled != null && 0 < result.resembled.length) {
//        $(CONTAINERPANEL).append(`<span class="newapino"><p>there is similar API already exist:  ${result.resembled}</p></span>`);
        m = `there is a similar API already existing:  ${result.resembled}`;
      }
    }

    typingControll(m);
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
    }

    rejectCancelableCmdList("post");
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
  let usedb = "";// database name for switching
  let complementflg = false;// turn to 'true' if got compliment words

  /*
    if (inCancelableCmdList(["apitest"])) {
      let p = `{${preferent.apitestparams[preferent.apiparams_count]}}`;
      let inp = $(`${COLUMNSPANEL} [name='apiin']`).text();
      let reps = inp.replace(p, original_chatbox_input_text);
      $(`${COLUMNSPANEL} [name='apiin']`).addClass("attentionapiinout").text(reps);
      cmd = "apitest";
    }
  */
  if (inScenarioChk(ut, 'common-execute-again-cmd')) {
    if (0 < cancelableCmdList.length) {
      cmd = cancelableCmdList[0];
      if (inCancelableCmdList(["apitest"])) {
        preferent.apiparams_count = 0;
        $(`${COLUMNSPANEL} [name='apiin']`).removeClass("attentionapiinout");
        $(`${COLUMNSPANEL} [name='apiin']`).text(preferent.original_apiin_str);
      }
    }
  }

  if(inScenarioChk(ut, 'func-subpanel-focus-cmd')){
    if(isVisibleGenelicPanel()){
      let subq = $(GENELICPANELINPUT).val();
      let p = subq.length;
//      $(GENELICPANELINPUT).val('');
      $(GENELICPANELINPUT).focus().get(0).setSelectionRange(p,p)
//      $(GENELICPANELINPUT).val(subq);
    }

    if(containsMultiTables()){
      m = chooseMsg('func-postcolumn-where-indispensable-msg', "", "");
    }else{
      m = chooseMsg('func-postcolumn-where-option-msg', "", "");
    }
  }

  if (1 < cmdCandidates.length) {
    cmd = whichCommandsInOrders(ut);
  } else {
    /*
      Tips:
        because of scenario[], it has a chance duplicate commands.
        cmdCandidates is for judging, and the belows 'if' sentences are to find
        this duplicated commands.
        it is not good as 'if{}else if{}else....', here shoud be 'if{} if{}...'
    */
    if (inScenarioChk(ut, 'common-cancel-cmd') || inScenarioChk(ut, 'func-selecteditem-cancel-cmd')) {
      cmd = 'cancel';
      preferent.cmd = "";
      cmdCandidates.push("cancel");
    }

    if (cmd == "" && inScenarioChk(ut, 'func-cleanup-cmd')) {
      cmd = 'cleanup';
      cmdCandidates.push("clean up");
    }

    if (cmd == "" && $(UPFILE).val() != "" && inScenarioChk(ut, 'func-fileupload-cmd')) {
      cmd = 'fileupload';
      cmdCandidates.push("file upload");
    }

    if (cmd == "" && inScenarioChk(ut, 'func-show-table-list-cmd')) {
      cmd = TABLEAPILISTOPEN;
      cmdCandidates.push("show table list");
    } else if (cmd == "" && inScenarioChk(ut, 'func-show-api-list-cmd')) {
      cmd = TABLEAPILISTOPEN;
      cmdCandidates.push("show api list");
    } else if (cmd == "" && inScenarioChk(ut, 'func-fileupload-open-cmd')) {
      cmd = FILESELECTOROPEN;
      cmdCandidates.push("file open");
    } else if (inScenarioChk(ut, 'func-table-api-open-close-cmd')) {
      rejectCancelableCmdList(cmd);
      cmd = SELECTITEM;
      cmdCandidates.push("open or close table/api");
    } else if (cmd == "" && inScenarioChk(ut, 'func-item-select-cmd')) {
      cmd = SELECTITEM;
      cmdCandidates.push("select columns");
    } else if (cmd == "" && inScenarioChk(ut, "func-item-select-all-cmd")) {
      cmd = SELECTITEM;
      cmdCandidates.push("select columns all");
    } else if (cmd == "" && inScenarioChk(ut, 'func-subpanel-open-cmd')) {
      cmd = "subquery";
      cmdCandidates.push("open sub query panel");
    }

    if (cmd == "" && inScenarioChk(ut, 'func-tabledrop-cmd')) {
      cmd = TABLEAPIDELETE;
      preferent.cmd = cmd;
      cmdCandidates.push("drop table");
    } else if (cmd == "" && inScenarioChk(ut, 'func-apidelete-cmd')) {
      cmd = TABLEAPIDELETE;
      preferent.cmd = cmd;
      cmdCandidates.push("delete api");
    }

    // db switching
    if (cmd == "" && inScenarioChk(ut, 'func-db-switch-cmd')) {
      cmd = "switchdb";
      usedb = "";
    } else if (cmd == "" && inScenarioChk(ut, 'func-use-postgresql-cmd')) {
      cmd = "switchdb";
      usedb = "postgresql";
    } else if (cmd == "" && inScenarioChk(ut, 'func-use-mysql-cmd')) {
      cmd = "switchdb";
      usedb = "mysql";
    } else if (cmd == "" && inScenarioChk(ut, 'func-use-redis-cmd')) {
      cmd = "switchdb";
      usedb = "redis";
    } else if (cmd == "" && $.inArray("switchdb", cmdCandidates) != -1) {
      cmd = "switchdb";
    }

    if (cmd == "" && inScenarioChk(ut, 'common-post-cmd') ||
      (cmd == "" && inScenarioChk(ut, 'func-apicreate-cmd'))) {
      cmd = 'post';
      //cmdCandidates.push("post");
      cancelableCmdList.push("post");
    }

    if (cmd == "" && !isSelectedItem() && inScenarioChk(ut, 'func-api-test-cmd')) {
      cmd = "apitest";
      cancelableCmdList.push("apitest");
    }

    if (cmd == "" && isSelectedItem() && inScenarioChk(ut, 'func-api-test-cmd')) {
      cmd = "preapitest";
      cancelableCmdList.push("preapitest");
    }

    if (cmd.length == 0) {
      cmd = getPreferentPropertie('cmd');
      if (cmd.length == 0) {
        cmd = ut;
      }
    }

    // show/hide command, maybe
    if (inScenarioChk(ut, 'func-api-test-panel-show-cmd')) {
      showApiTestPanel(true);
    } else if (inScenarioChk(ut, 'func-api-test-panel-hide-cmd')) {
      showApiTestPanel(false);
    } else if (inScenarioChk(ut, 'func-subpanel-close-cmd')) {
      showGenelicPanel(false);
    }

    // greeting for something execution
    if(inScenarioChk(ut,'general-thanks-cmd')||inScenarioChk(ut,'general-complement-cmd')){
      if(inCancelableCmdList(["apitest","preapitest"])){
        complementflg = true;
        cmd = "cancel";
      }else{
        showSomethingMsgPanel(false);
      }
    }
  }

  if (-1 < $.inArray(cmd, [TABLEAPILISTOPEN, FILESELECTOROPEN])) {
    getAjaxData(scenario["function-get-url"][4]);
    openFunctionPanel();    
  } else {
    // nothing happens without opening function panel :P
  }
  /*
    Tips:
      this is a precautionary logic.
      in the case of duplicating commands in scenario[], Jetelina asks you which is right.
      the user request is postponed until the command is be clear with reserving it as preferent.ut.
      that's why 'cmd' is be unset, then 'switch' goes to 'default', but it does not have any process. 👍
  */
  if (1 < cmdCandidates.length) {
    if (preferent.ut == null || preferent.ut == "") {
      preferent.ut = ut;
    }

    cmd = "";
    let mm = "";
    for (let i = 0; i < cmdCandidates.length; i++) {
      mm += "'" + cmdCandidates[i] + "',";
    }

    m = chooseMsg('common-comand-duplicated-msg', mm, "");
  }
  /*
    Tips:
      clean up some parameters after defining 'cmd'.
  */
  if (0 < cmd.length) {
    cmdCandidates = [];
    if (preferent.ut != null && 0 < preferent.ut.length) {
      ut = preferent.ut;
      preferent.ut = "";
    }

    if (cmd == "" && inScenarioChk(ut, 'common-execute-again-cmd')) {
      cmd = cancelableCmdList[0];
    }

    if (cmd != "cancel" && inCancelableCmdList(["apitest"])) {
      let p = `{${preferent.apitestparams[preferent.apiparams_count]}}`;
      let inp = $(`${COLUMNSPANEL} [name='apiin']`).text();
      let reps = inp.replace(p, original_chatbox_input_text);
      $(`${COLUMNSPANEL} [name='apiin']`).addClass("attentionapiinout").text(reps);
      cmd = "apitest";
    }
/*
    if ($.inArray(cmd, ["apitest", "preapitest"]) == -1 && inCancelableCmdList(["apitest", "preapitest"])) {
      rejectCancelableCmdList("apitest");
      rejectCancelableCmdList("preapitest");
      preferent.apiparams_count = null;
    }*/
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
        8.cleanup: cleanup column/selecteditem field
        9.subquery: open subquery panel
        10.preapitest: api test before registring
        11.apitest: exist api test mode
        12.switchdb: switchng using database
        default: non
  */
  switch (cmd) {
    case FILESELECTOROPEN://open file selector
      $(UPFILE).click();
      m = chooseMsg('func-fileupload-open-msg', "", "");
      break;
    case 'fileupload'://csv file upload
      const f = $(UPFILE).prop("files");
      if (f != null && 0 < f.length) {
        delete preferent.apilist;
        fileupload();
        m = chooseMsg('inprogress-msg', '', '');
      } else {
        m = chooseMsg('func-fileupload-msg', "", "");
      }

      break;
    case TABLEAPILISTOPEN:
      // show database list
      setLeftPanelTitle();
      isVisibleDatabaseList(true);
      // these defaults are for table list
      let hidepanel = APICONTAINER;
      let showpanel = TABLECONTAINER;
      let geturl = scenario["function-get-url"][1];

      // cleanup the screen first 
      cleanupItems4Switching();
      cleanupContainers();

      if (inScenarioChk(ut, 'func-show-table-list-cmd')) {
        showApiTestPanel(false);
        cleanUp('tables');
      } else if (inScenarioChk(ut, 'func-show-api-list-cmd')) {
        hidepanel = TABLECONTAINER;
        showpanel = APICONTAINER;
        $(GENELICPANEL).hide();
        geturl = scenario["function-get-url"][0];
      }

      delete preferent.apilist;

      cleanupRelatedList(false);
      displayTablesAndApis();

      m = IGNORE;
      break;
    case SELECTITEM:
      let findflg = false;
      let t = ut.split(' ');

      // for opening table 
      $(CONTAINERNEWAPINO).remove();
      /*
        Attention:
          if statement exectution is 'all' + 'close'
            -> in the case of 'ut' is 'close all', 'all close'
      */
      if (($.inArray('all', t) != -1) && ($.inArray('close', t) != -1)) {
        $("#table_container span, #api_container span").filter(".relatedItem, .activeItem, .activeandrelatedItem").each(function () {
          if ($(this).hasClass("relatedItem")) {
            $(this).removeClass("relatedItem");
          }
          if ($(this).hasClass("activeItem")) {
            $(this).removeClass("activeItem");
          }
          if ($(this).hasClass("activeandrelatedItem")) {
            $(this).removeClass("activeandrelatedItem");
          }

          showGenelicPanel(false);
          cleanUp("items");
          let n = $(this).text();
          if (relatedDataList[n] != null) {
            delete relatedDataList[n];
          }
        });
      }

      for (let n = 0; n < t.length; n++) {
        /*
          Tips:
            at the first, searching in the table list, then the api list if did not hit.
            respect table seaching if there were a word 'table' in 'ut'.

            because... may the name of table has variety, against it the name of api has a rule.
            if there were the same name in the both list, this selection hit both, but puting 'table' in the order,
            it could be limited in the table list.
            and wanna execute vargue hitting in the api list.
            i mean
              'js100' is in the both table and api list. yes rare case. :)
                  case 1. order 'open js100' hit the both.
                  case 2. order 'open table js100' hit the only table.
                  case 3. order 'open 100' hit the only api.
        */
        $(`${TABLECONTAINER} span`).each(function (i, v) {
          if (v.textContent == t[n]) {
            listClick($(this));
            m = chooseMsg('success-msg', "", "");
            findflg = true;
          }
        });

//        if (ut.indexOf("table") == -1) {
        if(!findflg){      
          $(`${APICONTAINER} span`).each(function (i, v) {
            if (v.textContent.indexOf(t[n]) != -1) {
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
          $(`${COLUMNSPANEL} span`).filter(".item").each(function () {
            itemSelect($(this));
          });
        } else {
          // ordered item
          for (let n = 0; n < t.length; n++) {
            $(`${COLUMNSPANEL} span`).filter(".item").each(function (i, v) {
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
        /*
          Tips:
            get 'pass phrase' confirmation here.
            continue the process if ..sw is not null, ask it if it is not in loginuser.sw. 
            the matching the 'pass phrase' is done in Jetelina.
        */
        if ((loginuser.sw == null || loginuser.sw == "") && (!$(SOMETHINGINPUT).is(":visible"))) {
          showSomethingMsgPanel(true);
          if (loginuser.available) {
            showSomethingInputField(true, 2);
            m = chooseMsg('func-require-stichwort-msg', '', '');
          } else {
            showSomethingInputField(true, 1);
            m = chooseMsg('func-register-stichwort-msg', '', '');
          }
        } else {
          /* execute drop table and/or delete api,
             but 'pass phrase' is must item. 
          */
          if (($(SOMETHINGINPUT).is(":visible") && 0 < $(SOMETHINGINPUT).val().length) || (loginuser.sw != null && 0 < loginuser.sw.length)) {
            let droptables = [];
            $(`${TABLECONTAINER} span`).filter('.deleteItem').each(function () {
              droptables.push($(this).text());
            });

            if (0 < droptables.length) {
              dropThisTable(droptables);
            }
            let deleteapis = [];
            $(`${APICONTAINER} span`).filter('.deleteItem').each(function () {
              deleteapis.push($(this).text());
            });

            if (0 < deleteapis.length) {
              deleteThisApi(deleteapis);
            }
          }

          m = IGNORE;
        }
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
        for (let n = 0; n < utarray.length; n++) {
          $(`${TABLECONTAINER} span`).each(function (i, v) {
            if (v.textContent == utarray[n]) {
              $(this).addClass("deleteItem");
              m = chooseMsg("common-confirm-msg", "", "");
            }
          });

          let jijujdexist = false;
          $(`${APICONTAINER} span`).each(function (i, v) {
            if (v.textContent.indexOf(utarray[n]) != -1) {
              if (v.textContent.startsWith('js')) {
                $(this).addClass("deleteItem");
                m = chooseMsg("common-confirm-msg", "", "");
              } else if (v.textContent.startsWith('ji') || v.textContent.startsWith('ju') || v.textContent.startsWith('jd')) {
                jijujdexist = true;
              }
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
      showApiTestPanel(false);
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
//            showGenelicPanel(true);
            if(subquerysentence != "" && subquerysentence != IGNORE){
              if (checkGenelicInput(subquerysentence)) {
                postSelectedColumns("");
                m = IGNORE;
              }    
            }else{
              m = chooseMsg('func-postcolumn-where-indispensable-msg', "", "");
            }
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
//          if (inScenarioChk(ut, 'confirmation-sentences-cmd')) {
//            showGenelicPanel(true);
//            m = chooseMsg('func-subpanel-opened-msg', "", "");
//          } else {
 //           $(GENELICPANELINPUT).val(IGNORE);
 //         }

          if(!containsMultiTables()){
            if (subquerysentence == "") {
//              $(GENELICPANELINPUT).val(IGNORE);
              m = chooseMsg('func-postcolumn-available-msg', "", "");
            }
          }
          // use $(..).val() because this may was set 'ignore' just above.
          //if ($(GENELICPANELINPUT).val() != "") {
            m = chooseMsg('func-postcolumn-available-msg', "", "");
          //}

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
          also it may happen in file up loading, oh my.. in apitest as well.
  
          Attention:
            in the case of cancel 'drop table' and 'delete api' are be canceld every selected tables and apis.
            in the case of cancel 'itme(column)' is able to be canceled selectively: each 'cancel <column name>'.
      */
      // cancel table drop and/or api delete
      if (inCancelableCmdList([TABLEAPIDELETE])) {
        showApiTestPanel(false);
        // cleanup the screen
        cleanupItems4Switching();
        cleanupContainers();
        showSomethingInputField(false);
        showSomethingMsgPanel(false);
        rejectCancelableCmdList(TABLEAPIDELETE);
        m = chooseMsg('cancel-msg', "", "");
        //        } else {
        // table list
        if (deleteSelectedItems()) {
          showGenelicPanel(false);
          rejectCancelableCmdList(TABLEAPIDELETE);
          m = chooseMsg('cancel-msg', "", "");
        } else {
          m = chooseMsg('unknown-msg', "", "");
        }
        //        }

        $(`${TABLECONTAINER} span`).removeClass('deleteItem');
        $(`${APICONTAINER} span`).removeClass('deleteItem');
      } else if (inCancelableCmdList([FILESELECTOROPEN])) {
        $(UPFILE).val("");
        $(`${MYFORM} label span`).text("Upload CSV File");
        $(FILEUP).removeClass("genelic_panel");
        rejectCancelableCmdList(FILESELECTOROPEN);
        m = chooseMsg("cancel-msg", "", "");
      } else if (inCancelableCmdList([SELECTITEM])) {
        let t = ut.split(' ');
        // cancel selected columns
        if (inScenarioChk(ut, "func-selecteditem-all-cancel-cmd")) {
          // cancel all items
          $(`${CONTAINERPANEL} span`).filter(".selectedItem").each(function (i, v) {
            itemSelect($(this));
          });

          if (isVisibleGenelicPanel()) {
            showGenelicPanel(false);
          }

          selectedItemsArr = [];
          m = chooseMsg('cancel-msg', "", "");
        } else {
          // cancel each item
          $(`${CONTAINERPANEL} span`).filter(".selectedItem").each(function (i, v) {
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

      } else if (inCancelableCmdList(["apitest", "preapitest"])) {
        rejectCancelableCmdList("apitest");
        rejectCancelableCmdList("preapitest");
        $(`${COLUMNSPANEL} [name='apiin']`).removeClass("attentionapiinout").text(preferent.original_apiin_str);
        $(`${COLUMNSPANEL} [name='apiout']`).removeClass("attentionapiinout").text(preferent.original_apiout_str);
        if(complementflg){
          m = chooseMsg('general-thanks-msg', loginuser.lastname, "c");
        }else{
          m = chooseMsg('cancel-msg', '', '');
        }

        preferent.apiparams_count = null;
      }

      break;
    case 'cleanup': //clean up the panels
      cleanupItems4Switching();
      deleteSelectedItems();
      cleanupContainers();
      refreshApiList();
      refreshTableList();
      m = chooseMsg('refreshing-msg', '', '');
      break;
    case 'subquery': //open subquery panel
      // if api test result panel is openend yet
      //      if (isVisibleApiContainer()) {
      showApiTestPanel(false);
      //      }

      showGenelicPanel(true);
      m = chooseMsg('func-subpanel-opened-msg', '', '');
      break;
    case 'preapitest':
      if (0 < selectedItemsArr.length) {
        // API test mode before registering
        // before hitting this command, should desplay 'func-api-test-msg' in anywhere.
        if (checkGenelicInput($(GENELICPANELINPUT).val())) {
          postSelectedColumns("pre");
        } else {
          m = chooseMsg('func-api-test-subquery-chk-error-msg', '', '');
        }
      }
      break;
    case 'apitest':
      /*
        Tips:
          API 'IN' parameters are already collected in buildJetelinaJsonForm() as preferent.apitestparams.
          ust this for setting each ones in chatting.
      */
      if (preferent.original_apiin_str == null || preferent.original_apiin_str == "") {
        preferent.original_apiin_str = $(`${COLUMNSPANEL} [name='apiin']`).text();
      }

      if (preferent.original_apiout_str == null || preferent.original_apiout_str == "") {
        preferent.original_apiout_str = $(`${COLUMNSPANEL} [name='apiout']`).text();
      }

      if (inScenarioChk(ut, 'common-execute-again-cmd')) {
        preferent.apiparams_count = 0;
      }

      if (preferent.apitestparams != null && 0 < preferent.apitestparams.length) {
        if (preferent.apiparams_count == null) {
          preferent.apiparams_count = 0;
        } else {
          preferent.apiparams_count += 1;
        }

        if (preferent.apiparams_count < preferent.apitestparams.length) {
          m = `set '${preferent.apitestparams[preferent.apiparams_count]}'`;
        } else if (inScenarioChk(ut, 'func-api-test-execute-cmd')) {
          apiTestAjax();
          m = chooseMsg('inprogress-msg', '', '');
        } else {
          let e = chooseMsg('func-api-test-execute-cmd', '', '');
          m = chooseMsg('func-api-test-ready-msg', e, 'r');
        }
      } else {
        if (inScenarioChk(ut, 'func-api-test-execute-cmd')) {
          apiTestAjax();
          m = chooseMsg('inprogress-msg', '', '');
        } else {
          let e = chooseMsg('func-api-test-execute-cmd', '', '');
          m = chooseMsg('func-api-test-ready-no-param-msg', e, 'r');
        }
      }

      break;
    case 'switchdb':
      if (inScenarioChk(ut, 'confirmation-sentences-cmd') && preferent.db != null && preferent.db != "") {
        //post
        setDBFocus(preferent.db);
        loginuser.dbtype = preferent.db;
        setLeftPanelTitle();
        tidyupcmdCandidates(cmd);
        deleteSelectedItems();
        cleanupItems4Switching();
        cleanupContainers();
        cancelableCmdList = [];

        // clean up the parameters for api test
        preferent.apitestparams = [];
        preferent.apiparams_count = null;
        preferent.original_apiin_str = "";
        preferent.original_apiout_str = "";

        let data = `{"param":"${preferent.db}"}`;
        postAjaxData(scenario['function-post-url'][9], data);
      } else {
        if (usedb != "") {
          preferent.db = usedb;
          if($(`#databaselist span[name='${usedb}']`).is(":visible")){
            // switch to usedb
            m = chooseMsg('func-determine-db-msg', preferent.db, 'r');
          }else{
            // start to use this db, but
            if(loginuser.roll == "admin"){
              // only admin can change the availability of this db

              let data = `{"db":"${preferent.db}"}`;
              postAjaxData(scenario["function-post-url"][10], data);
            }else{
              // display a message 'lack of roll'
              m = chooseMsg('no-authority-js-msg','','');
            }
          }
        } else {
          // display a message for changing database
          m = chooseMsg('func-select-db-msg', '', '');
        }

        cmdCandidates.push(cmd);
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
    /*
      in the case of showing table list, this field is for expecting 'Sub Query'
    */
    $(GENELICPANELTEXT).text("Sub Query:");
    $(GENELICPANELINPUT).val("where ");
//    $(GENELICPANELINPUT).attr('placeholder', 'where .....');

    $(GENELICPANEL).show();
//    $(GENELICPANELINPUT).focus();
  } else {
    $(GENELICPANEL).hide();
    $(GENELICPANELINPUT).val("");
    focusonJetelinaPanel();
  }
}
/**
 * @function checkGenelicInput
 * @param {string} ss  sub query sentence strings 
 * @returns {boolean}  true->acceptable  false->something suspect
 * 
 * check sub query sentence. 'ignore' is always acceptable.
 */
const checkGenelicInput = (ss) => {
  let ret = true;
  let s = $.trim(ss);

  if( s == "where" || s == "" ){
    s = IGNORE;
//    $(GENELICPANELINPUT).val(s);
  }

  if (s != IGNORE) {
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
    let arr = [];
    //    $(`${CONTAINERPANEL} span`).filter(".selectedItem").each(function () {
    $(`${COLUMNSPANEL} span, ${CONTAINERPANEL} span`).filter('.item').each(function () {
      arr.push($(this).text());
    });

    // 1st: "" -> '' because sql does not accept ""
    let unacceptablemarks = ["\"","`"];
    for( let i in unacceptablemarks){
      s = s.replaceAll(unacceptablemarks[i],"'");      
    }
//    let sq = s.replaceAll("\"", "'");
    // 2nd: reject unexpected words
    let unexpectedwords = ["delete", "drop", ";"];
    for (i in unexpectedwords) {
      s = s.replaceAll(unexpectedwords[i], "");
    }
    // 3nd: items in the subquery sentence are in the open items list
    /*
      Tips:
        open items are rejected from 'sq', then the remains will be a string except items.
        i mean
            where ftest.ftest_name='AAA' -> where ='AAA'
            where ftest.ftest_name=ftest2.ftest2_name  -> where =
            where ftest.ftest_ave<0.2  -> where <0.2

        but this logic is postponed because of incomplete on sep/2024
    */
   /*
    let pp = s;
    for (i in arr) {
      let p = pp.indexOf(arr[i]);
      if (0 < p) {
        pp = pp.substring(0, p) + pp.substring(p + arr[i].length, pp.length);
      }
    }

    if (0 < pp.length) {
      // ここが問題。最後のチェックで関係ないtableがまだsubqueryにないかどうかを見たいが"."だけだと小数点数字もアリなので困る
      if (pp.indexOf('.') != -1) {
        $(GENELICPANELINPUT).focus();
        ret = false;
      }
    } else {
      ret = false;
    }
  */
    if (ret) {
      $(GENELICPANELINPUT).val(s);
    }
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

  if (loginuser.sw == null || loginuser.sw == "") {
    pd["pass"] = $(SOMETHINGINPUT).val();
  } else {
    pd["pass"] = loginuser.sw;
  }

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
    let m = "";
    if (checkResult(result)) {
//      for (let i = 0; i < apis.length; i++) {
//        $(`${APICONTAINER} span`).each(function () {
//          if ($(this).text() === apis[i]) {
//            if($(this).hasClass("activeItem") || $(this).hasClass("activeandrelatedItem")){
              cleanUp("items");
//              for(let n in relatedDataList[apis[i]]){
//                $(`${TABLECONTAINER} span`).filter(".relatedItem").each(function () {
//                  if($(this).text() == relatedDataList[apis[i]][n]){
//                    $(this).removeClass("relatedItem");
//                  }
//                });
//              }
//            }
//            $(this).remove();
//            removeColumn(apis[i]);
//            cleanupContainers();
//            return;
//          }
//        });
//      }

      // 'pass' is authorized by Jetelina
      loginuser.sw = pd["pass"];
      showSomethingInputField(false);
      showSomethingMsgPanel(false);
      showGenelicPanel(false);
      rejectCancelableCmdList(TABLEAPIDELETE);
      preferent.cmd = "";
      refreshApiList();
      refreshTableList();
      m = chooseMsg('refreshing-msg', '', '');
    } else {
      m = result["message from Jetelina"];
      if (m == null || m == "") {
        m = chooseMsg('fail-msg', '', '');
      }
      // try again
      //$(SOMETHINGINPUT).focus();
    }

    typingControll(m);
  }).fail(function (result) {
    checkResult(result);
    console.error("deleteThisApi() faild: ", result);
    typingControll(chooseMsg('fail-msg', "", ""));
  }).always(function () {
    // release it for allowing to input new command in the chatbox 
    inprogress = false;
  });
}
/**
 * @function whichCommandsInOrders
 * @param {string} s user typing string
 * @return {string} command string
 * 
 * match with user input in cmdCandidates
 */
const whichCommandsInOrders = (s) => {
  let c = "";
  for (key in cmdCandidates) {
    if (s == cmdCandidates[key]) {
      switch (s) {
        case 'cancel': c = "cancel"; break;
        case "clean up": c = "cleanup"; break;
        case "file upload": c = "fileupload"; break;
        case "show table list", "show api list": c = TABLEAPILISTOPEN; break;
        case "file open": c = FILESELECTOROPEN; break;
        case "open or close table/api": case "select columns": case "select columns all": c = SELECTITEM; break;
        case "open sub query panel": c = subquery; break;
        case "drop table": case "delete api": c = TABLEAPIDELETE; break;
        case "post": c = "post"; break;
        case "preapitest": c = "preapitest"; break;
        case "apitest": c = "apitest"; break;
        case "switchdb": c = "switchdb"; break;
        default:
          break;
      }

      cmdCandidates = [];
      return c;
    }
  }

  return c;
}
/**
 * @function cleanupRelatedList
 * 
 * clear screen in api_container panel and/or relatedDataList object
 *
 * @param {boolean} b  false -> clear the list, true-> delete relatedDataList as well
 */
const cleanupRelatedList = (b) => {
  //  $("#api_container span").remove();
  if (b) {
    for (let i in relatedDataList) {
      delete relatedDataList[i];
    }
  }
}
/**
 * @function displayTablesAndApis
 * 
 * display table list and api list
 * 
 */
const displayTablesAndApis = () => {
  refreshApiList();
  refreshTableList();
}
/**
 * @function refreshApiList
 * 
 * refresh displaying of api list
 */
const refreshApiList = () => {
  cleanUp("apis");
  if (preferent.apilist != null) {
    delete preferent.apilist
  }

  $("#right_panel").addClass("genelic_panel");
  getAjaxData(scenario["function-get-url"][0]);
}
/**
 * @function refreshTableList
 * 
 * refresh displaying of table list
 */
const refreshTableList = () => {
  cleanUp("tables");
  $("#left_panel").addClass("genelic_panel");
  getAjaxData(scenario["function-get-url"][1]);
}
/**
 * @function tidyupcmdCandidates
 * 
 * reject 'targetcmd' from cmdCandidates
 * 
 * @param {string} targetcmd command string
 */
const tidyupcmdCandidates = (targetcmd) => {
  return cmdCandidates = cmdCandidates.filter(function (v) {
    return v != targetcmd;
  });
}

const setLeftPanelTitle = () => {
  title = "Table List";
  if (loginuser.dbtype == "redis") {
    title = "Keys List";
  }

  $(LeftPanelTitle).text(title);
}

const isSelectedItem = () => {
  let ret = false;
  let selecteditems = $(`${CONTAINERPANEL} span`).filter(".selectedItem").text();
  if (0 < selecteditems.length) {
    ret = true;
  }

  return ret;
}

$(GENELICPANELINPUT).blur(function(){
  let subq = $(GENELICPANELINPUT).val();
  /*
  if( $.inArray(subq[subq.length-1],["\n","\r\n"] != -1) ){
    console.log("subq:",subq);
    let subq1 = subq.slice(0,subq.lenth-1);
    console.log("change subquey str: ", subq1, subq.length, "->", subq1.length);
    $(GENELICPANELINPUT).val(subq1);
  }*/
 let subq1 = subq.replace(/\r?\n/g,'');
 $(GENELICPANELINPUT).val('');
 $(GENELICPANELINPUT).val(subq1);
});
