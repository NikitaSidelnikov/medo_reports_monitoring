---------------------------ПАРАМЕТРЫ-------------------------------
--DECLARE @DateStart DateTime2
--DECLARE @DateEnd DateTime2
--SET @DateStart = '2021-03-01'
--SET @DateEnd = '2021-06-01'
-------------------------------------------------------------------

IF OBJECT_ID('tempdb..#Tmp') is not null
	DROP TABLE #Tmp

CREATE TABLE #Tmp (LogId BIGINT NOT NULL)

INSERT INTO #Tmp
	SELECT --ActualPackages = обработанные пакеты с последним логом в период отчета
		ProcessedPackage.LogId
		--,ProcessedPackage.Success
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
		SELECT --ProcessedPackage = обработанные пакеты в период отчета
			ValidationLog.Package
			,ValidationLog.Id			AS LogId
			,ValidationLog.ValidatedOn
		FROM Package
		INNER JOIN ValidationLog
			ON ValidationLog.Package = Package.Id
		WHERE
			Processed = 1
			AND Success = 1
			AND Incoming = 0 --только исходящие пакеты
			AND Package.ReceivedOn >=  DATETIMEFROMPARTS(DATEPART(YEAR, @DateStart), DATEPART(MONTH, @DateStart), DATEPART(DAY, @DateStart), '0', '0', '0', '0') --начало периода отчета
			AND Package.ReceivedOn < DATEADD(DAY, 1, DATETIMEFROMPARTS(DATEPART(YEAR, @DateEnd), DATEPART(MONTH, @DateEnd), DATEPART(DAY, @DateEnd), '0', '0', '0', '0')) --конец периода отчета
	) AS ProcessedPackage
		ON ProcessedPackage.Package = ActualLog.PackageId
		AND ProcessedPackage.ValidatedOn = ActualLog.Max_ValidatedOn

SELECT --Рейтинговая таблица по использованию ЭП в документах
	DENSE_RANK() OVER	(
							PARTITION BY 
								MemberType 
							ORDER BY 
								ROUND(100*(Prop_ES_in_ED + Prop_ES_in_TC)/2, 2) DESC
						)								AS Rank		--позиция в рейтинге
	,*
FROM (	
	SELECT --Рейтинговая таблица по использованию ЭП в документах
		Member.Name
		,Member.Type										AS MemberType
		,ROUND(100*(Prop_ES_in_ED + Prop_ES_in_TC)/2, 2)	AS Rating	--оценка участника
		,Count_ED
		,ISNULL(SUM_ES_in_ED, 0)							AS SUM_ES_in_ED
		,ISNULL(SUM_ES_in_TC, 0)							AS SUM_ES_in_TC
		,ISNULL(ROUND(Prop_ES_in_ED, 4), 0)					AS Prop_ES_in_ED
		,ISNULL(ROUND(Prop_ES_in_TC, 4), 0)					AS Prop_ES_in_TC
	FROM (
		SELECT --Статистика по использованию ЭП в ТК по каждому участнику
			MemberGuid									
			,IIF(MemberGuid is not null, COUNT(*), 0)			AS Count_ED			--Всего документов
			,SUM(ES_in_ED)										AS SUM_ES_in_ED		--Всего ЭД с подписью
			,SUM(ES_in_TC)										AS SUM_ES_in_TC		--Всего ТК с подписью
			,SUM(CAST(ES_in_ED AS FLOAT))/COUNT(*)				AS Prop_ES_in_ED	--Доля ЭД с подписью
			,SUM(CAST(ES_in_TC AS FLOAT))/COUNT(*)				AS Prop_ES_in_TC	--Доля ТК с подписью
		FROM (
			SELECT --Перечень ТК использующих/не использующих ЭП
				MemberGuid
				,MAX(ES_in_ED) AS ES_in_ED
				,MAX(ES_in_TC) AS ES_in_TC
			FROM (
				SELECT --Перечень ТК использующих/не использующих ЭП
					Score.ValidationLog
					,Score.MemberGuid
					,IIF(Score.Value <> 0 and Score.Criterion = '3.13', 1, 0) AS ES_in_ED --Электронная подпись в ЭД
					,IIF(Score.Value <> 0 and Score.Criterion = '3.14', 1, 0) AS ES_in_TC --Электронная подпись в ТК
				FROM #Tmp 
				INNER JOIN Score
					ON Score.ValidationLog = #Tmp.LogId
				WHERE 
					Score.Criterion IN ('3.13', '3.14')
			) AS SIG_in_ED_TC
			GROUP BY
				ValidationLog	
				,MemberGuid
		) AS Using_SIG
		GROUP BY 
			MemberGuid
	) AS Stats_SIG
	RIGHT JOIN Member
		ON Member.Guid = Stats_SIG.MemberGuid
	WHERE
		Member.Active = 1
) AS Score_SIG