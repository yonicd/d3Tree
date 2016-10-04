#Load Libraries
homDir=''
if(dir.exists('/data/jonathans/script/lib')){
  .libPaths('/data/jonathans/script/lib')  
  homeDir='/data/shiny-server/SearchTree/'
}

    library(reshape2)
    library(shiny)
    library(shinyAce)
    library(stringr)
    library(DT)
    library(plyr)
    library(dplyr)
    
  #reading in and creating d3 tree
    source(paste0(homeDir,'www/functions/d3TreeFunctions.r'))
  
  #Initialize empty node for d3 tree
    nodesList=list()
