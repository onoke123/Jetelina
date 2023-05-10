let sad = false;//getsqlanalyzerdataは一回だけ呼び出すので、getAjaxData()内でこれをtrueに設定する
const conditionPanelFunctions = (ut,cmd) => {
    if( !sad ){
        getAjaxData("/getsqlanalyzerdata");
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
                            if( name == "column_name" ){
                                base_table_name.push(value);
                            }else if( name == "combination" ){
                                combination_table.push(value);
                            }else if( name == "access_number" ){
                                access_count.push(value);
                            }
//                            console.log("json data: ", name, value);
                        });
                    }
                })

                viewGraph(base_table_name,base_table_no,combination_table,access_count);

            }
        });

    }


}

const viewGraph = (bname,bno,ct,ac) => {
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