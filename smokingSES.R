## smokingSES.R
## plot of smoking vs socioeconomic status
##
## Sept 7 2012

require(reshape2)

smokeSES = read.csv("Data/GovData/censusSmokers/smokingbyeducation.txt")
smokeSES$Education =ordered(smokeSES$Education, levels=c("less than equal to 8 yrs","9-11 yrs",  "0-12 yrs (no diploma)", "12 yrs (no diploma)", "GED", "High school graduate", "Some college (no degree)", "Associate degree", "Undergraduate degree", "Graduate degree"))
smokeSES = subset(smokeSES, Education>"12 yrs (no diploma)", select=c("Education","women", "men"))
smokeSES = melt(smokeSES)

qplot(value, Education, data=smokeSES, color=variable)+labs(x="percent smokers", color="")+annotate("segment", x=12, xend=12, y=-Inf, yend=Inf, color="darkgrey", lty="dashed") + annotate("text", x=28, y=5.5, label="rate for EHR population", color="darkgrey")

