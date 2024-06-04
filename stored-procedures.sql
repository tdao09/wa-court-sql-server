/* Write the SQL to create a stored procedure to populate a new row into the table CRIME_CLASS within an explicit transaction */

CREATE PROCEDURE NewRow_INSERT_Crime_Class
@CrimeCName varchar(50),
@OffenseDescr varchar(500),
@CrimeCTypeName varchar(50)

AS
DECLARE  @CrimeCType_ID INT

SET @CrimeCType_ID = (SELECT CrimeClassTypeID FROM tblCRIME_CLASS_TYPE WHERE CrimeClassTypeName = @CrimeCTypeName)

BEGIN TRANSACTION T1
INSERT INTO tblCRIME_CLASS (CrimeClassName, OffenseDescription, CrimeClassTypeID)
VALUES (@CrimeCName,  @OffenseDescr, @CrimeCType_ID)
COMMIT TRANSACTION T1
GO

/* Create a stored procedure that sentences a new individual to an institution (they have never received a prior sentence) */

CREATE PROCEDURE newIndividualSentence
@Fname varchar(35),
@Lname varchar(35),
@DOB DATE,
@SexName varchar(25),
@RaceName varchar(25),
@SentenceDate DATE,
@SentenceTypeName varchar(50),
@CrimeClassName varchar(50),
@AdmissionName varchar(35),
@CountyName varchar(50),
@CourtName varchar(50),
@InstitutionName varchar(50),
@BeginDate DATE,
@EndDate DATE

AS
DECLARE @Sex_ID INT, @Race_ID INT, @Individual_ID INT,
@SentenceType_ID INT, @CrimeClass_ID INT, @Admission_ID INT,
@County_ID INT, @Court_ID INT, @Sentence_ID INT,
@Institution_ID INT

SET @Sex_ID = (SELECT SexID FROM tblSEX WHERE SexName = @SexName)
SET @Race_ID = (SELECT RaceID FROM tblRACE WHERE RaceName = @RaceName)
SET @SentenceType_ID = (SELECT SentenceTypeID FROM tblSENTENCE_TYPE WHERE SentenceTypeName = @SentenceTypeName)
SET @CrimeClass_ID = (SELECT CrimeClassID FROM tblCRIME_CLASS WHERE CrimeClassName = @CrimeClassName)
SET @Admission_ID = (SELECT AdmissionID FROM tblADMISSION WHERE AdmissionName = @AdmissionName)
SET @County_ID = (SELECT CountyID FROM tblCOUNTY WHERE CountyName = @CountyName)
SET @Court_ID = (SELECT CourtID FROM tblCOURT WHERE CourtName = @CourtName)

BEGIN TRANSACTION TRAVON1
INSERT INTO tblINDIVIDUAL(IndividualFname, IndividualLname, BirthDate, SexID, RaceID)
VALUES(@Fname, @Lname, @DOB, @Sex_ID, @Race_ID)
SET @Individual_ID = (SELECT SCOPE_IDENTITY())
INSERT INTO tblSENTENCE(IndividualID, SentenceDate, SentenceTypeID, CrimeClassID, AdmissionID, CountyID, CourtID)
VALUES(@Individual_ID, @SentenceDate, @SentenceType_ID, @CrimeClass_ID, @Admission_ID, @County_ID, @Court_ID)
SET @Sentence_ID = (SELECT SCOPE_IDENTITY())
INSERT INTO tblSENTENCE_INSTITUTION(SentenceID, InstitutionID, BeginDate, EndDate)
VALUES(@Sentence_ID, @Institution_ID, @BeginDate, @EndDate)
COMMIT TRANSACTION TRAVON1
GO

/* Create a stored procedure for sentencing a new individual but they are not being incarcerated */

CREATE PROCEDURE nonIncarcSentence
@Fname varchar(35),
@Lname varchar(35),
@DOB DATE,
@SexName varchar(25),
@RaceName varchar(25),
@SentenceDate DATE,
@SentenceTypeName varchar(50),
@CrimeClassName varchar(50),
@AdmissionName varchar(35),
@CountyName varchar(50),
@CourtName varchar(50)

AS
DECLARE @Sex_ID INT, @Race_ID INT, @Individual_ID INT,
@SentenceType_ID INT, @CrimeClass_ID INT, @Admission_ID INT,
@County_ID INT, @Court_ID INT

SET @Sex_ID = (SELECT SexID FROM tblSEX WHERE SexName = @SexName)
SET @Race_ID = (SELECT RaceID FROM tblRACE WHERE RaceName = @RaceName)
SET @SentenceType_ID = (SELECT SentenceTypeID FROM tblSENTENCE_TYPE WHERE SentenceTypeName = @SentenceTypeName)
SET @CrimeClass_ID = (SELECT CrimeClassID FROM tblCRIME_CLASS WHERE CrimeClassName = @CrimeClassName)
SET @Admission_ID = (SELECT AdmissionID FROM tblADMISSION WHERE AdmissionName = @AdmissionName)
SET @County_ID = (SELECT CountyID FROM tblCOUNTY WHERE CountyName = @CountyName)
SET @Court_ID = (SELECT CourtID FROM tblCOURT WHERE CourtName = @CourtName)

BEGIN TRANSACTION S1
INSERT INTO tblINDIVIDUAL(IndividualFname, IndividualLname, BirthDate, SexID, RaceID)
VALUES(@Fname, @Lname, @DOB, @Sex_ID, @Race_ID)
SET @Individual_ID = (SELECT SCOPE_IDENTITY())
INSERT INTO tblSENTENCE(IndividualID, SentenceDate, SentenceTypeID, CrimeClassID, AdmissionID, CountyID, CourtID)
VALUES(@Individual_ID, @SentenceDate, @SentenceType_ID, @CrimeClass_ID, @Admission_ID, @County_ID, @Court_ID)
COMMIT TRANSACTION S1
GO

/* Create a stored procedure for giving a repeat offender (someone who has already committed an offense/already in the database) a new sentence but they aren’t being incarcerated */

CREATE PROCEDURE RepeatOffender
@Fname varchar(35),
@Lname varchar(35),
@DOB DATE,
@SentenceDate DATE,
@SentenceTypeName varchar(50),
@CrimeClassName varchar(50),
@CountyName varchar(50),
@CourtName varchar(50)

AS
DECLARE @Individual_ID INT,
@SentenceType_ID INT, @CrimeClass_ID INT, @Admission_ID INT,
@County_ID INT, @Court_ID INT

SET @Individual_ID = (SELECT IndividualID FROM tblINDIVIDUAL WHERE IndividualFname = @Fname AND IndividualLname = @Lname AND BirthDate = @DOB)
SET @SentenceType_ID = (SELECT SentenceTypeID FROM tblSENTENCE_TYPE WHERE SentenceTypeName = @SentenceTypeName)
SET @CrimeClass_ID = (SELECT CrimeClassID FROM tblCRIME_CLASS WHERE CrimeClassName = @CrimeClassName)
SET @Admission_ID = (SELECT AdmissionID FROM tblADMISSION WHERE AdmissionName = 'Repeat Offender')
SET @County_ID = (SELECT CountyID FROM tblCOUNTY WHERE CountyName = @CountyName)
SET @Court_ID = (SELECT CourtID FROM tblCOURT WHERE CourtName = @CourtName)

BEGIN TRANSACTION S2
INSERT INTO tblSENTENCE(IndividualID, SentenceDate, SentenceTypeID, CrimeClassID, AdmissionID, CountyID, CourtID)
VALUES(@Individual_ID, @SentenceDate, @SentenceType_ID, @CrimeClass_ID, @Admission_ID, @County_ID, @Court_ID)
COMMIT TRANSACTION S2
GO

/* Create stored procedure for a repeat offender who is being incarcerated */

CREATE OR ALTER PROCEDURE repeatIncarceration
@Fname varchar(35),
@Lname varchar(35),
@DOB DATE,
@SentenceDate DATE,
@SentenceTypeName varchar(50),
@CrimeClassName varchar(50),
@CountyName varchar(50),
@CourtName varchar(50),
@InstitutionName varchar(50),
@BeginDate DATE,
@EndDate DATE

AS
DECLARE @Individual_ID INT,
@SentenceType_ID INT, @CrimeClass_ID INT, @Admission_ID INT,
@County_ID INT, @Court_ID INT, @Sentence_ID INT,
@Institution_ID INT

SET @Individual_ID = (SELECT IndividualID FROM tblINDIVIDUAL WHERE IndividualFname = @Fname AND IndividualLname = @Lname
AND BirthDate = @DOB)
SET @SentenceType_ID = (SELECT SentenceTypeID FROM tblSENTENCE_TYPE WHERE SentenceTypeName = @SentenceTypeName)
SET @CrimeClass_ID = (SELECT CrimeClassID FROM tblCRIME_CLASS WHERE CrimeClassName = @CrimeClassName)
SET @Admission_ID = (SELECT AdmissionID FROM tblADMISSION WHERE AdmissionName = 'Repeat Offender')
SET @County_ID = (SELECT CountyID FROM tblCOUNTY WHERE CountyName = @CountyName)
SET @Court_ID = (SELECT CourtID FROM tblCOURT WHERE CourtName = @CourtName)
SET @Institution_ID = (SELECT InstitutionID FROM tblINSTITUTION WHERE InstitutionName = @InstitutionName)

BEGIN TRANSACTION S4
INSERT INTO tblSENTENCE(IndividualID, SentenceDate, SentenceTypeID, CrimeClassID, AdmissionID, CountyID, CourtID)
VALUES(@Individual_ID, @SentenceDate, @SentenceType_ID, @CrimeClass_ID, @Admission_ID, @County_ID, @Court_ID)
SET @Sentence_ID = (SELECT SCOPE_IDENTITY())
INSERT INTO tblSENTENCE_INSTITUTION(SentenceID, InstitutionID, BeginDate, EndDate)
VALUES(@Sentence_ID, @Institution_ID, @BeginDate, @EndDate)
COMMIT TRANSACTION S4
GO

/* Write a stored procedure to insert a new institution into the table Institution */

CREATE OR ALTER PROCEDURE NewInstitution
@InstitutionName varchar(75),
@InstitutionTypeName varchar(75)

AS
DECLARE @InstitutionTypeID INT
SET @InstitutionTypeID = (SELECT InstitutionTypeID FROM tblINSTITUTION_TYPE WHERE InstitutionTypeName = @InstitutionTypeName)

BEGIN TRANSACTION T1
INSERT INTO tblInstitution (InstitutionName, InstitutionTypeID)
VALUES (@InstitutionName, @InstitutionTypeID)
COMMIT TRANSACTION T1
GO