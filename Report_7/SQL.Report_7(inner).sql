---------------------------ПАРАМЕТРЫ-------------------------------
--DECLARE @DateStart DateTime2
--DECLARE @DateEnd DateTime2
--DECLARE @Member nvarchar(255)
--SET @DateStart = '2021-04-01'
--SET @DateEnd = '2021-06-01'
--SET @Member = 'ecc99082-f3b4-4028-8007-a7f69d6cd1d7' --АО ДОМ.РФ
-------------------------------------------------------------------

IF OBJECT_ID('tempdb..#Tmp') is not null
	DROP TABLE #Tmp

CREATE TABLE #Tmp (
					PackageId INT
					,LogId BIGINT
					,ReceivedOn Datetime2 (7)
)

INSERT INTO #Tmp
	SELECT --ActualPackages = обработанные пакеты с последним логом в период отчета
		ActualLog.PackageId
		,ProcessedPackage.LogId
		,ProcessedPackage.ReceivedOn
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
			,ValidationLog.Id		AS LogId
			,ValidationLog.ValidatedOn
			,Package.ReceivedOn
		FROM Package
		INNER JOIN ValidationLog
			ON ValidationLog.Package = Package.Id
		WHERE
			Processed = 1
			AND Success = 1
			AND Incoming = 0 --только исходящие пакеты
			AND Package.ReceivedOn >=  DATETIMEFROMPARTS(DATEPART(YEAR, @DateStart), DATEPART(MONTH, @DateStart), DATEPART(DAY, @DateStart), '0', '0', '0', '0') --начало периода отчета
			AND Package.ReceivedOn < DATETIMEFROMPARTS(DATEPART(YEAR, @DateEnd), DATEPART(MONTH, @DateEnd), DATEPART(DAY, @DateEnd), '23', '59', '59', '0') --окончание периода отчета
	) AS ProcessedPackage
		ON ProcessedPackage.Package = ActualLog.PackageId
		AND ProcessedPackage.ValidatedOn = ActualLog.Max_ValidatedOn



SELECT --Перечень ТК использующих/не использующих ЭП (отформатированная таблица)
	ES_in_ED_TC.PackageId
	,MAX(ES_in_ED)			AS ES_in_ED
	,MAX(ES_in_TC)			AS ES_in_TC
	,ES_in_ED_TC.ReceivedOn
FROM (
	SELECT --Перечень ТК использующих/не использующих ЭП
		#Tmp.PackageId
		,IIF(Score.Value <> 0 and Score.Criterion = '3.13', 1, 0) AS ES_in_ED --Электронная подпись в ЭД
		,IIF(Score.Value <> 0 and Score.Criterion = '3.14', 1, 0) AS ES_in_TC --Электронная подпись в ТК
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

