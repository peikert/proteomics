#' Example 3
#'
#' starts a test shiny app
#' @export
runExample03 <- function() {
  appDir <- system.file("shiny-examples", "03", package = "clustpro")
  moduleDir <- system.file("shiny_module", package = "clustpro")
  if (appDir == "") {
    stop("Could not find example directory. Try re-installing `clustpro`.", call. = FALSE)
  }
  source(file.path(appDir,"app.R"))
  source(file.path(moduleDir,"module_shiny_clustpro.R"))

  df_proteomics <- mcp_reimann_et_al_2017
  data_columns <- c("Mean_log10_ratio_MTP_vs_MT","Mean_log10_ratio_MT_vs_MB","Mean_log10_ratio_MTP_vs_MB")
  df_proteomics <- df_proteomics[complete.cases(df_proteomics[,data_columns]),]
  sds <-  apply(df_proteomics[,data_columns],1,sd,na.rm=TRUE)
  bp <- boxplot(sds)
  df_proteomics <- df_proteomics[sds>bp$stats[5],]
  info_columns <- c("Uniprot","First_ID","Gene_names","Protein_names","Main_cluster","Cluster","Mol_weight_kDa","Number_of_proteins","Peptides","Unique_peptides","Sequence_coverage")
  rownames(df_proteomics) <- df_proteomics$First_ID
  # nrow(df_proteomics)

  # info_columns <- c(info_columns;'link')
  # df_proteomics$link <- paste0("http://www.uniprot.org/uniprot/",df_proteomics$First_ID)
  #
  #
  # # shinyClustPro(df_data)
  # # shinyClustPro(df_data, data_columns = data_columns)
  # #shinyClustPro(df_data, info_columns = info_columns)
  # sapply(df_proteomics[,data_columns],class)
  shinyClustPro(df_proteomics, data_columns = data_columns, info_columns = info_columns)
  #shinyClustPro()
}
