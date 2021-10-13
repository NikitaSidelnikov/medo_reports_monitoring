---------------------------���������-------------------------------
--DECLARE @DateStart DateTime2
--DECLARE @DateEnd DateTime2
--DECLARE @Member nvarchar(255)
--SET @DateStart = '2021-04-01'
--SET @DateEnd = '2021-06-01'
--SET @Member = '1D04CA3E-DF1A-0CB4-C325-6EF4003CA2AB' --�������� ������
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
							PackageIdR INT
							,MemberResponseMessagerR CHAR(36)
							,MessageTypeR NVARCHAR(255)
							,PackageDelivaredOnR DATETIME2(7)
							,TotalMessageR INT
							,RequieredR INT
							,ResponsedR INT
						)
CREATE TABLE #ScoreNotifications (
							PackageIdN INT
							,MemberResponseMessagerN CHAR(36)
							,MessageTypeN NVARCHAR(255)
							,PackageDelivaredOnN DATETIME2(7)
							,TotalMessageN INT
							,RequieredN INT
							,ResponsedN INT
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
			Package.Processed = 1 --������ ������������ ������
			AND Success = 1 --????
	) AS ReportPacks
		ON ActualDates.Max_Package = ReportPacks.Id
		AND ActualDates.Max_ValidatedOn = ReportPacks.ValidatedOn


INSERT INTO #ScoreReceipt
	SELECT -- ScoreReceipt --������ ���������� ���������� �������� ����. �� (��������� ��� �������� ��������� � �� ������������ �����������)
		RequestMessage.PackageId			AS PackageIdR
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
			MAX(#tmp_Packages.PackageId)	AS PackageId
			,AllRequestMessage.MessageUid
			,AllRequestMessage.SenderGuid
			,AllRequestMessage.MessageType
			,AllRequestMessage.RecipientGuid
			,AllRequestMessage.PackageDelivaredOn
		FROM (
			SELECT  --AllRequestMessage - ��� ���������/��, ��������� ��������� (��� ������ �������� ���������)
				MessageUid
				,ValidatingLog
				,SenderGuid
				,MessageType
				,RecipientGuid
				,PackageDelivaredOn
				,MAX(PackageDelivaredOn) OVER (PARTITION BY  MessageUid
												,SenderGuid
												,RecipientGuid
												,MessageType
											) AS MinPackageDelivaredOn --���� ����� 1 ���������� �������� ���������/�� (���������� sender, Doc.Uid � recipient ���������� ������, ��� � ����� ������), �� ����� ������������ ����
			FROM 
				ConfirmationControl --WHERE Request = 1 ����������, ��� �� ������� ��� �������� �������� ������
			WHERE
				RecipientGuid = @Member
		) AS AllRequestMessage
		INNER JOIN #tmp_Packages
			ON #tmp_Packages.LogId = AllRequestMessage.ValidatingLog
		WHERE
			AllRequestMessage.PackageDelivaredOn is not null
			AND AllRequestMessage.PackageDelivaredOn >=  DATEADD(DAY, -3, DATETIMEFROMPARTS(DATEPART(YEAR, @DateStart), DATEPART(MONTH, @DateStart), DATEPART(DAY, @DateStart), '0', '0', '0', '0')) --������ ������� ������. ���� ��������� ������ ������ ���� �� �����, ��� �� 3 ��� �� ��������� �������
			AND AllRequestMessage.PackageDelivaredOn < DATEADD(DAY, -2, DATETIMEFROMPARTS(DATEPART(YEAR, @DateEnd), DATEPART(MONTH, @DateEnd), DATEPART(DAY, @DateEnd), '0', '0', '0', '0'))	--����� ������� ������. ���� �������� ����������� ������ ���� �� ����� ���� ��������� ������� ������, ����� ���� ������������ ����������� �������� �� ��������� �������� ����
			AND AllRequestMessage.MinPackageDelivaredOn = AllRequestMessage.PackageDelivaredOn
		GROUP BY 
			AllRequestMessage.MessageUid
			,AllRequestMessage.SenderGuid
			,AllRequestMessage.MessageType
			,AllRequestMessage.RecipientGuid
			,AllRequestMessage.PackageDelivaredOn
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
				AND SenderGuid = @Member
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
	--				WHEN DATEDIFF(DAY, CONVERT(DATE, ResponseDelivaredOn), CONVERT(DATE, DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn))) = 0 --���� ���� ���������, �� ���������� �� �������������
	--				THEN DATEDIFF(MILLISECOND, ResponseDelivaredOn, DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn))
	--				ELSE DATEDIFF(DAY, CONVERT(DATE, ResponseDelivaredOn), CONVERT(DATE, DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn)))  --����� ���������� �� ����
	--				END
	--			is not null) --���� ���� � ����� �������� ��������� ������ �������� ���������� �������, �� DateDiff �� null, ������ ����������� ������ � ���� �� �������� �������. ����� �� ���������, ��� ��������� ����� ������ ����� �������� �������, �� �� ���� ��������
	
	--	OR (CASE
	--		WHEN DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn))) = 0  --���� ���� ���������, �� ���������� �� �������������
	--		THEN DATEDIFF(MILLISECOND, GETDATE(), DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn))
	--		ELSE DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, DATEADD(DAY, 3, RequestMessage.PackageDelivaredOn)))  --����� ���������� �� ����
	--		END
	--	<= 0 )


INSERT INTO #ScoreNotifications
	SELECT -- ScoreNotifications  = ������ ���������� ���������� �������� ����. �� (��������� ��� �������� ����������� � ��� ������������ �����������)
		RequestMessage.PackageId			AS PackageIdN
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
			MAX(#tmp_Packages.PackageId)		AS PackageId
			,AllRequestMessage.DocumentUid 
			,AllRequestMessage.SenderGuid
			,AllRequestMessage.MessageType
			,AllRequestMessage.RecipientGuid
			,AllRequestMessage.PackageDelivaredOn
		FROM (
			SELECT  --AllRequestMessage - ��� ���������/��, ��������� ����������� (��� ������ �������� ����������)
				DocumentUid
				,ValidatingLog
				,SenderGuid
				,RecipientGuid
				,MessageType
				,PackageDelivaredOn
				,MAX(PackageDelivaredOn) OVER (PARTITION BY  DocumentUid
															,SenderGuid
															,RecipientGuid
															,MessageType
												) AS MinPackageDelivaredOn --���� ����� 1 ���������� �������� ���������/�� (���������� sender, Doc.Uid � recipient ���������� ������, ��� � ����� ������), �� ����� ������������ ����
			FROM  
				RegistrationControl
			WHERE
				RecipientGuid = @Member
				AND RequestCount = 1
		) AS AllRequestMessage
		INNER JOIN #tmp_Packages
			ON #tmp_Packages.LogId = AllRequestMessage.ValidatingLog
		WHERE
			AllRequestMessage.PackageDelivaredOn is not null
			AND AllRequestMessage.PackageDelivaredOn >=  DATEADD(DAY, -5, DATETIMEFROMPARTS(DATEPART(YEAR, @DateStart), DATEPART(MONTH, @DateStart), DATEPART(DAY, @DateStart), '0', '0', '0', '0')) --������ ������� ������. ���� ��������� ������ ������ ���� �� �����, ��� �� 3 ��� �� ��������� �������
			AND AllRequestMessage.PackageDelivaredOn < DATEADD(DAY, -4, DATETIMEFROMPARTS(DATEPART(YEAR, @DateEnd), DATEPART(MONTH, @DateEnd), DATEPART(DAY, @DateEnd), '0', '0', '0', '0'))	--����� ������� ������. ���� �������� ����������� ������ ���� �� ����� ���� ��������� ������� ������, ����� ���� ������������ ����������� �������� �� ��������� �������� ����
			AND AllRequestMessage.PackageDelivaredOn = AllRequestMessage.MinPackageDelivaredOn
		GROUP BY
			AllRequestMessage.DocumentUid 
			,AllRequestMessage.SenderGuid
			,AllRequestMessage.MessageType
			,AllRequestMessage.RecipientGuid
			,AllRequestMessage.PackageDelivaredOn
	) AS RequestMessage
	LEFT OUTER JOIN (
		SELECT		--ResponseMessage - ��� �����������, ������������ � ����� �� ���������/��, � �������� �������
			MAX(#tmp_Packages.PackageId)		 AS PackageId
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
				,PackageDelivaredOn			AS ResponseDelivaredOn
				,MIN(PackageDelivaredOn) OVER (PARTITION BY  DocumentUid
															,SenderGuid
															,RecipientGuid
															,MessageType
												) AS MinResponseDelivaredOn --���� ����� 1 ���������� �������� ����������� (sender, Mess.Uid � recipient ���������� ������, ��� � ����� ������), �� ����� ����������� ���� ��������				
			FROM 
				RegistrationControl
			WHERE
				ResponseCount = 1
				AND SenderGuid = @Member
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
	

SELECT --���������� ������ ���������� �������� ����������� � ��������� �������
	#ScoreReceipt.MemberResponseMessagerR
	,#ScoreReceipt.PackageIdR
	,#ScoreReceipt.MessageTypeR
	,#ScoreReceipt.PackageDelivaredOnR
	,ISNULL(#ScoreReceipt.[TotalMessageR], 0)		AS TotalMessageR
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
