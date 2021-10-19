---------------------------���������-------------------------------
--DECLARE @DateStart DateTime2
--DECLARE @DateEnd DateTime2
--DECLARE @Member nvarchar(255)
--SET @DateStart = '2021-01-01'
--SET @DateEnd = '2021-06-01'
--SET @Member = 'ecc99082-f3b4-4028-8007-a7f69d6cd1d7'; --�� ���.��
-------------------------------------------------------------------

WITH #Tmp AS (
	SELECT --ActualPackages = ������������ ������ � ��������� ����� � ������ ������
		ActualLog.PackageId
		,ProcessedPackage.LogId
		,ProcessedPackage.ReceivedOn
	FROM(
		SELECT -- ActualLog = ��������� ��� �� ������
			ValidationLog.Package			AS PackageId
			,MAX(ValidationLog.ValidatedOn)	AS Max_ValidatedOn
		FROM ValidationLog		
		WHERE
			Success = 1
		GROUP BY
			ValidationLog.Package
	) AS ActualLog
	INNER JOIN (
		SELECT --ProcessedPackage = ������������ ������ � ������ ������
			ValidationLog.Package
			,ValidationLog.Id			AS LogId
			,ValidationLog.ValidatedOn
			,Package.ReceivedOn
		FROM Package
		--INNER JOIN Batch
		--	ON Package.Batch = Batch.Id
		INNER JOIN ValidationLog
			ON ValidationLog.Package = Package.Id
		WHERE
			Processed = 1
		--	AND MemberGuid = @Member
			AND Success = 1
			AND Incoming = 0 --������ ��������� ������
			AND Package.ReceivedOn >=  DATETIMEFROMPARTS(DATEPART(YEAR, @DateStart), DATEPART(MONTH, @DateStart), DATEPART(DAY, @DateStart), '0', '0', '0', '0') --������ ������� ������
			AND Package.ReceivedOn < DATEADD(DAY, 1, DATETIMEFROMPARTS(DATEPART(YEAR, @DateEnd), DATEPART(MONTH, @DateEnd), DATEPART(DAY, @DateEnd), '0', '0', '0', '0')) --����� ������� ������
	) AS ProcessedPackage
		ON ProcessedPackage.Package = ActualLog.PackageId
		AND ProcessedPackage.ValidatedOn = ActualLog.Max_ValidatedOn )



SELECT --�������� �� � ��������� ������������� ������������ (����������������� �������)
	Using_Directory.PackageId
	,MAX(ED_Type)		AS ED_Type
	,MAX(ED_Signature)	AS ED_Signature
	,MAX(ED_Region)		AS ED_Region
	,MAX(ED_Relation)	AS ED_Relation
	,Using_Directory.ReceivedOn
FROM (
	SELECT --�������� �� � ��������� ������������� ������������
		#Tmp.PackageId
		,IIF(Score.Value <> 0 and Score.Criterion = '3.6',  1, 0)	AS ED_Type		--�������� "��� ���������"
		,IIF(Score.Value <> 0 and Score.Criterion = '3.7',  1, 0)	AS ED_Signature	--�������� "���� ���������"
		,IIF(Score.Value <> 0 and Score.Criterion = '3.8',  1, 0)	AS ED_Region	--�������� "������ ���������"
		,IIF(Score.Value <> 0 and Score.Criterion = '3.11', 1, 0)	AS ED_Relation	--�������� "��� ����� ���������"
		,#Tmp.ReceivedOn
	FROM #Tmp 
	INNER JOIN Score
		ON Score.ValidationLog = #Tmp.LogId
	WHERE 
		Score.Criterion IN ('3.6', '3.7', '3.8', '3.11')
		AND Score.MemberGuid = @Member
) AS Using_Directory
GROUP BY
	Using_Directory.PackageId
	,Using_Directory.ReceivedOn

