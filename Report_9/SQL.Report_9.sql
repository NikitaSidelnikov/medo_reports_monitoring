---------------------------���������-------------------------------
--DECLARE @LogId INT
--SET @LogId = 696760
-------------------------------------------------------------------

SELECT  --AllCriterionGroupScore  --������ ���������� ���� ������ � ������ ���� ����� ���������
	--ScoreLog.ValidationLog
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
	SELECT --ScoreLog  --������ ���������� ���� ������
		Score.ValidationLog
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
