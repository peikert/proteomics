#' Example 3
#'
#' starts a test shiny app
#' @export
runExample03 <- function() {
  appDir <- system.file("shiny-examples", "03", package = "clustpro")
  if (appDir == "") {
    stop("Could not find example directory. Try re-installing `clustpro`.", call. = FALSE)
  }

  shiny::runApp(appDir, display.mode = "normal")
}
