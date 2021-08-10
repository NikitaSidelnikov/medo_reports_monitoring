---------------------------���������-------------------------------
--DECLARE @DateStart DateTime2
--DECLARE @DateEnd DateTime2
--SET @DateStart = '2021-04-01'
--SET @DateEnd = '2021-06-01'
-------------------------------------------------------------------

if object_id('tempdb..#tmp_ValidationLog') is not null
	DROP TABLE #tmp_ValidationLog

CREATE TABLE #tmp_ValidationLog (
								LogId BIGINT PRIMARY KEY
								,Incoming BIT
								,ReceivedOn DATETIME2(7)
							) --������� ���� �������� ��������� �����

INSERT INTO #tmp_ValidationLog  
	SELECT -- ActualLogs - Id ��������� �������� ����� �� ������� ������������� ������ � ������ ������
		ValidationLog.Id		AS LogId
		,SuccesPackage.Incoming
		,SuccesPackage.ReceivedOn
	FROM
		ValidationLog		
	INNER JOIN (
		SELECT -- SuccesPackage = ���� ��������� �������� ����� �� ������� ������������� ������ � ������ ������. ���� � ������ ��������� ����� ���������, �� ��� ������� ���������� ���� ValidatedOn � ������������ ValidatedOn �� ������. � ����� ������� �� � ������� ��, ��� �����
			SuccesLogs.Package		AS PackageId
			,SuccesLogs.Incoming
			,SuccesLogs.ValidatedOn
			,MAX(SuccesLogs.ValidatedOn) OVER (PARTITION BY SuccesLogs.Package)	AS Max_ValidatedOn
			,SuccesLogs.ReceivedOn	
		FROM (	
			SELECT -- SuccesLogs = ��� �������� ���� �� ���� ������������ ������� � ������ ������
				ValidationLog.Package
				,ValidationLog.ValidatedOn
				,Package.Incoming
				,Package.ReceivedOn
			FROM
				ValidationLog
			INNER JOIN Package
				ON Package.Id = ValidationLog.Package
			WHERE 
				ValidationLog.Success = 1
				AND Package.Processed = 1
		) AS SuccesLogs
	) AS SuccesPackage
		ON SuccesPackage.PackageId = ValidationLog.Package
		AND SuccesPackage.Max_ValidatedOn = ValidationLog.ValidatedOn
	WHERE
		SuccesPackage.Max_ValidatedOn = SuccesPackage.ValidatedOn


SELECT
	DENSE_RANK() OVER(	PARTITION BY Member.Type
						ORDER BY P1+P2+P3+P4+P5+MemberScoreP6.RatingP6+MemberScoreP7.RatingP7 DESC
	  ) AS RankMember  --��� ����������� �������. ���� ���� � 1-��� � 2-��� ���������� ��������� - �� ����� ���������. ���� ���� �� ����� �� ����� ��������� 0 ����� ��� NULL - �� �������� � ����� �������
	,P1+P2+P3+P4+P5+MemberScoreP6.RatingP6+MemberScoreP7.RatingP7	AS Rating
	,Member.Name
	,Member.Type AS MemberType
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

	SELECT   -- ��������� ������� �� ������� ��������� ������� (�1-�5)
		MemberGuid 
		,MAX([countP1]) AS countP1 
		,MAX([P1])		AS P1			--������ ���������� ������
		,MAX([countP2]) AS countP2
		,MAX([P2])		AS P2			--������ ���������� ���������
		,MAX([countP3]) AS countP3
		,MAX([P3])		AS P3			--������ ���������� ���������
		,MAX([countP4]) AS countP4
		,MAX([P4])		AS P4			--������ ���������� �����������
		,MAX([countP5]) AS countP5
		,MAX([P5])		AS P5			--������ ��������� ���������
	FROM(	
		SELECT   -- ��������� ������� �� ������� ��������� ������� (�1-�5)
			MemberGuid 
			,'countP1' = IIF([1] is not null, CountPackage, 0)			--case when ([1] is not null) then CountPackage end
			,[1]		AS P1											--������ ���������� ������
			,'countP2' = IIF([2] is not null, CountPackage, 0)
			,[2]		AS P2											--������ ���������� ���������
			,'countP3' = IIF([3] is not null, CountPackage, 0)
			,[3]		AS P3											--������ ���������� ���������
			,'countP4' = IIF([4] is not null, CountPackage, 0)
			,[4]		AS P4											--������ ���������� �����������
			,'countP5' = IIF([5] is not null, CountPackage, 0)
			,[5]		AS P5											--������ ��������� ���������
		FROM(
			SELECT  -- FinalScoreForMemberName = ����� ���� ������ �� ���� �������, ���-�� ������� �� ������� ��������� � �������� ������� (�������)
				Member.Guid												AS MemberGuid 
				--,ActualSumScore.CriterionGroup
				,CAST(SUBSTRING(ActualSumScore.Criterion, 1, 1) AS INT)	AS CriterionGroup
				,MAX(CountCriterion)									AS CountPackage
				--,COUNT(ActualSumScore.SumValue) AS CountPackage
				,SUM(ActualSumScore.AvgValue)							AS Rating
			FROM (
				SELECT -- ActualSumScore = ������� ������ �� ������� �������� ��� ������� ���������
					ScoreGrouped.MemberGuid
					--,ScoreGrouped.CriterionGroup
					,ScoreGrouped.Criterion
					--,#tmp_ValidationLog.LogId
					,COUNT(CAST(SUBSTRING(ScoreGrouped.Criterion, 1, 1) AS INT))	AS CountCriterion  
					,AVG(ScoreGrouped.Value)										AS AvgValue
				FROM
					#tmp_ValidationLog --������� ���� �������� ��������� �����
				INNER JOIN ( --ScoreGrouped = ������ ���� �������
					SELECT
						DISTINCT 
						Score.ValidationLog
						,Score.Value
						,Score.MemberGuid
						--,Criterion.CriterionGroup
						,Score.Criterion
					FROM
						Score 
				) AS ScoreGrouped
					ON #tmp_ValidationLog.LogId = ScoreGrouped.ValidationLog
				WHERE
					#tmp_ValidationLog.Incoming = 0
					AND #tmp_ValidationLog.ReceivedOn >=  DATETIMEFROMPARTS(DATEPART(YEAR, @DateStart), DATEPART(MONTH, @DateStart), DATEPART(DAY, @DateStart), '0', '0', '0', '0') --������ ������� ������
					AND #tmp_ValidationLog.ReceivedOn < DATETIMEFROMPARTS(DATEPART(YEAR, @DateEnd), DATEPART(MONTH, @DateEnd), DATEPART(DAY, @DateEnd), '23', '59', '59', '0') --����� ������� ������
					--AND #tmp_ValidationLog.ReceivedOn >=  '2021-03-01' --������ ������� ������
					--AND #tmp_ValidationLog.ReceivedOn < '2021-04-01' --����� ������� ������
				GROUP BY
					ScoreGrouped.MemberGuid
					--,#tmp_ValidationLog.LogId
					--,ScoreGrouped.CriterionGroup					
					,ScoreGrouped.Criterion
			) AS ActualSumScore
			RIGHT OUTER JOIN Member
				ON Member.Guid = ActualSumScore.MemberGuid
			GROUP BY
				Member.Guid 
				--,ActualSumScore.CriterionGroup
				,CAST(SUBSTRING(ActualSumScore.Criterion, 1, 1) AS INT)
			)x
			PIVOT(
				MAX(Rating)
				FOR CriterionGroup
				IN([1],[2],[3],[4],[5])	 
			) AS PivotTable
	) AS Final_Rating
	GROUP BY 
		MemberGuid 
) AS FormatScore

INNER JOIN (
	SELECT --MemberScoreP6 --������� ���-�� ��������� �����, ���-�� �������� ������� ���������� � �������� (�������)
		Member.Guid													AS MemberGuid 
		,SUM(ScoreForMessage.Score)/COUNT(ScoreForMessage.Member)	AS RatingP6
		,COUNT(ScoreForMessage.Member)								AS countMessP6
	FROM (	 
		SELECT --ScoreForMessage --���� �� �������� ����������� � ����
			CheckMessageComplete.DocumentUid
			,CheckMessageComplete.Member
			,CheckMessageComplete.ControllerReactedOn
			,'Score' = CASE 
							WHEN CheckMessageComplete.DateDiff >= 0 THEN 200 
							WHEN ((CheckMessageComplete.DateDiff < 0) OR (CheckMessageComplete.DateDiff IS NULL)) THEN 0 
							END
		FROM (
			SELECT --CheckMessageComplete --��������, ��� ����������� ����������� � ���� (DateDiff < 0 - �� � ����, DateDiff > � ����)
				RegistrationMessage.DocumentUid
				,RegistrationMessage.Member
				--,DATEDIFF(MILLISECOND, RegistrationMessage.MemberDelivaredOn, RegistrationMessage.ControllerReactedOn) AS DateDiff --��� ������������ �� ������������� ���� - �� ��������
				,'DateDiff' = IIF(DATEDIFF(DAY, CONVERT(DATE, RegistrationMessage.MemberDelivaredOn), CONVERT(DATE, RegistrationMessage.ControllerReactedOn)) = 0 --���� ���� ���������, �� ���������� �� �������
									,DATEDIFF(MINUTE, RegistrationMessage.MemberDelivaredOn, RegistrationMessage.ControllerReactedOn)
									,DATEDIFF(DAY, CONVERT(DATE, RegistrationMessage.MemberDelivaredOn), CONVERT(DATE, RegistrationMessage.ControllerReactedOn)))  --����� ���������� �� ����
																				
				,RegistrationMessage.ControllerReactedOn
			FROM (
				SELECT --RegistrationMessage - ���� �������� ������ �� ��������� � ���� �������� ������ �� ����������� �� ������� DocumentUid
					RequestMessage.DocumentUid					AS DocumentUid
					,RequestMessage.SenderGuid					AS Controller
					,RequestMessage.RecipientGuid				AS Member
					,RequestMessage.MaxReactedOn				AS ControllerReactedOn
					,ResponseMessage.MinPackageDelivaredOn		AS MemberDelivaredOn
				FROM (
					SELECT  --RequestMessage - ������������������ ���������/��, ��������� ����������� � ������ ����� �� ������� ��������� �� ������� uid  ���������
						RegistrationControl.DocumentUid
						,RegistrationControl.RecipientGuid
						,RegistrationControl.SenderGuid
						,RegistrationControl.MessageType
						,MAX(DATEADD(DAY, 5, RegistrationControl.PackageDelivaredOn)) AS MaxReactedOn --���� ����� 1 ���������� �������� ���������/�� (���������� sender, Doc.Uid � recipient ���������� ������, ��� � ����� ������), �� ����� ������������ ���� ��������
					FROM RegistrationControl 
					INNER JOIN #tmp_ValidationLog  --������� ���� �������� ��������� �����
						ON #tmp_ValidationLog.LogId = RegistrationControl.ValidatingLog
					WHERE
						RequestCount = 1
						AND RegistrationControl.PackageDelivaredOn >=  DATEADD(DAY, -5, DATETIMEFROMPARTS(DATEPART(YEAR, @DateStart), DATEPART(MONTH, @DateStart), DATEPART(DAY, @DateStart), '0', '0', '0', '0')) --������ ������� ������. ���� ��������� ������ ������ ���� �� �����, ��� �� 5 ���� �� ��������� �������
						AND DATEADD(DAY, 5, RegistrationControl.PackageDelivaredOn) <= DATETIMEFROMPARTS(DATEPART(YEAR, @DateEnd), DATEPART(MONTH, @DateEnd), DATEPART(DAY, @DateEnd), '23', '59', '59', '0')	--����� ������� ������. ���� �������� ����������� ������ ���� �� ����� ���� ��������� ������� ������, ����� ���� ������������ ����������� �������� �� ��������� �������� ����
					GROUP BY
						DocumentUid
						,SenderGuid
						,RecipientGuid
						,MessageType
				) AS RequestMessage -- �������� ��������� � ��, ������� ������� �����������
				LEFT OUTER JOIN (
					SELECT --ResponseMessage - �����������, ������������ � ����� �� ���������/�� �� ������� ��������� � ������� uid ���������
						DocumentUid
						,SenderGuid
						,MessageType
						,RecipientGuid
						,MIN(PackageDelivaredOn) AS MinPackageDelivaredOn --���� ����� 1 ���������� �������� ����������� (sender, Doc.Uid � recipient ���������� ������, ��� � ����� ������), �� ����� ����������� ���� ��������
					FROM 
						RegistrationControl
					INNER JOIN #tmp_ValidationLog  --������� ���� �������� ��������� �����
						ON #tmp_ValidationLog.LogId = RegistrationControl.ValidatingLog
					WHERE 	
						ResponseCount = 1
					GROUP BY
						DocumentUid
						,SenderGuid
						,RecipientGuid
						,MessageType
				) AS ResponseMessage -- �������� �����������, ������� ���� ���������� ��� ����� �� ���������� ��������� � ��
				ON 
					RequestMessage.DocumentUid = ResponseMessage.DocumentUid 
					AND RequestMessage.SenderGuid = ResponseMessage.RecipientGuid 
					AND RequestMessage.RecipientGuid = ResponseMessage.SenderGuid
			) AS RegistrationMessage
		) AS CheckMessageComplete
		--WHERE
		--	(CASE
		--		WHEN DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, CheckMessageComplete.ControllerReactedOn)) = 0  --���� ���� ���������, �� ���������� �� �������������
		--		THEN DATEDIFF(MINUTE, GETDATE(), CheckMessageComplete.ControllerReactedOn)
		--		ELSE DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, CheckMessageComplete.ControllerReactedOn))  --����� ���������� �� ����
		--		END 
		--	> 0 
		--	AND CheckMessageComplete.DateDiff is not null) --���� ���� � ����� �������� ��������� ������ �������� ���������� �������, �� DateDiff �� null, ������ ����������� ������ � ���� �� �������� �������. ����� �� ���������, ��� ��������� ����� ������ ����� �������� �������, �� �� ���� ��������
		--	OR (CASE
		--		WHEN DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, CheckMessageComplete.ControllerReactedOn)) = 0  --���� ���� ���������, �� ���������� �� �������������
		--		THEN DATEDIFF(MINUTE, GETDATE(), CheckMessageComplete.ControllerReactedOn)
		--		ELSE DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, CheckMessageComplete.ControllerReactedOn))  --����� ���������� �� ����
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
	SELECT --MemberScoreP7 --������� ���-�� ��������� �����, ���-�� �������� ������� ���������� � �������� (�������)
		Member.Guid													AS MemberGuid 
		,SUM(ScoreForMessage.Score)/COUNT(ScoreForMessage.Member)	AS RatingP7
		,COUNT(ScoreForMessage.Member) as countMessP7
	FROM (	 
		SELECT --ScoreForMessage --���� �� �������� ����������� � ����
			CheckMessageComplete.MessageUid
			,CheckMessageComplete.Member
			,CheckMessageComplete.ControllerReactedOn
			,'Score' = CASE 
							WHEN CheckMessageComplete.DateDiff >= 0 THEN 200 
							WHEN ((CheckMessageComplete.DateDiff < 0) OR (CheckMessageComplete.DateDiff IS NULL)) THEN 0 
							END
		FROM (
			SELECT --CheckMessageComplete --��������, ��� ����������� ����������� � ���� (DateDiff < 0 - �� � ����, DateDiff > � ����)
				RegistrationMessage.MessageUid
				,RegistrationMessage.Member
				--,DATEDIFF(MILLISECOND, RegistrationMessage.MemberDelivaredOn, RegistrationMessage.ControllerReactedOn) AS DateDiff --��� ������������ �� ������������� ���� - �� ��������
				,'DateDiff' = IIF(DATEDIFF(DAY, CONVERT(DATE, RegistrationMessage.MemberDelivaredOn), CONVERT(DATE, RegistrationMessage.ControllerReactedOn)) = 0 --���� ���� ���������, �� ���������� �� �������������
									,DATEDIFF(MINUTE, RegistrationMessage.MemberDelivaredOn, RegistrationMessage.ControllerReactedOn)
									,DATEDIFF(DAY, CONVERT(DATE, RegistrationMessage.MemberDelivaredOn), CONVERT(DATE, RegistrationMessage.ControllerReactedOn)))  --����� ���������� �� ����
																				
				,RegistrationMessage.ControllerReactedOn
			FROM (
				SELECT --RegistrationMessage - ���� �������� ������ �� ��������� � ���� �������� ������ �� ����������� �� ������� DocumentUid
					RequestMessage.MessageUid					AS MessageUid
					,RequestMessage.SenderGuid					AS Controller
					,RequestMessage.RecipientGuid				AS Member
					,RequestMessage.MaxReactedOn				AS ControllerReactedOn
					,ResponseMessage.MinPackageDelivaredOn		AS MemberDelivaredOn
				FROM (
					SELECT  --RequestMessage - ������������������ ���������/��, ��������� ����������� � ������ ����� �� ������� ��������� �� ������� uid  ���������
						ConfirmationControl.MessageUid
						,ConfirmationControl.SenderGuid
						,ConfirmationControl.MessageType
						,ConfirmationControl.RecipientGuid
						,MAX(DATEADD(DAY, 3, ConfirmationControl.PackageDelivaredOn)) AS MaxReactedOn --���� ����� 1 ���������� �������� ���������/�� (���������� sender, Doc.Uid � recipient ���������� ������, ��� � ����� ������), �� ����� ������������ ���� ��������
					FROM ConfirmationControl 
					INNER JOIN #tmp_ValidationLog  --������� ���� �������� ��������� �����
						ON #tmp_ValidationLog.LogId = ConfirmationControl.ValidatingLog
					WHERE
						RequestCount = 1
						AND ConfirmationControl.PackageDelivaredOn >=  DATEADD(DAY, -3, DATETIMEFROMPARTS(DATEPART(YEAR, @DateStart), DATEPART(MONTH, @DateStart), DATEPART(DAY, @DateStart), '0', '0', '0', '0')) --������ ������� ������. ���� ��������� ������ ������ ���� �� �����, ��� �� 3 ��� �� ��������� �������
						AND DATEADD(DAY, 3, ConfirmationControl.PackageDelivaredOn) <= DATETIMEFROMPARTS(DATEPART(YEAR, @DateEnd), DATEPART(MONTH, @DateEnd), DATEPART(DAY, @DateEnd), '23', '59', '59', '0')	--����� ������� ������. ���� �������� ����������� ������ ���� �� ����� ���� ��������� ������� ������, ����� ���� ������������ ����������� �������� �� ��������� �������� ����
					GROUP BY
						MessageUid
						,SenderGuid
						,RecipientGuid
						,MessageType
				) AS RequestMessage -- �������� ��������� � ��, ������� ������� �����������
				LEFT OUTER JOIN (
					SELECT --ResponseMessage - �����������, ������������ � ����� �� ���������/�� �� ������� ��������� � ������� uid ���������
						MessageUid
						,SenderGuid
						,MessageType
						,RecipientGuid
						,MIN(PackageDelivaredOn) AS MinPackageDelivaredOn --���� ����� 1 ���������� �������� ����������� (sender, Doc.Uid � recipient ���������� ������, ��� � ����� ������), �� ����� ����������� ���� ��������
					FROM 
						ConfirmationControl
					INNER JOIN #tmp_ValidationLog  --������� ���� �������� ��������� �����
						ON #tmp_ValidationLog.LogId = ConfirmationControl.ValidatingLog
					WHERE 	
						ResponseCount = 1
					GROUP BY
						MessageUid
						,SenderGuid
						,RecipientGuid
						,MessageType
				) AS ResponseMessage -- �������� �����������, ������� ���� ���������� ��� ����� �� ���������� ��������� � ��
				ON 
					RequestMessage.MessageUid = ResponseMessage.MessageUid 
					AND RequestMessage.SenderGuid = ResponseMessage.RecipientGuid 
					AND RequestMessage.RecipientGuid = ResponseMessage.SenderGuid
			) AS RegistrationMessage
		) AS CheckMessageComplete
		--WHERE
		--	(CASE
		--		WHEN DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, CheckMessageComplete.ControllerReactedOn)) = 0  --���� ���� ���������, �� ���������� �� �������������
		--		THEN DATEDIFF(MINUTE, GETDATE(), CheckMessageComplete.ControllerReactedOn)
		--		ELSE DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, CheckMessageComplete.ControllerReactedOn))  --����� ���������� �� ����
		--		END 
		--	> 0 
		--	AND CheckMessageComplete.DateDiff is not null) --���� ���� � ����� �������� ��������� ������ �������� ���������� �������, �� DateDiff �� null, ������ ����������� ������ � ���� �� �������� �������. ����� �� ���������, ��� ��������� ����� ������ ����� �������� �������, �� �� ���� ��������
		--	OR (CASE
		--		WHEN DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, CheckMessageComplete.ControllerReactedOn)) = 0  --���� ���� ���������, �� ���������� �� �������������
		--		THEN DATEDIFF(MINUTE, GETDATE(), CheckMessageComplete.ControllerReactedOn)
		--		ELSE DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, CheckMessageComplete.ControllerReactedOn))  --����� ���������� �� ����
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
