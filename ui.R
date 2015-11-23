library(shiny)
library(shinyjs)
source('./SyndromicPlotFunctions.R')

shinyUI(navbarPage('MCA/Mice Visualization',
     tabPanel('Input/Column Choosing',
              sidebarLayout(
                sidebarPanel(
                fileInput('file1','Choose Raw data to input', accept=c('text/csv,','.csv')),
                checkboxInput('impute','Check here if you would like to impute your data',value=FALSE),
                checkboxInput('allcol','Check here to use whole data set/every column')
                
                
                ),
        
              mainPanel(
                
                  
                    uiOutput("FirstStep",align="left",style="color:blue"),
                    uiOutput('CompleteColumnSelector'),
                    uiOutput("SecondStep",align="left",style="color:red"),
                    uiOutput('IncompleteColumnSelector'),
                    tableOutput('dataviewer')

                
              
              )
     )),
     tabPanel('Column Classification',
              fluidPage(
                titlePanel("Categorize between nominal, ordinal, categorical"),
                fluidRow(
                  column(5,
                         h3('Categorical Variables, select these first'),
                         uiOutput('categorical')
                         ),
                  column(5,
                         h3('Continuous Variables, select these second'),
                         selectInput('numerical','Select columns',c('label1'='option1','label2'='option2'),multiple=TRUE),
                         checkboxInput('restContinuous','Check this if the rest of the vars are continuous',value=TRUE)
                     )),
                fluidRow(
                      checkboxInput('printData','Check this to print out your reorganized data table below',value=FALSE),
                      tableOutput('dataviewer2'))
                        
                )
              ),
     tabPanel('Imputation',
              fluidPage(
                titlePanel('Parameters for imputation'),
                fluidRow(
                  column(3,
                         h4('If cat var present, imputeFAMD, else impute PCA'),
                         sliderInput('ncp','Number of dims to use',1,5,value=2),
                         selectInput('method','Method to use, regularized default to prevent overfitting',c('Regularized','EM'),selected='Regularized',multiple=FALSE),
                         shinyjs::useShinyjs(),
                         actionButton('FAMD','Impute FAMD')
                
                        ),
                  column(3,
                         h4('This column is to use MCMC imputation'),
                         sliderInput('num.df','Number of imputed data frames',1,10,value=5),
                         selectInput('catmethod','Method to use for categorical var imputation',c('pmm','norm','norm.nob','norm.boot','mean','2l.norm','2lonly.mean','2lonly.norm','2lonly.pmm','quadratic','logreg','logreg.boot','polyreg','polr','lda','cart','rf','ri','sample','fastpmm'),selected='polr',multiple=FALSE),
                         selectInput('nummethod','Method to use for numerical var imputation', c('pmm','norm','norm.nob','norm.boot','mean','2l.norm','2lonly.mean','2lonly.norm','2lonly.pmm','quadratic','logreg','logreg.boot','polyreg','polr','lda','cart','rf','ri','sample','fastpmm'),selected='pmm',multiple=FALSE),
                         shinyjs::useShinyjs(),
                         actionButton('mice','Impute MCMC'),
                         tableOutput('imputedviewer')
                         )
                  )

                  )
              ),
     tabPanel('MCA',
              fluidPage(
                titlePanel('Where the magic happens, a NLPCA on click'),
                tabsetPanel('Visualizations',
                            tabPanel('Visualizations',
                                     column(3,
                                            numericInput('pcs','Number of Principal Components to use',3,2,10),
                                            actionButton('nlpca','Compute NLPCA'),
                                            h6('These are for controlling visualizations of the nlpca'),
                                            uiOutput('df2use'),
                                            uiOutput('plot.type'),
                                            uiOutput('plot.function'),
                                            uiOutput('subset'),
                                            uiOutput('dimA'),
                                            uiOutput('dimB'),
                                            uiOutput('interactive')
                                     ),
                                     column(8,
                                            plotOutput('Visualize')
                                            )
                                     ),
                            tabPanel('Syndromic Plot',
                                     column(3,
                                            uiOutput("FPlot"),
                                            uiOutput("CutOff"),
                                            uiOutput("NumArr"),
                                            uiOutput("varexp"),
                                            uiOutput('pctitle'),
                                            downloadButton('downloadBplot','Download this plot')
                                            ),
                                     column(8,
                                            plotOutput('syndromic')
                                            )
                                     )
                            )
               
                  
                )
              )
              )
  
                
              
             
     
     
     
  
  
  
  
)