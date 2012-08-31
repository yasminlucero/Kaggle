# sample_code_library.R
# Function library called by sample_code.R for the Practice Fusion Diabetes Classification Competition.
#
# Requires the provided SQLite database.
# 7-July-2012
# ================================================================================= #

library(RSQLite)


# ================================================================================= #
create_flattenedDataset <- function(con, typeString, Ndiagnosis, Nmedication, Nlab) {
# create_flattenedDataset()
# A given patient will have mulitple diagnoses, medication, labs, prescriptions, etc.
# This function does a simple flattening procedure whereby the top N most 
# prevalent values are converted into binary variables.
# Example: Assume the top 2 most common diagnoses are Hypertension and Thrombocytopenia.
#   Instead of being listed under ICD9 or diagnosis description as 2 possible categorical values, 
#   2 new binary features are created called Hypertension and Thrombocytopenia created to
#   indicate the absence/presence of these diagnoses for each given patient.
#
# Arugments
#       con: SQLite connection
#       typeString: test or training 
#       Ndiagnosis: Number of diagnosis features to include (by ICD9 code)
#       Nmedication: Number of medciation features to include (by medication name)
#       Nlab: Number of lab features to include (by HL7 text)
#
# Returns
#       Data frame with one patientGuid per row. 
#       Columns are [indicator] [Ndiagnosis + Nmedication + Nlab features]
  
  if ( typeString == "test" ) {
    patientTable <- dbGetQuery(con, "SELECT * FROM test_patient")
    patientDemo <-   subset(patientTable, select=c("PatientGuid", "Gender", "YearOfBirth"))
    # Convert gender = "F" or "M" to 0, 1
    patientDemo[patientDemo$Gender == "F",2] <- 0
    patientDemo[patientDemo$Gender == "M",2] <- 1
    
    flatDataset <- patientDemo 
  }
  else {
    patientTable <- dbGetQuery(con, "SELECT * FROM training_patient")
    patientDemo <-   subset(patientTable, select=c("PatientGuid", "dmIndicator", "Gender", "YearOfBirth"))
    # Convert gender = "F" or "M" to 0, 1
    patientDemo[patientDemo$Gender == "F",3] <- 0
    patientDemo[patientDemo$Gender == "M",3] <- 1
    
    flatDataset <- patientDemo
  }
  
  if ( typeString == "test" ) {
    if ( Ndiagnosis > 0 ) { flatDataset <- addDiagnosisVariables(con, "test", flatDataset, Ndiagnosis) }
    if ( Nmedication > 0 ) {flatDataset <- addMedicationVariables(con, "test", flatDataset, Nmedication) }
    if ( Nlab > 0 ) { flatDataset <- addLabsVariables(con, "test", flatDataset, Nlab) }
  }
  else {
    if ( Ndiagnosis > 0 ) { flatDataset <- addDiagnosisVariables(con, "training", flatDataset, Ndiagnosis) }
    if ( Nmedication > 0 ) { flatDataset <- addMedicationVariables(con, "training", flatDataset, Nmedication) }
    if ( Nlab >0 ) { flatDataset <- addLabsVariables(con, "training", flatDataset, Nlab) }
  }
  
  return(flatDataset) 
}


# ================================================================================= #
addDiagnosisVariables <- function(con, typeString, flatDataset, Ndiagnosis) {
# addDiagnosisVariables()
# Adds Ndiagnosis diagnosis features to the input flatDataset.
# Diagnosis features to include are determined by frequency in the training set
# Diagnosis features are identified by ICD9 codes.
#
# Arguments
#      con: SQLite connection
#      typeString: "test" or "training"
#      flatDataset: data frame to which features are added
#      Ndiagnosis: number of diagnosis features to add
#
# Returns
#      flatDataset: input dataset with diagnosis features added
  
  # Create frequency table of ICD9 codes as determined by training set.
  # Train and test sets need to reference the same features.
  train_dxTable <- dbGetQuery(con, "SELECT * FROM training_diagnosis")
  freqTable <- data.frame(prop.table(table(train_dxTable$ICD9Code)))
  colnames(freqTable) <- c("ICD9", "Freq")
  freqTable$ICD9 <- levels(droplevels(freqTable$ICD9))  # formating step: remove factors to get ICD9 as strings
  freqTable <- freqTable[order(freqTable$Freq, decreasing=TRUE),]
  
  if ( typeString == "test" ) {
    tableToRead <- dbGetQuery(con, "SELECT * FROM test_diagnosis")
  }
  else {
    tableToRead <- train_dxTable
  }
  
  for ( i in 1:Ndiagnosis ) {
    hasFeature <- unique(subset(tableToRead, ICD9Code==freqTable[i,1])$PatientGuid)
    indCol <- rep(0, length(flatDataset[,1]))
    indCol[flatDataset$PatientGuid %in% hasFeature] <- 1
    flatDataset <- cbind(flatDataset, indCol)
    colnames(flatDataset)[length(flatDataset)] <- freqTable[i,1]
  }
  
  return(flatDataset) 
}

# ================================================================================= #
addMedicationVariables <- function(con, typeString, flatDataset, Nmedication) {
  # addMedicationVariables()
  # Adds specified number of medication features (Nmedication) to the input flatDataset.
  # Medication features are identified by medication name.
  #
  # Arguments
  #      medTable: medication table
  #      flatDataset: data frame to which features are added
  #      Nmedication: number of medication features to add
  #
  # Returns
  #      flatDataset: input dataset with diagnosis features added
  
  # Create frequency table determined by training set.
  # Train and test sets need to reference the same features.
  train_medTable <- dbGetQuery(con, "SELECT * FROM training_medication")
  freqTable <- data.frame(prop.table(table(train_medTable$MedicationName)))  
  colnames(freqTable) <- c("MedName", "Freq")
  freqTable$MedName <- levels(droplevels(freqTable$MedName))  # formating step: remove factors to get MedName as strings
  freqTable <- freqTable[order(freqTable$Freq, decreasing=TRUE),]
  
  if ( typeString == "test" ) {
    tableToRead <- dbGetQuery(con, "SELECT * FROM test_medication")
  }
  else {
    tableToRead <- train_medTable
  }  
  
  for ( i in 1:Nmedication ) {
    hasFeature <- unique(subset(tableToRead, MedicationName==freqTable[i,1])$PatientGuid)
    indCol <- rep(0, length(flatDataset[,1]))
    indCol[flatDataset$PatientGuid %in% hasFeature] <- 1
    flatDataset <- cbind(flatDataset, indCol)
    colnames(flatDataset)[length(flatDataset)] <- freqTable[i,1]
  }
  
  return(flatDataset)
}


# ================================================================================= #
addLabsVariables <- function(con, typeString, flatDataset, Nlab) {
# addLabsVariables()
# Adds specified number of medication features (Nlabs) to the input flatDataset.
# Lab features are identified by HL7 text
#
# Arguments
#      labsTable: joined version of labPanel, labObservation and labResult tables
#      flatDataset: data frame to which features are added
#      Nlab: number of lab features to add
#
# Returns
#      flatDataset: input dataset with diagnosis features added  
  
  # Create frequency table determined by training set.
  # Train and test sets need to reference the same features.
  train_labsTable <- dbGetQuery(con, "SELECT * FROM training_labs")  
  freqTable <- data.frame(prop.table(table(train_labsTable$HL7Text)))
  colnames(freqTable) <- c("HL7text", "Freq")
  freqTable$HL7text <- levels(droplevels(freqTable$HL7text))  # formating step: remove factors to get HL7Text as strings
  freqTable <- freqTable[order(freqTable$Freq, decreasing=TRUE),]
  
  if ( typeString == "test" ) {
    tableToRead <- dbGetQuery(con, "SELECT * FROM test_labs")
  }
  else {
    tableToRead <- train_labsTable
  }  
  
  for ( i in 1:Nlab ) {
    hasFeature <- unique(subset(tableToRead, HL7Text==freqTable[i,1])$PatientGuid)
    indCol <- rep(0, length(flatDataset[,1]))
    indCol[flatDataset$PatientGuid %in% hasFeature] <- 1
    flatDataset <- cbind(flatDataset, indCol)
    colnames(flatDataset)[length(flatDataset)] <- freqTable[i,1]
  }
  
  return(flatDataset) 
}

