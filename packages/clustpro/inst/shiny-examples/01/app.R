library('shiny')
# library('shinyjs')
library('clustpro')
library('gradientPickerD3')
source('module_shiny_clustpro.R')
library("plotly")
library('stringr')

#'shinyClustPro
#'
#' ToDo
#'
#' @param data ToDo
#' @param data_columns ToDo
#' @param info_columns ToDo
#'
#' @import shiny, shinyjs, clustpro, gradientPickerD3
#' @import plotly
#' @import string
#' @export
shinyClustPro = function(data,  data_columns, info_columns){
  calls = match.call()
  shinyApp(
ui <- fluidPage(
      # useShinyjs(),
      #extendShinyjs(text = jsCode),
        clustProPanelUI('clustProPanel')
  ),
# Define server logic required to draw a histogram
shinyServer(function(input, output) {

out_clustProPanel <- callModule(clustProPanel,"clustProPanel",reactive(data), data_columns, info_columns)
# out_clustProPanel <- callModule(clustProPanel,"clustProPanel")
})
  )}


df_mtcars <- datasets::mtcars
df_data <- as.data.frame(scale(df_mtcars))
colnames(df_mtcars) <- paste0('info_',colnames(df_mtcars))
data_columns <- colnames(df_data)
info_columns <- colnames(df_mtcars)
df_data <- cbind(df_data,df_mtcars)

shinyClustPro(df_data, data_columns = data_columns, info_columns = info_columns)

