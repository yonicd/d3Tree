shinyServer(function(input, output, session) {
  
  #SearchTree----
  
  output$Hierarchy <- renderUI({
    Hierarchy=names(m)
    Hierarchy=head(Hierarchy,-1)
    selectizeInput("Hierarchy","Tree Hierarchy",
                   choices = Hierarchy,multiple=T,selected = Hierarchy,
                   options=list(plugins=list('drag_drop','remove_button')))
  })
  
  network <- reactiveValues()
  
  observeEvent(input$d3_update,{
    network$nodes <- unlist(input$d3_update$.nodesData)
    activeNode<-input$d3_update$.activeNode
    if(!is.null(activeNode)) network$click <- jsonlite::fromJSON(activeNode)
  })
  
  observeEvent(network$click,{
    output$clickView<-renderTable({
      as.data.frame(network$click)
    },caption='Last Clicked Node',caption.placement='top')
  })
 
  
  TreeStruct=eventReactive(network$nodes,{
    df=m
    if(is.null(network$nodes)){
      df=m
    }else{
      
      x.filter=tree.filter(network$nodes,m)
      df=ddply(x.filter,.(ID),function(a.x){m%>%filter_(.dots = list(a.x$FILTER))%>%distinct})
    }
    df
  })
  
  observeEvent(input$Hierarchy,{
    output$d3 <- renderD3tree({
      if(is.null(input$Hierarchy)){
        p=m
      }else{
        p=m%>%select(one_of(c(input$Hierarchy,"NEWCOL")))%>%unique
      }
      
      d3tree(data = list(root = df2tree(struct = p,rootname = 'Titanic'), layout = 'collapse'),activeReturn = c('name','value','depth','id'),height = 18)
    })
  })

  observeEvent(network$nodes,{
    output$results <- renderPrint({
      str.out=''
      if(!is.null(network$nodes)) str.out=tree.filter(network$nodes,m)
      return(str.out)
    })    
  })

  output$table <- renderTable(expr = {
    TreeStruct()%>%select(-NEWCOL)
  })
  
})