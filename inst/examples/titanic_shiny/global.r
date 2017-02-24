library(reshape2)
library(shiny)
library(stringr)
library(DT)
library(plyr)
library(dplyr)
library(SearchTree)

m=Titanic%>%data.frame%>%mutate(value=NA)%>%distinct
nodesList=list()