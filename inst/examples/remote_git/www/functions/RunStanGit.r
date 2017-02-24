RunStanGit=function(url.loc,dat.loc.in,r.file,flag=T){

# Internal Functions ----  
  unpack.list <- function(object) {
    for(.x in names(object)){
      assign(value = object[[.x]], x=.x, envir = parent.frame())
    }
  }
  
  strip.path=function(y){
    str=strsplit(y,'[\\/]')[[1]]
    str[length(str)]
  }
  
  setwd.url=function(y){
    x=c(as.numeric(gregexpr('\\"',y)[[1]]),as.numeric(gregexpr("\\'",y)[[1]]))
    x=x[x!=-1]
    
    str.old=substr(y,x[1],x[2])
    str.change=strip.path(substr(y,x[1]+1,x[2]-1))

    if(grepl('source',y)){ 
      str.out=paste0('unpack.list(RunStanGit(url.loc,dat.loc.in,"',str.change,'",flag=F))')
    }else{
      str.new=paste0('"',dat.loc,str.change,'"')
      file.name=gsub(' ','',strsplit(y,'<-|=')[[1]][1])
      eval(parse(text=paste0(file.name,' <<- tempfile()')))
      eval(parse(text=paste0('download.file(',str.new,',',file.name,',quiet = T,method="curl")')))
      str.out=gsub(str.old,file.name,y)      
    }
    str.out  
  }
  
  dat.loc=paste0(url.loc,dat.loc.in)
  code.loc=paste0(dat.loc,r.file)
  
#Read R code ----  
  r.code=strsplit(gsub('\\r','',getURL(code.loc)[1]),'\\n')[[1]]
  
#Rewrite paths for source and read commands to url path ----
  for(i in which(grepl('read|source',r.code))) r.code[i]=setwd.url(r.code[i])
  stan.find=which(grepl('stan\\(',r.code))
  to.unlink=rep(NA,length(stan.find))
  
#Find the names of the objects that the stan calls are saved to ----
  keep.files=gsub(' ','',unlist(lapply(strsplit(r.code[which(grepl('stan\\(',r.code))],'<-'),'[',1)))

# Comment out print calls ----
  r.code=gsub('print','#print',r.code)
  r.code=gsub('pairs','#pairs',r.code)  
  if(length(keep.files)>0){
      for(i in 1:length(keep.files)){
        comment.out=r.code[grep(keep.files[i],r.code)[!grepl('#|<-|=',r.code[grep(keep.files[i],r.code)])]]
        r.code[grep(keep.files[i],r.code)[!grepl('#|<-|=',r.code[grep(keep.files[i],r.code)])]]=paste0('#',comment.out)
      }
    }

#Download the stan file to a temp file and change the call to stan from a text object to a connection ----
  if(length(stan.find)>0){
      for(i in 1:length(stan.find)){
        x=c(as.numeric(gregexpr('\\"',r.code[stan.find[i]])[[1]]),as.numeric(gregexpr("\\'",r.code[stan.find[i]])[[1]]))
        x=x[x!=-1]
        file.name=strip.path(substr(r.code[stan.find[i]],x[1]+1,x[2]-1))
        eval(parse(text=paste0(file.name,' <- tempfile()')))
        loc.file=paste0('"',dat.loc,file.name,'"')
        eval(parse(text=paste0('download.file(',loc.file,',',file.name,',quiet = T,method="curl")')))
        to.unlink[i]=file.name
        r.code[stan.find[i]]=gsub(substr(r.code[stan.find[i]],x[1],x[2]),strip.path(substr(r.code[stan.find[i]],x[1]+1,x[2]-1)),r.code[stan.find[i]])
      }
  }

#Evaluate new code ----
  eval(parse(text=r.code))
  
#Unlink temp stan files ----
  junk=sapply(to.unlink[!is.na(to.unlink)],unlink)
  
#Return objects (conditional if call is nested or not) ----
  if(flag){ret.obj=keep.files}else{ret.obj=ls(pattern = '[^(flag|r.code|keep.files)]')}
  list.out <- sapply(ls()[ls()%in%ret.obj], function(x) get(x))
  
  return(list.out)
#End of function ----
}

#example ----
  # url.loc='https://raw.githubusercontent.com/stan-dev/example-models/master/ARM/'
  # ex=data.frame(r.file=c('10.4_LackOfOverlapWhenTreat.AssignmentIsUnknown.R',
  #                        '10.5_CasualEffectsUsingIV.R',
  #                        '10.6_IVinaRegressionFramework.R', #sourcing another file
  #                        '3.1_OnePredictor.R', #removing partial path to file
  #                        '8.4_PredictiveSimulationToCheckFitOfTimeSeriesModels.R'), #removing echo call from readlines
  #               stringsAsFactors = F)
  # 
  # ex$chapter=unlist(lapply(lapply(strsplit(ex$r.file,'[\\_]'),'[',1),function(x) paste('Ch',strsplit(x,'[\\.]')[[1]][1],sep='.')))
  # ex$example=unlist(lapply(lapply(strsplit(ex$r.file,'[\\_]'),'[',1),function(x) strsplit(x,'[\\.]')[[1]][2]))
  # 
  # a=dlply(ex%>%slice(c(3)),.(r.file),.fun=function(x) RunStanGit(url.loc,dat.loc=paste0(x$chapter,'/'),r.file=x$r.file),.progress = 'text')
#
# Functions to read output into nested list structure with data.frame in leaf
  # stan.sim.out=llply(a,.fun=function(m){
  #   llply(m,.fun=function(stan.out){
  #     x=attributes(stan.out)
  #     x1=llply(x$sim$samples,attributes)
  #     names(x1)=c(1:length(x1))
  #     df.model=ldply(x1,.fun=function(x) do.call('cbind',x$sampler_params)%>%data.frame%>%mutate(Iter=1:nrow(.)),.id="Chain")
  #     
  #     df.samples=stan.out@sim$samples
  #     names(df.samples)=c(1:length(df.samples))
  #     df.samples=ldply(df.samples,.fun = function(y) data.frame(y)%>%mutate(Iter=1:nrow(.)),.id = 'Chain')
  #     
  #     df.model%>%left_join(df.samples,by=c('Chain','Iter'))
  #   })
  # } )
  # 
  # stan.sim.out.files=ldply(a,.fun=function(x) data.frame(stan.obj.output=names(x)))
