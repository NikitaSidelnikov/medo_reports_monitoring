---------------------------ПАРАМЕТРЫ-------------------------------
--DECLARE @Member CHAR(36)
--DECLARE @DateStart DateTime2
--DECLARE @DateEnd DateTime2
--SET @Member = 'ecc99082-f3b4-4028-8007-a7f69d6cd1d7'
--SET @DateStart = '2021-04-01'
--SET @DateEnd = '2021-06-01'
-------------------------------------------------------------------


if object_id('tempdb..#tmp_ValidationLog') is not null
	DROP TABLE #tmp_ValidationLog

CREATE TABLE #tmp_ValidationLog (
								LogId BIGINT PRIMARY KEY
								,Incoming BIT
								,ReceivedOn DATETIME2(7)
							) --Таблица всех валидных последних логов

INSERT INTO #tmp_ValidationLog  
	SELECT -- ActualLogs - Id последних валидных логов по каждому обработанному пакету в период отчета
		ValidationLog.Id		AS LogId
		,SuccesPackage.Incoming
		,SuccesPackage.ReceivedOn
	FROM
		ValidationLog		
	INNER JOIN (
		SELECT -- SuccesPackage = даты последних валидных логов по каждому обработанному пакету в период отчета. Если у пакета несколько логов валидаций, то для каждого запоминаем свой ValidatedOn и максимальный ValidatedOn по пакету. А потом сравним их и отберем те, что равны
			SuccesLogs.Package		AS PackageId
			,SuccesLogs.Incoming
			,SuccesLogs.ValidatedOn
			,MAX(SuccesLogs.ValidatedOn) OVER (PARTITION BY SuccesLogs.Package)	AS Max_ValidatedOn
			,SuccesLogs.ReceivedOn	
		FROM (	
			SELECT -- SuccesLogs = все валидные логи по всем обработанным пакетам в период отчета
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
				AND Incoming = 0
				AND ReceivedOn >=  DATETIMEFROMPARTS(DATEPART(YEAR, @DateStart), DATEPART(MONTH, @DateStart), DATEPART(DAY, @DateStart), '0', '0', '0', '0') --начало периода отчета
				AND ReceivedOn < DATETIMEFROMPARTS(DATEPART(YEAR, @DateEnd), DATEPART(MONTH, @DateEnd), DATEPART(DAY, @DateEnd), '23', '59', '59', '0') --конец периода отчета				
		) AS SuccesLogs
	) AS SuccesPackage
		ON SuccesPackage.PackageId = ValidationLog.Package
		AND SuccesPackage.Max_ValidatedOn = ValidationLog.ValidatedOn
	WHERE
		SuccesPackage.Max_ValidatedOn = SuccesPackage.ValidatedOn

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
		ScoreGrouped.Criterion	
		,AVG(ScoreGrouped.Value)	AS AvgScore
	FROM #tmp_ValidationLog
	INNER JOIN ( --ScoreGrouped = оценки всех пакетов с удалением дубликатов оценок по критериям
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
	INNER JOIN Member
		ON Member.Guid = ScoreGrouped.MemberGuid
	WHERE 
		Member.Guid = @Member
	GROUP BY
		ScoreGrouped.Criterion	
) AS ScoreLog
RIGHT JOIN Criterion
	ON Criterion.Code = ScoreLog.Criterion
INNER JOIN CriterionGroup
	ON Criterion.CriterionGroup = CriterionGroup.Id



