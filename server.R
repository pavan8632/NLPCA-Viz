library(shiny)
library(ggplot2)
library(mice)
library(missMDA)
library(shinyjs)
library(data.table)
library(memoise)
library(homals)
library(gridExtra)
library(png)
library(grid)
library(shinythemes)
library(shinyBS)

source('./SyndromicPlotFunctions.R')
source("./FergPlot.R")


shinyServer(function(input,output,session,clientData){
  pp<-theme(
    axis.line = element_line(colour = 'black', size = .55), 
    panel.background = element_blank(),  
    plot.background = element_blank()
  )
  memhomals<-memoise(homals)

  observe({
    catcols<-input$cat
    allcolname<-colnames(dataFrameCreator())
    updateSelectInput(session,'numerical',choices=setdiff(allcolname,catcols))
 
  })
 
  observe({
    restcont<-input$restContinuous
    restcat<-input$restCategorical
    if(restcont&&restcat){
      createAlert(session,'alert','varAlert',title='Classification Error',content='Both rest categorical and rest continuous can not be checked',append=FALSE)
      #updateCheckboxInput(session,'restCategorical',value=FALSE)
      #updateCheckboxInput(session,'restContinuous',value=FALSE)
    }
    else{
      closeAlert(session,'varAlert')
      
    }
    
  })
 

  #get data input, clean data, determine imputability
  parsing<-reactive({

    dataFile<-input$file1
    if(is.null(dataFile))
      return(NULL)
    
    data<-read.csv(dataFile$datapath,header=TRUE,sep=',',quote="'",row.names=NULL)
   # Remove any columns with strings, and rows and columns with no values
    data<-removeString(data)
    data<-removeNACol(data)
    data<-removeNArow(data)
    data<-removeNoVary(data)
    return(data)
    })
  output$FirstStep<-renderText({
    if(input$allcol)
      return(NULL)
    "First step is to choose complete columns for data set"
  })
  output$CompleteColumnSelector<-renderUI({
     if(input$allcol)
       return(NULL)
     if(is.null(parsing()))
       return(NULL)
    #access the data
    df<-parsing()
    #fill the complete and incomplete columns
    complete.columns<-completeColNames(df)
    selectInput('completecols','Choose columns with no missing entries',complete.columns,multiple=TRUE)

    })
  output$SecondStep<-renderText({
    if(input$allcol)
      return(NULL)
    "Second step is to choose incomplete columns for data set"
  })
  output$IncompleteColumnSelector<-renderUI({
    if(input$allcol)
      return(NULL)
    if(is.null(parsing()))
      return(NULL)
    #access the data
    df<-parsing()
    #fill the complete and incomplete columns
    incomplete.columns<-incompleteColNames(df)
    selectInput('incompletecols','Choose columns with missing data',incomplete.columns,multiple=TRUE)
    
  })
 
 
  #pre imputation choosing of columns
  dataFrameCreator<-reactive({
    if(is.null(parsing()))
      return(NULL)
    if(input$allcol)
      return(parsing())
    df<-parsing()
    col1<-input$incompletecols
    col2<-input$completecols
    cols<-c(col1,col2)
    df<-df[cols]
    return(df)
  })
  #For imputation after columns are organized
  dataFrameCreator2<-reactive({
    if(is.null(dataFrameCreator()))
      return(NULL)
    df<-dataFrameCreator()
    df.cat<-df[input$cat]
    if(input$restCategorical==TRUE)
      df.cat<-df[,!names(df)%in% input$numerical]
    else{
      df.cat<-df[input$cat]
    }
    if(input$restContinuous==TRUE)
      df.num<-df[,!names(df)%in% input$cat]
    else{
      df.num<-df[input$numerical]
    }
    return(data.frame(df.cat,df.num))
  })

  #initial viewer after columns chosen
  output$dataviewer<-renderTable({
    if(is.null(parsing()))
      return(NULL)
    if(is.null(dataFrameCreator()))
      return(NULL)
    print(summary(dataFrameCreator()))
  })
  #second viewer after organized into categorical / not
  output$dataviewer2<-renderTable({
    if(is.null(dataFrameCreator2()))
      return(NULL)
    if(input$printData)
      print(dataFrameCreator2())
  })


output$categorical<-renderUI({
  if(is.null(dataFrameCreator()))
     return(NULL)
  allcolname<-colnames(dataFrameCreator())
  selectInput('cat','Categorical Var names',allcolname,multiple=TRUE)
})

#### Isolate function makes reactive dependent on input$FAMD which is action button and not
#dependent on the inputs for the imputed data imputation.


imputationFAMD<-reactive({
  ###IMPUTATION  on click
  if(input$FAMD==0)
      return(NULL)
  if(isolate(length(input$cat))>0)
      return(isolate({
         imputedData<-imputeFAMD(dataFrameCreator2(),ncp=input$ncp,method=input$method)
 
      }))
  else{
      return(isolate({
         imputedData<-imputePCA(dataFrameCreator2(),ncp=input$ncp,method=input$method)
    }))
  }
})

#need to figure out how to get all values from a list and create a reactive that returns a list of all reactive objects

imputationMICE<-reactive({
  if(is.null(dataFrameCreator2()))
    return(NULL)
  if(input$mice==0)
    return(NULL)
  df<-dataFrameCreator2()
  if(isolate(length(input$cat))>0)
    return({
      isolate(mice(dataFrameCreator2(),m=input$num.df,method=c(rep(input$catmethod,length(input$cat)),rep(input$nummethod,(length(df)-length(input$cat))))))
    })
  else{
    return({
      isolate(mice(dataFrameCreator2(),m=input$num.df,method=c(rep(input$nummethod,length(df)))))
    })
  }
})

listOfImputed<-reactive({
  if(is.null(dataFrameCreator2()))
    return(NULL)
  df.orig<-dataFrameCreator2()
  l<-list()
  i=1
  l[[i]]<-df.orig
  
  if(!is.null(imputationFAMD())){
      i<-i+1
      famd<-imputationFAMD()$completeObs
      l[[i]]<-famd
  }
  if(!is.null(imputationMICE())){
    i<-i+1
    mice<-imputationMICE()
    j<-1
    while(j<input$num.df+1){
      l[[i]]<-mice:::complete(mice,j)
      i<-i+1
      j<-j+1
    }
  }
  l<-l[!sapply(l,is.null)]
  return(l)  
   
  })
#makes a col var data frame for comparison
cvimputed<-reactive({
  if(is.null(listOfImputed()))
    return(NULL)
  l<-listOfImputed()
  r<-vector()
  r<-c(r,'original')
  if(!is.null(imputationFAMD()))
    r<-c(r,'FAMD')
  if(!is.null(imputationMICE())){
    i<-1
    while(i<input$num.df+1){
      r<-c(r,paste('MICE',i,sep=""))
      i<-i+1
    }
  }
  lvar<-lapply(l,function(x)colVars(x,na.rm=TRUE))
  lvarta<-t(as.data.frame(lvar))
  row.names(lvarta)<-r
  return(list(lvarta,r))
})
output$df2use<-renderUI({
  if(is.null(cvimputed()))
    return(NULL)
  selectInput('df2plot','Select which dataframe to visualize',choices=cvimputed()[[2]])
  
})

#### have an issue here...
output$imputedviewer<-renderTable({
  if(is.null(cvimputed()))
    return(NULL)
  print(cvimputed()[[1]])
  
  
})

nlpca<-reactive({
  if(input$nlpca==0)
    return(NULL)
  l<-listOfImputed()
  numcat<-length(input$cat)
  numcol<-NCOL(dataFrameCreator2())
  output<-lapply(l,function(x) 
   tryCatch(
    isolate(memhomals(x,ndim=input$pcs,rank=1,level=c(rep('nominal',numcat),rep('numerical',(numcol-numcat))),verbose=1)),
    error=function(e) {print('this dataframe wasnt usable probably due to multiple colinearities preventing imputation')}
  )
  )
  return(output)
})


output$plot.function<-renderUI({
  choices<-c('Scores Plot'='objplot',
             'Scree Plot'='screeplot',
             'Loadings Plot'='loadplot'
  )
  selectInput('plfx','Choose a function to plot/visualize',choices=choices)
})
output$subset<-renderUI({
  selectInput('subs','Choose which columns to use for your visualization',choices=colnames(dataFrameCreator2()),multiple=TRUE)
})
output$interactive<-renderUI({
  checkboxInput('int','Check if you want interactive plots',value=FALSE)
})
output$dimA<-renderUI({
  numericInput('dim1','First Dimension to plot against',1,1,input$pcs)
})
output$dimB<-renderUI({
  numericInput('dim2','Second Dimension to plot against',1,2,input$pcs)
})
#potentially implement a subset function to subset the variables displayed
output$Visualize<-renderPlot({
  if(is.null(nlpca()))
    return(NULL)
  num<-which(cvimputed()[[2]]%in%input$df2plot)
  df<-nlpca()[[num]]
  plotfx<-memoise(homals:::plot.homals)
  subcols<-which(colnames(dataFrameCreator2())%in%input$subs)
  plot.output<-plotfx(df,plot.dim=c(input$dim1,input$dim2),plot.type=input$plfx,var.subset=subcols,identify=input$int)
  print(plot.output)
  
})
SyndromicPlot<-reactive({
  if (is.null(nlpca())) 
    return(NULL)
 
    tmp<-nlpca()[[which(cvimputed()[[2]]%in%input$df2plot)]]
    i<-input$Pc2Plot
    load<-t(as.data.frame(loadingextractor(tmp$loadings,i)))
    varexp<-input$var.exp
    a<-LoadingSort(load,input$cutoff,input$NumArr)
    b<-FergusonPlotCoordinates(a)
    plot<-FergusonPlot(b,varexp,input$pctitle)
    plot
  
})
output$syndromic<-renderPlot({
  if(is.null(nlpca()))
    return(NULL)
  SyndromicPlot()
  
})
output$FPlot<-renderUI({
  if(is.null(nlpca()))
    return(NULL)
  maxNum<-10
  sliderInput("Pc2Plot","Choose which PC to create your FPlot from",min=1,max=input$pcs,value=1,step=1)
})
output$NumArr<-renderUI({
  if(is.null(nlpca()))
    return(NULL)
  numericInput("NumArr", "Number of Maximum Arrows for Ferg Plot",5,min=2,max=15)
  
})
output$CutOff<-renderUI({
  if(is.null(nlpca())){
    return(NULL)
  }
  numericInput("cutoff","Choose a value of significance for Loadings, between 0-1",0,min=0,max=1)
})
output$varexp<-renderUI({
  if(is.null(nlpca()))
    return(NULL)
  numericInput('var.exp','Type var explaiend by pc',0,min=0,max=1)
})
output$pctitle<-renderUI({
  if(is.null(nlpca()))
    return(NULL)
  textInput('pctitle','Type title for center of Syndromic Plot',value='')
})

output$downloadBplot<-downloadHandler(
  
  filename=function(){paste('FergPlot',toString(input$Pc2Plot),'.pdf',sep='')},
  content=function(file){
    
    ggsave(file, plot = BasicPlot(),width=15,height=10,units="in")
  }
)


output$downloadImputed<-downloadHandler(
  filename=paste('ImputedData','.zip',sep=''),
  content=function(file){
    tmpdir<-tempdir()
    setwd(tempdir())
    print(tempdir())
    fs<-unlist(lapply(cvimputed()[[2]],function(x) paste('imputed_',x,'.csv',sep='')))
    lapply(cvimputed()[[2]],function(x)
      write.csv(listOfImputed()[[which(cvimputed()[[2]]%in%x)]],file=paste('imputed_',x,'.csv',sep=''),sep=',')
      )
    print(fs)
    zip(zipfile=file,files=fs)
    if(file.exists(paste0(file, ".zip"))) {file.rename(paste0(file, ".zip"), file)}
  
  },
  contentType='application/zip'
  
)


  
}
)
