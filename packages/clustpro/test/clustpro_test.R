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
color_spectrum_unqiue_breaks(c(-1.1,-0.5,-0.1,0.1,0.5,1.1),c("blue","lightblue","white","yellow", "red"),br)
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
data2 <- clustpro(matrix=matrix,
                  method = "kmeans",
                  min_k = 2,
                  max_k = 10,
                  fixed_k = 25,
                  tooltip = info_list
                  )
#names(data2)
