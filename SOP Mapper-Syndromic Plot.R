##INPUT DATA
## needed packages
library(mice)
a<-read.csv('/Users/pavan/Desktop/RTest.csv')
# REmove all none numerical columns 
#Remove all rows with no values / columns with no values
a<-removeString(a)
a<-removeNACol(a)
a<-removeNArow(a)
#Check if data is missing then ask to impute
missingdata(a) #If true then data is missing
#Choose columns / have checkbox for choose all
incomplete.columns<-incompleteColNames(a)
complete.columns<-completeColNames(a)

##
columns <- #Some type of mix of colnames from incomplete and complete
df<-a[columns]
#data imputation through multiple chained equations
imp1<-mice(df,m=5)
imp_tot<-mice:::complete(imp1,'long',inc=TRUE)
#split into x data frames with each version of imputation, for pooling later





