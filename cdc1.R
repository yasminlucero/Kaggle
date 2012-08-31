## cdc1.R
## cdc data 
## smoking by sex and state
## August 25 2012

require(reshape2)

smoke.sex.state = read.csv("Data/GovData/statab2008_0193_CurrentCigaretteSmokingBySexAndStat-csv/statab2008_0193_CurrentCigaretteSmokingBySexAndStat_0_Data.csv", skip=8, header=TRUE)
smoke.sex.state$FIPS = NULL
smoke.sex.state$FIPS.1 = NULL
smoke.sex.state = subset(smoke.sex.state, abbreviation!="U.S.")

state.pops = read.csv("Data/GovData/census/statepops.txt", header=TRUE)
pr.pops = read.csv("Data/GovData/census/puertorico.txt", header=TRUE)

div.codes = data.frame(matrix(c(0, "United States Total", 
1, "New England",
2, "Middle Atlantic",
3, "East North Central",
4, "West North Central", 
5, "South Atlantic",
6, "East South Central", 
7, "West South Central", 
8, "Mountain",
9, "Pacific"), 10, 2, byrow=TRUE), stringsAsFactors=FALSE)
names(div.codes) = c("div.number", "div.name")

i.max = dim(state.pops)[1]
state.pops$division = rep(NA, i.max)
for(i in 1:i.max){
  state.pops$division[i] = div.codes$div.name[which(div.codes$div.number==state.pops$DIVISION[i])]
} # end i loop

state.codes.txt = state.codes
state.codes.txt$state.abb = as.character(state.codes.txt$state.abb)
state.codes.txt$division = as.character(state.codes.txt$division)
smoke.sex.state$abbreviation = as.character(smoke.sex.state$abbreviation)
j.max = dim(smoke.sex.state)[1]
smoke.sex.state$division = rep(NA, j.max)
for(j in 1:j.max){
  smoke.sex.state$division[j] = state.codes.txt$division[which(state.codes.txt$state.abb==smoke.sex.state$abbreviation[j])]  
} # end j loop



census.totals = aggregate(POPESTIMATE2011~division, state.pops, sum, subset=AGE==999&SEX==0&SUMLEV==40)

census.melt = melt(subset(state.pops, AGE!=999&SEX!=0&SUMLEV==40), id.vars = c("division", "NAME", "AGE", "SEX"))
census.melt = subset(census.melt, variable=="POPESTIMATE2011")
census.melt$value = as.numeric(census.melt$value)
census.cast = dcast(census.melt, division + NAME + SEX ~ variable, sum)

rm(state.name)
rm(state.abb)
require(datasets)
state.name = c(state.name, "District of Columbia")
state.abb = c(state.abb, "DC")

census.cast$state.abb = as.character(census.cast$NAME)
for(i in 1:dim(census.cast)[1]) census.cast$state.abb[i] = state.abb[which(state.name==as.character(census.cast$NAME[i]))]

census.men = subset(census.cast, SEX==1)
census.women = subset(census.cast, SEX==2)
