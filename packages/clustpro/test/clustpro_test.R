#setwd("D:/git/proteomics/packages)
# install.packages('devtools')
# source("https://bioconductor.org/biocLite.R")
# biocLite("Biobase")
# biocLite("Mfuzz")
# biocLite("ctc")
# biocLite("roxygen2")
# install.packages('ggplot2')

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
# unload("D:/git/proteomics/packages/clustpro")
#remove.packages('clustpro')


graphic_type <<- "tif"
br <- min(diff(c(0,2,4,6,8,10))/40)
color_spectrum_unqiue_breaks(c(0,2,4,6,8,10),c("grey","khaki2","yellow","orange", "red"),br)
#
matrix <- iris[-ncol(iris)]
#




#########

test_data = read.csv('D:/git/proteomics/packages/clustpro/for_clustering.txt',sep='\t',header=TRUE,check.names=FALSE, stringsAsFactors = FALSE)
rownames(test_data) <- test_data[,1]
test_data[,1] <- NULL
min(test_data)
max(test_data)
br <- min(diff(c(-1.1,-0.5,-0.1,0.1,0.5,1.1))/40)
heatmap_color <- color_spectrum_unqiue_breaks(c(-1.1,-0.5,-0.1,0.1,0.5,1.1),c("blue","lightblue","white","yellow", "red"),br)

heatmap_color$label_position <- c(-1,-0.5,0,0.5,1)

matrix <- test_data
# matrix <- rbind(matrix,matrix)
# matrix <- rbind(matrix,matrix)
#########
# matrix <- as.data.frame(matrix(round(runif(400, 0.1, 9.9),1),ncol=4,byrow=T))
# matrix <- as.data.frame(matrix(round(runif(4800, 0.1, 9.9),1),ncol=4,byrow=T))
# matrix <- as.data.frame(matrix(round(runif(4800*4, 0.1, 9.9),1),ncol=4,byrow=T))

# colnames(matrix) <- c('A','B','C','D')
# rownames(matrix) <- paste('gene_',c(1:nrow(matrix)))


# data2 <- clustpro(matrix=matrix, method = "kmeans", min_k = 2, max_k = 10)

get_first_split_element <- function(x,split){
  return(sub('\\s+$', '',unlist(strsplit(x, split))[1]))
}

info_list <- list()
info_list[['link']] <- paste('http://tritrypdb.org/tritrypdb/app/record/gene/',sapply(rownames(matrix),get_first_split_element,';'),sep='')
info_list[['description']] <- rep('no description', nrow(matrix))

# first run this:    perform clustpro with clustering

data2 <- clustpro(matrix=matrix,
                  method = "kmeans",
                  min_k = 2,
                  max_k = 10,
                  fixed_k = 25,
                  tooltip = info_list,
                  cols = TRUE,
                  rows = TRUE,
                  color_legend = heatmap_color,
                  export_dir = "D://test",
                  export_type = 'svg'
                  )



data2 <- clustpro(matrix=matrix,
                  method = "kmeans",
                  min_k = 2,
                  max_k = 10,
                  fixed_k = 25,
                  tooltip = info_list,
                  cols = FALSE,
                  rows = TRUE
)

data2 <- clustpro(matrix=matrix,
                  method = "kmeans",
                  min_k = 2,
                  max_k = 10,
                  fixed_k = 25,
                  tooltip = info_list,
                  cols = TRUE,
                  rows = FALSE,
                  export_dir = "D://test",
                  export_type = 'svg'
)

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
