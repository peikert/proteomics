/** Last Updated: 17th December
    Version: 0.0.23
*/
function clustpro(selector, data, options, location_object_array, cluster_change_rows, cluster,
    rowDendLinesListner, colDendLinesListner, sidebar_options, sideBarDimensions, 
        workSpaceDimensions, innerworkSpaceDimensions, randomIdString) {
    console.log("-- Entered CLUSTPRO() --");
    debugger;
    // ==== BEGIN HELPERS =================================
    function htmlEscape(str) {
        return (str + "").replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
    }

    // Given a list of widths/heights and a total width/height, provides
    // easy access to the absolute top/left/width/height of any individual
    // grid cell. Optionally, a single cell can be specified as a "fill"
    // cell, meaning it will take up any remaining width/height.
    // rows and cols are arrays that contain numeric pixel dimensions,
    // and up to one "*" value.s
    function GridSizer(widths, heights, /*optional*/ totalWidth, /*optional*/ totalHeight) {
        this.widths = widths;
        this.heights = heights;
        var fillColIndex = null;
        var fillRowIndex = null;
        var usedWidth = 0;
        var usedHeight = 0;
        var i;
        for (i = 0; i < widths.length; i++) {
            if (widths[i] === "*") {
                if (fillColIndex !== null) {
                    throw new Error("Only one column can be designated as fill");
                }
                fillColIndex = i;
            } else {
                usedWidth += widths[i];
            }
        }
        if (fillColIndex !== null) {
            widths[fillColIndex] = totalWidth - usedWidth;
        } else {
            if (typeof (totalWidth) === "number" && totalWidth !== usedWidth) {
                throw new Error("Column widths don't add up to total width");
            }
        }
        for (i = 0; i < heights.length; i++) {
            if (heights[i] === "*") {
                if (fillRowIndex !== null) {
                    throw new Error("Only one row can be designated as fill");
                }
                fillRowIndex = i;
            } else {
                usedHeight += heights[i];
            }
        }
        if (fillRowIndex !== null) {
            heights[fillRowIndex] = totalHeight - usedHeight;
        } else {
            if (typeof (totalHeight) === "number" && totalHeight !== usedHeight) {
                throw new Error("Column heights don't add up to total height");
            }
        }
    }

    GridSizer.prototype.getCellBounds = function (x, y) {
        if (x < 0 || x >= this.widths.length || y < 0 || y >= this.heights.length)
            throw new Error("Invalid cell bounds");

        var left = 0;
        for (var i = 0; i < x; i++) {
            left += this.widths[i];
        }

        var top = 0;
        for (var j = 0; j < y; j++) {
            top += this.heights[j];
        }

        return {
            width: this.widths[x],
            height: this.heights[y],
            top: top,
            left: left
        }
    }
    function xaxis_height_calculate(value) {
        return 120;
    }
    // ==== END HELPERS ===================================

    var el = d3.select(selector);

    var bbox = el.node().getBoundingClientRect();

    var Controller = function () {
        this._events = d3.dispatch("highlight", "datapoint_hover", "transform");
        this._highlight = { x: null, y: null };
        this._datapoint_hover = { x: null, y: null, value: null };
        this._transform = null;
    };
    (function () {
        this.highlight = function (x, y) {
            // Copy for safety
            if (!arguments.length) return { x: this._highlight.x, y: this._highlight.y };

            if (arguments.length == 1) {
                this._highlight = x;
            } else {
                this._highlight = { x: x, y: y };
            }
            this._events.highlight.call(this, this._highlight);
        };

        this.datapoint_hover = function (_) {
            if (!arguments.length) return this._datapoint_hover;

            this._datapoint_hover = _;
            this._events.datapoint_hover.call(this, _);
        };

        this.transform = function (_) {
            if (!arguments.length) return this._transform;
            this._transform = _;
            this._events.transform.call(this, _);
        };

        this.on = function (evt, callback) {
            this._events.on(evt, callback);
        };
    }).call(Controller.prototype);

    var controller = new Controller();

    // Set option defaults
    var opts = {};
    options = options || {};
    opts.width = innerworkSpaceDimensions.width;
    opts.height = innerworkSpaceDimensions.height;
    opts.xclust_height = options.xclust_height || workSpaceDimensions.height * 0.12; // Issue - 31
    opts.yclust_width = options.yclust_width || opts.width * 0.12;
    opts.link_color = opts.link_color || "#AAA";

    // Change here
    opts.xaxis_height = xaxis_height_calculate(2); // CHANGE THE HEIGHT OF THE X-AXIS FROM HERE.
    // CALCULATE THE VALUE OF THE HEIGHT WITH A HELPER FUNCTION.

    opts.yaxis_width = options.yaxis_width[0] || 120;
    opts.yaxis_width = options.yaxis_width[0] || 120;
    opts.axis_padding = options.axis_padding || 6;
    opts.show_grid = options.show_grid[0];
    if (typeof (opts.show_grid) === 'undefined') {
        opts.show_grid = true;
    }
    opts.brush_color = options.brush_color[0] || "#0000FF";
    opts.xaxis_font_size = options.xaxis_font_size[0];
    opts.yaxis_font_size = options.yaxis_font_size[0];
    opts.anim_duration = options.anim_duration[0];
    if (typeof (opts.anim_duration) === 'undefined') {
        opts.anim_duration = 500;
    }

    if (!data.dendnw_row) {
        opts.yclust_width = 0;
    }
    if (!data.dendnw_col) {
        opts.xclust_height = 0;
    }

    var gridSizer = new GridSizer(
        [opts.yclust_width, "*", opts.yaxis_width],
        [opts.xclust_height, "*", opts.xaxis_height],
        opts.width,
        opts.height
    );

    var colormapBounds = gridSizer.getCellBounds(1, 1);
    var colDendBounds = gridSizer.getCellBounds(1, 0);
    // coldDendBounds should be 10 % of the outer workspace area or something ?
    var rowDendBounds = gridSizer.getCellBounds(0, 1);
    var yaxisBounds = gridSizer.getCellBounds(2, 1);
    var xaxisBounds = gridSizer.getCellBounds(1, 2);
    var zoomAreaBounds = gridSizer.getCellBounds(1, 1); // To be one of the things returned by this function
    // Hack Zoom Area Bound. Height and width should be 20 % bigger.
    zoomAreaBounds.height = zoomAreaBounds.height * 5;
    zoomAreaBounds.width = zoomAreaBounds.width * 5;

    xaxisBounds.height = 200;

    function cssify(styles) {
        return {
            position: "absolute",
            top: styles.top + "px",
            left: styles.left + "px",
            width: styles.width + "px",
            height: styles.height + "px"
        };
    }

    // Create DOM structure
    (function () {
        debugger;
        var inner = el.append("div").attr("id", "inner").classed("inner", true);
        var sidebar = inner.append("div").attr( "id", "myTopnav"+randomIdString).classed("topnav"+randomIdString, true).style(cssify(sideBarDimensions));
        var workspace = inner.append("div").attr("id","workspace"+randomIdString).classed("workspace"+randomIdString, true).style(cssify(workSpaceDimensions));
        var workspaceInner = workspace.append("div").attr("id", "workspaceinner"+randomIdString).classed("workspaceinner"+randomIdString, true).style(cssify(innerworkSpaceDimensions));
        var colDend = workspaceInner.append("svg").classed("dendrogram colDend", true).style(cssify(colDendBounds));
        // update the dimensions of row dendogram to compensate for the side bar.   GITHUB ISSUE # 13
        rowDendBounds.width = rowDendBounds.width - (sideBarDimensions.width * 0.7); 
        rowDendBounds.left = sideBarDimensions.width * 0.7;
        var rowDend = workspaceInner.append("svg").classed("dendrogram rowDend", true).style(cssify(rowDendBounds));
        var colmap = workspaceInner.append("svg").attr("id", "colormap"+randomIdString).classed("colormap", true).style(cssify(colormapBounds));
        var xaxis = workspaceInner.append("svg").attr("id", "xaxis"+randomIdString).classed("axis xaxis", true).style(cssify(xaxisBounds));
        var yaxis = workspaceInner.append("svg").attr("id", "yaxis").classed("axis yaxis", true).style(cssify(yaxisBounds));
        
        // Hack the width of the x-axis to allow x-overflow of rotated labels; the
        // QtWebkit viewer won't allow svg elements to overflow:visible.
        xaxis.style("width", (opts.width - opts.yclust_width) + "px");
        xaxis
            .append("defs")
            .append("clipPath").attr("id", "xaxis-clip")
            .append("polygon")
            .attr("points", "" + [
                [0, 0],
                [xaxisBounds.width, 0],
                [xaxisBounds.width + yaxisBounds.width, xaxisBounds.height],
                [0, xaxisBounds.height]
            ]);
        xaxis.node(0).setAttribute("clip-path", "url(#xaxis-clip)");

        inner.on("click", function () {
            controller.highlight(null, null);
        });
        controller.on('highlight.inner', function (hl) {
            inner.classed('highlighting',
                typeof (hl.x) === 'number' || typeof (hl.y) === 'number');
        });

        // Add listener on the scroll bars, so that each time the workspace div
        // is changed, the updated scroll values are sent to the shiny app.
        // See issue 47
        
        // +++++++++++ TODO ++++++++++++++
        // When the R side is implemented, integrate the scroll values coming from the shiny app

        document.getElementById("workspace"+randomIdString).onscroll = function(){
            var left = document.getElementById("workspace"+randomIdString).scrollLeft;
            var right = document.getElementById("workspace"+randomIdString).scrollTop;
            if (HTMLWidgets.shinyMode) {
                    Shiny.onInputChange(el.id+"_scrollParameters", [left,top] ); // Return scroll bar information to the shiny app
                }
        };
        



    })();
    data.matrix.tooltip = data.tooltip; // Temporary solution
    console.log("       [Generating Color Map]");
    var colormap = colormap(el.select('svg.colormap'), data.matrix, colormapBounds.width, colormapBounds.height, data.tooltip);
    console.log("       [ColorMap generated]");
    columnNames = data.matrix.cols;
    console.log("       [Generating Xaxis]");
    var xax = axisLabels(el.select('svg.xaxis'), columnNames, true, xaxisBounds.width, xaxisBounds.height, opts.axis_padding);
    console.log("       [Xaxis generated]");
    console.log("       [Generating Yaxis]");
    if (sidebar_options.rowLabels) {
        var yax = axisLabels(el.select('svg.yaxis'), data.rows || data.matrix.rows, false, yaxisBounds.width, yaxisBounds.height, opts.axis_padding);
    }
    console.log("       [Yaxis generated]");
    if (data.dendnw_row[0] != null) {
        console.log("       [Generating Row Dendogram]");
        var row = dendogram(el.select('svg.rowDend'), false, rowDendBounds.width, rowDendBounds.height,
            opts.axis_padding,  /*no of cols*/ data.matrix.cols.length, cluster, data.dendnw_row[0], columnNames);
        console.log("       [Row Dendogram generated]");
    }

    if (data.dendnw_col[0] != null) {
        console.log("       [Generating Column Dendogram]");
        var col = dendogram(el.select('svg.colDend'), true, colDendBounds.width, colDendBounds.height,
            opts.axis_padding, data.matrix.cols.length, cluster, data.dendnw_col[0], columnNames);
        console.log("       [Column Dendogram Generated]");
    }


    function colormap(svg, data, width, height, tooltip) {
        console.log("           --Entered colormap() --");
        // Check for no data
        if (data.length === 0)
            return function () { };

        if (!opts.show_grid) {
            svg.style("shape-rendering", "crispEdges");
        }
        var cols = data.dim[1];
        var rows = data.dim[0];
        var merged = data.merged;
        links = data.tooltip.link; // temp solution for the double click function.
        var tooltip = tooltip;
        var x = d3.scale.linear().domain([0, cols]).range([0, width]);
        var y = d3.scale.linear().domain([0, rows]).range([0, height]);
        var tip = d3.tip() //HTML of the tip
            .attr('class', 'clustpro-tip')
            .attr('id', 'clustpro-tip')
            .html(function (d, i) {
                var html_string = "<table>" +
                    // The constant 3 lines that will always be in the tooltip.
                    "<tr><th align=\"right\">Row</th><td>" + htmlEscape(data.rows[d.row]) + "</td></tr>" +
                    "<tr><th align=\"right\">Column</th><td>" + htmlEscape(data.cols[d.col]) + "</td></tr>" +
                    "<tr><th align=\"right\">Value</th><td>" + htmlEscape(d.label) + "</td></tr>";
                // Grab more lines to put into the tooltip.
                Object.keys(data.tooltip).forEach(function (key) {
                    html_string = html_string + "<tr><th align=\"right\">" + key + "</th><td>" + htmlEscape(data.tooltip[key][d.row]) + "</td></tr>";
                });
                html_string = html_string + "</table>";
                // return "<table>" +
                //     "<tr><th align=\"right\">Row</th><td>" + htmlEscape(data.rows[d.row]) + "</td></tr>" +
                //     "<tr><th align=\"right\">Column</th><td>" + htmlEscape(data.cols[d.col]) + "</td></tr>" +
                //     "<tr><th align=\"right\">Value</th><td>" + htmlEscape(d.label) + "</td></tr>" +
                //     "<tr><th align=\"right\">Link</th><td>" + htmlEscape(data.tooltip.link[d.row]) + "</td></tr>" +
                //     "<tr><th align=\"right\">Description</th><td>" + htmlEscape(data.tooltip.description[d.row]) + "</td></tr>" +
                //     "</table>";
                return html_string;
            })
            .direction("se")
            .style("position", "fixed");

        var brush = d3.svg.brush()
            .x(x)
            .y(y)
            .clamp([true, true])
            .on('brush', function () {
                var extent = brush.extent();
                extent[0][0] = Math.floor(extent[0][0]);   // Fix for issue # 6
                extent[0][1] = Math.round(extent[0][1]);
                extent[1][0] = Math.ceil(extent[1][0]);   // Fix for issue # 6
                extent[1][1] = Math.round(extent[1][1]);
                d3.select(this).call(brush.extent(extent));
            })
            .on('brushend', function () { // Select an area in the color map
                if (brush.empty()) {
                    controller.transform({
                        scale: [1, 1],
                        translate: [0, 0],
                        extent: [[0, 0], [cols, rows]]
                    });
                } else {
                    var tf = controller.transform();
                    var ex = brush.extent();
                    var scale = [
                        cols / (ex[1][0] - ex[0][0]),
                        rows / (ex[1][1] - ex[0][1])
                    ];
                    var translate = [
                        ex[0][0] * (width / cols) * scale[0] * -1,
                        ex[0][1] * (height / rows) * scale[1] * -1
                    ];
                    controller.transform({ scale: scale, translate: translate, extent: ex });
                }
                brush.clear();
                d3.select(this).call(brush).select(".brush .extent")
                    .style({ fill: opts.brush_color, stroke: opts.brush_color });
            });

        svg = svg
            .attr("width", width)
            .attr("height", height);
        var rect = svg.selectAll("rect").data(merged);
        rect.enter().append("rect").classed("datapt", true)
            .property("colIndex", function (d, i) { return i % cols; })
            .property("rowIndex", function (d, i) { return Math.floor(i / cols); })
            .property("value", function (d, i) { return d.value; })
            .attr("fill", function (d) {
                if (!d.color) {
                    return "transparent";
                }
                return d.color;
            });
        rect.exit().remove();
        rect.append("title")
            .text(function (d, i) { return d.label; });

        rect.call(tip);

        var spacing;
        if (typeof (opts.show_grid) === 'number') {
            spacing = opts.show_grid;
        } else if (!!opts.show_grid) {
            spacing = 0.25;
        } else {
            spacing = 0;
        }

        function draw(selection) {
            location_object_array = [];
            d3.selectAll("#line"+randomIdString).remove();

            selection
                .attr("x", function (d, i) {
                    return x(i % cols);
                })
                .attr("y", function (d, i) {
                    // Cluster line drawing
                    for (var j = 0; j < cluster_change_rows.length; j++) {
                        if (selection[0][i].rowIndex == cluster_change_rows[j].ylocation) {
                            location_object_array.push({
                                begin: null, end: y(Math.floor(i / cols)),
                                cluster: cluster_change_rows[j].cluster, rowInformation: cluster_change_rows[j].rowInformation
                            });
                            svg.append("line")
                                .attr("id", "line"+randomIdString)
                                .attr("x1", 0)
                                .attr("y1", y(Math.floor(i / cols)))
                                .attr("x2", selection[0][i].width.animVal.value * (cols))
                                .attr("y2", y(Math.floor(i / cols)))
                                .attr("stroke", "black")
                                .attr("stroke-width", 1.25)
                                .attr("fill", "none");
                        }
                    }
                    // End of line Drawing.
                    return y(Math.floor(i / cols));
                })
                .attr("width", (x(1) - x(0)) - spacing)
                .attr("height", (y(1) - y(0)) - spacing);
        }

        draw(rect);
        controller.on('transform.colormap', function (_) {
            x.range([_.translate[0], width * _.scale[0] + _.translate[0]]);
            y.range([_.translate[1], height * _.scale[1] + _.translate[1]]);
            draw(rect.transition().duration(opts.anim_duration).ease("linear"));
        });


        var brushG = svg.append("g")
            .attr('class', 'brush')
            .call(brush)
            .call(brush.event);

        brushG.select("rect.background")
            .on("mouseenter", function () {
                tip.style("display", "block");
            })
            .on("mousemove", function () {
                var e = d3.event;
                var offsetX = d3.event.offsetX;
                var offsetY = d3.event.offsetY;
                if (typeof (offsetX) === "undefined") {
                    // Firefox 38 and earlier
                    var target = e.target || e.srcElement;
                    var rect = target.getBoundingClientRect();
                    offsetX = e.clientX - rect.left,
                        offsetY = e.clientY - rect.top;
                }

                var col = Math.floor(x.invert(offsetX));
                var row = Math.floor(y.invert(offsetY));
                var label = merged[row * cols + col].label;
                tip.show({ col: col, row: row, label: label }).style({
                    top: d3.event.clientY + 15 + "px",
                    left: d3.event.clientX + 15 + "px",
                    opacity: 0.9
                });
                controller.datapoint_hover({ col: col, row: row, label: label });
            })
            .on("mouseleave", function () {
                tip.hide().style("display", "none");
                controller.datapoint_hover(null);
            })
            .on("dblclick", function () {
                debugger;
                var e = d3.event;
                var offsetX = d3.event.offsetX;
                var offsetY = d3.event.offsetY;
                if (typeof (offsetX) === "undefined") {
                    // Firefox 38 and earlier
                    var target = e.target || e.srcElement;
                    var rect = target.getBoundingClientRect();
                    offsetX = e.clientX - rect.left,
                        offsetY = e.clientY - rect.top;
                }
                var col = Math.floor(x.invert(offsetX));
                var row = Math.floor(y.invert(offsetY));
                var link = links[row];                
                if (HTMLWidgets.shinyMode) {
                    Shiny.onInputChange(el.id+"_clickedCell", [row,col] ); // Return clicked cell information to the shiny app
                }
                window.open(link);
            });


        controller.on('highlight.datapt', function (hl) {
            rect.classed('highlight', function (d, i) {
                return (this.rowIndex === hl.y) || (this.colIndex === hl.x);
            });
        });
    }

    function axisLabels(svg, data, rotated, width, height, padding) {
        console.log("           --Entered axisLabel() --");
        debugger;
        svg = svg.append('g');
        // The data variable is either cluster info, or a flat list of names.
        // If the former, transform it to simply a list of names.
        var leaves;

        if (data.children) {
            leaves = d3.layout.cluster().nodes(data)
                .filter(function (x) { return !x.children; })
                .map(function (x) { return x.label + ""; });
        } else if (data.length) {
            leaves = data;
        }

        // Define scale, axis
        var scale = d3.scale.ordinal()
            .domain(leaves)
            .rangeBands([0, rotated ? width : height]);

        var axis = d3.svg.axis()
            .scale(scale)
            .orient(rotated ? "bottom" : "right")
            .outerTickSize(0)
            .tickPadding(padding)
            .tickValues(leaves);

        // Create the actual axis
        var axisNodes = svg.append("g")
            .attr("transform", rotated ? "translate(0," + padding + ")" : "translate(" + padding + ",0)")
            .call(axis);

        // Maximum data length
        var maxLength = 0;
        for (i in data) { data[i].length > maxLength ? maxLength = data[i].length : maxLength = maxLength }

        // Discarded - Fix for issue 36
        var fontSize = opts[(rotated ? 'x' : 'y') + 'axis_font_size'] ||
                                maxLength >= 40 ? maxLength >= 50 ? maxLength >= 60 ? maxLength >= 70 ? "8" : 
                                                "10" : 
                                                    "12" :
                                                         "14" :
                                                             Math.min(18, Math.max(9, scale.rangeBand() - (rotated ? 11 : 8)));

        // We discard the above fix for fontsize for a better and more robust calculation below:
        // The formula only works for x_axis labels
        fontSize =  opts[(rotated ? 'x' : 'y') + 'axis_font_size'] || rotated ? ((scale.rangeBand()/1.7) / maxLength) * 1.577909 : 
                                                                                    Math.min(18, Math.max(9, scale.rangeBand() - 8));

        //var fontSize = opts[(rotated ? 'x' : 'y') + 'axis_font_size'] || Math.min(18, Math.max(9, scale.rangeBand() - (rotated ? 11 : 8))) + "px";
        axisNodes.selectAll("text").style("font-size", fontSize); // Actual Value


        // Calculated on the basis of text length
        axisNodes.selectAll("text").style("fill", "#6F6F6F");



        // First find the maximum length,
        // If the maximum length is greater then 25, then rotate.
        //var maxLength = 0;
        //for (i in data) { data[i].length > maxLength ? maxLength = data[i].length : maxLength = maxLength }
        //axisNodes.selectAll("text").
        //    attr("transform", rotated ?
        //        maxLength > 25 ? "rotate(45), translate(70,0)" : "rotate(0)"
        //        : "rotate(0)");


        var halfColumnWidth = (width/data.length)/2;
        var mouseTargets = svg.append("g")
            .selectAll("g").data(leaves);
        mouseTargets
            .enter()
            .append("g").append("rect")
            .attr("transform", rotated ? "translate(-"+halfColumnWidth.toString()+",0)" : "")
            .attr("fill", "transparent")
            .on("click", function (d, i) {
                var dim = rotated ? 'x' : 'y';
                var selectedAxis = rotated ? [null, d]: [d, null];
                if (HTMLWidgets.shinyMode) {
                    Shiny.onInputChange(el.id+"_axis", selectedAxis); // Return Json object to the shiny app
                }
                var hl = controller.highlight() || { x: null, y: null };
                if (hl[dim] == i) {
                    // If clicked already-highlighted row/col, then unhighlight
                    hl[dim] = null;
                    controller.highlight(hl);
                } else {
                    hl[dim] = i;
                    controller.highlight(hl);
                }
                d3.event.stopPropagation();
            });
        function layoutMouseTargets(selection) {
            selection
                .attr("transform", function (d, i) {
                    var x = rotated ? scale(d) + scale.rangeBand() / 2 : 0;
                    var y = rotated ? padding + 6 : scale(d);
                    return "translate(" + x + "," + y + ")";
                })
                .selectAll("rect")
                .attr("height", scale.rangeBand() / (rotated ? 1.414 : 1))
                .attr("width", rotated ? height * 1.414 * 1.2 : width);
        }
        layoutMouseTargets(mouseTargets);

        if (false) {
            axisNodes.selectAll("text")
                .attr("transform", "rotate(0),translate(6, 0)")
                .style("text-anchor", "start");
        }

        controller.on('highlight.axis-' + (rotated ? 'x' : 'y'), function (hl) {
            var ticks = axisNodes.selectAll('.tick');
            var selected = hl[rotated ? 'x' : 'y'];
            if (typeof (selected) !== 'number') {
                ticks.classed('faded', false);
                return;
            }
            ticks.classed('faded', function (d, i) {
                return i !== selected;
            });
        });

        controller.on('transform.axis-' + (rotated ? 'x' : 'y'), function (_) {
            var dim = rotated ? 0 : 1;
            //scale.domain(leaves.slice(_.extent[0][dim], _.extent[1][dim]));
            var rb = [_.translate[dim], (rotated ? width : height) * _.scale[dim] + _.translate[dim]];
            scale.rangeBands(rb);
            var tAxisNodes = axisNodes.transition().duration(opts.anim_duration).ease('linear');
            tAxisNodes.call(axis);
            // Set text-anchor on the non-transitioned node to prevent jumpiness
            // in RStudio Viewer pane

            /* Stop x-axis labels to change position while transforming */
            // axisNodes.selectAll("text").style("text-anchor", "start");
            tAxisNodes.selectAll("g")
                .style("opacity", function (d, i) {
                    if (i >= _.extent[0][dim] && i < _.extent[1][dim]) {
                        return 1;
                    } else {
                        return 0;
                    }
                });
            
            /* Stop x-axis labels to change position while transforming */
            //tAxisNodes
            //     .selectAll("text")
            //     .style("text-anchor", "start");
                    
            mouseTargets.transition().duration(opts.anim_duration).ease('linear')
                .call(layoutMouseTargets)
                .style("opacity", function (d, i) {
                    if (i >= _.extent[0][dim] && i < _.extent[1][dim]) {
                        return 1;
                    } else {
                        return 0;
                    }
                });
        });

    }


    // ------------ HELPER FUNCTIONS for Dendogram------------- //


    function edgeStrokeWidth(node) {
        if (node.edgePar && node.edgePar.lwd)
            return node.edgePar.lwd;
        else
            return 1;
    }

    function maxChildStrokeWidth(node, recursive) {
        var max = 0;
        for (var i = 0; i < node.children.length; i++) {
            if (recursive) {
                max = Math.max(max, maxChildStrokeWidth(node.children[i], true));
            }
            max = Math.max(max, edgeStrokeWidth(node.children[i]));
        }
        return max;
    }

    function refineLocationObjectArray(number_of_columns, height, cluster_array) {
        for (i = 0; i < location_object_array.length; i++) {
            location_object_array.splice(i + 1, number_of_columns - 1);
        }
        location_object_array.push({
            begin: null, end: height, cluster: cluster_array[cluster_array.length - 1],
            rowInformation: cluster_change_rows[cluster_change_rows.length - 1].rowInformation
        }); // add the information for the last array

        location_object_array[0].begin = 0;
        for (i = 1; i < location_object_array.length; i++) {
            location_object_array[i].begin = location_object_array[i - 1].end;
        }
        return location_object_array;
    }

    function childrenArrayFinder(children_array_object, rotated) {
        // A Recursive function that retruns the children of a line object in an array form.
        var childrenArray = [];
        // for each element in the childrern array
        // if the element in focus have no children then push it in the children Array
        // if it does, go into one level deep.\
        if (children_array_object.children == null) {
            childrenArray.push(!rotated ? children_array_object.character : children_array_object.column);
        }
        else {
            for (i in children_array_object.children) {
                result = childrenArrayFinder(children_array_object.children[i], rotated);
                childrenArray = childrenArray.concat(result);
            }
        }
        return childrenArray;
    }

    function characterLength(string_array) {
        var length = 0;
        for (i in string_array) {
            if (string_array[i] != "" &&
                string_array[i] != "(" &&
                string_array[i] != ")" &&
                string_array[i] != "," &&
                string_array[i] != ";") {
                length = string_array[i].length + length;
            }
        }
        return length;
    }

    function maxDepth(string_array, pointer, depth, maxdepth) {
        while (pointer < string_array.length) {
            if (string_array[pointer] == "(") {
                result = maxDepth(string_array, pointer + 1, depth + 1, maxdepth);
                pointer = result[1];
                maxdepth = result[2];
                if (result[0] > maxdepth) {
                    maxdepth = result[0];
                }
            }
            else if (string_array[pointer] == ")") {
                return [depth, pointer + 1, maxdepth];
            }
            else {
                pointer++;
            }
        }
        return maxdepth;
    }


    // ------------ End of Helper functions ------------- //

    function string_parser(string_array, location_object_array, pointer, id, colDendogram,
                           /*col dendogram arguments*/ columnNames, columnsDrawnSoFar, width, height, totalCharacterLength, depth, maxdepth) {
        var table = [];
        var elements = [];
        var last2Elements = [];
        var correspondingString = !colDendogram ? "(" : "";
        while (pointer < string_array.length) {
            if (string_array[pointer] == "(") {
                result = string_parser(string_array, location_object_array, pointer + 1, id, colDendogram, columnNames, columnsDrawnSoFar, width,height, totalCharacterLength, depth + 1, maxdepth);
                if (!colDendogram) {
                    sub_table = result[0];
                    pointer = result[1];
                    id = result[2];
                    correspondingString = correspondingString + result[3];
                    // PUT SOMETHING HERE ALSO FOR CORRESPONDING STRINGS.
                    table = table.concat(sub_table);
                    last2Elements.push(sub_table[sub_table.length - 1]);
                }
                if (colDendogram) {
                    sub_table = result[0];
                    pointer = result[1];
                    columnsDrawnSoFar = result[2]; // ADD THIS.
                    correspondingString = correspondingString + result[3];
                    elements = elements.concat(result[4]); // ADD THIS.
                    table = table.concat(sub_table);
                    last2Elements.push(sub_table[sub_table.length - 1]);
                }
            }


            else if (string_array[pointer] == ")") {
                var children = [];
                var sum = 0;
                // At this point you must have only two OBJCTS in the table.
                // combine them and make a new object from them and push them into the table
                // then retrun to the previous recursion level.

                // ADD the sibling information.
                if (!colDendogram) {
                    for (i in table) {
                        if (table[i].character == last2Elements[0].character) {
                            table[i].sibling = last2Elements[1];
                        }
                        if (table[i].character == last2Elements[1].character) {
                            table[i].sibling = last2Elements[0];
                        }
                    }
                }

                if (colDendogram) {
                    for (i in table) {
                        if (table[i].correspondingString == last2Elements[0].correspondingString) {
                            table[i].sibling = last2Elements[1];
                        }
                        if (table[i].correspondingString == last2Elements[1].correspondingString) {
                            table[i].sibling = last2Elements[0];
                        }
                    }
                }

                last2Elements[0].sibling = last2Elements[1];
                last2Elements[1].sibling = last2Elements[0];
                // ADDED

                if (!colDendogram) {
                    var new_character = "";
                    if (last2Elements.length == 0) {
                        for (var j = table.length - 2; j <= table.length - 1; j++) {
                            sum = sum + table[j].location.vertical;
                            new_character = new_character + table[j].character;
                            children.push(table[j]);
                        }
                    }
                    else // Will this always be true ?? Verify ! Because last 2 elements  will always have tw
                    {
                        for (var j = 0; j <= last2Elements.length - 1; j++) {
                            sum = sum + last2Elements[j].location.vertical;
                            new_character = new_character + last2Elements[j].character;
                            children.push(last2Elements[j]);
                        }
                    }
                    var mid_point = sum / 2;
                    // Find out how many characters does the string have, that way, we will be able to find the horizontal location of the
                    // object.
                    correspondingString = correspondingString + string_array[pointer];
                    // var horizontal = (new_character.length - 1 ) * (20 / totalCharacterLength); // CURRENT WORKING ONE
                    // var horizontal = (new_character.length - 1) * 1 ;    // Intelligently calculate this number


                    var horizontal = 20 - ((20 / maxdepth) * depth) + 3;  //Expreimental value


                    var location = { horizontal: horizontal, vertical: mid_point };
                    var rowStart = last2Elements[0].rowLocationInformation.startRow;
                    var rowEnd = last2Elements[1].rowLocationInformation.endRow;
                    table.push({
                        character: new_character,
                        location: location,
                        children: children,
                        id: id,
                        rowLocationInformation: { startRow: rowStart, endRow: rowEnd },
                        sibling: null,
                        correspondingString: correspondingString
                    });
                    id = id + 1;
                    return [table, pointer + 1, id, correspondingString];
                }

                if (colDendogram) {
                    for (i in last2Elements) {
                        sum = sum + last2Elements[i].location.horizontal;
                        children.push(last2Elements[i]);
                    }
                    correspondingString = "(" + last2Elements[0].correspondingString + "," + last2Elements[1].correspondingString + ")";
                    var horizontal = sum / 2;
                    var vertical = 30 - ((30 / maxdepth) * depth) + 3; // Fix for problem 31
                    var location = { vertical: vertical, horizontal: horizontal };
                    //Finding the column range
                    var colRangeArray = [];
                    {
                        for (var i in elements) {
                            colRangeArray.push(columnNames.indexOf(elements[i]));
                        }
                    }
                    var start = Math.min.apply(null, colRangeArray);
                    var end = Math.max.apply(null, colRangeArray);


                    var columnRange = { start: start, end: end };
                    table.push({ column: correspondingString, location: location, correspondingString: correspondingString, children: children, sibling: null, columnRange: columnRange });
                    return [table, pointer + 1, columnsDrawnSoFar, correspondingString, elements];
                }

            }
            else if (string_array[pointer] == ",") {
                // Do nothing;
                correspondingString = correspondingString + string_array[pointer];
                pointer++;
            }
            else if (string_array[pointer] == "" || string_array[pointer] == " " || string_array[pointer] == ";") {
                pointer++;
            }
            else // The object is a cluster OR a column name.
            {
                if (!colDendogram) {
                    var vertical = 0;
                    correspondingString = correspondingString + string_array[pointer];
                    var rowLocationInformation;
                    for (var j in location_object_array) {
                        if (string_array[pointer] == parseInt(location_object_array[j].cluster)) {
                            vertical = (location_object_array[j].begin + location_object_array[j].end) / 2;
                            rowLocationInformation = location_object_array[j].rowInformation;
                        }
                    }
                    var location = { horizontal: 2, vertical: vertical };
                    table.push({
                        character: string_array[pointer],
                        location: location,
                        children: null,
                        id: id,
                        rowLocationInformation: rowLocationInformation,
                        sibling: null,
                        correspondingString: string_array[pointer]
                    });
                    last2Elements.push({
                        character: string_array[pointer],
                        location: location,
                        children: null,
                        id: id,
                        rowLocationInformation: rowLocationInformation,
                        sibling: null,
                        correspondingString: string_array[pointer]
                    });
                    pointer = pointer + 1;
                    id = id + 1;
                }
                if (colDendogram) {
                    correspondingString = string_array[pointer];
                    var horizontal = ((width / (columnNames.length * 2)) + ((width / columnNames.length) * columnsDrawnSoFar.length));
                    var location = { vertical: 0, horizontal: horizontal };
                    columnsDrawnSoFar.push(string_array[pointer]);
                    var start = columnNames.indexOf(correspondingString);
                    var columnRange = { start: start, end: null };
                    table.push({
                        column: string_array[pointer],
                        location: location,
                        correspondingString: correspondingString,
                        children: null,
                        sibling: null,
                        columnRange: columnRange
                    });
                    elements.push(string_array[pointer]);
                    last2Elements.push({
                        column: string_array[pointer],
                        location: location,
                        correspondingString: correspondingString,
                        children: null,
                        sibling: null,
                        columnRange: columnRange
                    });
                    pointer++;
                }
            }
        }
        // Adding ID's for each object to be used later by the onClick and onHover function. (i dont understand ?)
        return table;



    }

    function preLineObjects(table, links1, rotated) {
        console.log("                                       ** PreLine Objects **");
        var links1Counter = 0;
        for (var i in table) {
            if (table[i].children != null) {
                for (var j in table[i].children) {
                    links1[links1Counter].source.x = !rotated ? table[i].location.vertical : table[i].location.horizontal;
                    links1[links1Counter].source.y = !rotated ? table[i].location.horizontal : table[i].location.vertical;
                    links1[links1Counter].target.x = !rotated ? table[i].children[j].location.vertical : table[i].children[j].location.horizontal;
                    links1[links1Counter].target.y = !rotated ? table[i].children[j].location.horizontal : table[i].children[j].location.vertical;
                    links1[links1Counter].line_name = !rotated ? table[i].children[j].character : table[i].children[j].correspondingString;
                    links1[links1Counter].siblingLineName = !rotated ? table[i].children[j].sibling.character : table[i].children[j].sibling.correspondingString;
                    links1[links1Counter].correspondingString = table[i].children[j].correspondingString;
                    links1[links1Counter].siblingCorrespondingString = table[i].children[j].sibling.correspondingString;
                    links1[links1Counter].rowRange = !rotated ? table[i].children[j].rowLocationInformation : null;
                    links1[links1Counter].siblingRowRange = !rotated ? table[i].children[j].sibling.rowLocationInformation : null;
                    links1[links1Counter].columnRange = !rotated ? null : table[i].children[j].columnRange;
                    links1[links1Counter].siblingColumnRange = !rotated ? null : table[i].children[j].sibling.columnRange;
                    links1[links1Counter].correspondingChildrenArray = childrenArrayFinder(table[i].children[j], rotated);
                    links1Counter++;
                }
            }
        }
        return links1;
    }

    function drawDendogramLines(dendrG, links1, table) {
        var DendogramLines = dendrG.selectAll("polyline").data(links1); // GLOBAL
        DendogramLines
            .enter().append("polyline")
            .attr("class", "link")
            .attr("stroke", "#A2A2A2")
            .attr("stroke-width", edgeStrokeWidth)
            .attr("stroke-dasharray", function (d, i) {
                var pattern;
                pattern = [];
                return pattern.join(",");
            })
            .on("mouseover", function (d, i) {
                console.log(i);
                console.log(d);
                d3.select(this)
                    .style("cursor", "pointer")
                    .style("stroke", "blue")
                    .attr("stroke-width", "4");
                // Turn all the children Blue.
                var sibling_children_array = [];
                for (var j = 0; j < table.length; j++) {   // FOR ALL THR LINES
                    // children of d must be blue.
                    // color all the children elements of d
                    // color all the lines that contains the children elements of d
                    if (d.correspondingChildrenArray.indexOf(links1[j].line_name) > -1) {
                        // Color all the children elements of d.
                        d3.select(DendogramLines[0][j])
                            .style("stroke", "blue")
                            .attr("stroke-width", "4");
                    }
                    // Color all the lines which contain a child contained in d.
                    for (var k in links1[j].correspondingChildrenArray) {
                        if (d.correspondingChildrenArray.indexOf(links1[j].correspondingChildrenArray[k]) > -1 &&
                            d.line_name.length > links1[j].line_name.length) {
                            d3.select(DendogramLines[0][j])
                                .style("stroke", "blue")
                                .attr("stroke-width", "2.5");
                        }
                    }
                    // Exact sibling line to red.
                    if (d.siblingLineName == links1[j].line_name
                        // && links1[j].correspondingChildrenArray have no child elements that are also in d.correspondingChildrenArray
                    ) {
                        // CHange the sibling dendogram to red.
                        d3.select(DendogramLines[0][j])
                            .style("stroke", "red")
                            .attr("stroke-width", "2.5");
                        // Get the children array of this line
                        sibling_children_array = links1[j].correspondingChildrenArray;
                    }
                }
                for (var j = 0; j < table.length; j++) {
                    for (var k in links1[j].correspondingChildrenArray) {
                        //THIS THING IS NOT WORKING :(
                        // This condition is never becoming true.
                        if (sibling_children_array.indexOf(links1[j].correspondingChildrenArray[k]) > -1 &&
                            d.siblingLineName.length >= links1[j].line_name.length) {
                            d3.select(DendogramLines[0][j])
                                .style("stroke", "red")
                                .attr("stroke-width", "2.5");
                        }
                    }
                }


            })
            .on("mouseout", function (d, i) {
                d3.select(this)
                    .style("stroke", "#A2A2A2")
                    .attr("stroke-width", "1.5");

                for (var j = 0; j < table.length; j++) {
                    if (d.line_name.indexOf(links1[j].line_name) > -1) {
                        d3.select(DendogramLines[0][j])
                            .style("stroke", "#A2A2A2")
                            .attr("stroke-width", "1.5");
                    }
                    if (d.siblingLineName.indexOf(links1[j].line_name) > -1) {
                        d3.select(DendogramLines[0][j])
                            .style("stroke", "#A2A2A2")
                            .attr("stroke-width", "1.5");
                    }
                }

            });
        return DendogramLines;

    }
    function dendogram(svg, rotated, width, height, padding, noOfCols, cluster_array, newickString, columnNames) {
        console.log("           --Entered dendogram() --");
        rotated ? console.log("                     Column Dendogram") : console.log("                 Row Dendogram");
        var fakedata = {
            members: 150, edgePar: { cols: "" }, height: 30, children: [{
                members: 150, edgePar: { cols: "" },
                height: 30, children: [{}, {}], counter: 10
            }, {
                members: 150, edgePar: { cols: "" },
                height: 30, children: [{}, {}], counter: 10
            }], counter: 10
        } // CHANGE THIS 150 to the real value.    AND SHOULD THE HEIGHT STAY 30 ?
        // CHANGE THE NAME OF THE VARIABLE FAKE DATA INTO SOMETHING COOLER.
        var topLineWidth = maxChildStrokeWidth(fakedata, false); // What does it do ?
        var x = d3.scale.linear()
            .domain([fakedata.height, 0]) // FAKE DATA !
            .range([topLineWidth / 2, width - padding]); // Try to remove this. //what is this shit ?
        var y = d3.scale.linear()
            .domain([0, height])
            .range([0, height]);  // Try to remove this. // What is this shit ?

        var cluster = d3.layout.cluster()
            .separation(function (a, b) { return 1; })
            .size([rotated ? width : height, NaN]);
        var transform = "translate(1,0)";
        var id = "rowDend";

        if (rotated) {
            // Flip dendrogram vertically
            x.range([topLineWidth / 2, -height + padding + 2]);
            // Rotate
            transform = "rotate(-90) translate(-2,0)";
            id = "coldDend";
        }

        var dendrG = svg
            .attr("id", id)
            .attr("width", width)
            .attr("height", height)
            .append("g")
            .attr("transform", transform);


        var testnodes = cluster.nodes(fakedata);
        var testlinks = cluster.links(testnodes);
        for (var i = 0; i < 50; i++) // This looks really ugly, do something about it.
        {
            testlinks.push(testlinks[0]);
        }
        // After the heatmap loads the "links"
        // array mutates to much smaller values.
        // So instead we just make a deep copy of
        // the parts we want.
        var links1 = testlinks.map(function (link, i) {
            return {
                source: { x: 0, y: 0 },
                target: { x: 0, y: 0 },
                edgePar: link.target.edgePar
            };
        });
        //Refine location object array
        location_object_array = refineLocationObjectArray(noOfCols, height, cluster_array);
        //  Use "++" around the entities you want to seperate 
        newickString = newickString.replace(/\(/g, "+-*+-*(+-*+-*");
        newickString = newickString.replace(/\)/g, "+-*+-*)+-*+-*");
        newickString = newickString.replace(/\,/g, "+-*+-*,+-*+-*");

        // Couont the number of characters in the newick String.
        totalCharacterLength = characterLength(newickString.split("+-*+-*"));
        maxdepth = maxDepth(newickString.split("+-*+-*"), 0, 0, 0);
        console.log("                           Entering string_parser()");
        console.log("                                   Preparing the Data Structure for the Dendogram . . . . .");

        // ERROR Solved
        // There is a problem in column dendogram generation because the colums sometimes have spaces and that is causig the error.
        // So we replace the space(which was the splitting cirteria before) with the pattern "+-*+-*" which makes it possible to have spaces
        // as in the column/row names. 
        var table = string_parser(newickString.split("+-*+-*"), location_object_array, 0, 0, rotated, columnNames, [], width, height, totalCharacterLength, 0, maxdepth);
        console.log("                           Done !");
        console.log("                           Entering PreLineObjects()");
        console.log("                                   Getting information from the data structure and generating line objects");
        links1 = preLineObjects(table, links1, rotated);
        console.log("                           Done !");
        console.log("                           Entering drawDendogramLines()");
        console.log("                                   Rendering the lines from the line objects");
        var DendogramLines = drawDendogramLines(dendrG, links1, table);
        console.log("                           Done !");

        function draw(selection, rotated) {
            function elbow(d, i) {

                // Draw DENDOGRAM LABELS
                try {
                    if (!rotated && d.correspondingString.length < 3) {
                        var text = dendrG.append("text");
                        var xPos = x(d.target.y);
                        var yPos = y(d.target.x);
                        var fontsize = document.getElementById("rowDend").width.baseVal.value - xPos;
                        if (d.correspondingString.length == 1) {
                            text.attr("x", xPos + 2)
                                .attr("y", yPos + 5)
                                .text(d.correspondingString)
                                .attr("fill", "#7B7B7B")
                                .style("font-size", fontsize + "px"); // Issue 30 - Done: Calculate font size Intellegently
                        }
                    else { // IF string length is two, adjust the x-axis location accordingly
                            text.attr("x", xPos - 1)
                                .attr("y", yPos + 5)
                                .text(d.correspondingString)
                                .attr("fill", "#7B7B7B")
                                .style("font-size", fontsize - 2 + "px");  // Issue 30 - Done: Calculate font size Intellegently
                        }
                    }
                }
                catch (err) {
                    //do nothing
                }
                //  LABELS ADDED
                return x(d.source.y) + "," + y(d.source.x) + " " +
                    x(d.source.y) + "," + y(d.target.x) + " " +
                    x(d.target.y) + "," + y(d.target.x);
            }

            selection
                .attr("points", elbow);
        }

        // Dendogram transitions
        controller.on('transform.dendr-' + (rotated ? 'x' : 'y'), function (_) {
            var scaleBy = _.scale[rotated ? 0 : 1];
            var translateBy = _.translate[rotated ? 0 : 1];
            y.range([translateBy, height * scaleBy + translateBy]);
            dendrG.selectAll("text").remove(); // REMOVE OLD LABELS
            draw(DendogramLines.transition().duration(opts.anim_duration).ease("linear"), rotated);
        });
        draw(DendogramLines, rotated);

        if (rotated) {
            colDendLinesListner = DendogramLines;
        }
        else {
            rowDendLinesListner = DendogramLines;
        }
    }

    var dispatcher = d3.dispatch('hover', 'click');

    controller.on("datapoint_hover", function (_) {
        dispatcher.hover({ data: _ });
    });

    function on_col_label_mouseenter(e) {
        controller.highlight(+d3.select(this).attr("index"), null);
    }
    function on_col_label_mouseleave(e) {
        controller.highlight(null, null);
    }
    function on_row_label_mouseenter(e) {
        controller.highlight(null, +d3.select(this).attr("index"));
    }
    function on_row_label_mouseleave(e) {
        controller.highlight(null, null);
    }

    return [{
        on: function (type, listener) {
            dispatcher.on(type, listener);
            return this;
        }
    }, rowDendLinesListner, colDendLinesListner, cssify(zoomAreaBounds)];
}
