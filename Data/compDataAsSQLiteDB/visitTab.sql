-- SQLite script to create visitTab
-- this is a table or join from Practice Fusion dataset
-- It is a summary of some patient doctor visiting habits

-- Usage:
-- sqlite3.exe name.db < filename.sql

.mode csv

-- =============================================================
-- Join: ptprofileTab
-- PatientGuid, YearOfBirth, Gender, State, dmIndicator table training_patient
--- count(ConditionGuid) table training_patientCondition 
--- count(TranscriptGuid) table training_transcript
---- count(MedicationGuid) table training_medication
-- =============================================================
DROP TABLE IF EXISTS condCount;
CREATE TEMP TABLE condCount AS
	SELECT PatientGuid, COUNT(ConditionGuid) 
	FROM training_patientCondition
	GROUP BY PatientGuid;
DROP TABLE IF EXISTS medCount;
CREATE TEMP TABLE medCount AS
	SELECT PatientGuid, COUNT(MedicationGuid) 
	FROM training_medication
	GROUP BY PatientGuid;
DROP TABLE IF EXISTS diagCount;
CREATE TEMP TABLE diagCount AS
	SELECT PatientGuid, COUNT(DiagnosisGuid)
	FROM training_diagnosis
	GROUP BY PatientGuid;
DROP TABLE IF EXISTS transcriptCount;
CREATE TEMP TABLE transcriptCount AS
	SELECT PatientGuid, COUNT(TranscriptGuid) 
	FROM training_transcript
	GROUP BY PatientGuid;	
DROP TABLE IF EXISTS ptCond;
CREATE TEMP TABLE ptCond AS
	SELECT *
	FROM training_patient
	LEFT OUTER JOIN condCount
		ON training_patient.PatientGuid = condCount.PatientGuid;
DROP TABLE IF EXISTS ptCondMed;
CREATE TEMP TABLE ptCondMed AS
	SELECT *
	FROM ptCond
	LEFT OUTER JOIN medCount
		ON ptCond.PatientGuid = medCount.PatientGuid;
DROP TABLE IF EXISTS ptCondMedDiag;
CREATE TEMP TABLE ptCondMedDiag AS
	SELECT *
	FROM ptCondMed
	LEFT OUTER JOIN diagCount
		ON ptCondMed.PatientGuid = diagCount.PatientGuid;
DROP TABLE IF EXISTS ptprofile;
CREATE TABLE ptprofile AS
	SELECT *
	FROM ptCondMedDiag
	LEFT OUTER JOIN transcriptCount
		ON ptCondMedDiag.PatientGuid = transcriptCount.PatientGuid;
DROP TABLE IF EXISTS condCount;
DROP TABLE IF EXISTS medCount;
DROP TABLE IF EXISTS diagCount;
DROP TABLE IF EXISTS transcriptCount;
DROP TABLE IF EXISTS ptCond;
DROP TABLE IF EXISTS ptCondMed;


-- =============================================================
-- Join: cdtprofileTab
-- ConditionGuid, Name table condition
-- PatientGuid table training_patientCondition
-- Join on ptprofileTab
-- =============================================================