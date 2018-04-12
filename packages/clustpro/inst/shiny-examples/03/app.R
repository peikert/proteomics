# library('shiny')
# library('shinyjs')
# library('clustpro')
# library('gradientPickerD3')
# source('module_shiny_clustpro.R')
# library("plotly")
# library('stringr')
# library("Mfuzz")
#'shinyClustPro
#'
#' ToDo
#'
#' @param data ToDo
#' @param data_columns ToDo
#' @param info_columns ToDo
#'
#' @import shiny, shinyjs, clustpro, gradientPickerD3, plotly, stringr
#' @export
shinyClustPro = function(data=NULL,  data_columns=NULL, info_columns=NULL){
  lapply(c("shiny", "shinyjs", "clustpro", "gradientPickerD3", "plotly", "stringr"), library, character.only = TRUE)
  shinyApp(
ui <- fluidPage(
      # useShinyjs(),
      #extendShinyjs(text = jsCode),
        clustProPanelUI('clustProPanel')
  ),
# Define server logic required to draw a histogram
shinyServer(function(input, output) {
# options(warn = -1)
# head(data)
  if(is.null(data))file_browser=TRUE else file_browser=FALSE
  if(is.null(data_columns)) data_columns=colnames(data)
out_clustProPanel <- callModule(clustProPanel,"clustProPanel",reactive(data), reactive(data_columns), reactive(info_columns), file_browser=file_browser)
# out_clustProPanel <- callModule(clustProPanel,"clustProPanel")




})
  )}





