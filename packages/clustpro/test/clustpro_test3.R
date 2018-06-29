
if(F){
  library("devtools")
  setwd("D:/git/proteomics/packages/clustpro")
# devtools::check()
  devtools::document()
  # devtools::build_vignettes()
  # remove.packages("clustpro")
  devtools::install()
}
library("clustpro")
#runExample01()
#runExample02()
#runExample03()
#runExample04()
#runExample05()

# path = "D:/git/proteomics/packages/clustpro/payload.json"
path = "/home/numair/Videos/proteomics/packages/clustpro/payload.json"
#json_data <- jsonlite::fromJSON(paste(readLines( "D:/git/proteomics/packages/clustpro/payload.json"), collapse=""))
json_data <- jsonlite::fromJSON(paste(readLines( "/home/numair/Videos/proteomics/packages/clustpro/payload.json"), collapse=""))
clustpro(json = json_data)
