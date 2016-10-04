source('/data/shiny-server/SearchTree/global.r')

shinyUI(fluidPage(
  
  tags$head(
    tags$script(type="text/javascript", src = "css/d3.v3.js"),
    tags$script(type="text/javascript", src = "css/d3.tip.js"),
    tags$script(type="text/javascript", src = "css/ggtree.js"),
    tags$script(type="text/javascript", src = "css/cycle.js"),
    tags$script(type="text/javascript", src = "css/busy.js"),
    tags$link(rel = 'stylesheet', type = 'text/css', href = 'css/ggtree.css')
  ),
  
  div(class = "busy",
      img(src="http://downgraf.com/wp-content/uploads/2014/09/01-progress.gif", height="100",width="100"),
      p("Simulating...")
  ),
  headerPanel("Reactive Tree Search"),
    sidebarPanel(width=3,
      #a(img(src='http://metrumrg.com/assets/img/logo_bigger.png',align='left',width='50%'),href='http://metrumrg.com/opensourcetools.html',target="_blank"),
      #hr(),
      #verbatimTextOutput("holdOut"),
      radioButtons("m", "Example Data",split(c('Titanic','StanModels','Stan'),
                                     c('1. Titanic',
                                       '2. Applied Regression Modeling: Full Tree',
                                       '3. Applied Regression Modeling: Sim Output')),selected = 'StanModels'),
      hr(),
      checkboxInput(inputId='showtbl',label = 'Show Filter Queries',value = F),
      conditionalPanel('input.showtbl',p('Reactive Filters'),uiOutput("filterPrint")),
      hr(),
      conditionalPanel('input.m=="StanModels"',
                       actionButton("goButton", "Simulate From GitHub")
                       
      ),
      conditionalPanel('input.goButton==1',
                              uiOutput("SimPrint")
             ),
      conditionalPanel('input.m=="Stan"', uiOutput('TableView'),
                       # actionButton('shinystan','Launch Shiny Stan'),
                       downloadButton('downloadSave', 'Export Stan Output')
                       )
    ),
    
  mainPanel(
    tabsetPanel(
      tabPanel("Tree Filter",  
               fluidPage(
                  fluidRow(
                  column(6,uiOutput("Hierarchy")
                         #,
                         #verbatimTextOutput("clientdataText")
                         )
                  ),
                  column(6,HTML("<div id=\"d3\" class=\"d3plot\"><svg /></div>"))
                  )
              ),
      tabPanel("View Simulation Code",
               fluidPage(
                 
                 column(6,uiOutput('getRScriptShow'),
                          uiOutput("RCodePrint")),
                 
                 column(6,uiOutput('getStanScriptShow'),
                        uiOutput("StanCodePrint"))
               )
      ),
      tabPanel("Reactive Table",
               fluidPage(
                          column(12,tableOutput('table'))
                        )
               )
    )
  )
)
)
