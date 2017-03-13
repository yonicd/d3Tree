#  see if search tree is working as an htmlwidget
library(d3Tree)

#Using d3Tree::df2tree function

#horizontal(default)
d3tree(list(root = df2tree(rootname = 'Titanic',struct = as.data.frame(Titanic),toolTip = letters[1:5]),layout = 'collapse'))

#vertical
d3tree(list(root = df2tree(rootname = 'Titanic',struct = as.data.frame(Titanic),toolTip = letters[1:5]),layout = 'collapse'),direction = 'v')

#vertical
d3tree(list(root = df2tree(rootname = 'Titanic',struct = as.data.frame(Titanic),toolTip = letters[1:5]),layout = 'collapse'),activeReturn = c('name','value','depth','id'))

#Using d3r::d3nest function
library(d3r)

d3tree(
  list(
    root = d3r::d3_nest(as.data.frame(Titanic)),
    layout = "collapse"
  ),
  value = "colname"
)
