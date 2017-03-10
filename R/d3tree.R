#' @title d3tree
#'
#' @description Htmlwidget that binds to d3js trees. When used in Shiny environment the widget returns
#' a data.frame of logical expressions that represent the current state of the tree. 
#'
#' @param data named list containing hierarchy structure of data created by df2tree and the layout of the tree (collapse,radial,cartesian)
#' @param name character containing the names of the nodes
#' @param value charater containing the name of the tooltip column
#' that are used in the leafs
#' @param direction charater containing the direction the collapsible tree layout will grow to horizontal or vertical (can be 'h','v')
#' 
#' @examples  
#' 
#' \donttest{
#' if(interactive()){
#' 
#' d3tree(list(root = df2tree(rootname='Titanic',
#'                            struct=as.data.frame(Titanic)
#'                            ),
#'             layout = 'collapse')
#'       )
#' 
#' d3tree(list(root = df2tree(rootname='Titanic',
#'                            struct=as.data.frame(Titanic),
#'                            toolTip=letters[1:(ncol(as.data.frame(Titanic))+1)]),
#'             layout = 'collapse')
#'       )
#' }
#' }
#' 
#' @import htmlwidgets
#'
#' @export
d3tree <- function(
  data,
  name = "name",
  value = "value",
  direction='horizontal',
  width = NULL, height = NULL, elementId = NULL
) {
  
  # forward options using x
  x = list(
    data = data,
    options = list(name = name, value = value,dir=tolower(substring(direction, 1, 1)))
  )
  
  # create widget
  hw <- htmlwidgets::createWidget(
    name = 'd3tree',
    x,
    width = width,
    height = height,
    package = 'd3Tree',
    elementId = elementId
  )
  
  hw
}

#' Shiny bindings for d3tree
#'
#' Output and render functions for using d3tree within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a d3tree
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name d3tree-shiny
#'
#' @export
d3treeOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'd3tree', width, height, package = 'd3Tree')
}

#' @rdname d3tree-shiny
#' @export
renderD3tree <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, d3treeOutput, env, quoted = TRUE)
}