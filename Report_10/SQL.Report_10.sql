---------------------------���������-------------------------------
--DECLARE @DateStart DateTime2
--DECLARE @DateEnd DateTime2
--SET @DateStart = '2021-03-01'
--SET @DateEnd = '2021-04-01'
-------------------------------------------------------------------

IF OBJECT_ID('tempdb..#tmp') is not null
	DROP TABLE #tmp
IF OBJECT_ID('tempdb..#tmp_Packages') is not null
	DROP TABLE #tmp_Packages

CREATE TABLE #tmp_Packages (
							LogId BIGINT
							,ContainerXmlVersion char(8)
						)

INSERT INTO #tmp_Packages  
	SELECT -- ActualLogs = ���������� ������ � ��������� �����
		ReportPacks.LogId
		,ReportPacks.ContainerXmlVersion
	FROM (
		SELECT -- ActualDates = ���������� ���� ����� �������. ���� ���� �� ������ ��������, �� ����� ��������� ������������ ���
			Package AS Max_Package
			,MAX(ValidatedOn)	AS Max_ValidatedOn
		FROM	
			ValidationLog
		WHERE 
			Success = 1
		GROUP BY
			Package
	) AS ActualDates
	INNER JOIN (
		SELECT -- ReportPacks = ��� ������������ (processed = 1) ������
			ValidationLog.Id	AS LogId
			,ValidationLog.ContainerXmlVersion
			,ValidationLog.Package
			,ValidationLog.ValidatedOn
		FROM
			Package
		INNER JOIN ValidationLog
			ON ValidationLog.Package = Package.Id
		WHERE
			Package.Incoming = 1 --������ ��������� ������ 
			AND Package.Processed = 1 --������ ������������ ������
			AND Success = 1
	) AS ReportPacks
		ON ActualDates.Max_Package = ReportPacks.Package
		AND ActualDates.Max_ValidatedOn = ReportPacks.ValidatedOn


CREATE TABLE #tmp ( --������ ��������� � ������
	Rank INT
	,SenderGuid char(36)
	,RecipientGuid char(36)
	,CountNewVersionED INT
	,ALLCountNewVersionED INT
	,CountActiveCommunications INT
)

INSERT INTO #tmp  
	SELECT 	--������ ��������� � ������
		DENSE_RANK() OVER (ORDER BY CountActiveCommunications DESC, ALLCountNewVersionED DESC, Member.Name ASC) AS Rank
		,SenderGuid
		,RecipientGuid
		,CountNewVersionED
		,ALLCountNewVersionED
		,CountActiveCommunications
	FROM (
		SELECT	--ComunicationsScore = ������ ���������
			SenderGuid
			,RecipientGuid
			,ISNULL(CountNewVersionED, -1)											AS CountNewVersionED --��� ��������� ���, ��� -1
			,SUM(CountNewVersionED)	OVER (PARTITION BY SenderGuid)					AS ALLCountNewVersionED --����� ���� �� � ������� 2.7.1 �� ��������� 
			,SUM(IIF(CountNewVersionED > 2, 1, 0)) OVER (PARTITION BY SenderGuid)	AS CountActiveCommunications --���� � ��������� ���� ����� 2 �� 2.7.1, �� +1 � �������� ���������
		FROM ( --CommunicationsControl = ������������ Sender � Recipient � ���-�� ������ 2.7.1 ��
			SELECT
				AllCommunications.SenderGuid
				,AllCommunications.RecipientGuid
				,NewVersionControl.CountNewVersionED
			FROM ( --AllCommunications = ��� ��������� �������� ������������ Sender � Recipient
				SELECT 
					Member1.Guid	AS SenderGuid
					,Member2.Guid	AS RecipientGuid 
				FROM 
					Member AS Member1
				CROSS JOIN (
					SELECT 
						Member.Guid
					FROM 
						Member
					WHERE
						Member.Active = 1
				) AS Member2
				WHERE 
					Member1.Active = 1
			) AS AllCommunications
			LEFT JOIN (
				SELECT -- NewVersionControl = ������������ MemberY � MemberX � ������ ������ �� �� � ��������� ���-�� ������ 2.7.1 ��
					VersionControl.MemberY
					,VersionControl.MemberX
					,SUM(IIF(VersionControl.VersionED = '2.7.1', 1, 0)) AS CountNewVersionED
				FROM (
					SELECT  -- VersionControl = ��� ������������ MemberY � MemberX � ������ ������ �� �� � ��������� ������ ��
						SenderGuid		AS MemberY		--�����������
						,RecipientGuid	AS MemberX	--����������
						,#tmp_Packages.ContainerXmlVersion	AS VersionED
					FROM	
						RegistrationControl
					INNER JOIN #tmp_Packages
						ON #tmp_Packages.LogId = ValidatingLog
					WHERE 	
						RequestCount = 1
						AND PackageDelivaredOn >=  DATETIMEFROMPARTS(DATEPART(YEAR, @DateStart), DATEPART(MONTH, @DateStart), DATEPART(DAY, @DateStart), '0', '0', '0', '0') --������ ������� ������
						AND PackageDelivaredOn < DATEADD(DAY, 1, DATETIMEFROMPARTS(DATEPART(YEAR, @DateEnd), DATEPART(MONTH, @DateEnd), DATEPART(DAY, @DateEnd), '0', '0', '0', '0')) --����� ������� ������
				) AS VersionControl
				GROUP BY
					VersionControl.MemberY
					,VersionControl.MemberX
			) AS NewVersionControl
				ON AllCommunications.SenderGuid = NewVersionControl.MemberY
				AND AllCommunications.RecipientGuid = NewVersionControl.MemberX
		) AS CommunicationsControl	
	) AS ComunicationsScore
	INNER JOIN Member
		ON Member.Guid = ComunicationsScore.SenderGuid;

WITH #tmp2 AS ( 
	SELECT 
		DISTINCT
		#tmp.Rank
		,#tmp.SenderGuid
	FROM #tmp
)

SELECT 
	A.Rank AS RankA
	,A.SenderGuid
	,B.Rank AS RankB
	,A.RecipientGuid
	,A.CountNewVersionED
	,A.CountActiveCommunications
	,A.ALLCountNewVersionED	
FROM #tmp AS A
INNER JOIN #tmp2 AS B
	ON A.RecipientGuid = B.SenderGuid
