
if(F){
  library("devtools")
  setwd("D:/git/proteomics/packages/clustpro")
# devtools::check()
  devtools::document()
  # devtools::build_vignettes()
  devtools::install()
}
library("clustpro")
#runExample03()

path = "D:/git/proteomics/packages/clustpro/payload.json"
json_data <- jsonlite::fromJSON(paste(readLines( "D:/git/proteomics/packages/clustpro/payload.json"), collapse=""))
clustpro(json = json_data)

