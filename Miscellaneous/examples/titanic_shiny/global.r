library(reshape2)
library(shiny)
library(stringr)
library(DT)
library(plyr)
library(dplyr)
library(d3Tree)

m <- Titanic |>
  tibble::as_tibble() |>
  dplyr::mutate(NEWCOL = NA) |>
  dplyr::distinct()