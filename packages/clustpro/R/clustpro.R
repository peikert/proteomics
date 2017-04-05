#' title: "clustpro - a cluster analysis package"
#' author: "Christian Peikert and Muhammad Numair Mansur"
#' version: 0.01b
#' date: "19. Januar 2017"
#' <Add Description>
#'
#' @import htmlwidgets
#' @import ggplot2
#' @import pracma
#' @import Biobase
#' @import Mfuzz
#' @import clusterSim
#' @import pheatmap
#' @import gplots
#' @import ctc
#' @import jsonlite
#' @import foreach

#' @export
clustpro_example <- function(){
  graphic_type <<- "tif"
  matrix <- iris[-ncol(iris)]
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
                    fixed_k = -1,
                    perform_clustering = TRUE,
                    cluster_ids = NULL,
                    rows = TRUE,
                    cols = TRUE,
                    tooltip = info_list,
                    save_widget = TRUE,
                    color_legend = heatmap_color,
                    width = NULL,
                    height = NULL,
                    export_dir = NA,
                    export_type = 'svg',
                    seed=1
    )
  )


  return(clustering(matrix,method = "kmeans",  min_k = 2, max_k = 10))
}


#' @export
clustpro <- function(matrix,
                     method = "kmeans",
                     min_k = 2,
                     max_k = 10,
                     fixed_k = -1,
                     perform_clustering = TRUE,
                     cluster_ids = NULL,
                     rows = TRUE,
                     cols = TRUE,
                     tooltip = NULL,
                     save_widget = TRUE,
                     color_legend = NULL,
                     width = NULL,
                     height = NULL,
                     export_dir = NA,
                     export_type = 'svg',
                     seed = NULL) {
  if (F) {
    library(htmlwidgets)
    library(ggplot2)
    library(pracma)
    library(Biobase)
    library(Mfuzz)
    library(clusterSim)
    library(pheatmap)
    library(gplots)
    library(ctc)
    library(jsonlite)
    library(foreach)

    matrix <- matrix
    min_k = 2
    max_k = 100
    fixed_k = -1
    method = "kmeans"
    no_cores = 2
    perform_clustering = TRUE
    cluster_ids = NULL
    tooltip = info_list
    rows = TRUE
    cols = TRUE
    color_legend = heatmap_color
    export_dir = NA
    export_type = 'svg'
    seed = 1
  }
  if (F) {
    matrix = matrix
    col_dend_hclust = data2$col_dend_hclust
    cluster_ids = cluster_ids
    perform_clustering = FALSE
    rows = FALSE
    cols = TRUE
  }

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


  # matrix = rs$matrix
  clusters <- NULL
  cluster_centers <- NULL
  row_dend_nw <- NULL
  col_dend_nw <- NULL
  row_dend_hclust <- NULL
  col_dend_hclust <- NULL
  data <- NULL
  cobject <- NULL


  if (!perform_clustering) {
    clusters <- cluster_ids
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
    if (is.null(cluster_ids) ||
        class(cluster_ids) != 'integer' ||
        length(cluster_ids) != nrow(matrix)) {
      stop('cluster_ids has to been a numeric vector of same length as the data matrix!')
    }
    if (!is.logical(rows) &&
        !is.null(rows) && class(rows) == "hclust") {
      row_dend_nw <- hc2Newick(rows)
      row_dend_nw <- gsub(":\\d+\\.{0,1}\\d*", "", row_dend_nw)
      row_dend <- as.dendrogram(rows)
    }
    if (!is.logical(cols) &&
        !is.null(cols) && class(cols) == "hclust") {
      col_dend_nw <- hc2Newick(cols)
      col_dend_nw <- gsub(":\\d+\\.{0,1}\\d*", "", col_dend_nw)
      col_dend <- as.dendrogram(cols)
    }
  } else{
    rs <- clustering(
      matrix = matrix,
      method = method,
      min_k = min_k,
      max_k = max_k,
      fixed_k = fixed_k,
      no_cores = no_cores,
      seed = seed
    )

    matrix = rs$data[, !colnames(rs$data) %in% 'cluster']
    clusters = rs$clusters
    cluster_centers = rs$cluster_centers
    row_dend_nw = rs$dendnw_row_nw
    col_dend_nw = rs$dendnw_col_nw
    row_dend_hclust <- rs$row_dend_hclust
    col_dend_hclust <- rs$col_dend_hclust
    data = rs$data
    cobject = rs$cobject
  }
  new_order <-
    sapply(rownames(matrix), function(x)
      which(x == tooltip[['id']]))
  reordered_tooltip <- lapply(tooltip, function(x)
    x[new_order])
  reordered_tooltip[['id']] <- NULL
  ### color matrix ###
  color_matrix <-
    as.data.frame(
      apply(
        matrix,
        c(1, 2),
        get_color,
        ticks = color_legend$ticks,
        colors = color_legend$colors
      )
    ) ## without id column
  colnames(color_matrix) <- colnames(matrix)
  rownames(color_matrix) <- rownames(matrix)
  #############

  payload[['matrix']] <- list(
    data = as.matrix(matrix),
    rows = rownames(matrix),
    cols = colnames(matrix),
    dim = dim(matrix)
  )

  payload[['clusters']] <- clusters


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
  ######
  payload[['tooltip']] <- reordered_tooltip

  payload[['export_dir']] <- export_dir
  payload[['export_type']] <- export_type

  json_payload = toJSON(payload, pretty = TRUE)
  write(json_payload,
        file = "payload.json",
        ncolumns = 1,
        append = FALSE)
  write(data.frame(),
        file = "version_0.03a",
        ncolumns = 1,
        append = FALSE)
  widget <- htmlwidgets::createWidget(
    'clustpro',
    json_payload,
    width = width,
    height = height,
    sizingPolicy = sizingPolicy(browser.fill = TRUE)
  )
  show(widget)
  if (save_widget) {
    saveWidget(widget, file = paste(getwd(), 'widget.html', sep = '/'))
  }
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
clustproOutput <-
  function(outputId,
           width = '100%',
           height = '400px') {
    htmlwidgets::shinyWidgetOutput(outputId, 'clustpro', width, height, package = 'clustpro')
  }

#' @rdname clustpro-shiny
#' @export
renderClustpro <-
  function(expr,
           env = parent.frame(),
           quoted = FALSE) {
    if (!quoted) {
      expr <- substitute(expr)
    } # force quoted
    shinyRenderWidget(expr, clustproOutput, env, quoted = TRUE)
  }

distributions_histograms <- function(matrix) {
  for (i in 1:ncol(matrix)) {
    x <- matrix[, i, drop = FALSE]
  initialize_graphic(paste('distribution_column_',colnames(matrix)[i], sep = "_"), type = 'tif')
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
    show(g)
  dev.off()
  }
}

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

findk_cmeans <- function(matrix, k, minimalSet, fp, seed = NULL) {
  tryCatch({
    if (!is.null(seed))
      set.seed(seed)
    cluster <- mfuzz(minimalSet, c = k, m = fp)$cluster
    db_score <- index.DB(matrix,
                         cluster,
                         centrotypes = "centroids",
                         p = 2,
                         q = 2)
    return(c(k, db_score$DB))
  }, warning = function(w) {
    print(paste('findk_cmeans', w, sep = ': '))
    return(NA)
  }, error = function(e) {
    print(paste('findk_cmeans', e, sep = ': '))
    return(NA)
  })
}

findk_kmeans <- function(matrix, k, seed = NULL) {
  tryCatch({
    if (!is.null(seed))
      set.seed(seed)
    cluster <- kmeans(matrix, k, iter.max = 1000)
    db_score <-
      index.DB(
        matrix,
        cluster$cluster,
        centrotypes = "centroids",
        p = 2,
        q = 2
      )
    return(c(k, db_score$DB))
  }, warning = function(w) {
    print(paste('findk_kmeans', w, sep = ': '))
    return(NA)
  }, error = function(e) {
    print(paste('findk_kmeans', e, sep = ': '))
    return(NA)
  })
}

get_best_k <-
  function(matrix,
           min_k,
           max_k,
           method,
           no_cores,
           seed = NULL) {
    if (nrow(matrix) < max_k) {
      max_k <- nrow(matrix)
      print("max_k larger the rows in matrix.")
      print(paste("max_k was set to ", max_k, sep = ""))
    }
    iterations <- max_k
    matrix <- matrix

    switch(method,
           kmeans = {
             findk <- findk_kmeans
             db_list <-
               t(foreach(
                 k = c(min_k:iterations),
                 .combine = "cbind",
                 .export = c('findk', 'matrix', 'seed')
               ) %do% findk(matrix, k, seed))
             return(list(db_list = db_list))

           },
           cmeans = {
             minimalSet <- ExpressionSet(assayData = as.matrix(matrix))
             fp <- mestimate(minimalSet)
             findk <- findk_cmeans
             clusterExport(cl, c("matrix", "findk", "seed"))
             clusterEvalQ(cl, c(library('clusterSim'), library('Mfuzz'), library('e1071'), library('clustpro'), library('Biobase')))
             db_list <- t(foreach(
               k = c(min_k:iterations),
               .combine = "cbind",
               .export = c("mfuzz", "index.DB", "minimalSet", "fp")
             ) %dopar% {
               findk(matrix, k, minimalSet, fp)
             })
             return(list(
               db_list = db_list,
               minimalSet = minimalSet,
               fp = fp
             ))
           })


  }

clustering <- function(matrix,
                       min_k = 2,
                       max_k = 100,
                       fixed_k = -1,
                       method = "kmeans",
                       no_cores = 2,
                       seed = NULL) {
  #  distributions_histograms(matrix, "distributions_histograms")
  distributions_histograms(matrix)

  if (fixed_k > 0) {
    k <- fixed_k
  } else {
    rv <-
      get_best_k(matrix, min_k, max_k, method, no_cores = no_cores, seed)
    db_list <- as.data.frame(rv$db_list)
    if (method == 'cmeans') {
      minimalSet <- rv$minimalSet
      fp <- rv$fp
    }
    k <- as.numeric(db_list[db_list[, 2] == max(db_list[, 2], na.rm = TRUE),][1])
    colnames(db_list) <- c('k','score')
    initialize_graphic('best k estimation', type = 'tif')
    g <-
      ggplot(db_list, aes(x = k, y=score)) +
      geom_line()+
      geom_point()+
      geom_point(data = db_list[which(db_list$k == k),],mapping = aes(x=k,y=score), color="red") +
      geom_text(data = db_list[which(db_list$k == k),],mapping = aes(x=k,y=score), label = paste('k:',k,';seed:',seed,sep=''), vjust = 0, nudge_y = 0.01, color="red")+
      ylab("Davies–Bouldin Index [DBI]") +
      xlab("k") +
      # scale_x_continuous(limits=c(-2, 7),breaks = (-2:7))+
      theme(plot.title = element_text(size = 12, face = "plain"),
            axis.title=element_text(size=12,face="plain"),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            panel.background = element_blank(),
            axis.line = element_line(colour = "black")) +
   ggtitle('best k estimation')
    show(g)
   dev.off()
  }
  if (!is.null(seed))
    set.seed(seed)
  cluster_cols <- F
  cluster_rows <- T

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

  set.seed(1234)
  d_rows <-
    dist(cluster_centers, method = "euclidean") # distance matrix
  d_cols <-
    dist(t(cluster_centers), method = "euclidean") # distance matrix

  row_dend_hclust <- hclust(d_rows, method = "ward.D2")
  col_dend_hclust <- hclust(d_cols, method = "ward.D2")

  col_dend_nw <- hc2Newick(col_dend_hclust)
  col_dend_nw <- gsub(":\\d+\\.{0,1}\\d*", "", col_dend_nw)

  row_dend_nw <- hc2Newick(row_dend_hclust)
  row_dend_nw <- gsub(":\\d+\\.{0,1}\\d*", "", row_dend_nw)
  col_dend <- as.dendrogram(col_dend_hclust)
  row_dend <- as.dendrogram(row_dend_hclust)

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
#' @param title , project, type, number
#' @keywords initialize graphic
#' @export
#' @examples
#' initialize_graphic()
initialize_graphic <- function(title, type = graphic_type, ...) {
  gap_free_title <- gsub('\\s', '_', title)
  switch(type,
         svg = {
           svg(paste(gap_free_title, '.svg', sep = ''),
               width = 10,
               height = 10)
         },
         tif = {
           tiff(
             paste(gap_free_title, '.tif', sep = ''),
             width = 2000,
             height = 2000,
             res = 200,
             compression = 'lzw'
           )
         },
         pdf = {
           pdf(paste(gap_free_title, '.pdf', sep = ''),
               width = 10,
               height = 10)
         })
}



#' Function to get color
#'
#' xxxxxx
#' @param x
#' @keywords get color
#' @export
#' @examples
#' get_color()

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
#' @param values should be a list which define the breaks of the color space. color_spect should be a list of color. Keep in mean that there must be 1 more board in the vaules list than color in color_spect.
#' @keywords color spectrum heatmaps
#' @export
#' @examples
#' color_spectrum()
color_spectrum <-
  function(values, color_spect, shift_factor = 0.0000000001) {
    index <- 1
    colors <- c()
    ticks <- c()
    while (index < length(values)) {
      ticks <-
        c(ticks,
          seq(values[index] + shift_factor, values[index + 1] - shift_factor, length =
                100))
      index <- index + 1
    }
    ticks <- unique(ticks)
    colors <-
      colorRampPalette(color_spect)(n = ((length(values) - 1) * 100) - 1)
    return(list(ticks = ticks, colors = colors))
  }

####

#' Function to set heatmap color
#'
#' This function allows you to define the color spectrum for heatmaps.
#' @param data todo
#' @param color_list todo
#' @param intervals todo
#' @param auto todo
#' @keywords color spectrum heatmaps
#' @export
#' @examples
#' color_spectrum()

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
                            colors = colorRampPalette(color_list)(n = 299))
    } else{
      if (min(intervals) > min(data, na.rm = TRUE) |
          max(data, na.rm = TRUE) > max(intervals)) {
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
      br <- min(diff(intervals) / 40)
      heatmap_color <- color_spectrum(intervals, color_list, br)
      heatmap_color$ticks[1]
      heatmap_color$ticks[301]
      sapply(heatmap_color, length)
    }
  }
