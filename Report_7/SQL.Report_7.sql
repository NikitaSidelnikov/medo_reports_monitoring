---------------------------���������-------------------------------
--DECLARE @DateStart DateTime2
--DECLARE @DateEnd DateTime2
--SET @DateStart = '2021-03-01'
--SET @DateEnd = '2021-06-01'
-------------------------------------------------------------------

IF OBJECT_ID('tempdb..#Tmp') is not null
	DROP TABLE #Tmp

CREATE TABLE #Tmp (
	LogId BIGINT
)

INSERT INTO #Tmp
	SELECT --ActualPackages = ������������ ������ � ��������� ����� � ������ ������
		ProcessedPackage.LogId
		--,ProcessedPackage.Success
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
		FROM Package
		INNER JOIN ValidationLog
			ON ValidationLog.Package = Package.Id
		WHERE
			Processed = 1
			AND Success = 1
			AND Incoming = 0 --������ ��������� ������
			AND Package.ReceivedOn >=  DATETIMEFROMPARTS(DATEPART(YEAR, @DateStart), DATEPART(MONTH, @DateStart), DATEPART(DAY, @DateStart), '0', '0', '0', '0') --������ ������� ������
			AND Package.ReceivedOn <= DATETIMEFROMPARTS(DATEPART(YEAR, @DateEnd), DATEPART(MONTH, @DateEnd), DATEPART(DAY, @DateEnd), '23', '59', '59', '0') --��������� ������� ������
	) AS ProcessedPackage
		ON ProcessedPackage.Package = ActualLog.PackageId
		AND ProcessedPackage.ValidatedOn = ActualLog.Max_ValidatedOn


SELECT --����������� ������� �� ������������� �� � ����������
	DENSE_RANK() OVER	(
							PARTITION BY 
								Final_Rating.MemberType 
							ORDER BY 
								ROUND(100*(Prop_ES_in_ED + Prop_ES_in_TC)/2, 2) DESC
						)								AS Rank		--������� � ��������
	,Final_Rating.MemberName
	,Final_Rating.MemberType
	,ROUND(100*(Prop_ES_in_ED + Prop_ES_in_TC)/2, 2)	AS Rating	--������ ���������
	,Count_ED
	,ISNULL(SUM_ES_in_ED, 0)							AS SUM_ES_in_ED
	,ISNULL(SUM_ES_in_TC, 0)							AS SUM_ES_in_TC
	,ISNULL(ROUND(Prop_ES_in_ED, 4), 0)					AS Prop_ES_in_ED
	,ISNULL(ROUND(Prop_ES_in_TC, 4), 0)					AS Prop_ES_in_TC
FROM (
	SELECT --���������� �� ������������� �� � �� �� ������� ���������
		Member.Name											AS MemberName
		,Member.Type										AS MemberType
		,IIF(Using_ES.MemberGuid is not null, COUNT(*), 0)	AS Count_ED			--����� ����������
		,SUM(ES_in_ED)										AS SUM_ES_in_ED		--����� �� � ��������
		,SUM(ES_in_TC)										AS SUM_ES_in_TC		--����� �� � ��������
		,SUM(CAST(ES_in_ED AS FLOAT))/COUNT(*)				AS Prop_ES_in_ED	--���� �� � ��������
		,SUM(CAST(ES_in_TC AS FLOAT))/COUNT(*)				AS Prop_ES_in_TC	--���� �� � ��������
	FROM (
		SELECT --�������� �� ������������/�� ������������ ��
			LogId
			,MemberGuid
			,MAX(ES_in_ED) AS ES_in_ED
			,MAX(ES_in_TC) AS ES_in_TC
		FROM (
			SELECT --�������� �� ������������/�� ������������ ��
				#Tmp.LogId
				,Score.MemberGuid
				,IIF(Score.Value <> 0 and Score.Criterion = '3.13', 1, 0) AS ES_in_ED --����������� ������� � ��
				,IIF(Score.Value <> 0 and Score.Criterion = '3.14', 1, 0) AS ES_in_TC --����������� ������� � ��
			FROM #Tmp 
			INNER JOIN Score
				ON Score.ValidationLog = #Tmp.LogId
			WHERE 
				Score.Criterion IN ('3.13', '3.14')
		) AS ES_in_ED_TC
		GROUP BY
			MemberGuid
			,LogId
	) AS Using_ES
	RIGHT JOIN Member
		ON Member.Guid = Using_ES.MemberGuid
	WHERE
		Member.Active = 1
	GROUP BY 
		Member.Name
		,Member.Type
		,Using_ES.MemberGuid
) AS Final_Rating
