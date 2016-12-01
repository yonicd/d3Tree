library(SearchTree)

#  see if search tree is working as an htmlwidget
tit_d3 <- list(
  root = SearchTree:::df2tree(as.data.frame(Titanic)),
  layout = 'collapse'
)

ggtree(tit_d3)
