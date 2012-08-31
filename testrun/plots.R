# plots.R
# The best plots

p <- qplot(age.bin, BMI, data=subset(d2.ss, !is.na(age.bin)), fill=dmIndicator2, geom="boxplot", position="dodge", ylim=c(15,50), aes(linetype="dotted"), main="Compare BMI for diabetics vs. non-diabetics in the EHR population") + facet_grid(Gender2~.)
p + annotate("rect", ymin=18.5, ymax=25, xmin=-Inf, xmax=Inf, alpha=0.2) + labs(x="Age group", y="BMI", fill="") + annotate("text", x=2.5, y=22, label="healthy target range for BMI")
