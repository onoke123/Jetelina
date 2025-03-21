<<<<<<< HEAD:Jetelina/public/jetelina/js/origin/dashboard.js
/**
 * @author Ono Keiji
 * 
 * This is the main js file for Jetelina. These functions handle the initial behavior of Jetelina screen.
 * 
 *     Functions list:
 *        focusonJetelinaPanel() focust on the input tag of jetelina panel
 *        activePanel(p) make active the panel
 *        inactivePanel(p) make inactive the panel
 *        isactivePanel(p) check the 'p' is active or inactive
 *        getRandomNumber(i) create random number. the range is 0 to i.
 */
const ANIMATEDURATION = 1500;// animate() duration
const ANIMATEDSCROLLING = 2000;// message scrolling duration in box
const IGNORE = "ignore"; // when jetelina message is nothing
const GUIDANCE = "#guidance";
const JETELINAPANEL = "#jetelina_panel";
const FUNCTIONPANEL = "#function_panel";
const CONTAINERPANEL = "#container";
const RELATEDTABLESAPIS = "#right_panel";
const COLUMNSPANEL = "#columns";
const JETELINACHATBOX = `${JETELINAPANEL} [name='chat_input']`;
const PIECHARTPANEL = "#piechart";
const APIACCESSNUMBERS = "#api_access_numbers";
const LINECHARTPANEL = "#apispeedchart";

let stage = 0;// action stage number ex. 1:before login  'login':at login
let preferent = {};// contains precedence commands. ex. droptable, deliteApi...
let presentaction = {};// contains the present function, mode etc  ex. functionpanel -> table
let cancelableCmdList = [];// candidate list for cancelable commands, cancelable 'presentaction' is listed in here  
let timerId;// interval timer of the idling comment in the opening screen。uses in jetelinalib.js burabura()
let logouttimerId;// interval timer of transfering logout to opening scree, use in jetelinalib.js chatKeyDown()
let inprogress = false;// true -> ajax function is in progress , false -> is not i progress. set in $.ajax({xhr:})
let loginuser = {}; // contains login user info
let authcount = 0; // authentication count. this is randum number that is set in login function

$(window).load(function () {
  /**
   * manipulate jetelina panel (chat)
   */
  $(JETELINAPANEL).show().draggable();
  /**
   *  manipulate function panel
   */
  $(FUNCTIONPANEL).hide().draggable();
  /**
   *   manipulate stats panel
   */
  //  $(STATSPANEL).hide().draggable();
  //  $(CHARTPANEL).mouseover(function () {
  //    $(STATSPANEL).draggable("disable");
  //  }).mouseout(function () {
  //    $(STATSPANEL).draggable("enable");
  //  });
  /**
   * switch active/inactive panel by focusting
   */
  $(".squarepanel").mouseover(function () {
    let elementid = $(this).attr('id');
    if (elementid == 'jetelina_panel') {
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
$(document).on("keydown", JETELINACHATBOX, function (e) {
  if (e.keyCode == 13) {
    if (timerId != null) {
      clearInterval(timerId);
    }

    if (!inprogress) {
      chatKeyDown();
    } else {
      // refuse any commands so that something ajax() inprogress
      typingControll(chooseMsg('refuse-command-msg', "", ""));
    }
  }
});
/**
 * @function activePanel
 * @param {string]} p tag name
 * 
 * make active the panel
 */
const activePanel = (p) => {
  $(p).removeClass("commonpanelborderoff");
  $(p).addClass("commonpanelborderon");
}
/**
 * @function inactivePanel
 * @param {string} p tag name
 *  
 * make inactive the panel
 */
const inactivePanel = (p) => {
  $(p).removeClass("commonpanelborderon");
  $(p).addClass("commonpanelborderoff");
}
/**
 * @function isactivePanel
 * @param {string} p tag name 
 * @returns boolean  true -> active, false -> inactive
 * 
 * check the 'p' is active or inactive
 */
const isactivePanel = (p) => {
  let ret = false;
  if(p.hasClass("commonpanelborderon")){
    ret = true;
  }

  return ret;
}
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
$(".yourText,.zoomInOut").on('mouseover', function () {
  $(this).animate({
    'font-size': '22px'
  }, 200);
}).on('mouseout', function () {
  $(this).animate({
    'font-size': '6px'
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
=======
const _0x1f3c0e=_0x2d1b;(function(_0x269464,_0xda2176){const _0x112dd1=_0x2d1b,_0x2b3f05=_0x269464();while(!![]){try{const _0x411cc6=parseInt(_0x112dd1(0x188))/0x1+parseInt(_0x112dd1(0x19a))/0x2*(parseInt(_0x112dd1(0x198))/0x3)+parseInt(_0x112dd1(0x197))/0x4+parseInt(_0x112dd1(0x18e))/0x5+-parseInt(_0x112dd1(0x19c))/0x6+-parseInt(_0x112dd1(0x191))/0x7*(parseInt(_0x112dd1(0x194))/0x8)+-parseInt(_0x112dd1(0x1a6))/0x9;if(_0x411cc6===_0xda2176)break;else _0x2b3f05['push'](_0x2b3f05['shift']());}catch(_0x729ce6){_0x2b3f05['push'](_0x2b3f05['shift']());}}}(_0x4360,0xadbc2));const ANIMATEDURATION=0x5dc,IGNORE=_0x1f3c0e(0x19d),JETELINAPANEL=_0x1f3c0e(0x196),FUNCTIONPANEL=_0x1f3c0e(0x1a4),CONDITIONPANEL=_0x1f3c0e(0x1a7),CONTAINERPANEL=_0x1f3c0e(0x193),COLUMNSPANEL=_0x1f3c0e(0x1a0),JETELINACHATBOX=JETELINAPANEL+_0x1f3c0e(0x1a9),CHARTPANEL=_0x1f3c0e(0x18c);function _0x2d1b(_0x13887e,_0x20b2a0){const _0x4360cd=_0x4360();return _0x2d1b=function(_0x2d1bd5,_0xbb7b57){_0x2d1bd5=_0x2d1bd5-0x187;let _0x41a041=_0x4360cd[_0x2d1bd5];return _0x41a041;},_0x2d1b(_0x13887e,_0x20b2a0);}let stage=0x0,preferent={},presentaction={},cancelableCmdList=[],isSuggestion=![],timerId,logouttimerId,inprogress=![],loginuser={},authcount=0x0,usetcount=0x0;function _0x4360(){const _0x40c93f=['5090164YxuyUZ','87CYLVXx','hide','32462KPXicV','removeClass','4117680sIdCKM','ignore','6px','focus','#columns','addClass','.yourText,.zoomInOut','mouseout','#function_panel','commonpanelborderoff','15439077CTUkBI','#condition_panel','floor','\x20[name=\x27chat_input\x27]','load','mouseover','549864YgYqPY','random','disable','animate','#plot','.squarepanel','5518545pGpSXD','click','draggable','992117pSgAFu','commonpanelborderon','#container','16BBhWzP','refuse-command-msg','#jetelina_panel'];_0x4360=function(){return _0x40c93f;};return _0x4360();}$(window)[_0x1f3c0e(0x1aa)](function(){const _0x20a446=_0x1f3c0e,_0x4b4f61=_0xb60eba=>{const _0x54dac9=_0x2d1b;$(_0xb60eba)[_0x54dac9(0x19b)](_0x54dac9(0x1a5)),$(_0xb60eba)[_0x54dac9(0x1a1)](_0x54dac9(0x192));},_0x56574b=_0x4bf1fa=>{const _0x4557b2=_0x2d1b;$(_0x4bf1fa)[_0x4557b2(0x19b)](_0x4557b2(0x192)),$(_0x4bf1fa)[_0x4557b2(0x1a1)](_0x4557b2(0x1a5));};$(JETELINAPANEL)['show']()[_0x20a446(0x190)](),$(FUNCTIONPANEL)[_0x20a446(0x199)]()[_0x20a446(0x190)](),$(CONDITIONPANEL)[_0x20a446(0x199)]()[_0x20a446(0x190)](),$(CHARTPANEL)[_0x20a446(0x187)](function(){const _0x27a467=_0x20a446;$(CONDITIONPANEL)[_0x27a467(0x190)](_0x27a467(0x18a));})[_0x20a446(0x1a3)](function(){$(CONDITIONPANEL)['draggable']('enable');}),$(_0x20a446(0x18d))[_0x20a446(0x187)](function(){let _0x22574b=$(this)['attr']('id');_0x22574b=='jetelina_panel'&&focusonJetelinaPanel(),_0x4b4f61(this);})[_0x20a446(0x1a3)](function(){_0x56574b(this);})['on'](_0x20a446(0x18f),function(){}),focusonJetelinaPanel(),openingMessage();});const focusonJetelinaPanel=()=>{const _0xbcee4d=_0x1f3c0e;$(JETELINACHATBOX)[_0xbcee4d(0x19f)]();};$(document)['on']('keydown',JETELINACHATBOX,function(_0x4f0cd6){const _0x3685be=_0x1f3c0e;_0x4f0cd6['keyCode']==0xd&&(timerId!=null&&clearInterval(timerId),!inprogress?chatKeyDown():typingControll(chooseMsg(_0x3685be(0x195),'','')));}),$(_0x1f3c0e(0x1a2))['on'](_0x1f3c0e(0x187),function(){const _0x574dc0=_0x1f3c0e;$(this)[_0x574dc0(0x18b)]({'font-size':'22px'},0xc8);})['on'](_0x1f3c0e(0x1a3),function(){const _0x2d6010=_0x1f3c0e;$(this)[_0x2d6010(0x18b)]({'font-size':_0x2d6010(0x19e)},0xc8);})['on'](_0x1f3c0e(0x18f),function(){});const getRandomNumber=_0x155144=>{const _0x52625d=_0x1f3c0e;return Math[_0x52625d(0x1a8)](Math[_0x52625d(0x189)]()*_0x155144);};
>>>>>>> 184e08d (js obfuscator):Jetelina/public/jetelina/js/dashboard.js
