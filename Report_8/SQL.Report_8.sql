---------------------------ПАРАМЕТРЫ-------------------------------
--DECLARE @Member CHAR(36)
--DECLARE @DateStart DateTime2
--DECLARE @DateEnd DateTime2
--SET @Member = '853db228-05e8-4b45-92ee-19debef3039f'
--SET @DateStart = '2021-04-01'
--SET @DateEnd = '2021-08-07'
-------------------------------------------------------------------


--if object_id('tempdb..#tmp_ValidationLog') is not null
--	DROP TABLE #tmp_ValidationLog

--CREATE TABLE #tmp_ValidationLog (
--								LogId BIGINT NOT NULL
--							) --Таблица всех валидных последних логов


;with #tmp_ValidationLog  as (
	SELECT --ActualPackages = обработанные пакеты с последним логом в период отчета
		ProcessedPackage.LogId
	FROM(
		SELECT -- ActualLog = последний лог по пакету
			ValidationLog.Package			AS PackageId
			,MAX(ValidationLog.ValidatedOn)	AS Max_ValidatedOn
		FROM ValidationLog	
		WHERE 
			Success = 1
		GROUP BY
			ValidationLog.Package
	) AS ActualLog
	INNER JOIN (
		SELECT --ProcessedPackage = обработанные пакеты в период отчета
			ValidationLog.Package
			,ValidationLog.Id			AS LogId
			,ValidationLog.ValidatedOn
		FROM Package
		--INNER JOIN Batch
		--	ON Package.Batch = Batch.Id
		INNER JOIN ValidationLog
			ON ValidationLog.Package = Package.Id
		WHERE
			Processed = 1
			--AND MemberGuid = @Member
			AND Success = 1
			AND Incoming = 0 --только исходящие пакеты
			AND Package.ReceivedOn >=  DATETIMEFROMPARTS(DATEPART(YEAR, @DateStart), DATEPART(MONTH, @DateStart), DATEPART(DAY, @DateStart), '0', '0', '0', '0') --начало периода отчета
			AND Package.ReceivedOn < DATEADD(DAY, 1, DATETIMEFROMPARTS(DATEPART(YEAR, @DateEnd), DATEPART(MONTH, @DateEnd), DATEPART(DAY, @DateEnd), '0', '0', '0', '0')) --конец периода отчета
	) AS ProcessedPackage
		ON ProcessedPackage.Package = ActualLog.PackageId
		AND ProcessedPackage.ValidatedOn = ActualLog.Max_ValidatedOn
	)

SELECT  --AllCriterionGroupScore  --оценки выбранного лога пакета с учетом всех групп критериев
	CriterionGroup.Object							AS CriterionGroupName
	,CriterionGroup.Id								AS CriterionGroupId  
	,CAST(SUBSTRING(Criterion.Code, 3, 2) AS INT)	AS CriterionId  
	,Criterion.Name									AS CriterionName
	--,CriterionGroup.ScoreValue					AS MaxCriterionGroupValue
	,Criterion.ScoreValue							AS MaxCriterionValue
	,ScoreLog.AvgScore
FROM (
	SELECT --ScoreLog  --средние оценки по каждому критерию всех выбранных логов по выбраному участнику
		Score.Criterion	
		,AVG(Score.Value)	AS AvgScore
	FROM #tmp_ValidationLog
	INNER JOIN Score
		ON #tmp_ValidationLog.LogId = Score.ValidationLog
	WHERE 
		Score.MemberGuid = @Member
	GROUP BY
		Score.Criterion	
) AS ScoreLog
RIGHT JOIN Criterion
	ON Criterion.Code = ScoreLog.Criterion
INNER JOIN CriterionGroup
	ON Criterion.CriterionGroup = CriterionGroup.Id

