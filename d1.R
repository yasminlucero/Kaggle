## d1.R
## data processing script
## processes d1
## recode smoking status
## August 25 2012

library(car)

# create state division variate
require(datasets)
state.codes = cbind(state.abb, as.character(state.division))
state.codes = rbind(state.codes, c("DC", "South Atlantic"))
state.codes = rbind(state.codes, c("PR", "South Atlantic"))
state.codes = data.frame(state.codes)
names(state.codes)[2] = "division"
d1$Division = d1$State

i.max = dim(d1)[1]
for(i in 1:i.max){
  j = which(as.character(state.codes$state.abb[i]) == d1$State[i])
  d1$Division[i] = as.character(state.codes$division[i])
} # end i loop

# create smoker binary variate
tmp = recode(d1$SmokingStatus_NISTCode, "c(5,9)='NA'; c(0,3,4)='FALSE'; c(1,2)='TRUE'")
d1$Smoker = as.logical(tmp)

#
aggregate(Smoker~Gender + Division, d1, mean)
aggregate(Smoker~Gender + Division, d1, length)

d1$age = 2012-d1$YearOfBirth
d1$age[(d1$age>85)]=85 # bin 85+ group to match census

quartz()
par(mar = c(5, 9, 2, 2) + 0.1)
boxplot(age~Division, d1, col=2, horizontal=TRUE, las=1, varwidth=T, xlab="age (yrs)")


