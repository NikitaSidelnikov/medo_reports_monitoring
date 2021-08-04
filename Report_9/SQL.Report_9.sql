---------------------------���������-------------------------------
--DECLARE @LogId INT
--SET @LogId = 6904879
-------------------------------------------------------------------

SELECT  --AllCriterionGroupScore  --������ ���������� ���� ������ � ������ ���� ����� ���������
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
	SELECT --ScoreLog  --������ ���������� ���� ������
		Score.ValidationLog
		,Score.Id
		,MAX(Score.Id) OVER (PARTITION BY Score.Criterion) AS MaxScoreId --��� �������� ������������� ������ �� ������ �������� ����� ������ � ������� Id
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
	(ScoreLog.Id = ScoreLog.MaxScoreId --������� ���������
	AND ScoreLog.Id is not null)
	OR ScoreLog.Id is null