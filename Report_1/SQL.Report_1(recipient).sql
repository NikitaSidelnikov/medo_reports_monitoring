---------------------------ПАРАМЕТРЫ-------------------------------
--DECLARE @DateStart DateTime2
--DECLARE @DateEnd DateTime2
--DECLARE @Recipient nvarchar(255)
--SET @DateStart = '2020-01-01'
--SET @DateEnd = '2021-06-01'
--SET @Recipient = '1D04CA3E-DF1A-0CB4-C325-6EF4003CA2AB' --Минцифры России
-------------------------------------------------------------------


IF OBJECT_ID('tempdb..#Tmp') is not null
	DROP TABLE #Tmp
	
CREATE TABLE #Tmp (
					SenderGuid char(36)
					,PackageXmlVersion nvarchar(255)
					,ContainerXmlVersion nvarchar(255)
					,Type INT
)

INSERT INTO #Tmp
/*
Type = 
	1 -- квитанция
	2 -- уведомление
	3 -- документ
	4 -- ТК
*/
SELECT --ActualPackagesWithType = обработанные пакеты с последним логом в период отчета с указанием типа пакета
	SenderGuid
	,PackageXmlVersion
	,ContainerXmlVersion
	,PackageType = CASE 
						WHEN ConfirmationControl.MessageType = N'Транспортный контейнер'
							THEN 4
						WHEN ConfirmationControl.MessageType = N'Документ'
							THEN 3
						WHEN ConfirmationControl.MessageType = N'Уведомление'
							THEN 2
						WHEN ConfirmationControl.MessageType = N'Квитанция'
							THEN 1
						ELSE NULL
						END
FROM(
	SELECT --ActualPackages = обработанные пакеты с последним логом в период отчета
		ProcessedPackage.LogId
		,ProcessedPackage.PackageXmlVersion
		,ProcessedPackage.ContainerXmlVersion
	FROM(
		SELECT -- ActualLog = последний лог по пакету
			ValidationLog.Package				AS PackageId
			,MAX(ValidationLog.ValidatedOn)		AS Max_ValidatedOn
		FROM ValidationLog	
		WHERE 
			Success = 1
		GROUP BY
			ValidationLog.Package
	) AS ActualLog
	INNER JOIN (
		SELECT --ProcessedPackage = обработанные пакеты в период отчета
			ValidationLog.Package
			,ValidationLog.ValidatedOn
			,ValidationLog.Id				AS LogId
			,PackageXmlVersion
			,ContainerXmlVersion
		FROM Package
		INNER JOIN ValidationLog
			ON ValidationLog.Package = Package.Id
		WHERE
			Processed = 1
			AND Success = 1
	) AS ProcessedPackage
		ON ProcessedPackage.Package = ActualLog.PackageId
		AND ProcessedPackage.ValidatedOn = ActualLog.Max_ValidatedOn
) AS ActualPackagesWithType
INNER JOIN ConfirmationControl
	ON ConfirmationControl.ValidatingLog = ActualPackagesWithType.LogId
WHERE
	ConfirmationControl.RecipientGuid = @Recipient
	AND ConfirmationControl.PackageDelivaredOn >=  DATETIMEFROMPARTS(DATEPART(YEAR, @DateStart), DATEPART(MONTH, @DateStart), DATEPART(DAY, @DateStart), '0', '0', '0', '0') --начало периода отчета
	AND ConfirmationControl.PackageDelivaredOn < DATEADD(DAY, 1, DATETIMEFROMPARTS(DATEPART(YEAR, @DateEnd), DATEPART(MONTH, @DateEnd), DATEPART(DAY, @DateEnd), '0', '0', '0', '0'))
						

SELECT
	DENSE_RANK() OVER(PARTITION BY MemberType ORDER BY Score DESC) AS Rank	
	,*
FROM(
	SELECT
		Member.Name			AS Member
		,Member.Type		AS MemberType
		,'Score' = IIF(ED.[AllContainer] <> 0 AND ED.[2.7.1] <> 0, 100*(0 + CAST(ISNULL(ED.[2.7.1],0) AS FLOAT)/CAST(ED.[AllContainer] AS FLOAT)), 0)					
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
			SELECT --Определяем кол-во пакетов по каждой версии формата
				#Tmp.SenderGuid AS MemberEM
				,PackageXmlVersion
				,COUNT(*) AS CountPackageXmlVersion
			FROM #Tmp
			GROUP BY 
				#Tmp.SenderGuid
				,PackageXmlVersion
		)x
		PIVOT (
		MAX(CountPackageXmlVersion)
			FOR PackageXmlVersion
			IN([2.7.1],[2.7],[2.6],[2.5],[2.2],[2.0])
		) AS VersionMessage
	) AS EM
	LEFT JOIN (
		SELECT --ED = оценка перехода на 2.7.1 в период отчета по ЭД
				MemberED
				,'AllContainer' = ISNULL(VersionContainer.[2.7.1], 0) + ISNULL(VersionContainer.[2.7], 0) + ISNULL(VersionContainer.[NoContainer], 0) + ISNULL(VersionContainer.[x], 0)
				,VersionContainer.[2.7.1]		AS '2.7.1' 
				,VersionContainer.[2.7]			AS '2.7'
				,VersionContainer.[NoContainer] AS 'NoContainer'
				,VersionContainer.[x]			AS 'x'
		FROM (
			SELECT --Определяем кол-во пакетов по каждой версии
				MemberED
				,ContainerXmlVersion
				,COUNT(*) AS CountContainerXmlVersion
			FROM (
				SELECT --Containers = определяем формата пакета
					#Tmp.SenderGuid AS MemberED
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
