shinyUI(
  fluidPage(
               fluidRow(
                 column(7,
                        uiOutput("Hierarchy"),
                        verbatimTextOutput("results"),
                        tableOutput("clickView"),
                        d3treeOutput(outputId="d3",width = '1200px',height = '800px')
                 ),
                 column(5,
                        tableOutput('table')
                        )
               )
      )
)