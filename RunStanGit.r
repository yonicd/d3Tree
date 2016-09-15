RunStanGit=function(url.loc,dat.loc.in,r.file,flag=T){
  
  unpack.list <- function(object) {
    for(.x in names(object)){
      assign(value = object[[.x]], x=.x, envir = parent.frame())
    }
  }
  
  setwd.url=function(y){
    x=c(as.numeric(gregexpr('\\"',y)[[1]]),as.numeric(gregexpr("\\'",y)[[1]]))
    x=x[x!=-1]
    str.old=substr(y,x[1],x[2])
    str.new=paste0('"',dat.loc,substr(y,x[1]+1,x[2]-1),'"')
    str.out=gsub(str.old,str.new,y)
    if(grepl('source',y)) str.out=paste0('unpack.list(RunStanGit(url.loc,dat.loc.in,',str.old,',flag=F))')
    str.out  
  }
  
  dat.loc=paste0(url.loc,dat.loc.in)
  code.loc=paste0(dat.loc,r.file)
  
  y=readLines(code.loc)
  y=gsub('print','#print',y)
  
  for(i in which(grepl('read|source',y))) y[i]=setwd.url(y[i])
  stan.find=which(grepl('stan\\(',y))
  to.unlink=rep(NA,length(stan.find))
  
  
  for(i in 1:length(stan.find)){
    x=c(as.numeric(gregexpr('\\"',y[stan.find[i]])[[1]]),as.numeric(gregexpr("\\'",y[stan.find[i]])[[1]]))
    x=x[x!=-1]
    file.name=substr(y[stan.find[i]],x[1]+1,x[2]-1)
    eval(parse(text=paste0(file.name,' <- tempfile()')))
    loc.file=paste0('"',dat.loc,file.name,'"')
    eval(parse(text=paste0('download.file(',loc.file,',',file.name,',quiet = T)')))
    to.unlink[i]=file.name
  }
  
  for(i in stan.find) y[i]=gsub("[\\']",'',y[i])
  
  eval(parse(text=y))
  junk=sapply(to.unlink[!is.na(to.unlink)],unlink)
  if(flag){ret.obj='.sf1'}else{ret.obj='[^flag]'}
  list.out <- sapply(ls()[ls()%in%ls(pattern = ret.obj)], function(x) get(x))
  return(list.out)
}

#example
# url.loc='https://raw.githubusercontent.com/stan-dev/example-models/master/ARM/'
# dat.loc='Ch.10/'
# ex=data.frame(r.file=c('10.4_LackOfOverlapWhenTreat.AssignmentIsUnknown.R',
#                        '10.5_CasualEffectsUsingIV.R',
#                        '10.6_IVinaRegressionFramework.R')
#               )

# a=dlply(ex,.(r.file),.fun=function(x) RunStanGit(url.loc,dat.loc,r.file=x$r.file),.progress = 'text')
