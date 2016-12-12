HTMLWidgets.widget({
    name: "clustpro",
    type: "output",

    initialize: function(el, width, height) {
        console.log("Last Updated: August 28th [13:55] (numair.mansur@gmail.com)");
        debugger;
        return {
            lastTheme: null,
            lastValue: null
        };
    },
    renderValue: function(el, x, instance) {
        var rowNewickString = x.dendnw_row[0];
        var colNewickString = x.dendnw_col[0];
        x.matrix.data = [].concat.apply([],x.matrix.data); // Flattening the data array.
        this.doRenderValue(el, x, rowNewickString, colNewickString, instance, null, false);
    },
    resize: function(el, width, height, instance) {
        d3.select(el).select("svg")
            .attr("width", width)
            .attr("height", height);
//
        instance.force.size([width, height]).resume();
        this.doRenderValue(el, instance.lastValue, instance);  // FIX THIS >:/
    },


    doRenderValue: function(el, x, rowNewickSting, colNewickString, instance, newMerged,scrollable){

        { // This should be done when new values are given by the user.
            // document.getElementById(el.id).style.height = "1000px"; //experimental value
            // document.getElementById(el.id).style.width = "700px"; //experimental value
            // document.getElementsByTagName("body")[0].style.overflow = "scroll"; // Expreimental Value
        }

        // el.clientWidth = 1000;  //experimental values
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
        // Calculate at which row index where the cluster value changes:
        cluster_change_rows = this.clusterChangeInformation(cluster, cluster_change_rows);
        var rowDendLinesListner = null;
        var colDendLinesListner = null;
        var heatMapObject = clustpro(el, x, x.options, location_object_array, cluster_change_rows,cluster, rowDendLinesListner, colDendLinesListner);


        // Save the SVGs here.
        debugger;
        // STEPS:
        // 1)  Generate a drop down menu or a button that gives the option to save the svg in different
        //      formats. At the moment i am only going to create a button  (IN PROGRESS)
        // Add multiple options here.
        select = document.createElement("select");
        select.options.add(new Option("Saving Options",0));
        select.options.add(new Option("Save RowDend SVG",1));
        select.options.add(new Option("Save ColDend SVG",2));
        select.options.add(new Option("Save ColorMap SVG",3));
        select.options.add(new Option("Save as PNG",4));
        select.options.add(new Option("Testing", 5));
        select.options.add(new Option("MAKE IT SCROLLABLE", 6));
        select.options.add(new Option("Original Size", 7));


        select.id = "selectionbox";
        select.onchange = function (value){
            debugger;
            if(value.srcElement.value == 1){
                svgString = "dendrogram rowDend";
                var url = self.saveSvg(svgString);
                var win = window.open(url, "_blank");
                win.focus();
            }
            else if (value.srcElement.value == 2){
                svgString = "dendrogram colDend";
                var url = self.saveSvg(svgString);
                var win = window.open(url, "_blank");
                win.focus();
            }
            else if (value.srcElement.value == 3){
                svgString = "colormap";
                var url = self.saveSvg(svgString);
                var win = window.open(url, "_blank");
                win.focus();
            }
            else if (value.srcElement.value == 6){
                debugger;
                // Making scrollable
                var new_html_widget = el;
                new_html_widget.style.width = "1600px";
                new_html_widget.style.height = "2000px";
                x.options.yaxis_width[0] = 220;
                self.doRenderValue(new_html_widget, x, rowNewickSting, colNewickString, instance, newMerged, true);
            }
            else if (value.srcElement.value == 7){
                debugger;
                // Going back to original
                var old_html_widget = el;
                old_html_widget.style.width = "100%";
                old_html_widget.style.height = "100%";
                x.options.yaxis_width[0] = 120;
                self.doRenderValue(old_html_widget, x, rowNewickSting, colNewickString, instance, newMerged, false);
            }
        };
        document.getElementById("htmlwidget-1d9f9b9fdca3023baa83").appendChild(select);
        // 2)   Just try to save the SVGs somewhere.
        //              - First try to do it without any external libraries. If
        //                that don't work out then try out some libraries.
        //              - Take a look into FileSaver.js if nothing is working out.
        // 3)   Save the SVGs as other file formats (jpeg, png etc).
        // 4)   Enjoy the new feature.

        var hm = heatMapObject[0];
        rowDendLinesListner = heatMapObject[1];
        colDendLinesListner = heatMapObject[2];
        rowDendLinesListner.on("click", function(d,i) {
                console.log("you clicked a line");
                console.log(i);
                console.log(d);
                self.refreshRowDendogram(d,el,x, rowNewickSting, colNewickString, instance);
            });
        colDendLinesListner.on("click",function (d,i) {
                console.log("you clicked a column dendogram line");
                console.log(i);
                console.log(d);
                self.refreshColDendogram(d,el,x,rowNewickSting,colNewickString,instance);
            });
        },
    doSomething: function(){
        console.log("you clicked a button");
    },
    saveSvg: function(svgString){
        var svg = document.getElementsByClassName(svgString)[0];
        var serializer = new XMLSerializer();
        var source = serializer.serializeToString(svg);
        if(!source.match(/^<svg[^>]+xmlns="http\:\/\/www\.w3\.org\/2000\/svg"/)){
            source = source.replace(/^<svg/, '<svg xmlns="http://www.w3.org/2000/svg"');
        }
        if(!source.match(/^<svg[^>]+"http\:\/\/www\.w3\.org\/1999\/xlink"/)){
            source = source.replace(/^<svg/, '<svg xmlns:xlink="http://www.w3.org/1999/xlink"');
        }
        // source = '<?xml version="1.0" standalone="no"?>\r\n' + source;
        source = '<?xml version="1.0"?>\r\n' + '<?xml-stylesheet href="lib/clustpro-0.0.1/./clustpro.css" type="text/css"?>\r\n' + source;
        var url = "data:image/svg+xml;charset=utf-8,"+encodeURIComponent(source);
        return url;

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
        for(var i=0; i<x.matrix.data.length; i=i+4){
            columnstobeSwaped1 = x.matrix.data.slice(i+columnRange1.start, columnRange1.end ==null ? i+columnRange1.start+1 : i+columnRange1.end +1 );
            columnstobeSwaped2 = x.matrix.data.slice(i+columnRange2.start, columnRange2.end == null? i+columnRange2.start+1 : i+columnRange2.end +1 );
            mergecolumnstobeSwapped1 = x.matrix.merged.slice(i+columnRange1.start, columnRange1.end ==null ? i+columnRange1.start+1 : i+columnRange1.end +1 );
            mergeColumnstoBeSwapped2 = x.matrix.merged.slice(i+columnRange2.start, columnRange2.end == null? i+columnRange2.start+1 : i+columnRange2.end +1 );
            var newArray = x.matrix.data.slice(i,i+columnRange1.start);
            var newMergeArray = x.matrix.merged.slice(i,i+columnRange1.start);
            newArray = newArray.concat(columnstobeSwaped2);
            newMergeArray = newMergeArray.concat(mergeColumnstoBeSwapped2);
            newArray = newArray.concat(columnstobeSwaped1);
            newMergeArray = newMergeArray.concat(mergecolumnstobeSwapped1);
            newArray = newArray.concat(columnRange2.end == null ? x.matrix.data.slice(columnRange2.start+1,i+4) : x.matrix.data.slice(columnRange2.end,i+4));
            newMergeArray = newMergeArray.concat(columnRange2.end == null ? x.matrix.merged.slice(i+columnRange2.start+1,i+4) : x.matrix.merged.slice(i+columnRange2.end,i+4));
            var newArraycounter = 0;
            for(var j=i; j<i+4;j++) {
                x.matrix.data[j] =newArray[newArraycounter];
                x.matrix.merged[j] = newMergeArray[newArraycounter];
                newArraycounter++;
            }
        }
        return x.matrix;
    },

    stringSwap: function(d,newickString){
        var clickedString = d.correspondingString;
        var siblingString = d.siblingCorrespondingString;
        newickString = clickedString.length == "1" ? newickString.search(clickedString +",") != -1 ? newickString.replace(clickedString+",","clicked,"): newickString.replace(clickedString+")","clicked)")  : newickString.replace(clickedString,"clicked");
        newickString = siblingString.length == "1" ? newickString.search(siblingString +",") != -1 ? newickString.replace(siblingString+",","sibling,"): newickString.replace(siblingString+")","sibling)")  : newickString.replace(siblingString,"sibling");
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