#setwd("D:/git/proteomics/packages)
# install.packages('devtools')
# source("https://bioconductor.org/biocLite.R")
# biocLite("Biobase")
# biocLite("Mfuzz")
# biocLite("ctc")
# biocLite("roxygen2")
# install.packages('ggplot2')
# options(warn=-1)
#devtools::create("clustpro")
if(F){
  library(devtools)
#setwd("C:/Users/cpeikert/Documents/proteomics/packages/clustpro")
  setwd("D:/git/proteomics/packages/clustpro")
# devtools::check()
  devtools::document()
  devtools::install()
  #devtools::reload()
}
setwd("D:/git/proteomics/packages/clustpro/output")
library("clustpro")

get_first_split_element <- function(x,split){
  return(sub('\\s+$', '',unlist(strsplit(x, split))[1]))
}
# unload("D:/git/proteomics/packages/clustpro")
#remove.packages('clustpro')


graphic_type <<- "tif"
matrix <- iris[-ncol(iris)]
#




#########

test_data = read.csv('D:/git/proteomics/packages/clustpro/for_clustering.txt',sep='\t',header=TRUE,check.names=FALSE, stringsAsFactors = FALSE)
rownames(test_data) <- test_data[,1]
test_data[,1] <- NULL
min(test_data)
max(test_data)
br <- min(diff(c(-1.1,-0.5,-0.1,0.1,0.5,1.1))/40)
heatmap_color <- color_spectrum(c(-1.1,-0.5,-0.1,0.1,0.5,1.1),c("blue","lightblue","white","yellow", "red"),br)

heatmap_color$label_position <- c(-1,-0.5,0,0.5,1)

intervals <- c(-1.1,-0.5,-0.1,0.1,0.5,1.1)
color_list <- c("blue","lightblue","white","yellow", "red")
data  <- test_data

heatmap_color <- setHeatmapColors(data=test_data,color_list = ('red','yellow','green','blue'),auto=TRUE)
matrix <- test_data

info_list <- list()
info_list[['id']]  <- rownames(matrix)
info_list[['link']] <- paste('http://tritrypdb.org/tritrypdb/app/record/gene/',sapply(rownames(matrix),get_first_split_element,';'),sep='')
info_list[['description']] <- rep('no description', nrow(matrix))

#####


# test_data = read.csv('D:/projects/AG Warscheid/MM87/clustering_do not work.txt',sep='\t',header=TRUE,check.names=FALSE, stringsAsFactors = FALSE)
# rownames(test_data) <- test_data[,1]
# test_data[,1] <- NULL
# min(test_data)
# max(test_data)
# br <- min(diff(c(-0.1,0.2,0.4,0.6,0.8,1.1,2.1))/40)
# # heatmap_color <- color_spectrum(c(-0.1,0.2,0.4,0.6,0.8,1.1,2.1),c("blue","lightblue","white","yellow", "red"),br)
# heatmap_color <-color_spectrum(c(-0.1,0.2,0.4,0.6,0.8,1.1,(df_max+1)),c("white","white","yellow","orange", "red",'red'),br)
#
# heatmap_color$label_position <- c(0,0.5,1,1.5,2)
#
#
# info_list <- list()
#
#
# info_list[['link']] <- paste('http://www.yeastgenome.org/locus/',sapply(rownames(test_data),get_first_split_element,';'),'/overview',sep='')
# info_list[['description']] <- rep('no description', nrow(test_data))
#
# matrix <- test_data

####






# matrix <- rbind(matrix,matrix)
# matrix <- rbind(matrix,matrix)
#########
# matrix <- as.data.frame(matrix(round(runif(400, 0.1, 9.9),1),ncol=4,byrow=T))
# matrix <- as.data.frame(matrix(round(runif(4800, 0.1, 9.9),1),ncol=4,byrow=T))
# matrix <- as.data.frame(matrix(round(runif(4800*4, 0.1, 9.9),1),ncol=4,byrow=T))

# colnames(matrix) <- c('A','B','C','D')
# rownames(matrix) <- paste('gene_',c(1:nrow(matrix)))


# data2 <- clustpro(matrix=matrix, method = "kmeans", min_k = 2, max_k = 10)



color_legend <- heatmap_color
# first run this:    perform clustpro with clustering
head(matrix)
data2 <- clustpro(matrix=matrix,
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





head(data2$datatable)
tail(data2$datatable)
write.table(data2$datatable, 'test.txt', sep = "\t", row.names = TRUE , col.names = NA, quote = FALSE)

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
