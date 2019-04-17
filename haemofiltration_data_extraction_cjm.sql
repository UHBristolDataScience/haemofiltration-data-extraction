---------------------------------------------------
-- Which patients are on haemofiltration:
SELECT TOP 10 * FROM D_Intervention WHERE longLabel='Access (Arterial) Pressure' --3431
SELECT COUNT(DISTINCT(attributeId)) FROM PtAssessment WHERE interventionId=3431 -- only a single attribute for this ID

-- Output result of followling query to file for patient summary:
SELECT P.encounterId, CONVERT(varchar, MAX(C.inTime), 20) as inTIME, CONVERT(varchar, MIN(C.outTime), 20) as outTime, MIN(D.age) as age, MIN(D.lifeTimeNumber) as tNumber, MIN(C.lengthOfStay) as 'lengthOfStay (mins)', MAX(D.gender) as gender, COUNT(ptAssessmentId) as numberOfRecords 
FROM PtAssessment P
INNER JOIN PtCensus C
ON P.encounterId=C.encounterId
INNER JOIN D_Encounter D
ON P.encounterId=D.encounterId
WHERE P.interventionId=3431 and P.clinicalUnitId=5 and C.inTime>'2015-01-31 23:59:59'
GROUP BY P.encounterId
ORDER BY inTime

---------------------------------------------------
-- We then want to locate and extract the following variables:
-- From arterial blood gas : serum pH, sodium, potassium, ionised calcium, bicarbonate
-- From laboratory bloods: serum sodium, potassium, urea, creatinine
-- We also want some haemofiltration variables to determine how long filter sets last...(see further down)
------------
-- Locating the required variables:
------------
-- Sodium (bloods and labs, both stored in PtLabResult)
SELECT TOP 10 * FROM D_Intervention WHERE longLabel='Na' --726
SELECT * FROM D_Attribute WHERE attributeId in (SELECT DISTINCT(attributeId) FROM PtLabResult WHERE interventionId=726)
-- attributeId 7868 Na.Sodium.Sodium
SELECT TOP 100 * FROM D_Intervention WHERE longLabel like '%sodium%' and type='LabTest' --541, 706
SELECT TOP 10 * FROM PtLabResult WHERE interventionId=541 -- 541 not in use
SELECT COUNT(DISTINCT(attributeId)) FROM PtLabResult WHERE interventionId=706 -- 3 attributes
SELECT * FROM D_Attribute WHERE attributeId in (SELECT DISTINCT(attributeId) FROM PtLabResult WHERE interventionId=706)
-- attributeId 1865 Sodium.Sodium.Sodium contains the value.
-- How frequently in use?
SELECT TOP 20 D.interventionId, D.longLabel, COUNT(DISTINCT(P.encounterId)) AS count
FROM D_Intervention D
INNER JOIN PtLabResult P
ON D.interventionId=P.interventionId
WHERE P.clinicalUnitId=5 AND D.interventionId in (726, 706)
GROUP BY D.interventionId, D.longLabel
ORDER BY count DESC
-- 706	Sodium	5624
-- 726	Na	5475

------------
-- Potassium (bloods and labs, both stored in PtLabResult)
SELECT TOP 10 * FROM D_Intervention WHERE longLabel='K' --725
SELECT * FROM D_Attribute WHERE attributeId in (SELECT DISTINCT(attributeId) FROM PtLabResult WHERE interventionId=725)
-- attributeId 6138 K.Potassium.Potassium 
SELECT TOP 100 * FROM D_Intervention WHERE longLabel like '%potassium%' and type='LabTest' --510, 646
SELECT TOP 10 * FROM PtLabResult WHERE interventionId=646 -- 646 not in use
SELECT COUNT(DISTINCT(attributeId)) FROM PtLabResult WHERE interventionId=510 -- 3 attributes
SELECT * FROM D_Attribute WHERE attributeId in (SELECT DISTINCT(attributeId) FROM PtLabResult WHERE interventionId=510)
-- attributeId 20878 Potassium.Potassium.Potassium contains the value.
-- How frequently in use?
SELECT TOP 20 D.interventionId, D.longLabel, COUNT(DISTINCT(P.encounterId)) AS count
FROM D_Intervention D
INNER JOIN PtLabResult P
ON D.interventionId=P.interventionId
WHERE P.clinicalUnitId=5 AND D.interventionId in (725, 510)
GROUP BY D.interventionId, D.longLabel
ORDER BY count DESC
-- 510	Potassium	5625
-- 725	K	5474

------------
-- pH (blood gas) 
SELECT TOP 10 * FROM D_Intervention WHERE longLabel='pH' or shortLabel='pH'
-- How frequently in use?
SELECT TOP 20 D.interventionId, D.longLabel, COUNT(DISTINCT(P.encounterId)) AS count
FROM D_Intervention D
INNER JOIN PtLabResult P
ON D.interventionId=P.interventionId
WHERE P.clinicalUnitId=5 AND D.longLabel='pH'
GROUP BY D.interventionId, D.longLabel
-- 730	pH	1423
-- 13965	pH	3813
SELECT COUNT(DISTINCT(attributeId)) FROM PtLabResult WHERE interventionId=730 -- 2 attributes
SELECT * FROM D_Attribute WHERE attributeId in (SELECT DISTINCT(attributeId) FROM PtLabResult WHERE interventionId=730)
-- attributeId 8960 pH.Arterial pH.Arterial pH contains the value.
SELECT COUNT(DISTINCT(attributeId)) FROM PtLabResult WHERE interventionId=13965 -- 3 attributes
SELECT * FROM D_Attribute WHERE attributeId in (SELECT DISTINCT(attributeId) FROM PtLabResult WHERE interventionId=13965)
-- attributeId 37493 and 37492 pH.pH.pH may contain value?
-- Double check attribute usage for pH intervention 13965:
SELECT TOP 20 D.interventionId, D.longLabel, A.attributeId, COUNT(DISTINCT(P.encounterId)) AS count
FROM D_Intervention D
INNER JOIN PtLabResult P
ON D.interventionId=P.interventionId
INNER JOIN D_Attribute A
ON A.attributeId=P.attributeId
WHERE P.clinicalUnitId=5 AND D.interventionId=13965
GROUP BY D.interventionId, D.longLabel, A.attributeId
-- 13965	pH	37497	4067
-- 13965	pH	37493	4067
--- So attribute 37492 not in use although defined.

------------
-- Ionised calcium Ca++ (blood gas)
SELECT TOP 10 * FROM D_Intervention WHERE longLabel='Ca++' --721 (and 48954 free form?)
SELECT * FROM D_Attribute WHERE attributeId in (SELECT DISTINCT(attributeId) FROM PtLabResult WHERE interventionId=721)
-- attributeId 9668 Ca++.Calcium.Calcium
SELECT * FROM D_Attribute WHERE attributeId in (SELECT DISTINCT(attributeId) FROM PtLabResult WHERE interventionId=48954)
-- attributeId 16240 Free Form Lab Test Value
SELECT TOP 100 * FROM D_Intervention WHERE longLabel like '%calcium%' and type='LabTest' --484, 708
SELECT TOP 10 * FROM PtLabResult WHERE interventionId=708 -- 484 and 708 not in use
-- How frequently in use?
SELECT TOP 20 D.interventionId, D.longLabel, COUNT(DISTINCT(P.encounterId)) AS count
FROM D_Intervention D
INNER JOIN PtLabResult P
ON D.interventionId=P.interventionId
WHERE P.clinicalUnitId=5 AND D.interventionId in (721, 48954)
GROUP BY D.interventionId, D.longLabel
ORDER BY count DESC
-- 721	Ca++	5474
-- 48954	Ca++	351
-- How does Free form entry look compared to standard?
SELECT TOP 10 * FROM PtLabResult WHERE interventionId=721
SELECT TOP 10 * FROM PtLabResult WHERE interventionId=48954
-- Data stored as string! Use valueString

------------
-- Bicarbonate HCO3 (blood gas)
SELECT TOP 10 * FROM D_Intervention WHERE longLabel like '%hco3%' --720 (and three different from 'Free Form Lab' - see below)
SELECT * FROM D_Attribute WHERE attributeId in (SELECT DISTINCT(attributeId) FROM PtLabResult WHERE interventionId=720)
-- attributeId 2880 HCO3-std.Standard HCO3.Standard HCO3
-- How frequently in use?
SELECT TOP 20 D.interventionId, D.longLabel, COUNT(DISTINCT(P.encounterId)) AS count
FROM D_Intervention D
INNER JOIN PtLabResult P
ON D.interventionId=P.interventionId
WHERE P.clinicalUnitId=5 AND D.longLabel like '%hco3%'
GROUP BY D.interventionId, D.longLabel
ORDER BY count DESC
-- 720	HCO3-std	5473
-- 4328	HCO3-(c)	5282
-- 48959	HCO3 std	351
-- 48958	HCO3(c)	344
SELECT TOP 10 * FROM PtLabResult WHERE interventionId=4328
-- 4328, 48959, 48958 are all type 'Free Form Lab' and we need to use valueString
-- (only single attributes)
SELECT * FROM D_Attribute WHERE attributeId in (SELECT DISTINCT(attributeId) FROM PtLabResult WHERE interventionId in (4328, 48959, 48958))
-- attributeId 16240 (as above for Free form)

------------
-- Urea(laboratory)
SELECT TOP 10 * FROM D_Intervention WHERE longLabel='urea' --785,789,19505 (19505 is 'Free Form Lab')
-- How frequently in use?
SELECT TOP 20 D.interventionId, D.longLabel, COUNT(DISTINCT(P.encounterId)) AS count
FROM D_Intervention D
INNER JOIN PtLabResult P
ON D.interventionId=P.interventionId
WHERE P.clinicalUnitId=5 AND D.interventionId in (785,789,19505)
GROUP BY D.interventionId, D.longLabel
ORDER BY count DESC
-- 789	Urea	5626
-- 19505	Urea	4
SELECT * FROM D_Attribute WHERE attributeId in (SELECT DISTINCT(attributeId) FROM PtLabResult WHERE interventionId=789)
-- attributeId 20789 Urea.Urea.Urea

------------
-- Creatinine(laboratory)
SELECT TOP 10 * FROM D_Intervention WHERE longLabel='creatinine' --421,757,758,19504 (19504 is 'Free Form Lab')
-- How frequently in use?
SELECT TOP 20 D.interventionId, D.longLabel, COUNT(DISTINCT(P.encounterId)) AS count
FROM D_Intervention D
INNER JOIN PtLabResult P
ON D.interventionId=P.interventionId
WHERE P.clinicalUnitId=5 AND D.interventionId in (421,757,758,19504)
GROUP BY D.interventionId, D.longLabel
ORDER BY count DESC
-- 758	Creatinine	5634
-- 19504	Creatinine	4
SELECT * FROM D_Attribute WHERE attributeId in (SELECT DISTINCT(attributeId) FROM PtLabResult WHERE interventionId=758)
-- attributeId 12200 Creatinine.Creatinine.Creatinine

---------------------------------------------------------------------------------------------
-- We have now identified all the relevant variables in the labresults table (and their attributes).
-- We now extract the relevant columns in a single query and save to file (post-process in python script).
---------------------------------------------------------------------------------------
-- List of intervention and attribute Ids that we want from lab results table: 
declare @LabResIDs table (id int);
insert @LabResIDs(id) values (726), (706), (725), (510), (730), (13965),(721), (48954), (720), (4328), (48959), (48958), (789), (19505), (758), (19504);
declare @LabResAIDs table (id int);
insert @LabResAIDs(id) values (7868), (1865), (6138), (20878), (8960), (37493),(9668), (16240), (2880), (20789), (12200);
---------------------------------------------------------------------------------------------------------------------------------------------------
-- Save output of this query:
SELECT P.encounterId, D.interventionId, CONVERT(varchar,P.chartTime,20) AS chartTime, CONVERT(varchar,P.storeTime,20) AS storeTime, D.longLabel, P.attributeId, REPLACE(valueString,'	',' ') AS valueString, P.valueNumber, A.longLabel as attribute
FROM D_Intervention D
INNER JOIN PtLabResult P
	ON D.interventionId=P.interventionId
INNER JOIN D_Attribute A
	ON A.attributeId=P.attributeId
INNER JOIN PtCensus C
	ON P.encounterId = C.encounterId
WHERE P.clinicalUnitId=5 AND D.interventionId IN (select id from @LabResIDs) AND A.attributeId IN (select id from @LabResAIDs) AND C.inTime>'2015-01-31 23:59:59' AND C.lengthOfStay>15 AND P.encounterId NOT IN (
	SELECT DISTINCT(E.encounterId)
	FROM PtCensus P
	INNER JOIN(
		SELECT ptCensusId, encounterId, lengthOfStay FROM PtCensus WHERE clinicalUnitId=5 AND lengthOfStay>15
		) as E
		ON P.encounterId = E.encounterId
	WHERE P.ptCensusId <> E.ptCensusId
	)
ORDER BY P.encounterId, D.interventionId, chartTime ASC
---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

-- We now locate the variables from the haemofiltration flowsheet, which are stored in the ptAssessment table:
SELECT TOP 10 * FROM D_Intervention WHERE longLabel='First Checker' -- 27157
SELECT DISTINCT(attributeId) FROM PtAssessment WHERE interventionId=27157 -- 47889
SELECT TOP 10 * FROM D_Intervention WHERE longLabel='Filter In Use' -- 27436
SELECT DISTINCT(attributeId) FROM PtAssessment WHERE interventionId=27436 -- 47918
SELECT TOP 10 * FROM D_Intervention WHERE longLabel='Reason For Filter Loss' -- 5540
SELECT DISTINCT(attributeId) FROM PtAssessment WHERE interventionId=5540 -- 26342

SELECT TOP 10 * FROM D_Intervention WHERE longLabel='Filter Set' -- 3444, 38417
SELECT DISTINCT(attributeId) FROM PtAssessment WHERE interventionId IN (3444,38417) -- 7079,52328
SELECT * FROM D_Attribute WHERE attributeId in (SELECT DISTINCT(attributeId) FROM PtAssessment WHERE interventionId in (3444,38417))
-- 7079	NULL	Filter Set	Filter Set.Filter Set	Hemofiltration (procedure)	233581009	0
-- 52328	NULL	Filter Set	Filter Set.Filter Set	Hemofiltration (procedure)	233581009	0

SELECT TOP 10 * FROM D_Intervention WHERE longLabel='Therapy Run Time' -- 3427
SELECT DISTINCT(attributeId) FROM PtAssessment WHERE interventionId IN (3427) -- 10769
SELECT TOP 10 * FROM D_Intervention WHERE longLabel='Therapy Type' -- 3437
SELECT DISTINCT(attributeId) FROM PtAssessment WHERE interventionId IN (3437) -- 4990
SELECT TOP 10 * FROM D_Intervention WHERE shortLabel='Exch Rate' -- 3443
SELECT DISTINCT(attributeId) FROM PtAssessment WHERE interventionId IN (3443) -- 9463
SELECT TOP 10 * FROM D_Intervention WHERE shortLabel='Dialysate Flow Rate' -- 3438
SELECT DISTINCT(attributeId) FROM PtAssessment WHERE interventionId IN (3438) -- 16449

SELECT TOP 10 * FROM D_Intervention WHERE shortLabel='Calcium Dose' -- 33798,35307,38416
SELECT DISTINCT(attributeId) FROM PtAssessment WHERE interventionId IN (33798,35307,38416) -- 52326,52181,51209
SELECT * FROM D_Attribute WHERE attributeId in (SELECT DISTINCT(attributeId) FROM PtAssessment WHERE interventionId in (33798,35307,38416))

SELECT TOP 10 * FROM D_Intervention WHERE shortLabel='Calcium Chloride Dose Adjustment' -- 34730
SELECT DISTINCT(attributeId) FROM PtAssessment WHERE interventionId IN (34730) -- 51781
SELECT TOP 10 * FROM D_Intervention WHERE shortLabel='Citrate Dose' -- 3430,34876
SELECT DISTINCT(attributeId) FROM PtAssessment WHERE interventionId IN (3430,34876) -- 51845,10971
SELECT * FROM D_Attribute WHERE attributeId in (SELECT DISTINCT(attributeId) FROM PtAssessment WHERE interventionId in (3430,34876))

SELECT TOP 10 * FROM D_Intervention WHERE shortLabel='Citrate Dose Adjustment' -- 34727
SELECT DISTINCT(attributeId) FROM PtAssessment WHERE interventionId IN (34727) -- 51783
SELECT TOP 10 * FROM D_Intervention WHERE shortLabel='Fluid Removed' -- 3432
SELECT DISTINCT(attributeId) FROM PtAssessment WHERE interventionId IN (3432) -- 8236
SELECT TOP 10 * FROM D_Intervention WHERE shortLabel='Blood Flow Rate' -- 3447
SELECT DISTINCT(attributeId) FROM PtAssessment WHERE interventionId IN (3447) -- 22496
SELECT TOP 10 * FROM D_Intervention WHERE shortLabel='Return (Venous) Pressure' -- 3428
SELECT DISTINCT(attributeId) FROM PtAssessment WHERE interventionId IN (3428) -- 1477 
SELECT TOP 10 * FROM D_Intervention WHERE shortLabel='Pre-Filter Pressure' -- 33794
SELECT DISTINCT(attributeId) FROM PtAssessment WHERE interventionId IN (33794) -- 51229

-- We now extract these variables and save them to file for post-processing in python.
---------------------------------------------------------------------------------------
-- List of intervention and attribute Ids that we want from patient assessment table: 
declare @PtAssIDs table (id int);
insert @PtAssIDs(id) values (27157), (27436), (5540), (3444), (38417), (3427),(3437), (3443), (3483), (33798), (35307), (38416), (34730), (3430), (34876), (34727), (3432), (3447), (3428), (33794);
---------------------------------------------------------------------------------------------------------------------------------------------------
-- Save output of this query:
SELECT P.encounterId, D.interventionId, CONVERT(varchar,P.chartTime,20) AS chartTime, CONVERT(varchar,P.storeTime,20) AS storeTime, D.longLabel, P.attributeId, REPLACE(valueString,'	',' ') AS valueString, P.valueNumber, A.longLabel as attribute
FROM D_Intervention D
INNER JOIN PtAssessment P
	ON D.interventionId=P.interventionId
INNER JOIN D_Attribute A
	ON A.attributeId=P.attributeId
INNER JOIN PtCensus C
	ON P.encounterId = C.encounterId
WHERE P.clinicalUnitId=5 AND D.interventionId IN (select id from @PtAssIDs) AND C.inTime>'2015-01-31 23:59:59' AND C.lengthOfStay>15 AND P.encounterId NOT IN (
	SELECT DISTINCT(E.encounterId)
	FROM PtCensus P
	INNER JOIN(
		SELECT ptCensusId, encounterId, lengthOfStay FROM PtCensus WHERE clinicalUnitId=5 AND lengthOfStay>15
		) as E
		ON P.encounterId = E.encounterId
	WHERE P.ptCensusId <> E.ptCensusId
	)
ORDER BY P.encounterId, D.interventionId, chartTime ASC
---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
