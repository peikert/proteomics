#' Example app 3
#' By using a list of parameter it is possible to use default values for parameter with entry NULL
#'
#' parameter_list list of parameter for clustpro function call.
app03 <- function(parameter_list) {
require(shiny)
shinyApp(
  ui = fluidPage(div(style = 'width: 100% ; height:100vh', clustproOutput("cluster"))),
  server = function(input, output) {
    output$cluster <- renderClustpro({
      do.call(clustpro,parameter_list)
  })
  }
    )
  }

