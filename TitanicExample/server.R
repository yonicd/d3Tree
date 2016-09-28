m=Titanic%>%data.frame%>%mutate(value=NA)%>%distinct

shinyServer(function(input, output, session) {

  observe({
    nodesList<<-input$.nodesData
  })
  
  TreeStruct=reactive({
    df=m
    if(is.null(input$.nodesData)){
      df=m
    }else{
      x.filter=tree.filter(input$.nodesData,m)
      if(!is.null(x.filter)) df=ddply(x.filter,.(id),function(a.x){m%>%filter_(.dots = list(a.x$x2))%>%distinct})
    }
    df
  })
  
  output$d3 <- reactive({
    if(is.null(input$Hierarchy)){
      p=m
    }else{
      p=m%>%select(one_of(c(input$Hierarchy,"value")))%>%unique  
    }
    
    list(root = df2tree(p), layout = 'collapse')
    })
  
  output$table <- renderTable(expr = {
        TreeStruct()%>%select(-value)
  }
  #,
    # extensions = c('Buttons','Scroller','ColReorder','FixedColumns'), 
    # filter='top',
    # options = list(   deferRender = TRUE,
    #                   scrollX = TRUE,
    #                   pageLength = 50,
    #                   scrollY = 500,
    #                   scroller = TRUE,
    #                   dom = 'Bfrtip',
    #                   colReorder=TRUE,
    #                   fixedColumns = TRUE,
    #                   buttons = c('copy', 'csv', 'excel', 'pdf', 'print','colvis'))
  )

  output$results <- renderPrint({
    str.out=''
    if(!is.null(input$.nodesData)) str.out=tree.filter(input$.nodesData,m)
    str.out.global<<-str.out
    return(str.out)
  })
  
  output$Hierarchy <- renderUI({
    Hierarchy=names(m)
    Hierarchy=Hierarchy[-length(Hierarchy)]
    selectInput("Hierarchy","Tree Hierarchy",
                choices = Hierarchy,multiple=T,selected = Hierarchy)
  })
  
})