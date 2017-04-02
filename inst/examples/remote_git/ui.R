shinyUI(fluidPage(
  tags$head(
    tags$script(type="text/javascript", src = "css/busy.js"),
    tags$link(rel = 'stylesheet', type = 'text/css', href = 'css/style.css')
  ),
  headerPanel("Reactive Tree Search"),
    sidebarPanel(width=3,
                 uiOutput('radioChoice'),
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
    div(class = "busy",
        img(src=sprintf("https://raw.githubusercontent.com/metrumresearchgroup/d3Tree/master/Miscellaneous/busy/loading%s.gif",sample(1:5,1)), height="100",width="100"),
        p("Simulating...")
    ),
    tabsetPanel(
      tabPanel("Tree Filter",  
               fluidPage(
                  fluidRow(
                  column(6,uiOutput("Hierarchy"))
                  ),
                  column(6,d3treeOutput(outputId="d3",width = '1200px',height = '800px'))
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
                          column(12,dataTableOutput('table'))
                        )
               )
    )
  )
)
)
