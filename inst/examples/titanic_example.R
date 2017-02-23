library(SearchTree)

#  see if search tree is working as an htmlwidget
tit_d3 <- list(
  root = SearchTree:::df2tree(as.data.frame(Titanic)),
  layout = 'collapse'
)

ggtree(tit_d3)

library(d3r)

ggtree(
  list(
    root = d3r::d3_nest(
      as.data.frame(Titanic)
    ),
    layout = "collapse"
  ),
  value = "colname"
)
