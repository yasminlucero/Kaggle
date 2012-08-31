# sample_code.R
# Sample code for the Practice Fusion Diabetes Classification Competition.
# This codes provides an example of how to flatten the data set features for
# diagnoses, medications, and labs and computes a basic random forest benchmark
# for a transformed dataset with 2 diagnoses, 5 medications and 3 labs.
#
# Requires the provided SQLite database.
# Requires file sample_code_library.R
# 7-July-2012
# ================================================================================= #

library(RSQLite)
library(randomForest)
# Assumes sample_code_library.R is in current working directory
source(paste(getwd(), "/sample_code_library.R", sep=''))


# ================================================================================= #
# open connections
n <- dbDriver("SQLite", max.con=25)
con <- dbConnect(n, dbname="compData.db")


# ================================================================================= #
# Create dataset with (Ndx, Nmeds, Nlabs) = (2,5,3)
train <- create_flattenedDataset(con, "training", 2, 5, 3)
test <- create_flattenedDataset(con, "test", 2, 5, 3)


# ================================================================================= #
# Benchmark vanilla random forest
rf <- randomForest(train[,3:ncol(train)], train$dmIndicator)
rf_result <- predict(rf, test[,2:ncol(test)], type="response")

myPred <- data.frame(test$PatientGuid, rf_result)
write.table(myPred[order(myPred$test.PatientGuid),], "sample.csv", sep=',', row.names=FALSE, quote=TRUE, col.names=FALSE)