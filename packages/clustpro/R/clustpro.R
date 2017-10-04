#' Example function 01
#'
#' A theoretical proteomics dataset composed of 1000 human proteins (UniProt accessionn umbers) and random choosen values will be used to call the clustpro() main function.
#' @return see clustpro() function output
#' @export
#'
clustpro_example <- function(){
  matrix <- datasets::iris[-ncol(datasets::iris)]
  max(matrix)
  # intervals <- c(-0.1,2,4,6,8.1)
  color_list <- c("blue","lightblue","yellow", "red")
  heatmap_color <- setHeatmapColors(data=matrix,color_list = color_list ,auto=TRUE)
  heatmap_color$label_position <- c(0,2,4,6,8)

  info_list <- list()
  info_list[['id']]  <- rownames(matrix)
  info_list[['link']] <- NULL #paste('http://tritrypdb.org/tritrypdb/app/record/gene/',sapply(rownames(matrix),get_first_split_element,';'),sep='')
  info_list[['description']] <- NULL #rep('no description', nrow(matrix))

  return(
    clustpro(matrix=matrix,
                    method = "kmeans",
                    min_k = 2,
                    max_k = 100,
                    fixed_k = NULL,
                    perform_clustering = TRUE,
                    clusterVector = NULL,
                    rows = TRUE,
                    cols = TRUE,
                    tooltip = info_list,
                    save_widget = TRUE,
                    show_legend = FALSE,
                    color_legend = heatmap_color,
                    width = NULL,
                    height = NULL,
                    export_graphics = FALSE,
                    export_dir = NULL,
                    export_type = 'svg',
                    seed=1
    )
  )


  # return(clustering(matrix,method = "kmeans",  min_k = 2, max_k = 10))
}


#' Clustpro main function
#'
#' This function is used to start the clustering and visualisation process.
#' @param matrix 	numeric data.frame
#' @param method character; one of the following cluster methods: kmeans, cmeans
#' @param hclust_method character; one of the following cluster methods: "ward.D", "ward.D2", "single", "complete", "average" (= UPGMA), "mcquitty" (= WPGMA), "median" (= WPGMC) or "centroid" (= UPGMC)
#' @param min_k,max_k,fixed_k number of clusters, k; if fixed_k is a natural number > 0, k is set to fixed_k. Otherwise the a function is called to find the optimal k for this data in the range defined by the minimum and maximal k.
#' @param perform_clustering boolean; if true a clustering is performed
#' @param simplify_clustering boolean; if true a each cluster is represended by its mean values over all within the cluster itself.
#' @param clusterVector list or vector of natural number; for each row a cluster has to been given
#' @param rows,cols boolean; if true a hierarchical clustering for row / columns of the clustered matrix is performed
#' @param tooltip list of lists; list of lists containing information of each row e.g. a list for name, description.
#' @param save_widget boolean; if to TRUE html widget is saved as html page
#' @param color_legend list of lists; required lists: ticks and colors; ticks is a list of n breaks for the heatmap; colors is a list of n-1 colors; in addition a list for of position for shown labels can added  call label_position
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param export_graphics boolean; if TRUE grephics are exported
#' @param export_dir character; storage directory
#' @param export_type character; type of exported graphics, tested for tif and svg
#' @param seed natural number, useful for creating simulations or random objects that can be reproduced
#' @param cores natural number, number of nodes/cores used for parallelisation
#' @param show_legend boolean; if TRUE color legend is shown
#' @param useShiny if TRUE html widget is usable for shiny apps, otherwise clustering is returned to R
#' @return see clustpro() function output
#' @importFrom htmlwidgets createWidget sizingPolicy
#' @importFrom ctc hc2Newick
#' @importFrom jsonlite toJSON
#' @export
clustpro <- function(matrix,
                     method = "kmeans",
                     hclust_method = "ward.D2",
                     min_k = 2,
                     max_k = 10,
                     fixed_k = NULL,
                     perform_clustering = TRUE,
                     simplify_clustering = FALSE,
                     clusterVector = NULL,
                     rows = TRUE,
                     cols = TRUE,
                     tooltip = NULL,
                     save_widget = TRUE,
                     show_legend = FALSE,
                     color_legend = NULL,
                     width = NULL,
                     height = NULL,
                     export_graphics = FALSE,
                     export_dir = NULL,
                     export_type = 'svg',
                     seed = NULL,
                     cores = 2,
                     useShiny = TRUE) {

  #### proofing #####
  if(!class(matrix) %in% c('data.frame'))stop('matrix is no data.frame')
  if(!all(complete.cases(matrix)))stop('matrix is contains missing values')
  if(class(method) != 'character' | !method %in% c("kmeans","cmeans"))stop('method must be a string. options:"kmeans","cmeans"')
  if(!is.numeric(min_k))stop('min_k must be numeric')
  if(!is.numeric(min_k))stop('max_k must be numeric')
  if(!is.numeric(min_k))stop('fixed_k must be numeric')
  if(!is.logical(perform_clustering))
  if(!is.null(clusterVector) || (!class(clusterVector) %in% c("list","vector")) && length(clusterVector) != nrow(matrix)) stop('"clusterVector" must be NULL or of type "list/vector" with a length equal to the rows of the matrix')
  if(!is.logical(rows) & class(rows)!="hclust") stop('"rows" must be logical or of class hclust')
  if(!is.logical(cols) & class(cols)!="hclust") stop('"cols" must be logical or of class hclust')
  if(!is.null(tooltip) && class(tooltip)!='list') stop('"tooltip" must be NULL or of type "list"')
  if(!is.logical(save_widget)) stop('"save_widget" must be logical')
  if(!is.logical(show_legend)) stop('"show_legend" must be logical')
  if(!is.null(color_legend) && class(color_legend)!='list') stop('"color_legend" must be NULL or of type "list"')
  if(class(color_legend)=='list') {
    if(!all(c('ticks','colors') %in% names(color_legend)))stop('"color_legend" did not contain correct lists')
    if(min(matrix)<min(color_legend$ticks))stop('"color_legend" min ticks out of range')
    if(max(matrix)>max(color_legend$ticks))stop('"color_legend" max ticks out of range')
    }
  if(!is.null(width) && !is.numeric(width)) stop('"width" must be numeric')
  if(!is.null(width) && !is.numeric(height)) stop('"height" must be numeric')
  if(!is.logical(export_graphics)) stop('"export_graphics" must be logical')
  if(!is.null(export_dir) && (class(export_dir) != 'character' || !dir.exists(file.path(export_dir))))stop('"export_dir" must be NULL or an exsisting directory')
  if(class(export_type) != 'character' || !export_type %in% c("tiff","svg","png","jpg"))stop('"export_type" must be a string. options:"tiff","svg","png","jpg"')
  if(!is.null(seed) && (!is.numeric(seed) && seed != round(seed))) stop('"seed" must be integer')
  if(is.null(cores) || (!is.numeric(cores) && cores != round(cores))) stop('"cores" must be integer')

  # static default values
  xaxis_height = 80
  yaxis_width = 120
  xaxis_font_size = NULL
  yaxis_font_size = NULL
  brush_color = "#0000FF"
  show_grid = TRUE
  anim_duration = 500

  options <- NULL
  options <- c(
    options,
    list(
      xaxis_height = xaxis_height,
      yaxis_width = yaxis_width,
      xaxis_font_size = xaxis_font_size,
      yaxis_font_size = yaxis_font_size,
      brush_color = brush_color,
      show_grid = show_grid,
      anim_duration = anim_duration
    )
  )

  payload <- list(options = options)

  clusters <- NULL
  cluster_centers <- NULL
  row_dend_nw <- NULL
  col_dend_nw <- NULL
  row_dend_hclust <- NULL
  col_dend_hclust <- NULL
  data <- NULL
  cobject <- NULL


  if (!perform_clustering) {
    clusters <- clusterVector
    cobject <- NA
    row_dend_nw <- NULL
    col_dend_nw <- NULL
    row_dend <- NULL
    col_dend <- NULL
    if (!is.logical(rows) & class(rows) != 'hclust') {
      stop('row_dend is not of type hclust')
    }
    if (!is.logical(cols) & class(cols) != 'hclust') {
      stop('col_dend is not of type hclust')
    }
    if (is.null(clusterVector)) {
      stop('clusterVector has to been a numeric vector of same length as the data matrix!')
    }
    if (!is.logical(rows) &&
        !is.null(rows) && class(rows) == "hclust") {
      row_dend_nw <- ctc::hc2Newick(rows)
      row_dend_nw <- gsub(":\\d+\\.{0,1}\\d*", "", row_dend_nw)
      row_dend <- as.dendrogram(rows)
    }
    if (!is.logical(cols) &&
        !is.null(cols) && class(cols) == "hclust") {
      col_dend_nw <- ctc::hc2Newick(cols)
      col_dend_nw <- gsub(":\\d+\\.{0,1}\\d*", "", col_dend_nw)
      col_dend <- as.dendrogram(cols)
    }
    cluster_centers = aggregate(matrix, list(clusters), mean)
    cluster_centers <- cluster_centers[unique(clusters),]
    rownames(cluster_centers) <- cluster_centers[,1]
    cluster_centers[,1] <- NULL
  } else{
    rs <- clustering(
      matrix = matrix,
      method = method,
      min_k = min_k,
      max_k = max_k,
      fixed_k = fixed_k,
      cores = cores,
      seed = seed,
      export_graphics = export_graphics,
      export_type = export_type
    )

    matrix = rs$data[, !colnames(rs$data) %in% 'cluster', drop=FALSE]
    clusters = rs$clusters
    cluster_centers = rs$cluster_centers
    cluster_centers <- cluster_centers[unique(clusters),]
    row_dend_nw = rs$dendnw_row_nw
    col_dend_nw = rs$dendnw_col_nw
    row_dend_hclust <- rs$row_dend_hclust
    col_dend_hclust <- rs$col_dend_hclust
    data = rs$data
    cobject = rs$cobject
  }
  if(simplify_clustering){
    detailed_matrix <- matrix
    matrix <- cluster_centers
    detailed_clusters <- clusters
    clusters <- unique(clusters)
  }
  if(is.null(rownames(matrix)))rownames(matrix) <- 1:nrow(matrix)


  for(l in names(tooltip)){
    if(length(tooltip[[l]])!=nrow(matrix))tooltip[[l]] <- NULL
  }

  if(!is.null(tooltip[['id']])){
    new_order <-
      sapply(rownames(matrix), function(x)
        which(x == tooltip[['id']]))
    reordered_tooltip <- lapply(tooltip, function(x)
      x[new_order])
    reordered_tooltip[['id']] <- NULL
    tooltip <- reordered_tooltip
  }else{tooltip[['id']] <- rownames(matrix)
  tooltip[['link']] <- NULL
  }


  # sapply(color_legend,length)
  color_matrix <-
    as.data.frame(
      apply(
        matrix,
        c(1, 2),
        get_color,
        ticks = color_legend$ticks,
        colors = color_legend$colors
      )
    )
  colnames(color_matrix) <- colnames(matrix)
  rownames(color_matrix) <- rownames(matrix)

   ## Test>
  # payload[['matrix']] <- list(
  #   data = as.matrix(cluster_centers),
  #   rows = rownames(cluster_centers),
  #   cols = colnames(cluster_centers),
  #   dim = dim(cluster_centers)
  # )
  ## <Test

  payload[['matrix']] <- list(
    data = as.matrix(matrix),
    rows = rownames(matrix),
    cols = colnames(matrix),
    dim = dim(matrix)
  )
  payload[['clusters']] <- clusters
  if(simplify_clustering){
    payload[['detailed_matrix']] <- list(
      data = as.matrix(detailed_matrix),
      rows = rownames(detailed_matrix),
      cols = colnames(detailed_matrix),
      dim = dim(detailed_matrix)
    )
    payload[['detailed_clusters']] <- detailed_clusters
  }



  if ((is.logical(rows) &&
       rows && class(row_dend_nw) == "character") || class(rows) == 'hclust') {
    payload[['dendnw_row']] <- row_dend_nw
  } else{
    payload['dendnw_row'] <- NA
  }
  if ((is.logical(cols) &&
       cols && class(col_dend_nw) == "character") || class(cols) == 'hclust') {
    payload[['dendnw_col']] <- col_dend_nw
  } else{
    payload['dendnw_col'] <- NA
  }


  if (!is.null(color_matrix)) {
    payload[['colors']] <-  list(
      data = as.matrix(color_matrix),
      rows = rownames(color_matrix),
      cols = colnames(color_matrix),
      dim = dim(color_matrix)
    )
  } else{
    payload[['colors']] <- NA
  }

  df_legend <- data.frame(color = color_legend$colors)
  df_legend$x1 <- color_legend$ticks[1:length(color_legend$colors)]
  df_legend$x2 <-
    color_legend$ticks[2:(length(color_legend$colors) + 1)]
  payload[['color_legend']] <-
    list(gradient = df_legend,
         label_position = color_legend$label_position)

  payload[['tooltip']] <- tooltip

  payload[['export_dir']] <- export_dir
  payload[['export_type']] <- export_type
  payload[['show_legend']] <- show_legend

  json_payload <- jsonlite::toJSON(payload, pretty = TRUE)
  write(json_payload,
        file = "payload.json",
        ncolumns = 1,
        append = FALSE)
  write(data.frame(),
        file = "version_0.03a",
        ncolumns = 1,
        append = FALSE)
  utils::write.table(cbind(matrix,clusters),file = "clustered_matrix.txt",sep="\t", col.names=NA, row.names=T)
  # widget <-
  if(useShiny){
  return(
  htmlwidgets::createWidget(
    'clustpro',
    json_payload,
    width = width,
    height = height,
    package = 'clustpro',
    sizingPolicy = htmlwidgets::sizingPolicy(browser.fill = TRUE)
  )
  )
  # show(widget)
  # if (save_widget) {
  #   saveWidget(widget, file = paste(getwd(), 'widget.html', sep = '/'))
  # }
  }else{
  return(
    list(
      datatable = data,
      cobject = cobject,
      cluster_centers = cluster_centers,
      col_dend_hclust = col_dend_hclust,
      row_dend_hclust = row_dend_hclust
    )
  )
  }
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
#' @importFrom htmlwidgets shinyWidgetOutput
#'
#' @export
clustproOutput <-
  function(outputId,
           width = '100%',
           height = '400px') {
    htmlwidgets::shinyWidgetOutput(outputId, 'clustpro', width, height, package = 'clustpro')
  }

#' @rdname clustpro-shiny
#' @importFrom htmlwidgets shinyRenderWidget
#' @export
renderClustpro <-
  function(expr,
           env = parent.frame(),
           quoted = FALSE) {
    if (!quoted) {
      expr <- substitute(expr)
    } # force quoted
    htmlwidgets::shinyRenderWidget(expr, clustproOutput, env, quoted = TRUE)
  }

#' distributions_histograms
#'
#' .................
#' @param matrix numeric data.frame
#' @param export_type character; type of exported graphics, tested for tif and svg
#' @importFrom ggplot2 ggplot geom_density scale_color_discrete xlab xlab theme ggtitle ggsave  aes_string element_text element_blank element_line
#'
distributions_histograms <- function(matrix, export_type) {
  for (i in 1:ncol(matrix)) {
    x <- matrix[, i, drop = FALSE]
  # initialize_graphic(paste('distribution_column_',colnames(matrix)[i], sep = "_"), type = export_type)
    g <-
      ggplot(x, aes_string(x = colnames(x))) +
      geom_density(fill = 'blue',alpha = 0.2) +
      scale_color_discrete(name = '') +
      xlab("density") +
      xlab("value") +
      theme(plot.title = element_text(size = 12, face = "plain"),
            axis.title=element_text(size=12,face="plain"),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            panel.background = element_blank(),
            axis.line = element_line(colour = "black")) +
      ggtitle(paste('column: ',colnames(matrix)[i],sep=''))

    ggsave(paste('distribution_column_',colnames(matrix)[i],'.',export_type, sep = ""),plot = g, device =export_type)
  #   show(g)
  # grDevices::dev.off()
  }
}

#' order_dataframe_by_list
#'
#' .................
#' @param x numeric data.frame
#' @param list list, unique list of numbers or character in whished order
#' @param col character or numerical, col with should be ordered in accordance to list
#' @param reverse boolean, if TRUE reverse order of list

order_dataframe_by_list <- function(x, list, col, reverse = FALSE) {
  if (reverse) {
    list <- rev(list)
  }
  order_data <- x[x[, col] == list[1],]
  for (item in list[2:length(list)]) {
    order_data <- rbind(order_data, x[x[, col] == item,])
  }
  return(order_data)
}

#' findk_cmeans
#'
#' .................
#' @param matrix numeric data.frame
#' @param k number of clusters, k
#' @param minimalSet object of the class minimalSet
#' @param fp fuzzification parameter
#' @param seed natural number, useful for creating simulations or random objects that can be reproduced
#' @import Mfuzz
#' @import e1071
#' @importFrom clusterSim index.DB
#'

findk_cmeans <- function(matrix, k, minimalSet, fp, seed = NULL) {
  tryCatch({
    if (!is.null(seed))
      set.seed(seed)

    rs <- mfuzz(minimalSet, c = k, m = fp)
    cluster <- as.vector(rs$cluster)
    # print(cluster)
    # table(cluster)
    # length(cluster)
    # cluster)
    # class(cluster)
  #  print(paste0("k: ",rs$withinerror))
    db_score <- clusterSim::index.DB(matrix,
                         cluster,
                         centrotypes = "centroids",
                         p = 2,
                         q = 2)
    return(c(k, db_score$DB,rs$withinerror, list(db_score$d)))
  }, warning = function(w) {
    print(paste('findk_cmeans', w, sep = ': '))
    return(NA)
  }, error = function(e) {
    print(paste('findk_cmeans', e, sep = ': '))
    return(NA)
  })
}

#' findk_kmeans
#'
#' .................
#' @param matrix numeric data.frame
#' @param k number of clusters, k
#' @param seed natural number, useful for creating simulations or random objects that can be reproduced
#' @importFrom clusterSim index.DB

findk_kmeans <- function(matrix, k, seed = NULL) {
  tryCatch({
    if (!is.null(seed))
      set.seed(seed)
    cluster <- kmeans(matrix, k, iter.max = 1000, algorithm="Lloyd")
    db_score <-
      clusterSim::index.DB(
        matrix,
        cluster$cluster,
        centrotypes = "centroids",
        p = 2,
        q = 2
      )


    # return(c(k, db_score$DB))
    # attr(cluster,"tot.withinss")
    return(c(k, db_score$DB, cluster[["tot.withinss"]], list(db_score$d)))
  }, warning = function(w) {
    print(paste('findk_kmeans', w, sep = ': '))
    return(NA)
  }, error = function(e) {
    print(paste('findk_kmeans', e, sep = ': '))
    return(NA)
  })
}


#' Get best k
#'
#' .................
#' @param matrix numeric data.frame
#' @param min_k,max_k number of clusters, k; if the  function is called its tries to find the optimal k for this data in the range defined by the minimum and maximal k.
#' @param method character; one of the following cluster methods: kmeans, cmeans
#' @param cores natural number, number of nodes/cores used for parallelisation
#' @param seed natural number, useful for creating simulations or random objects that can be reproduced
#' @import foreach
#' @importFrom Biobase ExpressionSet
#' @import Mfuzz
#' @import e1071
#' @importFrom doParallel registerDoParallel
#' @importFrom parallel makeCluster stopCluster
#' @export
#'
get_best_k <-
  function(matrix,
           min_k = 2,
           max_k = 10,
           method = 'kmeans',
           cores = 1,
           seed = NULL) {
    if (nrow(matrix) < max_k) {
      max_k <- nrow(matrix)
      print("max_k larger the rows in matrix.")
      print(paste("max_k was set to ", max_k, sep = ""))
    }
    iterations <- max_k
    matrix <- matrix
    k <- NULL
    switch(method,
           kmeans = {
             cl <- parallel::makeCluster(cores, type = "SOCK")
             doParallel::registerDoParallel(cl)
             findk <- findk_kmeans
             db_list <-
               t(foreach(
                 k = c(min_k:iterations),
                 .combine = "cbind",
                 .export = c('findk', 'matrix', 'seed')
               ) %do% findk(matrix, k, seed))
             parallel::stopCluster(cl)
             db_list <- as.data.frame(db_list)
             colnames(db_list) <- c('k','score','withinerror','cluster_distances')
             db_list[,c('k','score','withinerror')] <- sapply(db_list[,c('k','score','withinerror')],as.numeric)
             print(head(db_list[,c(1:3)]))
             print(sapply(db_list,class))

             filtered_db_list <- as.data.frame(db_list[complete.cases(db_list[,c('k','score','withinerror')]),])
             best_id <- which(filtered_db_list$score == max(filtered_db_list$score, na.rm = TRUE))
             best_k <- as.numeric(filtered_db_list[best_id,'k'])
             cluster_distances <- as.data.frame(filtered_db_list[best_id,'cluster_distances'])
             colnames(cluster_distances) <- c(1:ncol(cluster_distances))
             rownames(cluster_distances) <- c(1:ncol(cluster_distances))

             db_list = as.data.frame(db_list[,c('k','score','withinerror')])
             db_list <- as.data.frame(sapply(db_list,as.numeric))
             return(list(db_list = db_list,
                         best_k = best_k,
                         cluster_distances = cluster_distances
                         ))

           },
           cmeans = {
             oldw <- getOption("warn")
             options(warn = -1)
             cl <- parallel::makeCluster(cores, type = "SOCK")
             doParallel::registerDoParallel(cl)
             minimalSet <- Biobase::ExpressionSet(assayData = as.matrix(matrix))
             fp <- mestimate(minimalSet)
             findk <- findk_cmeans
             #clusterExport(cl, c("findk", "seed"))
           #   findk_cmeans(matrix, 19, minimalSet, fp,seed)
             # findk_kmeans(matrix, 3)
             # clusterExport(cl, c("minimalSet", "fp","matrix", "findk", "seed"))
           #  clusterExport(cl, c("matrix", "findk", "seed"))
          #   clusterEvalQ(cl, c(library('clusterSim'), library('Mfuzz'), library('e1071'), library('clustpro'), library('Biobase')))
# library(foreach)
              db_list <- as.data.frame(t(foreach(
               k = c(min_k:iterations),
               .combine = "cbind",
               .export = c("matrix", "findk", "seed","minimalSet", "fp"),
               .packages = c("clusterSim","Mfuzz")
             ) %dopar% {
               findk(matrix = matrix, k = k, minimalSet = minimalSet, fp = fp,seed = seed)
             #  findk()
             }))
            #  print(colnames(db_list))
              parallel::stopCluster(cl)

              db_list <- as.data.frame(db_list)
              colnames(db_list) <- c('k','score','withinerror','cluster_distances')
              db_list[,c('k','score','withinerror')] <- sapply(db_list[,c('k','score','withinerror')],as.numeric)
              print(head(db_list[,c(1:3)]))
              print(sapply(db_list,class))

              filtered_db_list <- as.data.frame(db_list[complete.cases(db_list[,c('k','score','withinerror')]),])
              best_id <- which(filtered_db_list$score == max(filtered_db_list$score, na.rm = TRUE))
              best_k <- as.numeric(filtered_db_list[best_id,'k'])
              cluster_distances <- as.data.frame(filtered_db_list[best_id,'cluster_distances'])
              colnames(cluster_distances) <- c(1:ncol(cluster_distances))
              rownames(cluster_distances) <- c(1:ncol(cluster_distances))
              # print(db_list)
              # print(class(db_list))

              db_list = as.data.frame(db_list[,c('k','score','withinerror')])
              db_list <- as.data.frame(sapply(db_list,as.numeric))
             return(list(
               db_list = db_list,
               minimalSet = minimalSet,
               fp = fp,
               best_k = best_k,
               cluster_distances = cluster_distances
             ))
             options(warn = oldw)
           })


  }


#' Clustering
#'
#' Inner function performing the clustering
#' @param matrix numeric data.frame
#' @param min_k,max_k,fixed_k number of clusters, k; if fixed_k is a natural number > 0, k is set to fixed_k. Otherwise the a function is called to find the optimal k for this data in the range defined by the minimum and maximal k.
#' @param method character; one of the following cluster methods: kmeans, cmeans
#' @param hclust_method character; one of the following cluster methods: "ward.D", "ward.D2", "single", "complete", "average" (= UPGMA), "mcquitty" (= WPGMA), "median" (= WPGMC) or "centroid" (= UPGMC)
#' @param cores natural number, number of nodes/cores used for parallelisation
#' @param seed natural number, useful for creating simulations or random objects that can be reproduced
#' @param export_graphics boolean; if TRUE grephics are exported
#' @param export_type character; type of exported graphics, tested for tif and svg
#' @import stats
#' @import Mfuzz
#' @import e1071
#' @importFrom ggplot2 ggplot geom_line geom_point geom_text ylab xlab theme ggtitle ggsave aes_string element_text element_blank element_line
#' @importFrom Biobase ExpressionSet
#' @importFrom ctc hc2Newick
clustering <- function(matrix,
                       min_k = 2,
                       max_k = 100,
                       fixed_k = NULL,
                       method = "kmeans",
                       hclust_method = "ward.D2",
                       cores = 2,
                       seed = NULL,
                       export_graphics = FALSE,
                       export_type = 'svg') {

  if(export_graphics)distributions_histograms(matrix,export_type)

  if (!is.null(fixed_k)) {
    k <- fixed_k
    if (method == 'cmeans') {
      minimalSet <- Biobase::ExpressionSet(assayData = as.matrix(matrix))
      fp <- mestimate(minimalSet)
    }
  } else {
    rv <-
      get_best_k(matrix, min_k, max_k, method, cores = cores, seed)
    db_list <- as.data.frame(rv$db_list)
    if (method == 'cmeans') {
      minimalSet <- rv$minimalSet
      fp <- rv$fp
    }
    filtered_db_list <- db_list[complete.cases(db_list),]
    k <- as.numeric(filtered_db_list[filtered_db_list[, 2] == max(filtered_db_list[, 2], na.rm = TRUE),1])
    colnames(db_list) <- c('k','score','withinerror')
    if(export_graphics){
    # initialize_graphic('best k estimation', type = export_type)
      yfactor <- max(db_list$score,na.rm=T) / max(db_list$withinerror,na.rm=T)

      db_list$withinerror <- db_list$withinerror * yfactor
    g <-
      ggplot(db_list, aes_string(x = 'k')) +
      geom_line(aes_string(y='score',colour = shQuote("DBI"))) +
      geom_line(aes_string(y='withinerror', colour = shQuote("SoSE"))) +
      scale_y_continuous(sec.axis = sec_axis(~./yfactor, name = "withinerror"))+
      geom_point(aes_string(y='score'))+
      geom_point(data = db_list[which(db_list$k == k),],mapping = aes_string(x='k',y='score'), color="red") +
      geom_text(data = db_list[which(db_list$k == k),],mapping = aes_string(x='k',y='score'), label = paste('k:',k,';seed:',seed,sep=''), vjust = -1, nudge_y = 0.01, color="red")+
      ylab("Davies-Bouldin Index [DBI]") +
      xlab("k") +
      # scale_x_continuous(limits=c(-2, 7),breaks = (-2:7))+
      theme(plot.title = element_text(size = 12, face = "plain"),
            axis.title=element_text(size=12,face="plain"),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            panel.background = element_blank(),
            axis.line = element_line(colour = "black"),
            legend.position = c(0.8, 0.9)
            ) +
   ggtitle('best k estimation') +
    scale_colour_manual(values = c("blue", "red"))

    ggsave(paste0('best_k_estimation.',export_type),plot = g, device =export_type)
    # show(g)
    # grDevices::dev.off()
    }
  }
  if (!is.null(seed))
    set.seed(seed)
  # cluster_cols <- F
  # cluster_rows <- T

  switch(method, kmeans = {
    clustering_result <- kmeans(matrix, k, iter.max = 1000)
  }, cmeans = {
    clustering_result <- mfuzz(minimalSet, c = k, m = fp)
  })
  cluster <- clustering_result$cluster
  df <- cbind(matrix, cluster)

  cluster_centers <-
    aggregate(df[, -ncol(df)],
              by = df['cluster'],
              FUN = median,
              na.rm = TRUE)
  rownames(cluster_centers) <-
    sapply(cluster_centers$cluster, as.character)
  cluster_centers$cluster <- NULL

  # print(cluster_centers)
  # set.seed(1234)

  row_dend_nw = NULL
  col_dend_nw = NULL
  col_dend_hclust = NULL
  row_dend_hclust = NULL
  col_dend = NULL
  row_dend = NULL

  if(nrow(cluster_centers)>1){
  d_rows <-
    dist(cluster_centers, method = "euclidean") # distance matrix
  row_dend_hclust <- hclust(d_rows, method = hclust_method)
  row_dend_nw <- ctc::hc2Newick(row_dend_hclust)
  row_dend_nw <- gsub(":\\d+\\.{0,1}\\d*", "", row_dend_nw)
  row_dend <- as.dendrogram(row_dend_hclust)
}

  if(ncol(cluster_centers)>1){
  d_cols <-
    dist(t(cluster_centers), method = "euclidean") # distance matrix
  col_dend_hclust <- hclust(d_cols, method = hclust_method)
  col_dend_nw <- ctc::hc2Newick(col_dend_hclust)
  col_dend_nw <- gsub(":\\d+\\.{0,1}\\d*", "", col_dend_nw)
  col_dend <- as.dendrogram(col_dend_hclust)
}


  ordered_df <- NULL
  if (class(row_dend) == "dendrogram") {
    for (c in order.dendrogram(row_dend)) {
      if (is.null(ordered_df)) {
        ordered_df <- df[df$cluster == c, ]
      }
      else{
        ordered_df <- rbind(ordered_df, df[df$cluster == c, ])
      }
    }
  }

  if (class(col_dend) == "dendrogram") {
    ordered_df <-
      ordered_df[, c(order.dendrogram(col_dend), ncol(ordered_df))]
  }

  ordered_df_wo_cluster <-
    ordered_df[colnames(ordered_df)[!colnames(ordered_df) %in% c('cluster')]]

  clusters = as.vector(unlist(ordered_df['cluster']))

  return(
    list(
      matrix = matrix,
      clusters = clusters,
      cluster_centers = cluster_centers,
      dendnw_row_nw = row_dend_nw,
      dendnw_col_nw = col_dend_nw,
      col_dend_hclust = col_dend_hclust,
      row_dend_hclust = row_dend_hclust,
      data = ordered_df,
      cobject = clustering_result
    )
  )
}


#' Function to initialize a graphic
#'
#' This function allows you to initialize a graphic
#' @param filename character; filename for saving
#' @param type character; type of exported graphics, tif, svg or pdf
#' @param ...  further parameters
initialize_graphic <- function(filename, type = 'tif', ...) {
  gap_free_title <- gsub('\\s', '_', filename)
  switch(type,
         svg = {
           grDevices::svg(paste(gap_free_title, '.svg', sep = ''),
               width = 10,
               height = 10)
         },
         tif = {
           grDevices::tiff(
             paste(gap_free_title, '.tif', sep = ''),
             width = 2000,
             height = 2000,
             res = 200,
             compression = 'lzw'
           )
         },
         pdf = {
           grDevices::pdf(paste(gap_free_title, '.pdf', sep = ''),
               width = 10,
               height = 10)
         })
}



#' Function to get color
#'
#' ..............
#' @param x numeric; value in range of the ticks
#' @param ticks numeric vector breaks/ticks for a gradient
#' @param colors character vector of colors for a gradient

get_color <- function(x, ticks, colors) {
  i = 1
  c = ticks[i]
  while (c < x) {
    i = i + 1
    c = ticks[i]
  }
  return(colors[i - 1])
}

#' Function to to define the color spectrum for heatmaps
#'
#' This function allows you to define the color spectrum for heatmaps.
#' @param intervals list of numerical vaules which define the breaks of the color space
#' @param color_spect list of colors
#' @export
color_spectrum <-
  function(intervals, color_spect) {
    index <- 1
    colors <- c()
    ticks <- c()
    while (index < length(intervals)) {
      ticks <-
        c(ticks,
          seq(intervals[index], intervals[index + 1] , length = 100))
      colors <- c(colors,grDevices::colorRampPalette(color_spect[c(index,index + 1)])(n = 100-1))

      index <- index + 1
    }
    length(ticks)
    length(colors)
    ticks <- unique(ticks)
    # colors <-
    #   colorRampPalette(color_spect)(n = ((length(values) - 1) * 100) - 1)
    return(list(ticks = ticks, colors = colors))
  }

####

#' Function to set heatmap color
#'
#' This function allows you to define the color spectrum for heatmaps.
#' @param data numeric data.frame, list or vector
#' @param intervals list of numerical vaules which define the breaks of the color space
#' @param color_list list of colors
#' @param auto boolean, if TRUE automatical gerneates ticks for the dataset
#' @keywords color spectrum heatmaps
#' @export
setHeatmapColors <-
  function(data,
           color_list = c("red", "yellow", "green"),
           intervals,
           auto = FALSE) {
    if (auto) {
      d_min <- round(min(data, na.rm = TRUE), 8) - 0.00000001
      d_max <- round(max(data, na.rm = TRUE), 8) + 0.00000001
      steps <- (d_max - d_min) / 299
      heatmap_color <- list(ticks = seq(d_min, d_max, steps),
                            colors = grDevices::colorRampPalette(color_list)(n = 299),
                            label_position = c(round(d_min,2),round(d_max,2))
                                                )
    } else{
      if (!is.null(data) &&  (min(intervals) > min(data, na.rm = TRUE) |
          max(data, na.rm = TRUE) > max(intervals))) {
        stop(
          paste(
            "intervals borders doesn't fit to the data. min value:",
            min(data, na.rm = TRUE),
            ", max value:",
            max(data, na.rm = TRUE),
            sep = ''
          )
        )
      }
      intervals[1] <- intervals[1]-0.00000001
      intervals[length(intervals)] <- intervals[length(intervals)] +0.00000001

      heatmap_color <- color_spectrum(intervals, color_list)
      heatmap_color$label_position <- c(round(min(intervals),2),round(max(intervals),2))
      return(heatmap_color)

    }
  }


factorial <- function(n)
{
  if (n == 0)
  {
    return(1)
  }
  else
  {
    return(n * factorial(n - 1))
  }
}
