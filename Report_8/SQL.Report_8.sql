SELECT  --AllCriterionGroupScore  --оценки выбранного лога пакета с учетом всех групп критериев
	CriterionGroup.Object				AS CriterionGroupName
	,CriterionGroup.Id					AS CriterionGroupId  
	,CAST(SUBSTRING(Criterion.Code, 3, 2) AS INT)	AS CriterionId  
	,Criterion.Name						AS CriterionName
	--,CriterionGroup.ScoreValue		AS MaxCriterionGroupValue
	,Criterion.ScoreValue				AS MaxCriterionValue
	,ScoreLog.AvgScore
FROM (
	SELECT --ScoreLog  --средние оценки по каждому критерию всех выбранных логов по выбраному участнику
		Score.Criterion	
		,AVG(Score.Value)	AS AvgScore
	FROM Score
	INNER JOIN (
		SELECT -- LastLog - Id последних валидных логов по каждому обработанному пакету
			ValidationLog.Id AS LogId
		FROM
			ValidationLog		
		INNER JOIN (
			SELECT -- SuccesPackage = даты последних валидных логов по каждому обработанному пакету
				SuccesLogs.Package				AS PackageId
				,MAX(SuccesLogs.ValidatedOn)	AS Max_ValidatedOn
			FROM (	
				SELECT -- SuccesLogs = все валидные логи по всем обработанным пакетам
					ValidationLog.Package
					,ValidationLog.ValidatedOn
				FROM
					ValidationLog
				INNER JOIN Package
					ON Package.Id = ValidationLog.Package
				WHERE 
					ValidationLog.Success = 1
					AND Package.Processed = 1
					AND Incoming = 0
					AND Package.ReceivedOn >=  IIF(@DataStart is null, Package.ReceivedOn, DATETIMEFROMPARTS(DATEPART(YEAR, @DataStart), DATEPART(MONTH, @DataStart), DATEPART(DAY, @DataStart), '0', '0', '0', '0')) --начало периода отчета
					AND Package.ReceivedOn <= IIF(@DataEnd is null, Package.ReceivedOn, DATETIMEFROMPARTS(DATEPART(YEAR, @DataEnd), DATEPART(MONTH, @DataEnd), DATEPART(DAY, @DataEnd), '23', '59', '59', '0')) --конец периода отчета
					--AND Package.ReceivedOn >=  '2021-03-01' --начало периода отчета
					--AND Package.ReceivedOn < '2021-04-01' --конец периода отчета
			) AS SuccesLogs
			GROUP BY 
				SuccesLogs.Package
		) AS SuccesPackage
			ON SuccesPackage.PackageId = ValidationLog.Package
			AND SuccesPackage.Max_ValidatedOn = ValidationLog.ValidatedOn
	) AS LastLog
		ON LastLog.LogId = Score.ValidationLog
	INNER JOIN Member
		ON Member.Guid = Score.MemberGuid
	WHERE 
		Member.Name = @Member
		--Member.Guid = 'ecc99082-f3b4-4028-8007-a7f69d6cd1d7' --АО ДОМ.РФ
	GROUP BY
		Score.Criterion	
) AS ScoreLog

RIGHT JOIN Criterion
	ON Criterion.Code = ScoreLog.Criterion
INNER JOIN CriterionGroup
	ON Criterion.CriterionGroup = CriterionGroup.Id
--ORDER BY CriterionGroupId, CriterionId



