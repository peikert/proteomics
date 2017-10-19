#' Example 5
#'
#' starts a test shiny app
#' @export
runExample05 <- function() {
  appDir <- system.file("shiny-examples", "03", package = "clustpro")
  moduleDir <- system.file("shiny_module", package = "clustpro")
  if (appDir == "") {
    stop("Could not find example directory. Try re-installing `clustpro`.", call. = FALSE)
  }
  source(file.path(appDir,"app.R"))
  source(file.path(moduleDir,"module_shiny_clustpro.R"))

  shinyClustPro()

}
