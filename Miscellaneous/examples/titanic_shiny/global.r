library(reshape2)
library(shiny)
library(stringr)
library(DT)
library(plyr)
library(dplyr)
library(d3Tree)

m=Titanic%>%data.frame%>%mutate(NEWCOL=NA)%>%distinct