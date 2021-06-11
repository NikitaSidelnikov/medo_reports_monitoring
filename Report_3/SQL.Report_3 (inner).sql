--DROP TABLE #tmp_Packages
--DROP TABLE #ScoreReceipt
--DROP TABLE #ScoreNotifications
CREATE TABLE #tmp_Packages (LogId BIGINT PRIMARY KEY, PackageId INT, ReceivedOn DATETIME2(7) NULL)
CREATE TABLE #ScoreReceipt (PackageIdR INT, MemberResponseMessagerR NVARCHAR(255), MessageTypeR NVARCHAR(255), PackageDelivaredOnR DATETIME2(7), TotalMessageR INT, RequieredR INT, ResponsedR INT)
CREATE TABLE #ScoreNotifications (PackageIdN INT, MemberResponseMessagerN NVARCHAR(255), MessageTypeN NVARCHAR(255), PackageDelivaredOnN DATETIME2(7), TotalMessageN INT, RequieredN INT, ResponsedN INT)


INSERT INTO #tmp_Packages  
	SELECT -- ActualLogs = актуальные пакеты в периоде отчёта
		ReportPacks.LogId
		,ReportPacks.Id as PackageId
		,ReportPacks.ReceivedOn
	FROM (
		SELECT -- ActualDates = актуальные даты логов пакетов. Если логи по пакету менялись, то берем последний обработанный лог
			Package AS Max_Package
			,MAX(ValidatedOn) AS Max_ValidatedOn
		FROM	
			ValidationLog
		WHERE 
			Success = 1
		GROUP BY
			Package
	) AS ActualDates
	INNER JOIN (
		SELECT -- ReportPacks = все обработанные (processed = 1) пакеты в периоде отчёта 
			ValidationLog.Id AS LogId
			,Package.Id
			,Package.ValidatedOn
			,Package.ReceivedOn
		FROM
			Package
		INNER JOIN ValidationLog
			ON ValidationLog.Package = Package.Id
		INNER JOIN Batch
			ON Batch.Id = Package.Batch
		INNER JOIN Member
			ON Member.Guid = Batch.MemberGuid
		WHERE
			--Package.ReceivedOn >=  @DataStart --начало периода отчета
			--AND Package.ReceivedOn < @DataEnd --конец периода отчета
			--Package.Incoming = 1 --только исходящие пакеты 
			Package.Processed = 1 --только обработанные пакеты
			AND Member.Name = @Member
	) AS ReportPacks
		ON ActualDates.Max_Package = ReportPacks.Id
		AND ActualDates.Max_ValidatedOn = ReportPacks.ValidatedOn

INSERT INTO #ScoreReceipt
	SELECT		
		PackageIdR
		,Member.Name
		,MessageTypeR
		,PackageDelivaredOnR
		,[TotalMessageR]
		,[RequieredR]
		,[ResponsedR]
	FROM (
		SELECT -- ScoreReceipt
			 RequestMessage.PackageId			AS PackageIdR
			 --,Member.Name						AS MemberResponseMessagerR
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
				MAX(#tmp_Packages.PackageId) AS PackageId
				,AllRequestMessage.MessageUid
				,AllRequestMessage.SenderGuid
				,AllRequestMessage.MessageType
				,AllRequestMessage.RecipientGuid
				,AllRequestMessage.PackageDelivaredOn
			FROM (
				SELECT  --AllRequestMessage - Все документы/ТК, ожидающие квитанции (или просто входящие квитанции)
					MessageUid
					,SenderGuid
					,MessageType
					,RecipientGuid
					,MAX(PackageDelivaredOn) AS PackageDelivaredOn --если более 1 одинаковой отправки документа/ТК (одинаковые sender, Doc.Uid и recipient появляются больше, чем в одной записи), то берем максимальную дату
				FROM 
					ConfirmationControl --WHERE Request = 1 отсутсвует, ибо мы смотрим ВСЕ входящие учаснику пакеты
				GROUP BY
					MessageUid
					,SenderGuid
					,RecipientGuid
					,MessageType
			) AS AllRequestMessage
			INNER JOIN ConfirmationControl
				ON ConfirmationControl.PackageDelivaredOn = AllRequestMessage.PackageDelivaredOn
				AND ConfirmationControl.MessageUid = AllRequestMessage.MessageUid
				AND ConfirmationControl.SenderGuid = AllRequestMessage.SenderGuid
				AND ConfirmationControl.RecipientGuid = AllRequestMessage.RecipientGuid
				AND ConfirmationControl.MessageType = AllRequestMessage.MessageType
			INNER JOIN #tmp_Packages
				ON #tmp_Packages.LogId = ConfirmationControl.ValidatingLog
			WHERE
				--#tmp_Packages.ReceivedOn >=  '2021-03-10' --начало периода отчета
				--AND #tmp_Packages.ReceivedOn < '2021-03-11' --конец периода отчета
				--ConfirmationControl.PackageDelivaredOn >=  DATETIMEFROMPARTS(DATEPART(YEAR, @DataStart), DATEPART(MONTH, @DataStart), DATEPART(DAY, @DataStart), '0', '0', '0', '0') --начало периода отчета
				--AND ConfirmationControl.PackageDelivaredOn < DATETIMEFROMPARTS(DATEPART(YEAR, @DataEnd), DATEPART(MONTH, @DataEnd), DATEPART(DAY, @DataEnd), '23', '59', '59', '0') --конец периода отчета	
				#tmp_Packages.ReceivedOn >=  DATETIMEFROMPARTS(DATEPART(YEAR, @DataStart), DATEPART(MONTH, @DataStart), DATEPART(DAY, @DataStart), '0', '0', '0', '0') --начало периода отчета
				AND #tmp_Packages.ReceivedOn < DATETIMEFROMPARTS(DATEPART(YEAR, @DataEnd), DATEPART(MONTH, @DataEnd), DATEPART(DAY, @DataEnd), '23', '59', '59', '0') --конец периода отчета	
				AND AllRequestMessage.PackageDelivaredOn is not null
			GROUP BY 
				AllRequestMessage.MessageUid
				,AllRequestMessage.SenderGuid
				,AllRequestMessage.MessageType
				,AllRequestMessage.RecipientGuid
				,AllRequestMessage.PackageDelivaredOn
		) AS RequestMessage
		LEFT OUTER JOIN (
			SELECT		--ResponseMessage - Все квитанции, отправленные в ответ на документы/ТК, с номерами пакетов
				MAX(#tmp_Packages.PackageId) AS PackageId --MAX берем, потому что может опять при объединении совпасть sender, repicient, messUid и даже ResponseDelivaredOn
				,AllResponseMessage.MessageUid
				,AllResponseMessage.SenderGuid
				,AllResponseMessage.RecipientGuid
				,AllResponseMessage.ResponseDelivaredOn
			FROM (
				SELECT --AllResponseMessage - Все квитанции, отправленные в ответ на документы/ТК
					MessageUid
					,SenderGuid
					,RecipientGuid
					,MessageType
					,MIN(PackageDelivaredOn) AS ResponseDelivaredOn --если более 1 одинаковой отправки квитанции (sender, Mess.Uid и recipient появляются больше, чем в одной записи), то берем минимальную дату передачи
				FROM 
					ConfirmationControl
				WHERE
					ResponseCount = 1
					--AND SenderGuid = '853dResponseMessage228-05e8-4ResponseMessage45-92ee-19deResponseMessageef3039f'
				GROUP BY
					MessageUid
					,SenderGuid
					,RecipientGuid
					,MessageType
			) AS AllResponseMessage

			INNER JOIN ConfirmationControl
				ON ConfirmationControl.PackageDelivaredOn = AllResponseMessage.ResponseDelivaredOn
				AND ConfirmationControl.MessageUid = AllResponseMessage.MessageUid
				AND ConfirmationControl.SenderGuid = AllResponseMessage.SenderGuid
				AND ConfirmationControl.RecipientGuid = AllResponseMessage.RecipientGuid
				AND ConfirmationControl.MessageType = AllResponseMessage.MessageType
			INNER JOIN #tmp_Packages
				ON #tmp_Packages.LogId = ConfirmationControl.ValidatingLog
			GROUP BY				
				AllResponseMessage.MessageUid
				,AllResponseMessage.SenderGuid
				,AllResponseMessage.RecipientGuid
				,AllResponseMessage.ResponseDelivaredOn
		) AS ResponseMessage
			ON RequestMessage.MessageUid = ResponseMessage.MessageUid 
			AND RequestMessage.SenderGuid = ResponseMessage.RecipientGuid 
			AND RequestMessage.RecipientGuid = ResponseMessage.SenderGuid
		WHERE 
			(CASE
				WHEN DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn))) = 0  --если даты совпадают, то сравниваем по миллисекундам
				THEN DATEDIFF(MILLISECOND, GETDATE(), DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn))
				ELSE DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn)))  --иначе сравниваем по дням
				END 
			> 0 
			AND CASE
						WHEN DATEDIFF(DAY, CONVERT(DATE, ResponseDelivaredOn), CONVERT(DATE, DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn))) = 0 --если даты совпадают, то сравниваем по миллисекундам
						THEN DATEDIFF(MILLISECOND, ResponseDelivaredOn, DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn))
						ELSE DATEDIFF(DAY, CONVERT(DATE, ResponseDelivaredOn), CONVERT(DATE, DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn)))  --иначе сравниваем по дням
						END
					is not null) --если дата и время ожидания квитанции больше текущего системного времени, но DataDiff не null, значит уведомление пришло в срок до текущего времени. Иначе не учитываем, ибо квитанция может прийти позже текущего времени, но до даты ожидания
	
			OR (CASE
				WHEN DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn))) = 0  --если даты совпадают, то сравниваем по миллисекундам
				THEN DATEDIFF(MILLISECOND, GETDATE(), DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn))
				ELSE DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn)))  --иначе сравниваем по дням
				END
			<= 0 )
	) AS FinalScoreReceipt
	RIGHT JOIN Member
		ON Member.Guid = FinalScoreReceipt.MemberResponseMessagerR
	WHERE
		Member.Name = @Member



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
		SELECT -- ScoreNotifications
			RequestMessage.PackageId			AS PackageIdN
			--,Member.Name						AS MemberResponseMessagerN
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
				MAX(#tmp_Packages.PackageId) AS PackageId
				,AllRequestMessage.DocumentUid 
				,AllRequestMessage.SenderGuid
				,AllRequestMessage.MessageType
				,AllRequestMessage.RecipientGuid
				,AllRequestMessage.PackageDelivaredOn
			FROM (
				SELECT  --AllRequestMessage - Все документы/ТК, ожидающие уведомления (или просто входящие уведомлния)
					DocumentUid
					,SenderGuid
					,MessageType
					,RecipientGuid
					,MAX(PackageDelivaredOn) AS PackageDelivaredOn --если более 1 одинаковой отправки документа/ТК (одинаковые sender, Doc.Uid и recipient появляются больше, чем в одной записи), то берем максимальную дату
				FROM 
					RegistrationControl --WHERE Request = 1 отсутсвует, ибо мы смотрим ВСЕ входящие учаснику пакеты
				GROUP BY
					DocumentUid
					,SenderGuid
					,RecipientGuid
					,MessageType
			) AS AllRequestMessage
			INNER JOIN RegistrationControl
				ON RegistrationControl.PackageDelivaredOn = AllRequestMessage.PackageDelivaredOn
				AND RegistrationControl.DocumentUid = AllRequestMessage.DocumentUid
				AND RegistrationControl.SenderGuid = AllRequestMessage.SenderGuid
				AND RegistrationControl.RecipientGuid = AllRequestMessage.RecipientGuid
				AND RegistrationControl.MessageType = AllRequestMessage.MessageType
			INNER JOIN #tmp_Packages
				ON #tmp_Packages.LogId = RegistrationControl.ValidatingLog
			WHERE
				--#tmp_Packages.ReceivedOn >=  '2021-03-10' --начало периода отчета
				--AND #tmp_Packages.ReceivedOn < '2021-03-11' --конец периода отчета
				--ConfirmationControl.PackageDelivaredOn >=  DATETIMEFROMPARTS(DATEPART(YEAR, @DataStart), DATEPART(MONTH, @DataStart), DATEPART(DAY, @DataStart), '0', '0', '0', '0') --начало периода отчета
				--AND ConfirmationControl.PackageDelivaredOn < DATETIMEFROMPARTS(DATEPART(YEAR, @DataEnd), DATEPART(MONTH, @DataEnd), DATEPART(DAY, @DataEnd), '23', '59', '59', '0') --конец периода отчета	
				#tmp_Packages.ReceivedOn >=  DATETIMEFROMPARTS(DATEPART(YEAR, @DataStart), DATEPART(MONTH, @DataStart), DATEPART(DAY, @DataStart), '0', '0', '0', '0') --начало периода отчета
				AND #tmp_Packages.ReceivedOn < DATETIMEFROMPARTS(DATEPART(YEAR, @DataEnd), DATEPART(MONTH, @DataEnd), DATEPART(DAY, @DataEnd), '23', '59', '59', '0') --конец периода отчета									
				AND AllRequestMessage.PackageDelivaredOn is not null
			GROUP BY
				AllRequestMessage.DocumentUid 
				,AllRequestMessage.SenderGuid
				,AllRequestMessage.MessageType
				,AllRequestMessage.RecipientGuid
				,AllRequestMessage.PackageDelivaredOn
		) AS RequestMessage
		LEFT OUTER JOIN (
			SELECT		--ResponseMessage - Все Уведомления, отправленные в ответ на документы/ТК, с номерами пакетов
				MAX(#tmp_Packages.PackageId) AS PackageId
				,AllResponseMessage.DocumentUid
				,AllResponseMessage.SenderGuid
				,AllResponseMessage.RecipientGuid
				,AllResponseMessage.ResponseDelivaredOn
			FROM (
				SELECT --AllResponseMessage - Все уведомления, отправленные в ответ на документы/ТК
					DocumentUid
					,SenderGuid
					,MessageType
					,RecipientGuid
					,MIN(PackageDelivaredOn) AS ResponseDelivaredOn --если более 1 одинаковой отправки квитанции (sender, Mess.Uid и recipient появляются больше, чем в одной записи), то берем минимальную дату передачи
				FROM 
					RegistrationControl
				WHERE
					ResponseCount = 1
					--AND SenderGuid = '853dResponseMessage228-05e8-4ResponseMessage45-92ee-19deResponseMessageef3039f'
				GROUP BY
					DocumentUid
					,SenderGuid
					,RecipientGuid
					,MessageType
			) AS AllResponseMessage

			INNER JOIN RegistrationControl
				ON RegistrationControl.PackageDelivaredOn = AllResponseMessage.ResponseDelivaredOn
				AND RegistrationControl.DocumentUid = AllResponseMessage.DocumentUid
				AND RegistrationControl.SenderGuid = AllResponseMessage.SenderGuid
				AND RegistrationControl.RecipientGuid = AllResponseMessage.RecipientGuid
				AND RegistrationControl.MessageType = AllResponseMessage.MessageType
			INNER JOIN #tmp_Packages
				ON #tmp_Packages.LogId = RegistrationControl.ValidatingLog
			GROUP BY 			
				AllResponseMessage.DocumentUid
				,AllResponseMessage.SenderGuid
				,AllResponseMessage.RecipientGuid
				,AllResponseMessage.ResponseDelivaredOn
		) AS ResponseMessage
			ON RequestMessage.DocumentUid = ResponseMessage.DocumentUid 
			AND RequestMessage.SenderGuid = ResponseMessage.RecipientGuid 
			AND RequestMessage.RecipientGuid = ResponseMessage.SenderGuid
		WHERE 
			(CASE
				WHEN DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, DATEADD(DAY, 5, RequestMessage.PackageDelivaredOn))) = 0  --если даты совпадают, то сравниваем по миллисекундам
				THEN DATEDIFF(MILLISECOND, GETDATE(), DATEADD(DAY, 5, RequestMessage.PackageDelivaredOn))
				ELSE DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, DATEADD(DAY, 5, RequestMessage.PackageDelivaredOn)))  --иначе сравниваем по дням
				END 
			> 0 
			AND CASE
						WHEN DATEDIFF(DAY, CONVERT(DATE, ResponseDelivaredOn), CONVERT(DATE, DATEADD(DAY, 5, RequestMessage.PackageDelivaredOn))) = 0 --если даты совпадают, то сравниваем по миллисекундам
						THEN DATEDIFF(MILLISECOND, ResponseDelivaredOn, DATEADD(DAY, 5, RequestMessage.PackageDelivaredOn))
						ELSE DATEDIFF(DAY, CONVERT(DATE, ResponseDelivaredOn), CONVERT(DATE, DATEADD(DAY, 5, RequestMessage.PackageDelivaredOn)))  --иначе сравниваем по дням
						END
					is not null) --если дата и время ожидания квитанции больше текущего системного времени, но DataDiff не null, значит уведомление пришло в срок до текущего времени. Иначе не учитываем, ибо квитанция может прийти позже текущего времени, но до даты ожидания
	
	
			OR (CASE
				WHEN DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, DATEADD(DAY, 5, RequestMessage.PackageDelivaredOn))) = 0  --если даты совпадают, то сравниваем по миллисекундам
				THEN DATEDIFF(MILLISECOND, GETDATE(), DATEADD(DAY, 5, RequestMessage.PackageDelivaredOn))
				ELSE DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, DATEADD(DAY, 5, RequestMessage.PackageDelivaredOn)))  --иначе сравниваем по дням
				END
			<= 0 )
	) AS FinalScoreNotifications
	RIGHT JOIN Member
		ON Member.Guid = FinalScoreNotifications.MemberResponseMessagerN
	WHERE
		Member.Name = @Member

SELECT
	#ScoreReceipt.PackageIdR
	,#ScoreReceipt.MemberResponseMessagerR
	,#ScoreReceipt.MessageTypeR
	,#ScoreReceipt.PackageDelivaredOnR
	,#ScoreReceipt.[TotalMessageR]					AS TotalMessageR
	,ISNULL(#ScoreReceipt.[RequieredR], 0)			AS RequieredR
	,ISNULL(#ScoreReceipt.[ResponsedR], 0)			AS ResponsedR
	,ISNULL(#ScoreNotifications.[TotalMessageN], 0)	AS TotalMessageN
	,ISNULL(#ScoreNotifications.[RequieredN], 0)	AS RequieredN
	,ISNULL(#ScoreNotifications.[ResponsedN], 0)	AS ResponsedN
FROM #ScoreNotifications
FULL OUTER JOIN #ScoreReceipt
	ON #ScoreReceipt.PackageIdR = #ScoreNotifications.PackageIdN
WHERE 
	#ScoreReceipt.PackageIdR IS NOT NULL 
	OR (MemberResponseMessagerR IS NOT NULL AND #ScoreReceipt.PackageIdR IS NULL)
	
--ORDER BY MemberResponseMessagerR
