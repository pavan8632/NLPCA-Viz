
#check for and/or install dependencies
#NEED TO ADD CHECK FOR NFACTOR
need<-c("RCurl","ggplot2","gridExtra",'png','mice','missMDA','homals','memoise','png','grid','shinyjs')
for(i in 1:length(need)){
  if(require(need[i], character.only = TRUE)==FALSE){ install.packages(need[i]);library(need[i], character.only = TRUE)} else { library(need[i],character.only = TRUE)}
}