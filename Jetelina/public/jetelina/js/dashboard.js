/**
 * @author Ono Keiji
 * 
 * This is the main js file for Jetelina. These functions handle the initial behavior of Jetelina screen.
 * 
 *     Functions list:
 *       getRandomNumber(i) create random number. the range is 0 to i.
 */
const ANIMATEDURATION = 1500;// animate() duration
const IGNORE = "ignore"; // when jetelina message is nothing
const JETELINAPANEL ="#jetelina_panel"; 
const FUNCTIONPANEL = "#function_panel";
const CONDITIONPANEL = "#condition_panel";
const CONTAINERPANEL = "#container";
const RELATEDTABLESAPIS = "#right_panel";
const COLUMNSPANEL = "#columns";
const JETELINACHATBOX = `${JETELINAPANEL} [name='chat_input']`;
const CHARTPANEL = "#plot";
let stage = 0;// action stage number ex. 1:before login  'login':at login
let preferent = {};// contains precedence commands. ex. droptable, deliteApi...
let presentaction = {};// contains the present function, mode etc  ex. functionpanel -> table
let cancelableCmdList = [];// candidate list for cancelable commands, cancelable 'presentaction' is listed in here  
let isSuggestion = false; // set this to 'true' in getAjaxData() if there were Jetelina's suggestion
let timerId;// interval timer of the idling comment in the opening screen。uses in jetelinalib.js burabura()
let logouttimerId;// interval timer of transfering logout to opening scree, use in jetelinalib.js chatKeyDown()
let inprogress=false;// true -> ajax function is in progress , false -> is not i progress. set in $.ajax({xhr:})
let loginuser = {}; // contains login user info
let authcount = 0; // authentication count. this is randum number that is set in login function
//let usetcount = 0; // only use for the first login in checkNewCommer function in jetelinalib.js

$(window).load(function () {
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
  /**
   * manipulate jetelina panel (chat)
   */
  $(JETELINAPANEL).show().draggable();
  /**
   *  manipulate function panel
   */
  $(FUNCTIONPANEL).hide().draggable();
  /**
   *   manipulate condition panel
   */
  $(CONDITIONPANEL).hide().draggable();
  $(CHARTPANEL).mouseover(function () {
    $(CONDITIONPANEL).draggable("disable");
  }).mouseout(function () {
    $(CONDITIONPANEL).draggable("enable");
  });
  /**
   * switch active/inactive panel by focusting
   */
  $(".squarepanel").mouseover(function () {
    let elementid = $(this).attr('id');
    if (elementid == 'jetelina_panel'){
      focusonJetelinaPanel();
    }

    activePanel(this);
  }).mouseout(function () {
    inactivePanel(this);
  }).on('click', function () {
    // need to do something, maybe... who knows
  });
  /**
   * set forcus in the input tag of jetelina panel and say 'Hi' as the first message
   */
  focusonJetelinaPanel();
  openingMessage();
});
  /**
   * @function focusonJetelinaPanel
   * 
   * focust on the input tag of jetelina panel
   */
  const focusonJetelinaPanel = () => {
    $(JETELINACHATBOX).focus();
    subPanelCheck();
  }

/**
 * chatting with Jetelina
 */
$(document).on("keydown", JETELINACHATBOX, function(e){
  if (e.keyCode == 13) {
    if (timerId != null ){
      clearInterval(timerId);
    }

    if( !inprogress ){
      chatKeyDown();
    }else{
      // refuse any commands so that something ajax() inprogress
      typingControll(chooseMsg('refuse-command-msg', "", ""));
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
/**
 * @function getRandomNumber
 * @param {integer} ordered random range
 * @returns {boolean}  true -> yes a beginner, false -> an expert
 * 
 * create random number. the range is 0 to i.
 */
const getRandomNumber = (i) => {
  return Math.floor(Math.random() * i);
}
