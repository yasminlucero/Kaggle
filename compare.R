## compare.R
## processing script
## prepares d2 to be compared to state.df
## performs comparisons
## depends on kaggle_setup.R, d2.R, govdata.R
## Sept 4 2012

## environment setup
rm(list=ls())
setwd("~/Work/Kaggle/")
source("kaggle_setup.R")
source("d2.R")
source("govdata.R")

## d2 setup for comparisons
