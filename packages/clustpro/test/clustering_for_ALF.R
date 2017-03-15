library("clustpro")
library("data.table")
library("dplyr")
library("ggplot2")

get_first_split_element <- function(x,split){
  return(sub('\\s+$', '',unlist(strsplit(x, split))[1]))
}

data = read.csv('D:/git/proteomics/others/20170315_data_for_clustering_ALF.txt',sep='\t',header=TRUE,check.names=FALSE, stringsAsFactors = FALSE)
rownames(data) <- data[,"Unique identifier"]
# data[,"Unique identifier"][duplicated(data[,"Unique identifier"])]
# data = fread('S:/massspec/_people/cpeikert/__Table/2vv_Motif RxRxxS+T_for CP_ALF.txt',sep='\t',header=TRUE,check.names=FALSE, stringsAsFactors = FALSE)
# dim(data)
# rownames(data) <- data$`Unique identifier`

value_cols <- c("Mean log2 ratio MK","Mean log2 ratio U0","Mean log2 ratio LY","Mean log2 ratio To")

pvalue_cols <- c("t-test Significant_MK","t-test Significant_U0","t-test Significant_LY","t-test Significant_To")

data[,value_cols] <- sapply(data[,value_cols],as.numeric)
data[,pvalue_cols] <- sapply(data[,pvalue_cols],as.numeric)

passed_t_test <- apply(data[,pvalue_cols],1,sum,na.rm=T)>=1
df_sig <- apply(data[,value_cols],c(1,2),function(x)x < (-log2(1.5)))
df_sig[is.na(df_sig)] <- FALSE
passed_sig <- apply(df_sig,1,any)
data <- data[passed_t_test & passed_sig,]
nrow(data)

matrix <- as.data.frame(data[,value_cols])
rownames(matrix) <- rownames(data)
matrix <- matrix[complete.cases(matrix),]
dim(matrix)
matrix <- apply(matrix,c(1,2),function(x)2^x)
matrix <- as.data.frame(t(apply(matrix,1,function(x)x/max(x))))
matrix <- (matrix-1)*-1
min(matrix)
max(matrix)
hist(matrix[,1])
# br <- min(diff(c(-log2(100),-log2(100),-log2(3),-log2(1.5),log2(1.5),log2(3),log2(100)))/40)
# heatmap_color <- color_spectrum(c(-log2(100),-log2(10),-log2(3),-log2(1.5),log2(1.5),log2(3),log2(100)),c("purple","purple","blue","white","red","red"),br)

# br <- min(diff(c(-0.1,0.5,1.1))/40)
# heatmap_color <- color_spectrum(c(-0.1,0.5,1.1),c("white","yellow","red"),br)

# br <- min(diff(c(-0.1,0.5,1.1))/40)
# heatmap_color <- color_spectrum(c(-0.1,0.5,1.1),c("white","yellow","red"),br)

br <- min(diff(c(-0.1,0.2,0.4,0.8,1.1))/40)
heatmap_color <- color_spectrum(c(-0.1,0.2,0.4,0.8,1.1),c("white","yellow","red","purple","blue"),br)


# br <- min(diff(c(-1.1,0.5,0.1))/40)
# heatmap_color <- color_spectrum(c(-1.1,0.5,0.1),c("red","yellow","white"),br)

# br <- min(diff(c(-1.6,-1.0,-0.5,0.5,1.0,1.6))/40)
# heatmap_color <- color_spectrum(c(-1.6,-1.0,-0.5,0.5,1.0,1.6),c("blue","skyblue1","white","yellow","red"),br)


info_list <- list()
info_list[['link']] <- paste('http://www.uniprot.org/uniprot/',sapply(rownames(matrix),get_first_split_element,';'),sep='')
info_list[['description']] <- rep(data[rownames(matrix),'Protein'], nrow(matrix))


nrow(matrix)
graphic_type <<- "tif"
for(i in 1){
# print(i)
# apply(matrix,2,hist)

ggplot(data = melt(matrix), mapping = aes(x = value)) +
  geom_histogram(bins = 50) + facet_wrap(~variable, scales = 'fixed')

cr <- clustpro(matrix=matrix,
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
                  seed=i
        )
k <- nrow(cr$cluster_centers)



df <- cr$datatable
df_counts <- table(df$cluster)
df_box <- cr$cluster_centers
rownames(df_box) <- paste('C',rownames(df_box),':#',df_counts[rownames(cr$cluster_centers)],sep='')

pdf(paste("heatmap_mean_color_block_seed_",i,"_k_",k,".pdf",sep=''))
kmeanc <- pheatmap(df_box,
                   col=heatmap_color$palette,
                   breaks=heatmap_color$colors,
                   cluster_cols = cr$col_dend_hclust,
                   cluster_rows = cr$row_dend_hclust
)

dev.off()
data[,"Unique identifier"]
df$id <- rownames(df)
df_joined <- left_join(df,data,c("id"="Unique identifier"))
write.table(df_joined,file=paste('summary_table_seed_',i,'_k_',k,'.txt',sep=''),sep="\t", col.names=NA, row.names=T)


print(paste("seed: ",i," k: ",k,sep=''))
}
