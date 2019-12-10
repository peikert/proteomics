#' Example function 01
#'
#' A theoretical proteomics dataset composed of 1000 human proteins (UniProt accessionn umbers) and random choosen values will be used to call the clustpro() main function.
#' @return see clustpro() function output
#' @examples
#' clustpro_example()
#' @export
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
#' @param random_seeds null or natural number, if null seed is used for the determination of the best k, otherwise the number of random_seeds seeds will be consider
#' @param cores natural number, number of nodes/cores used for parallelisation
#' @param show_legend boolean; if TRUE color legend is shown
#' @param useShiny if TRUE html widget is usable for shiny apps, otherwise clustering is returned to R
#' @param json json file with will used to gernerate widget. further parameter are ignored.
#' @param elementId unique id for the htmlwdiget. Shiny should take care of this so the default value is NULL.
#' @return see clustpro() function output
#' @importFrom htmlwidgets createWidget sizingPolicy
#' @importFrom ctc hc2Newick
#' @importFrom jsonlite toJSON
#' @examples
#' library('foreach')
#' clustpro(matrix = mtcars
#' ,method = "kmeans"
#' ,hclust_method = "ward.D2"
#' ,min_k = 2
#' ,max_k = 10
#' ,fixed_k = NULL
#' ,perform_clustering = TRUE
#' ,simplify_clustering = FALSE
#' ,clusterVector = NULL
#' ,rows = TRUE
#' ,cols = TRUE
#' ,tooltip = NULL
#' ,save_widget = TRUE
#' ,show_legend = FALSE
#' ,color_legend = NULL
#' ,width = NULL
#' ,height = NULL
#' ,export_graphics = FALSE
#' ,export_dir = NULL
#' ,export_type = 'svg'
#' ,seed = NULL
#' ,random_seeds = NULL
#' ,cores = 2
#' ,useShiny = TRUE
#' ,json = NULL
#' )
#' @export
clustpro <- function(matrix = NULL,
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
                     random_seeds = NULL,
                     cores = 2,
                     useShiny = TRUE,
                     json = NULL,
                     elementId = NULL
                     ) {

  #### proofing #####
  if(!is.null(json) && class(json) != 'list') stop('"json" must be NULL or of type "list"')
  if(is.null(json)){
  if(!class(matrix) %in% c('data.frame'))stop('matrix is no data.frame')
  if(!all(complete.cases(matrix)))stop('matrix is contains missing values')
  if(class(method) != 'character' | !method %in% c("kmeans","cmeans"))stop('method must be a string. options:"kmeans","cmeans"')
  if(!is.numeric(min_k) && min_k>1)stop('min_k must be numeric and greater 1')
  if(!is.numeric(max_k) && max_k>min_k)stop('max_k must be numeric and greater min_k')
  if(!is.null(fixed_k) && (!is.numeric(fixed_k) && (is.numeric(fixed_k) && fixed_k<2)))stop('fixed_k must be numeric and greater 1 or NULL')
  # if(!is.logical(perform_clustering))
  if(!is.null(clusterVector) && (!class(clusterVector) %in% c("list","vector")) && length(clusterVector) != nrow(matrix)) stop('"clusterVector" must be NULL or of type "list/vector" with a length equal to the rows of the matrix')
  if(!is.logical(cols) & class(cols)!="hclust" & !is.Newick(cols)) stop('"cols" must be logical, hclust or a newick string')
  if(!is.logical(rows) & class(rows)!="hclust" & !is.Newick(rows)) stop('"rows" must be logical, hclust or a newick string')
  if(!is.null(tooltip) && class(tooltip)!='list') stop('"tooltip" must be NULL or of type "list"')
  if(!is.logical(save_widget)) stop('"save_widget" must be logical')
  if(!is.logical(show_legend)) stop('"show_legend" must be logical')
  if(!is.null(color_legend) && class(color_legend)!='list') stop('"color_legend" must be NULL or of type "list"')
  if(class(color_legend)=='list') {
    if(!all(c('ticks','colors') %in% names(color_legend)))stop('"color_legend" did not contain correct lists')
    if(min(matrix)<min(color_legend$ticks))stop(paste0('"color_legend" min ticks out of range! ',min(matrix),'<',min(color_legend$ticks)))
    if(max(matrix)>max(color_legend$ticks))stop(paste0('"color_legend" max ticks out of range! ',max(matrix),'>',max(color_legend$ticks)))
  if(!is.null(seed) && !class(seed)%in%c('numeric','integer')) stop('"seed" must be NULL or of type "numeric"')
  if(!is.null(random_seeds) && !class(random_seeds)%in%c('numeric','integer')) stop('"random_seeds" must be NULL or of type "numeric"')
  }

  if(!is.null(width) && !is.numeric(width)) stop('"width" must be numeric')
  if(!is.null(width) && !is.numeric(height)) stop('"height" must be numeric')
  if(!is.logical(export_graphics)) stop('"export_graphics" must be logical')
  if(!is.null(export_dir) && (class(export_dir) != 'character' || !dir.exists(file.path(export_dir))))stop('"export_dir" must be NULL or an exsisting directory')
  if(class(export_type) != 'character' || !export_type %in% c("tiff","svg","png","jpg"))stop('"export_type" must be a string. options:"tiff","svg","png","jpg"')
  if(!is.null(seed) && (!is.numeric(seed) && seed != round(seed))) stop('"seed" must be integer')
  if(is.null(cores) || (!is.numeric(cores) && cores != round(cores))) stop('"cores" must be integer')
  }

  if(!is.null(json) && class(json)=='list'){
    payload <- json
    useShiny <- TRUE
  }else{
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

    if (!is.logical(rows) && is.Newick(rows)) {
      row_dend_nw <- rows
      row_dend_nw <- gsub(":\\d+\\.{0,1}\\d*", "", row_dend_nw)
      pre_list <- gsub("\\(+", ",", row_dend_nw)
      pre_list <- gsub("\\)+", ",", pre_list)
      pre_list <- gsub(",+", ",", pre_list)
      if(substr(pre_list,nchar(pre_list),nchar(pre_list))==';') pre_list <- substr(pre_list,1,nchar(pre_list)-1)
      pre_list <- gsub("^,+", "", pre_list)
      pre_list <- gsub(",+$", "", pre_list)
      row_dend <- as.vector(sapply(strsplit(pre_list,',')[[1]],as.numeric))
    }
    if (!is.logical(cols) && is.Newick(cols)) {
      col_dend_nw <- cols
      col_dend_nw <- gsub(":\\d+\\.{0,1}\\d*", "", col_dend_nw)
      pre_list <- gsub("\\(+", ",", col_dend_nw)
      pre_list <- gsub("\\)+", ",", pre_list)
      pre_list <- gsub(",+", ",", pre_list)
      if(substr(pre_list,nchar(pre_list),nchar(pre_list))==';') pre_list <- substr(pre_list,1,nchar(pre_list)-1)
      pre_list <- gsub("^,+", "", pre_list)
      pre_list <- gsub(",+$", "", pre_list)
      col_dend <- as.vector(sapply(strsplit(pre_list,',')[[1]],as.numeric))
    }

    matrix$clusters <- clusters
    cluster_centers = aggregate(matrix, list(clusters), mean)
    matrix$clusters <- NULL
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
    rownames(matrix) <- paste0('C',sprintf("%02d",1:nrow(matrix)))
    detailed_clusters <- clusters
    clusters <- unique(clusters)
    tooltip[['cluster size']] <- as.vector(table(detailed_clusters)[clusters])
  }

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
  }else{
    tooltip <- c(list(id=rownames(matrix)),tooltip)
    tooltip[['link']] <- NULL
  }

  if(is.null(color_legend)){
    color_legend <- setHeatmapColors(data=matrix,auto=TRUE)
  }

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



  }

  payload[['elementId']] <- elementId
  json_payload <- jsonlite::toJSON(payload, digits = NaN, pretty = TRUE)

  write(json_payload,
        file = "payload.json",
        ncolumns = 1,
        append = FALSE)
  write(data.frame(),
        file = "version_0.03a",
        ncolumns = 1,
        append = FALSE)

  if(useShiny){
  return(
  htmlwidgets::createWidget(
    'clustpro',
    json_payload,
    width = width,
    height = height,
    package = 'clustpro',
    elementId = elementId,
    sizingPolicy = htmlwidgets::sizingPolicy(browser.fill = TRUE)
  )
  )

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
#' @examples
#' clustproOutput(1)
#' @export
clustproOutput <-
  function(outputId,
           width = '100%',
           height = '100%') {
    htmlwidgets::shinyWidgetOutput(outputId, 'clustpro', width, height, package = 'clustpro')
  }

#' @rdname clustpro-shiny
#' @importFrom htmlwidgets shinyRenderWidget
#' @examples
#' renderClustpro(NA)
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
#' @param export_type character; type of exported graphics, tested for tiff and svg
#' @importFrom ggplot2 ggplot geom_density scale_color_discrete xlab xlab theme ggtitle ggsave  aes_string element_text element_blank element_line
#' @examples
#' \dontrun{
#' distributions_histograms(mtcars[1:3],'tiff')
#' }
distributions_histograms <- function(matrix, export_type) {
  for (i in 1:ncol(matrix)) {
    x <- matrix[, i, drop = FALSE]
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
#' order a data.frame by the order of a list
#' .................
#' @param x numeric data.frame
#' @param list list, unique list of numbers or character in whished order
#' @param col character or numerical, col with should be ordered in accordance to list
#' @param reverse boolean, if TRUE reverse order of list
#' @examples
#' df_tmp <- mtcars
#' df_tmp$model <- rownames(df_tmp)
#' order_dataframe_by_list(x = df_tmp
#' ,list = sample(df_tmp$model,nrow(df_tmp)
#' ,replace = FALSE)
#' ,col = 'model')
#' @export
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
#' @param seed natural number, useful for creating simulations or random objects that can be reproduced
#' @import e1071
#' @importFrom clusterSim index.DB
#' @examples
#' \dontrun{
#' findk_cmeans(mtcars[1:3],2)
#' }
findk_cmeans <- function(matrix, k, seed = NULL) {
  tryCatch({
    if (!is.null(seed))
      set.seed(seed)
    rs <- e1071::cmeans(x = matrix, centers = k, iter.max = 1000)
    cluster <- as.vector(rs$cluster)
    db_score <- clusterSim::index.DB(matrix,
                         cluster,
                         centrotypes = "centroids",
                         p = 2,
                         q = 2)
    return(c(k, db_score$DB, rs$withinerror, list(db_score$d)))
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
#' @examples
#' \dontrun{
#' findk_kmeans(mtcars[1:3],2)
#' }
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
#' @import e1071
#' @importFrom doParallel registerDoParallel
#' @importFrom parallel makeCluster stopCluster
#' @examples
#' get_best_k(matrix = mtcars["mpg",drop=FALSE],min_k = 2,max_k = 4)
#' @export
get_best_k <-
  function(matrix,
           min_k = 2,
           max_k = 10,
           method = 'kmeans',
           cores = 1,
           seed = NULL
           ) {
    if (nrow(matrix) < max_k) {
      max_k <- nrow(matrix)
      print("max_k larger the rows in matrix.")
      print(paste("max_k was set to ", max_k, sep = ""))
    }
    if (!is.null(seed) && !is.integer(seed) && !is.numeric(seed)) {
      print(paste0("'seed' must be NULL or of type 'numeric'. Seed was set to NULL."))
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
             findk <- findk_cmeans
              db_list <- as.data.frame(t(foreach(
               k = c(min_k:iterations),
               .combine = "cbind",
               .export = c("matrix", "findk", "seed"),
               .packages = c("clusterSim","e1071")
             ) %dopar% {
               findk(matrix = matrix, k = k, seed = seed)
             }))
              parallel::stopCluster(cl)

              db_list <- as.data.frame(db_list)
              colnames(db_list) <- c('k','score','withinerror','cluster_distances')
              db_list[,c('k','score','withinerror')] <- sapply(db_list[,c('k','score','withinerror')],as.numeric)

              filtered_db_list <- as.data.frame(db_list[complete.cases(db_list[,c('k','score','withinerror')]),])
              best_id <- which(filtered_db_list$score == max(filtered_db_list$score, na.rm = TRUE))
              best_k <- as.numeric(filtered_db_list[best_id,'k'])
              cluster_distances <- as.data.frame(filtered_db_list[best_id,'cluster_distances'])
              colnames(cluster_distances) <- c(1:ncol(cluster_distances))
              rownames(cluster_distances) <- c(1:ncol(cluster_distances))

              db_list = as.data.frame(db_list[,c('k','score','withinerror')])
              db_list <- as.data.frame(sapply(db_list,as.numeric))
             return(list(
               db_list = db_list,
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
#' @param random_seeds null or natural number, if null seed is used for computation, otherwise the number of random_seeds seeds will be consider
#' @param export_graphics boolean; if TRUE grephics are exported
#' @param export_type character; type of exported graphics, tested for tif and svg
#' @import stats
#' @import e1071
#' @importFrom ggplot2 ggplot geom_line geom_point geom_text ylab xlab theme ggtitle ggsave aes_string element_text element_blank element_line scale_colour_manual sec_axis scale_y_continuous
#' @importFrom ctc hc2Newick
clustering <- function(matrix,
                       min_k = 2,
                       max_k = 100,
                       fixed_k = NULL,
                       method = "kmeans",
                       hclust_method = "ward.D2",
                       cores = 2,
                       seed = NULL,
                       random_seeds = NULL,
                       export_graphics = FALSE,
                       export_type = 'svg') {

  if(export_graphics)distributions_histograms(matrix,export_type)

  if (!is.null(fixed_k)) {
    k <- fixed_k
  } else {

    if(is.null(seed)){
      # seed <- .Random.seed[1]
      seed <- sample(1000:9999, 1)
    }
    seeds <- list(seed)
    if(is.numeric(random_seeds)){
      seeds <- sample(1000:9999, random_seeds, replace=T)
    }
    best_ks <- list()
    for(seed_i in seeds){
    rv <-
      get_best_k(matrix, min_k, max_k, method, cores = cores, seed=seed_i)
    best_ks <- c(best_ks, placeholder = rv$best_k)
    names(best_ks)[which(names(best_ks)=="placeholder")] <- as.character(sprintf("%04d", seed_i))
    }
    k_freq <-sort(table(unlist(best_ks)),decreasing = T)
    best_k <- as.numeric(names(k_freq[which.max(k_freq)]))
    seed_belong_to_k <- sapply(names(best_ks[best_ks==best_k]),as.numeric)

    rv <- get_best_k(matrix, min_k, max_k, method, cores = cores, seed=seed_belong_to_k[1])

    db_list <- as.data.frame(rv$db_list)
    if (method == 'cmeans') {
      minimalSet <- rv$minimalSet
      fp <- rv$fp
    }
    filtered_db_list <- db_list[complete.cases(db_list),]
    k <- as.numeric(filtered_db_list[filtered_db_list[, 2] == max(filtered_db_list[, 2], na.rm = TRUE),1])
    colnames(db_list) <- c('k','score','withinerror')
    if(export_graphics){
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
    clustering_result <- e1071::cmeans(x = matrix, centers = k, iter.max = 1000)
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

  # order.dendrogram(as.dendrogram(test))
  ordered_df <- NULL
  row_order <- NULL
  if (class(row_dend) == "dendrogram") {
    row_order <- order.dendrogram(row_dend)
  } else if (class(row_dend) == "list" && all(sapply(row_dend,is.numeric))) {
    row_order <- row_dend
  } else stop("row_dend is in wrong format!")

  ordered_df <- order_dataframe_by_list(x = df,list = row_order ,col = "cluster")


  col_order <- NULL
  if (class(col_dend) == "dendrogram") {
    col_order <- order.dendrogram(col_dend)
  } else if (class(col_dend) == "list" && all(sapply(col_dend,is.numeric))) {
    col_order <- col_dend
  } else stop("col_dend is in wrong format!")

  ordered_df <- ordered_df[, c(col_order, ncol(ordered_df))]

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

#' Function to get color
#'
#' ..............
#' @param x numeric; value in range of the ticks
#' @param ticks numeric vector breaks/ticks for a gradient
#' @param colors character vector of colors for a gradient
#' @examples
#' \dontrun{
#' get_color(x = 2, ticks = seq(1,3,1), colors = c('red','yellow','green'))
#' }

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
#' @examples
#' color_spectrum(c(1,2,3),c('red','green'))
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
#' @param border_extensions double, which are add/subtracted from the maxima/minima
#' @param decimal_places integer indicating the number of decimal places
#' @keywords color spectrum heatmaps
#' @examples
#' setHeatmapColors(scale(mtcars[1:3]),intervals = c(-3,0,3))
#' @export
setHeatmapColors <-
  function(data,
           color_list = c("red", "yellow", "green"),
           intervals,
           auto = FALSE,
           border_extensions = 0.0001,
           decimal_places = 4
           ) {
    if (auto) {
      d_min <- round(min(data, na.rm = TRUE), decimal_places) - border_extensions
      d_max <- round(max(data, na.rm = TRUE), decimal_places) + border_extensions
      steps <- (d_max - d_min) / 299
      heatmap_color <- list(ticks = seq(d_min, d_max, steps),
                            colors = grDevices::colorRampPalette(color_list)(n = 299),
                            label_position = c(round(d_min,2),round(d_max,2))
                                                )
      color_list <- grDevices::colorRampPalette(color_list)(n=length(color_list))
      pre_intervals <- seq(1,299,ceiling(299/(length(color_list)-1)))
      intervals <- c(d_min,heatmap_color$ticks[c(1,pre_intervals[2:length(pre_intervals)]-1,299)][2:(length(color_list)-1)],d_max)
      color_list <- heatmap_color$colors[c(1,pre_intervals[2:length(pre_intervals)]-1,299)]
      # heatmap_color$colors[95:105]
      # heatmap_color$colors[101]
      # sapply(color_list, function(x)which( heatmap_color$colors==x))

      # heatmap_color$colors[length(heatmap_color$colors)]

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
      # intervals[1] <- intervals[1] - border_extensions
      # intervals[length(intervals)] <- intervals[length(intervals)] + border_extensions

      heatmap_color <- color_spectrum(intervals, color_list)
      # heatmap_color$label_position <- c(round(min(intervals),2),round(max(intervals),2))
      #
      # heatmap_color$init_colors <- color_list
      # heatmap_color$init_intervals <-  intervals
      # return(heatmap_color)

    }

    heatmap_color$init_colors <- color_list
    heatmap_color$init_intervals <-  intervals
    heatmap_color$label_position <- c(round(min(intervals),2),round(max(intervals),2))

    return(heatmap_color)
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



#' Function to create the tooltip list from a data.frame
#'
#' This function allows you convert selected columns of a data.frame into a list
#' @param data numeric data.frame
#' @param selected_columns null or list of selected columns of data
#' @keywords tooltip
#' @examples
#' createTooltipList(data = mtcars, selected_columns =  c("cyl","mpg"))
#' @export
createTooltipList <- function(data,selected_columns=NULL){
    if(is.null(selected_columns)){return(sapply(data,function(x)return(list(x))))}

    filter_columns <- selected_columns[selected_columns %in% colnames(data)]

    if(length(filter_columns)>0) filtered_data <- data[,filter_columns]
    return(sapply(filtered_data,function(x)return(list(x))))
  }


#' Function to prove if sting is in newick format
#'
#' This function returns TRUE is string is in newick format, FALSE otherwise
#' @param newick_string string to test
#' @keywords newickformat
#' @import stringr
#' @examples
#' is.Newick(newick_string = "(1:0.1,(2:0.2,(3:0.3,4:0.4):0.5)):0.7")
#' @export

is.Newick <- function(newick_string){

  if(class(newick_string)!='character')return(FALSE)
  newick_string  <- str_replace_all(newick_string,":\\d+\\.{0,1}\\d*", "")
  if(str_sub(newick_string,-1,-1)!=';') newick_string <- paste0(newick_string,';')
  if(str_count(newick_string,"\\(") !=str_count(newick_string,"\\)"))return(FALSE)
  while(TRUE){
    newick_string_pre <- newick_string
    newick_string <- str_replace_all(newick_string,'\\([\\d+|\\?],[\\d+|\\?]\\)','\\?')
    if(newick_string_pre==newick_string)break
    # print(newick_string)
  }
  if(newick_string!="?;")return(FALSE)
  return(TRUE)
}
