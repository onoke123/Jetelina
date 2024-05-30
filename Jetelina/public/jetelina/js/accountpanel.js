/**
    JS library for Jetelina Account Manage Panel
    @author Ono Keiji

    This js lib works with dashboard.js and jetelinalib.js for the Account Mange Panel.

    Fucntions:
 */
/**
 * @function accountManager
 * 
 * @param {string} s user input string in the chatbox
 * 
 * manage user account  
 */
const userRegistrationFormInputChk = () =>{
    const FRISTNAME = "user_first_name";
    const LASTNAME = "user_last_name";
    const NICKNAME = "user_nick_name";
    let s = "";

    if($(`${USERREGFORM} [name=${FRISTNAME}]`).text().length == 0){
        s = "let me know the first name";
    }else if($(`${USERREGFORM} [name=${LASTNAME}]`).text().length == 0){
        s = "let me know the last name";
    }

    return s;
}

const accountManager = (s) =>{
    showUserRegistrationForm(true);
    const panelTop = window.innerHeight / 2 - 100;
    const panelLeft = window.innerWidth / 2 - 100;
    $(USERREGFORM).draggable().animate({
        width: "200px",
        height: "70px",
        top: `${panelTop}px`,
        left: `${panelLeft}px`//"210px"
    }, ANIMATEDURATION);

    if(inScenarioChk(s,'user-manage-add') ||(presentaction.um == 'user-add') ){
        // add new user/account
        console.log("user add");
        if(presentaction.um == null){
            presentaction.um = 'user-add';
        }

        return userRegistrationFormInputChk();
    }else if(inScenarioChk(s,'user-manage-update')){
        // update existence user data
        console.log("user update");
    }else if(inScenarioChk(s,'user-manage-list')){
        // display user/account list
        console.log("user list");
        showUserRegistrationForm(false);
    }else if(inScenarioChk(s,'user-manage-delete')){
        // delete user/account
        console.log("user delete");
    }

}
