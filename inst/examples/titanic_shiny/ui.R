#source('/data/shiny-server/SearchTree/TitanicExample/global.r')

shinyUI(fluidPage(

  mainPanel(
  tabsetPanel(
    tabPanel("Layout Tree Filter",
              fluidRow(
                        column(5,uiOutput("Hierarchy"),
                               p("Filters Mapped from Tree"),
                               verbatimTextOutput("results")),
                        column(7,ggtreeOutput(outputId="d3"))
                      )
             ),
    tabPanel("Reactive Table",
              column(12,tableOutput('table'))
              )
  )
)
)
)

