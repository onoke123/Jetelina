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
const accountManager = (s) =>{
    if(inScenarioChk(s,'user-manage-add')){
        // add new user/account
        console.log("user add");
    }else if(inScenarioChk(s,'user-manage-update')){
        // update existence user data
        console.log("user update");
    }else if(inScenarioChk(s,'user-manage-list')){
        // display user/account list
        console.log("user list");
    }else if(inScenarioChk(s,'user-manage-delete')){
        // delete user/account
        console.log("user delete");
    }
}
