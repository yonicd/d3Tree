# d3tree embed in shiny forked from https://github.com/cpsievert/shiny_apps/tree/master/ggtree
# recursive approach! http://stackoverflow.com/questions/12818864/how-to-write-to-json-with-children-from-r
makeList <- function(x,value=NULL) {
  if(is.null(value)) value=names(x)
  idx <- is.na(x[,2])
  if (ncol(x) > 2 && sum(idx) != nrow(x)){
    listSplit <- split(x[-1], x[1], drop=T)
    colName=value[1]
    value=value[-1]
    lapply(names(listSplit), function(y){
      list(name = y, value = colName, children = makeList(listSplit[[y]],value=value))
      })
  } else {
    if(!all(is.na(x[,1]))){nms <- x[,1]
    colName=value[1]
    lapply(seq_along(nms), function(y){
      list(name = nms[y], value = colName)
    })
    }
  }
}

# thanks Jeroen http://stackoverflow.com/questions/19734412/flatten-nested-list-into-1-deep-list
renquote <- function(l) if (is.list(l)) lapply(l, renquote) else enquote(l)

#data.frame to json sent to JS code
#' @title df2tree
#'
#' @description converts dataframe to json to send to javascript
#'
#' @param struct data.frame containing the structure the tree will represent
#' @param rootname character name of the root node
#' @param toolTip charater vector of the label to give to the nodes in each hierarchy
#' 
#' @examples  
#' df2tree(struct = as.data.frame(Titanic),rootname = 'Titanic')
#' df2tree(struct = as.data.frame(Titanic),rootname = 'Titanic',toolTip = letters[1:5])
#' @export
df2tree <- function(struct,rootname='root',toolTip=NULL) {
  if(is.null(toolTip)) toolTip=c(rootname,names(struct))
  list(name = rootname, children = makeList(struct,value = toolTip[-1]),value=toolTip[1])
}

#' @title tree.filter
#' @description creates character vector logial expression from tree structure
#' @param nodeList list created of tree nodes observed from d3tree.js hook
#' @param m data.frame to filter
#' @return data.frame
#' @export
#' @keywords internal
#' @importFrom plyr ldply ddply
#' @importFrom stringr str_count
#' @import dplyr
tree.filter=function(nodesList,m){

  nodesdf=data.frame(rowname=names(nodesList),x=nodesList,stringsAsFactors = F)
  nodesdf.show=nodesdf[!grepl('_children',nodesdf$rowname),]
  x=nodesdf.show$rowname[grepl('name',nodesdf.show$rowname)]
  if(length(x)==1){
    active_filter=NULL
  }else{
    x.count=10^-(stringr::str_count(x[-1],"children")-1)
    x.count.depth=c(0,(stringr::str_count(x[-1],"children")))
    x.depth=max(x.count.depth)
    node_id=1:(length(x.count.depth))
    parent_id=rep(0,length(x.count)+1)
    
    x.temp=rbind(unique(x.count.depth),rep(0,x.depth+1))
    x.temp[2,1]=1
    row.names(x.temp)=c("depth","current.parent.node")

    x.map=data.frame(node_name=c("root",utils::head(nodesdf.show[grepl('value',nodesdf.show$rowname),'x'],-1)),
                     node_data=nodesdf.show[grepl('name',nodesdf.show$rowname),2],
                     node_id,parent_id,stringsAsFactors = F)
    
    for(i in 2:nrow(x.map)){
      x.temp[2,x.count.depth[i]+1]=node_id[i]
      x.map$parent_id[i]=x.temp[2,x.count.depth[i]]
    }
    
    A = matrix(0,nrow = nrow(x.map),ncol=nrow(x.map))
    A[cbind(x.map$parent_id,x.map$node_id)] = 1
    
    tx=cbind(x.map,d=rowSums(A))
    
    y=plyr::ddply(tx%>%dplyr::filter_(.dots = ~node_name!="root"),c('parent_id'),
              .fun = function(df){
                                  if(all(df$d==0)){
                                    df
                                  }else{
                                    df%>%dplyr::filter_(.dots = ~d!=0)
                                  }
    })%>%dplyr::arrange(node_id)%>%
      dplyr::select_(.dots = '-d')%>%dplyr::mutate_all(funs(as.character))
    
    y$leaf=cumsum(as.numeric(!y$node_id%in%y$parent_id))*as.numeric(!y$node_id%in%y$parent_id)
    
    logics=vector('list',max(y$leaf))
    names(logics)=1:max(y$leaf)
    for(i in 1:max(y$leaf)){
      x=c(y$node_id[y$leaf==i],y$parent_id[y$leaf==i])
      repeat{
        x=c(x,y$parent_id[y$node_id==x[length(x)]])
        if(x[length(x)]=="1"){
          break
        }
      }
      logics[[i]]=x
    }
    
    
  active_filter=plyr::ldply(logics,.fun=function(x){ 

    y=y[y$node_id%in%x,]
    y$l=paste0(y$node_name,"=='",y$node_data,"'")
    y%>%dplyr::summarise_(.dots = list(FILTER='paste0(l,collapse="&")'))
    },.id = "id")
  
  active_filter$id=as.character(active_filter$id)
  names(active_filter)[which(names(active_filter)=='id')]='ID'
    
  }
  
  return(active_filter)
}