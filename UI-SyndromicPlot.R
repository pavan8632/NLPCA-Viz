library(shiny)
source('./SyndromicPlotFunctions.R')

shinyUI(navbarPage('MCA/Mice Visualization',
     tabPanel('Input/Imputation',
              sidebarLayout(
                sidebarPanel(
                fileInput('file1','Choose Raw data to input', accept=c('text/csv,','.csv'))
              )
              )
     ),
     tabPanel('MCA'),
     tabPanel('Visualization and Syndromic Plot')
     
  
  
  
  
))