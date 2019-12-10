#' Example 3
#'
#' starts a test shiny app
#' @examples
#' \dontrun{
#' runExample03()
#' }
#' @export
runExample03 <- function() {
  appDir <- system.file("shiny-examples", "03", package = "clustpro")
  moduleDir <- system.file("shiny_module", package = "clustpro")
  if (appDir == "") {
    stop("Could not find example directory. Try re-installing `clustpro`.", call. = FALSE)
  }
  shinyClustPro <- NULL

  source(file.path(appDir,"app.R"))
  source(file.path(moduleDir,"module_shiny_clustpro.R"))

  df_proteomics <- clustpro::mcp_reimann_et_al_2017
  data_columns <- c("Mean_log10_ratio_MTP_vs_MT","Mean_log10_ratio_MT_vs_MB","Mean_log10_ratio_MTP_vs_MB")
  df_proteomics <- df_proteomics[complete.cases(df_proteomics[,data_columns]),]
  sds <-  apply(df_proteomics[,data_columns],1,sd,na.rm=TRUE)
  bp <- graphics::boxplot(sds, plot=FALSE)
  df_proteomics <- df_proteomics[sds>bp$stats[5],]
  info_columns <- c("Uniprot","First_ID","Gene_names","Protein_names","Main_cluster","Cluster","Mol_weight_kDa","Number_of_proteins","Peptides","Unique_peptides","Sequence_coverage")
  rownames(df_proteomics) <- df_proteomics$First_ID
  shinyClustPro(df_proteomics, data_columns = data_columns, info_columns = info_columns)
}
