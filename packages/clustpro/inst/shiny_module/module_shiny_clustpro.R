 clustProPanelUI <- function(id) {
  ns <- NS(id)
  tagList(div(
    style = 'overflow-y: scroll;overflow-x: scroll;',
    # div(style = 'overflow-y: scroll;overflow-x: hidden; height: 100vh, width: 100wh',
    column(
      4,
      br(),
      div(
        style="
        display: inline-flex;
        flex-direction: row;
        justify-content: center;
        align-items: left;
        width: 100%;
        position: relavtive;
        ",
        div(style = "width: 65%; height:100%; padding: 4px;", uiOutput(ns('datafile'))),
        div(style = "width: 35%; height:100%; padding: 4px;", uiOutput(ns('choice')))
        ),
      fluidRow(
        column(
          6,
          fluidRow(
            column(
              5,
              align = "left",
              offset = 2,
              div(style = "height:40px; padding-top: 16px;", h4("current k", style = ""))
            ),
            column(5, align = "right", div(
              style = "height:40px;", numericInput(
                ns("clustering_k_numericInput"),
                "",
                value = 2,
                min = 2,
                max = 100
              )
            ))
          ),
          fluidRow(
            column(
              5,
              align = "left",
              offset = 2,
              div(style = "height:40px; padding-top: 16px;", h4("minimal k", style = ""))
            ),
            column(5, align = "right", div(
              style = "height:40px;", numericInput(
                ns("clustering_min_k_numericInput"),
                "",
                value = 2,
                min = 2,
                max = 99
              )
            ))
          ),
          fluidRow(
            column(
              5,
              align = "left",
              offset = 2,
              div(style = "height:40px; padding-top: 16px;", h4("maximal k", style = ""))
            ),
            column(5, align = "right", div(
              style = "height:40px;", numericInput(
                ns("clustering_max_k_numericInput"),
                "",
                value = 30,
                min = 3,
                max = 100
              )
            ))
          )
        ),
        column(
          6,
          column(
            5,
            align = "left",
            offset = 2,
            div(style = "height:40px; padding-top: 16px;", h4("set seed", style = ""))
          ),
          column(5, align = "right", div(
            style = "height:40px;", numericInput(
              ns("clustering_seed_numericInput"),
              "",
              value = 2,
              min = 2,
              max = 99
            )
          )),
          column(
            5,
            align = "left",
            offset = 2,
            div(style = "height:40px; padding-top: 16px;", h4("select method", style =
                                                                ""))
          ),
          column(5, align = "right", div(
            style = "height:40px;",  selectInput(
              ns("clustering_method_selectInput"),
              "",
              choices = c('kmeans', 'cmeans'),
              selected = 'kmenas'
            )
          ))
        )
      ),
      br(),
      fluidRow(
        div(
          stle = 'width: 100% ; height:100%',
          div(style = 'float:left', tags$h4("Choose Columns for Clustering")),
          div(
            style = 'float:right',
            actionButton(
              inputId = ns("clustering_aTOz_c"),
              label = "",
              icon = icon("glyphicon glyphicon-sort-by-alphabet", lib = "glyphicon")
            ),
            actionButton(
              inputId = ns("clustering_zTOa_c"),
              label = "",
              icon = icon("glyphicon glyphicon-sort-by-alphabet-alt", lib = "glyphicon")
            ),
            actionButton(
              inputId = ns("clustering_selectionToggle_c"),
              label = "",
              icon = icon("glyphicon glyphicon-adjust", lib = "glyphicon")
            )
          )
        ),
        div(
          align = 'left',
          style = 'overflow-x: scroll; overflow-y: scroll; width: 100% ; height:145px',
          checkboxGroupInput(
            inputId = ns("clustering_columns"),
            label = "",
            choices = NULL,
            selected = NULL
          )
        )
      ),
      br(),
      fluidRow(
        div(
          stle = 'width: 100% ; height:100%',
          div(style = 'float:left', tags$h4("Choose Columns for Tooltip")),
          div(
            style = 'float:right',
            actionButton(
              inputId = ns("clustering_aTOz_t"),
              label = "",
              icon = icon("glyphicon glyphicon-sort-by-alphabet", lib = "glyphicon")
            ),
            actionButton(
              inputId = ns("clustering_zTOa_t"),
              label = "",
              icon = icon("glyphicon glyphicon-sort-by-alphabet-alt", lib = "glyphicon")
            ),
            actionButton(
              inputId = ns("clustering_selectionToggle_t"),
              label = "",
              icon = icon("glyphicon glyphicon-adjust", lib = "glyphicon")
            )
          )
        ),
        div(
          align = 'left',
          style = 'overflow-x: scroll; overflow-y: scroll; width: 100% ; height:145px',
          checkboxGroupInput(
            inputId = ns("clustering_tooltips"),
            label = "",
            choices = NULL,
            selected = NULL
          )
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
    column(
      8,
      # div(style = 'overflow-x: scroll; overflow-y: scroll; width: 100% ; height:85vh',
      div(style = 'width: 100% ; height:85vh',
          clustProMainUI(ns('clustProMain')))
      ,
      div(style = 'width: 70%; height:15vh; margin: 0 auto;', gradientPickerD3Output(ns(
        'gradientPickerD3'
      )))
    )
  ))
}


clustProPanel <-
  function(input,
           output,
           session,
           ldf = NULL,
           data_columns = NULL,
           info_columns = NULL,
           file_browser = FALSE) {
    ns <- session$ns
    # showReactLog(time = TRUE)


    # update_heatmap <- reactiveValues(
    #   gradient = FALSE
    #   ,
    #   data = FALSE
    #   ,
    #   k = FALSE
    #   ,
    #   method = FALSE
    #   ,
    #   seed = FALSE
    #   ,
    #   tooltips = FALSE
    #   ,
    #   renew = FALSE
    # )

    if (file_browser) {
      output$datafile <-
        renderUI(fileInput(
          ns('datafile'),
          'Choose CSV file',
          accept = c('text/tsv', 'text/tab-separated-values')
        ))
      output$choice <-
        renderUI(actionButton(ns("choice"), "incorporate external information"))
      ldf_group <- eventReactive(input$choice, {
        datapath <- input$datafile$datapath
        ldf <-
          reactive(isolate(
            read.csv(
              datapath,
              sep = '\t',
              header = TRUE,
              check.names = FALSE,
              stringsAsFactors = FALSE
            )
          ))
        data_columns <- reactive(colnames(ldf()))
        list(ldf = ldf, data_columns = data_columns)
      })

      ldf <- eventReactive(ldf_group(), {
        ldf_group()$ldf()
      })

      data_columns <- eventReactive(ldf_group(), {
        ldf_group()$data_columns()
      })
    }


    c2p <-  eventReactive(ldf(), {
      if (is.null(data_columns)) {
        data_columns <- reactive(colnames(ldf()))
      }
      as.vector(colnames(ldf()[, data_columns()])[unlist(lapply(ldf()[, data_columns()], class)) ==
                                                    'numeric'])
    })


    observe({
      updateCheckboxGroupInput(
        session = session,
        inputId = "clustering_columns",
        choices = c2p(),
        selected = c2p()[1:2]
      )
    })

    observe({
      updateCheckboxGroupInput(
        session = session,
        inputId = "clustering_tooltips",
        choices = info_columns(),
        selected = NULL
      )
    })


    #### ??? ####

    out_clustProMain <-
      callModule(clustProMain,
                 "clustProMain",
                 clust_parameters
                 )
    # ,update_heatmap

    observe({
      out_clustProMain$json()
      # print('in')
      # update_heatmap <- out_clustProMain$update_heatmap
      update_json <- out_clustProMain$json
    })

    out_clustPlot <-
      callModule(clustPlot,
                 "clustPlot",
                 best_k,
                 reactive(input$clustering_k_numericInput))

    output$gradientPickerD3 <- renderGradientPickerD3({
      req(input$clustering_columns)
      # removeUI(ns('gradientPickerD3'),session=session)
      vmin <- min(ldf()[, input$clustering_columns], na.rm = TRUE)
      vmax <- max(ldf()[, input$clustering_columns], na.rm = TRUE)
      # print(vmin)
      # print(vmax)
      delta <- vmax - vmin
      totalTicks <- 5
      ticks = seq(vmin, vmax, (delta / (totalTicks - 1)))
      colors = c("blue", "DeepSkyBlue", "white", "yellow", "red")
      payload <- list(colors = colors,
                      ticks = ticks)
      gradientPickerD3(payload, width = '50px')
    })

    heatmapColors <- reactive({
      req(input$gradientPickerD3_table)
      req(ldf())
      req(input$clustering_columns)

      gcolors <- input$gradientPickerD3_table
      if (is.null(gcolors))
        return(NULL)
      df_gcolors <-
        as.data.frame(matrix(unlist(gcolors), ncol = 3, byrow = TRUE), stringsAsFactors = FALSE)
      colnames(df_gcolors) <- c('interval', 'color', 'ticks')
      df_gcolors$interval <- as.numeric(df_gcolors$interval)
      df_gcolors$ticks <- as.numeric(df_gcolors$ticks)
      setHeatmapColors(
        data = NULL,
        color_list = df_gcolors$color,
        intervals = df_gcolors$ticks
      )
    })


    observe({
      updateNumericInput(session, 'clustering_k_numericInput', value = out_clustPlot())
    })


    observe({
      req(ldf())
      vmax <- ceiling(nrow(ldf()) / 2)
      if (vmax > 100)
        vmax <- 100
      updateNumericInput(session, 'clustering_max_k_numericInput ', value =
                           vmax)
    })

    #### clustering columns ####

    observeEvent(input$clustering_aTOz_c, {
      updateCheckboxGroupInput(
        session = session,
        inputId = "clustering_columns",
        choices = sort(c2p()),
        selected = input$clustering_columns
      )
    })

    observeEvent(input$clustering_zTOa_c, {
      updateCheckboxGroupInput(
        session = session,
        inputId = "clustering_columns",
        choices = rev(sort(c2p())),
        selected = input$clustering_columns
      )
    })

    observeEvent(input$clustering_selectionToggle_c, {
      if (is.null(input$clustering_columns)) {
        updateCheckboxGroupInput(session = session,
                                 inputId = "clustering_columns",
                                 selected = c2p())
      } else {
        updateCheckboxGroupInput(session = session,
                                 inputId = "clustering_columns",
                                 selected = "")
      }
    })

    #### tooltips columns ####

    observeEvent(input$clustering_aTOz_t, {
      updateCheckboxGroupInput(
        session = session,
        inputId = "clustering_tooltips",
        choices = sort(c2p()),
        selected = input$clustering_tooltips
      )
    })

    observeEvent(input$clustering_zTOa_t, {
      updateCheckboxGroupInput(
        session = session,
        inputId = "clustering_tooltips",
        choices = rev(sort(c2p())),
        selected = input$clustering_tooltips
      )
    })

    observeEvent(input$clustering_selectionToggle_t, {
      if (is.null(input$clustering_tooltips)) {
        updateCheckboxGroupInput(session = session,
                                 inputId = "clustering_tooltips",
                                 selected = c2p())
      } else {
        updateCheckboxGroupInput(session = session,
                                 inputId = "clustering_tooltips",
                                 selected = "")
      }
    })

    best_k <- reactive({
      req(input$clustering_columns)
      if (length(input$clustering_columns) < 2)
        return(NULL)
      local_df <- ldf()
      local_df  <-  local_df[, input$clustering_columns]
      ccases <- complete.cases(local_df)
      if (nrow(local_df) > sum(ccases)) {
        showNotification(paste0((nrow(local_df) - sum(ccases)),
                                " rows containing missing values were removed"
        ))
      }
      local_df <-  local_df[ccases, ]

      local_df <- get_best_k(
        matrix = as.matrix(local_df),
        min_k = input$clustering_min_k_numericInput ,
        max_k = input$clustering_max_k_numericInput,
        method = input$clustering_method_selectInput,
        seed = input$clustering_seed_numericInput
      )
      db_list <- as.data.frame(local_df$db_list)
      k <- local_df$best_k
      updateNumericInput(session, 'clustering_k_numericInput', value = k)
      db_list
    })


    clust_parameters = list(
      data = ldf,
      selected_cols =  reactive(input$clustering_columns),
      fixed_k = reactive(input$clustering_k_numericInput),
      method = reactive(input$clustering_method_selectInput),
      seed = reactive(input$clustering_seed_numericInput),
      info_columns = reactive(input$clustering_tooltips),
      heatmap_colors = heatmapColors
    )


    # observeEvent(input$gradientPickerD3_table, {
    #   print("gradientPicker")
    #   update_heatmap$gradient = TRUE
    # })
    # observeEvent(input$clustering_columns, {
    #   print("clustering_columns")
    #   update_heatmap$renew = TRUE
    # })
    # observeEvent(input$clustering_k_numericInput, {
    #   print("clustering_k_numericInput")
    #   update_heatmap$renew = TRUE
    # })
    # observeEvent(input$clustering_method_selectInput, {
    #   print("clustering_method_selectInput")
    #   update_heatmap$renew = TRUE
    # })
    # observeEvent(input$clustering_seed_numericInput, {
    #   print("clustering_seed_numericInput")
    #   update_heatmap$renew = TRUE
    # })
    # observeEvent(input$clustering_tooltips, {
    #   print("clustering_tooltips")
    #   update_heatmap$tooltips = TRUE
    # })


    #### clustpro return values ####
    # jr_dendnw_row <-
    #   eventReactive(update_json(), {
    #     update_json()[["dendnw_row"]][[1]]
    #   })
    # jr_dendnw_col <-
    #   eventReactive(update_json(), {
    #     update_json()[["dendnw_col"]][[1]]
    #   })
    # jr_matrix <-  eventReactive(update_json(), {
    #   jr_data <-
    #     data.frame(matrix(
    #       update_json()$matrix[["data"]],
    #       ncol =  update_json()$matrix$dim[[2]],
    #       byrow = TRUE
    #     ))
    #   rownames(jr_data) <- update_json()$matrix[["rows"]]
    #   colnames(jr_data) <-  update_json()$matrix[["cols"]]
    #   return(jr_data)
    # })


  }


clustPlotUI <- function(id) {
  ns <- NS(id)
  plotlyOutput(ns('clustPlot'))
}


clustPlot <- function(input, output, session, best_k, nik) {
  ns <- session$ns
  output$clustPlot <- renderPlotly({
    req(best_k())

    local_df <-  best_k()
    if (is.null(best_k()))
      return(NULL)

    col_vec <- rep('black', nrow(local_df))

    filtered_local_df <- local_df[!is.na(local_df$score), ]
    best <-
      which(max(filtered_local_df$score) == filtered_local_df$score)

    col_vec[local_df$k == nik()] <- 'red'

    p <- plot_ly(
      local_df,
      x = ~ k,
      y = ~ score,
      type = 'scatter',
      mode = 'lines',
      colors = c('black', 'red'),
      hoverinfo = 'text',
      text = ~ paste('k: ', k,
                     '<br>db-index: ', round(score, 2))
    ) %>%
      # ggplotly(tooltip = c('k','score')) %>%
      add_markers(color = col_vec) %>%
      config(displayModeBar = F) %>%
      layout(
        showlegend = FALSE,
        xaxis = list(title = "Number of cluster (k)"),
        yaxis = list(title = "Davies-Bouldin index")
      ) %>%
      add_annotations(
        x = local_df$k[best],
        y = local_df$score[best],
        text = 'best k',
        xref = "x",
        yref = "y",
        showarrow = TRUE,
        arrowhead = 4,
        arrowsize = .5,
        ax = 20,
        ay = -40
      )
    p$elementId <- NULL
    p
  })

  selected_k <- reactive({
    d <- event_data("plotly_click")
    d$x
  })
  return(selected_k)
}

clustProMainUI <- function(id) {
  ns <- NS(id)
  clustproOutput(ns('clustProMain'), height = '100%')
}

clustProMain <-
  function(input,
           output,
           session,
           clust_parameters
           # ,update_heatmap
           ) {
    ns <- session$ns

    output$clustProMain   <- renderClustpro({


      # print(":: 1 ::")
      # print(update_heatmap$renew)


      req(clust_parameters$method())
      req(clust_parameters$fixed_k())
      req(clust_parameters$data())
      req(clust_parameters$selected_cols())
      req(clust_parameters$seed())
      req(clust_parameters$heatmap_colors())
      # req(update_heatmap)

      #### :: 1 :: ####
      # observe({
      #   update_heatmap

      # })


      if (length(clust_parameters$selected_cols()) < 1)
        return(NULL)
      # print('C')
      data  <-
        clust_parameters$data()[, clust_parameters$selected_cols(), drop = FALSE]
      ccases <- complete.cases(data)
      if (nrow(data) > sum(ccases)) {
        showNotification(paste0((nrow(data) - sum(ccases)),
                                " rows containing missing values were removed"
        ))
      }
      data <-  data[ccases, , drop = FALSE]

      fixed_k = clust_parameters$fixed_k()
      method = clust_parameters$method()

      heatmap_color <-  clust_parameters$heatmap_colors()
      info_list <- list()
      info_list[['id']]  <- rownames(data)
      # print('>>>>')
      # print(clust_parameters$info_columns())
      # print('link' %in% clust_parameters$info_columns())
      # print('<<<<')
      # if('link' %in% clust_parameters$info_columns()){
      #   print('in')
      #   info_list[['link']] <- clust_parameters$data()[,'link']
      #   clust_parameters$info_columns['link'] <- NULL
      # }else{
      #   info_list[['link']] <- paste0('https://www.google.de/search?q=',rownames(data))
      #
      #
      #   }
      #### TODO!!!! ####
      info_list[['link']] <-
        paste0('http://www.uniprot.org/uniprot/', rownames(data))
      # info_list[['link']] <- paste('http://tritrypdb.org/tritrypdb/app/record/gene/',sapply(rownames(matrix),get_first_split_element,';'),sep='')
      #   print(nrow(data))
      # info_list[['description']] <- rep('no description', nrow(data))
      # print(info_list)
      if (!is.null(clust_parameters$info_columns)) {
        temp_list <-
          lapply(clust_parameters$info_columns(), function(x) {
            clust_parameters$data()[, x]
          })
        names(temp_list) <- clust_parameters$info_columns()

        info_list <- c(info_list, temp_list)

      }

      if (min(data) < min(heatmap_color$ticks) |
          max(data) > max(heatmap_color$ticks))
        return(NULL)
      tryCatch({
        clustpro(
          matrix = data,
          method = method,
          min_k = 2,
          max_k = ceiling(nrow(data) / 2),
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
          seed = clust_parameters$seed(),
          cores = 2,
          useShiny = TRUE
        )
      }, warning = function(w) {
        print(w)
        return(NULL)
      }, error = function(e) {
        print(e)
        return(NULL)
      })
    })

    # for(i in 1:length(update_heatmap)){
    #   print(i)
    #   update_heatmap[[i]] <- reactive(FALSE)
    #   # observe(print(update_heatmap[[i]]()))
    # }

    # update_heatmap <- reactiveValues(
    #   gradient = FALSE
    #   ,data = FALSE
    #   ,k = FALSE
    #   ,method = FALSE
    #   ,seed = FALSE
    #   ,tooltips = FALSE
    # )

    # observeEvent(update_heatmap$renew, {
    #   if (update_heatmap$renew)
    #     update_heatmap$renew = FALSE
    # })

    #### :: 2 :: ####
    # observe({
    #   print(":: 2 ::")
    #   # print(update_heatmap$gradient)
    #   # print(update_heatmap$data)
    #   # print(update_heatmap$k)
    #   # print(update_heatmap$method)
    #   # print(update_heatmap$seed)
    #   # print(update_heatmap$tooltips)
    #   print(update_heatmap$renew)
    # })

    return(list(
      json = reactive(input$clustProMain_json)
      # ,update_heatmap = update_heatmap
    ))
  }
