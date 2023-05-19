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

        if (debug){
            console.log("conditonpanel.js conditonPanelFunctions() starts with : ", ut);
            console.log("conditonpanel.js conditonPanelFunctions() cmd : ", cmd);
        }        

        if (cmd == null || cmd.length <= 0) {
            for (let i = 0; i < scenario['6cond-graph-show-keywords'].length; i++) {
                if (ut.indexOf(scenario['6cond-graph-show-keywords'][i]) != -1) {
                    cmd = "graph";
                }
            }
        }

        switch (cmd) {
            case 'graph':
                $("#plot").show();
                m = chooseMsg('6cond-graph-show', "", "");
                break;
            default:
                m = "";//ここは後処理にお任せ
                break;
        }
    }

    return m;
}

const setGraphData = (o) => {
    if (o != null) {
        Object.keys(o).forEach(function (key) {
            //’Jetelina’のvalueはオブジェクトになっているからこうしている  name=>key value=>o[key]
            if (key == "Jetelina" && o[key].length > 0) {
                let base_table_name = [];
                let base_table_no = [];
                let combination_table = [];
                let access_count = [];
                $.each(o[key], function (k, v) {
                    if (v != null) {
                        $.each(v, function (name, value) {
                            if (name == "column_name") {
                                base_table_name.push(value);// original table column name -> point text
                            } else if (name == "combination") {
                                base_table_no.push(value[0]);// original table no -> x axis
                                let pn = 0;
                                if( 2<value.length ){
                                    let cbn = 0;
                                    for( let i=2; i<value.length; i++ ){
                                        cbn += value[i];
                                    }

                                    pn = cbn;
                                }else if( value.length == 2 ){
                                    pn = value[1];
                                }

                                combination_table.push(pn);// table combination no -> y axis                                    
                            } else if (name == "access_number") {
                                access_count.push(value);// table access normarize no -> z axis
                            }
                        });
                    }
                });

                //plot.jsのレンダリング実行速度がクライアントによって違うので、ここで遅延処理して辻褄を合わせる
                setTimeout(function () {
                    viewGraph(base_table_name, base_table_no, combination_table, access_count);
                }, 1000);

            }
        });

    }


}

const viewGraph = (bname, bno, ct, ac) => {
    console.log("bname: ", bname);
    console.log("bno: ", bno);
    console.log("ct: ", ct);
    console.log("at: ", ac);
    var data = [
        {
            opacity: 0.5,
            type: 'scatter3d',
            text: bname,
            x: bno,
            y: ct,
            z: ac,
            /*
            x: [1, 5, 6],
            y: [1, 2, 3],
            z: [1, 3, 8],
            text: ["a", "b", "c"],
        */
            mode: 'markers+text'
        }
    ];
    var layout = {
        plot_bgcolor: "rgb(0,0,0)",
        paper_bgcolor: "rgb(0,0,0)",
        scene: {
            xaxis: {
                backgroundcolor: "rgb(255,0,0)",
                showbackground: false,
                gridcolor: "rgb(0,153,153)"
            },
            yaxis: {
                backgroundcolor: "rgb(255,0,0)",
                showbackground: false,
                gridcolor: "rgb(0,153,153)"
            },
            zaxis: {
                backgroundcolor: "rgb(255,0,0)",
                showbackground: false,
                gridcolor: "rgb(0,153,153)"
            }
        }
    };

    Plotly.newPlot('plot', data, layout);
}