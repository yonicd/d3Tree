shinyServer(function(input, output, session) {

  observe({
    nodesList<<-input$.nodesData
  })
  
  output$d3 <- reactive({
    if(is.null(input$Hierarchy)){
      p=m
    }else{
      p=m%>%select(one_of(c(input$Hierarchy,"value")))%>%unique  
    }
    
    list(root = df2tree(p), layout = 'collapse')})
  
  output$table <- DT::renderDataTable(expr = {
    df=m
    if(is.null(input$.nodesData)){
      df=m
    }else{
      x.filter=tree.filter(input$.nodesData,m)
      if(!is.null(x.filter)) df=ddply(x.filter,.(id),function(a.x){m%>%filter_(.dots = list(a.x$x2))%>%distinct})
    }
    df=df%>%select(-c(id,value))%>%mutate_each(funs(factor))
    return(df)
  },
    extensions = c('Buttons','Scroller','ColReorder','FixedColumns'), 
    filter='top',
    options = list(   deferRender = TRUE,
                      dom='t',
                      scrollX = TRUE,
                      pageLength = 50,
                      scrollY = 500,
                      scroller = TRUE,
                      dom = 'Bfrtip',
                      colReorder=TRUE,
                      fixedColumns = TRUE,
                      buttons = c('copy', 'csv', 'excel', 'pdf', 'print','colvis'))
  )

  output$results <- renderPrint({
    str.out=''
    if(!is.null(input$.nodesData)) str.out=tree.filter(input$.nodesData,m)
    return(str.out)
  })
  

  output$Hierarchy <- renderUI({
    nm=names(m)
    ch=c("Cylinders","VS","AM","Carborators")
    Hierarchy=split(nm[-length(nm)],factor(ch,levels=ch))
    selectInput("Hierarchy","Tree Hierarchy",choices = Hierarchy,multiple=T,selected = Hierarchy)
  })
  

})