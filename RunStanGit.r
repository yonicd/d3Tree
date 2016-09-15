RunStanGit=function(url.loc,dat.loc,r.file){
  
  setwd.url=function(y){
    x=c(as.numeric(gregexpr('\\"',y)[[1]]),as.numeric(gregexpr("\\'",y)[[1]]))
    x=x[x!=-1]
    gsub(substr(y,x[1],x[2]),paste0('"',dat.loc,substr(y,x[1]+1,x[2]-1),'"'),y)  
  }
  
  dat.loc=paste0(url.loc,dat.loc)
  code.loc=paste0(url.loc,dat.loc,r.file)
  
  y=readLines(code.loc)
  y=gsub('print','#print',y)
  
  for(i in which(grepl('read',y))) y[i]=setwd.url(y[i])
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
  list.out <- sapply(ls()[ls()%in%ls(pattern = '.sf1')], function(x) get(x))
  return(list.out)}


url.loc='https://raw.githubusercontent.com/stan-dev/example-models/master/ARM/'

a=RunStanGit(url.loc,dat.loc='Ch.10/',r.file='10.5_CasualEffectsUsingIV.R')
