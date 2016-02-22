# NLPCA-Viz
![alt tag](https://zenodo.org/badge/20544/pavan8632/NLPCA-Viz.svg)

This is a basic application meant to do data imputation and perform an Non-Linear Principal Component. This is an R Shiny Application that requires R and will install numerous dependencies to make run. Run the following to bring up the applet on your computer. 

''' 
install.packages('shiny')
library(shiny)
runGitHub('NLPCA-Viz','pavan8632')
'''

###News about NLPCA-Viz
The first iteration is in use and capable of taking you through all steps from initial input of a .csv file to a visualization of the multiple imputed data sets and a novel visualization developed by the Ferguson Lab in UCSF's Brain and Spinal Injury Center. Future iterations will take this framework and port the R-Shiny application to an open source, PHP/JS driven webpage that optimizes efficiency.  

#### Outline of Workflow
First input a file, in a .csv format, using the sidebar on the left. Then you can choose functions to apply to parse and filter your data. The first tab allows the user to remove columns with no variance(No Vary) and remove columns and rows with only NA values (NA Col, NA Row)

Second, the user can choose which columns to use for the imputation by choosing column names and then viewing their final data table. 

Third, the user is told to classify their columns as either categorical or numerical variables. This is important for the NL-PCA and imputation techniques.

Fourth, the user can use two methods of imputation. An iterative PCA based approach, and a Monte-Carlo Multiple Chained Equation approach. All data tables are stored and the user can view summary statistics of each. 

In the final tab, the user can choose the datatable to use -- either the original data or one of the imputed data sets and run an NL-PCA. The NL-PCA used is an extension of the homals packaged published by the GIFI group. https://cran.r-project.org/web/packages/homals/index.html All visualizations and data tables used are downloadable for reproducibility and publishing. 
