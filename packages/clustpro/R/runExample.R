#' Proteomic dataset
#'
#' A dataset containing ......
#' The variables are as follows:
#'
#' \itemize{
#'   \item uniProtID. id
#'   \item MTP_MT. mean ratio of MTP MT
#'   \item MT_MB. mean ratio of MT_MB
#'   \item MTP_MB. mean ratio of MTP_MB
#'   \item geneNames. gene names of proteins
#'   \item definition. definition of proteins
#' }
#'
#' @docType data
#' @keywords datasets
#' @name proteomics_data
#' @references Warscheid Lab, Freiburg University
#' @usage data(proteomics_data)
#' @format A data frame with  2590 rows and 6 variables
NULL

#' Example 1
#'
#' starts a test shiny app
#' @export
runExample <- function() {
  appDir <- system.file("shiny-examples", "01", package = "clustpro")
  if (appDir == "") {
    stop("Could not find example directory. Try re-installing `clustpro`.", call. = FALSE)
  }

  shiny::runApp(appDir, display.mode = "normal")
}
