#Load Libraries ----
library(reshape2)
library(RCurl)
library(shiny)
library(shinyAce)
library(stringr)
library(DT)
library(plyr)
library(dplyr)
library(rstan)
library(d3Tree)



#Source App Functions----
source('www/functions/RunStanGit.r')
source('www/functions/StanFunctions.r')

#Read in list to populate d3 tree ----
  structure.list=list(
      Titanic=Titanic |> data.frame() |> mutate(value=NA) |> distinct(),
      StanModels=stan.models |> mutate(value=NA) |> distinct()
      )