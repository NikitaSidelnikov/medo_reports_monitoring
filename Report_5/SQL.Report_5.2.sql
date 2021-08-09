---------------------------���������-------------------------------
--DECLARE @DateStart DateTime2
--DECLARE @DateEnd DateTime2
--SET @DateStart = '2021-04-01'
--SET @DateEnd = '2021-06-01'
-------------------------------------------------------------------

if object_id('tempdb..#tmp_ValidationLog') is not null
	DROP TABLE #tmp_ValidationLog

CREATE TABLE #tmp_ValidationLog (
								LogId BIGINT PRIMARY KEY
								,Incoming BIT
								,ReceivedOn DATETIME2(7)
							) --������� ���� �������� ��������� �����

INSERT INTO #tmp_ValidationLog  
	SELECT -- ActualLogs - Id ��������� �������� ����� �� ������� ������������� ������ � ������ ������
		ValidationLog.Id		AS LogId
		,SuccesPackage.Incoming
		,SuccesPackage.ReceivedOn
	FROM
		ValidationLog		
	INNER JOIN (
		SELECT -- SuccesPackage = ���� ��������� �������� ����� �� ������� ������������� ������ � ������ ������. ���� � ������ ��������� ����� ���������, �� ��� ������� ���������� ���� ValidatedOn � ������������ ValidatedOn �� ������. � ����� ������� �� � ������� ��, ��� �����
			SuccesLogs.Package		AS PackageId
			,SuccesLogs.Incoming
			,SuccesLogs.ValidatedOn
			,MAX(SuccesLogs.ValidatedOn) OVER (PARTITION BY SuccesLogs.Package)	AS Max_ValidatedOn
			,SuccesLogs.ReceivedOn	
		FROM (	
			SELECT -- SuccesLogs = ��� �������� ���� �� ���� ������������ ������� � ������ ������
				ValidationLog.Package
				,ValidationLog.ValidatedOn
				,Package.Incoming
				,Package.ReceivedOn
			FROM
				ValidationLog
			INNER JOIN Package
				ON Package.Id = ValidationLog.Package
			WHERE 
				ValidationLog.Success = 1
				AND Package.Processed = 1
		) AS SuccesLogs
	) AS SuccesPackage
		ON SuccesPackage.PackageId = ValidationLog.Package
		AND SuccesPackage.Max_ValidatedOn = ValidationLog.ValidatedOn
	WHERE
		SuccesPackage.Max_ValidatedOn = SuccesPackage.ValidatedOn

SELECT
	Member.Guid
	,Member.Name
	,Member.Type									AS MemberType
	,CriterionGroup
	,Criterion.Code									AS Criterion
	,MAX(CountCriterion) OVER (PARTITION BY MemberGuid, CAST(SUBSTRING(Criterion, 1, 1) AS INT)) AS MaxCountCriterion
	,AvgValue
FROM (
		SELECT -- AvgScore = ������� ������ �� ������� �������� ��� ������� ���������
			ScoreGrouped.MemberGuid
			--,ScoreGrouped.CriterionGroup
			,ScoreGrouped.Criterion
			--,#tmp_ValidationLog.LogId
			,COUNT(CAST(SUBSTRING(ScoreGrouped.Criterion, 1, 1) AS INT))	AS CountCriterion  
			,AVG(ScoreGrouped.Value)										AS AvgValue
		FROM
			#tmp_ValidationLog --������� ���� �������� ��������� �����
		INNER JOIN ( --ScoreGrouped = ������ ���� �������
			SELECT
				DISTINCT 
				Score.ValidationLog
				,Score.Value
				,Score.MemberGuid
				--,Criterion.CriterionGroup
				,Score.Criterion
			FROM
				Score 
		) AS ScoreGrouped
			ON #tmp_ValidationLog.LogId = ScoreGrouped.ValidationLog
		WHERE
			#tmp_ValidationLog.Incoming = 0
			AND #tmp_ValidationLog.ReceivedOn >=  DATETIMEFROMPARTS(DATEPART(YEAR, @DateStart), DATEPART(MONTH, @DateStart), DATEPART(DAY, @DateStart), '0', '0', '0', '0') --������ ������� ������
			AND #tmp_ValidationLog.ReceivedOn < DATETIMEFROMPARTS(DATEPART(YEAR, @DateEnd), DATEPART(MONTH, @DateEnd), DATEPART(DAY, @DateEnd), '23', '59', '59', '0') --����� ������� ������
		GROUP BY
			ScoreGrouped.MemberGuid
			--,#tmp_ValidationLog.LogId
			--,ScoreGrouped.CriterionGroup					
			,ScoreGrouped.Criterion
	) AS AvgScore
RIGHT JOIN Member
	ON Member.Guid = AvgScore.MemberGuid
FULL OUTER JOIN Criterion
	ON Criterion.Code = AvgScore.Criterion
WHERE
	IIF(Member.Guid is not null, Active, 1) = 1
