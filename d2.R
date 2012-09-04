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

p <- qplot(age.bin, BMI, data=subset(d2.ss, !is.na(age.bin)), fill=dmIndicator2, geom="boxplot", position="dodge", ylim=c(15,50), aes(linetype="dotted"), main="Compare BMI for diabetics vs. non-diabetics in the EHR population") + facet_grid(Gender2~.)
p + annotate("rect", ymin=18.5, ymax=25, xmin=-Inf, xmax=Inf, alpha=0.2) + labs(x="Age group", y="BMI", fill="") + annotate("text", x=2.5, y=22, label="healthy target range for BMI")

p3 <- qplot(BMI, data = subset(d2.ss, !is.na(age.bin)), geom="histogram", fill=age.bin) + facet_grid(.~dmIndicator2)
p3 + annotate("rect", xmin = 18.5, xmax = 25, ymin = -Inf, ymax = Inf, alpha=0.2)

#p3 = p3 + annotate("rect", xmin=1, xmax=5, ymin=0, ymax=1005, alpha=0.2, color="red") 
#p3 = + annotate("rect", xmin=1, xmax=5, ymin=1005, ymax=2180, alpha=0.2, fill="green") 
#p3 = + annotate("rect", xmin=1, xmax=5, ymin=2180, ymax=3746, alpha=0.2, fill="blue") 
#p3 = + annotate("rect", xmin=1, xmax=5, ymin=3746, ymax=4491, alpha=0.2, fill="purple")

