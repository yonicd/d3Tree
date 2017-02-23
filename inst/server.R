shinyServer(function(input, output, session) {

  observe({
    nodesList<<-input$.nodesData
  })

  TreeStruct=reactive({
    m=structure.list[[input$m]]
    df=m
    if(is.null(input$.nodesData)){
      df=m
    }else{
      x.filter=tree.filter(input$.nodesData,m)
      if(!is.null(x.filter)) df=ddply(x.filter,.(id),function(a.x){m%>%filter_(.dots = list(a.x$x2))%>%distinct})
    }
    df<-df%>%select(-c(id,value))%>%mutate_each(funs(factor))
    df.global<<-df
    df
  })
  
  StanSelect=reactive({
    if(input$goButton==0){
      sim.output=stan.sim.output
    }else{
      sim.output=RunStan()[['out']]
    }
    
    out=read.stan(sim.output,TreeStruct())
    
    return(out)
  })
  
  RunStan<-eventReactive(input$goButton,{
    ex=TreeStruct()%>%select(r.files)%>%mutate_each(funs(as.character))%>%unique
    ex$chapter=unlist(lapply(lapply(strsplit(ex$r.files,'[\\_]'),'[',1),function(x) paste('Ch',strsplit(x,'[\\.]')[[1]][1],sep='.')))
    ex$example=unlist(lapply(lapply(strsplit(ex$r.files,'[\\_]'),'[',1),function(x) strsplit(x,'[\\.]')[[1]][2]))
    
    if(input$goButton>0){
    out=dlply(ex,.(r.files),.fun=function(x) {
      RunStanGit(url.loc='https://raw.githubusercontent.com/stan-dev/example-models/master/ARM/',
                 dat.loc=paste0(x$chapter,'/'),
                 r.file=x$r.files)
      },.progress = 'text')
    structure.list$Stan<<-stan.tree.construct(out)%>%mutate(value=NA)%>%distinct
    }else{
     out=stan.sim.output
    }
    msg<-'Done'
    return(list(msg=msg,out=out))
  })
  
  RunShinyStan<-eventReactive(input$shinystan,{
    if(input$goButton==0){
      sim.output=stan.sim.output
    }else{
      sim.output=RunStan()[['out']]
    }
    
    output.names=ldply(sim.output,.fun=function(x) data.frame(stan.obj.output=names(x)))
    
    df=output.names%>%filter(stan.obj.output==input$TableView)
    check.global<<-df
    launch_shinystan(sim.output[[df$r.files]][[df$stan.obj.output]])
  })
  
  output$d3 <- reactive({
    m=structure.list[[input$m]]
    if(is.null(input$Hierarchy)){
      p=m
    }else{
      p=m%>%select(one_of(c(input$Hierarchy,"value")))%>%unique  
    }
    
    list(root = df2tree(p), layout = 'collapse')
    })
  
  output$table <- renderDataTable(expr = {

    if(input$m=='Stan') {
      x.out=StanSelect()[[input$TableView]]
      x.out=x.out[,!apply(x.out,2,function(x) all(is.na(x)))]
    }else{
        x.out=TreeStruct()
    }

    x.out
  }
  ,
    extensions = c('Buttons','Scroller','ColReorder','FixedColumns'),
    filter='top',
    options = list(   deferRender = TRUE,
                      scrollX = TRUE,
                      pageLength = 50,
                      scrollY = 500,
                      scroller = TRUE,
                      dom = 'Bfrtip',
                      colReorder=TRUE,
                      fixedColumns = TRUE,
                      buttons = c('copy', 'csv', 'excel', 'pdf', 'print','colvis'))
  )

  output$filterPrint=renderUI({
    str.out=''
    if(!is.null(input$.nodesData)) str.out=tree.filter(input$.nodesData,m)
    str.out.global<<-str.out
    junk=textConnection(capture.output(str.out[['x2']]))
    toace=paste0(readLines(junk),collapse='\n')
    aceEditor(outputId = "code",value=toace,mode = "r", theme = "chrome", height = "100px", fontSize = 12)
  })
    
  output$SimPrint <- renderUI({
    junk=textConnection(capture.output(RunStan()[['msg']]))
    toace=paste0(readLines(junk),collapse='\n')
    aceEditor(outputId = "codeout",value=toace,mode = "r", theme = "chrome", height = "200px", fontSize = 12)
  })

  getRScripts=reactive({
    dlply(TreeStruct(),.(r.files),.fun=function(x){
      url.loc='https://raw.githubusercontent.com/stan-dev/example-models/master/ARM/'
      dat.loc=unique(paste0('Ch.',as.character(x$chapter),'/'))
      dat.loc=paste0(url.loc,dat.loc)
      code.loc=unique(paste0(dat.loc,as.character(x$r.file)))
      r.code=strsplit(gsub('\\r','',getURL(code.loc)[1]),'\\n')[[1]]
      return(r.code)
    })
  })
  
  getStanScripts=reactive({
    dlply(TreeStruct()%>%filter(r.files==input$getRScriptShow),.(stan.files),.fun=function(x){
      url.loc='https://raw.githubusercontent.com/stan-dev/example-models/master/ARM/'
      dat.loc=unique(paste0('Ch.',as.character(x$chapter),'/'))
      dat.loc=paste0(url.loc,dat.loc)
      code.loc=unique(paste0(dat.loc,as.character(x$stan.files)))
      stan.code=strsplit(gsub('\\r','',getURL(code.loc)[1]),'\\n')[[1]]
      return(stan.code)
    })
  })
  
  output$getRScriptShow=renderUI({
    nm=names(getRScripts())
    selectInput("getRScriptShow","R Script",choices = nm,multiple=F,selected = nm[1])
  })
    
  output$getStanScriptShow=renderUI({
    nm=names(getStanScripts())
    selectInput("getStanScriptShow","Stan Script",choices = nm,multiple=F,selected = nm[1])
  })
  
  output$RCodePrint <- renderUI({
    junk=textConnection(getRScripts()[[input$getRScriptShow]])
    toace=paste0(readLines(junk),collapse='\n')
    aceEditor(outputId = "code3",value=toace,mode = "r", theme = "chrome", height = "800px", fontSize = 12)
  })
  
  output$StanCodePrint <- renderUI({
    junk=textConnection(getStanScripts()[[input$getStanScriptShow]])
    toace=paste0(readLines(junk),collapse='\n')
    aceEditor(outputId = "code4",value=toace,mode = "r", theme = "chrome", height = "800px", fontSize = 12)
  })
  
  output$Hierarchy <- renderUI({
    Hierarchy=names(structure.list[[input$m]])
    Hierarchy=Hierarchy[-length(Hierarchy)]
    Hierarchy=Hierarchy[!(Hierarchy%in%c("stan.obj.output","model.eq"))]
    if(input$m=='Stan') Hierarchy=c('stan.obj.output','Chain','Measure','variable')
    selectizeInput("Hierarchy","Tree Hierarchy",choices = Hierarchy,multiple=T,selected = Hierarchy,
                   options=list(plugins=list('drag_drop','remove_button')))
  })
  
  output$TableView <- renderUI({
    nm=names(StanSelect())
    selectInput("TableView","Stan Output Objects",choices = nm,multiple=F,selected = nm[1])
  })
  
  output$downloadSave <- downloadHandler(
    filename = "StanOutput.RData",
    content = function(con) {
      
      unpack.list <- function(object) {
        for(.x in names(object)){
          assign(value = object[[.x]], x=.x, envir = parent.frame())
        }
      }
      
      if(input$goButton==0){
        shiny.output=stan.sim.output
      }else{
        shiny.output=RunStan()[['out']]
      }
      
      ret.obj=as.character(unlist(lapply(shiny.output,names)))
      
      for(i in 1:length(shiny.output)) unpack.list(shiny.output[[i]])

      save(list=ret.obj, file=con)
    }
  )
  
})