#' <Add Title>
#'
#' <Add Description>
#'
#' @import htmlwidgets
#' @import ggplot2
#' @import pracma
#' @import Biobase
#' @import Mfuzz
#' @import clusterSim
#' @import doSNOW
#' @import pheatmap
#' @import gplots
#' @import ctc
#' @import jsonlite

#' @export
test_package <- function(){
  graphic_type <<- "tif"
  br <- min(diff(c(0,2,4,6,8,10))/40)
  color_spectrum_unqiue_breaks(c(0,2,4,6,8,10),c("grey","khaki2","yellow","orange", "red"),br)

  matrix <- iris[-ncol(iris)]
  return(clustering(matrix,method = "kmeans",  min_k = 2, max_k = 10))
}


#' @export
clustpro <- function(width = NULL, height = NULL) {




  rs <- test_package()
#  rs <- clustering(matrix,method = "kmeans")
  # forward options using x

  # x = list(
  #   rows = rs$cluster[['dendnw_row']],
  #   cols = rs$cluster[['dendnw_col']],
  #   matrix = rs$matrix[,colnames(rs$matrix)!='cluster'],
  #   owncluster=rs$matrix[,'cluster']
  # )
   x = rs

 # library(rjson)
  #print(x)

 # write(x, file = "data.txt")

  # pass the data and settings using 'x'
  # x <- list(
  #   data = data,
  #   settings = settings
  # )

  widget <- htmlwidgets::createWidget('clustpro',
                            rs,
                            width = width,
                            height = height,
                            sizingPolicy = sizingPolicy(browser.fill = TRUE
                                                        )
                            )
  show(widget)
  saveWidget(widget, file=paste(getwd(),'widget.html',sep='/'))
}

#' Shiny bindings for clustpro
#'
#' Output and render functions for using clustpro within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a clustpro
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name clustpro-shiny
#'
#' @export
clustproOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'clustpro', width, height, package = 'clustpro')
}

#' @rdname clustpro-shiny
#' @export
renderClustpro <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, clustproOutput, env, quoted = TRUE)
}


#####################


# require(ggplot2)
# require(pracma)
# require(Biobase)
# require(Mfuzz)
# require(clusterSim)
# require(doSNOW)
# require(pheatmap)
# require(gplots)
# require(ctc) ## hclust to Newick format


distributions_histograms <- function(data, title) {
#  rvr_min <- floor(min(data, na.rm = TRUE))
#  rvr_max <- ceiling(max(data, na.rm = TRUE))
  for (i in 1:ncol(data)) {
    x <- data[, i, drop = FALSE]
    h <- histss(x[, 1], n = (nrow(data)/10), plotting = FALSE)
    title_add <- i
    if (!is.null(colnames(data)))
      title_add <- colnames(data)[i]
    initialize_graphic(paste(title, title_add, sep = "_"))
    g <- ggplot(x, aes_string(x = colnames(x))) + stat_bin(breaks = h$breaks)
    show(g)
    dev.off()
  }
}

order_dataframe_by_list <- function(x, list, col, reverse = FALSE) {
  if (reverse) {
    list <- rev(list)
  }
  order_data <- x[x[, col] == list[1], ]
  for (item in list[2:length(list)]) {
    order_data <- rbind(order_data, x[x[, col] == item, ])
  }
  return(order_data)
}

findk_cmeans <- function(k) {
  tryCatch({
    cluster <- mfuzz(minimalSet, c = k, m = fp)$cluster
    db_score <- index.DB(clustering_data, cluster, centrotypes = "centroids",
                         p = 2, q = 2)
    return(c(k, db_score$DB))
  }, warning = function(w) {
    print(paste('findk_cmeans',w,sep=': '))
    return(NA)
  }, error = function(e) {
    print(paste('findk_cmeans',e,sep=': '))
    return(NA)
  })
}

findk_kmeans <- function(k) {
  tryCatch({
    cluster <- kmeans(clustering_data, k, iter.max = 1000)
    db_score <- index.DB(clustering_data, cluster$cluster, centrotypes = "centroids",
                         p = 2, q = 2)
    return(c(k, db_score$DB))
  }, warning = function(w) {
    print(paste('findk_kmeans',w,sep=': '))
    return(NA)
  }, error = function(e) {
    print(paste('findk_kmeans',e,sep=': '))
    return(NA)
  })
}

get_best_k <- function(clustering_data, min_k, max_k, method) {
  if (nrow(clustering_data) < max_k) {
    max_k <- nrow(clustering_data)
    print("max_k larger the rows in clustering_data.")
    print(paste("max_k was set to ", max_k, sep = ""))
  }
  iterations <<- max_k
  clustering_data <<- clustering_data


  cl <- makeCluster(4, type = "SOCK")

  switch(method,
         kmeans = {
           findk <<- findk_kmeans
           clusterExport(cl, c("findk","kmeans", "index.DB","clustering_data"))
         },
         cmeans = {
           minimalSet <<- ExpressionSet(assayData = as.matrix(clustering_data))
           fp <<- mestimate(minimalSet)
           findk <<- findk_cmeans
           clusterExport(cl, c("findk", "mfuzz","cmeans", "index.DB", "minimalSet", "fp","clustering_data"))
         })

  registerDoSNOW(cl)
  getDoParWorkers()
  getDoParName()
  getDoParVersion()
  db_list <- t(foreach(k = c(min_k:iterations), .combine = "cbind") %dopar% {
    findk(k)
  })
  stopCluster(cl)
  return(db_list)

}

clustering <- function(clustering_data, min_k = 2, max_k = 100, fixed_k = -1, method = "kmeans") {
  # fixed_k=-1 clustering_data <- matrix
  #method = "cmeans"
  if(F){
    clustering_data <- matrix
    min_k = 2
    max_k = 100
    fixed_k = -1
    method = "kmeans"
  }
  distributions_histograms(clustering_data, "distributions_histograms")

  if (fixed_k > 0) {
    k <- fixed_k
  } else {
    db_list <- get_best_k(clustering_data, min_k, max_k, method)
    initialize_graphic(paste("db_index_ratio_div_ratio", sep = ""))
    plot(db_list, type = "b")
    dev.off()
    k <- db_list[db_list[, 2] == max(db_list[, 2],na.rm=TRUE), ][1]
  }
  set.seed(1)
  cluster_cols <- F
  cluster_rows <- T

  switch(method, kmeans = {
    clustering_result <- kmeans(clustering_data, k, iter.max = 1000)
  }, cmeans = {
    clustering_result <- mfuzz(minimalSet, c = k, m = fp)
  })

  cluster <- clustering_result$cluster
  df <- cbind(clustering_data,cluster)

  cluster_centers <- aggregate(df[,-ncol(df)],by=df['cluster'],FUN=median, na.rm=TRUE)
  rownames(cluster_centers) <- sapply(cluster_centers$cluster,as.character)
  cluster_centers$cluster <- NULL

  set.seed(1234)
  d_rows <- dist(cluster_centers[-1], method = "euclidean") # distance matrix
  d_cols <- dist(t(cluster_centers[-1]), method = "euclidean") # distance matrix

  row_dend <- hclust(d_rows, method="ward.D2")
  col_dend <- hclust(d_cols, method="ward.D2")

  col_dend_nw <- hc2Newick(col_dend)
  col_dend_nw <- gsub(":\\d+\\.{0,1}\\d*","", col_dend_nw)

  row_dend_nw <- hc2Newick(row_dend)
  row_dend_nw <- gsub(":\\d+\\.{0,1}\\d*","", row_dend_nw)
  col_dend <- as.dendrogram(col_dend)
  row_dend <- as.dendrogram(row_dend)

  ordered_df <- NULL
  if(class(row_dend)=="dendrogram"){
    for (c in order.dendrogram(row_dend)){
      if(is.null(ordered_df)){ordered_df <- df[df$cluster==c,]}
      else{ ordered_df <- rbind(ordered_df,df[df$cluster==c,])}
    }
  }

  if(class(col_dend)=="dendrogram"){
    ordered_df <- ordered_df[,c(order.dendrogram(col_dend),ncol(ordered_df))]
  }


  ordered_df_wo_cluster <- ordered_df[colnames(ordered_df)[!colnames(ordered_df) %in% c('cluster')]]
  color_matrix <- as.data.frame(apply(ordered_df_wo_cluster,c(1,2),get_color)) ## without id column
  colnames(color_matrix) <- colnames(ordered_df_wo_cluster)
  rownames(color_matrix) <- rownames(ordered_df)

  # ordered_df_wo_cluster,
  # clusters = as.vector(unlist(ordered_df['cluster'])),
  # dendrogram = "row",
  # Rowv = TRUE ,
  # Colv = TRUE,
  # dendnw_row = row_dend_nw,
  # dendnw_col = col_dend_nw,
  #
  # color_matrix

  #############


  xaxis_height = 80
  yaxis_width = 120
  xaxis_font_size = NULL
  yaxis_font_size = NULL
  brush_color = "#0000FF"
  show_grid = TRUE
  anim_duration = 500

  options <- NULL
  options <- c(options, list(
    xaxis_height = xaxis_height,
    yaxis_width = yaxis_width,
    xaxis_font_size = xaxis_font_size,
    yaxis_font_size = yaxis_font_size,
    brush_color = brush_color,
    show_grid = show_grid,
    anim_duration = anim_duration
  ))

  #############
  payload <- list(
    matrix = list(data=as.matrix(ordered_df_wo_cluster), rows=rownames(ordered_df_wo_cluster), cols=colnames(ordered_df_wo_cluster), dim = dim(ordered_df_wo_cluster)),
    options = options,
    clusters = as.vector(unlist(ordered_df['cluster']))
  )

  if(class(row_dend_nw)=="character"){
    payload <- c(payload, list(dendnw_row = row_dend_nw))
  }
  if(class(col_dend_nw)=="character"){
    payload <- c(payload, list(dendnw_col = col_dend_nw))
  }

  if(!is.null(color_matrix)){
    payload <- c(payload, list(colors=list(data = as.matrix(color_matrix), rows=rownames(color_matrix), cols=colnames(color_matrix), dim = dim(color_matrix))))
  }


  json_payload = toJSON(payload, pretty = TRUE)
  write(json_payload, file = "payload.json", ncolumns = 1, append = FALSE)

  return(json_payload)
  #  opar <- par(mfrow = c(1, 2))
  #  plot(fit_row,  hang=-1)
  # # rect.hclust(fit1, 2, border="red")
  #  plot(fit_cols, hang=-1)
  # # rect.hclust(fit2, 2, border="red")
  #  par(opar)
  # clustering_data$cluster <- clustering_result[['cluster']]
  # ordered_data <- clustering_data
  # switch(method, kmeans = {
  #
  #   if (cluster_rows) {
  #     dendrogram_row <- as.dendrogram(fit_row)
  #     row_dendrogram_order <- order.dendrogram(dendrogram_row)
  #     ordered_data <- order_dataframe_by_list(ordered_data, row_dendrogram_order,
  #                                             "cluster")
  #     clustering_result$dendnw_row<- hc2Newick(fit_row, flat=TRUE)
  #   }
  #   if (cluster_cols) {
  #     dendrogram_col <- as.dendrogram(fit_cols)
  #     col_dendrogram_order <- order.dendrogram(dendrogram_col)
  #     ordered_data[,1:(ncol(ordered_data)- 1)] <- ordered_data[, col_dendrogram_order]
  #     clustering_result$dendnw_col<- hc2Newick(fit_col, flat=TRUE)
  #   }
  # })
  #
  # write.table(ordered_data, file = paste("clustering_means_k_", k,
  #                                        ".txt", sep = ""), sep = "\t", col.names = NA)

  #######

  ### finding breaks for cluster blocks! Were should be insert a black line
  # cluster_infos <- data.frame(cluster_number = unique(ordered_data$cluster))
  # cluster_infos$amount <- table(ordered_data$cluster)[cluster_infos$cluster_number]
  #
  # h_space = c()
  # h_pos = 1
  # for (row_id in c(1:nrow(cluster_infos))) {
  #   if (h_pos == 1)
  #     h_space[h_pos] <- 0 else h_space[h_pos] <- (h_space[h_pos - 1] + cluster_infos[h_pos - 1, "amount"])
  #     h_pos <- h_pos + 1
  # }
  # h_space <- h_space[c(2:length(h_space))]

  #######


 # matrix <- as.matrix(ordered_data[,colnames(ordered_data)!='cluster'])
 # mat = matrix(c(4, 2, 3, 1), 2, 2, byrow = TRUE)
 # wid = lcm(c(3, 8))
 # hei = lcm(c(3, 12))
  # initialize_graphic(paste("heatmap_mean_k_", k, "_ratio_div_ratio",sep = ""))
  # heatmap.2(matrix, col = palette, breaks = colors, density.info = "none", dendrogram = "non",
  #           Rowv = FALSE, Colv = FALSE, symkey = FALSE, cexRow = 1.5, cexCol = 1.5, trace = "none",
  #           srtCol = 45, keysize = 2, rowsep = h_space, lmat = mat, lhei = hei, lwid = wid,
  #           labRow = NA)
  # # sepcolor='black', sepwidth=c(0.005,0.005),
  # dev.off()

 ## return(list(matrix = ordered_data, cluster = clustering_result, k = k))
}

###

#' Function to to define the color spectrum for heatmaps
#'
#' This function allows you to define the color spectrum for heatmaps.
#' @param values should be a list which define the breaks of the color space. color_spect should be a list of color. Keep in mean that there must be 1 more board in the vaules list than color in color_spect.
#' @keywords color spectrum heatmaps
#' @export
#' @examples
#' color_spectrum()

color_spectrum <- function(values, color_spect){
  index <- 1
  palette <- c()
  colors <- c()
  while(index<length(values)){
    colors <- c(colors,seq(values[index],values[index+1],length=100))
    index <- index +1
  }
  palette <- colorRampPalette(color_spect)(n = ((length(values)-1)*100)-1)
  ## standard global variables can define with <<-. However, in this case the variable were blocked by the enviroment so I have to use the
  ## assign function. The first argument is the global variable name, second the local variable in function and the last the target enviroment
  assign('colors', colors, envir = .GlobalEnv)
  assign('palette', palette, envir = .GlobalEnv)
}


#' Function to to define the color spectrum for heatmaps
#'
#' This function allows you to define the color spectrum for heatmaps.
#' @param values should be a list which define the breaks of the color space. color_spect should be a list of color. Keep in mean that there must be 1 more board in the vaules list than color in color_spect.
#' @keywords color spectrum heatmaps
#' @export
#' @examples
#' color_spectrum()

color_spectrum_unqiue_breaks <- function(values, color_spect, shift_factor=0.0000000001){
  index <- 1
  palette <- c()
  colors <- c()
  while(index<length(values)){
    colors <- c(colors,seq(values[index]+shift_factor,values[index+1]-shift_factor,length=100))
    index <- index +1
  }
  colors <- unique(colors)
  palette <- colorRampPalette(color_spect)(n = ((length(values)-1)*100)-1)
  ## standard global variables can define with <<-. However, in this case the variable were blocked by the enviroment so I have to use the
  ## assign function. The first argument is the global variable name, second the local variable in function and the last the target enviroment
  assign('colors', colors, envir = .GlobalEnv)
  assign('palette', palette, envir = .GlobalEnv)
}


#' Function to to define the color spectrum for heatmaps
#'
#' This function allows you to define the color spectrum for heatmaps.
#' @param values should be a list which define the breaks of the color space. color_spect should be a list of color. Keep in mean that there must be 1 more board in the vaules list than color in color_spect.
#' @keywords color spectrum heatmaps
#' @export
#' @examples
#' color_spectrum()

color_spectrum_local <- function(values, color_spect){
  index <- 1
  palette <- c()
  colors <- c()
  while(index<length(values)){
    colors <- c(colors,seq(values[index],values[index+1],length=100))
    index <- index +1
  }
  palette <- colorRampPalette(color_spect)(n = ((length(values)-1)*100)-1)
  return(c(colors=list(colors),palette=list(palette)))
}

#' Function to initialize a graphic
#'
#' This function allows you to initialize a graphic
#' @param title , project, type, number
#' @keywords initialize graphic
#' @export
#' @examples
#' initialize_graphic()
initialize_graphic <- function(title,type = graphic_type,...){
  gap_free_title <- gsub('\\s','_', title)
  switch(type,
         svg={
           svg(paste(gap_free_title,'.svg',sep=''),width = 10, height = 10)
         },
         tif={
           tiff(paste(gap_free_title,'.tif',sep=''),width = 2000, height = 2000,res = 200, compression='lzw')
         },
         pdf={
           pdf(paste(gap_free_title,'.pdf',sep=''),width = 10, height = 10)
         }
  )
}



#' Function to get color
#'
#' xxxxxx
#' @param x
#' @keywords get color
#' @export
#' @examples
#' get_color()

get_color <- function(x){
  i=1
  c = colors[i]
  while(c<x){
    i=i+1
    c = colors[i]
  }

  return(palette[i-1])
}


####




#clustpro()
#rs <- test_package()
#names(rs$cluster)
#rs$cluster["dendnw_row"]

