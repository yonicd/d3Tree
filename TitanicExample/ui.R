source('/data/shiny-server/SearchTree/TitanicExample/global.r')

shinyUI(fluidPage(
  
  tags$head(
    tags$script(type="text/javascript", src = "css/d3.v3.js"),
    tags$script(type="text/javascript", src ="css/d3.tip.js"),
    tags$script(type="text/javascript", src ="css/ggtree.js"),
    tags$script(type="text/javascript", src ="css/cycle.js"),
    tags$link(rel = 'stylesheet', type = 'text/css', href = 'css/ggtree.css')
  ),
  
  mainPanel(
  tabsetPanel(
    tabPanel("Layout Tree Filter",  
              fluidRow(
                        column(5,uiOutput("Hierarchy"),
                               p("Filters Mapped from Tree"),
                               verbatimTextOutput("results")),
                        column(7,HTML("<div id=\"d3\" class=\"d3plot\"><svg /></div>"))
                      )
             ),
    tabPanel("Reactive Table",
              column(12,tableOutput('table'))
              )
  )
)
)
)

