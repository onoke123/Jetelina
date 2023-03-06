let stage = 0;// action stage number ex. 1:before login  'login':at login
const animateDuration = 1500;// animate() duration
const debug = true;
const table = [];

$(window).load(function () {
  // focust on the input tag of jetelina panel
  const focusonJetelinaPanel = () => {
    $("#jetelina_panel [name='chat_input']").focus();
  }
  // make active the panel
  const activePanel = (p) => {
    $(p).removeClass("commonpanelborderoff");
    $(p).addClass("commonpanelborderon");
  }

  // make inactive the panel
  const inactivePanel = (p) => {
    $(p).removeClass("commonpanelborderon");
    $(p).addClass("commonpanelborderoff");
  }

  /* panelをclickしたときに画面中央にpanelを移動させる。
     panelサイズを考慮した移動にしないといけない。
  */
  const moveTotheCenter = () => {
  }

  // jetelina panel (chat)
  $("#jetelina_panel").show().draggable({
    /*
    start: function(event, ui) {  }, //at drag start
    drag: function( event, ui ) { }, //at during drag
    stop: function (event, ui) { }
    */
  });

  // condition panel
  $("#condition_panel").hide().draggable();
  // function panel
  $("#function_panel").hide().draggable();

  // switch active/inactive panel by focusting 
  $(".squarepanel").mouseover(function () {
    let elementid = $(this).attr('id');
    if (elementid == 'jetelina_panel') focusonJetelinaPanel();

    activePanel(this);
  }).mouseout(function () {
    inactivePanel(this);
  }).on('click', function () {
    /* panelをclickしたときに画面中央にpanelを移動させる。
       panelサイズを考慮した移動にしないといけない。
    */
    console.log("clicked");
    moveTotheCenter();
  });

  // set forcus in the input tag of jetelina panel
  focusonJetelinaPanel();

  /* 最初のチャットメッセージを表示する
     大体が"Hi"で始める
  */
  typing(0, chooseMsg(0, "", ""));
});

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
// chatting with Jetelina
$("#jetelina_panel [name='chat_input']").keypress(function (e) {
  if (e.keyCode == 13) {
    chatKeyDown();
  }
});