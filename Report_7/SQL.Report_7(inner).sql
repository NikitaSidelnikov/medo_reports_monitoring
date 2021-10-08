---------------------------���������-------------------------------
--DECLARE @DateStart DateTime2
--DECLARE @DateEnd DateTime2
--DECLARE @Member nvarchar(255)
--SET @DateStart = '2021-04-01'
--SET @DateEnd = '2021-06-01'
--SET @Member = 'ecc99082-f3b4-4028-8007-a7f69d6cd1d7' --�� ���.��
-------------------------------------------------------------------

IF OBJECT_ID('tempdb..#Tmp') is not null
	DROP TABLE #Tmp

CREATE TABLE #Tmp (
					PackageId INT
					,LogId BIGINT
					,ReceivedOn Datetime2 (7)
)

INSERT INTO #Tmp
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
			,ValidationLog.Id		AS LogId
			,ValidationLog.ValidatedOn
			,Package.ReceivedOn
		FROM Package
		INNER JOIN ValidationLog
			ON ValidationLog.Package = Package.Id
		WHERE
			Processed = 1
			AND Success = 1
			AND Incoming = 0 --������ ��������� ������
			AND Package.ReceivedOn >=  DATETIMEFROMPARTS(DATEPART(YEAR, @DateStart), DATEPART(MONTH, @DateStart), DATEPART(DAY, @DateStart), '0', '0', '0', '0') --������ ������� ������
			AND Package.ReceivedOn < DATETIMEFROMPARTS(DATEPART(YEAR, @DateEnd), DATEPART(MONTH, @DateEnd), DATEPART(DAY, @DateEnd), '23', '59', '59', '0') --��������� ������� ������
	) AS ProcessedPackage
		ON ProcessedPackage.Package = ActualLog.PackageId
		AND ProcessedPackage.ValidatedOn = ActualLog.Max_ValidatedOn



SELECT --�������� �� ������������/�� ������������ �� (����������������� �������)
	ES_in_ED_TC.PackageId
	,MAX(ES_in_ED)			AS ES_in_ED
	,MAX(ES_in_TC)			AS ES_in_TC
	,ES_in_ED_TC.ReceivedOn
FROM (
	SELECT --�������� �� ������������/�� ������������ ��
		#Tmp.PackageId
		,IIF(Score.Value <> 0 and Score.Criterion = '3.13', 1, 0) AS ES_in_ED --����������� ������� � ��
		,IIF(Score.Value <> 0 and Score.Criterion = '3.14', 1, 0) AS ES_in_TC --����������� ������� � ��
		,#Tmp.ReceivedOn
	FROM #Tmp 
	INNER JOIN Score
		ON Score.ValidationLog = #Tmp.LogId
	WHERE 
		Score.Criterion IN ('3.13', '3.14')
		AND Score.MemberGuid = @Member
) AS ES_in_ED_TC
GROUP BY
	PackageId
	,ES_in_ED_TC.ReceivedOn

