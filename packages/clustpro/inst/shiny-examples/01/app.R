library('shiny')
library('clustpro')
library('gradientPickerD3')
source('module_shiny_clustpro.R')
library("plotly")
library('stringr')

#' @export
shinyClustPro = function(data,  data_columns, info_columns){
  calls = match.call()
  shinyApp(
ui <- fluidPage(
        clustProPanelUI('clustProPanel')
  ),
# Define server logic required to draw a histogram
shinyServer(function(input, output) {

out_clustProPanel <- callModule(clustProPanel,"clustProPanel",reactive(data), data_columns, info_columns)
# out_clustProPanel <- callModule(clustProPanel,"clustProPanel")
})
  )}

#proteomics_data <- read.csv('D:/proteomics_data.txt',sep='\t',header=TRUE,check.names=FALSE, stringsAsFactors = FALSE)
#devtools::use_data(proteomics_data,overwrite = TRUE)
# Run the application
#shinyClustPro(iris)
#shinyClustPro()


# data("proteomics_data")
# shinyClustPro(proteomics_data)

#test_data = na.omit(datasets::mtcars) #deletion of missing
#test_data = as.data.frame(scale(test_data)) #standarize variables
# nrow(test_data[,1:2])
#
# test_data[!duplicated(test_data[,1:2]),]
# kmeans(test_data[,1:2],27, iter.max = 1000)
# nrow(test_data)
df_mtcars <- datasets::mtcars
df_data <- as.data.frame(scale(df_mtcars))
colnames(df_mtcars) <- paste0('info_',colnames(df_mtcars))
data_columns <- colnames(df_data)
info_columns <- colnames(df_mtcars)
df_data <- cbind(df_data,df_mtcars)

max(df_data)
min(df_data)
shinyClustPro(df_data, data_columns = data_columns, info_columns = info_columns)

