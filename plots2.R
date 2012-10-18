## plots2.R
## make some plots
## make a map
## depends on state.df from govdata.R
## Sept 3 2012

require(maps)
require(RColorBrewer)
library(ggplot2)
library(scales)
library(car)

# map1: divisions
mapofstates=map_data("state")
alaska = map_data("world")
hawaii = subset(alaska, region=="Hawaii")
hawaii$region = tolower(hawaii$region)
alaska = subset(alaska, subregion=="Alaska")
alaska$region = tolower(alaska$subregion)

names(mapofstates)[5] = "lower.state"
names(alaska)[5] = "lower.state"
names(hawaii)[5] = "lower.state"

mapofstates=merge(mapofstates, state.df)
alaska = merge(alaska, state.df)
hawaii = merge(hawaii, state.df)

test = rbind(alaska, hawaii, mapofstates)

qplot(long, lat, data=test, geom="polygon", group=group, fill=state.division)
qplot(long, lat, data=mapofstates, geom="polygon", group=group, fill=state.division)
qplot(long, lat, data=mapofstates, geom="polygon", group=group, fill=state.division) + scale_fill_brewer(palette="Spectral")
qplot(long, lat, data=hawaii, geom="polygon", group=group, fill=state.division) + scale_fill_brewer(palette="Spectral")
qplot(long, lat, data=alaska, xlim=c(-200, -130), geom="polygon", group=group, fill=state.division) + scale_fill_brewer(palette="Spectral")

# map 2: represenativeness
state.df$representativeness = state.df$ehr.proportion - state.df$popprop
mapofstates=map_data("state")
names(mapofstates)[5] = "lower.state"
mapofstates=merge(mapofstates, state.df)
qplot(long, lat, data=mapofstates, geom="polygon", group=group, fill=representativeness, main="Distribution of EHR patients among states vs general population") + scale_fill_gradient(low="red", high="green", breaks=c(-0.02, 0, 0.02, 0.04, 0.06), labels=c("under represented", "well represented", "", "over represented", ""), na.value="red")+labs(fill="")

tmpStatepops = subset(state.df, select=c("state.name", "population", "popprop", "ehr.proportion"))
tmpStatepops = melt(tmpStatepops, id.vars=c("state.name", "population"))
tmpStatepops$state.name = ordered(tmpStatepops$state.name, levels=tmpStatepops$state.name[order(tmpStatepops$population, decreasing=TRUE)])
tmpStatepops$variable = recode(tmpStatepops$variable, "'popprop'='general'; 'ehr.proportion'= 'EHR patients'")
qplot(value, state.name, data=tmpStatepops, color=variable)+labs(x="proportion of population in state", y="state", color="population")


# age distributions w/ BMI
tmp.bmi = subset(d2, subset=!is.na(age.bin), select=c("age", "age.bin", "BMI", "dmIndicator2","dmIndicator", "Gender2", "PatientGuid"))
tmp.bmi$bmi.bin = cut(tmp.bmi$BMI, c(14:50), c(15:50))
tmpPropbmi = aggregate(dmIndicator~bmi.bin, tmp.bmi, mean)
tmp.bmi$age.bin = as.ordered(tmp.bmi$age.bin)
tmp.bmi = aggregate(BMI~PatientGuid+age.bin+dmIndicator2+Gender2, tmp.bmi, mean) 
tmp.bmi = aggregate(age.bin~PatientGuid+dmIndicator2+Gender2+BMI, tmp.bmi, max) 

qplot(age.bin, BMI, data=tmp.bmi, fill=dmIndicator2, geom="boxplot", position="dodge", ylim=c(15,50), aes(linetype="dotted"), main="Compare BMI for diabetics vs. non-diabetics in the EHR population") + facet_grid(Gender2~.) +labs(fill="", x="Age")

qplot(BMI, data = tmp.bmi, geom="histogram", fill=age.bin) + facet_grid(.~dmIndicator2)+ labs(x="BMI of EHR population", y="# of patients", fill="Age") 

tmpPropbmi$bmi.bin= as.numeric(as.character(tmpPropbmi$bmi.bin))
qplot(bmi.bin, dmIndicator, data=tmpPropbmi, geom = c("point", "smooth"), main="Proportion diabetic of patients with a given BMI") + labs(x="BMI", y="proportion diabetic")

# diabesity in high BMI group
csBMI = data.frame(matrix(seq(from=15,to=50), 36, 3))
names(csBMI) = c("BMI", "diabetic", "nondiabetic")
i.max=dim(csBMI)[1]
for(i in 1:i.max){
  csBMI[i,2:3] = table(subset(tmp.bmi, BMI>csBMI$BMI[i])$dmIndicator)
}#
propBMI = csBMI
propBMI$proportionD = csBMI$diabetic/(csBMI$diabetic + csBMI$nondiabetic)
csBMI = melt(csBMI, id.vars="BMI")

ggplot(data=csBMI, aes(x=BMI, y=value, fill=variable), main="test") + geom_bar(stat="identity")+labs(fill="", x="BMI threshold", y="# of EHR patients") + opts(title="Number of patients with BMI greater than BMI threshold") + annotate("segment", x=25, xend=25, y=-Inf, yend=Inf)+ annotate("segment", x=30, xend=30, y=-Inf, yend=Inf)+ annotate("segment", x=35, xend=35, y=-Inf, yend=Inf)+ annotate("segment", x=40, xend=40, y=-Inf, yend=Inf) + annotate("text", x=27.5, y=9700, label="overweight")+ annotate("text", x=32.5, y=9700, label="obese 1")+ annotate("text", x=37.5, y=9700, label="obese 2")+ annotate("text", x=42.5, y=9700, label="obese 3")
                                                                                                                                                                                                                                

ggplot(data=subset(csBMI, BMI>40), aes(x=BMI, y=value, fill=variable), main="test") + geom_bar(stat="identity")+labs(fill="", x="BMI threshold", y="# of EHR patients") + opts(title="Number of patients with BMI greater than BMI threshold")

qplot(BMI,proportionD, data=propBMI, main="proportion diabetic of patients with BMI above threshold")+labs(y="proportion diabetic", x="BMI threshold")


# population representativeness
qplot(popprop, ehr.proportion, data=state.df, size=diabetic, color=smokers.total, main="population proportions in each state")+annotate("segment", x=0, xend=.2, y=0, yend=.2, color="grey") + labs(x="general population", y="EHR population", size="diabetics", color="smokers")+scale_colour_gradient(low="green", high="purple") + annotate("text", x=0.09, y=0.12, label="1:1 line", color="darkgrey")

# diabetes
nat.avg = sum(state.df$popprop*state.df$diabetic)
qplot(diabetic, ehr.diabetes.proportion, data=state.df, color=population, size=ehr.population, main="State by state comparison of rates of diabetes in EHR vs general population")+annotate("segment", x=0.05, xend=.16, y=0.05, yend=.16, color="darkgrey")+scale_colour_gradient(low="blue", high="red")+labs(x="proportion of overall state population with diabetes", y="proportion of EHR patients with diabetes", size="# of EHR patients", color="state population")+annotate("segment", x=nat.avg, xend=nat.avg, y=-Inf, yend=Inf, lty="dashed")+annotate("text", x=.13, y=.16, label="1:1 line", color="darkgrey")#+annotate("text", x=nat.avg+.011, y=0.65, label="national average rate")

# obesity
qplot(obesityRate, ehr.obese.proportion, data=state.df, color=population, size=ehr.population, main="State by state comparison of rates of obesity (BMI>30) in EHR vs general population")+annotate("segment", x=0.2, xend=.35, y=0.2, yend=.35, color="darkgrey")+scale_colour_gradient(low="blue", high="red")+labs(x="rate of obesity in general population", y="rate of obeisty in EHR population", size="# of EHR patients", color="state population")+annotate("text", x=.32, y=.3, label="1:1 line", color="darkgrey")#+annotate("text", x=nat.avg+.011, y=0.65, label="national average rate")

# smoking
tmpSmoke = state.df
tmpSmoke$smokeGender=tmpSmoke$ehr.smokerF.state
tmpSmoke$Gender = rep("F", dim(tmpSmoke)[1])
tmpSmoke$smokeGender.gen = tmpSmoke$smokers.female
tmpSmokeM = tmpSmoke
tmpSmokeM$smokeGender = tmpSmoke$ehr.smokerM.state
tmpSmokeM$Gender = rep("M", dim(tmpSmoke)[1])
tmpSmoke$smokeGender.gen = tmpSmoke$smokers.male
tmpSmoke = rbind(tmpSmoke, tmpSmokeM)
tmpSmoke$smokeGender[which(tmpSmoke$smokeGender>0.8)]=NA
qplot(smokeGender.gen, smokeGender, data=tmpSmoke,size=ehr.population, color=Gender, main="State by state comparison of smoking rates of EHR vs general population") + annotate("segment", x=.1, y=.1, xend = .3, yend=.3, color="grey") + scale_color_hue(h=c(0, 90)) +labs(x="rate of smoking in general population", y="rate of smoking in EHR population")+annotate("text", x=.13, y=.16, label="1:1 line", color="darkgrey")

# Age distribution
tmp.age = subset(censusStatePops, select=c("AGE", "POPESTIMATE2011"), subset=SUMLEV==10&SEX==0&AGE!=999&AGE!=85)
ehr.age = table(2012-d5$YearOfBirth)
ehr.age=as.data.frame(ehr.age)
names(ehr.age)=c("AGE", "ehr")
tmp.age = merge(tmp.age, ehr.age, all.x=TRUE)
tmp.age$ehr[is.na(tmp.age$ehr)] = 0
tmp.age$percent.general = tmp.age$POPESTIMATE2011/sum(tmp.age$POPESTIMATE2011) 
tmp.age$percent.ehr = tmp.age$ehr/sum(tmp.age$ehr, na.rm=TRUE)
tmp.age$cumsum.ehr = cumsum(tmp.age$percent.ehr)
tmp.age$cumsum.general = cumsum(tmp.age$percent.general)
age.melt1 = melt(tmp.age, id.vars=c("AGE", "POPESTIMATE2011", "ehr", "cumsum.ehr", "cumsum.general"))
age.melt1$value = age.melt1$value*100
age.melt2 = melt(tmp.age, id.vars=c("AGE", "POPESTIMATE2011", "ehr", "percent.ehr", "percent.general"))
age.melt2$value = age.melt2$value*100
qplot(AGE, value, data=age.melt1, color=variable, geom=c("smooth", "point")) + scale_color_hue(h=c(20,100), labels=c("general", "EHR"))+labs(x="age", y="percentage of population", color="population")
qplot(AGE, value, data=age.melt2, color=variable, geom=c("line"))  + scale_color_hue(h=c(100, 20), labels=c("EHR", "general"))+labs(x="age", y="cumulative percentage of population", color="population")

# plot medical utilization/visits
tmp = melt(md1, measure.vars=c("count.medication", "count.diagnosis", "count.transcript"))
tmp$variable = recode(tmp$variable, "'count.medication'='medications'; 'count.diagnosis'='diagnoses'; 'count.transcript'='doctor visits'")
tmp$Smoker = recode(tmp$Smoker, "TRUE='smoker'; FALSE='nonsmoker'; else=NA")
tmp = subset(tmp, !is.na(Smoker))
qplot(Smoker, value, data=tmp, facets=.~variable, geom="boxplot", fill=Smoker, ylim=c(0, 20)) + scale_fill_hue(h.start=100) + labs(x="", y="count", fill="")
qplot(dmIndicator2, value, data=tmp, facets=.~variable, geom="boxplot", fill=dmIndicator2, ylim=c(0, 20)) + scale_fill_hue(h.start=0) + labs(x="", y="count", fill="")

# word cloud diabetics
test = subset(d2, dmIndicator)
test=table(test$PhysicianSpecialty)
test=sort(test, decreasing=T)
test=test[-c(1:5)]
wordcloud(names(test), test,c(2,.2), color=brewer.pal(9,"BuGn")[-c(1:4)])

# word cloud smoker
tmp = merge(d1,d2)
tmp = subset(tmp, Smoker)
tmp=table(tmp$PhysicianSpecialty)
tmp=sort(tmp, decreasing=T)
tmp=tmp[-c(1:4, 8)]
wordcloud(names(tmp), tmp,c(2,.2), color=brewer.pal(9,"BuGn")[-c(1:4)])
