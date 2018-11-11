--1. INPUT : Id
--Mostrar los pacientes
SELECT * FROM Patient
WHERE patientId = Id

--2. INPUT: Id
--Mostrar las visitas
SELECT visitId, vDate, motive AS 'P.E.E.A.', resumen FROM Visit
WHERE patientId = Id 

--3. INPUT: Id
--Mostrar los diagnosticos
SELECT v.visitId, vDate, ICD9CM, ICD10CM, DSM5 AS Diagnostico
FROM Visit v JOIN Diagnosis_details dd ON v.visitId = dd.visitId
JOIN Diagnosis d ON dd.dCode = d.dCode
WHERE v.patientId = Id

--4. INPUT: Id
--Mostrar medicinas recetadas
SELECT v.visitId, vDate, medName, ingredientName, quantity, typeOfDosis, laboratory, instructions
FROM Visit v JOIN Prescription p ON v.visitId = p.visitId
JOIN Prescription_details pd ON p.prescriptionId = pd.prescriptionId
JOIN Medicament m ON pd.medId = m.medId
WHERE v.patientId = Id

--5. INPUT: Id
--Mostrar examenes
SELECT t.*, descriptor
FROM (
	SELECT i.instanceId, i.testId, vDate, SUM(value) AS puntuacion
	FROM Response r JOIN Instance i ON r.instanceId = i.instanceId
	JOIN Visit v ON i.visitId = v.visitId
	WHERE v.patientId = Id
	GROUP BY instanceId
) t
LEFT JOIN Test_scale ts ON ts.testId = t.testId AND puntuacion BETWEEN ts.lowLimit AND ts.highLimit

--6. INPUT: Id
--Mostrar instancia de examen
SELECT questionTitle, questionInstructions, value FROM Question q
JOIN Response r ON q.questionId = r.questionId
WHERE instanceId = Id

--7. Input: patientScore
--Mostrar examenes con puntuacion minima k
SELECT t.*, descriptor
FROM (
    SELECT i.instanceId, i.testId, vDate, SUM(value) AS puntuacion
    FROM Response r JOIN Instance i ON r.instanceId = i.instanceId
    JOIN Visit v ON i.visitId = v.visitId
    GROUP BY instanceId
    HAVING puntuacion >= patientScore
) t
LEFT JOIN Test_scale ts ON ts.testId = t.testId AND puntuacion BETWEEN ts.lowLimit AND ts.highLimit

--8. Input: patientName
--Mostrar datos con nombre patientName
SELECT * FROM Patient
WHERE fName = patientName OR lName = patientName 
    OR fname + lName = patientName

--Delete Patient EHR
DELETE FROM Prescription_details WHERE prescriptionId IN (
    SELECT prescriptionId FROM Visit
    JOIN Prescription ON Visit.visitId = Prescription.visitId
    WHERE Visit.patientId = Id);
    
DELETE FROM Prescription WHERE visitId IN (
    SELECT visitId FROM Visit
    WHERE Visit.patientId = Id);
    
DELETE FROM Diagnosis_details WHERE visitId IN (
    SELECT visitId FROM Visit
    WHERE Visit.patientId = Id);
    
DELETE FROM Response WHERE instanceId IN (
    SELECT instanceId FROM Visit
    JOIN Instance ON Visit.visitId = Instance.visitId
    WHERE Visit.patientId = Id);
    
DELETE FROM Instance WHERE visitId IN (
    SELECT visitId FROM Visit
    WHERE Visit.patientId = Id);
    
DELETE FROM Visit WHERE patientId = Id;

DELETE FROM Patient WHERE patientId = Id;

