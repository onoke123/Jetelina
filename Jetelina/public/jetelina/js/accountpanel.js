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
    /*
        Tips:
            'whatJetelinaTold' is contained Jetelina's message.
            by comparing this and expected scenario message, may could take an correct action. :)
    */
    if(inScenarioChk(s,'user-manage-add') ||(presentaction.um == 'user-add') ){
        // add new user/account
        if(presentaction.um == null){
            presentaction.um = 'user-add';
        }

        if(-1<$.inArray(whatJetelinaTold, scenario['user-manage-username-msg'])){
                let data = `{"username":"${s}"}`;
                postAjaxData(scenario["function-post-url"][7],data);
        }

        return scenario['user-manage-username-msg'];
    }else if(inScenarioChk(s,'user-manage-update')){
        // update existence user data
        console.log("user update");
    }else if(inScenarioChk(s,'user-manage-delete')){
        // delete user/account
        console.log("user delete");
    }

}
