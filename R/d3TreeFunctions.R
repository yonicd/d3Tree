#data.frame to json sent to JS code
#' @title df2tree
#'
#' @description converts dataframe to json to send to javascript
#'
#' @param struct data.frame containing the structure the tree will represent
#' @param rootname character name of the root node
#' @param tool_tip charater vector of the label to give to the
#'   nodes in each hierarchy
#'
#' @examples
#' titanic_df <- as.data.frame(Titanic)
#'
#' df2tree(struct = titanic_df,rootname = 'Titanic')
#'
#' df2tree(
#'   struct = titanic_df,
#'   rootname = 'Titanic',
#'   tool_tip = letters[1:5]
#' )
#'
#' @export
df2tree <- function(struct, rootname = 'root', tool_tip = NULL) {

  if(is.null(tool_tip)){
    tool_tip <- c(rootname, names(struct))
  }

  list(
    name = rootname,
    children = make_list(
      struct,
      value = tool_tip[-1]
    ),
    value = tool_tip[1]
  )
}

#' @title tree_filter
#' @description creates character vector logial expression from tree structure
#' @param nodes_list list created of tree nodes observed from d3tree.js hook
#' @param m data.frame to filter
#' @return data.frame
#' @export
#' @keywords internal
#' @importFrom tibble tibble
#' @importFrom tidyselect everything
#' @importFrom utils globalVariables head
#' @importFrom dplyr mutate select arrange filter across summarise bind_rows
tree_filter <- function(nodes_list, m){

  nodesdf <- tibble::tibble(
    rowname = names(nodes_list),
    x = nodes_list
  )

  nodesdf_show <- nodesdf[!grepl('_children', nodesdf$rowname), ]

  x <- nodesdf_show$rowname[grepl('name', nodesdf_show$rowname)]

  if(length(x) == 1){

    active_filter <- NULL

  } else {

    str_counts <-  sapply(
      gregexpr('children', x[-1]),
      function(xi) length(attr(xi, 'match.length'))
    )

    x_count <- 10^-(str_counts - 1)
    x_count_depth <- c(0, str_counts)
    x_depth <- max(x_count_depth)

    node_id <- seq(length(x_count_depth))
    parent_id <- rep(0, length(x_count) + 1)

    x_temp <- rbind(unique(x_count_depth), rep(0,x_depth + 1))
    x_temp[2, 1] <- 1
    row.names(x_temp) <- c("depth","current.parent.node")

    x_map <- tibble::tibble(
      node_name = c(
        "root",
        utils::head(nodesdf_show[grepl('value', nodesdf_show$rowname), 'x'], -1)[[1]]
      ),
      node_data = nodesdf_show[grepl('name', nodesdf_show$rowname), 2][[1]],
      node_id,
      parent_id
    )

    for(i in 2:nrow(x_map)){
      x_temp[2,x_count_depth[i]+1] <- node_id[i]
      x_map$parent_id[i] <- x_temp[2,x_count_depth[i]]
    }

    A <- matrix(0, nrow = nrow(x_map), ncol = nrow(x_map))
    A[cbind(x_map$parent_id, x_map$node_id)] <- 1

    tx <- cbind(x_map, d = rowSums(A))

    y <- tx |> 
      dplyr::filter(node_name != "root") |> 
      dplyr::mutate(dd = cumsum(d), .by = parent_id) |> 
      dplyr::filter(d == dd) |> 
      dplyr::arrange(node_id) |> 
      dplyr::select(-c(d,dd)) |> 
      dplyr::mutate(dplyr::across(tidyselect::everything(), as.character))

    y$leaf <- cumsum(as.numeric(!y$node_id %in% y$parent_id)) * as.numeric(!y$node_id %in% y$parent_id)

    logics <- vector('list',max(y$leaf))
    names(logics) <- seq(max(y$leaf))

    for(i in 1:max(y$leaf)){
      x <- c(y$node_id[y$leaf == i], y$parent_id[y$leaf == i])

      repeat{

        x <- c(x, y$parent_id[y$node_id == x[length(x)]])

        if(x[length(x)] == "1"){
          break
        }
      }

      logics[[i]] <- x
    }

  active_filter_list <- lapply(logics, function(x){ 
      y <- y[y$node_id %in% x, ]

      y$l <- paste0( y$node_name, "=='", y$node_data, "'")

      y |> 
        dplyr::summarise(
          FILTER = paste0(l, collapse = "&")
        )
    })

    active_filter <- active_filter_list |>
      dplyr::bind_rows(.id = "id")

  active_filter$id <- as.character(active_filter$id)

  names(active_filter)[which(names(active_filter) == 'id')] <- 'ID'

  }

  return(active_filter)
}

utils::globalVariables(c('d', 'dd', 'node_name', 'l'))

make_list <- function(x, value = NULL) {

  if(is.null(value)){
    value <- names(x)
  }

  idx <- is.na(x[,2])
  if (ncol(x) > 2 && sum(idx) != nrow(x)){

    listSplit <- split(x[-1], x[1], drop = TRUE)
    colName <- value[1]
    value <- value[-1]

    lapply(names(listSplit), function(y){
      list(
        name = y,
        value = colName,
        children = make_list(listSplit[[y]],value=value)
        )
      })
  } else {

    if(!all(is.na(x[,1]))){

      nms <- x[,1]
      col_name <- value[1]

      lapply(seq_along(nms), function(y){
        list(
          name = nms[y],
          value = col_name
        )
      })
    }
  }
}

renquote <- function(l) {

  if (is.list(l)){
    lapply(l, renquote)
  } else {
    enquote(l)
  }

}
