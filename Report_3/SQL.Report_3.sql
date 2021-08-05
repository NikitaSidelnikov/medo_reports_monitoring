---------------------------ПАРАМЕТРЫ-------------------------------
--DECLARE @DateStart DateTime2
--DECLARE @DateEnd DateTime2
--SET @DateStart = '2021-04-01'
--SET @DateEnd = '2021-06-01'
-------------------------------------------------------------------

IF OBJECT_ID('tempdb..#tmp_Packages') is not null
	DROP TABLE #tmp_Packages
IF OBJECT_ID('tempdb..#ScoreReceipt') is not null
	DROP TABLE #ScoreReceipt
IF OBJECT_ID('tempdb..#ScoreNotifications') is not null
	DROP TABLE #ScoreNotifications

CREATE TABLE #tmp_Packages (
							LogId BIGINT PRIMARY KEY
							,PackageId INT
							,ReceivedOn DATETIME2(7) NULL
						)
CREATE TABLE #ScoreReceipt (
							PackageIdR INT
							,MemberResponseMessagerR CHAR(36)
							,MessageTypeR NVARCHAR(255)
							,PackageDelivaredOnR DATETIME2(7)
							,TotalMessageR INT
							,RequieredR INT
							,ResponsedR INT
						)
CREATE TABLE #ScoreNotifications (
							PackageIdN INT
							,MemberResponseMessagerN CHAR(36)
							,MessageTypeN NVARCHAR(255)
							,PackageDelivaredOnN DATETIME2(7)
							,TotalMessageN INT
							,RequieredN INT
							,ResponsedN INT
						)


INSERT INTO #tmp_Packages  
	SELECT -- ActualLogs = актуальные пакеты с последним логом
		ReportPacks.LogId
		,ReportPacks.Id			AS PackageId
		,ReportPacks.ReceivedOn
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
			,Package.Id
			,Package.ValidatedOn
			,Package.ReceivedOn
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


INSERT INTO #ScoreReceipt
	SELECT		
		PackageIdR
		,Member.Guid
		,MessageTypeR
		,PackageDelivaredOnR
		,[TotalMessageR]
		,[RequieredR]
		,[ResponsedR]
	FROM (
		SELECT -- ScoreReceipt --оценка соблюдения регламента отправки техн. ЭС (сравнение дат ожидания квитанции и ее фактического поступления)
			 RequestMessage.PackageId			AS PackageIdR
			,RequestMessage.RecipientGuid		AS MemberResponseMessagerR
			,RequestMessage.MessageType			AS MessageTypeR
			,RequestMessage.PackageDelivaredOn  AS PackageDelivaredOnR
			,'TotalMessageR' = 1
			,'RequieredR' = CASE WHEN 
									RequestMessage.PackageDelivaredOn is not null 
									AND RequestMessage.MessageType <> N'Квитанция'
								THEN 1
								ELSE 0
								END
			,'ResponsedR' = CASE WHEN 
									ResponseMessage.ResponseDelivaredOn is not null
									AND RequestMessage.MessageType <> N'Квитанция'
								THEN 1
								ELSE 0
								END
		FROM (
			SELECT --RequestMessage - документы/ТК, ожидающие квитанции в период очета
				MAX(#tmp_Packages.PackageId)	AS PackageId
				,AllRequestMessage.MessageUid
				,AllRequestMessage.SenderGuid
				,AllRequestMessage.MessageType
				,AllRequestMessage.RecipientGuid
				,AllRequestMessage.PackageDelivaredOn
			FROM (
				SELECT  --AllRequestMessage - Все документы/ТК, ожидающие квитанции (или просто входящие квитанции)
					MessageUid
					,ValidatingLog
					,SenderGuid
					,MessageType
					,RecipientGuid
					,PackageDelivaredOn
					,MAX(PackageDelivaredOn) OVER (PARTITION BY  MessageUid
													,SenderGuid
													,RecipientGuid
													,MessageType
												) AS MinPackageDelivaredOn --если более 1 одинаковой отправки документа/ТК (одинаковые sender, Doc.Uid и recipient появляются больше, чем в одной записи), то берем максимальную дату
				FROM 
					ConfirmationControl --WHERE Request = 1 отсутсвует, ибо мы смотрим ВСЕ входящие учаснику пакеты
			) AS AllRequestMessage
			INNER JOIN #tmp_Packages
				ON #tmp_Packages.LogId = AllRequestMessage.ValidatingLog
			WHERE
				AllRequestMessage.PackageDelivaredOn is not null
				AND AllRequestMessage.PackageDelivaredOn >=  DATEADD(DAY, -5, DATETIMEFROMPARTS(DATEPART(YEAR, @DateStart), DATEPART(MONTH, @DateStart), DATEPART(DAY, @DateStart), '0', '0', '0', '0')) --начало периода отчета. Дата получения пакета должна быть не ранее, чем за 3 дня до отчетного периода
				AND DATEADD(DAY, 5, AllRequestMessage.PackageDelivaredOn) <= DATETIMEFROMPARTS(DATEPART(YEAR, @DateEnd), DATEPART(MONTH, @DateEnd), DATEPART(DAY, @DateEnd), '23', '59', '59', '0')	--конец периода отчета. Дата ожидания уведомления должна быть не позже даты окончания периода отчета, иначе срок формирования уведомления попадает на следующий отчетный срок
				AND AllRequestMessage.MinPackageDelivaredOn = AllRequestMessage.PackageDelivaredOn
			GROUP BY 
				AllRequestMessage.MessageUid
				,AllRequestMessage.SenderGuid
				,AllRequestMessage.MessageType
				,AllRequestMessage.RecipientGuid
				,AllRequestMessage.PackageDelivaredOn
		) AS RequestMessage

		LEFT OUTER JOIN (
			SELECT		--ResponseMessage - Все квитанции, отправленные в ответ на документы/ТК, с номерами пакетов
				MAX(#tmp_Packages.PackageId)	AS PackageId --MAX берем, потому что может опять при объединении совпасть sender, repicient, messUid и даже ResponseDelivaredOn
				,AllResponseMessage.MessageUid
				,AllResponseMessage.SenderGuid
				,AllResponseMessage.RecipientGuid
				,AllResponseMessage.ResponseDelivaredOn
			FROM (
				SELECT --AllResponseMessage - Все квитанции, отправленные в ответ на документы/ТК
					MessageUid
					,ValidatingLog
					,SenderGuid
					,RecipientGuid
					,MessageType
					,PackageDelivaredOn		AS ResponseDelivaredOn
					,MIN(PackageDelivaredOn) OVER (PARTITION BY  MessageUid
																,SenderGuid
																,RecipientGuid
																,MessageType
													) AS MinResponseDelivaredOn --если более 1 одинаковой отправки квитанции (sender, Mess.Uid и recipient появляются больше, чем в одной записи), то берем минимальную дату передачи
				FROM 
					ConfirmationControl
				WHERE
					ResponseCount = 1
			) AS AllResponseMessage
			INNER JOIN #tmp_Packages
				ON #tmp_Packages.LogId = AllResponseMessage.ValidatingLog
			WHERE
				AllResponseMessage.MinResponseDelivaredOn = AllResponseMessage.ResponseDelivaredOn
			GROUP BY				
				AllResponseMessage.MessageUid
				,AllResponseMessage.SenderGuid
				,AllResponseMessage.RecipientGuid
				,AllResponseMessage.ResponseDelivaredOn
		) AS ResponseMessage
			ON RequestMessage.MessageUid = ResponseMessage.MessageUid 
			AND RequestMessage.SenderGuid = ResponseMessage.RecipientGuid 
			AND RequestMessage.RecipientGuid = ResponseMessage.SenderGuid

		--WHERE 
		--	(CASE
		--		WHEN DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn))) = 0  --если даты совпадают, то сравниваем по миллисекундам
		--		THEN DATEDIFF(MILLISECOND, GETDATE(), DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn))
		--		ELSE DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn)))  --иначе сравниваем по дням
		--		END 
		--	> 0 
		--	AND CASE
		--				WHEN DATEDIFF(DAY, CONVERT(DATE, ResponseDelivaredOn), CONVERT(DATE, DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn))) = 0 --если даты совпадают, то сравниваем по миллисекундам
		--				THEN DATEDIFF(MILLISECOND, ResponseDelivaredOn, DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn))
		--				ELSE DATEDIFF(DAY, CONVERT(DATE, ResponseDelivaredOn), CONVERT(DATE, DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn)))  --иначе сравниваем по дням
		--				END
		--			is not null) --если дата и время ожидания квитанции больше текущего системного времени, но DateDiff не null, значит уведомление пришло в срок до текущего времени. Иначе не учитываем, ибо квитанция может прийти позже текущего времени, но до даты ожидания
	
		--	OR (CASE
		--		WHEN DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn))) = 0  --если даты совпадают, то сравниваем по миллисекундам
		--		THEN DATEDIFF(MILLISECOND, GETDATE(), DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn))
		--		ELSE DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn)))  --иначе сравниваем по дням
		--		END
		--	<= 0 )
	) AS FinalScoreReceipt
	RIGHT JOIN Member
		ON Member.Guid = FinalScoreReceipt.MemberResponseMessagerR



INSERT INTO #ScoreNotifications
	SELECT		
		PackageIdN
		,Member.Name
		,MessageTypeN
		,PackageDelivaredOnN
		,[TotalMessageN]
		,[RequieredN]
		,[ResponsedN]
	FROM (
		SELECT -- ScoreNotifications  = оценка соблюдения регламента отправки техн. ЭС (сравнение дат ожидания уведомления и его фактического поступления)
			RequestMessage.PackageId			AS PackageIdN
			,RequestMessage.RecipientGuid		AS MemberResponseMessagerN
			,RequestMessage.MessageType			AS MessageTypeN
			,RequestMessage.PackageDelivaredOn	AS PackageDelivaredOnN
			,'TotalMessageN' = CASE WHEN 
										RequestMessage.MessageType = N'Квитанция'
									THEN 0
									ELSE 1
									END
			,'RequieredN' = CASE WHEN 
									RequestMessage.PackageDelivaredOn is not null 
									AND RequestMessage.MessageType <> N'Уведомление'
								THEN 1
								ELSE 0
								END
			,'ResponsedN' = CASE WHEN 
									ResponseMessage.ResponseDelivaredOn is not null
									AND RequestMessage.MessageType <> N'Уведомление'
								THEN 1
								ELSE 0
								END
		FROM (
			SELECT --RequestMessage - документы/ТК, ожидающие уведомления в период очета
				MAX(#tmp_Packages.PackageId)	AS PackageId
				,AllRequestMessage.DocumentUid 
				,AllRequestMessage.SenderGuid
				,AllRequestMessage.MessageType
				,AllRequestMessage.RecipientGuid
				,AllRequestMessage.PackageDelivaredOn
			FROM (
				SELECT  --AllRequestMessage - Все документы/ТК, ожидающие уведомления (или просто входящие уведомлния)
					DocumentUid
					,ValidatingLog
					,SenderGuid
					,RecipientGuid
					,MessageType
					,PackageDelivaredOn
					,MAX(PackageDelivaredOn) OVER (PARTITION BY  DocumentUid
																,SenderGuid
																,RecipientGuid
																,MessageType
													) AS MinPackageDelivaredOn --если более 1 одинаковой отправки документа/ТК (одинаковые sender, Doc.Uid и recipient появляются больше, чем в одной записи), то берем максимальную дату
				FROM  
					RegistrationControl --WHERE Request = 1 отсутсвует, ибо мы смотрим ВСЕ входящие учаснику пакеты
			) AS AllRequestMessage
			INNER JOIN #tmp_Packages
				ON #tmp_Packages.LogId = AllRequestMessage.ValidatingLog
			WHERE
				AllRequestMessage.PackageDelivaredOn is not null
				AND AllRequestMessage.PackageDelivaredOn >=  DATEADD(DAY, -5, DATETIMEFROMPARTS(DATEPART(YEAR, @DateStart), DATEPART(MONTH, @DateStart), DATEPART(DAY, @DateStart), '0', '0', '0', '0')) --начало периода отчета. Дата получения пакета должна быть не ранее, чем за 3 дня до отчетного периода
				AND DATEADD(DAY, 5, AllRequestMessage.PackageDelivaredOn) <= DATETIMEFROMPARTS(DATEPART(YEAR, @DateEnd), DATEPART(MONTH, @DateEnd), DATEPART(DAY, @DateEnd), '23', '59', '59', '0')	--конец периода отчета. Дата ожидания уведомления должна быть не позже даты окончания периода отчета, иначе срок формирования уведомления попадает на следующий отчетный срок
				AND AllRequestMessage.PackageDelivaredOn = AllRequestMessage.MinPackageDelivaredOn
			GROUP BY
				AllRequestMessage.DocumentUid 
				,AllRequestMessage.SenderGuid
				,AllRequestMessage.MessageType
				,AllRequestMessage.RecipientGuid
				,AllRequestMessage.PackageDelivaredOn
		) AS RequestMessage
		LEFT OUTER JOIN (
			SELECT		--ResponseMessage - Все Уведомления, отправленные в ответ на документы/ТК, с номерами пакетов
				MAX(#tmp_Packages.PackageId)	AS PackageId
				,AllResponseMessage.DocumentUid
				,AllResponseMessage.SenderGuid
				,AllResponseMessage.RecipientGuid
				,AllResponseMessage.ResponseDelivaredOn
			FROM (
				SELECT --AllResponseMessage - Все уведомления, отправленные в ответ на документы/ТК
					DocumentUid
					,ValidatingLog
					,SenderGuid
					,RecipientGuid
					,MessageType
					,PackageDelivaredOn AS ResponseDelivaredOn
					,MIN(PackageDelivaredOn) OVER (PARTITION BY  DocumentUid
																,SenderGuid
																,RecipientGuid
																,MessageType
													) AS MinResponseDelivaredOn --если более 1 одинаковой отправки уведомления (sender, Mess.Uid и recipient появляются больше, чем в одной записи), то берем минимальную дату передачи				
				FROM 
					RegistrationControl
				WHERE
					ResponseCount = 1
			) AS AllResponseMessage
			INNER JOIN #tmp_Packages
				ON #tmp_Packages.LogId = AllResponseMessage.ValidatingLog
			WHERE
				AllResponseMessage.ResponseDelivaredOn = AllResponseMessage.MinResponseDelivaredOn
			GROUP BY 			
				AllResponseMessage.DocumentUid
				,AllResponseMessage.SenderGuid
				,AllResponseMessage.RecipientGuid
				,AllResponseMessage.ResponseDelivaredOn
		) AS ResponseMessage
			ON RequestMessage.DocumentUid = ResponseMessage.DocumentUid 
			AND RequestMessage.SenderGuid = ResponseMessage.RecipientGuid 
			AND RequestMessage.RecipientGuid = ResponseMessage.SenderGuid
		--WHERE 
		--	(CASE
		--		WHEN DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, DATEADD(DAY, 5, RequestMessage.PackageDelivaredOn))) = 0  --если даты совпадают, то сравниваем по миллисекундам
		--		THEN DATEDIFF(MILLISECOND, GETDATE(), DATEADD(DAY, 5, RequestMessage.PackageDelivaredOn))
		--		ELSE DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, DATEADD(DAY, 5, RequestMessage.PackageDelivaredOn)))  --иначе сравниваем по дням
		--		END 
		--	> 0 
		--	AND CASE
		--				WHEN DATEDIFF(DAY, CONVERT(DATE, ResponseDelivaredOn), CONVERT(DATE, DATEADD(DAY, 5, RequestMessage.PackageDelivaredOn))) = 0 --если даты совпадают, то сравниваем по миллисекундам
		--				THEN DATEDIFF(MILLISECOND, ResponseDelivaredOn, DATEADD(DAY, 5, RequestMessage.PackageDelivaredOn))
		--				ELSE DATEDIFF(DAY, CONVERT(DATE, ResponseDelivaredOn), CONVERT(DATE, DATEADD(DAY, 5, RequestMessage.PackageDelivaredOn)))  --иначе сравниваем по дням
		--				END
		--			is not null) --если дата и время ожидания квитанции больше текущего системного времени, но DateDiff не null, значит уведомление пришло в срок до текущего времени. Иначе не учитываем, ибо квитанция может прийти позже текущего времени, но до даты ожидания
	    --
	
		--	OR (CASE
		--		WHEN DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, DATEADD(DAY, 5, RequestMessage.PackageDelivaredOn))) = 0  --если даты совпадают, то сравниваем по миллисекундам
		--		THEN DATEDIFF(MILLISECOND, GETDATE(), DATEADD(DAY, 5, RequestMessage.PackageDelivaredOn))
		--		ELSE DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, DATEADD(DAY, 5, RequestMessage.PackageDelivaredOn)))  --иначе сравниваем по дням
		--		END
		--	<= 0 )
	) AS FinalScoreNotifications
	RIGHT JOIN Member
		ON Member.Guid = FinalScoreNotifications.MemberResponseMessagerN

SELECT
	DENSE_RANK() OVER (ORDER BY Score DESC) AS Rank
	,*
FROM (
	SELECT
		Member.Name AS MemberResponseMessagerR
		,Score = Round(100*(CAST(ResponsedR AS FLOAT)/IIF(RequieredR = 0, 1, RequieredR)+ CAST(ResponsedN AS FLOAT)/IIF(RequieredN = 0, 1, RequieredN))/2, 2)
		--,#ScoreReceipt.PackageIdR
		--,#ScoreReceipt.MessageTypeR
		--,#ScoreReceipt.PackageDelivaredOnR
		,TotalMessageR
		,RequieredR
		,ResponsedR
		,TotalMessageN
		,RequieredN
		,ResponsedN
	FROM (
		SELECT --Объединяем оценку соблюдения отправки уведомлений и квитанций воедино
			#ScoreReceipt.MemberResponseMessagerR
			--,#ScoreReceipt.PackageIdR
			--,#ScoreReceipt.MessageTypeR
			--,#ScoreReceipt.PackageDelivaredOnR
			,SUM(ISNULL(#ScoreReceipt.[TotalMessageR], 0))			AS TotalMessageR
			,SUM(ISNULL(#ScoreReceipt.[RequieredR], 0))				AS RequieredR
			,SUM(ISNULL(#ScoreReceipt.[ResponsedR], 0))				AS ResponsedR
			,SUM(ISNULL(#ScoreNotifications.[TotalMessageN], 0))	AS TotalMessageN
			,SUM(ISNULL(#ScoreNotifications.[RequieredN], 0))		AS RequieredN
			,SUM(ISNULL(#ScoreNotifications.[ResponsedN], 0))		AS ResponsedN
		FROM #ScoreNotifications
		FULL OUTER JOIN #ScoreReceipt
			ON #ScoreReceipt.PackageIdR = #ScoreNotifications.PackageIdN
		WHERE 
			#ScoreReceipt.PackageIdR IS NOT NULL 
			OR (MemberResponseMessagerR IS NOT NULL AND #ScoreReceipt.PackageIdR IS NULL)
		GROUP BY 
			#ScoreReceipt.MemberResponseMessagerR
		--ORDER BY MemberResponseMessagerR
	) AS Report3
	INNER JOIN Member
		ON Member.Guid = Report3.MemberResponseMessagerR COLLATE SQL_Latin1_General_CP1_CI_AS
	WHERE
		Member.Active = 1
) AS Final_Rating