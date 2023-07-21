const conditionPanelFunctions = (ut) => {
    let m = "";

    if (presentaction == null || presentaction.length == 0) {
        presentaction.push('cond');
    }

    if (ut.indexOf('func') != -1) {
        delete preferent;
        delete presentaction;
        stage = 'chose_func_or_cond';
        chatKeyDown(ut);
    } else {
        // 優先オブジェクトがあればそれを使う
        let cmd = getPreferentPropertie('cmd');

        if (debug) {
            console.log("conditonpanel.js conditonPanelFunctions() starts with : ", ut);
            console.log("conditonpanel.js conditonPanelFunctions() cmd : ", cmd);
        }

        if (cmd == null || cmd.length <= 0) {
            if ($.inArray(ut, scenario['6cond-graph-show-keywords']) != -1) {
                cmd = "graph";
            } else if ($.inArray(ut, scenario['6cond-performance-graph-show-keywords']) != -1) {
                cmd = "performance";
            }
        }

        switch (cmd) {
            case 'graph':
                /*
                    #plotは3Dグラフをグリグリ回転させるので、divパネル自体は
                    draggableにはしないでおく。
                */
                $("#plot").show().animate({
                    top: "5%",
                    left: "-5%"
                }, animateDuration);
                /*
                    このグラフは2DだからdivパネルをdraggableでもOK
                */
                $("#performance_real").show().draggable().animate({
                    top: "-50%",
                    left: "50%"
                }, animateDuration);

                m = chooseMsg('6cond-graph-show', "", "");
                break;
            case 'performance':
                /*
                    このグラフは2DだからdivパネルをdraggableでもOK
                */
                $("#performance_test").show().draggable().animate({
                    top: "-70%",
                    left: "30%"
                }, animateDuration);

                m = chooseMsg('6cond-graph-show', "", "");
                break;
            default:
                m = "";//ここは後処理にお任せ
                break;
        }
    }

    return m;
}

const setGraphData = (o, type) => {
    if (o != null) {
        Object.keys(o).forEach(function (key) {
            //’Jetelina’のvalueはオブジェクトになっているからこうしている  name=>key value=>o[key]
            if (key == "Jetelina" && o[key].length > 0) {
                // access vs combination
                let base_table_name = [];
                let base_table_no = [];
                let combination_table = [];
                let access_count = [];
                /* performance
                    apino,max,min,mean -> apino, meanだけを使う。
                */
                let apino = [];
                let mean = [];

                $.each(o[key], function (k, v) {
                    if (v != null) {
                        $.each(v, function (name, value) {
                            if (name == "apino") {
                                apino.push(value);
                            } else if (name == "combination") {
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
                            } else if (name == "access_number") {
                                access_count.push(value);// table access normarize no -> z axis
                            } else if (name == "mean") {
                                mean.push(value);
                            }
                        });
                    }
                });

                //plot.jsのレンダリング実行速度がクライアントによって違うので、ここで遅延処理して辻褄を合わせる
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
}

const viewPerformanceGraph = (apino, mean, type) => {
    var data = [
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
            title: 'exection speed'
        }
    };

    if (type == "real") {
        Plotly.newPlot('performance_real_graph', data, layout);
    } else {
        Plotly.newPlot('performance_test_graph', data, layout);
    }
}

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