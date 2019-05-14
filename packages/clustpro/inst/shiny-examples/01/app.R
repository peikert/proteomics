require(shiny)
shinyApp(
  ui = fluidPage(
     div(style = 'width: 100% ; height:100vh',clustproOutput("cluster"))
  ),
  server = function(input, output, session) {
    output$cluster <- renderClustpro({
      df_mtcars <- datasets::mtcars
      df_data <- as.data.frame(scale(df_mtcars))
      colnames(df_mtcars) <- paste0('info_', colnames(df_mtcars))
      data_columns <- colnames(df_data)
      info_columns <- colnames(df_mtcars)
      data <- cbind(df_data, df_mtcars)
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
            stringr::str_match(x, 'info_(.*)')[2])

        info_list <- c(info_list, temp_list)
      }

      clustpro(
        matrix = data[, data_columns,drop=FALSE],
        method = "kmeans",
        min_k = 2,
        max_k = 30,
        perform_clustering = TRUE,
        rows = TRUE,
        cols = TRUE,
        tooltip = info_list,
        save_widget = TRUE,
        show_legend = FALSE,
        color_legend = color_legend,
        seed = 1234,
        cores = 2,
        useShiny = TRUE
      )
    })
  }
)
