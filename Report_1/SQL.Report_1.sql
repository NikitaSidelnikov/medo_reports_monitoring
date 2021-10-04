---------------------------ПАРАМЕТРЫ-------------------------------
--DECLARE @DateStart DateTime2
--DECLARE @DateEnd DateTime2
--SET @DateStart = '2021-04-01'
--SET @DateEnd = '2021-06-01'
-------------------------------------------------------------------

IF OBJECT_ID('tempdb..#Tmp') is not null
	DROP TABLE #Tmp
	
CREATE TABLE #Tmp (
					MemberGuid char(36)
					,PackageXmlVersion nvarchar(255)
					,ContainerXmlVersion nvarchar(255)
					,Type INT
					--,Success BIT
					)
INSERT INTO #Tmp
	/*
	Type = 
		1 -- квитанция
		2 -- уведомление
		3 -- документ
		4 -- ТК
	*/
	SELECT --ActualPackages = предыдущая таблица ActualPackages  с указанием типа пакета
		--ActualPackages.PackageId
		--,ActualPackages.LogId
		PackageType.MemberGuid			
		--,ActualPackages.PackageXml
		,PackageXmlVersion
		--,ActualPackages.ContainerXml
		,ActualPackages.ContainerXmlVersion
		,Type
	FROM (
		SELECT   --PackageType = определяем тип пакетов (не учитывая период отчета)
			MemberGuid
			,ValidationLog
			,MAX(Type) AS Type
		FROM (
			SELECT --PackageType = определяем: какие критерии есть в оценке пакета. Исходя из них, сделаем вывод о типе
				ValidationLog
				,Score.MemberGuid
				,CASE 
					WHEN Criterion = '3.4' AND Value > 0
						THEN 4				--ТК
					WHEN Criterion = '3.4' AND Value = 0
						THEN 3				--Документ
					WHEN Criterion = '4.1'
						THEN 2				--Уведомление
					WHEN Criterion = '5.1'	
						THEN 1				--Квитанция
					END AS Type
			FROM Score
			WHERE
				Criterion IN ('3.4', '4.1', '5.1')
		) AS CheckPackageType
		GROUP BY
			CheckPackageType.MemberGuid
			,CheckPackageType.ValidationLog
	) AS PackageType

	RIGHT JOIN (
		SELECT --ActualPackages = обработанные исходящие пакеты в период отчета с последним логом
			ActualLog.PackageId
			,ProcessedPackage.LogId
			,ProcessedPackage.PackageXmlVersion
			,ProcessedPackage.ContainerXmlVersion
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
			SELECT --ProcessedPackage = обработанные исходящие пакеты в период отчета
				ValidationLog.Package
				,ValidationLog.Id			AS LogId
				,ValidationLog.ValidatedOn
				,ValidationLog.PackageXmlVersion
				,ValidationLog.ContainerXmlVersion
			FROM Package
			INNER JOIN ValidationLog
				ON ValidationLog.Package = Package.Id
			WHERE
				Processed = 1
				AND Success = 1
				AND Incoming = 0
				AND Package.ReceivedOn >=  DATETIMEFROMPARTS(DATEPART(YEAR, @DateStart), DATEPART(MONTH, @DateStart), DATEPART(DAY, @DateStart), '0', '0', '0', '0') --начало периода отчета
				AND Package.ReceivedOn < DATETIMEFROMPARTS(DATEPART(YEAR, @DateEnd), DATEPART(MONTH, @DateEnd), DATEPART(DAY, @DateEnd), '23', '59', '59', '0') --конец периода отчета
		) AS ProcessedPackage
			ON ProcessedPackage.Package = ActualLog.PackageId
			AND ProcessedPackage.ValidatedOn = ActualLog.Max_ValidatedOn
	) AS ActualPackages
		ON PackageType.ValidationLog = ActualPackages.LogId 

SELECT
	DENSE_RANK() OVER(ORDER BY Score DESC) AS Rank	
	,*
FROM(
	SELECT -- Join таблиц по ЭД и по ЭС
		Member.Name						AS Member
		,'Score' = Round(IIF(ED.[AllContainer] <> 0 AND ED.[2.7.1] <> 0, 100*(0 + CAST(ISNULL(ED.[2.7.1],0) AS FLOAT)/CAST(ED.[AllContainer] AS FLOAT)), 0), 2)					
		,ISNULL(EM.[AllMessage], 0)		AS AllMessage
		,ISNULL(EM.[2.7.1], 0)			AS EM_2_7_1
		,ISNULL(EM.[2.7], 0)			AS EM_2_7
		,ISNULL(EM.[2.6], 0)			AS EM_2_6
		,ISNULL(EM.[2.5], 0)			AS EM_2_5
		,ISNULL(EM.[2.2], 0)			AS EM_2_2
		,ISNULL(EM.[2.0], 0)			AS EM_2_0
		,ISNULL(ED.[AllContainer], 0)	AS AllContainer
		,ISNULL(ED.[2.7.1], 0)			AS ED_2_7_1
		,ISNULL(ED.[2.7], 0)			AS ED_2_7
		,ISNULL(ED.[NoContainer], 0)	AS ED_NoContainer
		,ISNULL(ED.[x], 0)				AS ED_X
	FROM (
		SELECT --EM = оценка перехода на 2.7.1 в период отчета по ЭС
				MemberEM
				,'AllMessage' = ISNULL(VersionMessage.[2.7.1], 0) + ISNULL(VersionMessage.[2.7], 0) + ISNULL(VersionMessage.[2.6], 0) + ISNULL(VersionMessage.[2.5], 0) + ISNULL(VersionMessage.[2.2], 0) + ISNULL(VersionMessage.[2.0], 0)
				,VersionMessage.[2.7.1]	AS '2.7.1'
				,VersionMessage.[2.7]	AS '2.7'
				,VersionMessage.[2.6]	AS '2.6'
				,VersionMessage.[2.5]	AS '2.5'
				,VersionMessage.[2.2]	AS '2.2'
				,VersionMessage.[2.0]	AS '2.0'
		FROM (
			SELECT -- Кол-во каждого формата ЭС по каждому участнику
				#Tmp.MemberGuid AS MemberEM
				,PackageXmlVersion
				,COUNT(*) AS CountPackageXmlVersion
			FROM #Tmp
			GROUP BY 
				#Tmp.MemberGuid
				,PackageXmlVersion
		)x
		PIVOT (
		MAX(CountPackageXmlVersion)
			FOR PackageXmlVersion
			IN([2.7.1],[2.7],[2.6],[2.5],[2.2],[2.0])
		) AS VersionMessage
	) AS EM
	LEFT JOIN (
		SELECT --EM = оценка перехода на 2.7.1 в период отчета по ЭС
				MemberED
				,'AllContainer' = ISNULL(VersionContainer.[2.7.1], 0) + ISNULL(VersionContainer.[2.7], 0) + ISNULL(VersionContainer.[NoContainer], 0) + ISNULL(VersionContainer.[x], 0)
				,VersionContainer.[2.7.1]		AS '2.7.1' 
				,VersionContainer.[2.7]			AS '2.7'
				,VersionContainer.[NoContainer] AS 'NoContainer'
				,VersionContainer.[x]			AS 'x'
		FROM (
			SELECT -- Кол-во каждого формата ЭД по каждому участнику
				MemberED
				,ContainerXmlVersion
				,COUNT(*) AS CountContainerXmlVersion
			FROM (
				SELECT --Containers = Отбор ЭД и указание формата
					#Tmp.MemberGuid AS MemberED
					,CASE 
						WHEN #Tmp.Type = 3 			--Документ
							THEN 'NoContainer'
						WHEN #Tmp.Type = 4 AND #Tmp.ContainerXmlVersion is null
							THEN 'x'				--ТК
						ELSE
							#Tmp.ContainerXmlVersion
						END 
					AS ContainerXmlVersion			
				FROM #Tmp
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
	) AS ED
		ON ED.MemberED = EM.MemberEM
	RIGHT JOIN Member
		ON Member.Guid = ISNULL(EM.MemberEM, ED.MemberED) COLLATE SQL_Latin1_General_CP1_CI_AS
	WHERE  
		Member.Active = 1
) AS Finaly_Table
