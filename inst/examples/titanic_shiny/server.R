m=Titanic%>%data.frame%>%mutate(value=NA)%>%distinct

shinyServer(function(input, output, session) {
  
  network <- reactiveValues()
  
  observeEvent(input$d3_update,{
    network$nodes <- unlist(input$d3_update$.nodesData)
    #str(network$nodes)
  })
  
  TreeStruct=reactive({
    df=m
    if(is.null(network$nodes)){
      df=m
    }else{
      x.filter=SearchTree:::tree.filter(network$nodes,m)
      if(!is.null(x.filter)) df=ddply(x.filter,.(id),function(a.x){m%>%filter_(.dots = list(a.x$x2))%>%distinct})
    }
    df
  })
  
  output$d3 <- renderGgtree({
    if(is.null(input$Hierarchy)){
      p=m
    }else{
      p=m%>%select(one_of(c(input$Hierarchy,"value")))%>%unique
    }
    
    ggtree(list(root = SearchTree:::df2tree(p), layout = 'collapse'))
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
    if(!is.null(network$nodes)) str.out=SearchTree:::tree.filter(network$nodes,m)
    str.out.global<<-str.out
    return(str.out)
  })
  
  output$Hierarchy <- renderUI({
    Hierarchy=names(m)
    Hierarchy=Hierarchy[-length(Hierarchy)]
    selectizeInput("Hierarchy","Tree Hierarchy",
                   choices = Hierarchy,multiple=T,selected = Hierarchy,
                   options=list(plugins=list('drag_drop','remove_button')))
  })
  
})