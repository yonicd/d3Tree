#' <Add Title>
#'
#' <Add Description>
#'
#' @import htmlwidgets
#'
#' @export
ggtree <- function(
  data,
  name = "name",
  width = NULL, height = NULL, elementId = NULL
) {

  # forward options using x
  x = list(
    data = data,
    options = list(name = name)
  )

  # create widget
  hw <- htmlwidgets::createWidget(
    name = 'ggtree',
    x,
    width = width,
    height = height,
    package = 'SearchTree',
    elementId = elementId
  )

  hw
}

#' Shiny bindings for ggtree
#'
#' Output and render functions for using ggtree within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a ggtree
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name ggtree-shiny
#'
#' @export
ggtreeOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'ggtree', width, height, package = 'SearchTree')
}

#' @rdname ggtree-shiny
#' @export
renderGgtree <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, ggtreeOutput, env, quoted = TRUE)
}
