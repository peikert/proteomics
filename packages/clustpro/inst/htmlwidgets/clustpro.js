/** Last Updated: 19th June
    Version: 0.0.3
*/
HTMLWidgets.widget({
    name: "clustpro",
    type: "output",

    initialize: function (el, width, height) {
        console.log("-- Entered initialize() --");
        debugger;
        // Disable zoom 
        (function(){
        setInterval("document.body.style.zoom=1/window.devicePixelRatio",1);
        var viewport=document.createElement("meta");
        viewport.id="viewport";
        viewport.name="viewport";
        viewport.content="width=device-width, initial-scale=1";
        document.body.parentElement.children[0].appendChild(viewport);
        })()
        
        return {
            lastTheme: null,
            lastValue: null
        };
    },

    htmlSideBarInitialize : function (el,x){
        var el = d3.select(el);
        var bbox = el.node().getBoundingClientRect();
        var height = bbox.height;
        var left = 0;
        var top = 0;
        var width = bbox.width * 0.12 * 0.25;
        return {height:height, left:left, top:top, width:width};
    },
    workspaceDimensionsInitialize : function(el,x){
        var el = d3.select(el);
        var bbox = el.node().getBoundingClientRect();
        var height = bbox.height;
        var left = bbox.width * 0.12 * 0.25;
        var top = 0;
        var width = bbox.width - left;
        return {height:height, left:left, top:top, width:width};

    },

    renderValue: function (el, x, instance) {
        console.log("-- Entered renderValue() --");
        debugger;
        var rowNewickString = x.dendnw_row[0];
        var colNewickString = x.dendnw_col[0];
        var sidebar_options = {"colorLegend":true, "rowLabels":true, "zoom_enabled":false};
        var sideBarDimensions = this.htmlSideBarInitialize(el,x);
        var workSpaceDimensions = this.workspaceDimensionsInitialize(el,x);
        var innerworkSpaceDimensions = this.workspaceDimensionsInitialize(el,x);
        x.matrix.data = [].concat.apply([], x.matrix.data); // Flattening the data array.
        this.doRenderValue(el, x, rowNewickString, colNewickString, instance, null, false, sidebar_options, sideBarDimensions, workSpaceDimensions, innerworkSpaceDimensions);
    },
    resize: function (el, width, height, instance) {
        d3.select(el).select("svg")
            .attr("width", width)
            .attr("height", height);
        // instance.force.size([width, height]).resume();
        // this.doRenderValue(el, instance.lastValue, instance);  // FIX THIS >:/
    },

    drawColorLegend : function(el,x){
        debugger;
        var self = this;
        xaxis = d3.select("#xaxis");
        col = d3.select("#coldDend");
        var UniqueColors = [];
        for (i in x.color_legend.gradient) { UniqueColors[i] = x.color_legend.gradient[i].color }
        var numberOfUniqueColors = UniqueColors.length;
        var widthOfSVG = colormap.width.baseVal.value; // a big number idicating the length of the svg
        var startingPoint = widthOfSVG / 2;  //The point where the color legend should begin
        var widthOfOneBox = (widthOfSVG - startingPoint) / numberOfUniqueColors;
        for (i in UniqueColors) {
            xaxis.append("rect")
                .style("fill", UniqueColors[i])
                .attr("width", widthOfOneBox.toString() + "px")
                .attr("height", "20px")
                .attr("x", startingPoint + widthOfOneBox * i)
                .attr("y", 70);
        }
        // *********** Labels for the color legend **************
        var labels = x.color_legend.label_position;
        var numberOfLabels = labels.length;
        var labelText = xaxis.append("text");
        // Calculate the starting point of the first text element
        var startLabelText = startingPoint;
        // Calculate the distance between the label texts
        var distanceBetweenLabels = (widthOfSVG - 4 - startLabelText) / (numberOfLabels - 1);  // Issue # 17
        for (var i in labels) {
            xaxis.append("text")
                .attr("x", startingPoint + (distanceBetweenLabels * i))
                .attr("id", "colorlegends")
                .attr("y", 100)
                .text(labels[i])
                .attr("fill", "black")
                .style("font-size", "10px");
        }
    },


    doRenderValue: function (el, x, rowNewickSting, colNewickString, instance, 
                                newMerged, scrollable, sidebar_options, sideBarDimensions, workSpaceDimensions, innerworkSpaceDimensions) {
        console.log("-- Entered doRenderValue() --");
        if(scrollable){document.getElementById("workspace").style.overflow="scroll";}
        self = this;
        instance.lastValue = x;
        el.innerHTML = "";
        var merged = [];
        var dataMatrixIndex = 0;
        // coloring information.
        //
        for (var i = 0; i < x.colors.data.length; i++) {
            for (var j = 0; j < x.colors.data[i].length; j++) {
                merged.push({
                    label: x.matrix.data[dataMatrixIndex++].toString(),
                    color: this.hextorgb(x.colors.data[i][j])
                });
            }
        }
        if (newMerged == null) {
            x.matrix.merged = merged;
        }
        else {
            x.matrix.merged = newMerged;
        }
        // Preparing the needed data objects here:
        var location_object_array = []; // Document it's purpose here.
        var cluster_change_rows = []; // Document it's purpose here.
        var cluster = x.clusters; //Document it's purpose here.
        cluster_change_rows = this.clusterChangeInformation(cluster, cluster_change_rows);
        var rowDendLinesListner = null;
        var colDendLinesListner = null;
        console.log("Initializing ClustPro()");
        var heatMapObject = clustpro(el, x, x.options, location_object_array, cluster_change_rows, 
                                        cluster, rowDendLinesListner, colDendLinesListner, 
                                            sidebar_options,scrollable, sideBarDimensions, workSpaceDimensions, innerworkSpaceDimensions);
        console.log("Exited ClustPro()");
        // ******************* Color Legend *****************************************
        // Check from the options object if colorLegend is "true". If yes, then draw color legend.
        if(sidebar_options.colorLegend){
            debugger;
            self.drawColorLegend(el,x);
        }
        // **************************************************************************
        //********************* HTML SIDE BAR ****************************************  
        debugger;
        var sideBar = document.getElementById("myTopnav");
        { // Side bar Gif Dimensions
            var sideBarWidth = sideBar.offsetWidth; // int 
            var normalGIFHeight = sideBarWidth + (sideBarWidth * 0.5);
            var normalGIFWidth = sideBarWidth * 0.90; // 90 % of the width.
            var normalgifHeightcssText = normalGIFHeight.toString()+"px"; // Normal height of the GIF.
            var normalgifWidthcssText = normalGIFWidth.toString()+"px"; // Normal width of the GIF.
            var zoomedInGidWidthCssText = sideBarWidth.toString()+"px"; // Hovered width of the GIF.
            var normalCSSText = "height:"+normalgifHeightcssText+"; width:"+normalgifWidthcssText;
            var hoverCSSText = "height:"+normalgifHeightcssText+"; width:"+zoomedInGidWidthCssText+";  cursor : pointer";
        }

        

        { // 1) SAVE 
            var save = document.createElement("div");
            save.setAttribute("id", "save");
            save.setAttribute("title", "Save");
            save.style.cssText = normalCSSText;
            save.innerHTML = saveIcon();
            sideBar.appendChild(save);
            d3.select("#save")
                .on("click", function () {
                debugger;
                self.saveSvg(x.export_type[0]);
            })
                .on("mouseover", function (d, i) {
                    save.style.cssText = hoverCSSText;
                    debugger;
            })
            .on("mouseout", function (d, i) {
                    save.style.cssText = normalCSSText;
            });
        }

         
        { // 2) Show Color Legend
            var colorLegend = document.createElement("div");
            colorLegend.setAttribute("id", "colorLegend");
            colorLegend.setAttribute("title", "Show Color Legend");
            colorLegend.style.cssText = normalCSSText;
            // Insert GIF
            colorLegend.innerHTML = showColorLegendIcon();
            //GIF Inserted
            sideBar.appendChild(colorLegend);

            d3.select("#colorLegend")
                .on("click", function () {
                    debugger;
                    if(sidebar_options.colorLegend) // If the color legend is already being displayed.
                    { // Hide it.
                        xaxis.selectAll("rect").remove();
                        xaxis.selectAll("#colorlegends").remove();
                        sidebar_options.colorLegend = false;
                    }else{ // If not then display it. 
                        self.drawColorLegend(el,x);
                        sidebar_options.colorLegend = true;
                    }
            })
                .on("mouseover", function (d, i) {
                    colorLegend.style.cssText = hoverCSSText;
            })
            .on("mouseout", function (d, i) {
                    colorLegend.style.cssText = normalCSSText;
            });
        }

        // 3) Unscroll all 
        var unscroll = document.createElement("div");
        unscroll.setAttribute("id", "unscroll");
        unscroll.setAttribute("title", "UnScroll");
        unscroll.style.cssText = normalCSSText;
        // Try to insert a GIF in here....
        unscroll.innerHTML = unScroll();
        // GIF INSERTED....
        sideBar.appendChild(unscroll);

        d3.select("#unscroll") // On click for VzoomIn
            .on("click", function () {
                debugger;
                // Make the inner workspace height equal to the normal workspace height.
                innerworkSpaceDimensions.width = workSpaceDimensions.width;
                innerworkSpaceDimensions.height = workSpaceDimensions.height;
                self.doRenderValue(el, x, rowNewickSting, colNewickString, instance, newMerged, false, sidebar_options, sideBarDimensions, workSpaceDimensions, innerworkSpaceDimensions);
         })
        .on("mouseover", function (d, i) {
                unscroll.style.cssText = hoverCSSText;
        })
        .on("mouseout", function (d, i) {
                unscroll.style.cssText = normalCSSText;
        });



        // 4) Enable Row Label
        {
            var enablerowlabel = document.createElement("div");
            enablerowlabel.setAttribute("id", "enablerowlabel");
            enablerowlabel.setAttribute("title", "Enable Row Legend");
            enablerowlabel.style.cssText = normalCSSText;
            // Try to insert a GIF in here....
            enablerowlabel.innerHTML = showRowLabel();
            // GIF INSERTED....
            sideBar.appendChild(enablerowlabel);

            d3.select("#enablerowlabel")
                .on("click", function () {
                    debugger;
                    if(sidebar_options.rowLabels){
                        sidebar_options.rowLabels = false;
                        self.doRenderValue(el, x, rowNewickSting, colNewickString, instance, newMerged, false, sidebar_options, sideBarDimensions, workSpaceDimensions, innerworkSpaceDimensions);
                    }else{
                        sidebar_options.rowLabels = true;
                        self.doRenderValue(el, x, rowNewickSting, colNewickString, instance, newMerged, false, sidebar_options, sideBarDimensions, workSpaceDimensions, innerworkSpaceDimensions);
                    }
                
            })
            .on("mouseover", function (d, i) {
                    enablerowlabel.style.cssText = hoverCSSText;
            })
            .on("mouseout", function (d, i) {
                    enablerowlabel.style.cssText = normalCSSText;
            });
        }

        // 5) Zoom Box (EXPERIMENTAL) [ UNDERDEVELOPMENT ]
        {
            var zoombox = document.createElement("div");
            zoombox.setAttribute("id", "zoombox");
            zoombox.setAttribute("title", "Zoom Box");
            zoombox.style.cssText = normalCSSText;
            // Try to insert a GIF in here....
            zoombox.innerHTML = zoomBox();
            // GIF INSERTED....
            sideBar.appendChild(zoombox);
            var old_html_widget = el.style.width;
            var old_html_height = el.style.height;
            d3.select("#zoombox")
                .on("click", function () {
                    debugger;
                    if(sidebar_options.zoom_enabled)
                    {
                        debugger;
                        // Just remove the SVGs here and turn the scroll into "hide".
                        sidebar_options.zoom_enabled = false;
                        d3.select("#draggablebox").remove();
                        d3.select("#resizerectangle").remove();
                        d3.select("#zoomAreasvg").remove();
                        d3.select("#zoomarea").remove();
                        el.style.width = old_html_widget;
                        el.style.height = old_html_height;
                    } else {
                        sidebar_options.zoom_enabled = true;
                        dimensions = self.calculateDimensions();
                        // No need for this currently
                        // window.scrollTo(document.getElementById("colormap").getBoundingClientRect().width, document.getElementById("colormap").getBoundingClientRect().height); // Scroll to the bottom right
                        var old_el_style_width = dimensions[0];
                        var old_el_style_height = dimensions[1];
                        el.style.width = heatMapObject[3].width; // Increase the over all scrollable area 
                        el.style.height = heatMapObject[3].height; // Increase the over all scrollable area
                        document.getElementById("workspace").style.overflow="scroll";
                        var drag = d3.behavior.drag()
                                .on('drag', function() {
                                    box.attr("x", d3.event.x - 20)
                                        .attr("y", d3.event.y - 20);
                                    rectangle.attr("width", d3.event.x +10)
                                            .attr("height", d3.event.y +10);
                                });
                        // Implemetation details:
                        // The start location of zoomArea should be the start location of the colormap. // Very important. Not compromisable. 
                        var zoomAreaCss = heatMapObject[3]; // Zoom Area dimensions returned by clustpro.                    
                        var zoomAreaSvgContainer = d3.select("#workspaceinner").append("svg").attr({"id":"zoomarea"}).classed("zoomarea", true).style(zoomAreaCss);
                        var zoomAreaRectangle = d3.select("#zoomarea").append("rect") // Equal to the size of the color map.
                                            .attr("x",0)
                                            .attr("y",0)
                                            .attr("id", "zoomAreasvg")
                                            .attr("width",document.getElementById("zoomarea").getBoundingClientRect().width) // Should be a specific size bigger then the color map
                                            .attr("height", document.getElementById("zoomarea").getBoundingClientRect().height) // Should be a specific size bigger then the color map
                                            .style("opacity",0);
                        var rectangle = d3.select("#zoomarea").append("rect") // Equal to the size of the color map.
                                            .attr("x",0)
                                            .attr("y",0)
                                            .attr("id", "resizerectangle")
                                            .attr("width",d3.select("#colormap")[0][0].width.baseVal.value) // Should be the width of the color map
                                            .attr("height", d3.select("#colormap")[0][0].height.baseVal.value) // Should be the height of the color map
                                            .style("opacity", 0.5);
                    var box = d3.select("#zoomarea").append("rect") // The draggable box 
                                            .attr("x", d3.select("#colormap")[0][0].width.baseVal.value - 30)
                                            .attr("y", d3.select("#colormap")[0][0].height.baseVal.value - 30)
                                            .attr("id","draggablebox")
                                            .attr("width", 30)
                                            .attr("height", 30)
                                            .attr("opacity", 0.8)
                                            .call(drag)
                                            .on("mouseup", function(){
                                                                debugger;
                                                                console.log("Calculate where you unclicked the box and redraw the whole html with that dimensions");
                                                                var e = d3.event.target;
                                                                var dim = e.getBoundingClientRect();
                                                                var x_coordinate = d3.event.clientX - 
                                                                                            document.getElementById("colormap").getBoundingClientRect().left + 
                                                                                            document.getElementById("inner").getBoundingClientRect().left ; // Subtract width of the rowdendogram or the left distance of the color map ?
                                                                var y_coordinate = d3.event.clientY - 
                                                                                            document.getElementById("colormap").getBoundingClientRect().top // Subtract the height of the colDendogram or the top portion of the color map ?
                                                                var width_increase = x_coordinate - d3.select("#colormap")[0][0].width.baseVal.value;
                                                                var height_increase =  y_coordinate - d3.select("#colormap")[0][0].height.baseVal.value;
                                                                innerworkSpaceDimensions.width = innerworkSpaceDimensions.width + width_increase;
                                                                innerworkSpaceDimensions.height = innerworkSpaceDimensions.height + height_increase;
                                                                sidebar_options.zoom_enabled = false;
                                                                self.doRenderValue(el, x, rowNewickSting, colNewickString, 
                                                                                            instance, newMerged, true, sidebar_options, sideBarDimensions, workSpaceDimensions, innerworkSpaceDimensions);
                                                            });
                    }
            })
            .on("mouseover", function (d, i) {
                    zoombox.style.cssText = hoverCSSText;
            })
            .on("mouseout", function (d, i) {
                    zoombox.style.cssText = normalCSSText;
            });
        } 

        //*****************************************************************************/

        var hm = heatMapObject[0];
        if (x.dendnw_row[0] != null) { // if row dendogram information is provided.
            rowDendLinesListner = heatMapObject[1];
            rowDendLinesListner.on("click", function (d, i) {
                console.log("you clicked a line");
                console.log(i);
                console.log(d);
                self.refreshRowDendogram(d, el, x, rowNewickSting, colNewickString, instance, sidebar_options, sideBarDimensions);
            });
        }


        if (x.dendnw_col[0] != null) { // If column dendogram information is provided.
            colDendLinesListner = heatMapObject[2];
            colDendLinesListner.on("click", function (d, i) {
                console.log("you clicked a column dendogram line");
                console.log(i);
                console.log(d);
                self.refreshColDendogram(d, el, x, rowNewickSting, colNewickString, instance, sidebar_options, sideBarDimensions);
            });
        }

    },

    calculateDimensions: function(){ // Returns the combined widths and heights of all the elements in the html container.
        debugger;
        var width = document.getElementById("rowDend").getBoundingClientRect().width + 
                        document.getElementById("colormap").getBoundingClientRect().width + 
                            document.getElementById("yaxis").getBoundingClientRect().width;
        var height = document.getElementById("coldDend").getBoundingClientRect().height +
                        document.getElementById("colormap").getBoundingClientRect().height +
                            document.getElementById("coldDend").getBoundingClientRect().height; // whats wrong with this ?
        return [width, height];
    },

    showcolorlegend: function (el, x) {
        var self = this;
        xaxis = d3.select("#xaxis");
        var colorlegendtext = xaxis.append("text");
        d3.select("#hidecolorlegend").remove();
        colorlegendtext.attr("x", 450)
            .attr("y", 100)
            .attr("id", "showcolorlegend")
            .text("Show Color Legend")
            .attr("fill", "black")
            .style("font-size", "15px")
            .on("click", function () {
                console.log("show color legend");
                self.colorLegend(el, x);
            })
            .on("mouseover", function (d, i) {
                d3.select(this)
                    .style("cursor", "pointer")
                    .attr("fill", "blue");
            })
            .on("mouseout", function (d, i) {
                d3.select(this)
                    .attr("fill", "black");
            });
    },


    colorLegend: function (selector, x) {
        // Create Color Legend here.
        self = this;
        // EXPERIMENTAL CODE  *** CONTROL PANEL *****
        xaxis = d3.select("#xaxis");
        rectangle = xaxis.append("g");
        var colorlegendtext2 = xaxis.append("text");
        d3.select("#showcolorlegend").remove();
        colorlegendtext2.attr("x", 450)
            .attr("y", 100)
            .attr("id", "hidecolorlegend")
            .text("Hide Color Legend")
            .attr("fill", "black")
            .style("font-size", "15px")
            .on("click", function () {
                xaxis.selectAll("rect").remove();
                xaxis.selectAll("#colorlegends").remove();
                self.showcolorlegend(selector, x);
            })
            .on("mouseover", function (d, i) {
                d3.select(this)
                    .style("cursor", "pointer")
                    .attr("fill", "blue");
            })
            .on("mouseout", function (d, i) {
                d3.select(this)
                    .attr("fill", "black");
            });

            





        debugger;
        col = d3.select("#coldDend");
        colormap = d3.select("#colormap");
        var UniqueColors = [];
        for (i in x.color_legend.gradient) { UniqueColors[i] = x.color_legend.gradient[i].color }

        var numberOfUniqueColors = UniqueColors.length;

        var widthOfSVG = colormap[0][0].width.baseVal.value; // a big number idicating the length of the svg

        var startingPoint = widthOfSVG / 2;  //The point where the color legend should begin.

        var widthOfOneBox = (widthOfSVG - startingPoint) / numberOfUniqueColors;


        for (i in UniqueColors) {
            xaxis.append("rect")
                .style("fill", UniqueColors[i])
                .attr("width", widthOfOneBox.toString() + "px")
                .attr("height", "20px")
                .attr("x", startingPoint + widthOfOneBox * i)
                .attr("y", 70);
        }
        debugger;
        // *********** Labels for the color legend **************
        var labels = x.color_legend.label_position;
        var numberOfLabels = labels.length;
        var labelText = xaxis.append("text");
        // Calculate the starting point of the first text element
        var startLabelText = startingPoint;
        // Calculate the distance between the label texts
        var distanceBetweenLabels = (widthOfSVG - startLabelText) / (numberOfLabels - 1);

        for (var i in labels) {
            xaxis.append("text")
                .attr("x", startingPoint + (distanceBetweenLabels * i))
                .attr("id", "colorlegends")
                .attr("y", 100)
                .text(labels[i])
                .attr("fill", "black")
                .style("font-size", "10px");
        }
    },


    combineSVG: function () {
        debugger;
        var rowDend = document.getElementsByClassName("rowDend")[0];
        var rowDendSvgString = "";
        if (rowDend.getElementsByTagName("g")[0] != undefined) {
            rowDend.getElementsByTagName("g")[0].setAttribute("transform", "translate(0,110)");
            rowDendSvgString = rowDend.innerHTML;
            rowDend.getElementsByTagName("g")[0].setAttribute("transform", "translate(0,0)"); // Transform it back
        }
        var colDend = document.getElementsByClassName("dendrogram colDend")[0];
        var colDendSvgString = "";
        if (colDend.getElementsByTagName("g")[0] != undefined) {
            colDend.getElementsByTagName("g")[0].setAttribute("transform", "rotate(-90)  translate(0,216)");
            colDendSvgString = colDend.innerHTML;
            colDend.getElementsByTagName("g")[0].setAttribute("transform", "rotate(-90)  translate(0,0)");
        }
        else {
            colDend = "";
        }

        var colormap = document.getElementsByClassName("colormap")[0];
        var normalized_colormap = '<g transform="translate(216,110)">' + colormap.innerHTML + '</g>';
        // Do extensicve string manipulations here.
        var combinedSVG = rowDendSvgString + colDendSvgString + normalized_colormap;
        combinedSVG = '<?xml version="1.0"?>\r\n' +
            '<?xml-stylesheet href="lib/clustpro-0.0.1/./clustpro.css" type="text/css"?>\r\n' +
            '<svg xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg" class="colormap" width="2000" height="1000" style="position: absolute; top: 0px; left: 0px; width:1680px; height: 1000px;">\r\n' +
            '<defs> <style type="text/css"><![CDATA[ .link { fill: none; } ]]></style> </defs>' + // CSS for the dendogŕam
            combinedSVG + '</svg>';
        return combinedSVG;
    },


    saveSvg: function (export_type) {
        debugger;
        console.log("       --Entered SaveSVG()");
        var source = this.combineSVG();
        if (!source.match(/^<svg[^>]+xmlns="http\:\/\/www\.w3\.org\/2000\/svg"/)) {
            source = source.replace(/^<svg/, '<svg xmlns="http://www.w3.org/2000/svg"');
        }
        if (!source.match(/^<svg[^>]+"http\:\/\/www\.w3\.org\/1999\/xlink"/)) {
            source = source.replace(/^<svg/, '<svg xmlns:xlink="http://www.w3.org/1999/xlink"');
        }
        var url = "data:image/svg+xml;charset=utf-8," + encodeURIComponent(source);
        debugger;
        // Saving wih the "FileSaver.js"
        console.log("       --Saving as " + export_type);
        saveAs(new Blob([source], { type: "application/svg+xml" }), "clustpro_heatmap." + export_type); // saving in the user passed format.
    },

    refreshRowDendogram: function (d, el, x, rowNewickSting, colNewickString, instance, sidebar_options, sideBarDimensions) {
        var clusterSwapArray_1 = x.clusters.slice(d.rowRange.startRow, d.rowRange.endRow + 1);
        var clusterSwapArray_2 = x.clusters.slice(d.siblingRowRange.startRow, d.siblingRowRange.endRow + 1);
        var matrixDataArray_1 = x.matrix.data.slice(d.rowRange.startRow * x.matrix.cols.length, ((d.rowRange.endRow + 1) * x.matrix.cols.length));
        var matrixDataArray_2 = x.matrix.data.slice(d.siblingRowRange.startRow * x.matrix.cols.length, (d.siblingRowRange.endRow + 1) * x.matrix.cols.length);
        var matrixMergeArray_1 = x.matrix.merged.slice(d.rowRange.startRow * x.matrix.cols.length, ((d.rowRange.endRow + 1) * x.matrix.cols.length));
        var matrixMergeArray_2 = x.matrix.merged.slice(d.siblingRowRange.startRow * x.matrix.cols.length, (d.siblingRowRange.endRow + 1) * x.matrix.cols.length);
        // ownClusterCounter should always start with the smaller rowIndex (d.rowRange.startRow,d.siblingRowRange.startRow)
        ownClusterCounter = d.rowRange.startRow < d.siblingRowRange.startRow ? d.rowRange.startRow : d.siblingRowRange.startRow;
        matrixDataCounter = d.rowRange.startRow < d.siblingRowRange.startRow ? d.rowRange.startRow * x.matrix.cols.length : d.siblingRowRange.startRow * x.matrix.cols.length;
        matrixMergeCounter = d.rowRange.startRow < d.siblingRowRange.startRow ? d.rowRange.startRow * x.matrix.cols.length : d.siblingRowRange.startRow * x.matrix.cols.length;
        //Swap the cluster array.
        x.clusters = d.rowRange.startRow > d.siblingRowRange.startRow ? this.arraySwap(x, clusterSwapArray_1, clusterSwapArray_2, ownClusterCounter) : // If the line clicked is the lower sibling
            this.arraySwap(x, clusterSwapArray_2, clusterSwapArray_1, ownClusterCounter); // If the line clicked is the upper sibling.
        // Swap the Matrix Data array + Swap the Merged Data
        x.matrix = d.rowRange.startRow > d.siblingRowRange.startRow ? this.dataMatrixSwap(x, matrixDataArray_1, matrixDataArray_2, matrixMergeArray_1, matrixMergeArray_2, matrixDataCounter, matrixMergeCounter) : // If the line clicked is the lower sibling
            this.dataMatrixSwap(x, matrixDataArray_2, matrixDataArray_1, matrixMergeArray_2, matrixMergeArray_1, matrixDataCounter, matrixMergeCounter); // If the line clicked is the upper sibling.
        rowNewickSting = this.stringSwap(d, rowNewickSting); //refresh newick string.
        x.dendnw_row[0] = rowNewickSting;
        this.doRenderValue(el, x, rowNewickSting, colNewickString, instance, x.matrix.merged, false, sidebar_options, sideBarDimensions);
    },

    refreshColDendogram: function (d, el, x, rowNewickSting, colNewickString, instance, sidebar_options, sideBarDimensions) {
        var columnRangeClicked = d.columnRange;
        var siblingColumnRange = d.siblingColumnRange;
        if (columnRangeClicked.start < siblingColumnRange.start) {
            x.matrix = this.columnMatrixSwap(x, columnRangeClicked, siblingColumnRange);
            x.matrix.cols = this.refreshColumns(x, columnRangeClicked, siblingColumnRange);
        }
        else {
            x.matrix = this.columnMatrixSwap(x, siblingColumnRange, columnRangeClicked);
            x.matrix.cols = this.refreshColumns(x, siblingColumnRange, columnRangeClicked);
        }
        colNewickString = this.stringSwap(d, colNewickString); //refresh newick string.
        x.dendnw_col[0] = colNewickString; //refresh newick string.
        this.doRenderValue(el, x, rowNewickSting, colNewickString, instance, x.matrix.merged, false, sidebar_options, sideBarDimensions);
    },


    // HELPER FUNCTIONS ------------

    refreshColumns: function (x, columnRange1, columnRange2) {
        debugger;
        swap1 = x.matrix.cols.slice(columnRange1.start, columnRange1.end == null ? columnRange1.start + 1 : columnRange1.end + 1);
        swap2 = x.matrix.cols.slice(columnRange2.start, columnRange2.end == null ? columnRange2.start + 1 : columnRange2.end + 1);
        var columns = x.matrix.cols.slice(0, columnRange1.start);
        columns = columns.concat(swap2);
        columns = columns.concat(swap1);
        if (columnRange2.end == null) {
            if (columns.length < x.matrix.cols.length) {
                columns = columns.concat(x.matrix.cols.slice(columns.length, x.matrix.cols.length));
            }
            else {
                // pass
            }
        }
        else {
            if (columnRange2.end == x.matrix.cols.length - 1) {
                // pass
            }
            else {
                columns = columns.concat(x.matrix.cols.slice(columnRange2.end + 1, x.matrix.cols.length));
            }
        }
        return columns;
    },

    columnMatrixSwap: function (x, columnRange1, columnRange2) {
        debugger;
        for (var i = 0; i < x.matrix.data.length; i = i + x.matrix.cols.length) {
            columnstobeSwaped1 = x.matrix.data.slice(i + columnRange1.start, columnRange1.end == null ? i + columnRange1.start + 1 : i + columnRange1.end + 1);
            columnstobeSwaped2 = x.matrix.data.slice(i + columnRange2.start, columnRange2.end == null ? i + columnRange2.start + 1 : i + columnRange2.end + 1);
            mergecolumnstobeSwapped1 = x.matrix.merged.slice(i + columnRange1.start, columnRange1.end == null ? i + columnRange1.start + 1 : i + columnRange1.end + 1);
            mergeColumnstoBeSwapped2 = x.matrix.merged.slice(i + columnRange2.start, columnRange2.end == null ? i + columnRange2.start + 1 : i + columnRange2.end + 1);
            var newArray = x.matrix.data.slice(i, i + columnRange1.start);
            var newMergeArray = x.matrix.merged.slice(i, i + columnRange1.start);
            newArray = newArray.concat(columnstobeSwaped2);
            newMergeArray = newMergeArray.concat(mergeColumnstoBeSwapped2);
            newArray = newArray.concat(columnstobeSwaped1);
            newMergeArray = newMergeArray.concat(mergecolumnstobeSwapped1);
            newArray = newArray.concat(columnRange2.end == null ? x.matrix.data.slice(columnRange2.start + 1, i + x.matrix.cols.length) : x.matrix.data.slice(columnRange2.end + 1, i + x.matrix.cols.length));
            newMergeArray = newMergeArray.concat(columnRange2.end == null ? x.matrix.merged.slice(i + columnRange2.start + 1, i + x.matrix.cols.length) : x.matrix.merged.slice(i + columnRange2.end + 1, i + x.matrix.cols.length));
            var newArraycounter = 0;
            for (var j = i; j < i + x.matrix.cols.length; j++) {
                x.matrix.data[j] = newArray[newArraycounter];
                x.matrix.merged[j] = newMergeArray[newArraycounter];
                newArraycounter++;
            }
        }
        return x.matrix;
    },

    stringSwap: function (d, newickString) {
        var clickedString = d.correspondingString;
        var siblingString = d.siblingCorrespondingString;
        newickString = newickString.replace("(" + clickedString + ",", "(clicked,");
        newickString = newickString.replace("," + clickedString + ")", ",clicked)");
        newickString = newickString.replace("(" + siblingString + ",", "(sibling,");
        newickString = newickString.replace("," + siblingString + ")", ",sibling)");
        if (clickedString.length != 1) {
            newickString = newickString.replace(clickedString, "clicked");
        }
        if (siblingString.length != 1) {
            newickString = newickString.replace(siblingString, "sibling");
        }
        newickString = newickString.replace("clicked", siblingString);
        newickString = newickString.replace("sibling", clickedString);
        return newickString;
    },

    dataMatrixSwap: function (x, matrixDataArray_1, matrixDataArray_2, matrixMergeArray_1, matrixMergeArray_2, matrixDataCounter, matrixMergeCounter) {
        // Can be made even more efficent with the help of array splicing and array concatination operations.
        for (var i = 0; i < matrixDataArray_1.length; i++) {
            x.matrix.data[matrixDataCounter] = matrixDataArray_1[i];
            x.matrix.merged[matrixMergeCounter] = matrixMergeArray_1[i];
            matrixDataCounter++;
            matrixMergeCounter++;
        }
        for (var i = 0; i < matrixDataArray_2.length; i++) {
            x.matrix.data[matrixDataCounter] = matrixDataArray_2[i];
            x.matrix.merged[matrixMergeCounter] = matrixMergeArray_2[i];
            matrixDataCounter++;
            matrixMergeCounter++;
        }
        return x.matrix;
    },

    arraySwap: function (x, array1, array2, ownClusterCounter) {
        // Can be made even more efficent with the help of array splicing and array concatination operations.
        // Swaps two arrays
        for (var i = 0; i < array1.length; i++) {
            x.clusters[ownClusterCounter] = array1[i];
            ownClusterCounter++;
        }
        for (var i = 0; i < array2.length; i++) {
            x.clusters[ownClusterCounter] = array2[i];
            ownClusterCounter++;
        }
        return x.clusters;
    },

    hextorgb: function (hex) {
        var hex2 = hex.replace('#', '');
        var bigint = parseInt(hex2, 16);
        var r = (bigint >> 16) & 255;
        var g = (bigint >> 8) & 255;
        var b = bigint & 255;
        return "rgba(" + r + "," + g + "," + b + ",1)";
    },

    clusterChangeInformation: function (cluster, cluster_change_rows) {
        var current_cluster_value = cluster[0];
        var startRow = 0;
        for (var i = 0; i < cluster.length; i++) {
            if (current_cluster_value != cluster[i]) {
                cluster_change_rows.push({
                    ylocation: i, cluster: current_cluster_value,
                    rowInformation: { startRow: startRow, endRow: i - 1 }
                }); //cluster changes at this y-Location.
                current_cluster_value = cluster[i];
                startRow = i;
            }
        }
        //adding information for last cluster
        cluster_change_rows.push({
            ylocation: null, cluster: current_cluster_value,
            rowInformation: { startRow: startRow, endRow: cluster.length - 1 }
        });
        return cluster_change_rows;
    }


});