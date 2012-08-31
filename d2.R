## d2.R
## plotting script
## depends on output of kaggle_setup.R
## August 29 2012

library(ggplot2)
library(scales)
library(car)

d2$age = d2$VisitYear - d2$YearOfBirth
d2$age[d2$age<10] = NA
d2$age.bin = cut(as.numeric(d2$age), c(10, 30, 45, 65, 100), c("18-29","30-44", "45-64", "65+"))
d2$Gender2 = recode(d2$Gender, "'M'='Men'; 'F'='Women'; else=NA")
d2$dmIndicator2 = recode(d2$dmIndicator, "TRUE='diabetic'; FALSE='non-diabetic'; else=NA")
d2.ss = subset(d2, Weight<400 & Weight>60 & Height>48 & Height<96)



qplot(age.bin, Weight, data=d2.ss, fill=dmIndicator2, geom="boxplot", position="dodge", facets=Gender~.)
qplot(age.bin, Weight, data=subset(d2.ss, !is.na(age.bin)), fill=dmIndicator, geom="boxplot", position="dodge", facets=Gender~., ylab="Weight (lbs)", xlab="Age group", ylim=c(100,300))

p <- qplot(age.bin, BMI, data=subset(d2.ss, !is.na(age.bin)), fill=dmIndicator2, geom="boxplot", position="dodge", ylim=c(15,50), aes(linetype="dotted"), main="Compare BMI for diabetics vs. non-diabetics in the EHR population") + facet_grid(Gender2~.)
p + annotate("rect", ymin=18.5, ymax=25, xmin=-Inf, xmax=Inf, alpha=0.2) + labs(x="Age group", y="BMI", fill="") + annotate("text", x=2.5, y=22, label="healthy target range for BMI")

p2 <- qplot(dmIndicator, BMI, data=subset(d2.ss, !is.na(age.bin)), fill=dmIndicator, geom="boxplot", ylim=c(15,50)) + facet_grid(Gender~age.bin)
p2 + annotate("rect", ymin=18.5, ymax=25, xmin=-Inf, xmax=Inf, alpha=0.2) + labs(x="", y="BMI", fill="diabetic?")

p3 <- qplot(BMI, data = subset(d2.ss, !is.na(age.bin)), geom="histogram", fill=age.bin) + facet_grid(.~dmIndicator2)
p3 + annotate("rect", xmin=18.5, xmax=25, ymin=-Inf, ymax=Inf, alpha=0.2) + annotate("text", y=6000, x=50, label="") 


boxplot(as.numeric(YearOfBirth)~dmIndicator, d2, subset=Weight<600 & Weight>60 & Height>48 & Height<96, pch=20, xlab="Diabetes Melitus?", ylab="Year of Birth", las=1)

boxplot(BMI~dmIndicator+Gender, d2, subset=Weight<600 & Weight>60 & Height>48 & Height<96, pch=20, horizontal=FALSE, las=1, ylim=c(5,60), xlab="Diabetes? by gender", ylab="BMI")

boxplot(Weight~dmIndicator+Gender, d2, subset=Weight<600 & Weight>60 & Height>48 & Height<96, pch=20, horizontal=FALSE, las=1, xlab="Diabetes? by gender", ylab="Weight (lbs)")

boxplot(Weight~dmIndicator + age.bin, d2, subset= Gender=="M" & Weight<600 & Weight>60 & Height>48 & Height<96, pch=20, horizontal=FALSE, las=1, xlab="Diabetes? by gender", ylab="Weight (lbs)")
title("Males")
boxplot(Weight~dmIndicator + age.bin, d2, subset= Gender=="F" & Weight<600 & Weight>60 & Height>48 & Height<96, pch=20, horizontal=FALSE, las=1, xlab="Diabetes? by gender", ylab="Weight (lbs)")
title("Females")

boxplot(age~dmIndicator+Gender, d2, subset=Weight<600 & Weight>60 & Height>48 & Height<96, pch=20, xlab="Diabetes Melitus?", ylab="age", las=1)


