#Load Libraries
 .libPaths('/data/jonathans/script/lib')
    library(reshape2)
    library(shiny)
    library(shinyAce)
    library(stringr)
    library(DT)
    library(plyr)
    library(dplyr)

    homeDir='/data/shiny-server/SearchTree/TitanicExample/'
    
  #reading in and creating d3 tree
    source(paste0(homeDir,'www/functions/d3TreeFunctions.r'))
  
  #Initialize empty node for d3 tree
    nodesList=list()
