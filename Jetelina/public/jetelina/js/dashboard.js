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
let timerId;// interval timer of the idling comment in the opening screen。uses in jetelinalib.js burabura()
let acVscom;// flg for exisiting the data of 'Access vs Combination'.
let inprogress=false;// true -> ajax function is in progress , false -> is not i progress. set in $.ajax({xhr:})
let loginuser = {}; // contains login user info

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

    if( !inprogress ){
      chatKeyDown();
    }else{
      // refuse any commands so that something ajax() inprogress
      typingControll(chooseMsg('refuse-command', "", ""));
    }
  }
});

/**
 * text zoom In/Out
 *    In -> fontsize change to 22px
 *    Out -> fontsize change to 6px
 * 
 * zoom 'your_tell' text in Jetelina Chatbox 'id=jetelina_panel'
 * font-size=22px is preliminary
 * font-size=6px is matched with '.yourText' class in dashboard.css 
 * 
 * 'yourText' is defined in dashboard.css, '.zoomInOut' is not defined anywhare so that 
 * this class name gives this effection as your demand. 
 */
$(".yourText,.zoomInOut").on('mouseover',function () {
  $(this).animate({
    'font-size':'22px'
  }, 200);
}).on('mouseout',function () {
  $(this).animate({
    'font-size':'6px'
  }, 200);
}).on('click', function () {
  /* something will be implemented someday */
});