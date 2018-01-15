## ----eval = FALSE--------------------------------------------------------
#  #devtools::install_github("cpeikert/clustpro")

## ----initialization------------------------------------------------------
# suppressMessages is used to turn of loading package messages
suppressMessages(library('clustpro'))
unique_ids <<- paste0('vingette_id_',sprintf("%06d", 1:100000))

get_unique_id <- function(){
  id <- unique_ids[1]
  unique_ids <<- unique_ids[-1]
  return(id)
}


## ----basic usage---------------------------------------------------------
seed <- 1234
df_mtcars <- datasets::mtcars
df_data <- as.data.frame(scale(df_mtcars))

clustpro(matrix = df_data, elementId = get_unique_id())


## ----color setup---------------------------------------------------------

# setting of individual colors
  color_list <- c("blue", "lightblue", "white", "yellow", "red")
  color_legend01 <-
    clustpro::setHeatmapColors(data = df_data,
                     color_list = color_list,
                     auto = TRUE)

clustpro(matrix = df_data, color_legend = color_legend01, show_legend = TRUE ,seed = 1234, elementId = get_unique_id())  
 
# setting of individual intervals
intervals <- c(-1.9,-0.5,0,0.5,3.3)
  color_legend02 <-
    clustpro::setHeatmapColors(data = df_data,
                     color_list = color_list,
                     intervals = intervals,
                     auto = FALSE)

clustpro(matrix = df_data, color_legend = color_legend02, show_legend = TRUE ,seed = 1234, elementId = get_unique_id())  

# setting of individual shown ticks in the legend
color_legend03 <- color_legend02
color_legend03$label_position <- c(-1.9,-0.5,0,0.5,3.3)

clustpro(matrix = df_data, color_legend = color_legend03, show_legend = TRUE ,seed = 1234, elementId = get_unique_id())  

## ----tooltips------------------------------------------------------------
# adding row id to the tooltips as well as a web link 
  info_list <- list()
  info_list[['id']]  <- rownames(df_data)
  info_list[['link']] <-
    paste('https://www.google.de/search?q=/', rownames(df_data), sep = '')

clustpro(matrix = df_data,seed = 1234, tooltip = info_list, elementId = get_unique_id())  
 
# adding all matrix values as strings to the tooltip list     
  df_mtcars02 <- df_mtcars
  colnames(df_mtcars02) <- paste0('info_', colnames(df_mtcars02))
  data_columns <- colnames(df_data)
  info_columns <- colnames(df_mtcars02)
  df_data_extended <- cbind(df_data, df_mtcars02)
  
  if (!is.null(info_columns)) {
    temp_list <- lapply(info_columns, function(x) {
      df_data_extended[, x]
    })
    names(temp_list) <-
      sapply(info_columns, function(x)
        stringr:::str_match(x, 'info_(.*)')[2])

    info_list02 <- c(info_list, temp_list)
  }

clustpro(matrix = df_data,seed = 1234, tooltip = info_list02, elementId = get_unique_id()) 

## ----clustering----------------------------------------------------------
# determine the best number of clusters using the DB-index. Minimal and maximal cluster size defining the rank of options.
db_object <- clustpro::get_best_k(matrix = df_data, min_k = 2, max_k = 10, method = 'kmeans', seed = seed, cores = 4)

db_object$db_list
best_k <- db_object$best_k

# the best k is used to run the clustpro function with fixed k
clustpro(matrix = df_data, method = 'kmeans', fixed_k = best_k, seed = seed, elementId = get_unique_id())

# it is also possible to use the fussy cmeans algorithm
db_object <- get_best_k(matrix = df_data, min_k = 2, max_k = 10, method = 'cmeans', seed = seed, cores = 4)

db_object$db_list
best_k <- db_object$best_k

clustpro(matrix = df_data, method = 'cmeans', fixed_k = best_k, seed = seed, elementId = get_unique_id())

# large dataset can be simplified for visualisation. This means that own the mean value of a cluster is show in a single row. The tooltip included the number of grouped proteins. In the json file all protein of a group a stored.
clustpro(matrix = df_data, method = 'cmeans', fixed_k = best_k, simplify_clustering = TRUE, seed = seed, elementId = get_unique_id())

## ----using clustPro without visualization--------------------------------
# run clustPro without visualization just in the console
clustpro(matrix = df_data, method = 'kmeans', seed = seed, useShiny = FALSE, elementId = get_unique_id())

## ----using pre clustered data--------------------------------------------
#randomly group matrix in 3 clusters
set.seed(seed)
clusterVector <- sample(1:3, nrow(df_data), replace = TRUE)
df_data_extended <- df_data
df_data_extended$clusterVector <- clusterVector

#compute mean matrix
mean_df_data <- aggregate(df_data_extended[,colnames(df_data)], list(df_data_extended$clusterVector), mean)
mean_df_data$Group.1 <- NULL

#determine dendrograms matrix
d_rows <- dist(mean_df_data, method = "euclidean") # distance matrix
row_dend_hclust <- hclust(d_rows, method = "ward.D2")
row_dend_nw <- ctc::hc2Newick(row_dend_hclust)
row_dend_nw <- gsub(":\\d+\\.{0,1}\\d*", "", row_dend_nw)
row_dend <- as.dendrogram(row_dend_hclust)

d_cols <- dist(t(mean_df_data), method = "euclidean") # distance matrix
col_dend_hclust <- hclust(d_cols, method = "ward.D2")
col_dend_nw <- ctc::hc2Newick(col_dend_hclust)
col_dend_nw <- gsub(":\\d+\\.{0,1}\\d*", "", col_dend_nw)
col_dend <- as.dendrogram(col_dend_hclust)

#order matrix in accordance with dendrograms
df_data_extended <- clustpro::order_dataframe_by_list(df_data_extended,order.dendrogram(row_dend),'clusterVector')
clusterVector <- df_data_extended$clusterVector
df_data_extended$clusterVector <- NULL
df_data_extended <- df_data_extended[,order.dendrogram(col_dend)]

#run clustpro without clustering
clustpro(matrix = df_data_extended
         ,clusterVector = clusterVector
         ,perform_clustering = FALSE
         ,rows = row_dend_hclust
         ,cols = col_dend_hclust, elementId = get_unique_id())


## ------------------------------------------------------------------------


## ----session info, cache=FALSE-------------------------------------------
sessionInfo()

