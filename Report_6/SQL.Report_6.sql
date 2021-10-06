---------------------------ПАРАМЕТРЫ-------------------------------
--DECLARE @DateStart DateTime2
--DECLARE @DateEnd DateTime2
--SET @DateStart = '2021-03-01'
--SET @DateEnd = '2021-04-01'
-------------------------------------------------------------------

if object_id('tempdb..#Tmp') IS NOT NULL
	drop table #Tmp

CREATE TABLE #Tmp (LogId BIGINT NOT NULL)

INSERT INTO #Tmp
	SELECT --ActualPackages = обработанные пакеты с последним логом в период отчета
		ProcessedPackage.LogId
	FROM(
		SELECT -- ActualLog = последний лог по пакету
			ValidationLog.Package	AS PackageId
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
			AND Package.ReceivedOn < DATETIMEFROMPARTS(DATEPART(YEAR, @DateEnd), DATEPART(MONTH, @DateEnd), DATEPART(DAY, @DateEnd), '23', '59', '59', '0') --окончание периода отчета
	) AS ProcessedPackage
		ON ProcessedPackage.Package = ActualLog.PackageId
		AND ProcessedPackage.ValidatedOn = ActualLog.Max_ValidatedOn


/*
	Оценка = СУММ(Prop_ES*w), где w - вес использования справочника
	--Вес "Вид документа"		= 0.4
	--Вес "Гриф документа"		= 0.2
	--Вес "Регион документа"	= 0.2
	--Вес "Тип связи документа"	= 0.2
	Сумма коэф. = 1
*/

SELECT
	DENSE_RANK() OVER (
						PARTITION BY 
							MemberType 
						ORDER BY 
							Score DESC
					 )	AS Rank		--позиция в рейтинге
	,*
FROM (
	SELECT --Оценка использования справочников в документах		
		Member.Name
		,Member.Type	AS MemberType
		,ROUND(100 * ( 0.4 * CAST(Prop_ED_Type		AS  FLOAT)
					 + 0.2 * CAST(Prop_ED_Signature AS  FLOAT)
					 + 0.2 * CAST(Prop_ED_Region	AS  FLOAT) 
					 + 0.2 * CAST(Prop_ED_Relation	AS  FLOAT)
					 ) 
				,2)	AS Score	--оценка участника
		,Count_ED
		,ISNULL(SUM_ED_Type, 0)						AS SUM_ED_Type
		,ISNULL(SUM_ED_Signature, 0)				AS SUM_ED_Signature
		,ISNULL(SUM_ED_Region, 0)					AS SUM_ED_Region
		,ISNULL(SUM_ED_Relation, 0)					AS SUM_ED_Relation
		,ISNULL(ROUND(Prop_ED_Type, 4), 0)			AS Prop_ED_Type
		,ISNULL(ROUND(Prop_ED_Signature, 4), 0)		AS Prop_ED_Signature
		,ISNULL(ROUND(Prop_ED_Region, 4), 0)		AS Prop_ED_Region
		,ISNULL(ROUND(Prop_ED_Relation, 4), 0)		AS Prop_ED_Relation
	FROM (
		SELECT --Статистика по использованию справочников в ЭД
			MemberGuid
			,IIF(Using_Directory.MemberGuid is not null, COUNT(*), 0)	AS Count_ED				--Всего документов
			,SUM(ED_Type)												AS SUM_ED_Type			--Всего ЭД с заполненным "Вид документа"
			,SUM(ED_Signature)											AS SUM_ED_Signature		--Всего ЭД с заполненным "Гриф документа"
			,SUM(ED_Region)												AS SUM_ED_Region		--Всего ЭД с заполненным "Регион документа"
			,SUM(ED_Relation)											AS SUM_ED_Relation		--Всего ЭД с заполненным "Тип связи документа"
			,SUM(CAST(ED_Type AS FLOAT))/COUNT(*)						AS Prop_ED_Type			--Доля ЭД с заполненным "Вид документа"
			,SUM(CAST(ED_Signature AS FLOAT))/COUNT(*)					AS Prop_ED_Signature	--Доля ЭД с заполненным "Гриф документа"
			,SUM(CAST(ED_Region AS FLOAT))/COUNT(*)						AS Prop_ED_Region		--Доля ЭД с заполненным "Регион документа"
			,SUM(CAST(ED_Relation AS FLOAT))/COUNT(*)					AS Prop_ED_Relation		--Доля ЭД с заполненным "Тип связи документа"
		FROM (
			SELECT --Перечень ЭД с признаком использования справочников (отформатированная таблица)
				ValidationLog
				,MemberGuid
				,MAX(ED_Type)		AS ED_Type
				,MAX(ED_Signature)	AS ED_Signature
				,MAX(ED_Region)		AS ED_Region
				,MAX(ED_Relation)	AS ED_Relation
			FROM (
				SELECT --Перечень ЭД с признаком использования справочников
					Score.ValidationLog
					,Score.MemberGuid
					,IIF(Score.Value <> 0 and Score.Criterion = '3.6', 1, 0)	AS ED_Type		--Заполнен "Вид документа"
					,IIF(Score.Value <> 0 and Score.Criterion = '3.7', 1, 0)	AS ED_Signature	--Заполнен "Гриф документа"
					,IIF(Score.Value <> 0 and Score.Criterion = '3.8', 1, 0)	AS ED_Region	--Заполнен "Регион документа"
					,IIF(Score.Value <> 0 and Score.Criterion = '3.11', 1, 0)	AS ED_Relation	--Заполнен "Тип связи документа"
				FROM #Tmp 
				INNER JOIN Score
					ON Score.ValidationLog = #Tmp.LogId
				WHERE 
					Score.Criterion IN ('3.6', '3.7', '3.8', '3.11')
			) AS ED_Directory
			GROUP BY
				MemberGuid		
				,ValidationLog
		) AS Using_Directory
		GROUP BY 
			MemberGuid
	) AS Stats_Directory
	RIGHT JOIN Member
		ON Member.Guid = Stats_Directory.MemberGuid
	WHERE
		Member.Active = 1
) AS Score_Directory

