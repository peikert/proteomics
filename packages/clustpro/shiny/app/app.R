library('shiny')
library('clustpro')
library('gradientPickerD3')
source('module_shiny_clustpro.R')
library("plotly")

#' @export
shinyClustPro = function(data){
  calls = match.call()
  shinyApp(
ui <- fluidPage(
        clustProPanelUI('clustProPanel')
  ),

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

  out_clustProPanel <- callModule(clustProPanel,"clustProPanel",reactive(data))




})
  )}

# Run the application
shinyClustPro(iris)
