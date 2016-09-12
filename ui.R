shinyUI(fluidPage(
  
  tags$head(
    tags$script(type="text/javascript", src = "d3.v3.js"),
    tags$script(type="text/javascript", src ="d3.tip.js"),
    tags$script(type="text/javascript", src ="ggtree.js"),
    tags$script(type="text/javascript", src ="cycle.js"),
    tags$link(rel = 'stylesheet', type = 'text/css', href = 'ggtree.css')
  ),
  
  sidebarLayout(
    sidebarPanel(
      
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
                  column(6,HTML("<div id=\"d3\" class=\"d3plot\"><svg /></div>"))
                  )
              ),
      tabPanel("Table",
               fluidPage(
                 fluidRow(
                   column(12,
                          DT::dataTableOutput('table')
                   )
                 )
               )
      )
    )
  )
)
))