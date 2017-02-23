#Load Libraries
homeDir=getwd()
# if(dir.exists('/data/jonathans/script/lib')){
#   .libPaths('/data/jonathans/script/lib')  
#   homeDir='/data/shiny-server/SearchTree/'
# }

    library(reshape2)
    library(shiny)
    library(shinyAce)
    library(stringr)
    library(DT)
    library(plyr)
    library(dplyr)
    library(SearchTree)
  #reading in and creating d3 tree
    source(file.path(homeDir,'www/functions/d3TreeFunctions.r'))
  
  #Initialize empty node for d3 tree
    nodesList=list()
