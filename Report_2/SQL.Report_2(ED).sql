---------------------------ПАРАМЕТРЫ-------------------------------
--DECLARE @DateStart DateTime2
--DECLARE @DateEnd DateTime2
--DECLARE @DateStartCompare DateTime2
--DECLARE @DateEndCompare DateTime2
--SET @DateStart = '2021-04-01'
--SET @DateEnd = '2021-04-30'
--SET @DateStartCompare = '2021-03-01'
--SET @DateEndCompare = '2021-03-31'
-------------------------------------------------------------------

IF OBJECT_ID('tempdb..#Tmp') is not null
	DROP TABLE #Tmp

CREATE TABLE #Tmp (
					PackageId INT
					,LogId INT 
					,MemberGuid char(36)
					,ContainerXml nvarchar(255)
					,ContainerXmlVersion nvarchar(255)
					,Type INT
					--,Success BIT
					,Period INT)
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
	,PackageType.MemberGuid
	,ActualPackages.ContainerXml
	,ActualPackages.ContainerXmlVersion
	,CASE 
		WHEN PackageType.Type = 3 AND ActualPackages.ContainerXml is null
			THEN 3				--Документ
		WHEN PackageType.Type = 3 AND ActualPackages.ContainerXml is not null
			THEN 4				--ТК
		ELSE
			PackageType.Type
		END			AS Type
	--,ActualPackages.Success
	,CASE WHEN
			(ReceivedOn >=  DATETIMEFROMPARTS(DATEPART(YEAR, @DateStart), DATEPART(MONTH, @DateStart), DATEPART(DAY, @DateStart), '0', '0', '0', '0') --начало периода отчета
			AND ReceivedOn < DATETIMEFROMPARTS(DATEPART(YEAR, @DateEnd), DATEPART(MONTH, @DateEnd), DATEPART(DAY, @DateEnd), '23', '59', '59', '0') --конец периода отчета			
			)
			THEN 1 --период отчета
		WHEN 
			(ReceivedOn >=  DATETIMEFROMPARTS(DATEPART(YEAR, @DateStartCompare), DATEPART(MONTH, @DateStartCompare), DATEPART(DAY, @DateStartCompare), '0', '0', '0', '0') --начало периода сравнения
			AND ReceivedOn < DATETIMEFROMPARTS(DATEPART(YEAR, @DateEndCompare), DATEPART(MONTH, @DateEndCompare), DATEPART(DAY, @DateEndCompare), '23', '59', '59', '0') --конец периода сравнения
			) 
			THEN 2 --период сравнения
		ELSE 0 --Пакеты, не входящие в периоды очтета или сравнения
	END AS Period
FROM (
	SELECT   --PackageType = определяем тип пакетов (не учитывая период отчета)
		ValidationLog
		,MemberGuid
		,MAX(Type)	AS Type
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
				END		AS Type
		FROM Score
		WHERE
			Criterion = '3.4'
			OR Criterion = '4.1'
			OR Criterion = '5.1'
	) AS CheckPackageType
	GROUP BY
		CheckPackageType.ValidationLog
		,CheckPackageType.MemberGuid
) AS PackageType

RIGHT JOIN (
	SELECT --ActualPackages = обработанные исходящие пакеты с последним логом
		ActualLog.PackageId
		,ActualLog.Max_ValidatedOn
		,ProcessedPackage.LogId
		,ProcessedPackage.ContainerXml
		,ProcessedPackage.ContainerXmlVersion
		,ProcessedPackage.Success
		,ProcessedPackage.ReceivedOn
	FROM(
		SELECT -- ActualLog = последний лог по пакету
			ValidationLog.Package				AS PackageId
			,MAX(ValidationLog.ValidatedOn)		AS Max_ValidatedOn
		FROM ValidationLog		
		GROUP BY
			ValidationLog.Package
	) AS ActualLog
	INNER JOIN (
		SELECT --ProcessedPackage = обработанные исходящие пакеты 
			ValidationLog.Package
			,ValidationLog.Id		AS LogId
			,ValidationLog.ValidatedOn
			,ValidationLog.Success
			,ContainerXml
			,ContainerXmlVersion
			,Package.ReceivedOn
		FROM Package
		INNER JOIN ValidationLog
			ON ValidationLog.Package = Package.Id
		WHERE
			Processed = 1
			AND Incoming = 0
			AND Success = 1
	) AS ProcessedPackage
		ON ProcessedPackage.Package = ActualLog.PackageId
		AND ProcessedPackage.ValidatedOn = ActualLog.Max_ValidatedOn
) AS ActualPackages
	ON PackageType.ValidationLog = ActualPackages.LogId 



SELECT
	DENSE_RANK() OVER (PARTITION BY IIF(ISNULL([2.7.1_1], 0) + ISNULL([2.7.1_2], 0) = 0, 1, 0) ORDER BY ChangesDynamic DESC, Member ASC) AS Rank
	,*
FROM (
	SELECT
		Member.Name			AS Member
		,ChangesDynamic = ROUND(
							CASE
							WHEN Format_Versions.AllContainer_1 > 0 AND Format_Versions.AllContainer_2 > 0
								THEN 100*((100*Format_Versions.[2.7.1_1]/Format_Versions.AllContainer_1) - (100*Format_Versions.[2.7.1_2]/Format_Versions.AllContainer_2))/(100+ABS(100*Format_Versions.[2.7.1_1]/Format_Versions.AllContainer_1) + ABS(100*Format_Versions.[2.7.1_2]/Format_Versions.AllContainer_2))
							WHEN Format_Versions.AllContainer_1 > 0 AND (Format_Versions.AllContainer_2 = 0 OR Format_Versions.AllContainer_2 is null)
								THEN 100*((100*Format_Versions.[2.7.1_1]/Format_Versions.AllContainer_1) - 0)/(100+ABS(100*Format_Versions.[2.7.1_1]/Format_Versions.AllContainer_1) + 0)
							WHEN (Format_Versions.AllContainer_1 = 0 OR Format_Versions.AllContainer_1 is null) AND Format_Versions.AllContainer_2 > 0
								THEN 100*(0 - (100*Format_Versions.[2.7.1_2]/Format_Versions.AllContainer_2))/(100+0 + ABS(100*Format_Versions.[2.7.1_2]/Format_Versions.AllContainer_2))
							ELSE NULL
							END
						, 2)
		,'Score1' = ROUND(
						IIF(Format_Versions.AllContainer_1 > 0 ,100 * Format_Versions.[2.7.1_1]/Format_Versions.AllContainer_1 ,NULL)
					, 2)
		,Format_Versions.AllContainer_1
		,Format_Versions.[2.7.1_1]
		,'Score2' = ROUND(
						IIF(Format_Versions.AllContainer_2 > 0 ,100 * Format_Versions.[2.7.1_2]/Format_Versions.AllContainer_2 ,NULL)
					, 2)
		,Format_Versions.AllContainer_2
		,Format_Versions.[2.7.1_2]
	FROM (
		SELECT
			Member
			,MAX(AllContainer_1)	AS AllContainer_1
			,MAX(AllContainer_2)	AS AllContainer_2
			,MAX([2.7.1_1])			AS '2.7.1_1'
			,MAX([2.7.1_2])			AS '2.7.1_2'
		FROM(
			SELECT --Format_Versions = оценка перехода на 2.7.1 в периоды сравнения и отчета
				Member
				,CAST(ISNULL([2.7.1], 0) + ISNULL([2.7], 0) + ISNULL([NoContainer], 0) + ISNULL([x], 0) AS FLOAT)			AS 'AllContainer_1'
				,CAST(ISNULL([2.7.1], 0) AS FLOAT)																			AS '2.7.1_1'
				,CAST(ISNULL([2.7.1_2], 0) + ISNULL([2.7_2], 0) + ISNULL([NoContainer_2], 0) + ISNULL([x_2], 0) AS FLOAT)	AS 'AllContainer_2'
				,CAST(ISNULL([2.7.1_2], 0) AS FLOAT)																		AS '2.7.1_2'
			FROM (
				SELECT --Containers = Кол-во каждой версии ЭД по каждому участнику в периоды сравнения и отчета
					Member
					,Period
					,IIF(Period = 1, ContainerXmlVersion, NULL)			AS ContainerXmlVersion_1
					,IIF(Period = 2, ContainerXmlVersion+'_2', NULL)	AS ContainerXmlVersion_2
					,SUM(IIF(Period = 1, 1, 0))							AS CountContainerXmlVersion_1
					,SUM(IIF(Period = 2, 1, 0))							AS CountContainerXmlVersion_2
				FROM (	
					SELECT 
						#Tmp.MemberGuid AS Member
						,#Tmp.Period
						,CASE 
							WHEN #Tmp.Type = 3 				--Документ
								THEN 'NoContainer'
							WHEN #Tmp.Type = 4 AND #Tmp.ContainerXmlVersion is null
								THEN 'x'					--ТК без формата
							ELSE
								#Tmp.ContainerXmlVersion	--ТК
							END 
						AS ContainerXmlVersion			
					FROM #Tmp
					WHERE
						Period IN (1, 2)
				) AS Containers
				GROUP BY 
					Member
					,ContainerXmlVersion
					,Period
			)x
			PIVOT (
				MAX(CountContainerXmlVersion_1)
				FOR ContainerXmlVersion_1
				IN([2.7.1],[2.7],[NoContainer],[x])
			) AS VersionContainer_1
			PIVOT (
				MAX(CountContainerXmlVersion_2)
				FOR ContainerXmlVersion_2
				IN([2.7.1_2],[2.7_2],[NoContainer_2],[x_2])
			) AS VersionContainer_2
		) AS Versions_Pivot
		GROUP BY
			Member
	) AS Format_Versions
	RIGHT JOIN Member
		ON Member.Guid = Format_Versions.Member COLLATE SQL_Latin1_General_CP1_CI_AS
	WHERE
		Member.Active = 1
) AS Final_table
