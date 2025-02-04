
/**
    JS library for Jetelina Condition Panel
    @author Ono Keiji

    This js lib works with dashboard.js and jetelinalib.js for the Condition Panel.
    
    Functions:
      openStatsPanel(b,type) visible or hide "APIACCESSNUMBERS" an "#plot"
      isVisibleChartPanel() checking "#plot" is visible or not
      isVisibleApiAccessNumbers() checking "APIACCESSNUMBERS" is visible or not
      isVisiblePerformanceReal() checking "#performance_real" is visible or not
      isVisiblePerformanceTest() checking "#performance_test" is visible or not
      statsPanelFunctions(ut)  Exectute some functions ordered by user chat input message
      setGraphData(o,type)  set data to a graph of creating by plot.js. data and 'type' are passed by getAjaxData() in jetelinalib.js 
      showApiAccessNumbersList()  show api access number data in DataTable 
      apiAccessNumbersListController(cmd) api access numbers list controller. paging and search api order by chat box
      viewPerformanceGraph(apino, data, type)  show 'performance graph'
      viewCombinationGraph(bname, bno, ct, ac)  show the 'combination graph'
*/
const APIACCESSNUMBERSLIST = "#api_access_numbers_list";
const APIACCESSNUMBERSCOMMAND = "apiaccessnumbers";
const DBACCESSNUMBERSCOMMAND = "dbaccessnumbers";
/**
 *  @function openStatsPanel
 *  @param {boolean} true -> visible false -> hide
 * 
 *  visible or hide "APIACCESSNUMBERS" and "#plot"
 */
const openStatsPanel = (b, type) => {
    if (b) {
        const dataurls = scenario['analyzed-data-collect-url'];
        /*
            check for existing Jetelina's suggestion
        */
        if (type == APIACCESSNUMBERSCOMMAND) {
            getAjaxData(dataurls[4]);
        } else if (type == DBACCESSNUMBERSCOMMAND) {
            getAjaxData(dataurls[5]);
        }
    } else {
        hideApiAccessNumbersList();
        //$(APIACCESSNUMBERS).hide();
        $(CHARTPANEL).hide();
    }
}
/**
 * @function isVisibleApiAccessNumbers
 * @returns {boolean}  true -> visible, false -> invisible
 * 
 * checking "APIACCESSNUMBERS" is visible or not
 */
const isVisibleApiAccessNumbers = () => {
    let ret = false;
    if ($(APIACCESSNUMBERS).is(":visible")) {
        ret = true;
    }

    return ret;
}
/**
 * @function isVisibleChartPanel
 * @returns {boolean}  true -> visible, false -> invisible
 * 
 * checking "#plot" is visible or not
 */
const isVisibleChartPanel = () => {
    let ret = false;
    if ($(CHARTPANEL).is(":visible")) {
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
const isVisiblePerformanceReal = () => {
    let ret = false;
    if ($("#performance_real").is(":visible")) {
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
const isVisiblePerformanceTest = () => {
    let ret = false;
    if ($("#performance_test").is(":visible")) {
        ret = true;
    }

    return ret;
}
/**
 * @function statsPanelFunctions
 * @param {string} ut  chat message by user 
 * @returns {string}  answer chat message by Jetelina
 * 
 * Exectute some functions ordered by user chat input message
 */
const statsPanelFunctions = (ut) => {
    let m = IGNORE;

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
        if (inScenarioChk(ut, 'cond-api-access-numbers-list-show-cmd')) {
            cmd = APIACCESSNUMBERSCOMMAND;
        } else if (inScenarioChk(ut, 'cond-db-access-numbers-chart-show-cmd')) {
            cmd = DBACCESSNUMBERSCOMMAND;
        }
        /*
        } else if (inScenarioChk(ut, 'cond-sql-performance-graph-show-cmd')) {
            if (isSuggestion) {
                cmd = "performance";
            } else {
                cmd = "no_suggestion";
            }
        } else if (inScenarioChk(ut, 'confirmation-sentences-cmd') && isSuggestion) {
            cmd = "performance";
        }
        */
    }

    /*
        Tips:
            cmd
                'graph': show 'api access numbers' graph
                'performance: show the result of analyzing sql exection on test db.
                              this cmd can execute in the case of being a suggestion.
    */
    if (-1 < $.inArray(cmd, [APIACCESSNUMBERSCOMMAND, DBACCESSNUMBERSCOMMAND])) {
        openStatsPanel(true, cmd);
    }

    switch (cmd) {
        case APIACCESSNUMBERSCOMMAND:
            showSomethingMsgPanel(false);
            $(APIACCESSNUMBERS).show().draggable();

            m = chooseMsg('cond-graph-show-msg', "", "");
            break;
        case DBACCESSNUMBERSCOMMAND:
            showSomethingMsgPanel(false);
            $(CHARTPANEL).show().draggable();

            m = chooseMsg('cond-graph-show-msg', "", "");
            break;
        /*
        case 'performance':
            if (isVisibleApiAccessNumbers()) {
                $(APIACCESSNUMBERS).hide();
            }

            if (isVisiblePerformanceReal()) {
                $("#performance_real").hide();
            }

            $(CHARTPANEL).show().animate({
                 top: "5%",
                 left: "-5%"
             }, ANIMATEDURATION);
            $("#performance_test").show().draggable().animate({
                top: "20%", //-50%",
                left: "20%" //"50%"
            }, ANIMATEDURATION).draggable('disable');

            showSomethingMsgPanel(true);
            m = chooseMsg('cond-graph-show-msg', "", "");
            break;
        case 'no_suggestion':
            m = chooseMsg('cond-no-suggestion-msg', "", "");
            break;
        */
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
 * @param {string} type  'ac'-> access numbers in each api  'db'-> access numbers in each database  'sp" -> access nubmers and execution speed in each api
 * @return {boolean} true -> exists 'Access vs Combination data'  false-> not exists it
 * set data to a graph of creating by plot.js. data and 'type' are passed by getAjaxData() in jetelinalib.js  
 * 
 * Attention:
 *    this function expects the json data form alike
 *      - api access numbers
 *      {"Jetelina:[{"Jetelina":[{"apino":"js4","access_numbers":1},{"apino":"js24","access_numbers":1},...],"date":"2025-01-15","result":true},{"Jetelina":[{......}]},...],"result":true}
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
            if (key == "Jetelina" && o[key].length > 0) { // first json "Jetelina" name field
                // access vs combination
                let apino = [];
                let access_count = [];
                let dbaccessnumbers_chart_values = [];
                let dbaccessnumbers_chart_labels = [];
                /*
                    Tips:
                        api access data list has possibility to redraw sometimes, therefore the data should be holded.
                */
                preferent.apiaccesslistdata = [];
                let base_table_no = [];
                let combination_table = [];
                /* performance
                    apino,max,min,mean -> apino, use only 'mean' data
                */
                let apispeed_mean = [];
                let apispeed_max = [];
                let apispeed_min = [];
                let datadate = [];

                $.each(o[key], function (k, v) {
                    if (v != null) {
                        $.each(v, function (name, value) {
                            if (name == "date") {
                                datadate.push(value);
                            }

                            if (name == "Jetelina") { // in array field
                                $.each(value, function (na, va) {
                                    if (va != null) {
                                        if (type == "ac") {
                                            let existflg = false;
                                            /*
                                                Tips:
                                                    access numbers in each api  -> list figure
                                            */
                                            if (va != null) {
                                                if (0 < preferent.apiaccesslistdata.length) {
                                                    let ald = preferent.apiaccesslistdata;
                                                    for (let i = 0; i < ald.length; i++) {
                                                        if (ald[i][0] == va.apino) {
                                                            ald[i][1] += va.access_numbers;
                                                            existflg = true;
                                                        }
                                                    }
                                                }

                                                if (!existflg) {
                                                    preferent.apiaccesslistdata.push([va.apino, va.access_numbers, va.database]);
                                                }
                                            }
                                        } else if (type == "db") {
                                            /*
                                                Tips:
                                                    access numbers in each database -> pie chart
                                            */
                                            if (va != null) {
                                                let existflg = false;
                                                if (0 < dbaccessnumbers_chart_labels.length) {
                                                    let dbcl = dbaccessnumbers_chart_labels;
                                                    let dbcv = dbaccessnumbers_chart_values;
                                                    for (let i = 0; i < dbcl.length; i++) {
                                                        if (dbcl[i] == va.database) {
                                                            dbcv[i] += va.access_numbers;
                                                            existflg = true;
                                                        }
                                                    }
                                                }

                                                if (!existflg) {
                                                    dbaccessnumbers_chart_labels.push(va.database);
                                                    dbaccessnumbers_chart_values.push(va.access_numbers);
                                                }
                                            }
                                        } else if (type == "sp") {
                                            /*
                                                Tips:
                                                    access numbers / execution speed in each api -> 3D scatter plot
                                            */
                                        }
                                    }
                                });
                            } else if (name = "date") {

                            }
                        });
                    }
                });

                /*
                    Tips:
                        showing the data of start date and end date.
                */
                let datadate2 = [];
                for (let i = 0; i < datadate.length; i++) {
                    let d = new Date(datadate[i]);
                    datadate2.push(d);
                }

                let startdateEnddate = determindDateStart2End(datadate2);
                let startdate = startdateEnddate[0];
                let enddate = startdateEnddate[1];

                if (type == "ac") {
                    // list
                    $(`${APIACCESSNUMBERS} [name='between']`).text(`${startdate} - ${enddate}`);
                    showApiAccessNumbersList();
                } else {
                    // ploty graph
                    $(`${CHARTPANEL} [name='between']`).text(`${startdate} - ${enddate}`);
                    /*
                        Tips:
                        adjusting the plot.js execution time because it is depend on clients environment
                    */
                    setTimeout(function () {
                        if (type == "db") {
                            let d = [dbaccessnumbers_chart_labels, dbaccessnumbers_chart_values];
                            viewPlotlyChart(d, type);
                            //viewPerformanceGraph(apino, access_count, type);
                        } else if (type == "sp") {
                            viewPerformanceGraph(apino, mean, type);
                        }
                    }, 1000);
                }
            }
        });
    }

    return ret;
}
/**
 * @function showApiAccessNumbersList
 * 
 * show api access number data in DataTable 
 */
const showApiAccessNumbersList = () => {

    let tableoptions = {
        "paging": true,
        "info": false,
        "searching": true,
        "order": [1, 'desc'],
        "pagingType": "simple",
        "data": preferent.apiaccesslistdata
    }

    $(APIACCESSNUMBERSLIST).DataTable(tableoptions);
}
/**
 * @function hideApiAccessNumbersList
 * 
 * hide APIACCESSNUMBERS and destroy the DataTable()
 */
const hideApiAccessNumbersList = () => {
    $(APIACCESSNUMBERS).hide();
    $(APIACCESSNUMBERSLIST).DataTable().destroy();
}
/**
 * @function apiAccessNumbersListController
 * @param {string} cmd   typed string in jetelina chat box 
 * @returns {string} something message
 * 
 * api access numbers list controller. paging and search api order by chat box
 */
const apiAccessNumbersListController = (cmd) => {
    let t = $(APIACCESSNUMBERSLIST).DataTable();
    let ret = "";

    if (inScenarioChk(cmd, 'cond-apiaccessnumberslist-next-cmd')) {
        t.page("next").draw(false);
    } else if (inScenarioChk(cmd, 'cond-apiaccessnumberslist-prev-cmd')) {
        t.page("previous").draw(false);
    } else if (inScenarioChk(cmd, 'cond-apiaccessnumberslist-last-cmd')) {
        t.page("last").draw(false);
    } else if (inScenarioChk(cmd, 'cond-apiaccessnumberslist-first-cmd')) {
        t.page("first").draw(false);
    } else if (inScenarioChk(cmd, 'cond-apiaccessnumberslist-search-cmd')) {
        let sar = cmd.split(" ");
        for (let i = 0; i < sar.length; i++) {
            /*
                Tips:
                    this searching in DataTable works with both the api name and database name.
                    unfortunately, this code should be rewritten if new database were added.  :p
            */
            if (sar[i].match(/^ji|^js|^ju|^jd|^postgre|^mysq|^redi|^mongo/)) {
                t.search(sar[i]).draw(false);
            }
        }
    } else if (inScenarioChk(cmd, 'cond-apiaccessnumberslist-again-cmd')) {
        t.destroy();
        showApiAccessNumbersList();
    } else {
        ret = chooseMsg('waiting-next-msg', '', '');
    }

    if (!inScenarioChk(ret, 'waiting-next-msg')) {
        ret = chooseMsg('cond-graph-show-msg', '', '');
    }

    return ret;
}
/**
 * @function viewPlotlyChart
 * @param {Float64Array} d  array of any data 
 * @param {string} type  'db'-> database access numbers
 *
 * show plotly chart 
 */
const viewPlotlyChart = (basedata, type) => {
    let data;
    let layout;

    if (type == "db") {
        data = [
            {
                labels: basedata[0],
                values: basedata[1],
                type: 'pie'
            }
        ];

        layout = {
            height: 400,
            width: 500,
            font: {
                color: ' #f1ef46',
                style: 'italic',
                size: 10,
                shadow: '0 0 10px rgb(193, 206, 194), 0 0 15px #f1ef46'
            },
            paper_bgcolor: 'rgba(109, 98, 226, 0.15)'
        };
    } else {
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
    }

    /*
        let paper_bgc = 'rgb(112,128,144)';
        let font_col = 'rgb(255,255,255)';
        if (type == 'test') {
            paper_bgc = 'rgb(0,129,104)';//'rgb(240,230,140)'
            //        font_col = 'rgb(255,0,0)';
        }
    
        let title = "exection speed";
        if (type == "access") {
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
    */
    if (type == "db") {
        //        Plotly.react('db_access_numbers_chart', data, layout);
        Plotly.react('plot_graph', data, layout);
    } else {
        Plotly.newPlot('performance_test_graph', data, layout);
    }
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

    if (type == "real" || type == "access") {
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
    } else {
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


        data = [real_data, test_data];
    }


    let paper_bgc = 'rgb(112,128,144)';
    let font_col = 'rgb(255,255,255)';
    if (type == 'test') {
        paper_bgc = 'rgb(0,129,104)';//'rgb(240,230,140)'
        //        font_col = 'rgb(255,0,0)';
    }

    let title = "exection speed";
    if (type == "access") {
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

    if (type == "access") {
        $(APIACCESSNUMBERS).show();
        //        Plotly.newPlot('api_access_numbers_graph', data, layout);
        Plotly.react('api_access_numbers_graph', data, layout);
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