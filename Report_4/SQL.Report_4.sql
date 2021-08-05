---------------------------���������-------------------------------
--DECLARE @DateStart DateTime2
--DECLARE @DateEnd DateTime2
--DECLARE @DateStartCompare DateTime2
--DECLARE @DateEndCompare DateTime2
--SET @DateStart = '2021-04-01'
--SET @DateEnd = '2021-04-30'
--SET @DateStartCompare = '2021-03-01'
--SET @DateEndCompare = '2021-03-31'
-------------------------------------------------------------------

IF OBJECT_ID('tempdb..#tmp_Packages') is not null
	DROP TABLE #tmp_Packages
IF OBJECT_ID('tempdb..#ScoreReceipt') is not null
	DROP TABLE #ScoreReceipt
IF OBJECT_ID('tempdb..#ScoreNotifications') is not null
	DROP TABLE #ScoreNotifications

CREATE TABLE #tmp_Packages (
							LogId BIGINT PRIMARY KEY
							,PackageId INT
							,ReceivedOn DATETIME2(7) NULL
						)
CREATE TABLE #ScoreReceipt (
							MemberR CHAR(36)
							--,PackageDelivaredOnR DATETIME2(7)
							--,TotalMessageR INT
							,Sum_RequieredR INT
							,Sum_ResponsedR INT
							,PeriodR INT
						)
CREATE TABLE #ScoreNotifications (
							MemberN CHAR(36)
							--,PackageDelivaredOnN DATETIME2(7)
							--,TotalMessageN INT
							,Sum_RequieredN INT
							,Sum_ResponsedN INT
							,PeriodN INT
						)


INSERT INTO #tmp_Packages  
	SELECT -- ActualLogs = ���������� ������ � ��������� �����
		ReportPacks.LogId
		,ReportPacks.Id			AS PackageId
		,ReportPacks.ReceivedOn
	FROM (
		SELECT -- ActualDates = ���������� ���� ����� �������. ���� ���� �� ������ ��������, �� ����� ��������� ������������ ���
			Package AS Max_Package
			,MAX(ValidatedOn)	AS Max_ValidatedOn
		FROM	
			ValidationLog
		WHERE 
			Success = 1 --????
		GROUP BY
			Package
	) AS ActualDates
	INNER JOIN (
		SELECT -- ReportPacks = ��� ������������ (processed = 1) ������
			ValidationLog.Id	AS LogId
			,Package.Id
			,Package.ValidatedOn
			,Package.ReceivedOn
		FROM
			Package
		INNER JOIN ValidationLog
			ON ValidationLog.Package = Package.Id
		WHERE
			--Package.Incoming = 1 --������ ��������� ������ 
			Package.Processed = 1 --������ ������������ ������
	) AS ReportPacks
		ON ActualDates.Max_Package = ReportPacks.Id
		AND ActualDates.Max_ValidatedOn = ReportPacks.ValidatedOn


INSERT INTO #ScoreReceipt
	SELECT		--���-�� ��������� ��������� �� � ������������ ��������� � ������ ������ � � ������ ���������
		MemberResponseMessagerR		AS MemberR
		--,TotalMessageR
		,SUM(RequieredR)			AS Sum_RequieredR --���-�� ��������� ��������� ��
		,SUM(ResponsedR)			AS Sum_ResponsedR --���-�� ������������ ���������
		,Period						AS PeriodR
	FROM (
		SELECT -- ScoreReceipt --������ ���������� ���������� �������� ����. �� (��������� ��� �������� ��������� � �� ������������ �����������)
			 RequestMessage.PackageId			AS PackageIdR
			,RequestMessage.RecipientGuid		AS MemberResponseMessagerR
			,RequestMessage.MessageType			AS MessageTypeR
			,RequestMessage.PackageDelivaredOn  AS PackageDelivaredOnR
			,RequestMessage.Period
			,'TotalMessageR' = 1
			,'RequieredR' = CASE WHEN 
									RequestMessage.PackageDelivaredOn is not null 
									AND RequestMessage.MessageType <> N'���������'
								THEN 1
								ELSE 0
								END
			,'ResponsedR' = CASE WHEN 
									ResponseMessage.ResponseDelivaredOn is not null
									AND RequestMessage.MessageType <> N'���������'
								THEN 1
								ELSE 0
								END
		FROM (
			SELECT --RequestMessage - ���������/��, ��������� ��������� � ������� ������ (Period = 0) � ��������� (Period = 1)
				MAX(#tmp_Packages.PackageId)	AS PackageId
				,AllRequestMessage.MessageUid
				,AllRequestMessage.SenderGuid
				,AllRequestMessage.MessageType
				,AllRequestMessage.RecipientGuid
				,AllRequestMessage.PackageDelivaredOn
				,AllRequestMessage.Period
			FROM (
				SELECT  --AllRequestMessage - ��� ���������/��, ��������� ��������� (��� ������ �������� ���������)
					MessageUid
					,ValidatingLog
					,SenderGuid
					,MessageType
					,RecipientGuid
					,PackageDelivaredOn
					,CASE	WHEN (
								PackageDelivaredOn >=  DATEADD(DAY, -5, DATETIMEFROMPARTS(DATEPART(YEAR, @DateStart), DATEPART(MONTH, @DateStart), DATEPART(DAY, @DateStart), '0', '0', '0', '0')) --������ ������� ������. ���� ��������� ������ ������ ���� �� �����, ��� �� 3 ��� �� ��������� �������
								AND DATEADD(DAY, 5, PackageDelivaredOn) <= DATETIMEFROMPARTS(DATEPART(YEAR, @DateEnd), DATEPART(MONTH, @DateEnd), DATEPART(DAY, @DateEnd), '23', '59', '59', '0')	--����� ������� ������. ���� �������� ����������� ������ ���� �� ����� ���� ��������� ������� ������, ����� ���� ������������ ����������� �������� �� ��������� �������� ����
								)
								THEN 1 --������ ������
							WHEN (
								PackageDelivaredOn >=  DATETIMEFROMPARTS(DATEPART(YEAR, @DateStartCompare), DATEPART(MONTH, @DateStartCompare), DATEPART(DAY, @DateStartCompare), '0', '0', '0', '0') --������ ������� ���������
								AND PackageDelivaredOn < DATETIMEFROMPARTS(DATEPART(YEAR, @DateEndCompare), DATEPART(MONTH, @DateEndCompare), DATEPART(DAY, @DateEndCompare), '23', '59', '59', '0') --����� ������� ���������
								) 
								THEN 2 --������ ���������
							ELSE 0 --������, �� �������� � ������� ������ ��� ���������
							END AS Period
					,MAX(PackageDelivaredOn) OVER (PARTITION BY  MessageUid
													,SenderGuid
													,RecipientGuid
													,MessageType
												) AS MinPackageDelivaredOn --���� ����� 1 ���������� �������� ���������/�� (���������� sender, Doc.Uid � recipient ���������� ������, ��� � ����� ������), �� ����� ������������ ����
				FROM 
					ConfirmationControl --WHERE Request = 1 ����������, ��� �� ������� ��� �������� �������� ������
			) AS AllRequestMessage
			INNER JOIN #tmp_Packages
				ON #tmp_Packages.LogId = AllRequestMessage.ValidatingLog
			WHERE
				AllRequestMessage.PackageDelivaredOn is not null
				AND AllRequestMessage.Period IN (1,2)
				AND AllRequestMessage.MinPackageDelivaredOn = AllRequestMessage.PackageDelivaredOn
			GROUP BY 
				AllRequestMessage.MessageUid
				,AllRequestMessage.SenderGuid
				,AllRequestMessage.MessageType
				,AllRequestMessage.RecipientGuid
				,AllRequestMessage.PackageDelivaredOn
				,AllRequestMessage.Period
		) AS RequestMessage

		LEFT OUTER JOIN (
			SELECT		--ResponseMessage - ��� ���������, ������������ � ����� �� ���������/��, � �������� �������
				MAX(#tmp_Packages.PackageId)	AS PackageId --MAX �����, ������ ��� ����� ����� ��� ����������� �������� sender, repicient, messUid � ���� ResponseDelivaredOn
				,AllResponseMessage.MessageUid
				,AllResponseMessage.SenderGuid
				,AllResponseMessage.RecipientGuid
				,AllResponseMessage.ResponseDelivaredOn
			FROM (
				SELECT --AllResponseMessage - ��� ���������, ������������ � ����� �� ���������/��
					MessageUid
					,ValidatingLog
					,SenderGuid
					,RecipientGuid
					,MessageType
					,PackageDelivaredOn		AS ResponseDelivaredOn
					,MIN(PackageDelivaredOn) OVER (PARTITION BY  MessageUid
																,SenderGuid
																,RecipientGuid
																,MessageType
													) AS MinResponseDelivaredOn --���� ����� 1 ���������� �������� ��������� (sender, Mess.Uid � recipient ���������� ������, ��� � ����� ������), �� ����� ����������� ���� ��������
				FROM 
					ConfirmationControl
				WHERE
					ResponseCount = 1
			) AS AllResponseMessage
			INNER JOIN #tmp_Packages
				ON #tmp_Packages.LogId = AllResponseMessage.ValidatingLog
			WHERE
				AllResponseMessage.MinResponseDelivaredOn = AllResponseMessage.ResponseDelivaredOn
			GROUP BY				
				AllResponseMessage.MessageUid
				,AllResponseMessage.SenderGuid
				,AllResponseMessage.RecipientGuid
				,AllResponseMessage.ResponseDelivaredOn
		) AS ResponseMessage
			ON RequestMessage.MessageUid = ResponseMessage.MessageUid 
			AND RequestMessage.SenderGuid = ResponseMessage.RecipientGuid 
			AND RequestMessage.RecipientGuid = ResponseMessage.SenderGuid

		--WHERE 
		--	(CASE
		--		WHEN DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn))) = 0  --���� ���� ���������, �� ���������� �� �������������
		--		THEN DATEDIFF(MILLISECOND, GETDATE(), DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn))
		--		ELSE DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn)))  --����� ���������� �� ����
		--		END 
		--	> 0 
		--	AND CASE
		--			WHEN DATEDIFF(DAY, CONVERT(DATE, ResponseDelivaredOn), CONVERT(DATE, DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn))) = 0 --���� ���� ���������, �� ���������� �� �������������
		--			THEN DATEDIFF(MILLISECOND, ResponseDelivaredOn, DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn))
		--			ELSE DATEDIFF(DAY, CONVERT(DATE, ResponseDelivaredOn), CONVERT(DATE, DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn)))  --����� ���������� �� ����
		--			END
		--		is not null) --���� ���� � ����� �������� ��������� ������ �������� ���������� �������, �� DateDiff �� null, ������ ����������� ������ � ���� �� �������� �������. ����� �� ���������, ��� ��������� ����� ������ ����� �������� �������, �� �� ���� ��������
	    --
		--	OR (CASE
		--		WHEN DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn))) = 0  --���� ���� ���������, �� ���������� �� �������������
		--		THEN DATEDIFF(MILLISECOND, GETDATE(), DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn))
		--		ELSE DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn)))  --����� ���������� �� ����
		--		END
		--	<= 0 )
	) AS ScoreReceipt
GROUP BY
	MemberResponseMessagerR
	,Period


INSERT INTO #ScoreNotifications
	SELECT		--���-�� ��������� ����������� �� � ������������ ����������� � ������ ������ � � ������ ���������
		MemberResponseMessagerN		AS MemberN
		--,SUM([TotalMessageN])
		,SUM(RequieredN)			AS Sum_RequieredN --���-�� ��������� ����������� ��
		,SUM(ResponsedN)			AS Sum_ResponsedN --���-�� ������������ �����������
		,Period						AS PeriodN
	FROM (
		SELECT -- ScoreNotifications  = ������ ���������� ���������� �������� ����. �� (��������� ��� �������� ����������� � ��� ������������ �����������)
			RequestMessage.PackageId			AS PackageIdN
			,RequestMessage.RecipientGuid		AS MemberResponseMessagerN
			,RequestMessage.MessageType			AS MessageTypeN
			,RequestMessage.PackageDelivaredOn	AS PackageDelivaredOnN
			,Period
			,'TotalMessageN' = CASE WHEN 
										RequestMessage.MessageType = N'���������'
									THEN 0
									ELSE 1
									END
			,'RequieredN' = CASE WHEN 
									RequestMessage.PackageDelivaredOn is not null 
									AND RequestMessage.MessageType <> N'�����������'
								THEN 1
								ELSE 0
								END
			,'ResponsedN' = CASE WHEN 
									ResponseMessage.ResponseDelivaredOn is not null
									AND RequestMessage.MessageType <> N'�����������'
								THEN 1
								ELSE 0
								END
		FROM (
			SELECT --RequestMessage - ���������/��, ��������� ����������� � ������� ������ (Period = 0) � ��������� (Period = 1)
				MAX(#tmp_Packages.PackageId)	AS PackageId
				,AllRequestMessage.DocumentUid 
				,AllRequestMessage.SenderGuid
				,AllRequestMessage.MessageType
				,AllRequestMessage.RecipientGuid
				,AllRequestMessage.PackageDelivaredOn
				,AllRequestMessage.Period
			FROM (
				SELECT  --AllRequestMessage - ��� ���������/��, ��������� ����������� (��� ������ �������� ����������)
					DocumentUid
					,ValidatingLog
					,SenderGuid
					,RecipientGuid
					,MessageType
					,PackageDelivaredOn
					,CASE	WHEN (
								PackageDelivaredOn >=  DATEADD(DAY, -5, DATETIMEFROMPARTS(DATEPART(YEAR, @DateStart), DATEPART(MONTH, @DateStart), DATEPART(DAY, @DateStart), '0', '0', '0', '0')) --������ ������� ������. ���� ��������� ������ ������ ���� �� �����, ��� �� 3 ��� �� ��������� �������
								AND DATEADD(DAY, 5, PackageDelivaredOn) <= DATETIMEFROMPARTS(DATEPART(YEAR, @DateEnd), DATEPART(MONTH, @DateEnd), DATEPART(DAY, @DateEnd), '23', '59', '59', '0')	--����� ������� ������. ���� �������� ����������� ������ ���� �� ����� ���� ��������� ������� ������, ����� ���� ������������ ����������� �������� �� ��������� �������� ����
								)
								THEN 1 --������ ������
							WHEN (
								PackageDelivaredOn >=  DATETIMEFROMPARTS(DATEPART(YEAR, @DateStartCompare), DATEPART(MONTH, @DateStartCompare), DATEPART(DAY, @DateStartCompare), '0', '0', '0', '0') --������ ������� ���������
								AND PackageDelivaredOn < DATETIMEFROMPARTS(DATEPART(YEAR, @DateEndCompare), DATEPART(MONTH, @DateEndCompare), DATEPART(DAY, @DateEndCompare), '23', '59', '59', '0') --����� ������� ���������
								) 
								THEN 2 --������ ���������
							ELSE 0 --������, �� �������� � ������� ������ ��� ���������
							END AS Period
					,MAX(PackageDelivaredOn) OVER (PARTITION BY  DocumentUid
																,SenderGuid
																,RecipientGuid
																,MessageType
													) AS MinPackageDelivaredOn --���� ����� 1 ���������� �������� ���������/�� (���������� sender, Doc.Uid � recipient ���������� ������, ��� � ����� ������), �� ����� ������������ ����
				FROM  
					RegistrationControl --WHERE Request = 1 ����������, ��� �� ������� ��� �������� �������� ������
			) AS AllRequestMessage
			INNER JOIN #tmp_Packages
				ON #tmp_Packages.LogId = AllRequestMessage.ValidatingLog
			WHERE
				AllRequestMessage.PackageDelivaredOn is not null
				AND AllRequestMessage.Period IN (1,2)
				AND AllRequestMessage.MinPackageDelivaredOn = AllRequestMessage.PackageDelivaredOn
			GROUP BY
				AllRequestMessage.DocumentUid 
				,AllRequestMessage.SenderGuid
				,AllRequestMessage.MessageType
				,AllRequestMessage.RecipientGuid
				,AllRequestMessage.PackageDelivaredOn
				,AllRequestMessage.Period
		) AS RequestMessage
		LEFT OUTER JOIN (
			SELECT		--ResponseMessage - ��� �����������, ������������ � ����� �� ���������/��, � �������� �������
				MAX(#tmp_Packages.PackageId)	AS PackageId
				,AllResponseMessage.DocumentUid
				,AllResponseMessage.SenderGuid
				,AllResponseMessage.RecipientGuid
				,AllResponseMessage.ResponseDelivaredOn
			FROM (
				SELECT --AllResponseMessage - ��� �����������, ������������ � ����� �� ���������/��
					DocumentUid
					,ValidatingLog
					,SenderGuid
					,RecipientGuid
					,MessageType
					,PackageDelivaredOn AS ResponseDelivaredOn
					,MIN(PackageDelivaredOn) OVER (PARTITION BY  DocumentUid
																,SenderGuid
																,RecipientGuid
																,MessageType
													) AS MinResponseDelivaredOn --���� ����� 1 ���������� �������� ����������� (sender, Mess.Uid � recipient ���������� ������, ��� � ����� ������), �� ����� ����������� ���� ��������				
				FROM 
					RegistrationControl
				WHERE
					ResponseCount = 1
			) AS AllResponseMessage
			INNER JOIN #tmp_Packages
				ON #tmp_Packages.LogId = AllResponseMessage.ValidatingLog
			WHERE
				AllResponseMessage.ResponseDelivaredOn = AllResponseMessage.MinResponseDelivaredOn
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
				WHEN DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, DATEADD(DAY, 5, RequestMessage.PackageDelivaredOn))) = 0  --���� ���� ���������, �� ���������� �� �������������
				THEN DATEDIFF(MILLISECOND, GETDATE(), DATEADD(DAY, 5, RequestMessage.PackageDelivaredOn))
				ELSE DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, DATEADD(DAY, 5, RequestMessage.PackageDelivaredOn)))  --����� ���������� �� ����
				END 
			> 0 
			AND CASE
						WHEN DATEDIFF(DAY, CONVERT(DATE, ResponseDelivaredOn), CONVERT(DATE, DATEADD(DAY, 5, RequestMessage.PackageDelivaredOn))) = 0 --���� ���� ���������, �� ���������� �� �������������
						THEN DATEDIFF(MILLISECOND, ResponseDelivaredOn, DATEADD(DAY, 5, RequestMessage.PackageDelivaredOn))
						ELSE DATEDIFF(DAY, CONVERT(DATE, ResponseDelivaredOn), CONVERT(DATE, DATEADD(DAY, 5, RequestMessage.PackageDelivaredOn)))  --����� ���������� �� ����
						END
					is not null) --���� ���� � ����� �������� ��������� ������ �������� ���������� �������, �� DateDiff �� null, ������ ����������� ������ � ���� �� �������� �������. ����� �� ���������, ��� ��������� ����� ������ ����� �������� �������, �� �� ���� ��������
	
	
			OR (CASE
				WHEN DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, DATEADD(DAY, 5, RequestMessage.PackageDelivaredOn))) = 0  --���� ���� ���������, �� ���������� �� �������������
				THEN DATEDIFF(MILLISECOND, GETDATE(), DATEADD(DAY, 5, RequestMessage.PackageDelivaredOn))
				ELSE DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, DATEADD(DAY, 5, RequestMessage.PackageDelivaredOn)))  --����� ���������� �� ����
				END
			<= 0 )
	) AS FinalScoreNotifications	
GROUP BY
	MemberResponseMessagerN
	,Period


SELECT
	DENSE_RANK() OVER (PARTITION BY 
								MemberType
								,IIF((Score_Period_1+Score_Period_2 = 0) OR (Score_Period_1 is null AND Score_Period_2 is null), 1, 0)
						ORDER BY 
								ROUND(100*(ISNULL(Score_Period_1, 0) - ISNULL(Score_Period_2, 0))/(1 + ABS(ISNULL(Score_Period_1, 0)) + ABS(ISNULL(Score_Period_2, 0))), 2) DESC
						)	AS Rank
	,ROUND(100*(ISNULL(Score_Period_1, 0) - ISNULL(Score_Period_2, 0))/(1 + ABS(ISNULL(Score_Period_1, 0)) + ABS(ISNULL(Score_Period_2, 0))), 2) AS ChangeDynamics
	,*

FROM (
	SELECT
		Member.Name
		,Member.Type															AS MemberType
		,ROUND(0.5*(Prop_Receipt_Period_1 + Prop_Notifications_Period_1), 2)	AS Score_Period_1
		,ROUND(Prop_Receipt_Period_1, 2)										AS Prop_Receipt_Period_1
		,ROUND(Prop_Notifications_Period_1, 2)									AS Prop_Notifications_Period_1
		,ROUND(0.5*(Prop_Receipt_Period_2 + Prop_Notifications_Period_2), 2)	AS Score_Period_2
		,ROUND(Prop_Receipt_Period_2, 2)										AS Prop_Receipt_Period_2
		,ROUND(Prop_Notifications_Period_2, 2)									AS Prop_Notifications_Period_2
	FROM(
		SELECT
			Member
			,MAX([1])	AS Prop_Receipt_Period_1
			,MAX([3])	AS Prop_Notifications_Period_1
			,MAX([2])	AS Prop_Receipt_Period_2
			,MAX([4])	AS Prop_Notifications_Period_2
		FROM (
			SELECT --���� ������������ ��������� � ����������� � ������� ������ � ���������
				#ScoreReceipt.MemberR									AS Member
				--,SUM(ISNULL(#ScoreReceipt.[TotalMessageR], 0))		AS TotalMessageR
				,IIF(#ScoreReceipt.Sum_ResponsedR <> 0	
									,100*CAST(ISNULL(#ScoreReceipt.Sum_ResponsedR, 0) AS FLOAT)/#ScoreReceipt.Sum_RequieredR
										,0)								AS Prop_Receipt			--���� ������������ ���������
				--,SUM(ISNULL(#ScoreNotifications.[TotalMessageN], 0))	AS TotalMessageN
				,IIF(#ScoreNotifications.Sum_ResponsedN <> 0	
									,100*CAST(ISNULL(#ScoreNotifications.Sum_ResponsedN, 0) AS FLOAT)/#ScoreNotifications.Sum_RequieredN
									,0)									AS Prop_Notifications	--���� ������������ �����������
				,PeriodR												AS PeriodR -- 1-������ ������; 2-������ ���������
				,PeriodN + 2											AS PeriodN -- 3-������ ������; 4-������ ���������
			FROM #ScoreNotifications
			FULL OUTER JOIN #ScoreReceipt
				ON #ScoreReceipt.MemberR = #ScoreNotifications.MemberN
				AND #ScoreReceipt.PeriodR = #ScoreNotifications.PeriodN
		) AS Prop_Notifications_and_Receipt
		PIVOT(
			MAX(Prop_Receipt)
			FOR PeriodR
			IN ([1], [2])
		) AS Receipt_Pivot
		PIVOT(
			MAX(Prop_Notifications)
			FOR PeriodN
			IN ([3], [4])
		) AS Notifications_Pivot
		GROUP BY
			Member
	) AS Pivot_Stats
	RIGHT JOIN Member
		ON Member.Guid = Pivot_Stats.Member COLLATE SQL_Latin1_General_CP1_CI_AS
	WHERE
		Active = 1
) AS Score_Stats