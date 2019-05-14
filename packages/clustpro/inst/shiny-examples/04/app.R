#' Example app 4
#' By using a list of parameter it is possible to use default values for parameter with entry NULL
#'
#' parameter_list list of parameter for clustpro function call.
app04 <- function(parameter_list) {
  require("shiny")
  require("gradientPickerD3")
  shinyApp(
    ui = fluidPage(
      div(style = 'width: 100% ; height:100vh', clustproOutput("cluster"))
      ,
      div(gradientPickerD3Output('gradientPickerD3'))
    ),
    server = function(input, output) {
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
    }
  )
}
