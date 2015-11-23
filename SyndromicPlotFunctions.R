#All functions necessary for Syndromic Plot
library(memoise)
missingdata<- function(df){
  return(sum(sapply(df,is.na))>0)
}
removeNACol <- function(df){
  df[ , colSums(is.na(df))!=nrow(df)]
  
}
# can it be imputed aka does it have complete rows?
imputable<- function(df){
  sums=apply(a,1,is.na)
  sums=colSums(sums)
  if(is.element(0,sums)){
    return(TRUE)
  }
  return(FALSE)
}
removeNArow<-function(df){
  df[rowSums(is.na(df))+1!=ncol(df) , ]
}

removeString <-function(df){
  
  df[!sapply(df, is.factor)]
}

completeColList<-function(df){
  return(colSums(sapply(df,is.na)))
}

removeNoVary<-function(df){
    df[ ,apply(df, 2, var, na.rm=TRUE)!=0]
  }

completeColNames<-function(df){
  binary<-ifelse(completeColList(df)>0,1,0)
  complete<-list()
  incomplete<-list()
  for(i in 1:length(binary)){
    if(binary[[i]]==0)
      complete<-c(complete,binary[i])
    
   
  }
  return(names(complete))
}
incompleteColNames<-function(df){
  binary<-ifelse(completeColList(df)>0,1,0)
  incomplete<-list()
  for(i in 1:length(binary)){
    if(binary[[i]]==1)
      incomplete<-c(incomplete,binary[i])
  }
  return(names(incomplete))
}


colVars <- function(x, na.rm=FALSE, dims=1, unbiased=TRUE, SumSquares=FALSE,
                    twopass=FALSE) {
  if (SumSquares) return(colSums(x^2, na.rm, dims))
  N <- colSums(!is.na(x), FALSE, dims)
  Nm1 <- if (unbiased) N-1 else N
  if (twopass) {x <- if (dims==length(dim(x))) x - mean(x, na.rm=na.rm) else
    sweep(x, (dims+1):length(dim(x)), colMeans(x,na.rm,dims))}
  (colSums(x^2, na.rm, dims) - colSums(x, na.rm, dims)^2/N) / Nm1
}
#return a list of percent change in variance from non imputed data 

varChecker<-function(df,imp){
  x<-colVars(df,na.rm=TRUE)
  y<-colVars(imp)
  mapply(function(a,b) (a-b)/a*100, x,y)
  
}

screepl<-function(pca){
  df<-rbind(pca$eigenvalues)
  x<-c(1:ncol(df))
  y<-df
  plot(x,y,type="b",main="Scree Plot of Eigenvalues vs. Principal Components", xlab="Principal Components",ylab="EigenValues")
  
}

memhomals<-function(...){
  memoise(homals())
}

#extracts laodings from homal$loadings, and a pc to plot
loadingextractor<-function(loadings,pc){
  loadings<-as.data.frame(loadings)
  x<-paste('D',pc,sep='')
  mask<-grepl(x,colnames(loadings))
  return(loadings[mask])
}

