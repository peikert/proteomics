
library(networkD3)
library(reshape2)
library(htmltools)


dm <- test1$cluster_distances

nodes <- data.frame(name=paste0('C',colnames(dm)))
nodes$id <- 0:(nrow(nodes)-1)
nodes$group <- 1:nrow(nodes)
nodes$size <- 80

nameToid <- nodes$id
names(nameToid) <- nodes$name

colnames(dm) <-  paste0('C',colnames(dm))
rownames(dm) <-  paste0('C',rownames(dm))
links <- melt(as.matrix(dm))
colnames(links) <- c('source','target','value')
class(links$source)
links$value <- links$value

links$source <- sapply(links$source, function(x)nameToid[x])

links$target <- sapply(links$target, function(x)nameToid[x])

browsable(tagList(
  tags$head(
    tags$style(
      '
      body{background-color: #ffffff !important}
      .nodetext{

      fill: #000000;
      }
      .legend text{fill: #FF0000}
      ')
    ),
  forceNetwork(
    Links = links
    ,
    Nodes = nodes
    ,
    Source = "source"
    ,
    Target = "target"
    ,
    Value = "value"
    ,
    linkDistance = JS('function(d) {', 'return d.value*200;', '}')
    ,
    NodeID = "name"
    ,
    Group = "group"
    ,
    opacity = 0.85
    ,
    linkColour = "#bfbfbf"
    ,
    Nodesize = 'size'
    ,
    linkWidth  = networkD3::JS("function(d) { return 5; }")
    ,
    opacityNoHover = 1
    ,
    fontSize = 22
    ,
    zoom = F
    ,
    bounded = T
    ,
    height = 500
    ,
    width = 500
    ,
    colourScale = JS('force.alpha(1); force.restart(); d3.scaleOrdinal(d3.schemeCategory20);')
  )
    ))


# networkD3::saveNetwork(D3_network_LM, "D3_LM.html", selfcontained = TRUE)
