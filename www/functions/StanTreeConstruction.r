library(plyr)
library(rvest)
library(zoo)
library(dplyr)

stan.models=ddply(data.frame(chapter=c(1:25)[-c(1,11,15,17)]),.(chapter),.fun=function(y){
  x=readLines(con = paste0('https://raw.githubusercontent.com/stan-dev/example-models/master/ARM/Ch.',y$chapter,'/README'))
  x1=x[as.logical(cumsum(x=='Models'))]
  df.out=data.frame(model.type='NA',model.eq='NA',stringsAsFactors = F)
  if(length(x1)>4){
    model.num=do.call('rbind',strsplit(x1[grepl('[0-9]',substr(x1,1,1))],'[.]'))%>%
      data.frame%>%rename(model=X1,model.type=X2)%>%mutate(model=seq(1,nrow(.)))
    
    df=data.frame(x1,model=NA,stringsAsFactors = F)
    df$model[which(grepl('[0-9]',substr(x1,1,1)))]=as.numeric(factor(which(grepl('[0-9]',substr(x1,1,1)))))
    df$model[1]=0
    df$model=na.locf(df$model)
    df.out=df%>%filter(x1!='')%>%filter(model!=0)%>%left_join(model.num,by='model')%>%filter(grepl('[~]',x1))%>%select(model.type,model.eq=x1)
  }
  return(df.out)
},.progress = 'text')

stan.models=stan.models%>%filter(!grepl('NA|Other|Above|weight',model.type))%>%filter(grepl('stan',model.eq))
stan.models$stan.files=gsub(' ','',unlist(lapply(strsplit(stan.models$model.eq,'[:]'),'[',1)))
stan.models$model.eq=gsub('^\\s+|\\s+$','',unlist(lapply(strsplit(stan.models$model.eq,'[:]'),'[',2)))
stan.models$reg.type=gsub('^\\s+|\\s+$','',unlist(lapply(strsplit(stan.models$model.eq,'[\\(]'),'[',1)))

url.path='https://github.com/stan-dev/example-models/tree/master/ARM/'
url.path.raw='https://raw.githubusercontent.com/stan-dev/example-models/master/ARM/'

h=ddply(data.frame(chapter=c(1:25)[-c(1,11,15,17)]),.(chapter),.fun=function(y){
  url.chapter=paste0('Ch.',y,'/')
  read_html(paste0(url.path,url.chapter))%>%
    html_nodes(xpath = '//*[contains(concat( " ", @class, " " ), concat( " ", "css-truncate-target", " " ))]//*[contains(concat( " ", @class, " " ), concat( " ", "js-navigation-open", " " ))]')%>%
    html_text()%>%data.frame(x=.)%>%filter(grepl(glob2rx(paste0(y,'*_*')),.$x))%>%mutate(x.path=paste0(url.path.raw,url.chapter,x))  
},.progress = 'text')



stan.chapter.files=ddply(h,.(chapter,x),.fun=function(a){
          r.code=readLines(a$x.path)
          stan.find=which(grepl('stan\\(',r.code))
          file.name=output.name=NA
          if(length(stan.find)>0){
            for(i in 1:length(stan.find)){
                  x=c(as.numeric(gregexpr('\\"',r.code[stan.find[i]])[[1]]),as.numeric(gregexpr("\\'",r.code[stan.find[i]])[[1]]))
                  x=x[x!=-1]
                  str=strsplit(substr(r.code[stan.find[i]],x[1]+1,x[2]-1),'[\\/]')[[1]]
                  file.name[i]=str[length(str)]
            }
            output.name=gsub(' ','',unlist(lapply(strsplit(r.code[which(grepl('stan\\(',r.code))],'<-'),'[',1)))
          }
          data.frame(stan.files=file.name,
                     stan.obj.output=output.name,
                     stringsAsFactors = F)
},.progress = 'text')%>%
  filter(!is.na(stan.files))%>%distinct

stan.models=
  stan.chapter.files%>%
  left_join(stan.models,by=c('chapter','stan.files'))%>%
  filter(!is.na(reg.type))%>%
  rename(r.files=x)%>%
  distinct

stan.models=stan.models[names(stan.models)[c(1,7,5,2,3,4,6)]]

# stan.sim.output=a
# 
# save(stan.out,stan.list,stan.models,stan.sim.output,file='www/stan_output.rdata')
