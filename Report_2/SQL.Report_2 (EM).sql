--DECLARE @DataStart DateTime2
--DECLARE @DataEnd DateTime2
--DECLARE @DataStartCompare DateTime2
--DECLARE @DataEndCompare DateTime2

--SET @DataStart = '2021-03-01'
--SET @DataEnd = '2021-04-01'
--SET @DataStartCompare = '2021-02-01'
--SET @DataEndCompare = '2021-03-01'

IF OBJECT_ID('tempdb..#Tmp') is not null
	DROP TABLE #Tmp

CREATE TABLE #Tmp (
					PackageId INT
					,LogId INT 
					,MemberGuid nvarchar(255)
					,PackageXml nvarchar(255)
					,PackageXmlVersion nvarchar(255)
					,Type INT
					,Success BIT
					,ReceivedOn DateTime2(7))
INSERT INTO #Tmp
/*
Type = 
	1 -- квитанция
	2 -- уведомление
	3 -- документ
	4 -- ТК
*/
SELECT --ActualPackages = предыдущая таблица ActualPackages  с указанием типа пакета
	ActualPackages.PackageId
	,ActualPackages.LogId
	,ActualPackages.MemberGuid AS MemberGuid
	,ActualPackages.PackageXml
	,IIF(ActualPackages.PackageXmlVersion is null AND ActualPackages.PackageId is not null, 'x', PackageXmlVersion) AS PackageXmlVersion
	,CASE 
		WHEN PackageType.Type = 3 AND ActualPackages.ContainerXml is null
			THEN 3				--Документ
		WHEN PackageType.Type = 3 AND ActualPackages.ContainerXml is not null
			THEN 4				--ТК
		ELSE
			PackageType.Type
		END AS Type
	,ActualPackages.Success
	,ActualPackages.ReceivedOn
FROM (
	SELECT   --PackageType = определяем тип пакетов (не учитывая период отчета)
		ValidationLog
		,MAX(Type) AS Type
	FROM (
		SELECT --PackageType = определяем: какие критерии есть в оценке пакета. Исходя из них, сделаем вывод о типе
			ValidationLog
			,MemberGuid
			,CASE 
				WHEN Criterion = '3.4'
					THEN 3				--ТК/Документ
				WHEN Criterion = '4.1'
					THEN 2				--Уведомление
				WHEN Criterion = '5.1'	
				THEN 1				--Квитанция
				END AS Type
		FROM Score
		WHERE
			Criterion = '3.4'
			OR Criterion = '4.1'
			OR Criterion = '5.1'
	) AS CheckPackageType
	GROUP BY
		CheckPackageType.ValidationLog
) AS PackageType

RIGHT JOIN (
	SELECT --ActualPackages = обработанные исходящие пакеты в период отчета с последним логом
		ActualLog.PackageId
		,ActualLog.Max_ValidatedOn
		,ProcessedPackage.MemberGuid
		,ProcessedPackage.LogId
		,ProcessedPackage.PackageXml
		,ProcessedPackage.PackageXmlVersion
		,ProcessedPackage.ContainerXml
		,ProcessedPackage.ContainerXmlVersion
		,ProcessedPackage.Success
		,ProcessedPackage.ReceivedOn
	FROM(
		SELECT -- ActualLog = последний лог по пакету
			ValidationLog.Package	AS PackageId
			,MAX(ValidationLog.ValidatedOn)	AS Max_ValidatedOn
		FROM ValidationLog		
		GROUP BY
			ValidationLog.Package
	) AS ActualLog
	INNER JOIN (
		SELECT --ProcessedPackage = обработанные исходящие пакеты в период отчета
			ValidationLog.Package
			,ValidationLog.Id AS LogId
			,ValidationLog.ValidatedOn
			,ValidationLog.Success
			,Batch.MemberGuid
			,PackageXml
			,PackageXmlVersion
			,ContainerXml
			,ContainerXmlVersion
			,Package.ReceivedOn
		FROM Package
		INNER JOIN ValidationLog
			ON ValidationLog.Package = Package.Id
		INNER JOIN Batch
			ON Batch.Id = Package.Batch
		WHERE
			Processed = 1
			AND Incoming = 0
			--AND Package.ReceivedOn >=  DATETIMEFROMPARTS(DATEPART(YEAR, @DataStart), DATEPART(MONTH, @DataStart), DATEPART(DAY, @DataStart), '0', '0', '0', '0') --начало периода отчета
			--AND Package.ReceivedOn < DATETIMEFROMPARTS(DATEPART(YEAR, @DataEnd), DATEPART(MONTH, @DataEnd), DATEPART(DAY, @DataEnd), '23', '59', '59', '0') --конец периода отчета
			--AND Package.ReceivedOn >=  '2021-03-01' --начало периода отчета
			--AND Package.ReceivedOn < '2021-04-01' --конец периода отчета	
	) AS ProcessedPackage
		ON ProcessedPackage.Package = ActualLog.PackageId
		AND ProcessedPackage.ValidatedOn = ActualLog.Max_ValidatedOn
) AS ActualPackages
	ON PackageType.ValidationLog = ActualPackages.LogId 

SELECT
	Member.Name AS Member
	,ChangesDynamic = ROUND(
						CASE
						WHEN Report1.AllMessage1 > 0 AND Report2.AllMessage2 > 0
							THEN 100*((100*Report1.[2.7.1_1]/Report1.AllMessage1) - (100*Report2.[2.7.1_2]/Report2.AllMessage2))/(100+ABS(100*Report1.[2.7.1_1]/Report1.AllMessage1) + ABS(100*Report2.[2.7.1_2]/Report2.AllMessage2))
						WHEN Report1.AllMessage1 > 0 AND (Report2.AllMessage2 = 0 OR Report2.AllMessage2 is null)
							THEN 100*((100*Report1.[2.7.1_1]/Report1.AllMessage1) - 0)/(100+ABS(100*Report1.[2.7.1_1]/Report1.AllMessage1) + 0)
						WHEN (Report1.AllMessage1 = 0 OR Report1.AllMessage1 is null) AND Report2.AllMessage2 > 0
							THEN 100*(0 - (100*Report2.[2.7.1_2]/Report2.AllMessage2))/(100+0 + ABS(100*Report2.[2.7.1_2]/Report2.AllMessage2))
						ELSE NULL
						END
					, 2)
	,'Score1' = ROUND(
					IIF(Report1.AllMessage1 > 0
					,100 * Report1.[2.7.1_1]/Report1.AllMessage1
					,NULL)
				, 2)
	,Report1.AllMessage1
	,Report1.[2.7.1_1]
	,'Score2' = ROUND(
					IIF(Report2.AllMessage2 > 0
					,100 * Report2.[2.7.1_2]/Report2.AllMessage2
					,NULL) 
				, 2)
	,Report2.AllMessage2
	,Report2.[2.7.1_2]
FROM (
	SELECT --EM = оценка перехода на 2.7.1 в период отчета по ЭС
		MemberEM AS MemberEM2
		,'AllMessage2' = CAST(ISNULL(VersionMessage.[2.7.1], 0) + ISNULL(VersionMessage.[2.7], 0) + ISNULL(VersionMessage.[2.6], 0) + ISNULL(VersionMessage.[2.5], 0) + ISNULL(VersionMessage.[2.2], 0) + ISNULL(VersionMessage.[2.0], 0) + ISNULL(VersionMessage.[x], 0) AS FLOAT)
		,CAST(ISNULL(VersionMessage.[2.7.1], 0) AS FLOAT) AS '2.7.1_2'
	FROM (
		SELECT 
			#Tmp.MemberGuid AS MemberEM
			,PackageXmlVersion
			,COUNT(*) AS CountPackageXmlVersion
		FROM #Tmp
		WHERE
			#Tmp.ReceivedOn >=  DATETIMEFROMPARTS(DATEPART(YEAR, @DataStartCompare), DATEPART(MONTH, @DataStartCompare), DATEPART(DAY, @DataStartCompare), '0', '0', '0', '0') --начало периода отчета
			AND #Tmp.ReceivedOn < DATETIMEFROMPARTS(DATEPART(YEAR, @DataEndCompare), DATEPART(MONTH, @DataEndCompare), DATEPART(DAY, @DataEndCompare), '23', '59', '59', '0') --конец периода отчета
			--#Tmp.ReceivedOn >=  '2021-03-01' --начало периода отчета
			--AND #Tmp.ReceivedOn < '2021-03-31' --конец периода отчета
		GROUP BY 
			#Tmp.MemberGuid
			,PackageXmlVersion
	)x
	PIVOT (
	MAX(CountPackageXmlVersion)
		FOR PackageXmlVersion
		IN([2.7.1],[2.7],[2.6],[2.5],[2.2],[2.0], [x])
	) AS VersionMessage
) AS Report2
FULL OUTER JOIN (
	SELECT --EM = оценка перехода на 2.7.1 в период сравнения отчета по ЭС
		MemberEM AS MemberEM1
		,'AllMessage1' = CAST(ISNULL(VersionMessage.[2.7.1], 0) + ISNULL(VersionMessage.[2.7], 0) + ISNULL(VersionMessage.[2.6], 0) + ISNULL(VersionMessage.[2.5], 0) + ISNULL(VersionMessage.[2.2], 0) + ISNULL(VersionMessage.[2.0], 0) + ISNULL(VersionMessage.[x], 0) AS FLOAT)
		,CAST(ISNULL(VersionMessage.[2.7.1], 0) AS FLOAT) AS '2.7.1_1'
	FROM (
		SELECT 
			#Tmp.MemberGuid AS MemberEM
			,PackageXmlVersion
			,COUNT(*) AS CountPackageXmlVersion
		FROM #Tmp
		WHERE
			#Tmp.ReceivedOn >=  DATETIMEFROMPARTS(DATEPART(YEAR, @DataStart), DATEPART(MONTH, @DataStart), DATEPART(DAY, @DataStart), '0', '0', '0', '0') --начало периода отчета
			AND #Tmp.ReceivedOn < DATETIMEFROMPARTS(DATEPART(YEAR, @DataEnd), DATEPART(MONTH, @DataEnd), DATEPART(DAY, @DataEnd), '23', '59', '59', '0') --конец периода отчета
		GROUP BY 
			#Tmp.MemberGuid
			,PackageXmlVersion
	)x
	PIVOT (
	MAX(CountPackageXmlVersion)
		FOR PackageXmlVersion
		IN([2.7.1],[2.7],[2.6],[2.5],[2.2],[2.0], [x])
	) AS VersionMessage
) AS Report1
	ON Report1.MemberEM1 = Report2.MemberEM2
RIGHT JOIN Member
	ON Member.Guid = IIF(Report2.MemberEM2 is not null, Report2.MemberEM2, Report1.MemberEM1) COLLATE SQL_Latin1_General_CP1_CI_AS
WHERE
	Active = 1