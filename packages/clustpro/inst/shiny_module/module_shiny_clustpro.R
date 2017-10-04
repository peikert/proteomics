clustProPanelUI <- function(id) {
  ns <- NS(id)
  tagList(
    div(style = 'overflow-y: scroll;overflow-x: scroll;',
        # div(style = 'overflow-y: scroll;overflow-x: hidden; height: 100vh, width: 100wh',
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
                    column(5,align="right",div(style = "height:40px;", numericInput(ns("clustering_min_k_numericInput"), "", value =2, min = 2, max =99)))
                  ),
                  fluidRow(
                  column(5,align="left",offset=2,div(style = "height:40px; padding-top: 16px;", h4("maximal k", style=""))),
                  column(5,align="right",div(style = "height:40px;", numericInput(ns("clustering_max_k_numericInput"), "", value =30, min = 3, max =100)))
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
               div(style = 'float:left',tags$h4("Choose Columns for Clustering")),
               div(style = 'float:right',
                   actionButton(inputId = ns("clustering_aTOz_c"), label = "", icon = icon("glyphicon glyphicon-sort-by-alphabet", lib = "glyphicon")),
                   actionButton(inputId = ns("clustering_zTOa_c"), label = "", icon = icon("glyphicon glyphicon-sort-by-alphabet-alt", lib = "glyphicon")),
                   actionButton(inputId = ns("clustering_selectionToggle_c"), label = "", icon = icon("glyphicon glyphicon-adjust", lib = "glyphicon"))
               )
           ),
           div(align = 'left', style = 'overflow-x: scroll; overflow-y: scroll; width: 100% ; height:145px',
               checkboxGroupInput(inputId = ns("clustering_columns"), label = "", choices = NULL, selected = NULL)
           )
         ),
        br(),
           fluidRow(
             div(stle = 'width: 100% ; height:100%',
                 div(style = 'float:left',tags$h4("Choose Columns for Tooltip")),
                 div(style = 'float:right',
                     actionButton(inputId = ns("clustering_aTOz_t"), label = "", icon = icon("glyphicon glyphicon-sort-by-alphabet", lib = "glyphicon")),
                     actionButton(inputId = ns("clustering_zTOa_t"), label = "", icon = icon("glyphicon glyphicon-sort-by-alphabet-alt", lib = "glyphicon")),
                     actionButton(inputId = ns("clustering_selectionToggle_t"), label = "", icon = icon("glyphicon glyphicon-adjust", lib = "glyphicon"))
                 )
             ),
        div(align = 'left', style = 'overflow-x: scroll; overflow-y: scroll; width: 100% ; height:145px',
                checkboxGroupInput(inputId = ns("clustering_tooltips"), label = "", choices = NULL, selected = NULL)
          )
          ),
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
  )
}


clustProPanel <- function(input, output, session, ldf=NULL, data_columns=NULL, info_columns=NULL) {
  ns <- session$ns

  # observe({
  # print(data_columns())
  # print(info_columns())
  # })
    observe({
  if(is.null(ldf()) || is.null(ldf)){
    # print("in")
  output$datafile <-  renderUI(fileInput(ns('datafile'), 'Choose CSV file', accept=c('text/tsv', 'text/tab-separated-values')))
  }
  })
    observe({
      req(input$datafile)
      datapath <- input$datafile$datapath
      if (is.null(datapath) | !file.exists(datapath)) {return(NULL)}else{
       ldf <-reactive(read.csv(datapath,sep='\t',header=TRUE,check.names=FALSE, stringsAsFactors = FALSE))
      }
    })

    # observe({print(ldf())})
  # ldf <- reactive({
  #   req(input$datafile)
  #   print(output$datafile)
  #
  #       if (is.null(input$datafile)) {
  #         return(NULL)
  #       }else return(read.csv(infile$datapath,sep='\t',header=TRUE,check.names=FALSE, stringsAsFactors = FALSE))
  #     })




  if(is.null(data_columns)){
    data_columns <- reactive(colnames(ldf()))
  }

  #ldf <- reactive(iris)
  # c2p <-  reactive(as.vector(colnames(ldf())[unlist(lapply(ldf(),class))=='numeric']))
  c2p <-  eventReactive(ldf,{
    as.vector(colnames(ldf()[,data_columns()])[unlist(lapply(ldf()[,data_columns()],class))=='numeric'])
    })

#  local_df <- ldf()
  observe({
    updateCheckboxGroupInput(
      session = session, inputId = "clustering_columns", choices = c2p(), selected = c2p()[1:2]
    )
    })

  observe({
    updateCheckboxGroupInput(
      session = session, inputId = "clustering_tooltips", choices = c2p(), selected = NULL
    )
  })

  out_clustProMain <- callModule(clustProMain,"clustProMain",clust_parameters)
  out_clustPlot <- callModule(clustPlot,"clustPlot",best_k,reactive(input$clustering_k_numericInput))

  output$gradientPickerD3 <- renderGradientPickerD3({
    req(input$clustering_columns)
    # removeUI(ns('gradientPickerD3'),session=session)
    vmin <- min(ldf()[,input$clustering_columns],na.rm=TRUE)
    vmax <- max(ldf()[,input$clustering_columns],na.rm=TRUE)
    # print(vmin)
    # print(vmax)
    delta <- vmax - vmin
    totalTicks <- 5
    ticks= seq(vmin,vmax,(delta/(totalTicks-1)))
    colors=c("blue","DeepSkyBlue", "white", "yellow", "red")
    payload <- list(
      colors=colors,
      ticks= ticks
                    )
    # print(payload)
    # payload <- list(colors=c("blue 0%","DeepSkyBlue 25%", "white 50%", "yellow 75%", "red 100%"))
    gradientPickerD3(payload, width = '50px')
  })

  heatmapColors <- reactive({
    req(input$gradientPickerD3_table)
    req(ldf())
    req(input$clustering_columns)

    gcolors <- input$gradientPickerD3_table
    if(is.null(gcolors)) return(NULL)
    #print(gcolors)
    df_gcolors <- as.data.frame(matrix(unlist(gcolors), ncol = 3, byrow = TRUE),stringsAsFactors = FALSE)
    colnames(df_gcolors) <- c('interval','color','ticks')
    # print(df_gcolors)
  #  df_gcolors$ticks <- NULL
    df_gcolors$interval <- as.numeric(df_gcolors$interval)
    df_gcolors$ticks <- as.numeric(df_gcolors$ticks)
    # print(df_gcolors)
    # df_gcolors$ticks <- NULL
    # df_gcolors <- as.data.frame(str_match_all(gcolors,'([^ ]+) (\\d{1,3})%')[[1]][,2:3],stringsAsFactors=FALSE)
    # colnames(df_gcolors) <- c("color","interval")

     # print(input$clustering_columns)
 #    local_df <- ldf()[,input$clustering_columns]
 #    local_df <- as.data.frame(apply(local_df,c(1,2), as.numeric))
 #
 #    # print(head(ldf()))
 #    minv <- min(local_df,na.rm=TRUE)#-0.00000001
 #    maxv <- max(local_df,na.rm=TRUE)#+0.00000001
 #    diff_value <- diff(c(minv,maxv))
 #
 #    # print(df_gcolors$interval)
 # #   rownames(df_gcolors) <- NULL
 #  # df_gcolors_mod <- data.frame(color=character(0),interval=numeric(0))
 #    if(df_gcolors$interval[1]>0){
 #      temp_df <- df_gcolors[1,,drop=FALSE]
 #
 #      temp_df$interval[1] <- 0
 #      temp_df$ticks[1] <- minv -0.00000001
 #      # print(temp_df)
 #      df_gcolors <- rbind(temp_df,df_gcolors)
 #    }
 #
 #    if(df_gcolors$interval[nrow(df_gcolors)]<1){
 #      temp_df <- df_gcolors[nrow(df_gcolors),,drop=FALSE]
 #      temp_df$interval <- 1
 #      temp_df$interval[1] <- 1
 #      temp_df$ticks[1] <- maxv + 0.00000001
 #      df_gcolors <- rbind(df_gcolors,temp_df)
 #    }
 #
 #    df_gcolors$interval_mod <- sapply(df_gcolors$interval,function(x){minv+diff_value*x/100})
 #    print(df_gcolors)
    # rgb(0,104,255)
    # print(df_gcolors)
    setHeatmapColors(data=NULL,color_list=df_gcolors$color,intervals=df_gcolors$ticks)
  })

  # observe(print(heatmapColors()))


observe({
  updateNumericInput(session,'clustering_k_numericInput',value=out_clustPlot())
})


observe({
  req(ldf())
  # updateNumericInput(session,'clustering_min_k_numericInput ',value=2)
  vmax <- ceiling(nrow(ldf())/2)
  if(vmax>100)vmax <- 100
  updateNumericInput(session,'clustering_max_k_numericInput ',value=vmax)
})

##


observeEvent(input$clustering_aTOz_c, {
  updateCheckboxGroupInput(
    session = session, inputId = "clustering_columns", choices = sort(c2p()), selected = input$clustering_columns
  )
})

observeEvent(input$clustering_zTOa_c, {
  updateCheckboxGroupInput(
    session = session, inputId = "clustering_columns", choices = rev(sort(c2p())), selected = input$clustering_columns
  )
})

observeEvent(input$clustering_selectionToggle_c, {
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

####
observeEvent(input$clustering_aTOz_t, {
  updateCheckboxGroupInput(
    session = session, inputId = "clustering_tooltips", choices = sort(c2p()), selected = input$clustering_tooltips
  )
})

observeEvent(input$clustering_zTOa_t, {
  updateCheckboxGroupInput(
    session = session, inputId = "clustering_tooltips", choices = rev(sort(c2p())), selected = input$clustering_tooltips
  )
})

observeEvent(input$clustering_selectionToggle_t, {
  if (is.null(input$clustering_tooltips)) {
    updateCheckboxGroupInput(
      session = session, inputId = "clustering_tooltips", selected = c2p()
    )
  } else {
    updateCheckboxGroupInput(
      session = session, inputId = "clustering_tooltips", selected = ""
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
      db_list <- as.data.frame(local_df$db_list)
      # colnames(db_list) <- c('k','score','withinerror')
     # filtered_local_df <- local_df[!is.na(local_df$score),]
     # k <- filtered_local_df$k[which(max(filtered_local_df$score)==filtered_local_df$score)]
      k <- local_df$best_k
      updateNumericInput(session,'clustering_k_numericInput',value=k)
      # print(k)
      # print(db_list)
      db_list
  })


  clust_parameters = list(
    data = ldf,
    selected_cols =  reactive(input$clustering_columns),
    fixed_k = reactive(input$clustering_k_numericInput),
    method = reactive(input$clustering_method_selectInput),
    seed = reactive(input$clustering_seed_numericInput),
    # data_columns = data_columns,
    info_columns = reactive(input$clustering_tooltips),
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
  print(class(local_df))
    if(is.null(best_k()))return(NULL)

    #   as.data.frame(best_k()$db_list)
    # print(local_df)
    # print(nik())
    col_vec <- rep('black',nrow(local_df))

    filtered_local_df <- local_df[!is.na(local_df$score),]
    best <- which(max(filtered_local_df$score)==filtered_local_df$score)
    print(class(filtered_local_df$score))
    print(round(filtered_local_df$score,2))
 #   best <- which(max(local_df$score,na.rm=T)==local_df$score)
    col_vec[local_df$k==nik()] <- 'red'



  #gg <- ggplot(local_df,aes(x=k, y=score, group=1))+ geom_line() + geom_point(aes(colour=color))+scale_colour_manual(values=c("blue", "red"))
    # ggplotly(gg
    #
    #          )


 #    ggplotly(gg) %>%
 #      # ggplotly(tooltip = c('k','score')) %>%
 # #     add_markers(color = ~color) %>%
 #      config(displayModeBar = F) %>%
 #      layout(showlegend = FALSE)


   p <- plot_ly(local_df,
            x = ~k,
            y = ~score,
            type = 'scatter',
            mode = 'lines',
            colors = c('black','red'),
            hoverinfo = 'text',
            text = ~paste(
                          'k: ', k,
                          '<br>db-index: ', round(score,2)
                          )
            ) %>%
            # ggplotly(tooltip = c('k','score')) %>%
            add_markers(color = col_vec) %>%
            config(displayModeBar = F) %>%
            layout(
              showlegend = FALSE,
              xaxis = list(title = "Number of cluster (k)"),
              yaxis = list(title = "Davies-Bouldin index")
              )%>%
      add_annotations(x = local_df$k[best],
                      y = local_df$score[best],
                      text = 'best k',
                      xref = "x",
                      yref = "y",
                      showarrow = TRUE,
                      arrowhead = 4,
                      arrowsize = .5,
                      ax = 20,
                      ay = -40)
   p$elementId <- NULL
   p
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
  req(clust_parameters$seed())
  req(clust_parameters$heatmap_colors())

  if(length(clust_parameters$selected_cols())<1)return(NULL)
  # print('C')
    data  <-  clust_parameters$data()[,clust_parameters$selected_cols(),drop=FALSE]
    ccases <- complete.cases(data)
    if(nrow(data)>sum(ccases)){showNotification(paste0((nrow(data)-sum(ccases))," rows containing missing values were removed"))}
    data <-  data[ccases,,drop=FALSE]


    fixed_k = clust_parameters$fixed_k()
    method = clust_parameters$method()

    # color_list <- c("blue","lightblue","white","yellow", "red")
    #
    # heatmap_color <- setHeatmapColors(data=data, color_list = color_list,auto=TRUE)

    heatmap_color <-  clust_parameters$heatmap_colors()
    info_list <- list()
    info_list[['id']]  <- rownames(data)

    info_list[['link']] <- paste0('https://www.google.de/search?q=',rownames(data))
   # info_list[['link']] <- paste('http://tritrypdb.org/tritrypdb/app/record/gene/',sapply(rownames(matrix),get_first_split_element,';'),sep='')
 #   print(nrow(data))
    info_list[['description']] <- rep('no description', nrow(data))
      # print(info_list)
    if(!is.null(clust_parameters$info_columns)){
      temp_list <- lapply(clust_parameters$info_columns(),function(x){clust_parameters$data()[,x]})
      names(temp_list) <- clust_parameters$info_columns()

      info_list <- c(info_list, temp_list)

    }
      # print(info_list)
    color_legend <- heatmap_color
    # print(color_legend)
    # print( head(data))
    print(method)
             clustpro(matrix=data,
                      method =method,
                      min_k = 2,
                      max_k = ceiling(nrow(data)/2),
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
                      export_graphics = FALSE,
                      export_dir = NULL,
                      export_type = 'svg',
                      seed=clust_parameters$seed(),
                      cores = 2,
                      useShiny = TRUE
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




