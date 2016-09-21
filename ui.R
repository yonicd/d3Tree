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
  
  headerPanel("Tree Search"),
  
    sidebarPanel(width=3,
      radioButtons("m", "Data",split(c('Titanic','StanModels','Stan'),
                                     c('1. Titanic',
                                       '2. Applied Regression Modeling: Full Tree',
                                       '3. Applied Regression Modeling: Sim Output')),selected = 'StanModels'),
      conditionalPanel('input.m=="StanModels"',
                       actionButton("goButton", "Simulate Selection From Stan Repo")
      ),
      checkboxInput(inputId='showtbl',label = 'Show Filter Queries',value = F),
      conditionalPanel('input.m=="Stan"', uiOutput('TableView'),
                       downloadButton('downloadSave', 'Export Stan Output')
                       # ,
                       #                    actionButton('shinystan','Launch Shiny Stan')
                       )
    ),
    
  mainPanel(
    tabsetPanel(
      tabPanel("Layout Tree Filter",  
               fluidPage(
                  fluidRow(
                  column(6,uiOutput("Hierarchy"))
                  ),
                  column(6,HTML("<div id=\"d3\" class=\"d3plot\"><svg /></div>")),
                  column(6,conditionalPanel('input.showtbl',p('Reactive Filters'),
                                                            verbatimTextOutput("results")
                                            ),
                           conditionalPanel('input.goButton==1',
                                            p('Simulation Console Output'),
                                            verbatimTextOutput("results2"))
                         )
                  )
              ),
      tabPanel("Table",
               fluidPage(
                          column(12,DT::dataTableOutput('table'))
                        )
               )
    )
  )
)
)
