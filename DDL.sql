-- COUNTY Type Table --
CREATE TABLE tblCOURT_TYPE(
    CourtTypeID INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    CourtTypeName VARCHAR(50) NOT NULL
);

-- SENTENCE Type Table --
CREATE TABLE tblSENTENCE_TYPE(
    SentenceTypeID INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    SentenceTypeName VARCHAR(50)
);

-- INSTITUTION TYPE TABLE --
CREATE TABLE tblINSTITUTION_TYPE(
    InstitutionTypeID INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    InstitutionTypeName VARCHAR(50) NOT NULL
);

-- CRIME CLASS TYPE Table --
CREATE TABLE tblCRIME_CLASS_TYPE(
    CrimeClassTypeID INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    CrimeClassTypeName VARCHAR(50) NOT NULL
);

-- SENTENCE Table --
CREATE TABLE tblSENTENCE (
    SentenceID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    IndividualID INT NOT NULL,
    FOREIGN KEY (IndividualID) REFERENCES tblINDIVIDUAL(IndividualID),
    SentenceDate DATE NOT NULL,
    SentenceTypeID INT NOT NULL,
    FOREIGN KEY (SentenceTypeID) REFERENCES tblSENTENCE_TYPE(SentenceTypeID),
    CrimeClassID INT NOT NULL,
    FOREIGN KEY (CrimeClassID) REFERENCES tblCRIME_CLASS(CrimeClassID),
    AdmissionID INT NOT NULL,
    FOREIGN KEY (AdmissionID) REFERENCES tblADMISSION(AdmissionID),
    CountyID INT NOT NULL,
    FOREIGN KEY (CountyID) REFERENCES tblCOUNTY(CountyID),
    CourtID INT NOT NULL,
    FOREIGN KEY (CourtID) REFERENCES tblCOURT(CourtID)
);

-- SENTENCE-INSTITUTION Bridge Table --
CREATE TABLE tblSENTENCE_INSTITUTION(
    SentenceInstitutionID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    SentenceID INT NOT NULL,
    FOREIGN KEY (SentenceID) REFERENCES tblSENTENCE(SentenceID),
    InstitutionID INT NOT NULL,
    FOREIGN KEY (InstitutionID) REFERENCES tblInstitution(InstitutionID),
    BeginDate DATE NOT NULL,
    EndDate DATE
);

-- INSTITUTION Table --
CREATE TABLE tblINSTITUTION(
    InstitutionID INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    InstitutionName VARCHAR(50),
    InstitutionTypeID INT NOT NULL,
    FOREIGN KEY (InstitutionTypeID) REFERENCES tblINSTITUTION_TYPE
);

-- COURT Table --
CREATE TABLE tblCOURT(
    CourtID INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    CourtName VARCHAR(50) NOT NULL,
    CourtTypeID INT NOT NULL,
    FOREIGN KEY (CourtTypeID) REFERENCES tblCOURT_TYPE(CourtTypeID)
);

-- CRIME CLASS Table --
CREATE TABLE tblCRIME_CLASS(
    CrimeClassID INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    CrimeClassName VARCHAR(50) NOT NULL,
    OffenseDescription VARCHAR(200),
    CrimeClassTypeID INT NOT NULL,
    FOREIGN KEY (CrimeClassTypeID) REFERENCES tblCRIME_CLASS_TYPE(CrimeClassTypeID)
);

-- ADMISSION Table --
CREATE TABLE tblADMISSION(
    AdmissionID INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    AdmissionName VARCHAR(50) NOT NULL
);

-- COUNTY Table --
CREATE TABLE tblCOUNTY(
    CountyID INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    CountyName VARCHAR(50) NOT NULL
);

-- INDIVIDUAL Table --
CREATE TABLE tblINDIVIDUAL(
    IndividualID INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    IndividualFname VARCHAR(50) NOT NULL,
    IndividualLname VARCHAR(50) NOT NULL,
    BirthDate DATE NOT NULL,
    SexID INT NOT NULL,
    FOREIGN KEY (SexID) REFERENCES tblSEX(SexID),
    RaceID INT NOT NULL,
    FOREIGN KEY (RaceID) REFERENCES tblRACE(RaceID)
);

-- SEX Table --
CREATE TABLE tblSEX(
    SexID INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    SexName VARCHAR(50) NOT NULL
);

-- RACE Table --
CREATE TABLE tblRACE(
    RaceID INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    RaceName VARCHAR(50) NOT NULL
);