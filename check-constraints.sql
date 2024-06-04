
/* Nobody over the age of 96 can be sentenced to incarceration regardless of crime */

CREATE FUNCTION fn_ELDERELY()
RETURNS INT
AS
BEGIN
DECLARE @Ret INT = 0
   IF EXISTS (SELECT *
       FROM tblINDIVIDUAL I
       JOIN tblSENTENCE S ON I.IndividualID = S.IndividualID
       JOIN tblSENTENCE_TYPE ST ON S.SentenceTypeID = ST.SentenceTypeID
       WHERE I.BirthDate < DateAdd(YEAR, -96, GetDate())
       AND ST.SentenceTypeName = 'Incarceration'
       )
       BEGIN
           SET @Ret = 1
       END
RETURN @Ret
END
GO

ALTER TABLE tblSENTENCE WITH NOCHECK
ADD CONSTRAINT CK_ELDERELY
CHECK (dbo.fn_ELDERELY() = 0)
GO

/* Only those who have committed the crime type “felony” can be sentenced to death */

CREATE OR ALTER FUNCTION fn_Incarceration()
RETURNS INT
AS
BEGIN
DECLARE @Ret INT = 0
  IF EXISTS (SELECT *
      FROM tblINDIVIDUAL I
      JOIN tblSENTENCE S ON I.IndividualID = S.IndividualID
      JOIN tblSENTENCE_TYPE ST ON S.SentenceTypeID = ST.SentenceTypeID
      JOIN tblCRIME_CLASS CC ON S.CrimeClassID = CC.CrimeClassID
      JOIN tblCRIME_CLASS_TYPE CCT ON CC.CrimeClassTypeID = CCT.CrimeClassTypeID
      WHERE ST.SentenceTypeName = 'Death'
      AND CCT.CrimeClassTypeName != 'Felony'
      )
      BEGIN
          SET @Ret = 1
      END
RETURN @Ret
END
GO
ALTER TABLE tblSENTENCE WITH NOCHECK
ADD CONSTRAINT CK_SentenceMatches
CHECK (dbo.fn_Incarceration() = 0)
GO


/* Only sentences of type incarceration can be served at an institution
    a business rule that states that only sentences of sentenceType 'incarceration'can be placed into tblSENTENCE_INSTITUTION  
*/
CREATE FUNCTION fn_onlySentIncarcInstit()
RETURNS INT
AS
BEGIN
DECLARE @RET INT = 0
IF
EXISTS (SELECT * FROM tblSENTENCE S
   JOIN tblSENTENCE_TYPE ST ON S.SentenceTypeID = ST.SentenceTypeID
   JOIN tblSENTENCE_INSTITUTION SI ON S.SentenceID = SI.SentenceID
   WHERE ST.SentenceTypeName != 'Incarceration')
BEGIN
SET @RET = 1
END
RETURN @RET
END
GO

ALTER TABLE tblSENTENCE_INSTITUTION
ADD CONSTRAINT ck_SentenceIsIncarc
CHECK (dbo.fn_onlySentIncarcInstit() = 0)

/* Anyone younger than 18 can only be incarcerated in institutions of type ‘Juvenile’ 
    a business rule that states that individuals younger than 18 can only be incarcerated in institutions of type 'juvenile'
*/

CREATE FUNCTION fn_onlyJuvUnder18()
RETURNS INT
AS
BEGIN
DECLARE @RET INT = 0
IF
EXISTS (SELECT * FROM tblINDIVIDUAL I
   JOIN tblSENTENCE S ON I.IndividualID = S.IndividualID
   JOIN tblSENTENCE_INSTITUTION SI ON S.SentenceID = SI.SentenceID
   JOIN tblINSTITUTION INST ON SI.InstitutionID = INST.InstitutionID
   JOIN tblINSTITUTION_TYPE IT ON INST.InstitutionTypeID = IT.InstitutionTypeID
   WHERE I.BirthDate > DATEADD(YEAR, -18, GETDATE())
   AND IT.InstitutionTypeName != 'Juvenile')
BEGIN
SET @RET = 1
END
RETURN @RET
END
GO


ALTER TABLE tblSENTENCE_INSTITUTION
ADD CONSTRAINT ck_juvieAge
CHECK (dbo.fn_onlyJuvUnder18() = 0)

/* Crimes that are felonies can only be up to 100 years in prison */

CREATE OR ALTER FUNCTION fn_FelonyHundredYears()
RETURNS INT
AS
BEGIN
DECLARE @Ret INT = 0
  IF EXISTS (SELECT *
      FROM tblINDIVIDUAL I
      JOIN tblSENTENCE S ON I.IndividualID = S.IndividualID
      JOIN tblSENTENCE_INSTITUTION ST ON S.SentenceID = ST.SentenceID
      JOIN tblCRIME_CLASS CC ON S.CrimeClassID = CC.CrimeClassID
      JOIN tblCRIME_CLASS_TYPE CCT ON CC.CrimeClassTypeID = CCT.CrimeClassTypeID
      WHERE CCT.CrimeClassTypeName = 'Felony'
      AND DATEDIFF(YEAR, ST.BeginDate, ST.EndDate) > 100)
BEGIN
   SET @Ret = 1
END
RETURN @Ret
END
GO
ALTER TABLE tblSENTENCE_INSTITUTION WITH NOCHECK
ADD CONSTRAINT CK_FelonyLength
CHECK (dbo.fn_Incarceration() = 0)
GO

/* Woman can only be put in Women prisons */

CREATE OR ALTER FUNCTION fn_Women()
RETURNS INT
AS
BEGIN
DECLARE @Ret INT = 0
 IF EXISTS (SELECT *
     FROM tblSENTENCE S
     JOIN tblINDIVIDUAL I ON S.IndividualID = I.IndividualID
     JOIN tblSEX SEX ON I.SexID = SEX.SexID
     JOIN tblSENTENCE_INSTITUTION SI ON S.SentenceID = SI.SentenceID
     JOIN tblINSTITUTION INST ON SI.InstitutionID = INST.InstitutionID
     JOIN tblINSTITUTION_TYPE IT ON INST.InstitutionTypeID = IT.InstitutionTypeID
     WHERE SEX.SexName = 'Female'
     AND IT.InstitutionTypeName != 'Women'
     )
   BEGIN
       SET @Ret = 1
   END
RETURN @Ret
END
GO


ALTER TABLE tblSENTENCE_INSTITUTION
ADD CONSTRAINT CK_gender
CHECK (dbo.fn_Women() = 0)
GO




























