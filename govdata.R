## govdata.R
## data import and processing script
## import all of the government data
## set up a table to work with
## August 31 2012

#rm(list=ls())
setwd("~/Work/Kaggle/Data/GovData")
require(datasets)
require(reshape2)

# read in files
cdcBMI = read.csv("cdcBMI/cdcBMIdata/2007-2008-csv-export-table.csv")
cdcObesity = read.csv("cdcBRFSS/obesityratebystate.txt", stringsAsFactors=FALSE)
censusStatePops = read.csv("censusPopulations/statepops.txt")

kaiserDiabetes = read.csv("KaiserDiabetes/Percent_of_Adults_Who_Have_Ever_Been_Told_by_a_Doctor_that_They_Have_Diabetes.csv", skip=10, stringsAsFactors=FALSE)
kaiserStateLaws = read.csv("KaiserDiabetes/State_Smoking_Restrictions_for_Worksites,_Restaurants,_and_Bars.csv", colClasses=c("character", "factor", "factor", "factor"), skip=11)
smoke.state = read.csv("statab2008_0193_CurrentCigaretteSmokingBySexAndStat-csv/statab2008_0193_CurrentCigaretteSmokingBySexAndStat_0_Data.csv", skip=8, colClasses=c("character", "character", "integer","integer", "numeric", "numeric", "numeric"))

# set up state relation table
data(state)
state.df = data.frame(state.abb, state.name, state.division, stringsAsFactors=FALSE)
state.df = rbind(state.df, c("DC", "District of Columbia", "South Atlantic"))
state.df$lower.state = tolower(state.df$state.name)

# a little processing
names(kaiserDiabetes) = c("state.name", "diabetic", "gestational_diabetic", "non-diabetic", "pre-diabetic")
names(kaiserStateLaws)[1] =  "state.name"
smoke.state= smoke.state[,-c(2,3,4)]
names(smoke.state) = c("state.name", "smokers.total", "smokers.male", "smokers.female")

# aggregate age bins in census data
censusStatePops$age.bin = cut(censusStatePops$AGE, c(-1,18,30,45,65,85,1000), c("minors", "A.18to29", "A.30to44", "A.45to64", "A.65plus", "all.ages"))

# make table
state.df = merge(state.df, kaiserDiabetes)
state.df = merge(state.df, kaiserStateLaws)
state.df = merge(state.df, smoke.state)
state.df = merge(state.df, cdcObesity)

tmp = subset(censusStatePops, SUMLEV==40&SEX==0&AGE==999, select=c(NAME, POPESTIMATE2011))
names(tmp) = c("state.name", "population")
state.df = merge(state.df, tmp)

tmp = subset(censusStatePops, SUMLEV==40&SEX==0&AGE!=999, select=c(NAME, age.bin, POPESTIMATE2011))


tmp = aggregate(population~state.division, state.df, sum)
names(tmp)[2] = "division.population"

state.df = merge(state.df, tmp)
state.df$weights = state.df$population/state.df$division.population

# aggregate age into bins 
tmp = aggregate(POPESTIMATE2011~age.bin + NAME, censusStatePops, sum, subset=AGE!=999&SUMLEV==40&SEX==0)
tmp = melt(tmp)
tmp = dcast(tmp, NAME~age.bin)
names(tmp)[1] = "state.name"
tmp$state.name = as.character(tmp$state.name)
tmp = tmp[,-2]
state.df = merge(state.df, tmp)

# aggregate into age bins and gender 
tmp = aggregate(POPESTIMATE2011~age.bin + NAME, censusStatePops, sum, subset=AGE!=999&SUMLEV==40&SEX==1)
tmp = melt(tmp)
tmp = dcast(tmp, NAME~age.bin)
names(tmp)[1] = "state.name"
tmp$state.name = as.character(tmp$state.name)
tmp = tmp[,-2]
names(tmp)[-1] = paste("M", names(tmp)[-1], sep=".")
state.df = merge(state.df, tmp)

tmp = aggregate(POPESTIMATE2011~age.bin + NAME, censusStatePops, sum, subset=AGE!=999&SUMLEV==40&SEX==2)
tmp = melt(tmp)
tmp = dcast(tmp, NAME~age.bin)
names(tmp)[1] = "state.name"
tmp$state.name = as.character(tmp$state.name)
tmp = tmp[,-2]
names(tmp)[-1] = paste("F", names(tmp)[-1], sep=".")
state.df = merge(state.df, tmp)

tmp = subset(censusStatePops, subset=AGE==999&SUMLEV==40&SEX==2, select=c("NAME", "POPESTIMATE2011"))
names(tmp) = c("state.name", "FemalePopulation")
state.df = merge(state.df, tmp)

tmp = subset(censusStatePops, subset=AGE==999&SUMLEV==40&SEX==1, select=c("NAME", "POPESTIMATE2011"))
names(tmp) = c("state.name", "MalePopulation")
state.df = merge(state.df, tmp)

setwd("~/Work/Kaggle/")

