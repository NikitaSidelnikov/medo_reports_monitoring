SELECT  --AllCriterionGroupScore  --оценки выбранного лога пакета с учетом всех групп критериев
	ScoreLog.ValidationLog
	,CriterionGroup.Id			AS CriterionGroupId
	,CriterionGroup.Object		AS CriterionGroupName
	,CriterionGroup.ScoreValue	AS MaxCriterionGroupValue
	,Criterion.Code				AS CriterionId  
	,Criterion.Name				AS CriterionName
	,Criterion.ScoreValue		AS MaxCriterionValue
	,ScoreLog.MemberGuid
	,ScoreLog.Value
	,ScoreLog.Description
FROM (
	SELECT --ScoreLog  --оценки выбранного лога пакета
		ValidationLog.Package
		,ValidationLog.Id		AS ValidationLog
		,Score.Criterion
		,Score.MemberGuid
		,Score.Value
		,Score.Description
	FROM Score
	INNER JOIN ValidationLog
		ON ValidationLog.Id = Score.ValidationLog
	INNER JOIN (
		SELECT -- SuccesPackage = актуальна€ дата лога пакета. ≈сли логи по пакету мен€лись, то берем последний обработанный лог
			SuccesLogs.Package				AS PackageId
			,MAX(SuccesLogs.ValidatedOn)	AS Max_ValidatedOn
		FROM (	
			SELECT -- SuccesLogs = лог выбранного валидного и обработанного пакета
				ValidationLog.Package
				,ValidationLog.ValidatedOn
			FROM
				ValidationLog
			INNER JOIN Package
				ON Package.Id = ValidationLog.Package
			WHERE 
				Success = 1
				--AND Package.Id = @Package
				AND Incoming = 0
				AND Package.Id = 2
		) AS SuccesLogs

		GROUP BY SuccesLogs.Package
	) AS SuccesPackage
		ON SuccesPackage.PackageId = ValidationLog.Package
		AND SuccesPackage.Max_ValidatedOn = ValidationLog.ValidatedOn
) AS ScoreLog

RIGHT JOIN Criterion
	ON Criterion.Code = ScoreLog.Criterion
INNER JOIN CriterionGroup
	ON Criterion.CriterionGroup = CriterionGroup.Id

--ORDER BY CriterionId


