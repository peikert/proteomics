clustProPanelUI <- function(id) {
  ns <- NS(id)
  tagList(
  column(3,offset=2,div(style = "height:40px; padding-top: 16px;", h4("number of clusters (k)", style=""))),
  column(3,div(style = "height:40px;", numericInput(ns("clustering_k_numericInput"), "", value =2, min = 5, max =100))),
  column(3,offset=2,div(style = "height:40px; padding-top: 16px;", h4("minimal k", style=""))),
  column(3,div(style = "height:40px;", numericInput(ns("clustering_max_k_numericInput"), "", value =30, min = 3, max =100))),
  column(3,offset=2,div(style = "height:40px; padding-top: 16px;", h4("maximal k", style=""))),
  column(3,div(style = "height:40px;", numericInput(ns("clustering_min_k_numericInput"), "", value =2, min = 2, max =99))),
  column(3,offset=2,div(style = "height:40px; padding-top: 16px;", h4("set seed", style=""))),
  column(3,div(style = "height:40px;", numericInput(ns("clustering_seed_numericInput"), "", value =2, min = 2, max =99))),
  column(3,offset=2,div(style = "height:40px; padding-top: 16px;", h4("select method", style=""))),
  column(3,div(style = "height:40px;",  selectInput(ns("clustering_method_selectInput"), "", choices = c('kmeans','cmenas'), selected = 'kmenas'))),
  column(12,div(style = "height:40px;",  actionButton(ns("clustering_run_button"), "run"))),



  div(style = 'width: 100% ; height:80%',
      div(style = 'float:left',tags$h4("Choose Columns")),
      div(style = 'float:right',
          actionButton(inputId = ns("clustering_aTOz"), label = "", icon = icon("glyphicon glyphicon-sort-by-alphabet", lib = "glyphicon")),
          actionButton(inputId = ns("clustering_zTOa"), label = "", icon = icon("glyphicon glyphicon-sort-by-alphabet-alt", lib = "glyphicon")),
          actionButton(inputId = ns("clustering_selectionToggle"), label = "", icon = icon("glyphicon glyphicon-adjust", lib = "glyphicon"))
      )
  ),
  #br(),
  div(style = 'overflow-x: scroll; overflow-y: scroll; width: 100% ; height:150px',
      checkboxGroupInput(inputId = ns("clustering_columns"), label = "", choices = colnames(iris), selected = colnames(iris)[1:2])
  ),
  clustPlotUI(ns('clustPlot')),
  clustProMainUI(ns('clustProMain')),
  div(style = 'width: 70%; margin: 0 auto;',gradientPickerD3Output(ns('gradientPickerD3')))
  )
}


clustProPanel <- function(input, output, session, ldf) {
  ns <- session$ns
  out_clustProMain <- callModule(clustProMain,"clustProMain",clust_parameters)
  out_clustPlot <- callModule(clustPlot,"clustPlot",best_k,reactive(input$clustering_k_numericInput))
  output$gradientPickerD3 <- renderGradientPickerD3({
    payload <- list(colors=c("purple 0%","blue 25%", "green 50%", "yellow 75%", "pink 100%"),test='test')
    gradientPickerD3(payload)
  })

observe({
  updateNumericInput(session,'clustering_k_numericInput',value=out_clustPlot())
})



  best_k <- eventReactive(input$clustering_run_button, {
      local_df <- get_best_k(matrix = as.matrix(iris[1:4]),
                 min_k = input$clustering_min_k_numericInput ,
                 max_k = input$clustering_max_k_numericInput,
                 method = input$clustering_method_selectInput,
                 seed = input$clustering_seed_numericInput
                 )
      local_df <- as.data.frame(local_df$db_list)
      colnames(local_df) <- c('k','db_index')
      k <- local_df$k[which(max(local_df$db_index)==local_df$db_index)]
      updateNumericInput(session,'clustering_k_numericInput',value=k)
      local_df
  })

  clust_parameters = list(
    data = iris,
    fixed_k = reactive(input$clustering_k_numericInput),
    method = reactive(input$clustering_method_selectInput),
    seed = reactive(input$clustering_seed_numericInput)
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
    #   as.data.frame(best_k()$db_list)
    # print(local_df)
    # print(nik())
    local_df$color <- 'black'
    local_df$color[local_df$k==nik()] <- 'red'
    plot_ly(local_df,
            x = ~k,
            y = ~db_index,
            type = 'scatter',
            mode = 'lines',
            colors = c('black','red')
            # ,tooltip = c('k','db_index')
            ) %>%
            add_markers(color = ~color) %>%
            config(displayModeBar = F)


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
  clustproOutput(ns('clustProMain'))
}


clustProMain <- function(input, output, session, clust_parameters) {
  ns <- session$ns
  observe({
    print(clust_parameters$method())
    print(clust_parameters$fixed_k())
  })
  output$clustProMain   <- renderClustpro({
  req(clust_parameters$method())
    req(clust_parameters$fixed_k())
    data  <-  clust_parameters$matrix
    fixed_k = clust_parameters$fixed_k()
    method = clust_parameters$method()


    #fixed_k = 13
    method = 'kmeans'
    data=iris[,1:4]

    intervals <- c(-9.1,-0.5,-0.1,0.1,0.5,9.1)
    color_list <- c("blue","lightblue","white","yellow", "red")


    heatmap_color <- setHeatmapColors(data=data, color_list = color_list,auto=TRUE)
    info_list <- list()
    info_list[['id']]  <- rownames(data)
   # info_list[['link']] <- paste('http://tritrypdb.org/tritrypdb/app/record/gene/',sapply(rownames(matrix),get_first_split_element,';'),sep='')
    info_list[['description']] <- rep('no description', nrow(matrix))

    color_legend <- heatmap_color



             clustpro(matrix=data,
                      method =method,
                      min_k = 2,
                      max_k = 100,
                      fixed_k = fixed_k,
                      perform_clustering = TRUE,
                      cluster_ids = NULL,
                      rows = TRUE,
                      cols = TRUE,
                      tooltip = info_list,
                      save_widget = TRUE,
                      color_legend = heatmap_color,
                      width = NULL,
                      height = NULL,
                      graphics_export = FALSE,
                      export_dir = NA,
                      export_type = 'svg',
                      seed=1
             )

             # clustpro(matrix=matrix,
             #          method = "kmeans",
             #          min_k = 2,
             #          max_k = 100,
             #          fixed_k = -1,
             #          perform_clustering = TRUE,
             #          cluster_ids = NULL,
             #          rows = TRUE,
             #          cols = TRUE,
             #          tooltip = info_list,
             #          save_widget = TRUE,
             #          color_legend = heatmap_color,
             #          width = NULL,
             #          height = NULL,
             #          graphics_export = FALSE,
             #          export_dir = NA,
             #          export_type = 'svg',
             #          seed=1
             # )




             })

}








heatmapColorSelectorsUI <- function(id) {
  ns <- NS(id)
    uiOutput(ns('heatmapColorSelectors'))
}

heatmapColorSelectors <- function(input, output, session,ldf) {
  ns <- session$ns
  others <- 'others'
  # col_var <- c("POI","others")
  col_var <- reactive(c(others,input$pieSelection_cols))

  cols <- reactive({
    cols_list <- lapply(1:length(col_var()), function(i) {
      fluidRow(
        column(6,div(style = "height:40px; padding-top: 16px;", h4(paste0("Choose color for ",col_var()[i],": "), style=""))),
        column(6,div(style = "height:40px;", colourInput(ns(paste("col", i, sep="_")), "", randomColor(count = 1),allowTransparent = FALSE)))
      )
    })
    cols_list
  })

  output$pieColorSelectors <- renderUI({
    req(col_var())
    cols()
  })

  colors <- reactive({
    lapply(1:length(col_var()), function(i) {
      input[[paste("col", i, sep="_")]]
    })
  })

  colors <- reactive({
    setNames(lapply(1:length(col_var()), function(i) {input[[paste("col", i, sep="_")]]}),col_var())
  })




  return(list(col_var=col_var,colors=colors))

}




