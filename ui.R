shinyUI(fluidPage(
  
  tags$head(
    tags$script(type="text/javascript", src = "d3.v3.js"),
    tags$script(type="text/javascript", src ="d3.tip.js"),
    tags$script(type="text/javascript", src ="ggtree.js"),
    tags$script(type="text/javascript", src ="cycle.js"),
    tags$script(type="text/javascript", src = "busy.js"),
    tags$link(rel = 'stylesheet', type = 'text/css', href = 'ggtree.css')
  ),
  
  div(class = "busy",
      img(src="http://downgraf.com/wp-content/uploads/2014/09/01-progress.gif", height="100",width="100"),
      p("Simulating...")
  ),
  
  headerPanel("Tree Search"),
  
    sidebarPanel(width=2,
      radioButtons("m", "Data",split(c('Titanic','StanModels','Stan'),
                                     c('1. Titanic',
                                       '2. Applied Regression Modeling: Full Tree',
                                       '3. Applied Regression Modeling: Sim Output')),selected = 'Titanic')
    ),
    
  mainPanel(
    tabsetPanel(
      tabPanel("Layout Tree Filter",  
               fluidPage(
                  fluidRow(
                  column(6,uiOutput("Hierarchy")),
                  column(4,checkboxInput(inputId='showtbl',label = 'Show Filter Queries',value = F))
                  ),
                  conditionalPanel('input.showtbl',column(6,verbatimTextOutput("results"))),
                  conditionalPanel('input.m=="StanModels"',
                                   column(6,actionButton("goButton", "Simulate Selection From Stan Repo"))
                  ),
                  column(6,HTML("<div id=\"d3\" class=\"d3plot\"><svg /></div>")),
                  conditionalPanel('input.m=="StanModels"',column(6,verbatimTextOutput("results2")))
                  )
              ),
      tabPanel("Table",
               fluidPage(
                          conditionalPanel('input.m=="Stan"',uiOutput('TableView')),
                          column(12,DT::dataTableOutput('table'))
                        )
               )
    )
  )
)
)