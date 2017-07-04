library('shiny')
library('clustpro')
library('gradientPickerD3')
source('module_shiny_clustpro.R')
library("plotly")
library('stringr')

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
# out_clustProPanel <- callModule(clustProPanel,"clustProPanel")
})
  )}

#proteomics_data <- read.csv('D:/proteomics_data.txt',sep='\t',header=TRUE,check.names=FALSE, stringsAsFactors = FALSE)
#devtools::use_data(proteomics_data,overwrite = TRUE)
# Run the application
#shinyClustPro(iris)
#shinyClustPro()
data("proteomics_data")
shinyClustPro(proteomics_data)
