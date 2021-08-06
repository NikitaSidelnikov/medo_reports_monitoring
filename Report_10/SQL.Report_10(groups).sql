---------------------------ПАРАМЕТРЫ-------------------------------
--DECLARE @DateStart DateTime2
--DECLARE @DateEnd DateTime2
--SET @DateStart = '2021-01-01'
--SET @DateEnd = '2021-06-01'
-------------------------------------------------------------------

IF object_id('tempdb..#tmp') is not null
	DROP TABLE #tmp
IF object_id('tempdb..#tmp2') is not null
	DROP TABLE #tmp2
IF OBJECT_ID('tempdb..#tmp_Packages') is not null
	DROP TABLE #tmp_Packages

CREATE TABLE #tmp_Packages (
							LogId BIGINT PRIMARY KEY
							,ContainerXmlVersion nvarchar(255)
						)
INSERT INTO #tmp_Packages  
	SELECT -- ActualLogs = актуальные пакеты с последним логом
		ReportPacks.LogId
		,ReportPacks.ContainerXmlVersion
	FROM (
		SELECT -- ActualDates = актуальные даты логов пакетов. Если логи по пакету менялись, то берем последний обработанный лог
			Package AS Max_Package
			,MAX(ValidatedOn)	AS Max_ValidatedOn
		FROM	
			ValidationLog
		WHERE 
			Success = 1 --????
		GROUP BY
			Package
	) AS ActualDates
	INNER JOIN (
		SELECT -- ReportPacks = все обработанные (processed = 1) пакеты
			ValidationLog.Id	AS LogId
			,ValidationLog.ContainerXmlVersion
			,Package.Id
			,Package.ValidatedOn
		FROM
			Package
		INNER JOIN ValidationLog
			ON ValidationLog.Package = Package.Id
		WHERE
			--Package.Incoming = 1 --только исходящие пакеты 
			Package.Processed = 1 --только обработанные пакеты
			AND Success = 1
	) AS ReportPacks
		ON ActualDates.Max_Package = ReportPacks.Id
		AND ActualDates.Max_ValidatedOn = ReportPacks.ValidatedOn


CREATE TABLE #tmp ( --оценка переписок с рангом
	Rank INT
	,SenderGuid char(36)
	--,SenderName nvarchar(255)
	,RecipientGuid char(36)
	--,RecipientName nvarchar(255)
	,CountNewVersionED INT
	,CountActiveCommunications INT
	,ALLCountNewVersionED INT
)

INSERT INTO #tmp  
	SELECT 	--оценка переписок с рангом
		DENSE_RANK() OVER (ORDER BY CountActiveCommunications DESC, ALLCountNewVersionED DESC, Member.Name ASC) AS Rank
		,SenderGuid
		--,SenderName
		,RecipientGuid
		--,RecipientName
		,CountNewVersionED
		,CountActiveCommunications
		,ALLCountNewVersionED
	FROM (
		SELECT	--ComunicationsScore = оценка переписок
			CommunicationsControl.SenderGuid
			--,CommunicationsControl.SenderName
			,CommunicationsControl.RecipientGuid
			--,CommunicationsControl.RecipientName
			,ISNULL(CommunicationsControl.CountNewVersionED, -1) AS CountNewVersionED --где переписки нет, там -1
			,SUM(CommunicationsControl.CountNewVersionED) OVER (PARTITION BY CommunicationsControl.SenderGuid) AS ALLCountNewVersionED --сумма всех ЭД в формате 2.7.1 по участнику 
			,SUM(IIF(CommunicationsControl.CountNewVersionED > 2, 1, 0)) OVER (PARTITION BY CommunicationsControl.SenderGuid) AS CountActiveCommunications --если в переписке есть более 2 ЭД 2.7.1, то +1 к активной переписке
		FROM ( --CommunicationsControl = коммуникации Sender и Recipient и кол-во версий 2.7.1 ЭД
			SELECT
				AllCommunications.SenderGuid
				--,AllCommunications.SenderName
				,AllCommunications.RecipientGuid
				--,AllCommunications.RecipientName
				,NewVersionControl.CountNewVersionED
			FROM ( --AllCommunications = Все возможные варианты коммуникаций Sender и Recipient
				SELECT 
					Member1.Guid	AS SenderGuid
					--,Member1.Name	AS SenderName
					,Member2.Guid	AS RecipientGuid 
					--,Member2.Name	AS RecipientName
				FROM 
					Member AS Member1
				CROSS JOIN (
					SELECT 
						--Member.Name
						Member.Guid
					FROM 
						Member
					WHERE
						Member.Active = 1
						AND Member.Type IN (@Groups)
				) AS Member2
				WHERE 
					Member1.Active = 1
					AND Member1.Type IN (@Groups)
			) AS AllCommunications
			LEFT JOIN (
				SELECT -- NewVersionControl = коммуникации MemberY и MemberX в период отчета по ЭД с указанием кол-ва версий 2.7.1 ЭД
					VersionControl.MemberY
					,VersionControl.MemberX
					,SUM(IIF(VersionControl.VersionED = '2.7.1', 1, 0)) AS CountNewVersionED
				FROM (
					SELECT  -- VersionControl = Все коммуникации MemberY и MemberX в период отчета по ЭД с указанием версии ЭД
						ConfirmationControl.SenderGuid AS MemberY		--отправитель
						,ConfirmationControl.RecipientGuid AS MemberX	--получатель
						,#tmp_Packages.ContainerXmlVersion AS VersionED
					FROM	
						ConfirmationControl	
					INNER JOIN #tmp_Packages
						ON #tmp_Packages.LogId = ConfirmationControl.ValidatingLog
					WHERE 	
						ConfirmationControl.PackageDelivaredOn >=  DATETIMEFROMPARTS(DATEPART(YEAR, @DateStart), DATEPART(MONTH, @DateStart), DATEPART(DAY, @DateStart), '0', '0', '0', '0') --начало периода отчета
						AND ConfirmationControl.PackageDelivaredOn < DATETIMEFROMPARTS(DATEPART(YEAR, @DateEnd), DATEPART(MONTH, @DateEnd), DATEPART(DAY, @DateEnd), '23', '59', '59', '0') --конец периода отчета
						--AND(ConfirmationControl.MessageType = N'Транспортный контейнер' OR ConfirmationControl.MessageType = N'Документ')
				) AS VersionControl
				GROUP BY
					VersionControl.MemberY
					,VersionControl.MemberX
			) AS NewVersionControl
				ON AllCommunications.SenderGuid = NewVersionControl.MemberY
				AND AllCommunications.RecipientGuid = NewVersionControl.MemberX
		) AS CommunicationsControl	
	) AS ComunicationsScore
	INNER JOIN Member
		ON Member.Guid = ComunicationsScore.SenderGuid

CREATE TABLE #tmp2 ( --чтобы сортировать столбец так же, как и строку
	Rank INT
	,SenderGuid nvarchar(255)
) 

INSERT INTO #tmp2  
	SELECT 
		DISTINCT
		#tmp.Rank
		,#tmp.SenderGuid
	FROM #tmp


SELECT 
	A.Rank AS RankA
	,A.SenderGuid
	--,A.SenderName
	,B.Rank AS RankB
	,A.RecipientGuid
	--,A.RecipientName
	,A.CountNewVersionED
	,A.CountActiveCommunications
	,A.ALLCountNewVersionED	
FROM #tmp AS A
INNER JOIN #tmp2 AS B
	ON A.RecipientGuid = B.SenderGuid
