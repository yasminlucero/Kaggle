## kaggle_setup.R
## data import script
## connects to sqlite db
## pulls in dataframes
## August 25 2012 

rm(list=ls())
setwd("~/Work/Kaggle/Data/")
library("RSQLite")

m = dbDriver("SQLite")
con <- dbConnect(m, dbname = "compDataAsSQLiteDB/compData.db")

# get ptprofile query
mq1 <- dbSendQuery(con, "select * from ptprofile")
md1 <- fetch(mq1, n = -1)
dbHasCompleted(mq1)
dbClearResult(mq1)
md1 = md1[,-c(6,7,9,11,13)]
names(md1)[6:9]= c("count.condition", "count.medication", "count.diagnosis", "count.transcript")

# get condition table
mq2 <- dbSendQuery(con, "select * from condition")
condition.df <- fetch(mq2, n = -1)
dbHasCompleted(mq2)
dbClearResult(mq2)

# get diagnosis table
mq3 <- dbSendQuery(con, "select * from training_diagnosis")
diagnosis.df <- fetch(mq3, n = -1)
dbHasCompleted(mq3)
dbClearResult(mq3)

# get smoking status query
q1 <- dbSendQuery(con, "select * from training_smoke")
d1 <- fetch(q1, n = -1)
dbHasCompleted(q1)
dbClearResult(q1)

# get patient transcripts
q2 <- dbSendQuery(con, "select * from training_patientTranscript")
d2 <- fetch(q2, n = -1)
dbHasCompleted(q2)
dbClearResult(q2)

d2$Height = as.numeric(d2$Height)
d2$dmIndicator = as.logical(d2$dmIndicator)

# get labs
q3 <- dbSendQuery(con, "select * from training_labs")
d3 <- fetch(q3, n = -1)
dbHasCompleted(q3)
dbClearResult(q3)

# get meds
q4 <- dbSendQuery(con, "select * from training_allMeds")
d4 <- fetch(q4, n = -1)
dbHasCompleted(q4)
dbClearResult(q4)

# get patient
q5 <- dbSendQuery(con, "select * from training_patient")
d5 <- fetch(q5, n = -1)
dbHasCompleted(q5)
dbClearResult(q5)


# clean up
dbDisconnect(con)

setwd("~/Work/Kaggle/")
write.csv(d3, file="Data/d3.csv", row.names=FALSE)
write.csv(d4, file="Data/d4.csv", row.names=FALSE)
write.csv(d5, file="Data/d5.csv", row.names=FALSE)


