-- SQLite script to create single Practice Fusion databases
-- with all training and test tables and some useful joins.

-- Usage:
-- sqlite3.exe name.db < filename.sql

.mode csv

-- =============================================================
-- Raw data: Common files
-- =============================================================
DROP TABLE IF EXISTS condition;
CREATE TABLE condition (
	ConditionGuid char(36) PRIMARY KEY,
	Code varchar(50),
	Name varchar(100)
);
.import SyncCondition.csv condition
DELETE FROM condition WHERE ConditionGuid='ConditionGuid';

DROP TABLE IF EXISTS smokingStatus;
CREATE TABLE smokingStatus(
	SmokingStatusGuid char(36) PRIMARY KEY,
	Description varchar(255),
	NISTcode integer
);
.import SyncSmokingStatus.csv smokingStatus
DELETE FROM smokingStatus WHERE SmokingStatusGuid='SmokingStatusGuid';

-- =============================================================
-- Raw data: training
-- =============================================================
DROP TABLE IF EXISTS training_patient;
CREATE TABLE training_patient(
	PatientGuid char(36) PRIMARY KEY,
	dmIndicator integer,
	Gender varchar(1),
	YearOfBirth integer,
	State varchar(2),
	PracticeGuid char(36)
);
.import training_SyncPatient.csv training_patient
DELETE FROM training_patient WHERE PatientGuid='PatientGuid';

DROP TABLE IF EXISTS training_allergy;
CREATE TABLE training_allergy(
	AllergyGuid char(36) PRIMARY KEY,
	PatientGuid char(36) REFERENCES patient(patientGuid),
	AllergyType varchar(100),
	StartYear integer,
	ReactionName varchar(100),
	SeverityName varchar(100),
	MedicationNdcCode varchar(50),
	MedicationName varchar(100),
	UserGuid char(36)
);
.import training_SyncAllergy.csv training_allergy
DELETE FROM training_allergy WHERE AllergyGuid='AllergyGuid';

DROP TABLE IF EXISTS training_diagnosis;
CREATE TABLE training_diagnosis (
	DiagnosisGuid char(36) PRIMARY KEY,
	PatientGuid char(36) REFERENCES patient(patientGuid),
	ICD9Code varchar(50),
	DiagnosisDescription varchar(256),
	StartYear int,
	StopYear int,
	Acute int,
	UserGuid char(36)
);
.import training_SyncDiagnosis.csv training_diagnosis
DELETE FROM training_diagnosis WHERE DiagnosisGuid='DiagnosisGuid';

DROP TABLE IF EXISTS training_immunization;
CREATE TABLE training_immunization (
	ImmunizationGuid char(36) PRIMARY KEY,
	PatientGuid char(36) REFERENCES patient(patientGuid),
	VaccineName varchar(256),
	AdministeredYear int,
	CvxCode varchar(100),
	UserGuid char(36)
);
.import training_SyncImmunization.csv training_immunization
DELETE FROM training_immunization WHERE ImmunizationGuid='ImmunizationGuid';

DROP TABLE IF EXISTS training_transcript;
CREATE TABLE training_transcript(
	TranscriptGuid char(36) PRIMARY KEY,
	PatientGuid char(36) REFERENCES patient(patientGuid),
	VisitYear integer,
	Height,
	Weight real,
	BMI real,
	SystolicBP integer,
	DiastolicBP integer,
	RespiratoryRate integer,
	HeartRate integer,
	Temperature real,
	PhysicianSpecialty varchar(256),
	UserGuid char(36)
);
.import training_SyncTranscript.csv training_transcript
DELETE FROM training_transcript WHERE TranscriptGuid='TranscriptGuid';

DROP TABLE IF EXISTS training_labResult;
CREATE TABLE training_labResult(
	LabResultGuid char(36) PRIMARY KEY,
	UserGuid char(36),
	PatientGuid char(36) REFERENCES patient(patientGuid),
	TranscriptGuid char(36) REFERENCES transcript(transcriptGuid),
	PracticeGuid char(36),
	FacilityGuid char(36),
	ReportYear integer,
	AncestorLabResultGuid char(36)
);
.import training_SyncLabResult.csv training_labResult
DELETE FROM training_labResult WHERE LabResultGuid='LabResultGuid';

DROP TABLE IF EXISTS training_labPanel;
CREATE TABLE training_labPanel(
	PanelName varchar(255),
	LabPanelGuid char(36) PRIMARY KEY,
	LabResultGuid char(36) REFERENCES labResult(labResultGuid),
	ObservationYear integer,
	Status varchar(255)
);
.import training_SyncLabPanel.csv training_labPanel
DELETE FROM training_labPanel WHERE LabPanelGuid='LabPanelGuid';

DROP TABLE IF EXISTS training_labObservation;
CREATE TABLE training_labObservation (
	HL7Identifier varchar(255),
	HL7Text varchar(255),
	LabObservationGuid char(36) PRIMARY KEY,
	LabPanelGuid char(36) REFERENCES labPanel(labPanelGuid),
	HL7CodingSystem varchar(255),
	ObservationValue varchar(255),
	Units varchar(255),
	ReferenceRange varchar(255),
	AbnormalFlags varchar(255),
	ResultStatus varchar(255),
	ObservationYear int,
	UserGuid char(36),
	IsAbnormalValue int
);
.import training_SyncLabObservation.csv training_labObservation
DELETE FROM training_labObservation 
	WHERE LabObservationGuid='LabObservationGuid';

DROP TABLE IF EXISTS training_medication;
CREATE TABLE training_medication (
	MedicationGuid char(36) PRIMARY KEY,
	PatientGuid char(36) REFERENCES patient(patientGuid),
	MedicationNdcCode varchar(50),
	MedicationName varchar(256),
	MedicationStrength varchar(50),
	Schedule varchar(50),
	DiagnosisGuid char(36) REFERENCES diagnosis(diganosisGuid),
	UserGuid char(36)
);
.import training_SyncMedication.csv training_medication
DELETE FROM training_medication WHERE MedicationGuid='MedicationGuid';
	
DROP TABLE IF EXISTS training_patientCondition;
CREATE TABLE training_patientCondition (
	PatientConditionGuid char(36) PRIMARY KEY,
	PatientGuid char(36) REFERENCES patient(patientGuid),
	ConditionGuid char(36),
	CreatedYear integer
);
.import training_SyncPatientCondition.csv training_patientCondition
DELETE FROM training_patientCondition 
	WHERE PatientConditionGuid='PatientConditionGuid';

DROP TABLE IF EXISTS training_patientSmokingStatus;
CREATE TABLE training_patientSmokingStatus(
	PatientSmokingStatusGuid char(36) PRIMARY KEY,
	PatientGuid char(36) REFERENCES patient(patientGuid),
	SmokingStatusGuid char(36) REFERENCES smokingStatus(smokingStatusGuid),
	EffectiveYear integer
);
.import training_SyncPatientSmokingStatus.csv training_patientSmokingStatus
DELETE FROM training_patientSmokingStatus 
	WHERE PatientSmokingStatusGuid='PatientSmokingStatusGuid';

DROP TABLE IF EXISTS training_prescription;
CREATE TABLE training_prescription (
	PrescriptionGuid char(36) PRIMARY KEY,
	PatientGuid char(36) REFERENCES patient(patientGuid),
	MedicationGuid char(36) REFERENCES medication(medicationGuid),
	PrescriptionYear integer,
	Quantity varchar(50),
	NumberOfRefills varchar(50),
	RefillAsNeeded integer,
	GenericAllowed integer,
	UserGuid char(36)
);
.import training_SyncPrescription.csv training_prescription
DELETE FROM training_prescription WHERE PrescriptionGuid='PrescriptionGuid';

DROP TABLE IF EXISTS training_transcriptAllergy;
CREATE TABLE training_transcriptAllergy(
	TranscriptAllergyGuid char(36) PRIMARY KEY,
	TranscriptGuid char(36) REFERENCES transcript(transcriptGuid),
	AllergyGuid char(36) REFERENCES allergy(allergyGuid)
);
.import training_SyncTranscriptAllergy.csv training_transcriptAllergy
DELETE FROM training_transcriptAllergy 
	WHERE TranscriptAllergyGuid='TranscriptAllergyGuid';

DROP TABLE IF EXISTS training_transcriptDiagnosis;
CREATE TABLE training_transcriptDiagnosis (
	TranscriptDiagnosisGuid char(36) PRIMARY KEY,
	TranscriptGuid char(36) REFERENCES transcript(transcriptGuid),
	DiagnosisGuid char(36) REFERENCES diagnosis(diagnosisGuid)
);
.import training_SyncTranscriptDiagnosis.csv training_transcriptDiagnosis
DELETE FROM training_transcriptDiagnosis 
	WHERE TranscriptDiagnosisGuid='TranscriptDiagnosisGuid';

DROP TABLE IF EXISTS training_transcriptMedication;
CREATE TABLE training_transcriptMedication (
	TranscriptMedicationGuid char(36) PRIMARY KEY,
	TranscriptGuid char(36) REFERENCES transcript(transcriptGuid),
	MedicationGuid char(36) REFERENCES medication(medicationGuid)
);
.import training_SyncTranscriptMedication.csv training_transcriptMedication
DELETE FROM training_transcriptMedication 
	WHERE TranscriptMedicationGuid='TranscriptMedicationGuid';

-- =============================================================
-- Basic joined tables: training
-- =============================================================
DROP TABLE IF EXISTS templabs;
CREATE TEMP TABLE templabs AS
	SELECT *
	FROM training_labResult
	LEFT OUTER JOIN training_labPanel
		ON training_labResult.LabResultGuid = training_labPanel.LabResultGuid;
DROP TABLE IF EXISTS addObs;
CREATE TEMP TABLE addObs AS
	SELECT * FROM templabs
	LEFT OUTER JOIN training_labObservation
		ON templabs.LabPanelGuid = training_labObservation.LabPanelGuid;
DROP TABLE IF EXISTS training_labs;
CREATE TABLE training_labs AS SELECT * FROM addObs;

DROP TABLE IF EXISTS tempPatSmoke;
CREATE TEMP TABLE tempPatSmoke AS
	SELECT training_patient.PatientGuid, Gender, YearOfBirth, State, PracticeGuid,
		SmokingStatusGuid, EffectiveYear as SmokeEffectiveYear
	FROM training_patient
	LEFT OUTER JOIN training_patientSmokingStatus
		ON training_patient.PatientGuid = training_patientSmokingStatus.PatientGuid;
DROP TABLE IF EXISTS addSmoke;
CREATE TEMP TABLE addSmoke AS
	SELECT PatientGuid, Gender, YearOfBirth, State, PracticeGuid,
		SmokeEffectiveYear, Description as SmokingStatus_Description,
		NISTcode as SmokingStatus_NISTCode
	FROM tempPatSmoke
	LEFT OUTER JOIN smokingStatus 
		ON tempPatSmoke.SmokingStatusGuid = smokingStatus.SmokingStatusGuid;
DROP TABLE IF EXISTS training_smoke;
CREATE TABLE training_smoke AS SELECT * FROM addSmoke;

DROP TABLE IF EXISTS training_patientTranscript;
CREATE TABLE training_patientTranscript AS
	SELECT *
	FROM training_patient
	LEFT OUTER JOIN training_transcript
		ON training_patient.PatientGuid = training_transcript.PatientGuid;

DROP TABLE IF EXISTS tempMedsRx;
CREATE TEMP TABLE tempMedsRx AS
	SELECT * FROM training_medication
	LEFT OUTER JOIN training_prescription
		ON training_medication.PatientGuid = training_prescription.PatientGuid
		AND training_medication.MedicationGuid = training_prescription.MedicationGuid;
		
DROP TABLE IF EXISTS training_allMeds;
CREATE TABLE training_allMeds AS
	SELECT * FROM tempMedsRx
	LEFT OUTER JOIN training_allergy
		ON tempMedsRx.PatientGuid = training_allergy.PatientGuid
		AND tempMedsRx.MedicationNdcCode = training_allergy.MedicationNdcCode;
	
		
-- =============================================================
-- Raw data: test
-- =============================================================
DROP TABLE IF EXISTS test_patient;
CREATE TABLE test_patient(
	PatientGuid char(36) PRIMARY KEY,
	Gender varchar(1),
	YearOfBirth integer,
	State varchar(2),
	PracticeGuid char(36)
);
.import test_SyncPatient.csv test_patient
DELETE FROM test_patient WHERE PatientGuid='PatientGuid';

DROP TABLE IF EXISTS test_allergy;
CREATE TABLE test_allergy(
	AllergyGuid char(36) PRIMARY KEY,
	PatientGuid char(36) REFERENCES patient(patientGuid),
	AllergyType varchar(100),
	StartYear integer,
	ReactionName varchar(100),
	SeverityName varchar(100),
	MedicationNDCCode varchar(50),
	MedicationName varchar(100),
	UserGuid char(36)
);
.import test_SyncAllergy.csv test_allergy
DELETE FROM test_allergy WHERE AllergyGuid='AllergyGuid';

DROP TABLE IF EXISTS test_diagnosis;
CREATE TABLE test_diagnosis (
	DiagnosisGuid char(36) PRIMARY KEY,
	PatientGuid char(36) REFERENCES patient(patientGuid),
	ICD9Code varchar(50),
	DiagnosisDescription varchar(256),
	StartYear int,
	StopYear int,
	Acute int,
	UserGuid char(36)
);
.import test_SyncDiagnosis.csv test_diagnosis
DELETE FROM test_diagnosis WHERE DiagnosisGuid='DiagnosisGuid';

DROP TABLE IF EXISTS test_immunization;
CREATE TABLE test_immunization (
	ImmunizationGuid char(36) PRIMARY KEY,
	PatientGuid char(36) REFERENCES patient(patientGuid),
	VaccineName varchar(256),
	AdministeredYear int,
	CvxCode varchar(100),
	UserGuid char(36)
);
.import test_SyncImmunization.csv test_immunization
DELETE FROM test_immunization WHERE ImmunizationGuid='ImmunizationGuid';

DROP TABLE IF EXISTS test_transcript;
CREATE TABLE test_transcript(
	TranscriptGuid char(36) PRIMARY KEY,
	PatientGuid char(36) REFERENCES patient(patientGuid),
	VisitYear integer,
	Height,
	Weight real,
	BMI real,
	SystolicBP integer,
	DiastolicBP integer,
	RespiratoryRate integer,
	HeartRate integer,
	Temperature real,
	PhysicianSpecialty varchar(256),
	UserGuid char(36)
);
.import test_SyncTranscript.csv test_transcript
DELETE FROM test_transcript WHERE TranscriptGuid='TranscriptGuid';

DROP TABLE IF EXISTS test_labResult;
CREATE TABLE test_labResult(
	LabResultGuid char(36) PRIMARY KEY,
	UserGuid char(36),
	PatientGuid char(36) REFERENCES patient(patientGuid),
	TranscriptGuid char(36) REFERENCES transcript(transcriptGuid),
	PracticeGuid char(36),
	FacilityGuid char(36),
	ReportYear integer,
	AncestorLabResultGuid char(36)
);
.import test_SyncLabResult.csv test_labResult
DELETE FROM test_labResult WHERE LabResultGuid='LabResultGuid';

DROP TABLE IF EXISTS test_labPanel;
CREATE TABLE test_labPanel(
	PanelName varchar(255),
	LabPanelGuid char(36) PRIMARY KEY,
	LabResultGuid char(36) REFERENCES labResult(labResultGuid),
	ObservationYear integer,
	Status varchar(255)
);
.import test_SyncLabPanel.csv test_labPanel
DELETE FROM test_labPanel WHERE LabPanelGuid='LabPanelGuid';

DROP TABLE IF EXISTS test_labObservation;
CREATE TABLE test_labObservation (
	HL7Identifier varchar(255),
	HL7Text varchar(255),
	LabObservationGuid char(36) PRIMARY KEY,
	LabPanelGuid char(36) REFERENCES labPanel(labPanelGuid),
	HL7Codingsystem varchar(255),
	ObservationValue varchar(255),
	Units varchar(255),
	ReferenceRange varchar(255),
	AbnormalFlags varchar(255),
	ResultStatus varchar(255),
	ObservationYear int,
	UserGuid char(36),
	SsAbnormalValue int
);
.import test_SyncLabObservation.csv test_labObservation
DELETE FROM test_labObservation WHERE LabObservationGuid='LabObservationGuid';

DROP TABLE IF EXISTS test_medication;
CREATE TABLE test_medication (
	MedicationGuid char(36) PRIMARY KEY,
	PatientGuid char(36) REFERENCES patient(patientGuid),
	MedicationNdcCode varchar(50),
	MedicationName varchar(256),
	MedicationStrength varchar(50),
	Schedule varchar(50),
	DiagnosisGuid char(36) REFERENCES diagnosis(diganosisGuid),
	UserGuid char(36)
);
.import test_SyncMedication.csv test_medication
DELETE FROM test_medication WHERE MedicationGuid='MedicationGuid';
	
DROP TABLE IF EXISTS test_patientCondition;
CREATE TABLE test_patientCondition (
	PatientConditionGuid char(36) PRIMARY KEY,
	PatientGuid char(36) REFERENCES patient(patientGuid),
	ConditionGuid char(36),
	CreatedYear integer
);
.import test_SyncPatientCondition.csv test_patientCondition
DELETE FROM test_patientCondition WHERE PatientConditionGuid='PatientConditionGuid';

DROP TABLE IF EXISTS test_patientSmokingStatus;
CREATE TABLE test_patientSmokingStatus(
	PatientSmokingStatusGuid char(36) PRIMARY KEY,
	PatientGuid char(36) REFERENCES patient(patientGuid),
	SmokingStatusGuid char(36) REFERENCES smokingStatus(smokingStatusGuid),
	EffectiveYear integer
);
.import test_SyncPatientSmokingStatus.csv test_patientSmokingStatus
DELETE FROM test_patientSmokingStatus 
	WHERE PatientSmokingStatusGuid='PatientSmokingStatusGuid';

DROP TABLE IF EXISTS test_prescription;
CREATE TABLE test_prescription (
	PrescriptionGuid char(36) PRIMARY KEY,
	PatientGuid char(36) REFERENCES patient(patientGuid),
	MedicationGuid char(36) REFERENCES medication(medicationGuid),
	PrescriptionYear integer,
	Quantity varchar(50),
	NumberOfRefills varchar(50),
	RefillAsNeeded integer,
	GenericAllowed integer,
	UserGuid char(36)
);
.import test_SyncPrescription.csv test_prescription
DELETE FROM test_prescription WHERE PrescriptionGuid='PrescriptionGuid';

DROP TABLE IF EXISTS test_transcriptAllergy;
CREATE TABLE test_transcriptAllergy(
	TranscriptAllergyGuid char(36) PRIMARY KEY,
	TranscriptGuid char(36) REFERENCES transcript(transcriptGuid),
	AllergyGuid char(36) REFERENCES allergy(allergyGuid)
);
.import test_SyncTranscriptAllergy.csv test_transcriptAllergy
DELETE FROM test_transcriptAllergy 
	WHERE TranscriptAllergyGuid='TranscriptAllergyGuid';

DROP TABLE IF EXISTS test_transcriptDiagnosis;
CREATE TABLE test_transcriptDiagnosis (
	TranscriptDiagnosisGuid char(36) PRIMARY KEY,
	TranscriptGuid char(36) REFERENCES transcript(transcriptGuid),
	DiagnosisGuid char(36) REFERENCES diagnosis(diagnosisGuid)
);
.import test_SyncTranscriptDiagnosis.csv test_transcriptDiagnosis
DELETE FROM test_transcriptDiagnosis 
	WHERE TranscriptDiagnosisGuid='TranscriptDiagnosisGuid';

DROP TABLE IF EXISTS test_transcriptMedication;
CREATE TABLE test_transcriptMedication (
	TranscriptMedicationGuid char(36) PRIMARY KEY,
	TranscriptGuid char(36) REFERENCES transcript(transcriptGuid),
	MedicationGuid char(36) REFERENCES medication(medicationGuid)
);
.import test_SyncTranscriptMedication.csv test_transcriptMedication
DELETE FROM test_transcriptMedication 
	WHERE TranscriptMedicationGuid='TranscriptMedicationGuid';

-- =============================================================
-- Basic joined tables: test
-- =============================================================
DROP TABLE IF EXISTS templabs;
CREATE TEMP TABLE templabs AS
	SELECT *
	FROM test_labResult
	LEFT OUTER JOIN test_labPanel
		ON test_labResult.LabResultGuid = test_labPanel.LabResultGuid;
DROP TABLE IF EXISTS addObs;
CREATE TEMP TABLE addObs AS
	SELECT * FROM templabs
	LEFT OUTER JOIN test_labObservation
		ON templabs.LabPanelGuid = test_labObservation.LabPanelGuid;
DROP TABLE IF EXISTS test_labs;
CREATE TABLE test_labs AS SELECT * FROM addObs;

DROP TABLE IF EXISTS tempPatSmoke;
CREATE TEMP TABLE tempPatSmoke AS
	SELECT test_patient.PatientGuid, Gender, YearOfBirth, State, PracticeGuid,
		SmokingStatusGuid, EffectiveYear as SmokeEffectiveYear
	FROM test_patient
	LEFT OUTER JOIN test_patientSmokingStatus
		ON test_patient.PatientGuid = test_patientSmokingStatus.PatientGuid;
DROP TABLE IF EXISTS addSmoke;		
CREATE TEMP TABLE addSmoke AS
	SELECT PatientGuid, Gender, YearOfBirth, State, PracticeGuid,
		SmokeEffectiveYear, Description as SmokingStatus_Description,
		NISTcode as SmokingStatus_NISTCode
	FROM tempPatSmoke
	LEFT OUTER JOIN smokingStatus 
		ON tempPatSmoke.SmokingStatusGuid = smokingStatus.SmokingStatusGuid;
DROP TABLE IF EXISTS test_smoke;
CREATE TABLE test_smoke AS SELECT * FROM addSmoke;

DROP TABLE IF EXISTS test_patientTranscript;
CREATE TABLE test_patientTranscript AS
	SELECT *
	FROM test_patient
	LEFT OUTER JOIN test_transcript
		ON test_patient.PatientGuid = test_transcript.PatientGuid;
		
DROP TABLE IF EXISTS tempMedsRx;
CREATE TEMP TABLE tempMedsRx AS
	SELECT * FROM test_medication
	LEFT OUTER JOIN test_prescription
		ON test_medication.PatientGuid = test_prescription.PatientGuid
		AND test_medication.MedicationGuid = test_prescription.MedicationGuid;
DROP TABLE IF EXISTS test_allMeds;

CREATE TABLE test_allMeds AS
	SELECT * FROM tempMedsRx
	LEFT OUTER JOIN test_allergy
		ON tempMedsRx.PatientGuid = test_allergy.PatientGuid
		AND tempMedsRx.MedicationNdcCode = test_allergy.MedicationNdcCode;