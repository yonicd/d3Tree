#Load Libraries ----
library(reshape2)
library(shiny)
library(shinyAce)
library(stringr)
library(DT)
library(plyr)
library(dplyr)

#Source Functions----
  #reading in and creating d3 tree
    source('www/functions/d3TreeFunctions.r')
  #Run stan simulations
    source('www/functions/RunStanGit.r')
  #Extract sim outputs from stan simulations
    source('www/functions/StanFunctions.r')
#Load static data ----
  load('www/stan_output.rdata')
  data.list=list(Stan=stan.list,Titanic=Titanic)
#Create list to populate d3 tree ----
  structure.list=list(
      Titanic=Titanic%>%data.frame%>%mutate(value=NA)%>%distinct,
      StanModels=stan.models%>%mutate(value=NA)%>%distinct,
      Stan=stan.tree.construct(stan.sim.output)%>%mutate(value=NA)%>%distinct
      )  
#Initialize empty node for d3 tree ----
nodesList=list()
str.out.global=c()
df.global=c()
msg=c()
out.global=c()
