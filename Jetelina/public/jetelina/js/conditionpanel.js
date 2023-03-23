function getrandom(num, mul) {
    var value = []
    for (i = 0; i <= num; i++) {
        rand = Math.random() * mul;
        value.push(rand);
    }
    return value;
}

var data = [
    /*{
        opacity: 0.4, type: 'scatter3d',
        x: getrandom(50, 75),
        y: getrandom(50, 75),
        z: getrandom(50, 75),
        mode: 'markers'
    },
    {
        opacity: 0.5,
        type: 'scatter3d',
        x: getrandom(75, 75),
        y: getrandom(75, 75),
        z: getrandom(75, 75),
        mode: 'markers'
    },*/
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
