library(shiny)
library(shinyjs)
library(shinythemes)
source('./SyndromicPlotFunctions.R')

shinyUI(navbarPage('Non-linear PCA and Data Imputation',
     theme=shinytheme('cerulean'),
     tabPanel('Input/Column Choosing',
              sidebarLayout(
                sidebarPanel(
                fileInput('file1','Choose Raw data to input', accept=c('text/csv,','.csv')),
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
                         uiOutput('categorical'),
                         checkboxInput('restCategorical','Check this if the rest of the vars are categorical',value=FALSE),
                         checkboxInput('printData','Check this to print out your reorganized data table below',value=FALSE)
                         ),
                  column(5,
                         h3('Continuous Variables, select these second'),
                         selectInput('numerical','Select columns',c('label1'='option1','label2'='option2'),multiple=TRUE),
                         checkboxInput('restContinuous','Check this if the rest of the vars are continuous',value=TRUE)
                     )),
                fluidRow(
                      tableOutput('dataviewer2'))
                        
                )
              ),
     tabPanel('Imputation',
              fluidPage(
                titlePanel('Parameters for imputation'),
                fluidRow(
                  column(3,
                         h4('This row contains parameters for PCA imputation'),
                         shinyjs::useShinyjs(),
                         actionButton('FAMD','Impute FAMD')
                  ),
                  column(3,
                         sliderInput('ncp','Number of dims to use',1,5,value=2)
                  ),
                  column(3,
                         selectInput('method','Method to use, regularized default to prevent overfitting',c('Regularized','EM'),selected='Regularized',multiple=FALSE)
                         
                         )
                  
                        
                
                        ),
                fluidRow(
                  column(3,
                         h4('This row contains parameters to use MCMC imputation'),
                         shinyjs::useShinyjs(),
                         actionButton('mice','Impute MCMC')
                  ),
                  column(3,
                         sliderInput('num.df','Number of imputed data frames',1,10,value=5)
                         ),
                  column(3,
                         selectInput('catmethod','Method to use for categorical var imputation',c('pmm','norm','norm.nob','norm.boot','mean','2l.norm','2lonly.mean','2lonly.norm','2lonly.pmm','quadratic','logreg','logreg.boot','polyreg','polr','lda','cart','rf','ri','sample','fastpmm'),selected='polr',multiple=FALSE)
                         
                         ),
                  column(3,
                         selectInput('nummethod','Method to use for numerical var imputation', c('pmm','norm','norm.nob','norm.boot','mean','2l.norm','2lonly.mean','2lonly.norm','2lonly.pmm','quadratic','logreg','logreg.boot','polyreg','polr','lda','cart','rf','ri','sample','fastpmm'),selected='pmm',multiple=FALSE)
                        
                         )
                         
                       
                         ),
                fluidRow(
                         tableOutput('imputedviewer')
                        ),
                fluidRow(
                  column(3,
                         downloadButton('downloadImputed','Download all imputed datasets')
                    
                  )
                  
                )
                  )

                  
              ),
     tabPanel('NLPCA/Visualization',
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