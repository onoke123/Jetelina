let stage = 0;// action stage number ex. 1:before login  'login':at login
let preferent;// 優先されるべきコマンドを格納する
const animateDuration = 1500;// animate() duration
const debug = true;
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
  typing(0, chooseMsg(0, "", ""));
});

// chatting with Jetelina
$("#jetelina_panel [name='chat_input']").keypress(function (e) {
  if (e.keyCode == 13) {
    chatKeyDown();
  }
});