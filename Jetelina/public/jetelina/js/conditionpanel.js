
/**
    JS library for Jetelina Condition Panel
    @author Ono Keiji
    @version 1.0

    This js lib works with dashboard.js, functionpanel.js and conditionpanel.js for the Condition Panel.
    
    Functions:
      isVisiblePerformanceReal() checking "#performance_real" is visible or not
      isVisiblePerformanceTest() checking "#performance_test" is visible or not
      conditionPanelFunctions(ut)  Exectute some functions ordered by user chat input message
      setGraphData(o,type)  set data to a graph of creating by plot.js. data and 'type' are passed by getAjaxData() in jetelinalib.js 
      viewPerformanceGraph(apino, mean, type)  show 'performance graph'
      viewCombinationGraph(bname, bno, ct, ac)  show the 'combination graph'
*/
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

    if (inScenarioChk(ut,'function_panel')) {
        delete preferent;
        delete presentaction;
        stage = 'chose_func_or_cond';
        chatKeyDown(ut);
    } else {
        // use the prior command if it were
        let cmd = getPreferentPropertie('cmd');

        if (debug) {
            console.log("conditonpanel.js conditonPanelFunctions() starts with : ", ut);
            console.log("conditonpanel.js conditonPanelFunctions() cmd : ", cmd);
        }

        if (cmd == null || cmd.length <= 0) {
            if( inScenarioChk(ut,'6cond-graph-show-keywords')){
                cmd = "graph";
            }else if( inScenarioChk(ut,'6cond-sql-performance-graph-show-keywords')){
                if(isSuggestion){
                    cmd = "performance";
                }else{
                    cmd = "no_suggestion";
                }
            }else if( inScenarioChk(ut,'confirmation-sentences') && isSuggestion ){
                cmd = "performance";
            }
        }

        switch (cmd) {
            case 'graph':
                if(isVisiblePerformanceTest()){
                    $("#performance_test").hide();
                }        
                
                /*
                    Tips:
                        #plot rotates 3D graph, so the div panel is not to be draggable.
                        this graph is shown when the data exsists. this is judged by 'acVsCom' 
                        global valiable, and it is set in setGraphData() in jetelinalib.js.
                */
                if(acVscom){
                    $("#plot").show().animate({
                        top: "5%",
                        left: "-5%"
                    }, animateDuration);
                }
                /*
                    Tips:
                        This graph is 2D, the graph can zoom/pan...., 
                        so the div panel is also not to be draggable after getting its position.
                        the "#performance_real" will fly away to somewhere when "#plot" is invisible,
                        if the "top" variable is unchangeable. :-P
                */
               let ppp = "-50%";
                if(!$("#plot").is(":visible")){
                    ppp = "-5%";
                }

                $("#performance_real").show().draggable().animate({
                    top: ppp,
                    left: "50%"
                }, animateDuration).draggable('disable');

                m = chooseMsg('6cond-graph-show', "", "");
                break;
            case 'performance':
                if(isVisiblePerformanceReal()){
                    $("#performance_real").hide();
                }        
                /*
                    Tips:
                        below graphs performance is as same as 'case:graph'.
                */
                $("#plot").show().animate({
                    top: "5%",
                    left: "-5%"
                }, animateDuration);

                $("#performance_test").show().draggable().animate({
                    top: "-50%",
                    left: "50%"
                }, animateDuration).draggable('disable');

                m = chooseMsg('6cond-graph-show', "", "");
                break;
            case 'no_suggestion':
                m = chooseMsg('6cond-no-suggestion', "", "");
                break;
            default:
                m = "";
                break;
        }
    }

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
 * @param {string} type  'ac'-> access vs combination  'real'->real performance  'test->test performance    this is ordered in jetelinalib.js
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
                            if (name == apino) {
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
                    } else {
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
 * @param {Float64Array} mean  array of mean data 
 * @param {string} type  'ac'-> access vs combination  'real'->real performance  'test->test performance    this is ordered in jetelinalib.js
 * 
 * show 'performance graph'
 */
const viewPerformanceGraph = (apino, mean, type) => {
    let data;

    if (type == "real"){
        data = [
            {
                opacity: 0.5,
                type: 'scatter',
                text: apino,
                x: apino,
                y: mean,
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
                y: mean,
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
            title: 'exection speed'
        }
    };

    if (type == "real") {
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
    if (debug) {
        console.log("bname: ", bname);
        console.log("bno: ", bno);
        console.log("ct: ", ct);
        console.log("at: ", ac);
    }

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