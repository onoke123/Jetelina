/**
    JS library for Jetelina Function Panel
    @author Ono Keiji

    This js lib works with functionpanel.js.

    Functions:
      checkGenelicInput() check genelic panel input. caution: will imprement this in V2 if necessary
  */
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

  if (containsMultiTables()) {
    // collect all column name in showing
    let arr = [];
    $(`${COLUMNSPANEL} span, ${CONTAINERPANEL} span`).filter('.item').each(function () {
      arr.push($(this).text());
    });

    /*
      Tips:
        should check the table names if contain..() were true, meaning using multi tables
    */
    console.log("pre..mul:", preferent.multitables);
    // 複数table使用時はwhere文に設定されているハズのカラム名が<table name>.<column name>でなければいけない。
    // sをblanckでsplitし、カラム名と推定されるモノ->arrに類似文字列があるモノ　を特定し、それがpreferent.multitablesにあるtable名を持っているか調べる。
    let c_c = s.split(" ");
    if (0 < c_c.length) {
      for (let i in c_c) {
        if (-1 < $.inArray(c_c[i], arr)) {
          console.log("chk1: true ", c_c[i]);
        } else {
          console.log("chk2: false", c_c[i]);
        }
      }
    }

    return false;// for checking fast
  } else {
    if (s == "where" || s == "") {
      $(GENELICPANELINPUT).val(IGNORE);
    } else {
      ret = subquerychecking(s);
    }

    return ret;
  }
}

const subquerychecking = (s) => {
  let ret = true;
  /*
    Tips:
      check this sub query strings with #container->span text is in selected items,
      check this string is collect,
      check this string has its post query parameter, like '{parameter}',
                                                                         etc...
      well, there are a lot of tasks in here, therefore wanna set them beside now,
      writing the sub query is on your own responsibility. :)
  */

  // 1st: "" -> '' because sql does not accept ""
  let unacceptablemarks = ["\"", "`"];
  for (let i in unacceptablemarks) {
    s = s.replaceAll(unacceptablemarks[i], "'");
  }

  // 2nd: reject unexpected words
  let unexpectedwords = ["delete", "drop", ";"];
  for (i in unexpectedwords) {
    s = s.replaceAll(unexpectedwords[i], "");
  }

  // 3nd: the number of '{' and '}' is equal
  let cur_l = s.match(/{/igm)
  let cur_r = s.match(/}/igm)
  if (cur_l != null && cur_r != null) {
    if (cur_l.length != cur_r.length) {
      ret = false;
    }
  } else if ((cur_l != null && cur_r == null) || (cur_l == null && cur_r != null)) {
    ret = false;
  } else {
    // both null is available
  }

  if (ret) {
    $(GENELICPANELINPUT).val(s);
  }

  return ret;
}  