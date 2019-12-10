#' Example 4
#'
#' starts a test shiny app
#' @examples
#' \dontrun{
#' runExample04()
#' }
#' @export
runExample04 <- function() {
  appDir <- system.file("shiny-examples", "03", package = "clustpro")
  moduleDir <- system.file("shiny_module", package = "clustpro")
  if (appDir == "") {
    stop("Could not find example directory. Try re-installing `clustpro`.", call. = FALSE)
  }
  shinyClustPro <- NULL
  source(file.path(appDir,"app.R"))
  source(file.path(moduleDir,"module_shiny_clustpro.R"))
  data_columns <- c("Gal_div_Glc","Gly_div_Glc")
  df_proteomics <- df_proteomics[complete.cases(df_proteomics[,data_columns]),]
  info_columns <- c("Gene_names","Protein_Description","Sequence_coverage","Gene_names","High_confidence_mito_proteome","Mean_copy_number_Glucose","Mean_copy_number_Galactose","Mean_copy_number_Glycerol","Copy_number_Kulak_et_al_2014","Copy_number_Chong_et_al_2015","Copy_number_Ghaemmaghami_et_al_2003")
  rownames(df_proteomics) <- df_proteomics$Systematic_names

  df_proteomics <- df_proteomics[,c(data_columns,info_columns)]

  dim(df_proteomics)
  df_proteomics[,data_columns] <- sapply(df_proteomics[,data_columns],as.numeric)
  shinyClustPro(df_proteomics, data_columns = data_columns, info_columns = info_columns)

}
