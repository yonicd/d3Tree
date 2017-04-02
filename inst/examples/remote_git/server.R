shinyServer(function(input, output, session) {
  
  #Radio buttons----
  output$radioChoice=renderUI({
    if(input$goButton==0){
      radioButtons("m", "Example Data",split(c('Titanic','StanModels'),
                                             c('1. Titanic',
                                               '2. Applied Regression Modeling: Full Tree')),selected = 'StanModels')    
    }else{
      radioButtons("m", "Example Data",split(c('Titanic','StanModels','Stan'),
                                             c('1. Titanic',
                                               '2. Applied Regression Modeling: Full Tree',
                                               '3. Applied Regression Modeling: Sim Output')),selected = 'StanModels')
    }

  })
  
  #d3Tree----

  m<-eventReactive(input$m,{
    structure.list[[input$m]]
  })
    
  observeEvent(input$m,{
    output$Hierarchy <- renderUI({
      Hierarchy=names(m())
      Hierarchy=Hierarchy[-length(Hierarchy)]
      Hierarchy=Hierarchy[!(Hierarchy%in%c("stan.obj.output","model.eq"))]
      if(input$m=='Stan') Hierarchy=c('stan.obj.output','Chain','Measure','variable')
      selectizeInput("Hierarchy","Tree Hierarchy",choices = Hierarchy,multiple=T,selected = Hierarchy,
                     options=list(plugins=list('drag_drop','remove_button')))
    })
  })
  
  network <- reactiveValues()
  
  observeEvent(input$d3_update,{
    network$nodes <- unlist(input$d3_update$.nodesData)
  })

  TreeStruct=eventReactive(network$nodes,{
    df=m()
    if(is.null(network$nodes)){
      df=m()
    }else{
      x.filter=d3Tree::tree.filter(network$nodes,m())
      df=ddply(x.filter,.(ID),function(a.x){m()%>%filter_(.dots = list(a.x$FILTER))%>%distinct})
    }
    df
  })
  
  observeEvent(input$Hierarchy,{
    output$d3 <- renderD3tree({
        if(!any(names(m())%in%input$Hierarchy)){
          p=m()
        }else{
          p=m()%>%select(one_of(c(input$Hierarchy,"value")))%>%unique
        }

      d3Tree::d3tree(list(root = d3Tree::df2tree(p), layout = 'collapse'),height = 18)
    })
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
    launch_shinystan(sim.output[[df$r.files]][[df$stan.obj.output]])
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
    toace=str.out=''
    if(!is.null(network$nodes)){
      str.out=d3Tree::tree.filter(network$nodes,m())
      junk=textConnection(capture.output(str.out[['FILTER']]))
      toace=paste0(readLines(junk),collapse='\n')
    } 
    
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
  
  observeEvent(input$getRScriptShow,{
    output$getStanScriptShow=renderUI({
      nm=names(getStanScripts())
      selectInput("getStanScriptShow","Stan Script",choices = nm,multiple=F,selected = nm[1])
    })
  })
  
  observeEvent(input$getRScriptShow,{
    output$RCodePrint <- renderUI({
      j=getRScripts()[[input$getRScriptShow]]
      if(is.null(j)) j=''
      junk=textConnection(j)
      toace=paste0(readLines(junk),collapse='\n')
      aceEditor(outputId = "code3",value=toace,mode = "r", theme = "chrome", height = "800px", fontSize = 12)
    })
  })
  
  observeEvent(input$getStanScriptShow,{
    output$StanCodePrint <- renderUI({
      j=getStanScripts()[[input$getStanScriptShow]]
      if(is.null(j)) j=''
      junk=textConnection(j)
      toace=paste0(readLines(junk),collapse='\n')
      aceEditor(outputId = "code4",value=toace,mode = "r", theme = "chrome", height = "800px", fontSize = 12)
    })    
  })

observeEvent(input$goButton,{
  output$TableView <- renderUI({
    nm=names(StanSelect())
    selectInput("TableView","Stan Output Objects",choices = nm,multiple=F,selected = nm[1])
  })
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