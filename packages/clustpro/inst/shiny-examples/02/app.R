#' Example app 2
#' By using a list of parameter it is possible to use default values for parameter with entry NULL
#'
#' parameter_list list of parameter for clustpro function call.
#' @import shiny, shinyjs, clustpro, gradientPickerD3, plotly, stringr
#' @export
app <- function(parameter_list) {
shinyApp(
  ui = fluidPage(div(style = 'width: 100% ; height:100vh', clustproOutput("cluster"))),
  server = function(input, output) {
    output$cluster <- renderClustpro({
      do.call(clustpro,parameter_list)
  })
  }
    )
  }

