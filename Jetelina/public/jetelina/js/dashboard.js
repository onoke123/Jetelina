let stage = 0;// action stage number ex. 1:before login  'login':at login
let preferent = {};// 優先されるべきコマンドを格納する
let presentaction = {};// 現在実行されている機能を格納する ex. functionpanel -> table
const animateDuration = 1500;// animate() duration
let sad = false;//getsqlanalyzerdataは一回だけ呼び出すので、getAjaxData()内でこれをtrueに設定する
const debug = true;
let timerId;//opening画面のブラブラ表示実行interval timer変数。jetelinalib.js burabura()で使用している
//const table = [];

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
  $("#plot").mouseover(function () {
    $("#condition_panel").draggable("disable");
  }).mouseout(function () {
    $("#condition_panel").draggable("enable");
  });

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
    moveTotheCenter();
  });

  // set forcus in the input tag of jetelina panel
  focusonJetelinaPanel();

  /* 最初のチャットメッセージを表示する
     大体が"Hi"で始める
  */
     openingMessage();
  //  typing(0, chooseMsg(0, "", ""));
});

// chatting with Jetelina
$("#jetelina_panel [name='chat_input']").keypress(function (e) {
  if (e.keyCode == 13) {
    if (timerId != null ){
      clearInterval(timerId);
    }

    chatKeyDown();
  }
});