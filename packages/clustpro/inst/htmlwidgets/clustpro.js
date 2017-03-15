/** Last Updated: 20th February
    Version: 0.0.3
*/
HTMLWidgets.widget({
    name: "clustpro",
    type: "output",

    initialize: function(el, width, height) {
        console.log("-- Entered initialize() --");
        debugger;
        return {
            lastTheme: null,
            lastValue: null
        };
    },
    renderValue: function(el, x, instance) {
    	console.log("-- Entered renderValue() --");
        var rowNewickString = x.dendnw_row[0];
        var colNewickString = x.dendnw_col[0];
        x.matrix.data = [].concat.apply([],x.matrix.data); // Flattening the data array.
        this.doRenderValue(el, x, rowNewickString, colNewickString, instance, null, false);
    },
    resize: function(el, width, height, instance) {
        d3	.select(el).select("svg")
            .attr("width", width)
            .attr("height", height);
//
        instance.force.size([width, height]).resume();
        this.doRenderValue(el, instance.lastValue, instance);  // FIX THIS >:/
    },
    doRenderValue: function(el, x, rowNewickSting, colNewickString, instance, newMerged, scrollable){
    	console.log("-- Entered doRenderValue() --");
        if(scrollable){document.getElementsByTagName("body")[0].style.overflow = "scroll";}
        var self = this;
        instance.lastValue = x;
        el.innerHTML = "";
        var merged = [];
        var dataMatrixIndex = 0;
        // coloring information.
        for(var i=0; i < x.colors.data.length; i++){
            for(var j=0; j < x.colors.data[i].length; j++){
                merged.push({
                    label: x.matrix.data[dataMatrixIndex++].toString(),
                    color: this.hextorgb(x.colors.data[i][j])
                });
            }
        }
        if(newMerged == null){
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
        var heatMapObject = clustpro(el, x, x.options, location_object_array, cluster_change_rows,cluster, rowDendLinesListner, colDendLinesListner);
        console.log("Exited ClustPro()");

        //*********************** Control Panel ***************************************
        console.log("[Generating Control Panel]");
        this.controlPanel(el,x,rowNewickSting,colNewickString,instance,newMerged);
        console.log("Control Panel Generated");
        // ****************************************************************************

        var hm = heatMapObject[0];
        if(x.dendnw_row[0] != null){ // if row dendogram information is provided.
      		rowDendLinesListner = heatMapObject[1];
        	rowDendLinesListner.on("click", function(d,i) {
                console.log("you clicked a line");
                console.log(i);
                console.log(d);
                self.refreshRowDendogram(d,el,x, rowNewickSting, colNewickString, instance);
            	});
        }


        if(x.dendnw_col[0] != null){ // If column dendogram information is provided.
        	colDendLinesListner = heatMapObject[2];
        	colDendLinesListner.on("click",function (d,i) {
                console.log("you clicked a column dendogram line");
                console.log(i);
                console.log(d);
                self.refreshColDendogram(d,el,x,rowNewickSting,colNewickString,instance);
            	});
        }

        },




    showcolorlegend: function(el,x){
    	var self = this;
        xaxis = d3.select("#xaxis");
        var colorlegendtext = xaxis.append("text");
        d3.select("#hidecolorlegend").remove();
        colorlegendtext.attr("x",390)
             .attr("y",100)
             .attr("id","showcolorlegend")
             .text("Show Color Legend")
             .attr("fill", "black")
             .style("font-size","15px")
             .on("click",function(){
        			console.log("show color legend");
        			self.colorLegend(el,x);
             	})
        	.on("mouseover",function(d,i){
	        		d3.select(this)
	        		.style("cursor", "pointer")
	        		.attr("fill","blue");
             	})
        	.on("mouseout",function(d,i){
	        		d3.select(this)
	        		.attr("fill","black");
        	});

    },


    colorLegend: function(selector,x){
    	// Create Color Legend here.
    	self = this;
    	debugger;
        console.log("Creating color legend here");
        //var el = d3.select(selector);
        // EXPERIMENTAL CODE  *** CONTROL PANEL *****
        xaxis = d3.select("#xaxis");
        rectangle = xaxis.append("g");
        var colorlegendtext2 = xaxis.append("text");
        d3.select("#showcolorlegend").remove();
        colorlegendtext2.attr("x",390)
             .attr("y",100)
             .attr("id","hidecolorlegend")
             .text("Hide Color Legend")
             .attr("fill", "black")
             .style("font-size","15px")
             .on("click",function(){
        			xaxis.selectAll("rect").remove();
        			xaxis.selectAll("#colorlegends").remove();
        			self.showcolorlegend(selector,x);
             	})
        	.on("mouseover",function(d,i){
	        		d3.select(this)
	        		.style("cursor", "pointer")
	        		.attr("fill","blue");
             	})
        	.on("mouseout",function(d,i){
	        		d3.select(this)
	        		.attr("fill","black");
        	});





        debugger;
        col = d3.select("#coldDend");
        colormap = d3.select("#colormap");
        var UniqueColors = [];
        for(i in x.color_legend.gradient) {UniqueColors[i] = x.color_legend.gradient[i].color}

        var numberOfUniqueColors = UniqueColors.length;

    	var widthOfSVG = colormap[0][0].width.baseVal.value; // a big number idicating the length of the svg

    	var startingPoint = widthOfSVG/2;  //The point where the color legend should begin.
    
        var widthOfOneBox = (widthOfSVG - startingPoint)/numberOfUniqueColors;


        for(i in UniqueColors){
        	xaxis.append("rect")
        	.style("fill",UniqueColors[i])
        	.attr("width", widthOfOneBox.toString() + "px")
            .attr("height", "20px")
            .attr("x", startingPoint + widthOfOneBox*i)
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
        var distanceBetweenLabels = (widthOfSVG - startLabelText) / (numberOfLabels-1);

        for(var i in labels)
        {
		        xaxis.append("text")
		        .attr("x", startingPoint+(distanceBetweenLabels*i))
		        .attr("id","colorlegends")
		        .attr("y", 100)
		        .text(labels[i])
		        .attr("fill", "black")
		        .style("font-size","10px");
	        }
    },

    controlPanel: function(el,x,rowNewickSting,colNewickString,instance,newMerged){
    	var self = this;
    	col = d3.select("#coldDend");
    	colormap = d3.select("#colormap");
    	var widthOfSVG = colormap[0][0].width.baseVal.value;
    	var startingPoint = widthOfSVG/2;
        xaxis = d3.select("#xaxis");
        var savetext = xaxis.append("text");
        var scrolltext = xaxis.append("text");
        var unscrolltext = xaxis.append("text");
        var horizontalScroll = xaxis.append("text");
        self.showcolorlegend(el,x);
     
         
        savetext.attr("x",0)
             .attr("y",100)
             .text("SAVE")
             .attr("fill", "black")
             .style("font-size","15px")
             .on("click",function(){
        			console.log("[Saving Image]");
        			self.saveSvg(x.export_type[0]);
             	})
        	.on("mouseover",function(d,i){
	        		d3.select(this)
	        		.style("cursor", "pointer")
	        		.attr("fill","blue");
             	})
        	.on("mouseout",function(d,i){
	        		d3.select(this)
	        		.attr("fill","black");
        	});


        scrolltext.attr("x",70)
             .attr("y",100)
             .text("SCROLL")
             .attr("fill", "black")
             .style("font-size","15px")
             .on("click",function(d,i){
                    console.log("Scroll");
                	var new_html_widget = el;
                	new_html_widget.style.width = "2000px";
                	new_html_widget.style.height = "1700px";
                	x.options.yaxis_width[0] = 300;
                	self.doRenderValue(new_html_widget, x, rowNewickSting, colNewickString, instance, newMerged, true);        			
             	})
        	.on("mouseover",function(d,i){
	        		d3.select(this)
	        		.style("cursor", "pointer")
	        		.attr("fill","blue");
             	})
        	.on("mouseout",function(d,i){
	        		d3.select(this)
	        		.attr("fill","black");
        	});


        // SCROLL HORIZONTALLY
        horizontalScroll.attr("x",250)
             .attr("y",100)
             .text("Scroll Horizontally")
             .attr("fill", "black")
             .style("font-size","15px")
             .on("click",function(d,i){
                    console.log("Scroll Horizontally");
                	var new_html_widget = el;
                	new_html_widget.style.width = "2500px";
                	x.options.yaxis_width[0] = 600;
                	self.doRenderValue(new_html_widget, x, rowNewickSting, colNewickString, instance, newMerged, true);        			
             	})
        	.on("mouseover",function(d,i){
	        		d3.select(this)
	        		.style("cursor", "pointer")
	        		.attr("fill","blue");
             	})
        	.on("mouseout",function(d,i){
	        		d3.select(this)
	        		.attr("fill","black");
        	});


        unscrolltext.attr("x",150)
             .attr("y",100)
             .text("UNSCROLL")
             .attr("fill", "black")
             .style("font-size","15px")
             .on("click",function(d,i){
                    console.log("Unscroll");
	                var old_html_widget = el;
	                old_html_widget.style.width = "100%";
	                old_html_widget.style.height = "100%";
	                x.options.yaxis_width[0] = 120;
	                self.doRenderValue(old_html_widget, x, rowNewickSting, colNewickString, instance, newMerged, false);       			
             	})
        	.on("mouseover",function(d,i){
	        		d3.select(this)
	        		.style("cursor", "pointer")
	        		.attr("fill","blue");
             	})
        	.on("mouseout",function(d,i){
	        		d3.select(this)
	        		.attr("fill","black");
        	});

    },

    combineSVG: function(){
    	debugger;
    	var rowDend = document.getElementsByClassName("rowDend")[0];
    	var rowDendSvgString = "";
    	if(rowDend.getElementsByTagName("g")[0] != undefined)
    	{
    		rowDend.getElementsByTagName("g")[0].setAttribute("transform","translate(0,110)");
    		rowDendSvgString = rowDend.innerHTML;
    		rowDend.getElementsByTagName("g")[0].setAttribute("transform","translate(0,0)"); // Transform it back
    	}    	
    	var colDend = document.getElementsByClassName("dendrogram colDend")[0];
    	var colDendSvgString = "";
    	if(colDend.getElementsByTagName("g")[0] != undefined){
    		colDend.getElementsByTagName("g")[0].setAttribute("transform","rotate(-90)  translate(0,216)");
    		colDendSvgString = colDend.innerHTML;
    		colDend.getElementsByTagName("g")[0].setAttribute("transform","rotate(-90)  translate(0,0)");
    	}
    	else
    	{
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


    saveSvg: function(export_type){
        debugger;
        console.log("       --Entered SaveSVG()");
        var source = this.combineSVG();
        if(!source.match(/^<svg[^>]+xmlns="http\:\/\/www\.w3\.org\/2000\/svg"/)){
            source = source.replace(/^<svg/, '<svg xmlns="http://www.w3.org/2000/svg"');
        }
        if(!source.match(/^<svg[^>]+"http\:\/\/www\.w3\.org\/1999\/xlink"/)){
            source = source.replace(/^<svg/, '<svg xmlns:xlink="http://www.w3.org/1999/xlink"');
        }
        var url = "data:image/svg+xml;charset=utf-8," + encodeURIComponent(source);
        debugger;
        // Saving wih the "FileSaver.js"
        console.log("       --Saving as "+ export_type);
        saveAs(new Blob([source], {type:"application/svg+xml"}), "clustpro_heatmap."+ export_type); // saving in the user passed format.
    },

    refreshRowDendogram: function(d,el,x,rowNewickSting, colNewickString,instance){
        var clusterSwapArray_1 =x.clusters.slice(d.rowRange.startRow, d.rowRange.endRow+1);
        var clusterSwapArray_2 = x.clusters.slice(d.siblingRowRange.startRow, d.siblingRowRange.endRow+1);
        var matrixDataArray_1 = x.matrix.data.slice(d.rowRange.startRow * x.matrix.cols.length, ((d.rowRange.endRow+1)*x.matrix.cols.length));
        var matrixDataArray_2 = x.matrix.data.slice(d.siblingRowRange.startRow*x.matrix.cols.length, (d.siblingRowRange.endRow+1)*x.matrix.cols.length);
        var matrixMergeArray_1 = x.matrix.merged.slice(d.rowRange.startRow * x.matrix.cols.length, ((d.rowRange.endRow+1)*x.matrix.cols.length));
        var matrixMergeArray_2  = x.matrix.merged.slice(d.siblingRowRange.startRow*x.matrix.cols.length, (d.siblingRowRange.endRow+1)*x.matrix.cols.length);
        // ownClusterCounter should always start with the smaller rowIndex (d.rowRange.startRow,d.siblingRowRange.startRow)
        ownClusterCounter = d.rowRange.startRow < d.siblingRowRange.startRow ? d.rowRange.startRow : d.siblingRowRange.startRow;
        matrixDataCounter = d.rowRange.startRow < d.siblingRowRange.startRow ? d.rowRange.startRow *  x.matrix.cols.length : d.siblingRowRange.startRow * x.matrix.cols.length;
        matrixMergeCounter = d.rowRange.startRow < d.siblingRowRange.startRow ? d.rowRange.startRow *  x.matrix.cols.length : d.siblingRowRange.startRow * x.matrix.cols.length;
        //Swap the cluster array.
        x.clusters = d.rowRange.startRow > d.siblingRowRange.startRow ? this.arraySwap(x,clusterSwapArray_1,clusterSwapArray_2,ownClusterCounter) : // If the line clicked is the lower sibling
                this.arraySwap(x,clusterSwapArray_2, clusterSwapArray_1,ownClusterCounter); // If the line clicked is the upper sibling.
        // Swap the Matrix Data array + Swap the Merged Data
        x.matrix = d.rowRange.startRow > d.siblingRowRange.startRow ? this.dataMatrixSwap(x,matrixDataArray_1,matrixDataArray_2,matrixMergeArray_1,matrixMergeArray_2,matrixDataCounter,matrixMergeCounter): // If the line clicked is the lower sibling
                this.dataMatrixSwap(x, matrixDataArray_2, matrixDataArray_1, matrixMergeArray_2, matrixMergeArray_1, matrixDataCounter, matrixMergeCounter); // If the line clicked is the upper sibling.
        rowNewickSting = this.stringSwap(d,rowNewickSting); //refresh newick string.
        x.dendnw_row[0] = rowNewickSting;
        this.doRenderValue(el,x,rowNewickSting,colNewickString,instance, x.matrix.merged, false);
    },

    refreshColDendogram: function(d,el,x,rowNewickSting, colNewickString, instance){
        var columnRangeClicked = d.columnRange;
        var siblingColumnRange = d.siblingColumnRange;
        if(columnRangeClicked.start < siblingColumnRange.start){
            x.matrix = this.columnMatrixSwap(x,columnRangeClicked,siblingColumnRange);
            x.matrix.cols = this.refreshColumns(x,columnRangeClicked,siblingColumnRange);
        }
        else{
            x.matrix = this.columnMatrixSwap(x,siblingColumnRange, columnRangeClicked);
            x.matrix.cols = this.refreshColumns(x, siblingColumnRange, columnRangeClicked);
        }
        colNewickString = this.stringSwap(d,colNewickString); //refresh newick string.
        x.dendnw_col[0] = colNewickString; //refresh newick string.
        this.doRenderValue(el,x,rowNewickSting, colNewickString, instance, x.matrix.merged, false);
    },


    // HELPER FUNCTIONS ------------

    refreshColumns : function(x,columnRange1, columnRange2){
        debugger;
        swap1 = x.matrix.cols.slice(columnRange1.start, columnRange1.end ==null ? columnRange1.start+1 : columnRange1.end +1);
        swap2 = x.matrix.cols.slice(columnRange2.start, columnRange2.end == null? columnRange2.start+1 : columnRange2.end +1);
        var columns = x.matrix.cols.slice(0,columnRange1.start);
        columns = columns.concat(swap2);
        columns = columns.concat(swap1);
        if(columnRange2.end == null) {
            if(columns.length < x.matrix.cols.length) {
                columns = columns.concat(x.matrix.cols.slice(columns.length,x.matrix.cols.length));
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
                columns = columns.concat(x.matrix.cols.slice(columnRange2.end+1, x.matrix.cols.length));
            }
        }
        return  columns;
    },

    columnMatrixSwap: function(x, columnRange1, columnRange2 ){
        debugger;
        for(var i=0; i< x.matrix.data.length; i= i+ x.matrix.cols.length){
            columnstobeSwaped1 = x.matrix.data.slice(i+columnRange1.start, columnRange1.end == null ? i+columnRange1.start+1 : i+columnRange1.end +1 );
            columnstobeSwaped2 = x.matrix.data.slice(i+columnRange2.start, columnRange2.end == null ? i+columnRange2.start+1 : i+columnRange2.end +1 );
            mergecolumnstobeSwapped1 = x.matrix.merged.slice(i+columnRange1.start, columnRange1.end == null ? i+columnRange1.start+1 : i+columnRange1.end +1 );
            mergeColumnstoBeSwapped2 = x.matrix.merged.slice(i+columnRange2.start, columnRange2.end == null? i+columnRange2.start+1 : i+columnRange2.end +1 );
            var newArray = x.matrix.data.slice(i,i+columnRange1.start);
            var newMergeArray = x.matrix.merged.slice(i,i+columnRange1.start);
            newArray = newArray.concat(columnstobeSwaped2);
            newMergeArray = newMergeArray.concat(mergeColumnstoBeSwapped2);
            newArray = newArray.concat(columnstobeSwaped1);
            newMergeArray = newMergeArray.concat(mergecolumnstobeSwapped1);
            newArray = newArray.concat(columnRange2.end == null ? x.matrix.data.slice(columnRange2.start+1,i+x.matrix.cols.length) : x.matrix.data.slice(columnRange2.end + 1, i+x.matrix.cols.length));
            newMergeArray = newMergeArray.concat(columnRange2.end == null ? x.matrix.merged.slice(i+columnRange2.start+1,i+x.matrix.cols.length) : x.matrix.merged.slice(i+columnRange2.end +1 , i+x.matrix.cols.length));
            var newArraycounter = 0;
            for(var j=i; j< i+x.matrix.cols.length; j++) {
                x.matrix.data[j] = newArray[newArraycounter];
                x.matrix.merged[j] = newMergeArray[newArraycounter];
                newArraycounter++;
            }
        }
        return x.matrix;
    },

    stringSwap: function(d,newickString){
        var clickedString = d.correspondingString;
        var siblingString = d.siblingCorrespondingString;
        newickString = newickString.replace("("+clickedString+",","(clicked,");
        newickString = newickString.replace(","+clickedString+")",",clicked)");
        newickString = newickString.replace("("+siblingString+",","(sibling,");
        newickString = newickString.replace(","+siblingString+")",",sibling)");
        if(clickedString.length != 1) {
            newickString = newickString.replace(clickedString,"clicked");
        }
        if(siblingString.length != 1) {
            newickString = newickString.replace(siblingString,"sibling");
        }
        newickString = newickString.replace("clicked",siblingString);
        newickString = newickString.replace("sibling",clickedString);
        return newickString;
    },

    dataMatrixSwap: function(x,matrixDataArray_1, matrixDataArray_2, matrixMergeArray_1, matrixMergeArray_2, matrixDataCounter, matrixMergeCounter){
        // Can be made even more efficent with the help of array splicing and array concatination operations.
        for(var i=0; i<matrixDataArray_1.length; i++) {
            x.matrix.data[matrixDataCounter] = matrixDataArray_1[i];
            x.matrix.merged[matrixMergeCounter] = matrixMergeArray_1[i];
            matrixDataCounter++;
            matrixMergeCounter++;
        }
        for(var i=0; i<matrixDataArray_2.length; i++) {
            x.matrix.data[matrixDataCounter] = matrixDataArray_2[i];
            x.matrix.merged[matrixMergeCounter] = matrixMergeArray_2[i];
            matrixDataCounter++;
            matrixMergeCounter++;
        }
        return x.matrix;
    },

    arraySwap: function(x, array1, array2, ownClusterCounter) {
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

    hextorgb: function(hex){
        var hex2 = hex.replace('#','');
        var bigint = parseInt(hex2, 16);
        var r = (bigint >> 16) & 255;
        var g = (bigint >> 8) & 255;
        var b = bigint & 255;
        return "rgba(" + r + "," + g + "," + b + ",1)";
    },

    clusterChangeInformation: function(cluster, cluster_change_rows){
        var current_cluster_value = cluster[0];
        var startRow = 0;
        for(var i=0; i<cluster.length; i++){
            if(current_cluster_value != cluster[i]){
                cluster_change_rows.push({ylocation:i, cluster:current_cluster_value,
                    rowInformation:{startRow:startRow, endRow:i-1}}); //cluster changes at this y-Location.
                current_cluster_value = cluster[i];
                startRow = i;
            }
        }
        //adding information for last cluster
        cluster_change_rows.push({ylocation:null, cluster:current_cluster_value,
            rowInformation:{startRow:startRow , endRow:cluster.length-1}});
        return cluster_change_rows;
    }
});