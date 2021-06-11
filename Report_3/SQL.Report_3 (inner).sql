--DROP TABLE #tmp_Packages
--DROP TABLE #ScoreReceipt
--DROP TABLE #ScoreNotifications
CREATE TABLE #tmp_Packages (LogId BIGINT PRIMARY KEY, PackageId INT, ReceivedOn DATETIME2(7) NULL)
CREATE TABLE #ScoreReceipt (PackageIdR INT, MemberResponseMessagerR NVARCHAR(255), MessageTypeR NVARCHAR(255), PackageDelivaredOnR DATETIME2(7), TotalMessageR INT, RequieredR INT, ResponsedR INT)
CREATE TABLE #ScoreNotifications (PackageIdN INT, MemberResponseMessagerN NVARCHAR(255), MessageTypeN NVARCHAR(255), PackageDelivaredOnN DATETIME2(7), TotalMessageN INT, RequieredN INT, ResponsedN INT)


INSERT INTO #tmp_Packages  
	SELECT -- ActualLogs = ���������� ������ � ������� ������
		ReportPacks.LogId
		,ReportPacks.Id as PackageId
		,ReportPacks.ReceivedOn
	FROM (
		SELECT -- ActualDates = ���������� ���� ����� �������. ���� ���� �� ������ ��������, �� ����� ��������� ������������ ���
			Package AS Max_Package
			,MAX(ValidatedOn) AS Max_ValidatedOn
		FROM	
			ValidationLog
		WHERE 
			Success = 1
		GROUP BY
			Package
	) AS ActualDates
	INNER JOIN (
		SELECT -- ReportPacks = ��� ������������ (processed = 1) ������ � ������� ������ 
			ValidationLog.Id AS LogId
			,Package.Id
			,Package.ValidatedOn
			,Package.ReceivedOn
		FROM
			Package
		INNER JOIN ValidationLog
			ON ValidationLog.Package = Package.Id
		INNER JOIN Batch
			ON Batch.Id = Package.Batch
		INNER JOIN Member
			ON Member.Guid = Batch.MemberGuid
		WHERE
			--Package.ReceivedOn >=  @DataStart --������ ������� ������
			--AND Package.ReceivedOn < @DataEnd --����� ������� ������
			--Package.Incoming = 1 --������ ��������� ������ 
			Package.Processed = 1 --������ ������������ ������
			AND Member.Name = @Member
	) AS ReportPacks
		ON ActualDates.Max_Package = ReportPacks.Id
		AND ActualDates.Max_ValidatedOn = ReportPacks.ValidatedOn

INSERT INTO #ScoreReceipt
	SELECT		
		PackageIdR
		,Member.Name
		,MessageTypeR
		,PackageDelivaredOnR
		,[TotalMessageR]
		,[RequieredR]
		,[ResponsedR]
	FROM (
		SELECT -- ScoreReceipt
			 RequestMessage.PackageId			AS PackageIdR
			 --,Member.Name						AS MemberResponseMessagerR
			,RequestMessage.RecipientGuid		AS MemberResponseMessagerR
			,RequestMessage.MessageType			AS MessageTypeR
			,RequestMessage.PackageDelivaredOn  AS PackageDelivaredOnR
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
			SELECT --RequestMessage - ���������/��, ��������� ��������� � ������ �����
				MAX(#tmp_Packages.PackageId) AS PackageId
				,AllRequestMessage.MessageUid
				,AllRequestMessage.SenderGuid
				,AllRequestMessage.MessageType
				,AllRequestMessage.RecipientGuid
				,AllRequestMessage.PackageDelivaredOn
			FROM (
				SELECT  --AllRequestMessage - ��� ���������/��, ��������� ��������� (��� ������ �������� ���������)
					MessageUid
					,SenderGuid
					,MessageType
					,RecipientGuid
					,MAX(PackageDelivaredOn) AS PackageDelivaredOn --���� ����� 1 ���������� �������� ���������/�� (���������� sender, Doc.Uid � recipient ���������� ������, ��� � ����� ������), �� ����� ������������ ����
				FROM 
					ConfirmationControl --WHERE Request = 1 ����������, ��� �� ������� ��� �������� �������� ������
				GROUP BY
					MessageUid
					,SenderGuid
					,RecipientGuid
					,MessageType
			) AS AllRequestMessage
			INNER JOIN ConfirmationControl
				ON ConfirmationControl.PackageDelivaredOn = AllRequestMessage.PackageDelivaredOn
				AND ConfirmationControl.MessageUid = AllRequestMessage.MessageUid
				AND ConfirmationControl.SenderGuid = AllRequestMessage.SenderGuid
				AND ConfirmationControl.RecipientGuid = AllRequestMessage.RecipientGuid
				AND ConfirmationControl.MessageType = AllRequestMessage.MessageType
			INNER JOIN #tmp_Packages
				ON #tmp_Packages.LogId = ConfirmationControl.ValidatingLog
			WHERE
				--#tmp_Packages.ReceivedOn >=  '2021-03-10' --������ ������� ������
				--AND #tmp_Packages.ReceivedOn < '2021-03-11' --����� ������� ������
				--ConfirmationControl.PackageDelivaredOn >=  DATETIMEFROMPARTS(DATEPART(YEAR, @DataStart), DATEPART(MONTH, @DataStart), DATEPART(DAY, @DataStart), '0', '0', '0', '0') --������ ������� ������
				--AND ConfirmationControl.PackageDelivaredOn < DATETIMEFROMPARTS(DATEPART(YEAR, @DataEnd), DATEPART(MONTH, @DataEnd), DATEPART(DAY, @DataEnd), '23', '59', '59', '0') --����� ������� ������	
				#tmp_Packages.ReceivedOn >=  DATETIMEFROMPARTS(DATEPART(YEAR, @DataStart), DATEPART(MONTH, @DataStart), DATEPART(DAY, @DataStart), '0', '0', '0', '0') --������ ������� ������
				AND #tmp_Packages.ReceivedOn < DATETIMEFROMPARTS(DATEPART(YEAR, @DataEnd), DATEPART(MONTH, @DataEnd), DATEPART(DAY, @DataEnd), '23', '59', '59', '0') --����� ������� ������	
				AND AllRequestMessage.PackageDelivaredOn is not null
			GROUP BY 
				AllRequestMessage.MessageUid
				,AllRequestMessage.SenderGuid
				,AllRequestMessage.MessageType
				,AllRequestMessage.RecipientGuid
				,AllRequestMessage.PackageDelivaredOn
		) AS RequestMessage
		LEFT OUTER JOIN (
			SELECT		--ResponseMessage - ��� ���������, ������������ � ����� �� ���������/��, � �������� �������
				MAX(#tmp_Packages.PackageId) AS PackageId --MAX �����, ������ ��� ����� ����� ��� ����������� �������� sender, repicient, messUid � ���� ResponseDelivaredOn
				,AllResponseMessage.MessageUid
				,AllResponseMessage.SenderGuid
				,AllResponseMessage.RecipientGuid
				,AllResponseMessage.ResponseDelivaredOn
			FROM (
				SELECT --AllResponseMessage - ��� ���������, ������������ � ����� �� ���������/��
					MessageUid
					,SenderGuid
					,RecipientGuid
					,MessageType
					,MIN(PackageDelivaredOn) AS ResponseDelivaredOn --���� ����� 1 ���������� �������� ��������� (sender, Mess.Uid � recipient ���������� ������, ��� � ����� ������), �� ����� ����������� ���� ��������
				FROM 
					ConfirmationControl
				WHERE
					ResponseCount = 1
					--AND SenderGuid = '853dResponseMessage228-05e8-4ResponseMessage45-92ee-19deResponseMessageef3039f'
				GROUP BY
					MessageUid
					,SenderGuid
					,RecipientGuid
					,MessageType
			) AS AllResponseMessage

			INNER JOIN ConfirmationControl
				ON ConfirmationControl.PackageDelivaredOn = AllResponseMessage.ResponseDelivaredOn
				AND ConfirmationControl.MessageUid = AllResponseMessage.MessageUid
				AND ConfirmationControl.SenderGuid = AllResponseMessage.SenderGuid
				AND ConfirmationControl.RecipientGuid = AllResponseMessage.RecipientGuid
				AND ConfirmationControl.MessageType = AllResponseMessage.MessageType
			INNER JOIN #tmp_Packages
				ON #tmp_Packages.LogId = ConfirmationControl.ValidatingLog
			GROUP BY				
				AllResponseMessage.MessageUid
				,AllResponseMessage.SenderGuid
				,AllResponseMessage.RecipientGuid
				,AllResponseMessage.ResponseDelivaredOn
		) AS ResponseMessage
			ON RequestMessage.MessageUid = ResponseMessage.MessageUid 
			AND RequestMessage.SenderGuid = ResponseMessage.RecipientGuid 
			AND RequestMessage.RecipientGuid = ResponseMessage.SenderGuid
		WHERE 
			(CASE
				WHEN DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn))) = 0  --���� ���� ���������, �� ���������� �� �������������
				THEN DATEDIFF(MILLISECOND, GETDATE(), DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn))
				ELSE DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn)))  --����� ���������� �� ����
				END 
			> 0 
			AND CASE
						WHEN DATEDIFF(DAY, CONVERT(DATE, ResponseDelivaredOn), CONVERT(DATE, DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn))) = 0 --���� ���� ���������, �� ���������� �� �������������
						THEN DATEDIFF(MILLISECOND, ResponseDelivaredOn, DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn))
						ELSE DATEDIFF(DAY, CONVERT(DATE, ResponseDelivaredOn), CONVERT(DATE, DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn)))  --����� ���������� �� ����
						END
					is not null) --���� ���� � ����� �������� ��������� ������ �������� ���������� �������, �� DataDiff �� null, ������ ����������� ������ � ���� �� �������� �������. ����� �� ���������, ��� ��������� ����� ������ ����� �������� �������, �� �� ���� ��������
	
			OR (CASE
				WHEN DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn))) = 0  --���� ���� ���������, �� ���������� �� �������������
				THEN DATEDIFF(MILLISECOND, GETDATE(), DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn))
				ELSE DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn)))  --����� ���������� �� ����
				END
			<= 0 )
	) AS FinalScoreReceipt
	RIGHT JOIN Member
		ON Member.Guid = FinalScoreReceipt.MemberResponseMessagerR
	WHERE
		Member.Name = @Member



INSERT INTO #ScoreNotifications
	SELECT		
		PackageIdN
		,Member.Name
		,MessageTypeN
		,PackageDelivaredOnN
		,[TotalMessageN]
		,[RequieredN]
		,[ResponsedN]
	FROM (
		SELECT -- ScoreNotifications
			RequestMessage.PackageId			AS PackageIdN
			--,Member.Name						AS MemberResponseMessagerN
			,RequestMessage.RecipientGuid		AS MemberResponseMessagerN
			,RequestMessage.MessageType			AS MessageTypeN
			,RequestMessage.PackageDelivaredOn	AS PackageDelivaredOnN
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
			SELECT --RequestMessage - ���������/��, ��������� ����������� � ������ �����
				MAX(#tmp_Packages.PackageId) AS PackageId
				,AllRequestMessage.DocumentUid 
				,AllRequestMessage.SenderGuid
				,AllRequestMessage.MessageType
				,AllRequestMessage.RecipientGuid
				,AllRequestMessage.PackageDelivaredOn
			FROM (
				SELECT  --AllRequestMessage - ��� ���������/��, ��������� ����������� (��� ������ �������� ����������)
					DocumentUid
					,SenderGuid
					,MessageType
					,RecipientGuid
					,MAX(PackageDelivaredOn) AS PackageDelivaredOn --���� ����� 1 ���������� �������� ���������/�� (���������� sender, Doc.Uid � recipient ���������� ������, ��� � ����� ������), �� ����� ������������ ����
				FROM 
					RegistrationControl --WHERE Request = 1 ����������, ��� �� ������� ��� �������� �������� ������
				GROUP BY
					DocumentUid
					,SenderGuid
					,RecipientGuid
					,MessageType
			) AS AllRequestMessage
			INNER JOIN RegistrationControl
				ON RegistrationControl.PackageDelivaredOn = AllRequestMessage.PackageDelivaredOn
				AND RegistrationControl.DocumentUid = AllRequestMessage.DocumentUid
				AND RegistrationControl.SenderGuid = AllRequestMessage.SenderGuid
				AND RegistrationControl.RecipientGuid = AllRequestMessage.RecipientGuid
				AND RegistrationControl.MessageType = AllRequestMessage.MessageType
			INNER JOIN #tmp_Packages
				ON #tmp_Packages.LogId = RegistrationControl.ValidatingLog
			WHERE
				--#tmp_Packages.ReceivedOn >=  '2021-03-10' --������ ������� ������
				--AND #tmp_Packages.ReceivedOn < '2021-03-11' --����� ������� ������
				--ConfirmationControl.PackageDelivaredOn >=  DATETIMEFROMPARTS(DATEPART(YEAR, @DataStart), DATEPART(MONTH, @DataStart), DATEPART(DAY, @DataStart), '0', '0', '0', '0') --������ ������� ������
				--AND ConfirmationControl.PackageDelivaredOn < DATETIMEFROMPARTS(DATEPART(YEAR, @DataEnd), DATEPART(MONTH, @DataEnd), DATEPART(DAY, @DataEnd), '23', '59', '59', '0') --����� ������� ������	
				#tmp_Packages.ReceivedOn >=  DATETIMEFROMPARTS(DATEPART(YEAR, @DataStart), DATEPART(MONTH, @DataStart), DATEPART(DAY, @DataStart), '0', '0', '0', '0') --������ ������� ������
				AND #tmp_Packages.ReceivedOn < DATETIMEFROMPARTS(DATEPART(YEAR, @DataEnd), DATEPART(MONTH, @DataEnd), DATEPART(DAY, @DataEnd), '23', '59', '59', '0') --����� ������� ������									
				AND AllRequestMessage.PackageDelivaredOn is not null
			GROUP BY
				AllRequestMessage.DocumentUid 
				,AllRequestMessage.SenderGuid
				,AllRequestMessage.MessageType
				,AllRequestMessage.RecipientGuid
				,AllRequestMessage.PackageDelivaredOn
		) AS RequestMessage
		LEFT OUTER JOIN (
			SELECT		--ResponseMessage - ��� �����������, ������������ � ����� �� ���������/��, � �������� �������
				MAX(#tmp_Packages.PackageId) AS PackageId
				,AllResponseMessage.DocumentUid
				,AllResponseMessage.SenderGuid
				,AllResponseMessage.RecipientGuid
				,AllResponseMessage.ResponseDelivaredOn
			FROM (
				SELECT --AllResponseMessage - ��� �����������, ������������ � ����� �� ���������/��
					DocumentUid
					,SenderGuid
					,MessageType
					,RecipientGuid
					,MIN(PackageDelivaredOn) AS ResponseDelivaredOn --���� ����� 1 ���������� �������� ��������� (sender, Mess.Uid � recipient ���������� ������, ��� � ����� ������), �� ����� ����������� ���� ��������
				FROM 
					RegistrationControl
				WHERE
					ResponseCount = 1
					--AND SenderGuid = '853dResponseMessage228-05e8-4ResponseMessage45-92ee-19deResponseMessageef3039f'
				GROUP BY
					DocumentUid
					,SenderGuid
					,RecipientGuid
					,MessageType
			) AS AllResponseMessage

			INNER JOIN RegistrationControl
				ON RegistrationControl.PackageDelivaredOn = AllResponseMessage.ResponseDelivaredOn
				AND RegistrationControl.DocumentUid = AllResponseMessage.DocumentUid
				AND RegistrationControl.SenderGuid = AllResponseMessage.SenderGuid
				AND RegistrationControl.RecipientGuid = AllResponseMessage.RecipientGuid
				AND RegistrationControl.MessageType = AllResponseMessage.MessageType
			INNER JOIN #tmp_Packages
				ON #tmp_Packages.LogId = RegistrationControl.ValidatingLog
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
					is not null) --���� ���� � ����� �������� ��������� ������ �������� ���������� �������, �� DataDiff �� null, ������ ����������� ������ � ���� �� �������� �������. ����� �� ���������, ��� ��������� ����� ������ ����� �������� �������, �� �� ���� ��������
	
	
			OR (CASE
				WHEN DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, DATEADD(DAY, 5, RequestMessage.PackageDelivaredOn))) = 0  --���� ���� ���������, �� ���������� �� �������������
				THEN DATEDIFF(MILLISECOND, GETDATE(), DATEADD(DAY, 5, RequestMessage.PackageDelivaredOn))
				ELSE DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, DATEADD(DAY, 5, RequestMessage.PackageDelivaredOn)))  --����� ���������� �� ����
				END
			<= 0 )
	) AS FinalScoreNotifications
	RIGHT JOIN Member
		ON Member.Guid = FinalScoreNotifications.MemberResponseMessagerN
	WHERE
		Member.Name = @Member

SELECT
	#ScoreReceipt.PackageIdR
	,#ScoreReceipt.MemberResponseMessagerR
	,#ScoreReceipt.MessageTypeR
	,#ScoreReceipt.PackageDelivaredOnR
	,#ScoreReceipt.[TotalMessageR]					AS TotalMessageR
	,ISNULL(#ScoreReceipt.[RequieredR], 0)			AS RequieredR
	,ISNULL(#ScoreReceipt.[ResponsedR], 0)			AS ResponsedR
	,ISNULL(#ScoreNotifications.[TotalMessageN], 0)	AS TotalMessageN
	,ISNULL(#ScoreNotifications.[RequieredN], 0)	AS RequieredN
	,ISNULL(#ScoreNotifications.[ResponsedN], 0)	AS ResponsedN
FROM #ScoreNotifications
FULL OUTER JOIN #ScoreReceipt
	ON #ScoreReceipt.PackageIdR = #ScoreNotifications.PackageIdN
WHERE 
	#ScoreReceipt.PackageIdR IS NOT NULL 
	OR (MemberResponseMessagerR IS NOT NULL AND #ScoreReceipt.PackageIdR IS NULL)
	
--ORDER BY MemberResponseMessagerR
