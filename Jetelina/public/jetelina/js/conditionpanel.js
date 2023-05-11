const conditionPanelFunctions = (ut) => {
    if (ut.indexOf('func') != -1) {
        delete preferent;
        delete presentaction;
        stage = 'chose_func_or_cond';
        chatKeyDown(ut);
    } else {
        /*
            一度getsqlanalyzerdataが呼ばれたら、そのデータはすでにgraphにセットされている。
            このデータはあまり変わることはないので頻繁に呼び出す必要はない。
            そのため、一度呼び出したらsadフラグを設定して、これを判定として利用する。
        */
        if (!sad) {
            getAjaxData("/getsqlanalyzerdata");
        }

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

        return m;
    }
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
                                base_table_name.push(value);
                            } else if (name == "combination") {
                                combination_table.push(value);
                            } else if (name == "access_number") {
                                access_count.push(value);
                            }
                            //                            console.log("json data: ", name, value);
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
    var data = [
        {
            opacity: 0.5,
            type: 'scatter3d',
            x: [1, 5, 6],
            y: [1, 2, 3],
            z: [1, 3, 8],
            text: ["a", "b", "c"],
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