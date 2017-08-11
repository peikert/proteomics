
runExample02 <- function(var) {
  require(shiny)
  shinyApp(
    ui = fluidPage(
      sidebarLayout(
        sidebarPanel(sliderInput("n", "Bins", 5, 100, 20)),
        mainPanel(plotOutput("hist"))
      )
    ),
    server = function(input, output) {


      output$hist <- renderPlot(

        clustpro(matrix=var$matrix,
                 method = var$method,
                 min_k = var$min_k,
                 max_k = var$max_k,
                 fixed_k = var$fixed_k,
                 perform_clustering = var$perform_clustering,
                 clusterVector = var$clusterVector,
                 rows = var$rows,
                 cols = var$cols,
                 tooltip = var$tooltip,
                 save_widget = var$save_widget,
                 color_legend = var$color_legend,
                 width = var$width,
                 height = var$height,
                 export_dir = var$export_dir,
                 export_type = var$export_type,
                 export_graphics = var$export_graphics,
                 seed=var$seed,
                 cores = var$cores,
                 useShiny = var$useShiny
        )






      )
    }
  )
}

