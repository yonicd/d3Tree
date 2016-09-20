#Load Libraries
    library(reshape2)
    library(shiny)
    library(shinyAce)
    library(stringr)
    library(DT)
    library(plyr)
    library(dplyr)

  #reading in and creating d3 tree
    source('www/Functions/d3TreeFunctions.r')
  
  #Initialize empty node for d3 tree
    nodesList=list()
