#' Example app 2
#' By using a list of parameter it is possible to use default values for parameter with entry NULL
#'
#' parameter_list list of parameter for clustpro function call.
app04 <- function(parameter_list) {
  # init_borders <-
  #   isolate(c(
  #     min(parameter_list$color_legend$init_intervals),
  #     max(parameter_list$color_legend$init_intervals)
  #   ))
  # vr <- reactiveValues(color_legend = parameter_list$color_legend)
  # color_legend <- reactive(parameter_list$color_legend)

  # vr_parameter <- reactiveValues(color_legend = parameter_list$color_legend)
  # vr_parameter <- list()


  require("shiny")
  require("gradientPickerD3")
  shinyApp(
    ui = fluidPage(
      div(style = 'width: 100% ; height:100vh', clustproOutput("cluster"))
      ,
      div(gradientPickerD3Output('gradientPickerD3'))
    ),
    server = function(input, output) {
      # showReactLog(time = TRUE)
      vr_parameter <-  sapply(names(parameter_list),function(x){reactive(parameter_list[[x]])})
      names(vr_parameter) <- names(parameter_list)

      border_extensions <- 0

      output$gradientPickerD3 <- renderGradientPickerD3({
        req(vr_parameter$color_legend())
        payload <- list(
          colors = vr_parameter$color_legend()$init_colors,
          ticks =  vr_parameter$color_legend()$init_intervals
        )
        gradientPickerD3(payload,
                         width = '50px',
                         border_extensions = border_extensions
                         )
      })

      vr_parameter$color_legend2 <- eventReactive(input$gradientPickerD3_table, {
        print('in')
        gcolors <- input$gradientPickerD3_table
        return(NULL)
        if (is.null(gcolors)) return(NULL)
          df_gcolors <-
            as.data.frame(matrix(unlist(gcolors), ncol = 3, byrow = TRUE),
                          stringsAsFactors = FALSE)
          colnames(df_gcolors) <- c('interval', 'color', 'ticks')
          df_gcolors$interval <- as.numeric(df_gcolors$interval)
          df_gcolors$ticks <- as.numeric(df_gcolors$ticks)

          return(setHeatmapColors(
            data = NULL,
            color_list = df_gcolors$color,
            intervals = df_gcolors$ticks,
            auto = FALSE
          ))
      })


    # observe({
    #   # print(vr_parameter$color_legend())
    #   print(vr_parameter$color_legend2())
    # })

      # output$cluster <- renderClustpro({
      #   temp <- parameter_list
      #   temp <- sapply(names(parameter_list),function(x){isolate(parameter_list[[x]])})
      #   names(temp) <- names(parameter_list)
      #   do.call(clustpro, temp)
      # })



      #### clustpro return values ####
      # update_json <- reactive(input$cluster_json)
      #
      # jr_dendnw_row <-
      #   eventReactive(update_json(), {
      #     update_json()[["dendnw_row"]][[1]]
      #   })
      # jr_dendnw_col <-
      #   eventReactive(update_json(), {
      #     update_json()[["dendnw_col"]][[1]]
      #   })
      # jr_matrix <-  eventReactive(update_json(), {
      #   jr_data <-
      #     data.frame(matrix(
      #       update_json()$matrix[["data"]],
      #       ncol =  update_json()$matrix$dim[[2]],
      #       byrow = TRUE
      #     ))
      #   rownames(jr_data) <- update_json()$matrix[["rows"]]
      #   colnames(jr_data) <-  update_json()$matrix[["cols"]]
      #   return(jr_data)
      # })
      #
      # observe({
      #   print(head(jr_matrix()))
      #   print(jr_dendnw_row())
      #   print(jr_dendnw_col())
      #   # print(input$cluster_clickedCell)
      #   # print(input$cluster_axis)
      # })

    }
  )
}
