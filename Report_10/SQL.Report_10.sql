---------------------------���������-------------------------------
--DECLARE @DateStart DateTime2
--DECLARE @DateEnd DateTime2
--SET @DateStart = '2021-04-01'
--SET @DateEnd = '2021-06-01'
-------------------------------------------------------------------

IF object_id('tempdb..#tmp') is not null
	DROP TABLE #tmp
IF object_id('tempdb..#tmp2') is not null
	DROP TABLE #tmp2

CREATE TABLE #tmp ( --������ ��������� � ������
	Rank INT
	,SenderGuid char(36)
	,SenderName nvarchar(255)
	,RecipientGuid char(36)
	,RecipientName nvarchar(255)
	,CountNewVersionED INT
	,CountActiveCommunications INT
	,ALLCountNewVersionED INT
)

INSERT INTO #tmp  
	SELECT 	--������ ��������� � ������
		DENSE_RANK() OVER (ORDER BY CountActiveCommunications DESC, ALLCountNewVersionED DESC, Member.Name ASC) AS Rank
		,SenderGuid
		,SenderName
		,RecipientGuid
		,RecipientName
		,CountNewVersionED
		,CountActiveCommunications
		,ALLCountNewVersionED
	FROM (
		SELECT	--ComunicationsScore = ������ ���������
			CommunicationsControl.SenderGuid
			,CommunicationsControl.SenderName
			,CommunicationsControl.RecipientGuid
			,CommunicationsControl.RecipientName
			,ISNULL(CommunicationsControl.CountNewVersionED, -1) AS CountNewVersionED --��� ��������� ���, ��� -1
			,SUM(CommunicationsControl.CountNewVersionED) OVER (PARTITION BY CommunicationsControl.SenderGuid) AS ALLCountNewVersionED --����� ���� �� � ������� 2.7.1 �� ��������� 
			,SUM(IIF(CommunicationsControl.CountNewVersionED > 2, 1, 0)) OVER (PARTITION BY CommunicationsControl.SenderGuid) AS CountActiveCommunications --���� � ��������� ���� ����� 2 �� 2.7.1, �� +1 � �������� ���������
		FROM ( --CommunicationsControl = ������������ Sender � Recipient � ���-�� ������ 2.7.1 ��
			SELECT
				AllCommunications.SenderGuid
				,AllCommunications.SenderName
				,AllCommunications.RecipientGuid
				,AllCommunications.RecipientName
				,NewVersionControl.CountNewVersionED
			FROM ( --AllCommunications = ��� ��������� �������� ������������ Sender � Recipient
				SELECT 
					Member1.Guid	AS SenderGuid
					,Member1.Name	AS SenderName
					,Member2.Guid	AS RecipientGuid 
					,Member2.Name	AS RecipientName
				FROM 
					Member AS Member1
				CROSS JOIN (
					SELECT 
						Member.Name
						,Member.Guid
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
					SELECT  -- VersionControl ��� ������������ MemberY � MemberX � ������ ������ �� �� � ��������� ������ ��
						ConfirmationControl.SenderGuid AS MemberY		--�����������
						,ConfirmationControl.RecipientGuid AS MemberX	--����������
						,IIF(ConfirmationControl.MessageType = N'������������ ���������', ValidationLog.ContainerXmlVersion, ValidationLog.PackageXmlVersion) AS VersionED
					FROM	
						ConfirmationControl	
					INNER JOIN ValidationLog
						ON ValidationLog.Id = ConfirmationControl.ValidatingLog
					WHERE 	
						ConfirmationControl.PackageDelivaredOn >=  DATETIMEFROMPARTS(DATEPART(YEAR, @DateStart), DATEPART(MONTH, @DateStart), DATEPART(DAY, @DateStart), '0', '0', '0', '0') --������ ������� ������
						AND ConfirmationControl.PackageDelivaredOn < DATETIMEFROMPARTS(DATEPART(YEAR, @DateEnd), DATEPART(MONTH, @DateEnd), DATEPART(DAY, @DateEnd), '23', '59', '59', '0') --����� ������� ������
						AND(ConfirmationControl.MessageType = N'������������ ���������' OR ConfirmationControl.MessageType = N'��������')
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
		ON Member.Guid = ComunicationsScore.SenderGuid

CREATE TABLE #tmp2 ( --����� ����������� ������� ��� ��, ��� � ������
	Rank INT
	,SenderGuid nvarchar(255)
) 

INSERT INTO #tmp2  
	SELECT 
		DISTINCT
		#tmp.Rank
		,#tmp.SenderGuid
	FROM #tmp


SELECT 
	A.Rank AS RankA
	,A.SenderGuid
	,A.SenderName
	,B.Rank AS RankB
	,A.RecipientGuid
	,A.RecipientName
	,A.CountNewVersionED
	,A.CountActiveCommunications
	,A.ALLCountNewVersionED	
FROM #tmp AS A
INNER JOIN #tmp2 AS B
	ON A.RecipientGuid = B.SenderGuid
