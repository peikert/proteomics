#' Example 2
#'
#' starts a test shiny app
#' @export
runExample02 <- function() {
  appDir <- system.file("shiny-examples", "02", package = "clustpro")
  if (appDir == "") {
    stop("Could not find example directory. Try re-installing `clustpro`.", call. = FALSE)
  }

  shiny::runApp(appDir, display.mode = "normal")
}
