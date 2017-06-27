#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library('shiny')
library('clustpro')
library('gradientPickerD3')
source('module_shiny_clustpro.R')
library("plotly")
# Define UI for application that draws a histogram
ui <- fluidPage(


      # Show a plot of the generated distribution
   #   mainPanel(
        #div(style = 'overflow-x: scroll; overflow-y: scroll; width: 100% ; height:150px',clustproOutput("clustpro"))
        clustProPanelUI('clustProPanel')
   #   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

  out_clustProPanel <- callModule(clustProPanel,"clustProPanel",reactive(iris))




}

# Run the application
shinyApp(ui = ui, server = server)

