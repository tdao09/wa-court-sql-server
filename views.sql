/* What people have ever been sentenced in king county OR Garfield county for any crime? */

CREATE OR ALTER VIEW vwCountyJailed
AS
SELECT I.IndividualFname, I.IndividualLname, I.IndividualID
FROM tblINDIVIDUAL I
      JOIN tblSENTENCE S ON I.IndividualID = S.IndividualID
      JOIN tblCOUNTY C ON S.CountyID = C.CountyID
WHERE C.CountyName = 'King' OR C.CountyName = 'Garfield'
GROUP BY I.IndividualFname, I.IndividualLname, I.IndividualID

/* Individuals who have been sentenced to at least 1 Arson crime(s) in King County and at least 1 Armed Robberies in Garfield county (we are interested in such queries because our stakeholder is likely to look for repeat offenders who cross county lines and commit dangerous crimes) */

CREATE VIEW vwKing_Garfield
AS
SELECT A.*
FROM
(SELECT I.IndividualFname, I.IndividualLname, I.IndividualID
FROM tblINDIVIDUAL I
       JOIN tblSENTENCE S ON I.IndividualID = S.IndividualID
       JOIN tblCOUNTY C ON S.CountyID = C.CountyID
       JOIN tblCRIME_CLASS CC ON S.CrimeClassID = CC.CrimeClassID
WHERE C.CountyName = 'King'
AND CC.CrimeClassName = 'Arson'
GROUP BY I.IndividualFname, I.IndividualLname, I.IndividualID
HAVING COUNT(*) >= 1) A,


(SELECT I.IndividualFname, I.IndividualLname, I.IndividualID
FROM tblINDIVIDUAL I
       JOIN tblSENTENCE S ON I.IndividualID = S.IndividualID
       JOIN tblCOUNTY C ON S.CountyID = C.CountyID
       JOIN tblCRIME_CLASS CC ON S.CrimeClassID = CC.CrimeClassID
WHERE C.CountyName = 'Garfield'
AND CC.CrimeClassName = 'Armed Robbery'
GROUP BY I.IndividualFname, I.IndividualLname, I.IndividualID
HAVING COUNT(*) >= 1) B


WHERE A.IndividualID = B.IndividualID

/* Create a view of a subquery

    Get the individuals who have had at least 2 misdemeanors who
    have also had been incarcerated at least once in King County in the past 5 years

*/
CREATE VIEW vw_misdemeanorsThenIncarc
AS
SELECT A.*, numIncarcerations
FROM
(SELECT I.IndividualID, IndividualFname, IndividualLname, COUNT(*) AS numMisdemeanors
FROM tblINDIVIDUAL I
JOIN tblSENTENCE S ON I.IndividualID = S.IndividualID
JOIN tblCRIME_CLASS CC ON S.CrimeClassID = CC.CrimeClassID
JOIN tblCRIME_CLASS_TYPE CCT ON CC.CrimeClassTypeID = CCT.CrimeClassTypeID
WHERE CCT.CrimeClassTypeName = 'Misdemeanor'
AND S.SentenceDate >= DATEADD(YEAR, -5, GETDATE())
GROUP BY I.IndividualID, IndividualFname, IndividualLname
HAVING COUNT(*) >= 2) A,


(SELECT I.IndividualID, COUNT(*) AS numIncarcerations
FROM tblINDIVIDUAL I
JOIN tblSENTENCE S ON I.IndividualID = S.IndividualID
JOIN tblCRIME_CLASS CC ON S.CrimeClassID = CC.CrimeClassID
JOIN tblSENTENCE_TYPE ST ON S.SentenceTypeID = ST.SentenceTypeID
WHERE ST.SentenceTypeName = 'Incarceration'
AND S.SentenceDate >= DATEADD(YEAR, -5, GETDATE())
GROUP BY I.IndividualID
HAVING COUNT(*) >= 1) B
WHERE A.IndividualID = B.IndividualID


/* counties that had murders and DUIs
    Write the code to create a view that shows:
    The counties that
        a.) have hard at least 2 murders the past 15 years
        b.) also had at least 3 DUIs in the last 5 years where offender was a repeat offender
*/

CREATE VIEW vw_duiMurderCounties
AS
SELECT A.*, NumDUI5Years
FROM
(SELECT C.CountyID, C.CountyName, COUNT(*) AS numMurdersPast15Years
FROM tblCOUNTY C
   JOIN tblSENTENCE S ON C.CountyID = S.CountyID
   JOIN tblCRIME_CLASS CC ON S.CrimeClassID = CC.CrimeClassID
   WHERE CC.CrimeClassName = 'Murder'
   AND S.SentenceDate >= DATEADD(YEAR, -15, GETDATE())
   GROUP BY C.CountyID, C.CountyName
   HAVING COUNT(*) >= 2) A,
(SELECT C.CountyID, COUNT(*) AS NumDUI5Years
FROM tblCOUNTY C
   JOIN tblSENTENCE S ON C.CountyID = S.CountyID
   JOIN tblCRIME_CLASS CC ON S.CrimeClassID = CC.CrimeClassID
   JOIN tblADMISSION A ON S.AdmissionID = A.AdmissionID
   WHERE CC.CrimeClassName = 'Driving Under the Influence (DUI)'
   AND S.SentenceDate >= DATEADD(YEAR, -5, GETDATE())
   AND A.AdmissionName = 'Repeat Offender'
   GROUP BY C.CountyID, C.CountyName
   HAVING COUNT(*) >= 3) B
WHERE A.CountyID = B.CountyID

/* People that have been sentenced with murder or arson charges */

CREATE VIEW vwMurderArson
AS
SELECT I.IndividualID, I.IndividualFname, I.IndividualLname
FROM tblINDIVIDUAL I
      JOIN tblSENTENCE S ON I.IndividualID = S.IndividualID
      JOIN tblSENTENCE_TYPE ST ON S.SentenceTypeID = ST.SentenceTypeID
      JOIN tblCRIME_CLASS C ON S.CrimeClassID = C.CrimeClassID
WHERE C.CrimeClassName = 'Murder'
OR C.CrimeClassName = 'Arson'
GROUP BY I.IndividualID, I.IndividualFname, I.IndividualLname

/* The institutions that have sentenced at least 10,000 African-Americans in the past 20 years (put count(*) = 1 for testing purposes) */

CREATE  VIEW vw_AfricanAmericanInstitutions20yrs
AS
SELECT I.InstitutionID, I.InstitutionName, COUNT(*) AS NumAfricanAmerican20yrs
FROM tblINSTITUTION I
  JOIN tblSENTENCE_INSTITUTION SI ON I.InstitutionID = SI.InstitutionID
  JOIN tblSENTENCE S ON SI.SentenceID = S.SentenceID
  JOIN tblINDIVIDUAL IND ON S.IndividualID = IND.IndividualID
  JOIN tblRACE R ON IND.RaceID = R.RaceID
WHERE R.RaceName = 'Black'
AND S.SentenceDate >= DATEADD(YEAR, -20, GETDATE())
GROUP BY I.InstitutionID, I.InstitutionName
HAVING COUNT(*) >= 1
GO