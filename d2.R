## d2.R
## plotting script
## depends on output of kaggle_setup.R, govdata.R
## August 29 2012

require(car)

# age
d2$age = d2$VisitYear - d2$YearOfBirth
d2$age[d2$age<10] = NA
d2$age.bin = cut(as.numeric(d2$age), c(10, 30, 45, 65, 100), c("18-29","30-44", "45-64", "65+"))

# new names for some factors
d2$Gender2 = recode(d2$Gender, "'M'='Men'; 'F'='Women'; else=NA")
d2$dmIndicator2 = recode(d2$dmIndicator, "TRUE='diabetic'; FALSE='non-diabetic'; else=NA")

# subsetting
d2 = subset(d2, State!="PR")

# subsetting
d2 = subset(d2, Weight<400 & Weight>60 & Height>48 & Height<96)

write.csv(d2, file="Data/d2.csv", row.names=FALSE)



