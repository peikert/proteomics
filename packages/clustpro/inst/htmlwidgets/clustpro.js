HTMLWidgets.widget({
    name: "clustpro",
    type: "output",

    initialize: function(el, width, height) {
        console.log("Last Updated: August 7th [11:50 AM] (numair.mansur@gmail.com)");
        debugger;
        return {
            lastTheme: null,
            lastValue: null
        };

    },

    renderValue: function(el, x, instance) {
        debugger;
        var rowNewickString = x.dendnw_row[0];
        var colNewickString = x.dendnw_col[0];
        x.matrix.data = [].concat.apply([],x.matrix.data); // Flattening the data array.
        this.doRenderValue(el, x, rowNewickString, colNewickString, instance, null);
    },

    resize: function(el, width, height, instance) {
        d3.select(el).select("svg")
            .attr("width", width)
            .attr("height", height);
//
        instance.force.size([width, height]).resume();
        this.doRenderValue(el, instance.lastValue, instance);
    },


    doRenderValue: function(el, x, rowNewickSting, colNewickString, instance, newMerged){
        debugger;
        var self = this;
        instance.lastValue = x;

        // el.innerHTML = "";
        var merged = [];
        var dataMatrixIndex = 0;
        // coloring information.
        for(var i=0; i < x.colors.data.length; i++)
        {
            for(var j=0; j<x.colors.data[i].length; j++)
            {
                merged.push({
                    label: x.matrix.data[dataMatrixIndex++].toString(),
                    color: this.hextorgb(x.colors.data[i][j])
                });
            }
        }
        if(newMerged == null)
        {
            x.matrix.merged = merged;
        }
        else
        {
            x.matrix.merged = newMerged;
        }

        var heatMapObject = clustpro(el, x, x.options);
        },

    hextorgb: function(hex){
        var hex2 = hex.replace('#','');
        var bigint = parseInt(hex2, 16);
        var r = (bigint >> 16) & 255;
        var g = (bigint >> 8) & 255;
        var b = bigint & 255;
        return "rgba(" + r + "," + g + "," + b + ",1)";
    }

});