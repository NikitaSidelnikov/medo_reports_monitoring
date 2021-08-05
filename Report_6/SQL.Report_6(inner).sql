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
					PackageId INT PRIMARY KEY
					,LogId BIGINT
					,ReceivedOn Datetime2 
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
		GROUP BY
			ValidationLog.Package
	) AS ActualLog
	INNER JOIN (
		SELECT --ProcessedPackage = обработанные пакеты в период отчета
			ValidationLog.Package
			,ValidationLog.Id			AS LogId
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



SELECT --Перечень ЭД с признаком использования справочников (отформатированная таблица)
	Using_Directory.PackageId
	,MAX(ED_Type)		AS ED_Type
	,MAX(ED_Signature)	AS ED_Signature
	,MAX(ED_Region)		AS ED_Region
	,MAX(ED_Relation)	AS ED_Relation
	,Using_Directory.ReceivedOn
FROM (
	SELECT --Перечень ЭС с признаком использования справочников
		#Tmp.PackageId
		,Score.MemberGuid
		,IIF(Score.Value <> 0 and Score.Criterion = '3.6', 1, 0)	AS ED_Type		--Заполнен "Вид документа"
		,IIF(Score.Value <> 0 and Score.Criterion = '3.7', 1, 0)	AS ED_Signature	--Заполнен "Гриф документа"
		,IIF(Score.Value <> 0 and Score.Criterion = '3.8', 1, 0)	AS ED_Region	--Заполнен "Регион документа"
		,IIF(Score.Value <> 0 and Score.Criterion = '3.11', 1, 0)	AS ED_Relation	--Заполнен "Тип связи документа"
		,#Tmp.ReceivedOn
	FROM #Tmp 
	INNER JOIN Score
		ON Score.ValidationLog = #Tmp.LogId
	WHERE 
		Score.Criterion IN ('3.6', '3.7', '3.8', '3.11')
		AND Score.MemberGuid = @Member
) AS Using_Directory
INNER JOIN Member
	ON Member.Guid = Using_Directory.MemberGuid
GROUP BY
	Using_Directory.PackageId
	,Using_Directory.ReceivedOn

