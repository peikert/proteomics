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

        el.innerHTML = "";
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

        // Preparing the needed data objects here:
        var location_object_array = []; // Document it's purpose here.
        var cluster_change_rows = []; // Document it's purpose here.
        var cluster = x.clusters; //Document it's purpose here.
        // Calculate at which row index where the cluster value changes:
        cluster_change_rows = this.clusterChangeInformation(cluster, cluster_change_rows);
        var rowDendLinesListner = null;
        var colDendLinesListner = null;

        
        var heatMapObject = clustpro(el, x, x.options, location_object_array, cluster_change_rows,cluster, rowDendLinesListner, colDendLinesListner);
        var hm = heatMapObject[0];
        rowDendLinesListner = heatMapObject[1];
        colDendLinesListner = heatMapObject[2];


        rowDendLinesListner.on("click", function(d,i)
        {
            console.log("you clicked a line");
            console.log(i);
            console.log(d);
            self.refreshData(d,el,x, rowNewickSting, colNewickString, instance);

        });


        colDendLinesListner.on("click",function (d,i)
        {
            console.log("you clicked a column dendogram line");
            console.log(i);
            console.log(d);
            self.refreshColumn(d,el,x,rowNewickSting,colNewickString,instance);
        });


        },


    refreshData: function(d,el,x,rowNewickSting, colNewickString,instance){
        debugger;
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
        this.doRenderValue(el,x,rowNewickSting,colNewickString,instance, x.matrix.merged);
    },

    refreshColumn: function(d,el,x,rowNewickSting, colNewickString, instance){
        debugger;
        var columnRangeClicked = d.columnRange;
        var siblingColumnRange = d.siblingColumnRange;

        if(columnRangeClicked.start < siblingColumnRange.start){

        }
        else{

        }
    },


    // HELPER FUNCTIONS

    stringSwap: function(d,newickString){
        var clickedString = d.correspondingString;
        var siblingString = d.siblingCorrespondingString;
        newickString = newickString.replace(clickedString,"clicked");
        newickString = newickString.replace(siblingString,"sibling");
        newickString = newickString.replace("clicked",siblingString);
        newickString = newickString.replace("sibling",clickedString);
        return newickString;
    },

    dataMatrixSwap: function(x,matrixDataArray_1, matrixDataArray_2, matrixMergeArray_1, matrixMergeArray_2, matrixDataCounter, matrixMergeCounter){
        // Can be made even more efficent with the help of array splicing and array concatination operations.
        for(var i=0; i<matrixDataArray_1.length; i++)
        {
            x.matrix.data[matrixDataCounter] = matrixDataArray_1[i];
            x.matrix.merged[matrixMergeCounter] = matrixMergeArray_1[i];
            matrixDataCounter++;
            matrixMergeCounter++;
        }
        for(var i=0; i<matrixDataArray_2.length; i++)
        {
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