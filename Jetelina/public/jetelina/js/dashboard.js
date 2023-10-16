/**
 * @author Ono Keiji
 * @version 1.0
 * 
 * This is the main js file for Jetelina. These functions handle the initial behavior of Jetelina screen.
 * 
 */
let stage = 0;// action stage number ex. 1:before login  'login':at login
let preferent = {};// contains precedence commands
let presentaction = {};// contains the present function  ex. functionpanel -> table
const animateDuration = 1500;// animate() duration
let isSuggestion = false; // set this to 'true' in getAjaxData() if there were Jetelina's suggestion
const debug = true;// debug flag   true or false
let timerId;// interval timer of the idling comment in the opening screen。uses in jetelinalib.js burabura()
let acVscom;// flg for exisiting the data of 'Access vs Combination'.

$(window).load(function () {
  /**
   * @function focusonJetelinaPanel
   * 
   * focust on the input tag of jetelina panel
   */
  const focusonJetelinaPanel = () => {
    $("#jetelina_panel [name='chat_input']").focus();
  }
  /**
   * @function activePanel
   * @param {string]} panel tag name
   * 
   * make active the panel
   */
  const activePanel = (p) => {
    $(p).removeClass("commonpanelborderoff");
    $(p).addClass("commonpanelborderon");
  }
  /**
   * @function inactivePanel
   * @param {string} panel tag name
   *  
   * make inactive the panel
   */
  const inactivePanel = (p) => {
    $(p).removeClass("commonpanelborderon");
    $(p).addClass("commonpanelborderoff");
  }

  /* panelをclickしたときに画面中央にpanelを移動させる。
     panelサイズを考慮した移動にしないといけない。
     8/29 要るかどうかどうかわからないので一旦コメントアウト。 #83も同じ
  
  const moveTotheCenter = () => {
  }*/

  /**
   * manipulate jetelina panel (chat)
   */
  $("#jetelina_panel").show().draggable();
  /**
   *   manipulate condition panel
   */
  $("#condition_panel").hide().draggable();
  $("#plot").mouseover(function () {
    $("#condition_panel").draggable("disable");
  }).mouseout(function () {
    $("#condition_panel").draggable("enable");
  });
  /**
   *  manipulate function panel
   */
  $("#function_panel").hide().draggable();
  /**
   * switch active/inactive panel by focusting
   */
  $(".squarepanel").mouseover(function () {
    let elementid = $(this).attr('id');
    if (elementid == 'jetelina_panel') focusonJetelinaPanel();

    activePanel(this);
  }).mouseout(function () {
    inactivePanel(this);
  }).on('click', function () {
    /* panelをclickしたときに画面中央にpanelを移動させる。
       panelサイズを考慮した移動にしないといけない。
    moveTotheCenter();
    */
  });
  /**
   * set forcus in the input tag of jetelina panel
   */
  focusonJetelinaPanel();
  /**
   * Show the first message 'Hi'
   */
     openingMessage();
});
/**
 * chatting with Jetelina
 */
$("#jetelina_panel [name='chat_input']").keypress(function (e) {
  if (e.keyCode == 13) {
    if (timerId != null ){
      clearInterval(timerId);
    }

    chatKeyDown();
  }
});