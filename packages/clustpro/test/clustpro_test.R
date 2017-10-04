
if(F){

  #devtools::reload()
  # clustpro::mcp_reimann_et_al_2017
  # unload("D:/git/proteomics/packages/clustpro")
  #remove.packages('clustpro')
}

get_first_split_element <- function(x,split){
  return(sub('\\s+$', '',unlist(strsplit(x, split))[1]))
}


setwd("D:/git/proteomics/packages/clustpro")
library("clustpro")
##help(package = clustpro)
# clustpro_example()
# data()
graphic_type <<- "tif"


data = read.csv('D:/for_clustering.txt',sep='\t',header=TRUE,check.names=FALSE, stringsAsFactors = FALSE)
rownames(data) <- data[,1]
data[,1] <- NULL
min(data)
max(data)

intervals <- c(-1.1,-0.5,0,0.5,1.1)
color_list <- c("blue","lightblue","white","yellow", "red")


heatmap_color <- setHeatmapColors(data=data, color_list = color_list,auto=TRUE)
sapply(heatmap_color,length)
heatmap_color <- setHeatmapColors(data=data, color_list = color_list, intervals = intervals,auto=FALSE)
sapply(heatmap_color,length)

heatmap_color <- setHeatmapColors(data=NULL, color_list = color_list, intervals = intervals,auto=FALSE)
sapply(heatmap_color,length)


info_list <- list()
info_list[['id']]  <- rownames(data)
info_list[['link']] <- paste('http://tritrypdb.org/tritrypdb/app/record/gene/',sapply(rownames(matrix),get_first_split_element,';'),sep='')
info_list[['description']] <- rep('no description', nrow(matrix))

color_legend <- heatmap_color





  matrix=data #[,1,drop=FALSE]
  method = "cmeans"
  min_k = 2
  max_k = 30
  fixed_k = NULL
  perform_clustering = TRUE
  clusterVector = NULL
  rows = TRUE
  cols = TRUE
  tooltip = info_list
  save_widget = TRUE
  show_legend = FALSE
  color_legend = setHeatmapColors(matrix, color_list = color_list,auto=TRUE)
  width = NULL
  height = NULL
  export_dir = NULL
  export_type = 'svg'
  export_graphics = FALSE
  seed=1234
  cores = 2

  if(F){
  library(htmlwidgets)
  library(ggplot2)
  library(pracma)
  library(Biobase)
  library(Mfuzz)
  library(clusterSim)
  library(pheatmap)
  library(gplots)
  library(ctc)
  library(jsonlite)
  library(foreach)
  }

  test1 <- get_best_k(matrix,min_k = 2,max_k = 20,method = 'kmeans', seed=1234)

  dm <- test1$cluster_distances
  test2 <- get_best_k(matrix,min_k = 2,max_k = 20,method = 'cmeans', seed=1234)
  test <- test$db_list
  test <- as.data.frame(sapply(test,as.numeric))
  class(test$k)
  class(mtcars$mpg)
  sapply(test,class)
  db_list <- test$db_list
  filtered_db_list <- db_list[complete.cases(db_list[,c('k','score','withinerror')]),]

  get_best_k(data,min_k = 2,max_k = 20,method = 'kmeans', seed=1234)
  get_best_k(matrix,min_k = 2,max_k = 20,method = 'cmeans', seed=1234, cores = 2)





# clustpro(matrix=matrix[,1,drop=FALSE],
dim(matrix)
class(matrix)
cr <- clustpro(matrix=matrix,
                  method = "cmeans",
                  min_k = 2,
                  max_k = 30,
                  fixed_k = NULL,
                  perform_clustering = TRUE,
                  clusterVector = NULL,
                  rows = TRUE,
                  cols = TRUE,
                  tooltip = info_list,
                  save_widget = TRUE,
                  simplify_clustering=TRUE,
                  color_legend = heatmap_color,
                  width = NULL,
                  height = NULL,
                  export_dir = NULL,
                  export_type = 'svg',
                  export_graphics = FALSE,
                  seed=1,
                  cores = 2,
                  useShiny = T
                  )


pre_cluster <-as.data.frame(cr$datatable)
mean_cluster <- as.data.frame(cr$cobject$centers)
clusterVector <- unique(pre_cluster$cluster)
rownames(mean_cluster) <- paste0('cluster ',rownames(mean_cluster))

info_list <- list()
info_list[['id']]  <- rownames(mean_cluster)


dend_col <- cr$col_dend_hclust
dend_row <- cr$row_dend_hclust
  clustpro(matrix=mean_cluster,
           method = "kmeans",
           min_k = 2,
           max_k = 30,
           fixed_k = NULL,
           perform_clustering = FALSE,
           clusterVector = clusterVector,
           rows = dend_row,
           cols = dend_col,
           tooltip = info_list,
           save_widget = TRUE,
           color_legend = heatmap_color,
           width = NULL,
           height = NULL,
           export_dir = NULL,
           export_type = 'svg',
           export_graphics = FALSE,
           seed=1,
           cores = 2,
           useShiny = T
  )
