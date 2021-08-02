---------------------------ПАРАМЕТРЫ-------------------------------
--DECLARE @DateStart DateTime2
--DECLARE @DateEnd DateTime2
--DECLARE @DateStartCompare DateTime2
--DECLARE @DateEndCompare DateTime2
--SET @DateStart = '2021-03-01'
--SET @DateEnd = '2021-03-31'
--SET @DateStartCompare = '2021-04-01'
--SET @DateEndCompare = '2021-04-30'
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
	,ActualPackages.ReceivedOn
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
							WHEN Report1.AllContainer1 > 0 AND Report2.AllContainer2 > 0
								THEN 100*((100*Report1.[2.7.1_1]/Report1.AllContainer1) - (100*Report2.[2.7.1_2]/Report2.AllContainer2))/(100+ABS(100*Report1.[2.7.1_1]/Report1.AllContainer1) + ABS(100*Report2.[2.7.1_2]/Report2.AllContainer2))
							WHEN Report1.AllContainer1 > 0 AND (Report2.AllContainer2 = 0 OR Report2.AllContainer2 is null)
								THEN 100*((100*Report1.[2.7.1_1]/Report1.AllContainer1) - 0)/(100+ABS(100*Report1.[2.7.1_1]/Report1.AllContainer1) + 0)
							WHEN (Report1.AllContainer1 = 0 OR Report1.AllContainer1 is null) AND Report2.AllContainer2 > 0
								THEN 100*(0 - (100*Report2.[2.7.1_2]/Report2.AllContainer2))/(100+0 + ABS(100*Report2.[2.7.1_2]/Report2.AllContainer2))
							ELSE NULL
							END
						, 2)
		,'Score1' = ROUND(
						IIF(Report1.AllContainer1 > 0 ,100 * Report1.[2.7.1_1]/Report1.AllContainer1 ,0)
					, 2)
		,Report1.AllContainer1
		,Report1.[2.7.1_1]
		,'Score2' = ROUND(
						IIF(Report2.AllContainer2 > 0 ,100 * Report2.[2.7.1_2]/Report2.AllContainer2 ,0)
					, 2)
		,Report2.AllContainer2
		,Report2.[2.7.1_2]
	FROM (
		SELECT --EM = оценка перехода на 2.7.1 в период сравнения по ЭС
			MemberED AS MemberED2
			,'AllContainer2' = CAST(ISNULL(VersionContainer.[2.7.1], 0) + ISNULL(VersionContainer.[2.7], 0) + ISNULL(VersionContainer.[NoContainer], 0) + ISNULL(VersionContainer.[x], 0) AS FLOAT)
			,CAST(ISNULL(VersionContainer.[2.7.1], 0) AS FLOAT) AS '2.7.1_2'
		FROM (
			SELECT --Containers = Кол-во каждой версии ЭД по каждому участнику в период сравнения
				MemberED
				,ContainerXmlVersion
				,COUNT(*) AS CountContainerXmlVersion
			FROM (
				SELECT 
					#Tmp.MemberGuid AS MemberED
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
					#Tmp.ReceivedOn >=  DATETIMEFROMPARTS(DATEPART(YEAR, @DateStartCompare), DATEPART(MONTH, @DateStartCompare), DATEPART(DAY, @DateStartCompare), '0', '0', '0', '0') --начало периода отчета
					AND #Tmp.ReceivedOn < DATETIMEFROMPARTS(DATEPART(YEAR, @DateEndCompare), DATEPART(MONTH, @DateEndCompare), DATEPART(DAY, @DateEndCompare), '23', '59', '59', '0') --конец периода отчета
			) AS Containers
			GROUP BY 
				MemberED
				,ContainerXmlVersion
		)x
		PIVOT (
		MAX(CountContainerXmlVersion)
			FOR ContainerXmlVersion
			IN([2.7.1],[2.7],[NoContainer],[x])
		) AS VersionContainer
	) AS Report2
	FULL OUTER JOIN (
		SELECT --EM = оценка перехода на 2.7.1 в период отчета по ЭС
			MemberED AS MemberED1
			,'AllContainer1' = CAST(ISNULL(VersionContainer.[2.7.1], 0) + ISNULL(VersionContainer.[2.7], 0) + ISNULL(VersionContainer.[NoContainer], 0) + ISNULL(VersionContainer.[x], 0) AS FLOAT)
			,CAST(ISNULL(VersionContainer.[2.7.1], 0) AS FLOAT) AS '2.7.1_1'
		FROM (
			SELECT --Containers = Кол-во каждой версии ЭД по каждому участнику в период отчета
				MemberED
				,ContainerXmlVersion
				,COUNT(*) AS CountContainerXmlVersion
			FROM (
				SELECT 
					#Tmp.MemberGuid AS MemberED
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
					#Tmp.ReceivedOn >=  DATETIMEFROMPARTS(DATEPART(YEAR, @DateStart), DATEPART(MONTH, @DateStart), DATEPART(DAY, @DateStart), '0', '0', '0', '0') --начало периода отчета
					AND #Tmp.ReceivedOn < DATETIMEFROMPARTS(DATEPART(YEAR, @DateEnd), DATEPART(MONTH, @DateEnd), DATEPART(DAY, @DateEnd), '23', '59', '59', '0') --конец периода отчета
			) AS Containers
			GROUP BY 
				MemberED
				,ContainerXmlVersion
		)x
		PIVOT (
		MAX(CountContainerXmlVersion)
			FOR ContainerXmlVersion
			IN([2.7.1],[2.7],[NoContainer],[x])
		) AS VersionContainer
	) AS Report1
		ON Report1.MemberED1 = Report2.MemberED2
	RIGHT JOIN Member
		ON Member.Guid = IIF(Report2.MemberED2 is not null, Report2.MemberED2, Report1.MemberED1) COLLATE SQL_Latin1_General_CP1_CI_AS
	WHERE
		Member.Active = 1
) AS Final_table