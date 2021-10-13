---------------------------���������-------------------------------
--DECLARE @DateStart DateTime2
--DECLARE @DateEnd DateTime2
--SET @DateStart = '2021-03-01'
--SET @DateEnd = '2021-06-01'
-------------------------------------------------------------------

IF OBJECT_ID('tempdb..#Tmp') is not null
	DROP TABLE #Tmp

CREATE TABLE #Tmp (LogId BIGINT NOT NULL)

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
			AND Package.ReceivedOn < DATEADD(DAY, 1, DATETIMEFROMPARTS(DATEPART(YEAR, @DateEnd), DATEPART(MONTH, @DateEnd), DATEPART(DAY, @DateEnd), '0', '0', '0', '0')) --����� ������� ������
	) AS ProcessedPackage
		ON ProcessedPackage.Package = ActualLog.PackageId
		AND ProcessedPackage.ValidatedOn = ActualLog.Max_ValidatedOn

SELECT --����������� ������� �� ������������� �� � ����������
	DENSE_RANK() OVER	(
							PARTITION BY 
								MemberType 
							ORDER BY 
								ROUND(100*(Prop_ES_in_ED + Prop_ES_in_TC)/2, 2) DESC
						)								AS Rank		--������� � ��������
	,*
FROM (	
	SELECT --����������� ������� �� ������������� �� � ����������
		Member.Name
		,Member.Type										AS MemberType
		,ROUND(100*(Prop_ES_in_ED + Prop_ES_in_TC)/2, 2)	AS Rating	--������ ���������
		,Count_ED
		,ISNULL(SUM_ES_in_ED, 0)							AS SUM_ES_in_ED
		,ISNULL(SUM_ES_in_TC, 0)							AS SUM_ES_in_TC
		,ISNULL(ROUND(Prop_ES_in_ED, 4), 0)					AS Prop_ES_in_ED
		,ISNULL(ROUND(Prop_ES_in_TC, 4), 0)					AS Prop_ES_in_TC
	FROM (
		SELECT --���������� �� ������������� �� � �� �� ������� ���������
			MemberGuid									
			,IIF(MemberGuid is not null, COUNT(*), 0)			AS Count_ED			--����� ����������
			,SUM(ES_in_ED)										AS SUM_ES_in_ED		--����� �� � ��������
			,SUM(ES_in_TC)										AS SUM_ES_in_TC		--����� �� � ��������
			,SUM(CAST(ES_in_ED AS FLOAT))/COUNT(*)				AS Prop_ES_in_ED	--���� �� � ��������
			,SUM(CAST(ES_in_TC AS FLOAT))/COUNT(*)				AS Prop_ES_in_TC	--���� �� � ��������
		FROM (
			SELECT --�������� �� ������������/�� ������������ ��
				MemberGuid
				,MAX(ES_in_ED) AS ES_in_ED
				,MAX(ES_in_TC) AS ES_in_TC
			FROM (
				SELECT --�������� �� ������������/�� ������������ ��
					Score.ValidationLog
					,Score.MemberGuid
					,IIF(Score.Value <> 0 and Score.Criterion = '3.13', 1, 0) AS ES_in_ED --����������� ������� � ��
					,IIF(Score.Value <> 0 and Score.Criterion = '3.14', 1, 0) AS ES_in_TC --����������� ������� � ��
				FROM #Tmp 
				INNER JOIN Score
					ON Score.ValidationLog = #Tmp.LogId
				WHERE 
					Score.Criterion IN ('3.13', '3.14')
			) AS SIG_in_ED_TC
			GROUP BY
				ValidationLog	
				,MemberGuid
		) AS Using_SIG
		GROUP BY 
			MemberGuid
	) AS Stats_SIG
	RIGHT JOIN Member
		ON Member.Guid = Stats_SIG.MemberGuid
	WHERE
		Member.Active = 1
) AS Score_SIG