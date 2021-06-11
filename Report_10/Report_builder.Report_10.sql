--DECLARE @DataStart DateTime2
--DECLARE @DataEnd DateTime2
--SET @DataStart = '2021-03-01'
--SET @DataEnd = '2021-04-01'

if object_id('tempdb..#tmp') is not null
	DROP TABLE #tmp
if object_id('tempdb..#tmp2') is not null
	DROP TABLE #tmp2

CREATE TABLE #tmp (
	Rank INT
	,SenderGuid nvarchar(255)
	,RecipientGuid nvarchar(255)
	,CountNewVersionED INT
	,CountActiveCommunications INT
	,ALLCountNewVersionED INT
)

INSERT INTO #tmp  
	SELECT 	--������ ��������� � ������
		DENSE_RANK() OVER (ORDER BY CountActiveCommunications DESC, ALLCountNewVersionED DESC, Member.Name ASC) AS Rank
		,SenderGuid
		,RecipientGuid
		,CountNewVersionED
		,CountActiveCommunications
		,ALLCountNewVersionED
	FROM (
		SELECT	--������ ���������
			CommunicationsControl.SenderGuid
			,CommunicationsControl.RecipientGuid
			,IsNull(CommunicationsControl.CountNewVersionED, -1) AS CountNewVersionED --��� ��������� ���, ��� -1
			,SUM(CommunicationsControl.CountNewVersionED) OVER (PARTITION BY CommunicationsControl.SenderGuid) AS ALLCountNewVersionED --����� ���� �� � ������� 2.7.1 �� ��������� 
			,SUM(IIF(CommunicationsControl.CountNewVersionED > 2, 1, 0)) OVER (PARTITION BY CommunicationsControl.SenderGuid) AS CountActiveCommunications --���� � ��������� ���� ����� 2 �� 2.7.1, �� +1 � �������� ���������
		FROM ( --CommunicationsControl = ������������ Sender � Recipient � ���-�� ������ 2.7.1 ��
			SELECT
				AllCommunications.SenderGuid
				,AllCommunications.RecipientGuid
				,NewVersionControl.CountNewVersionED
			FROM ( --AllCommunications = ��� ��������� �������� ������������ Sender � Recipient
				SELECT 
					Member1.Name	AS Sender
					,Member1.Guid	AS SenderGuid
					,Member2.Name	AS Recipient 
					,Member2.Guid	AS RecipientGuid 
				FROM 
					Member AS Member1
				CROSS JOIN (
					SELECT 
						Member.Name
						,Member.Guid
						,Member.Active
					FROM 
						Member
				) AS Member2
				WHERE 
					Member1.Active = 1
					AND Member2.Active = 1
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
						ConfirmationControl.PackageDelivaredOn >=  DATETIMEFROMPARTS(DATEPART(YEAR, @DataStart), DATEPART(MONTH, @DataStart), DATEPART(DAY, @DataStart), '0', '0', '0', '0') --������ ������� ������
						AND ConfirmationControl.PackageDelivaredOn < DATETIMEFROMPARTS(DATEPART(YEAR, @DataEnd), DATEPART(MONTH, @DataEnd), DATEPART(DAY, @DataEnd), '23', '59', '59', '0') --����� ������� ������
						AND(ConfirmationControl.MessageType = N'������������ ���������' OR ConfirmationControl.MessageType = N'��������')
				) AS VersionControl
				GROUP BY
					VersionControl.MemberY
					,VersionControl.MemberX
			) AS NewVersionControl
				ON AllCommunications.SenderGuid = NewVersionControl.MemberY
				AND AllCommunications.RecipientGuid = NewVersionControl.MemberX
				) AS CommunicationsControl	
	) AS A
	INNER JOIN Member
		ON Member.Guid = A.SenderGuid

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
	Report10.RankA
	,MemberSender.Name AS Sender
	,Report10.SenderGuid
	,Report10.RankB 
	,MemberRecipient.Name AS Recipient
	,Report10.RecipientGuid
	,Report10.CountNewVersionED
	,Report10.CountActiveCommunications
	,Report10.ALLCountNewVersionED	
FROM (
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
) AS Report10
INNER JOIN Member AS MemberSender
	ON MemberSender.Guid = Report10.SenderGuid COLLATE SQL_Latin1_General_CP1_CI_AS
INNER JOIN Member AS MemberRecipient
	ON MemberRecipient.Guid = Report10.RecipientGuid COLLATE SQL_Latin1_General_CP1_CI_AS

