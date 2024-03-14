
/**
    JS library for Jetelina Condition Panel
    @author Ono Keiji
    @version 1.0

    This js lib works with dashboard.js, functionpanel.js and conditionpanel.js for the Condition Panel.
    
    Functions:
      isVisibleAccessCombination() checking "#plot" is visible or not
      isVisibleApiAccessNumbers() checking "#api_access_numbers" is visible or not
      isVisiblePerformanceReal() checking "#performance_real" is visible or not
      isVisiblePerformanceTest() checking "#performance_test" is visible or not
      conditionPanelFunctions(ut)  Exectute some functions ordered by user chat input message
      setGraphData(o,type)  set data to a graph of creating by plot.js. data and 'type' are passed by getAjaxData() in jetelinalib.js 
      viewPerformanceGraph(apino, data, type)  show 'performance graph'
      viewCombinationGraph(bname, bno, ct, ac)  show the 'combination graph'
*/
/**
 *  @function openFunctionPanel
 * 
 *  open and visible "#function_panel"
 */
const openConditionPanel = () => {
    if( isVisibleFunctionPanel() ){
        $("#function_panel").hide();
    }
    
    $("#condition_panel").show().animate({
        width: window.innerWidth * 0.8,
        height: window.innerHeight * 0.8,
        top: "10%",
        left: "10%"
    }, animateDuration);

    const dataurls = scenario['analyzed-data-collect-url'];
    /*
        check for existing Jetelina's suggestion
    */
    getAjaxData(dataurls[3]);
}
/**
 * @function isVisibleApiAccessNumbers
 * @returns {boolean}  true -> visible, false -> invisible
 * 
 * checking "#api_access_numbers" is visible or not
 */
const isVisibleApiAccessNumbers = () =>{
    let ret = false;
    if ($("#api_access_numbers").is(":visible")){
      ret = true;
    }
  
    return ret;
  }
/**
 * @function isVisibleAccessCombination
 * @returns {boolean}  true -> visible, false -> invisible
 * 
 * checking "#plot" is visible or not
 */
const isVisibleAccessCombination = () =>{
    let ret = false;
    if ($("#plot").is(":visible")){
      ret = true;
    }
  
    return ret;
  }
/**
 * @function isVisiblePerformanceReal
 * @returns {boolean}  true -> visible, false -> invisible
 * 
 * checking "#performance_real" is visible or not
 */
const isVisiblePerformanceReal = () =>{
    let ret = false;
    if ($("#performance_real").is(":visible")){
      ret = true;
    }
  
    return ret;
  }
/**
 * @function isVisiblePerformanceTest
 * @returns {boolean}  true -> visible, false -> invisible
 * 
 * checking "#performance_test" is visible or not
 */
const isVisiblePerformanceTest = () =>{
    let ret = false;
    if ($("#performance_test").is(":visible")){
      ret = true;
    }
  
    return ret;
  }
/**
 * @function conditionPanelFunctions
 * @param {string} ut  chat message by user 
 * @returns {string}  answer chat message by Jetelina
 * 
 * Exectute some functions ordered by user chat input message
 */
const conditionPanelFunctions = (ut) => {
    let m = 'ignore';

    if (presentaction == null || presentaction.length == 0) {
        presentaction.push('cond');
    }

//    if (inScenarioChk(ut,'function_panel-cmd')) {
//        delete preferent;
//        delete presentaction;
//        stage = 'lets_do_something';
//        chatKeyDown(ut);
//    } else {
        // use the prior command if it were
        let cmd = getPreferentPropertie('cmd');

        if (cmd == null || cmd.length <= 0) {
            if( inScenarioChk(ut,'cond-graph-show-cmd')){
                cmd = "graph";
            }else if( inScenarioChk(ut,'cond-sql-performance-graph-show-cmd')){
                if(isSuggestion){
                    cmd = "performance";
                }else{
                    cmd = "no_suggestion";
                }
            }else if( inScenarioChk(ut,'confirmation-sentences-cmd') && isSuggestion ){
                cmd = "performance";
            }
        }

        /*
            Tips:
                cmd
                    'graph': show 'api access numbers' graph
                    'performance: show the result of analyzing sql exection on test db.
                                  this cmd can execute in the case of being a suggestion.
        */
        if(-1<$.inArray(cmd,['graph','performance'])){
            openConditionPanel();
        }

        switch (cmd) {
            case 'graph':
                if(isVisiblePerformanceReal()){
                    $("#performance_real").hide();
                }

                if(isVisiblePerformanceTest()){
                    $("#performance_test").hide();
                }

                if(isVisibleAccessCombination()){
                    $("#plot").hide();
                }

                $("#something_msg").hide();

                $("#api_access_numbers").show().draggable().animate({
                    top: "20%",
                    left: "20%"
                }, animateDuration).draggable('disable');

                m = chooseMsg('cond-graph-show-msg', "", "");
                break;
            case 'performance':
                if(isVisibleApiAccessNumbers()){
                    $("#api_access_numbers").hide();
                }

                if(isVisiblePerformanceReal()){
                    $("#performance_real").hide();
                }        
                /*
                    Tips:
                        below graphs performance is as same as 'case:graph'.
                */
               /*
                $("#plot").show().animate({
                    top: "5%",
                    left: "-5%"
                }, animateDuration);
                */
                $("#performance_test").show().draggable().animate({
                    top: "20%", //-50%",
                    left: "20%" //"50%"
                }, animateDuration).draggable('disable');

                $("#something_msg").show();
                m = chooseMsg('cond-graph-show-msg', "", "");
                break;
            case 'no_suggestion':
                m = chooseMsg('cond-no-suggestion-msg', "", "");
                break;
            default:
                break;
        }
//    }

    return m;
}

/*
    Tips:
        the real sql execution performance data is stored in this parameter temporarily.
        this stored real data is needed when the test data is rendered.
        because the real data and test db performance data are packed in the same graph.
 */
let realPerformanceData;

/**
 * @function setGraphData
 * @param {object} o   json object data
 * @param {string} type  'ac'-> access vs combination  'real'->real performance 'access'->sql access numbers 'test'->test performance    this is ordered in jetelinalib.js
 * @return {boolean} true->exists 'Access vs Combination data'  false-> not exists it
 * set data to a graph of creating by plot.js. data and 'type' are passed by getAjaxData() in jetelinalib.js  
 */
const setGraphData = (o, type) => {
    let ret = false;
    const apino = "apino"; // ajax data field name
    const combination = "combination"; // same above
    const access_numbers = "access_numbers"; // same above
    const mean = "mean"; // same above

    if (o != null) {
        Object.keys(o).forEach(function (key) {
            // because a value of ’Jetelina’ is an object   name=>key value=>o[key]
            if (key == "Jetelina" && o[key].length > 0) {
                // access vs combination
                let base_table_name = [];
                let base_table_no = [];
                let combination_table = [];
                let access_count = [];
                /* performance
                    apino,max,min,mean -> apino, use only 'mean' data
                */
                let apino = [];
                let mean = [];

                $.each(o[key], function (k, v) {
                    if (v != null) {
                        $.each(v, function (name, value) {
                            if (name == "apino") {
                                apino.push(value);
                            } else if (name == combination) {
                                base_table_no.push(value[0]);// original table no -> x axis
                                let pn = 0;
                                if (2 < value.length) {
                                    let cbn = 0;
                                    for (let i = 2; i < value.length; i++) {
                                        cbn += value[i];
                                    }

                                    pn = cbn;
                                } else if (value.length == 2) {
                                    pn = value[1];
                                }

                                combination_table.push(pn);// table combination no -> y axis
                                ret = true; // meaning of exisiting combination_table is there is the data of 'Access vs Combination'.                                     
                            } else if (name == access_numbers) {
                                access_count.push(value);// table access normarize no -> z axis
                            } else if (name == mean) {
                                mean.push(value);
                            }
                        });
                    }
                });

                /*
                    Tips:
                      adjusting the plot.js execution time because it is depend on clients environment
                */
                setTimeout(function () {
                    if (type == "ac") {
                        viewCombinationGraph(apino, base_table_no, combination_table, access_count);
                    } else if (type == "access"){
                        viewPerformanceGraph(apino, access_count, type);
                    }else{
                        viewPerformanceGraph(apino, mean, type);
                    }
                }, 1000);

            }
        });
    }

    return ret;
}
/**
 * @function viewPerformanceGraph
 * @param {string} apino 
 * @param {Float64Array} d  array of any data 
 * @param {string} type  'ac'-> access vs combination  'real'->real performance 'access'->sql access numbers 'test->test performance    this is ordered in jetelinalib.js
 * 
 * show 'performance graph'
 */
const viewPerformanceGraph = (apino, d, type) => {
    let data;

    if (type == "real" || type == "access"){
        data = [
            {
                opacity: 0.5,
                type: 'scatter',
                text: apino,
                x: apino,
                y: d,
                mode: 'markers',
                marker: {
                    color: 'rgb(255,255,255)',
                    size: 20
                }
            }
        ];    
    }else{
        let real_data = 
            {
                opacity: 0.5,
                type: 'scatter',
                text: apino,
                x: apino,
                y: realPerformanceData,
                mode: 'markers',
                name: 'real sql',
                marker: {
                    color: 'rgb(255,255,255)',
                    size: 20
                }
            };
        

        let test_data = 
            {
                opacity: 0.5,
                type: 'scatter',
                text: apino,
                x: apino,
                y: d,
                mode: 'markers',
                name: 'test sql',
                marker: {
                    color: 'rgb(255,0,0)',
                    size: 20
                }
            };
        

        data = [real_data,test_data];
    }


    let paper_bgc = 'rgb(112,128,144)';
    let font_col = 'rgb(255,255,255)';
    if( type == 'test'){
        paper_bgc = 'rgb(0,129,104)';//'rgb(240,230,140)'
//        font_col = 'rgb(255,0,0)';
    }

    let title = "exection speed";
    if (type == "access"){
        title = "access numbers";
    }

    let layout = {
        plot_bgcolor: 'rgb(0,0,0)',
        paper_bgcolor: paper_bgc,
        xaxis: {
            backgroundcolor: 'rgb(255,0,0)',
            showbackground: false,
            gridcolor: 'rgb(0,153,153)',
            color: font_col,
            size: 20,
            title: 'api no'
        },
        yaxis: {
            backgroundcolor: 'rgb(255,0,0)',
            showbackground: false,
            gridcolor: 'rgb(0,153,153)',
            color: font_col,
            size: 20,
            title: title
        }
    };

    if (type == "access"){
        Plotly.newPlot('api_access_numbers_graph', data, layout);
    } else if (type == "real") {
        Plotly.newPlot('performance_real_graph', data, layout);
    } else {
        Plotly.newPlot('performance_test_graph', data, layout);
    }
}
/**
 * @function viewCombinationGraph
 * @param {string} bname   api number
 * @param {integre} bno   base table number 
 * @param {string} ct   table name of combination 
 * @param {integer} ac  sql access count number
 * 
 * show the 'combination graph' 
 */
const viewCombinationGraph = (bname, bno, ct, ac) => {
    var data = [
        {
            opacity: 0.5,
            type: 'scatter3d',
            text: bname,
            x: bno,
            y: ct,
            z: ac,
            mode: 'markers+text'
        }
    ];
    var layout = {
        plot_bgcolor: 'rgb(0,0,0)',
        paper_bgcolor: 'rgb(112,128,144)',
        xaxis: {
            backgroundcolor: 'rgb(255,0,0)',
            showbackground: false,
            gridcolor: 'rgb(0,153,153)',
            color: 'rgb(255,255,255)',
            size: 20,
            title: 'api no'
        },
        yaxis: {
            backgroundcolor: 'rgb(255,0,0)',
            showbackground: false,
            gridcolor: 'rgb(0,153,153)',
            color: 'rgb(255,255,255)',
            size: 20,
            title: 'combination'
        },
        zaxis: {
            backgroundcolor: 'rgb(255,0,0)',
            showbackground: false,
            gridcolor: 'rgb(0,153,153)',
            color: 'rgb(255,255,255)',
            size: 20,
            title: 'access'
        }
    };

    Plotly.newPlot('plot_graph', data, layout);
}