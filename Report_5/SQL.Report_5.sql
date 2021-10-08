---------------------------ПАРАМЕТРЫ-------------------------------
--DECLARE @DateStart DateTime2
--DECLARE @DateEnd DateTime2
--SET @DateStart = '2021-04-01'
--SET @DateEnd = '2021-06-01'
-------------------------------------------------------------------

if object_id('tempdb..#tmp_ValidationLog') is not null
	DROP TABLE #tmp_ValidationLog
	
CREATE TABLE #tmp_ValidationLog (
								LogId BIGINT
								,ReceivedOn DATETIME2(7)
								,Incoming BIT
							) --Таблица всех валидных последних логов


INSERT INTO #tmp_ValidationLog  
	SELECT --ActualPackages = обработанные пакеты с последним логом в период отчета
		ProcessedPackage.LogId
		,ProcessedPackage.ReceivedOn
		,ProcessedPackage.Incoming
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
			,Package.Incoming
		FROM Package
		INNER JOIN ValidationLog
			ON ValidationLog.Package = Package.Id
		WHERE
			Processed = 1
			AND Success = 1
			--AND Incoming = 0 --только исходящие пакеты
			--AND Package.ReceivedOn >=  DATETIMEFROMPARTS(DATEPART(YEAR, @DateStart), DATEPART(MONTH, @DateStart), DATEPART(DAY, @DateStart), '0', '0', '0', '0') --начало периода отчета
			--AND Package.ReceivedOn < DATETIMEFROMPARTS(DATEPART(YEAR, @DateEnd), DATEPART(MONTH, @DateEnd), DATEPART(DAY, @DateEnd), '23', '59', '59', '0') --окончание периода отчета
	) AS ProcessedPackage
		ON ProcessedPackage.Package = ActualLog.PackageId
		AND ProcessedPackage.ValidatedOn = ActualLog.Max_ValidatedOn

SELECT
	DENSE_RANK() OVER(
		ORDER BY P1+P2+P3+P4+P5+MemberScoreP6.RatingP6+MemberScoreP7.RatingP7 DESC, Member.Name ASC
	  ) AS RankMember  --тут присваиваем позицию. Если очки у 1-ого и 2-ого участников одинаковы - то место одинаково. Если хоть по одной из групп критериев 0 очков или NULL - не попадает в общий рейтинг
	,P1+P2+P3+P4+P5+MemberScoreP6.RatingP6+MemberScoreP7.RatingP7	AS Rating
	,Member.Name
	,countP1
	,FormatScore.P1
	,countP2
	,FormatScore.P2
	,countP3
	,FormatScore.P3
	,countP4
	,FormatScore.P4
	,countP5
	,FormatScore.P5
	,MemberScoreP6.countMessP6	AS countP6 
	,MemberScoreP6.RatingP6		AS P6
	,MemberScoreP7.countMessP7	AS countP7
	,MemberScoreP7.RatingP7		AS P7
FROM(

	SELECT   -- Финальная таблица по простым форматным оценкам (п1-п5)
		MemberGuid 
		,MAX([countP1]) AS countP1 
		,MAX([P1])		AS P1			--Формат исходящего пакета
		,MAX([countP2]) AS countP2
		,MAX([P2])		AS P2			--Формат исходящего сообщения
		,MAX([countP3]) AS countP3
		,MAX([P3])		AS P3			--Формат исходящего документа
		,MAX([countP4]) AS countP4
		,MAX([P4])		AS P4			--Формат исходящего уведомления
		,MAX([countP5]) AS countP5
		,MAX([P5])		AS P5			--Формат исходящей квитанции
	FROM(	
		SELECT   -- Финальная таблица по простым форматным оценкам (п1-п5)
			MemberGuid 
			,'countP1' = IIF([1] is not null, CountCriterion, 0)			--case when ([1] is not null) then CountPackage end
			,[1]		AS P1											--Формат исходящего пакета
			,'countP2' = IIF([2] is not null, CountCriterion, 0)
			,[2]		AS P2											--Формат исходящего сообщения
			,'countP3' = IIF([3] is not null, CountCriterion, 0)
			,[3]		AS P3											--Формат исходящего документа
			,'countP4' = IIF([4] is not null, CountCriterion, 0)
			,[4]		AS P4											--Формат исходящего уведомления
			,'countP5' = IIF([5] is not null, CountCriterion, 0)
			,[5]		AS P5											--Формат исходящей квитанции
		FROM ( -- FinalScoreForMemberName = Сумма всех оценок по всем пакетам, кол-во пакетов по каждому участнику и итоговый рейтинг (среднее)
			SELECT
				Member.Guid											AS MemberGuid 
				--,ActualSumScore.CriterionGroup
				,SUBSTRING(ActualSumScore.Criterion, 1, 1)			AS CriterionGroup
				,MAX(IIF(Criterion LIKE '%.1', CountCriterion, 0))	AS CountCriterion	--критерий №1 любой группы критериев не повторяется в отличии от других, которые либо повторяются (3.2), либо отсутствуют вовсе (5.2). Поэтому по этому критерию можно четко определить кол-во пакетов по данной группе критериев
				,SUM(ActualSumScore.AvgValue)						AS Rating
			FROM (
				SELECT -- ActualSumScore = средняя оценка по каждому критерию для каждого участника
					Score.MemberGuid
					--,ScoreGrouped.CriterionGroup
					,Score.Criterion
					--,#tmp_ValidationLog.LogId
					,COUNT(*)					AS CountCriterion --не верно, ибо где-то может быть больше критериев (3.2) , где-то меньше (1.2)
					,AVG(Score.Value)			AS AvgValue
				FROM
					#tmp_ValidationLog
				INNER JOIN Score with(forceseek)
					ON Score.ValidationLog = #tmp_ValidationLog.LogId  
				--INNER JOIN ( --ScoreGrouped = оценки всех пакетов
				--	SELECT
				--		DISTINCT 
				--		Score.ValidationLog
				--		,Score.Value						--distinct сжирал много времени,  но он влилял на кол-во строк оценок (в группе критериев №3 14 критериев, но могло быть в Score 15 и больше)
				--		,Score.MemberGuid					--однако все value у повторяющихся строк 0, поэтому на среднюю оценку они не будут влиять, но на кол-во влияют
				--		--,Criterion.CriterionGroup
				--		,Score.Criterion
				--	FROM
				--		Score 
				--) AS ScoreGrouped
				--	ON #tmp_ValidationLog.LogId = ScoreGrouped.ValidationLog
				WHERE
					--#tmp_ValidationLog.Incoming = 0
					#tmp_ValidationLog.ReceivedOn between DATETIMEFROMPARTS(DATEPART(YEAR, @DateStart), DATEPART(MONTH, @DateStart), DATEPART(DAY, @DateStart), '0', '0', '0', '0') --начало периода отчета
					and DATETIMEFROMPARTS(DATEPART(YEAR, @DateEnd), DATEPART(MONTH, @DateEnd), DATEPART(DAY, @DateEnd), '23', '59', '59', '0') --конец периода отчета
					AND Incoming = 0
				GROUP BY
					Score.MemberGuid			
					,Score.Criterion
			) AS ActualSumScore
			RIGHT OUTER JOIN Member
				ON Member.Guid = ActualSumScore.MemberGuid
			WHERE 
				Member.Active = 1
			GROUP BY
				Member.Guid 
				--,ActualSumScore.CriterionGroup
				,SUBSTRING(ActualSumScore.Criterion, 1, 1)
		) AS FinalScoreForMemberName
		PIVOT(
			MAX(FinalScoreForMemberName.Rating)
			FOR FinalScoreForMemberName.CriterionGroup
			IN([1],[2],[3],[4],[5])	 
		) AS PivotTable
	) AS Final_Rating
	GROUP BY 
		MemberGuid 
) AS FormatScore

INNER JOIN (
	SELECT --MemberScoreP6 --подсчет кол-ва набранных очков, кол-во принятых пакетов участником и рейтинга (среднее)
		Member.Guid													AS MemberGuid 
		,SUM(ScoreForMessage.Score)/COUNT(ScoreForMessage.Member)	AS RatingP6
		,COUNT(ScoreForMessage.Member)								AS countMessP6
	FROM (	 
		SELECT --ScoreForMessage --очки за доставку уведомления в срок
			CheckMessageComplete.DocumentUid
			,CheckMessageComplete.Member
			,CheckMessageComplete.ControllerReactedOn
			,'Score' = CASE 
							WHEN CheckMessageComplete.DateDiff >= 0 THEN 200 
							WHEN ((CheckMessageComplete.DateDiff < 0) OR (CheckMessageComplete.DateDiff IS NULL)) THEN 0 
							END
		FROM (
			SELECT --CheckMessageComplete --проверка, что уведомление доставленно в срок (DateDiff < 0 - не в срок, DateDiff > в срок)
				RegistrationMessage.DocumentUid
				,RegistrationMessage.Member
				--,DATEDIFF(MILLISECOND, RegistrationMessage.MemberDelivaredOn, RegistrationMessage.ControllerReactedOn) AS DateDiff --Тут переполнение по миллисекундам идет - не подходит
				,'DateDiff' = IIF(DATEDIFF(DAY, CONVERT(DATE, RegistrationMessage.MemberDelivaredOn), CONVERT(DATE, RegistrationMessage.ControllerReactedOn)) = 0 --если даты совпадают, то сравниваем по минутам
									,DATEDIFF(MINUTE, RegistrationMessage.MemberDelivaredOn, RegistrationMessage.ControllerReactedOn)
									,DATEDIFF(DAY, CONVERT(DATE, RegistrationMessage.MemberDelivaredOn), CONVERT(DATE, RegistrationMessage.ControllerReactedOn)))  --иначе сравниваем по дням
																				
				,RegistrationMessage.ControllerReactedOn
			FROM (
				SELECT --RegistrationMessage - даты ожидания ответа от участника и даты доставки пакета от контроллера по каждому DocumentUid
					RequestMessage.DocumentUid					AS DocumentUid
					,RequestMessage.SenderGuid					AS Controller
					,RequestMessage.RecipientGuid				AS Member
					,RequestMessage.MaxReactedOn				AS ControllerReactedOn
					,ResponseMessage.MinPackageDelivaredOn		AS MemberDelivaredOn
				FROM (
					SELECT  --RequestMessage - Зарегистрированные документы/ТК, ожидающие уведомления в период очета по каждому участнику по каждому uid  документа
						RegistrationControl.DocumentUid
						,RegistrationControl.RecipientGuid
						,RegistrationControl.SenderGuid
						,RegistrationControl.MessageType
						,MAX(DATEADD(DAY, 5, RegistrationControl.PackageDelivaredOn)) AS MaxReactedOn --если более 1 одинаковой отправки документа/ТК (одинаковые sender, Doc.Uid и recipient появляются больше, чем в одной записи), то берем максимальную дату ожидания
					FROM RegistrationControl 
					INNER JOIN #tmp_ValidationLog  --Таблица всех валидных последних логов
						ON #tmp_ValidationLog.LogId = RegistrationControl.ValidatingLog
					WHERE
						RequestCount = 1
						AND RegistrationControl.PackageDelivaredOn >=  DATEADD(DAY, -5, DATETIMEFROMPARTS(DATEPART(YEAR, @DateStart), DATEPART(MONTH, @DateStart), DATEPART(DAY, @DateStart), '0', '0', '0', '0')) --начало периода отчета. Дата получения пакета должна быть не ранее, чем за 5 дней до отчетного периода
						AND DATEADD(DAY, 5, RegistrationControl.PackageDelivaredOn) <= DATETIMEFROMPARTS(DATEPART(YEAR, @DateEnd), DATEPART(MONTH, @DateEnd), DATEPART(DAY, @DateEnd), '23', '59', '59', '0')	--конец периода отчета. Дата ожидания уведомления должна быть не позже даты окончания периода отчета, иначе срок формирования уведомления попадает на следующий отчетный срок
					GROUP BY
						DocumentUid
						,SenderGuid
						,RecipientGuid
						,MessageType
				) AS RequestMessage -- выбираем документы и ТК, которые ожидают уведомления
				LEFT OUTER JOIN (
					SELECT --ResponseMessage - уведомления, отправленные в ответ на документы/ТК по каждому участнику и каждому uid Документа
						DocumentUid
						,SenderGuid
						,MessageType
						,RecipientGuid
						,MIN(PackageDelivaredOn) AS MinPackageDelivaredOn --если более 1 одинаковой отправки уведомления (sender, Doc.Uid и recipient появляются больше, чем в одной записи), то берем минимальную дату передачи
					FROM 
						RegistrationControl
					INNER JOIN #tmp_ValidationLog  --Таблица всех валидных последних логов
						ON #tmp_ValidationLog.LogId = RegistrationControl.ValidatingLog
					WHERE 	
						ResponseCount = 1
					GROUP BY
						DocumentUid
						,SenderGuid
						,RecipientGuid
						,MessageType
				) AS ResponseMessage -- выбираем уведомления, которые были отправлены как ответ на полученные документы и ТК
				ON 
					RequestMessage.DocumentUid = ResponseMessage.DocumentUid 
					AND RequestMessage.SenderGuid = ResponseMessage.RecipientGuid 
					AND RequestMessage.RecipientGuid = ResponseMessage.SenderGuid
			) AS RegistrationMessage
		) AS CheckMessageComplete
		--WHERE
		--	(CASE
		--		WHEN DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, CheckMessageComplete.ControllerReactedOn)) = 0  --если даты совпадают, то сравниваем по миллисекундам
		--		THEN DATEDIFF(MINUTE, GETDATE(), CheckMessageComplete.ControllerReactedOn)
		--		ELSE DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, CheckMessageComplete.ControllerReactedOn))  --иначе сравниваем по дням
		--		END 
		--	> 0 
		--	AND CheckMessageComplete.DateDiff is not null) --если дата и время ожидания квитанции больше текущего системного времени, но DateDiff не null, значит уведомление пришло в срок до текущего времени. Иначе не учитываем, ибо квитанция может прийти позже текущего времени, но до даты ожидания
		--	OR (CASE
		--		WHEN DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, CheckMessageComplete.ControllerReactedOn)) = 0  --если даты совпадают, то сравниваем по миллисекундам
		--		THEN DATEDIFF(MINUTE, GETDATE(), CheckMessageComplete.ControllerReactedOn)
		--		ELSE DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, CheckMessageComplete.ControllerReactedOn))  --иначе сравниваем по дням
		--		END
		--	<= 0 )	 
		
	) AS ScoreForMessage
	RIGHT OUTER JOIN Member
		ON Member.Guid = ScoreForMessage.Member
	GROUP BY 
		Member.Guid
) as MemberScoreP6
	ON MemberScoreP6.MemberGuid =FormatScore.MemberGuid

INNER JOIN (
	SELECT --MemberScoreP7 --подсчет кол-ва набранных очков, кол-во принятых пакетов участником и рейтинга (среднее)
		Member.Guid													AS MemberGuid 
		,SUM(ScoreForMessage.Score)/COUNT(ScoreForMessage.Member)	AS RatingP7
		,COUNT(ScoreForMessage.Member) as countMessP7
	FROM (	 
		SELECT --ScoreForMessage --очки за доставку уведомления в срок
			CheckMessageComplete.MessageUid
			,CheckMessageComplete.Member
			,CheckMessageComplete.ControllerReactedOn
			,'Score' = CASE 
							WHEN CheckMessageComplete.DateDiff >= 0 THEN 200 
							WHEN ((CheckMessageComplete.DateDiff < 0) OR (CheckMessageComplete.DateDiff IS NULL)) THEN 0 
							END
		FROM (
			SELECT --CheckMessageComplete --проверка, что уведомление доставленно в срок (DateDiff < 0 - не в срок, DateDiff > в срок)
				RegistrationMessage.MessageUid
				,RegistrationMessage.Member
				--,DATEDIFF(MILLISECOND, RegistrationMessage.MemberDelivaredOn, RegistrationMessage.ControllerReactedOn) AS DateDiff --Тут переполнение по миллисекундам идет - не подходит
				,'DateDiff' = IIF(DATEDIFF(DAY, CONVERT(DATE, RegistrationMessage.MemberDelivaredOn), CONVERT(DATE, RegistrationMessage.ControllerReactedOn)) = 0 --если даты совпадают, то сравниваем по миллисекундам
									,DATEDIFF(MINUTE, RegistrationMessage.MemberDelivaredOn, RegistrationMessage.ControllerReactedOn)
									,DATEDIFF(DAY, CONVERT(DATE, RegistrationMessage.MemberDelivaredOn), CONVERT(DATE, RegistrationMessage.ControllerReactedOn)))  --иначе сравниваем по дням
																				
				,RegistrationMessage.ControllerReactedOn
			FROM (
				SELECT --RegistrationMessage - даты ожидания ответа от участника и даты доставки пакета от контроллера по каждому DocumentUid
					RequestMessage.MessageUid					AS MessageUid
					,RequestMessage.SenderGuid					AS Controller
					,RequestMessage.RecipientGuid				AS Member
					,RequestMessage.MaxReactedOn				AS ControllerReactedOn
					,ResponseMessage.MinPackageDelivaredOn		AS MemberDelivaredOn
				FROM (
					SELECT  --RequestMessage - Зарегистрированные документы/ТК, ожидающие уведомления в период очета по каждому участнику по каждому uid  документа
						ConfirmationControl.MessageUid
						,ConfirmationControl.SenderGuid
						,ConfirmationControl.MessageType
						,ConfirmationControl.RecipientGuid
						,MAX(DATEADD(DAY, 3, ConfirmationControl.PackageDelivaredOn)) AS MaxReactedOn --если более 1 одинаковой отправки документа/ТК (одинаковые sender, Doc.Uid и recipient появляются больше, чем в одной записи), то берем максимальную дату ожидания
					FROM ConfirmationControl 
					INNER JOIN #tmp_ValidationLog  --Таблица всех валидных последних логов
						ON #tmp_ValidationLog.LogId = ConfirmationControl.ValidatingLog
					WHERE
						RequestCount = 1
						AND ConfirmationControl.PackageDelivaredOn >=  DATEADD(DAY, -3, DATETIMEFROMPARTS(DATEPART(YEAR, @DateStart), DATEPART(MONTH, @DateStart), DATEPART(DAY, @DateStart), '0', '0', '0', '0')) --начало периода отчета. Дата получения пакета должна быть не ранее, чем за 3 дня до отчетного периода
						AND DATEADD(DAY, 3, ConfirmationControl.PackageDelivaredOn) <= DATETIMEFROMPARTS(DATEPART(YEAR, @DateEnd), DATEPART(MONTH, @DateEnd), DATEPART(DAY, @DateEnd), '23', '59', '59', '0')	--конец периода отчета. Дата ожидания уведомления должна быть не позже даты окончания периода отчета, иначе срок формирования уведомления попадает на следующий отчетный срок
					GROUP BY
						MessageUid
						,SenderGuid
						,RecipientGuid
						,MessageType
				) AS RequestMessage -- выбираем документы и ТК, которые ожидают уведомления
				LEFT OUTER JOIN (
					SELECT --ResponseMessage - уведомления, отправленные в ответ на документы/ТК по каждому участнику и каждому uid Документа
						MessageUid
						,SenderGuid
						,MessageType
						,RecipientGuid
						,MIN(PackageDelivaredOn) AS MinPackageDelivaredOn --если более 1 одинаковой отправки уведомления (sender, Doc.Uid и recipient появляются больше, чем в одной записи), то берем минимальную дату передачи
					FROM 
						ConfirmationControl
					INNER JOIN #tmp_ValidationLog  --Таблица всех валидных последних логов
						ON #tmp_ValidationLog.LogId = ConfirmationControl.ValidatingLog
					WHERE 	
						ResponseCount = 1
					GROUP BY
						MessageUid
						,SenderGuid
						,RecipientGuid
						,MessageType
				) AS ResponseMessage -- выбираем уведомления, которые были отправлены как ответ на полученные документы и ТК
				ON 
					RequestMessage.MessageUid = ResponseMessage.MessageUid 
					AND RequestMessage.SenderGuid = ResponseMessage.RecipientGuid 
					AND RequestMessage.RecipientGuid = ResponseMessage.SenderGuid
			) AS RegistrationMessage
		) AS CheckMessageComplete
		--WHERE
		--	(CASE
		--		WHEN DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, CheckMessageComplete.ControllerReactedOn)) = 0  --если даты совпадают, то сравниваем по миллисекундам
		--		THEN DATEDIFF(MINUTE, GETDATE(), CheckMessageComplete.ControllerReactedOn)
		--		ELSE DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, CheckMessageComplete.ControllerReactedOn))  --иначе сравниваем по дням
		--		END 
		--	> 0 
		--	AND CheckMessageComplete.DateDiff is not null) --если дата и время ожидания квитанции больше текущего системного времени, но DateDiff не null, значит уведомление пришло в срок до текущего времени. Иначе не учитываем, ибо квитанция может прийти позже текущего времени, но до даты ожидания
		--	OR (CASE
		--		WHEN DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, CheckMessageComplete.ControllerReactedOn)) = 0  --если даты совпадают, то сравниваем по миллисекундам
		--		THEN DATEDIFF(MINUTE, GETDATE(), CheckMessageComplete.ControllerReactedOn)
		--		ELSE DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, CheckMessageComplete.ControllerReactedOn))  --иначе сравниваем по дням
		--		END
		--	<= 0 )	 
		
	) AS ScoreForMessage
	RIGHT OUTER JOIN Member
		ON Member.Guid = ScoreForMessage.Member
	GROUP BY 
		Member.Guid
) AS MemberScoreP7
	ON MemberScoreP7.MemberGuid =FormatScore.MemberGuid 
RIGHT JOIN Member
	ON Member.Guid = FormatScore.MemberGuid COLLATE SQL_Latin1_General_CP1_CI_AS
WHERE
	Active = 1