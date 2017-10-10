#' Example 2
#'
#' starts a test shiny app
#' @export
runExample02 <- function() {
  appDir <- system.file("shiny-examples", "02", package = "clustpro")
  if (appDir == "") {
    stop("Could not find example directory. Try re-installing `clustpro`.", call. = FALSE)
  }
  source(file.path(appDir,"app.R"))


  df_mtcars <- datasets::mtcars
  df_data <- as.data.frame(scale(df_mtcars))
  colnames(df_mtcars) <- paste0('info_', colnames(df_mtcars))
  data_columns <- colnames(df_data)
  info_columns <- colnames(df_mtcars)
  data <- cbind(df_data, df_mtcars)

  # intervals <- c(-1.1,-0.5,0,0.5,1.1)
  color_list <- c("blue", "lightblue", "white", "yellow", "red")
  color_legend <-
    setHeatmapColors(data = df_data,
                     color_list = color_list,
                     auto = TRUE)
  color_legend$label_position <-
    seq(ceiling(min(df_data)), floor(max(df_data)), by = 1)

  info_list <- list()
  info_list[['id']]  <- rownames(data)
  info_list[['link']] <-
    paste('https://www.google.de/search?q=/', rownames(data), sep = '')
  info_list[['description']] <-
    rep('no description', nrow(data))

  if (!is.null(info_columns)) {
    temp_list <- lapply(info_columns, function(x) {
      data[, x]
    })
    names(temp_list) <-
      sapply(info_columns, function(x)
        stringr:::str_match(x, 'info_(.*)')[2])

    info_list <- c(info_list, temp_list)
  }

  parameter_list <- list()
  parameter_list$matrix = data[, data_columns,drop=FALSE]
  parameter_list$method = "kmeans"
  parameter_list$min_k = 2
  parameter_list$max_k = 30
  parameter_list$perform_clustering = TRUE
  parameter_list$simplify_clustering = TRUE
  parameter_list$rows = TRUE
  parameter_list$cols = TRUE
  parameter_list$tooltip = info_list
  parameter_list$save_widget = TRUE
  parameter_list$show_legend = FALSE
  parameter_list$color_legend = color_legend
  parameter_list$seed = 1234
  parameter_list$cores = 2
  parameter_list$useShiny = TRUE

  app03(parameter_list)
}
