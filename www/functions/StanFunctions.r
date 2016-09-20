stan.df.extract=function(a){
  out=ldply(a,.fun=function(m){
    ldply(m,.fun=function(stan.out){
      x=attributes(stan.out)
      x1=llply(x$sim$samples,attributes)
      names(x1)=c(1:length(x1))
      df.model=ldply(x1,.fun=function(x) do.call('cbind',x$sampler_params)%>%data.frame%>%mutate(Iter=1:nrow(.)),.id="Chain")
      
      df.samples=stan.out@sim$samples
      names(df.samples)=c(1:length(df.samples))
      df.samples=ldply(df.samples,.fun = function(y) data.frame(y)%>%mutate(Iter=1:nrow(.)),.id = 'Chain')
      
      df.model%>%left_join(df.samples,by=c('Chain','Iter'))
    },.id = 'stan.obj.output')
  },.id = 'r.files' )
  
  names(out)[names(out)=='r.file']='r.files'
  
  return(out)
  
}

stan.tree.construct=function(stan.sim.output){
  stan.models%>%mutate_each(funs(as.character),r.files,stan.obj.output)%>%
    inner_join(stan.df.extract(stan.sim.output)%>%
                 ddply(.(r.files,stan.obj.output),.fun=function(y) y%>%melt(.,c('r.files','stan.obj.output','Chain','Iter'))%>%filter(!is.na(value)))%>%
                 select(-c(Iter,value))%>%
                 distinct%>%mutate_each(funs(as.character),r.files,stan.obj.output),
               by=c('r.files','stan.obj.output')
    )%>%mutate(Measure=factor(gsub('[0-9.]','',variable)))
}

#create list for table view
read.stan=function(stan.data,tree.df){
  stan.df=stan.df.extract(stan.data)%>%
    mutate_each(funs(as.character),r.files,stan.obj.output)%>%
    mutate_each(funs(as.numeric),-c(r.files,stan.obj.output))
  
  x=stan.df%>%melt(.,c('r.files','stan.obj.output','Chain','Iter'))%>%mutate(variable=as.character(variable))
  x1=tree.df%>%select(stan.obj.output,Chain,variable)%>%mutate_each(funs(as.character))%>%mutate(Chain=as.numeric(Chain))
  
  x1%>%left_join(x,by=c('stan.obj.output','Chain','variable'))%>%
    dlply(.(stan.obj.output),.fun=function(df) df%>%dcast(Chain+Iter~variable,value.var='value'))
}