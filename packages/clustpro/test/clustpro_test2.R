
if(F){
  library(devtools)
  setwd("D:/git/proteomics/packages/clustpro")
# devtools::check()
  devtools::document()
  devtools::install()
  #devtools::reload()
}
setwd("D:/git/proteomics/packages/clustpro/output")
library("clustpro")
help(package = clustpro)
# clustpro_example()

get_first_split_element <- function(x,split){
  return(sub('\\s+$', '',unlist(strsplit(x, split))[1]))
}
# unload("D:/git/proteomics/packages/clustpro")
#remove.packages('clustpro')


graphic_type <<- "tif"
# matrix <- iris[-ncol(iris)]
#

msdata <- readRDS('data/sample_data.rds')
min(msdata[,c(3:6)])
max(msdata[,c(3:6)])
intervals <- c(-10.1,-5.0,-2.5,2.5,5.0,10.1)
color_list <- c("blue","lightblue","white","yellow", "red")

heatmap_color <- setHeatmapColors(data = msdata[,c(3:6)],color_list = color_list, intervals = intervals,auto=T)

heatmap_color <- setHeatmapColors(data=msdata[,c(3:6)],color_list = color_list ,auto=TRUE)
heatmap_color$label_position <- c(-8,0,8)


info_list <- list()
info_list[['id']]  <- rownames(msdata)
info_list[['link']] <- paste('http://www.uniprot.org/uniprot/',sapply(rownames(msdata),get_first_split_element,';'),sep='')
info_list[['description']] <- msdata$definition
info_list[['test']] <- rep('non',nrow(msdata))

color_legend <- heatmap_color
# matrix <- msdata[,c(3:6)]
cr <- clustpro(matrix=msdata[,c(3:6)],
                  method = "kmeans",
                  min_k = 2,
                  max_k = 100,
                  fixed_k = -1,
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
                  seed=1
                  )





# head(cr$datatable)
# tail(cr$datatable)
# write.table(cr$datatable, 'test.txt', sep = "\t", row.names = TRUE , col.names = NA, quote = FALSE)

# data2 <- clustpro(matrix=matrix,
#                   method = "kmeans",
#                   min_k = 2,
#                   max_k = 10,
#                   fixed_k = 25,
#                   tooltip = info_list,
#                   cols = FALSE,
#                   rows = TRUE,
#                   color_legend = heatmap_color
# )
#
# data2 <- clustpro(matrix=matrix,
#                   method = "kmeans",
#                   min_k = 2,
#                   max_k = 10,
#                   fixed_k = 25,
#                   tooltip = info_list,
#                   cols = TRUE,
#                   rows = FALSE,
#                   color_legend = heatmap_color,
#                   export_dir = "D://test",
#                   export_type = 'svg'
# )

#

# second  run this:    use clustering results from clustpro to perform clustpro without clustering

# cluster_ids <- as.vector(data2$cobject$cluster)
# data2$col_dend_hclust
# df_matrix <- data2$datatable
# df_matrix$cluster <- cluster_ids
# col_dend <- as.dendrogram(data2$col_dend_hclust)
#
# if(class(col_dend)=="dendrogram"){
#   df_matrix <- df_matrix[,c(order.dendrogram(col_dend),ncol(df_matrix))]
# }
#
#
# nrow(df_matrix)
# clustpro(matrix = df_matrix[,-ncol(df_matrix)],
#          cluster_ids = cluster_ids,
#         tooltip = info_list,
#         cols = TRUE,
#         rows = FALSE,
#          perform_clustering = FALSE)
#
