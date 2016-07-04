HTMLWidgets.widget({

    name: "clustpro",

    type: "output",

    initialize: function(el, width, height) {
       d3.select(el).append("svg")
           .attr("width", width)
           .attr("height", height);
        return {
            force: d3.layout.force()
        }

    },

    renderValue: function(el, x, instance) {
        this.doRenderValue(el, x, instance);
    },

    resize: function(el, width, height, instance) {
        d3.select(el).select("svg")
            .attr("width", width)
            .attr("height", height);
//
        instance.force.size([width, height]).resume();
        this.doRenderValue(el, instance.lastValue, instance);
    },


    doRenderValue: function(el, x, instance){
        var heatMapObject = clustpro(el, x)
        }
});
