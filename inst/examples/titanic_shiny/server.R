shinyServer(function(input, output, session) {
  
  #SearchTree----
  
  output$Hierarchy <- renderUI({
    Hierarchy=names(m)
    Hierarchy=head(Hierarchy,-1)
    selectizeInput("Hierarchy","Tree Hierarchy",
                   choices = Hierarchy,multiple=T,selected = Hierarchy,
                   options=list(plugins=list('drag_drop','remove_button')))
  })
  
  observeEvent(input$d3_update,{
    network$nodes <- unlist(input$d3_update$.nodesData)
  })
  
  network <- reactiveValues()
  
  TreeStruct=eventReactive(network$nodes,{
    df=m
    if(is.null(network$nodes)){
      df=m
    }else{
      x.filter=tree.filter(network$nodes,m)
      df=ddply(x.filter,.(id),function(a.x){m%>%filter_(.dots = list(a.x$x2))%>%distinct})
    }
    df
  })
  
  observeEvent(input$Hierarchy,{
    output$d3 <- renderD3tree({
      if(is.null(input$Hierarchy)){
        p=m
      }else{
        p=m%>%select(one_of(c(input$Hierarchy,"value")))%>%unique
      }
      
      d3tree(list(root = df2tree(m = p), layout = 'collapse'),height = 18)
    })
  })

  output$results <- renderPrint({
    str.out=''
    if(!is.null(network$nodes)) str.out=tree.filter(network$nodes,m)
    str.out.global<<-str.out
    return(str.out)
  })
  
  output$table <- renderTable(expr = {
    TreeStruct()%>%select(-value)
  })
  
})