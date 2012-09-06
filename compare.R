## compare.R
## processing script
## prepares d2 to be compared to state.df
## performs comparisons
## depends on kaggle_setup.R, d2.R, govdata.R
## Sept 4 2012

## environment setup
# rm(list=ls())
# setwd("~/Work/Kaggle/")
# source("kaggle_setup.R")
 source("govdata.R")
# source("d2.R")

# state region names
tmp = state.df[,1:4]
tmp$state.division = as.character(tmp$state.division)
names(d5)[which(names(d5)=="State")] = "state.abb"
names(d1)[which(names(d1)=="State")] = "state.abb"
names(d2)[which(names(d2)=="State")] = "state.abb"
d2 = merge(tmp, d2)
d1 = merge(tmp, d1)
d5 = merge(tmp, d5)

## obesity rate
d2$obese = d2$BMI>29

## smokers
smoketmp = recode(d1$SmokingStatus_NISTCode, "c(5,9)='NA'; c(0,3,4)='FALSE'; c(1,2)='TRUE'")
d1$Smoker = as.logical(smoketmp)
state.df$smokers.total = state.df$smokers.total/100
state.df$smokers.male = state.df$smokers.male/100
state.df$smokers.female = state.df$smokers.female/100

## d2 setup for comparisons: states
state.df$popprop = state.df$population/sum(state.df$population)

EHR.population.state  = aggregate(PatientGuid~state.name, data=d5, length)

EHR.diabetics.state  = aggregate(dmIndicator~state.name+PatientGuid, data=d2, mean)
EHR.diabetics.state  = aggregate(dmIndicator~state.name, data=EHR.diabetics.state, mean)
EHR.obesity.state  = aggregate(obese~state.name+PatientGuid, data=d2, mean)
EHR.obesity.state  = aggregate(obese~state.name, data=EHR.obesity.state, mean)
EHR.smoking.state  = aggregate(Smoker~state.name+PatientGuid, data=d1, mean)
EHR.smoking.state  = aggregate(Smoker~state.name, data=EHR.smoking.state, mean)
EHR.smokingM.state  = aggregate(Smoker~state.name+Gender+PatientGuid, data=d1, mean)
EHR.smokingF.state = subset(EHR.smokingM.state, Gender=="F", select=c("state.name", "Smoker", "PatientGuid"))
EHR.smokingM.state = subset(EHR.smokingM.state, Gender=="M", select=c("state.name", "Smoker", "PatientGuid"))

EHR.smokingM.state  = aggregate(Smoker~state.name, data=EHR.smokingM.state, mean)
EHR.smokingF.state  = aggregate(Smoker~state.name, data=EHR.smokingF.state, mean)
names(EHR.smokingM.state)[2] = "ehr.smokerM.state"
names(EHR.smokingF.state)[2] = "ehr.smokerF.state"

compare.state = merge(tmp, EHR.diabetics.state, all.x=TRUE)
compare.state = merge(compare.state, EHR.obesity.state, all.x=TRUE)
compare.state = merge(compare.state, EHR.smoking.state, all.x=TRUE)
compare.state = merge(compare.state, EHR.smokingM.state, all.x=TRUE)
compare.state = merge(compare.state, EHR.smokingF.state, all.x=TRUE)
compare.state = merge(compare.state, EHR.population.state, all.x=TRUE)

names(compare.state)[which(names(compare.state)=="dmIndicator")] = "ehr.diabetes.proportion"
names(compare.state)[which(names(compare.state)=="obese")] = "ehr.obese.proportion"
names(compare.state)[which(names(compare.state)=="Smoker")] = "ehr.smoker.proportion"
names(compare.state)[which(names(compare.state)=="PatientGuid")] = "ehr.population"

state.df = merge(state.df, compare.state[,-c(2:4)], by="state.name")
state.df$ehr.proportion = state.df$ehr.population/9916

## d2 setup for comparisons: division
EHR.diabetics.division  = aggregate(dmIndicator~state.division, data=d2, mean)
EHR.obesity.division  = aggregate(obese~state.division, data=d2, mean)
EHR.smoking.division  = aggregate(Smoker~state.division+Gender, data=d1, mean)
EHR.smokingM.division = subset(EHR.smoking.division, Gender=="M", select=c("state.division", "Smoker"))
EHR.smokingF.division = subset(EHR.smoking.division, Gender=="F", select=c("state.division", "Smoker"))
EHR.smoking.division  = aggregate(Smoker~state.division, data=d1, mean)

general.diabetics.division = aggregate(diabetic*weights~state.division, data=state.df, sum)
general.obesity.division = aggregate(obesityRate*weights~state.division, data=state.df, sum)
general.smoking.division = aggregate(smokers.total*weights~state.division, data=state.df, sum)
general.smokingM.division = aggregate(smokers.male*weights~state.division, data=state.df, sum)
general.smokingF.division = aggregate(smokers.female*weights~state.division, data=state.df, sum)

general.popprop.division = aggregate(population~state.division, data=state.df, sum)
general.popprop.division$population = general.popprop.division$population/sum(state.df$population)
names(general.popprop.division)[2] = "popprop"
