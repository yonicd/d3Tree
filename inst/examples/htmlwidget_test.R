#  see if search tree is working as an htmlwidget
library(d3Tree)

#Using d3Tree::df2tree function

d3tree(list(root = df2tree(rootname = 'Titanic',struct = as.data.frame(Titanic),toolTip = letters[1:5]),layout = 'collapse'))

#Using d3r::d3nest function
library(d3r)

d3tree(
  list(
    root = d3r::d3_nest(as.data.frame(Titanic)),
    layout = "collapse"
  ),
  value = "colname"
)
