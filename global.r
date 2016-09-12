library(shiny)
library(stringr)
library(DT)
library(plyr)
library(dplyr)

# recursive approach! http://stackoverflow.com/questions/12818864/how-to-write-to-json-with-children-from-r
makeList <- function(x) {
  idx <- is.na(x[,2])
  if (ncol(x) > 2 && sum(idx) != nrow(x)){
    listSplit <- split(x[-1], x[1], drop=T)
    lapply(names(listSplit), function(y){list(name = y, value = names(x)[1], children = makeList(listSplit[[y]]))})
  } else {
    nms <- x[,1]
    lapply(seq_along(nms), function(y){list(name = nms[y], value = names(x)[1])})
  }
}

# thanks Jeroen http://stackoverflow.com/questions/19734412/flatten-nested-list-into-1-deep-list
renquote <- function(l) if (is.list(l)) lapply(l, renquote) else enquote(l)


df2tree <- function(m) {
  list(name = "root", children = makeList(m))
}

tree.filter=function(nodesList,m){
  
  nodesdf=data.frame(rowname=names(nodesList),x=nodesList,stringsAsFactors = F)
  nodesdf.show=nodesdf%>%filter(!grepl('_children',rowname))
  x=nodesdf.show$rowname[grepl('name',nodesdf.show$rowname)]
  if(length(x)==1){
    active_filter=NULL
    }else{
  x.count=10^-(str_count(x[-1],"children")-1)
  x.count.depth=c(0,(str_count(x[-1],"children")))
  x.depth=max(x.count.depth)
  node_id=1:(length(x.count.depth))
  parent_id=rep(0,length(x.count)+1)
  parent_id[1]=NA
  
  x.temp=rbind(unique(x.count.depth),rep(0,x.depth+1))
  x.temp[2,1]=1
  row.names(x.temp)=c("depth","current.parent.node")
  
  x.map=data.frame(node_name=c("root",nodesdf.show[grepl('value',nodesdf.show$rowname),'x']),
                   node_data=nodesdf.show[grepl('name',nodesdf.show$rowname),2],
                   node_id,parent_id,stringsAsFactors = F)
  
  for(i in 2:nrow(x.map)){
    x.temp[2,x.count.depth[i]+1]=node_id[i]
    x.map$parent_id[i]=x.temp[2,x.count.depth[i]]
  }
  
  A = matrix(0,nrow = nrow(x.map),ncol=nrow(x.map))
  A[cbind(x.map$parent_id,x.map$node_id)] = 1
  
  tx=cbind(x.map,d=rowSums(A))
  
  y=ddply(tx%>%filter(node_name!="root"),.(parent_id),.fun = function(df){
    if(all(df$d==0)){
      df
    }else{
      df%>%filter(d!=0)
    }
  })%>%arrange(node_id)%>%select(-d)%>%mutate_each(funs(as.character))
  
  active_filter=y%>%mutate(id=cumsum(ifelse(parent_id==1,1,0)))%>%
    group_by(id,node_name)%>%summarise(x1=paste0('c(',paste(paste0("'",node_data,"'"),collapse=","),')'))%>%
    mutate(x1=paste(node_name,x1,sep="%in%"))%>%
    group_by(id)%>%summarise(x2=paste("(",x1,")",collapse="&"))
  
    }
  return(active_filter)
}

m=mtcars%>%select(cyl,vs,am,carb)%>%mutate(value=NA)%>%distinct
nodesList=list()