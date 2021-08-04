---------------------------ѕј–јћ≈“–џ-------------------------------
--DECLARE @LogId INT
--SET @LogId = 6904879
-------------------------------------------------------------------

SELECT  --AllCriterionGroupScore  --оценки выбранного лога пакета с учетом всех групп критериев
	--ScoreLog.ValidationLog
	--ScoreLog.Id
	--,ScoreLog.MaxScoreId
	CriterionGroup.Id			AS CriterionGroupId
	,CriterionGroup.Object		AS CriterionGroupName
	,CriterionGroup.ScoreValue	AS MaxCriterionGroupValue
	,Criterion.Code				AS CriterionId  
	,Criterion.Name				AS CriterionName
	,Criterion.ScoreValue		AS MaxCriterionValue
	--,ScoreLog.MemberGuid
	,ScoreLog.Value
	,ScoreLog.Description
FROM (
	SELECT --ScoreLog  --оценки выбранного лога пакета
		Score.ValidationLog
		,Score.Id
		,MAX(Score.Id) OVER (PARTITION BY Score.Criterion) AS MaxScoreId --ƒл€ удалени€ повтор€ющихс€ оценок по одному критерию берем оценку с большим Id
		,Score.Criterion
		,Score.MemberGuid
		,Score.Value
		,Score.Description
	FROM Score
	WHERE
		ValidationLog = @LogId
) AS ScoreLog
RIGHT JOIN Criterion
	ON Criterion.Code = ScoreLog.Criterion
INNER JOIN CriterionGroup
	ON Criterion.CriterionGroup = CriterionGroup.Id
WHERE
	(ScoreLog.Id = ScoreLog.MaxScoreId --”бираем дубликаты
	AND ScoreLog.Id is not null)
	OR ScoreLog.Id is null