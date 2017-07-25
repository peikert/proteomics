library('shiny')
# library('shinyjs')
library('clustpro')
library('gradientPickerD3')
source('module_shiny_clustpro.R')
library("plotly")
library('stringr')
library("Mfuzz")
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
shinyClustPro = function(data=NULL,  data_columns=NULL, info_columns=NULL){
  calls = match.call()
  shinyApp(
ui <- fluidPage(
      # useShinyjs(),
      #extendShinyjs(text = jsCode),
        clustProPanelUI('clustProPanel')
  ),
# Define server logic required to draw a histogram
shinyServer(function(input, output) {
head(data)
out_clustProPanel <- callModule(clustProPanel,"clustProPanel",reactive(data), reactive(data_columns), reactive(info_columns))
# out_clustProPanel <- callModule(clustProPanel,"clustProPanel")
})
  )}



# df_mtcars <- datasets::mtcars
# df_data <- as.data.frame(scale(df_mtcars))
# colnames(df_mtcars) <- paste0('info_',colnames(df_mtcars))
# data_columns <- colnames(df_data)
# info_columns <- colnames(df_mtcars)
# df_data <- cbind(df_data,df_mtcars)
#
# # shinyClustPro(df_data)
# # shinyClustPro(df_data, data_columns = data_columns)
# #shinyClustPro(df_data, info_columns = info_columns)
# shinyClustPro(df_data, data_columns = data_columns, info_columns = info_columns)
#shinyClustPro()



# head(proteomics_data)
# class(proteomics_data)
data("proteomics_data")
df_proteomics <- proteomics_data
data_columns <- c("TP_MT","MT_MB","MTP_MB")
df_proteomics <- df_proteomics[complete.cases(df_proteomics[,data_columns]),]
sds <-  apply(df_proteomics[,data_columns],1,sd,na.rm=TRUE)
bp <- boxplot(sds)
df_proteomics <- df_proteomics[sds>bp$stats[5],]
info_columns <- c("uniProtID","geneNames","definition")
rownames(df_proteomics) <- df_proteomics$uniProtID
nrow(df_proteomics)
#
#
# # shinyClustPro(df_data)
# # shinyClustPro(df_data, data_columns = data_columns)
# #shinyClustPro(df_data, info_columns = info_columns)
shinyClustPro(df_proteomics, data_columns = data_columns, info_columns = info_columns)
#shinyClustPro()


