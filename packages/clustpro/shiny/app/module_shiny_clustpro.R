clustProPanelUI <- function(id) {
  ns <- NS(id)
  tagList(
  column(4,
        br(),
        uiOutput(ns('datafile')),
         fluidRow(
           column(6,
                  fluidRow(
                  column(5,align="left",offset=2,div(style = "height:40px; padding-top: 16px;", h4("current k", style=""))),
                  column(5,align="right",div(style = "height:40px;", numericInput(ns("clustering_k_numericInput"), "", value =2, min = 5, max =100)))
                  ),
                  fluidRow(
                  column(5,align="left",offset=2,div(style = "height:40px; padding-top: 16px;", h4("minimal k", style=""))),
                  column(5,align="right",div(style = "height:40px;", numericInput(ns("clustering_max_k_numericInput"), "", value =30, min = 3, max =100)))
                  ),
                  fluidRow(
                  column(5,align="left",offset=2,div(style = "height:40px; padding-top: 16px;", h4("maximal k", style=""))),
                  column(5,align="right",div(style = "height:40px;", numericInput(ns("clustering_min_k_numericInput"), "", value =2, min = 2, max =99)))
                  )
                  ),
          column(6,
                 column(5,align="left",offset=2,div(style = "height:40px; padding-top: 16px;", h4("set seed", style=""))),
                 column(5,align="right",div(style = "height:40px;", numericInput(ns("clustering_seed_numericInput"), "", value =2, min = 2, max =99))),
                 column(5,align="left",offset=2,div(style = "height:40px; padding-top: 16px;", h4("select method", style=""))),
                 column(5,align="right",div(style = "height:40px;",  selectInput(ns("clustering_method_selectInput"), "", choices = c('kmeans','cmeans'), selected = 'kmenas')))
          )
          ),
         br(),
         fluidRow(
           div(stle = 'width: 100% ; height:100%',
               div(style = 'float:left',tags$h4("Choose Columns")),
               div(style = 'float:right',
                   actionButton(inputId = ns("clustering_aTOz"), label = "", icon = icon("glyphicon glyphicon-sort-by-alphabet", lib = "glyphicon")),
                   actionButton(inputId = ns("clustering_zTOa"), label = "", icon = icon("glyphicon glyphicon-sort-by-alphabet-alt", lib = "glyphicon")),
                   actionButton(inputId = ns("clustering_selectionToggle"), label = "", icon = icon("glyphicon glyphicon-adjust", lib = "glyphicon"))
               )
           ),
           div(style = 'overflow-x: scroll; overflow-y: scroll; width: 100% ; height:150px',
               checkboxGroupInput(inputId = ns("clustering_columns"), label = "", choices = NULL, selected = NULL)
           )),
           # div(actionButton(
           #   ns("clustering_run_button"),
           #   label = "run",
           #   icon = icon("glyphicon glyphicon-play", lib = "glyphicon")
           #   ,style="color: #fff; background-color: #337ab7; border-color: #2e6da4, width: 20%; height:40px;"
           #   )
           #   ),
           clustPlotUI(ns('clustPlot'))
  ),
  column(8,
         # div(style = 'overflow-x: scroll; overflow-y: scroll; width: 100% ; height:85vh',
          div(style = 'width: 100% ; height:85vh',
             clustProMainUI(ns('clustProMain'))
            )
         ,
          div(style = 'width: 70%; height:15vh; margin: 0 auto;',gradientPickerD3Output(ns('gradientPickerD3')))
  )
  )
}


clustProPanel <- function(input, output, session, ldf=NULL) {
  ns <- session$ns

  if(is.null(ldf)){
  output$datafile <-  renderUI(fileInput(ns('datafile'), 'Choose CSV file', accept=c('text/tsv', 'text/tab-separated-values')))
  ldf <- reactive({
    infile <- input$datafile
    if (is.null(infile)) {
      return(NULL)
    }
    read.csv(infile$datapath,sep='\t',header=TRUE,check.names=FALSE, stringsAsFactors = FALSE)
  })
  }
  #ldf <- reactive(iris)
  c2p <-  reactive(as.vector(colnames(ldf())[unlist(lapply(ldf(),class))=='numeric']))
#  local_df <- ldf()
  observe({

    updateCheckboxGroupInput(
      session = session, inputId = "clustering_columns", choices = c2p(), selected = c2p()[1:2]
    )
    })

  out_clustProMain <- callModule(clustProMain,"clustProMain",clust_parameters)
  out_clustPlot <- callModule(clustPlot,"clustPlot",best_k,reactive(input$clustering_k_numericInput))
  output$gradientPickerD3 <- renderGradientPickerD3({
    payload <- list(colors=c("blue 0%","DeepSkyBlue 25%", "white 50%", "yellow 75%", "red 100%"),test='test')
    gradientPickerD3(payload)
  })


  heatmapColors <- reactive({
    req(input$gradientPickerD3_selected)
    req(ldf())
    req(input$clustering_columns)
    gcolors <- input$gradientPickerD3_selected
    if(is.null(gcolors)) return(NULL)

    df_gcolors <- as.data.frame(str_match_all(gcolors,'([^ ]+) (\\d{1,3})%')[[1]][,2:3],stringsAsFactors=FALSE)
    colnames(df_gcolors) <- c("color","interval")

     # print(input$clustering_columns)
    local_df <- ldf()[,input$clustering_columns]
    local_df <- as.data.frame(apply(local_df,c(1,2), as.numeric))

    # print(head(ldf()))
    minv <- min(local_df,na.rm=TRUE)#-0.00000001
    maxv <- max(local_df,na.rm=TRUE)#+0.00000001
    diff_value <- diff(c(minv,maxv))
    df_gcolors$interval <- as.numeric(df_gcolors$interval)
    # print(df_gcolors$interval)
 #   rownames(df_gcolors) <- NULL
  # df_gcolors_mod <- data.frame(color=character(0),interval=numeric(0))
    if(df_gcolors$interval[1]>0){
      temp_df <- df_gcolors[1,,drop=FALSE]

      temp_df[1,2] <- 0
      # print(temp_df)
      df_gcolors <- rbind(temp_df,df_gcolors)
    }

    if(df_gcolors$interval[nrow(df_gcolors)]<100){
      temp_df <- df_gcolors[nrow(df_gcolors),,drop=FALSE]
      temp_df$interval <- 100
      df_gcolors <- rbind(df_gcolors,temp_df)
    }

    df_gcolors$interval_mod <- sapply(df_gcolors$interval,function(x){minv+diff_value*x/100})
    # print(df_gcolors$interval_mod)

    setHeatmapColors(data=NULL,color_list=df_gcolors$color,intervals=df_gcolors$interval_mod)
  })
 # observe(print(heatmapColors()))


observe({
  updateNumericInput(session,'clustering_k_numericInput',value=out_clustPlot())
})

##


observeEvent(input$clustering_aTOz, {
  updateCheckboxGroupInput(
    session = session, inputId = "clustering_columns", choices = c2p(), selected = input$clustering_columns
  )
})

observeEvent(input$clustering_zTOa, {
  updateCheckboxGroupInput(
    session = session, inputId = "clustering_columns", choices = rev(c2p()), selected = input$clustering_columns
  )
})

observeEvent(input$clustering_selectionToggle, {
  if (is.null(input$clustering_columns)) {
    updateCheckboxGroupInput(
      session = session, inputId = "clustering_columns", selected = c2p()
    )
  } else {
    updateCheckboxGroupInput(
      session = session, inputId = "clustering_columns", selected = ""
    )
  }
})

##
#  best_k <- eventReactive(input$clustering_run_button, {
best_k <- reactive({
  req(input$clustering_columns)
  if(length(input$clustering_columns)<2)return(NULL)
  local_df <- ldf()
  local_df  <-  local_df[,input$clustering_columns]
  ccases <- complete.cases(local_df)
  if(nrow(local_df)>sum(ccases)){showNotification(paste0((nrow(local_df)-sum(ccases))," rows containing missing values were removed"))}
  local_df <-  local_df[ccases,]

      local_df <- get_best_k(matrix = as.matrix(local_df),
                 min_k = input$clustering_min_k_numericInput ,
                 max_k = input$clustering_max_k_numericInput,
                 method = input$clustering_method_selectInput,
                 seed = input$clustering_seed_numericInput
                 )
      local_df <- as.data.frame(local_df$db_list)
      colnames(local_df) <- c('k','db_index')
      filtered_local_df <- local_df[!is.na(local_df$db_index),]
      k <- filtered_local_df$k[which(max(filtered_local_df$db_index)==filtered_local_df$db_index)]
      updateNumericInput(session,'clustering_k_numericInput',value=k)
      local_df
  })

  clust_parameters = list(
    data = ldf,
    selected_cols =  reactive(input$clustering_columns),
    fixed_k = reactive(input$clustering_k_numericInput),
    method = reactive(input$clustering_method_selectInput),
    seed = reactive(input$clustering_seed_numericInput),
    heatmap_colors = heatmapColors
  )
}


clustPlotUI <- function(id) {
  ns <- NS(id)
  plotlyOutput(ns('clustPlot'))
}


clustPlot <- function(input, output, session, best_k, nik) {
  ns <- session$ns

  # output$clustPlot <- renderPlot({
  #   plot(data$wt, data$mpg, type='o')
  # })


  output$clustPlot <- renderPlotly({
    req(best_k())

    local_df <-  best_k()
   # print(local_df)
    if(is.null(best_k()))return(NULL)
    #   as.data.frame(best_k()$db_list)
    # print(local_df)
    # print(nik())
    col_vec <- rep('black',nrow(local_df))

    filtered_local_df <- local_df[!is.na(local_df$db_index),]
    best <- which(max(filtered_local_df$db_index)==filtered_local_df$db_index)
 #   best <- which(max(local_df$db_index,na.rm=T)==local_df$db_index)
    col_vec[local_df$k==nik()] <- 'red'



  #gg <- ggplot(local_df,aes(x=k, y=db_index, group=1))+ geom_line() + geom_point(aes(colour=color))+scale_colour_manual(values=c("blue", "red"))
    # ggplotly(gg
    #
    #          )


 #    ggplotly(gg) %>%
 #      # ggplotly(tooltip = c('k','db_index')) %>%
 # #     add_markers(color = ~color) %>%
 #      config(displayModeBar = F) %>%
 #      layout(showlegend = FALSE)


    plot_ly(local_df,
            x = ~k,
            y = ~db_index,
            type = 'scatter',
            mode = 'lines',
            colors = c('black','red'),
            hoverinfo = 'text',
            text = ~paste(
                          'k: ', k,
                          '</br>db-index: ', round(db_index,2))
            ) %>%
            # ggplotly(tooltip = c('k','db_index')) %>%
            add_markers(color = col_vec) %>%
            config(displayModeBar = F) %>%
            layout(
              showlegend = FALSE,
              xaxis = list(title = "Number of cluster (k)"),
              yaxis = list(title = "Davies-Bouldin index")
              )%>%
      add_annotations(x = local_df$k[best],
                      y = local_df$db_index[best],
                      text = 'best k',
                      xref = "x",
                      yref = "y",
                      showarrow = TRUE,
                      arrowhead = 4,
                      arrowsize = .5,
                      ax = 20,
                      ay = -40)


    })
  # output$event <- renderPrint({
  #
  # })

  selected_k <- reactive({
    d <- event_data("plotly_click")
    # print(d$pointNumber)
    # print(d$x)
    # print(d$y)
    # print(d$x)
    d$x
  })
  return(selected_k)
}






clustProMainUI <- function(id) {
  ns <- NS(id)
  clustproOutput(ns('clustProMain'),height='100%')
}


clustProMain <- function(input, output, session, clust_parameters) {
  ns <- session$ns
  # observe({
  #   print(clust_parameters$method())
  #   print(clust_parameters$fixed_k())
  #   print(clust_parameters$data())
  # })
  #output$clustProMain   <- renderClustpro({clustpro_example()})
  output$clustProMain   <- renderClustpro({
  req(clust_parameters$method())
  req(clust_parameters$fixed_k())
  req(clust_parameters$data())
  req(clust_parameters$selected_cols())
  req(clust_parameters$heatmap_colors())

  if(length(clust_parameters$selected_cols())<2)return(NULL)
    data  <-  clust_parameters$data()[,clust_parameters$selected_cols()]
    ccases <- complete.cases(data)
    if(nrow(data)>sum(ccases)){showNotification(paste0((nrow(data)-sum(ccases))," rows containing missing values were removed"))}
    data <-  data[ccases,]


    fixed_k = clust_parameters$fixed_k()
    method = clust_parameters$method()

    # color_list <- c("blue","lightblue","white","yellow", "red")
    #
    # heatmap_color <- setHeatmapColors(data=data, color_list = color_list,auto=TRUE)

    heatmap_color <-  clust_parameters$heatmap_colors()
    info_list <- list()
    info_list[['id']]  <- rownames(data)
   # info_list[['link']] <- paste('http://tritrypdb.org/tritrypdb/app/record/gene/',sapply(rownames(matrix),get_first_split_element,';'),sep='')
 #   print(nrow(data))
    info_list[['description']] <- rep('no description', nrow(data))

    color_legend <- heatmap_color
    print(dim(data))
             clustpro(matrix=data,
                      method =method,
                      min_k = 2,
                      max_k = 100,
                      fixed_k = fixed_k,
                      perform_clustering = TRUE,
                      clusterVector = NULL,
                      rows = TRUE,
                      cols = TRUE,
                      tooltip = info_list,
                      save_widget = TRUE,
                      color_legend = heatmap_color,
                      width = NULL,
                      height = NULL,
                      graphics_export = FALSE,
                      export_dir = NULL,
                      export_type = 'svg',
                      seed=1,
                      cores = 2
             )










             })
#
}








# heatmapColorSelectorsUI <- function(id) {
#   ns <- NS(id)
#     uiOutput(ns('heatmapColorSelectors'))
# }
#
# heatmapColorSelectors <- function(input, output, session,ldf) {
#   ns <- session$ns
#   others <- 'others'
#   # col_var <- c("POI","others")
#   col_var <- reactive(c(others,input$pieSelection_cols))
#
#   cols <- reactive({
#     cols_list <- lapply(1:length(col_var()), function(i) {
#       fluidRow(
#         column(6,div(style = "height:40px; padding-top: 16px;", h4(paste0("Choose color for ",col_var()[i],": "), style=""))),
#         column(6,div(style = "height:40px;", colourInput(ns(paste("col", i, sep="_")), "", randomColor(count = 1),allowTransparent = FALSE)))
#       )
#     })
#     cols_list
#   })
#
#   output$pieColorSelectors <- renderUI({
#     req(col_var())
#     cols()
#   })
#
#   colors <- reactive({
#     lapply(1:length(col_var()), function(i) {
#       input[[paste("col", i, sep="_")]]
#     })
#   })
#
#   colors <- reactive({
#     setNames(lapply(1:length(col_var()), function(i) {input[[paste("col", i, sep="_")]]}),col_var())
#   })
#
#
#
#
#   return(list(col_var=col_var,colors=colors))
#
# }




