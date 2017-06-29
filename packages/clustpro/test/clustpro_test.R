
if(F){
  library(devtools)
  setwd("D:/git/proteomics/packages/clustpro")
# devtools::check()
  devtools::document()
  devtools::install()
  #devtools::reload()

  # unload("D:/git/proteomics/packages/clustpro")
  #remove.packages('clustpro')
}

get_first_split_element <- function(x,split){
  return(sub('\\s+$', '',unlist(strsplit(x, split))[1]))
}


setwd("D:/git/proteomics/packages/clustpro/output")
library("clustpro")
##help(package = clustpro)
clustpro_example()

graphic_type <<- "tif"
matrix <- iris[-ncol(iris)]

test_data = read.csv('D:/git/proteomics/packages/clustpro/data/for_clustering.txt',sep='\t',header=TRUE,check.names=FALSE, stringsAsFactors = FALSE)
rownames(test_data) <- test_data[,1]
test_data[,1] <- NULL
min(test_data)
max(test_data)

intervals <- c(-1.1,-0.5,0,0.5,1.1)
color_list <- c("blue","lightblue","white","yellow", "red")
data  <- test_data

heatmap_color <- setHeatmapColors(data=data, color_list = color_list,auto=TRUE)
sapply(heatmap_color,length)
heatmap_color <- setHeatmapColors(data=data, color_list = color_list, intervals = intervals,auto=FALSE)
sapply(heatmap_color,length)

heatmap_color <- setHeatmapColors(data=NULL, color_list = color_list, intervals = intervals,auto=FALSE)
sapply(heatmap_color,length)
matrix <- test_data

info_list <- list()
info_list[['id']]  <- rownames(matrix)
info_list[['link']] <- paste('http://tritrypdb.org/tritrypdb/app/record/gene/',sapply(rownames(matrix),get_first_split_element,';'),sep='')
info_list[['description']] <- rep('no description', nrow(matrix))

color_legend <- heatmap_color



no_cores = 12
seed = 1234
min_k = 2
max_k = 20
method = 'cmeans'

get_best_k(matrix,min_k = 2,max_k = 20,method = 'kmeans', seed=1234)

get_best_k(matrix,min_k = 2,max_k = 20,method = 'cmeans', seed=1234, cores = 2)


matrix

method = "cmeans"
min_k = 2
max_k = 100
fixed_k = 5
perform_clustering = TRUE
cluster_ids = NULL
rows = TRUE
cols = TRUE
tooltip = info_list
save_widget = TRUE
color_legend = heatmap_color
width = NULL
height = NULL
export_dir = NA
export_type = 'svg'
seed=1234
cores = 2
graphics_export = FALSE


clustpro(matrix=matrix,
                  method = "cmeans",
                  min_k = 2,
                  max_k = 100,
                  fixed_k = 5,
                  perform_clustering = TRUE,
                  cluster_ids = NULL,
                  rows = TRUE,
                  cols = TRUE,
                  tooltip = info_list,
                  save_widget = TRUE,
                  color_legend = heatmap_color,
                  width = NULL,
                  height = NULL,
                  export_dir = NA,
                  export_type = 'svg',
                  seed=1,
                  cores = 2
                  )
