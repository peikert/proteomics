#setwd("D:/git/proteomics/packages)
# install.packages('devtools')
# source("https://bioconductor.org/biocLite.R")
# biocLite("Biobase")
# biocLite("Mfuzz")
# biocLite("ctc")
# biocLite("roxygen2")

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
library(clustpro)



graphic_type <<- "tif"
br <- min(diff(c(0,2,4,6,8,10))/40)
color_spectrum_unqiue_breaks(c(0,2,4,6,8,10),c("grey","khaki2","yellow","orange", "red"),br)
#
matrix <- iris[-ncol(iris)]
#


test_data = read.csv('D:/git/proteomics/packages/clustpro/for_clustering.txt',sep='\t',header=TRUE,check.names=FALSE, stringsAsFactors = FALSE)
#head(test_data)
matrix <- test_data
# matrix <- as.data.frame(matrix(round(runif(400, 0.1, 9.9),1),ncol=4,byrow=T))
# matrix <- as.data.frame(matrix(round(runif(4800, 0.1, 9.9),1),ncol=4,byrow=T))
# matrix <- as.data.frame(matrix(round(runif(4800*4, 0.1, 9.9),1),ncol=4,byrow=T))

# colnames(matrix) <- c('A','B','C','D')
# rownames(matrix) <- paste('gene_',c(1:nrow(matrix)))


data2 <- clustpro(matrix=matrix, method = "kmeans", min_k = 2, max_k = 10)
