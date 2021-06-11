--DECLARE @DataStart DateTime2
--DECLARE @DataEnd DateTime2
--SET @DataStart = '2021-03-01'
--SET @DataEnd = '2021-04-01'

IF OBJECT_ID('tempdb..#Tmp') is not null
	DROP TABLE #Tmp

CREATE TABLE #Tmp (
					PackageId INT
					,LogId INT 
					,MemberGuid nvarchar(255)
					,PackageXml nvarchar(255)
					,PackageXmlVersion nvarchar(255)
					,ContainerXml nvarchar(255)
					,ContainerXmlVersion nvarchar(255)
					,Type INT
					,Success BIT)
INSERT INTO #Tmp
	/*
	Type = 
		1 -- ���������
		2 -- �����������
		3 -- ��������
		4 -- ��
	*/
	SELECT --ActualPackages = ���������� ������� ActualPackages  � ��������� ���� ������
		ActualPackages.PackageId
		,ActualPackages.LogId
		,Member.Guid AS MemberGuid
		,ActualPackages.PackageXml
		,IIF(ActualPackages.PackageXmlVersion is null AND ActualPackages.PackageId is not null, 'x', PackageXmlVersion) AS PackageXmlVersion
		,ActualPackages.ContainerXml
		,ActualPackages.ContainerXmlVersion
		,CASE 
			WHEN PackageType.Type = 3 AND ActualPackages.ContainerXml is null
				THEN 3				--��������
			WHEN PackageType.Type = 3 AND ActualPackages.ContainerXml is not null
				THEN 4				--��
			ELSE
				PackageType.Type
			END AS Type
		,ActualPackages.Success
	FROM (
		SELECT   --PackageType = ���������� ��� ������� (�� �������� ������ ������)
			ValidationLog
			,MAX(Type) AS Type
		FROM (
			SELECT --PackageType = ����������: ����� �������� ���� � ������ ������. ������ �� ���, ������� ����� � ����
				ValidationLog
				,MemberGuid
				,CASE 
					WHEN Criterion = '3.4'
						THEN 3				--��/��������
					WHEN Criterion = '4.1'
						THEN 2				--�����������
					WHEN Criterion = '5.1'	
						THEN 1				--���������
					END AS Type
			FROM Score
			WHERE
				Criterion = '3.4'
				OR Criterion = '4.1'
				OR Criterion = '5.1'
		) AS CheckPackageType
		GROUP BY
			CheckPackageType.ValidationLog
	) AS PackageType

	RIGHT JOIN (
		SELECT --ActualPackages = ������������ ��������� ������ � ������ ������ � ��������� �����
			ActualLog.PackageId
			,ActualLog.Max_ValidatedOn
			,ProcessedPackage.MemberGuid
			,ProcessedPackage.LogId
			,ProcessedPackage.PackageXml
			,ProcessedPackage.PackageXmlVersion
			,ProcessedPackage.ContainerXml
			,ProcessedPackage.ContainerXmlVersion
			,ProcessedPackage.Success
		FROM(
			SELECT -- ActualLog = ��������� ��� �� ������
				ValidationLog.Package	AS PackageId
				,MAX(ValidationLog.ValidatedOn)	AS Max_ValidatedOn
			FROM ValidationLog		
			GROUP BY
				ValidationLog.Package
		) AS ActualLog
		INNER JOIN (
			SELECT --ProcessedPackage = ������������ ��������� ������ � ������ ������
				ValidationLog.Package
				,ValidationLog.Id AS LogId
				,ValidationLog.ValidatedOn
				,ValidationLog.Success
				,Batch.MemberGuid
				,PackageXml
				,PackageXmlVersion
				,ContainerXml
				,ContainerXmlVersion
			FROM Package
			INNER JOIN ValidationLog
				ON ValidationLog.Package = Package.Id
			INNER JOIN Batch
				ON Batch.Id = Package.Batch
			WHERE
				Processed = 1
				AND Incoming = 0
				AND Package.ReceivedOn >=  DATETIMEFROMPARTS(DATEPART(YEAR, @DataStart), DATEPART(MONTH, @DataStart), DATEPART(DAY, @DataStart), '0', '0', '0', '0') --������ ������� ������
				AND Package.ReceivedOn < DATETIMEFROMPARTS(DATEPART(YEAR, @DataEnd), DATEPART(MONTH, @DataEnd), DATEPART(DAY, @DataEnd), '23', '59', '59', '0') --����� ������� ������
		) AS ProcessedPackage
			ON ProcessedPackage.Package = ActualLog.PackageId
			AND ProcessedPackage.ValidatedOn = ActualLog.Max_ValidatedOn
	) AS ActualPackages
		ON PackageType.ValidationLog = ActualPackages.LogId 
	RIGHT JOIN Member
		ON Member.Guid = ActualPackages.MemberGuid
	WHERE  
		Member.Active = 1

SELECT
	Member.Name			AS Member
	,'Score' = IIF(ED.[AllContainer] <> 0 AND ED.[2.7.1] <> 0, 100*(0 + CAST(ISNULL(ED.[2.7.1],0) AS FLOAT)/CAST(ED.[AllContainer] AS FLOAT)), 0)					
	,EM.[AllMessage]	AS AllMessage
	,EM.[2.7.1]			AS EM_2_7_1
	,EM.[2.7]			AS EM_2_7
	,EM.[2.6]			AS EM_2_6
	,EM.[2.5]			AS EM_2_5
	,EM.[2.2]			AS EM_2_2
	,EM.[2.0]			AS EM_2_0
	,EM.[x]				AS EM_X
	,ED.[AllContainer]
	,ED.[2.7.1]			AS ED_2_7_1
	,ED.[2.7]			AS ED_2_7
	,ED.[NoContainer]	AS ED_NoContainer
	,ED.[x]				AS ED_X
FROM (
	SELECT --EM = ������ �������� �� 2.7.1 � ������ ������ �� ��
			MemberEM
			,'AllMessage' = ISNULL(VersionMessage.[2.7.1], 0) + ISNULL(VersionMessage.[2.7], 0) + ISNULL(VersionMessage.[2.6], 0) + ISNULL(VersionMessage.[2.5], 0) + ISNULL(VersionMessage.[2.2], 0) + ISNULL(VersionMessage.[2.0], 0) + ISNULL(VersionMessage.[x], 0)
			,ISNULL(VersionMessage.[2.7.1], 0)	AS '2.7.1'
			,ISNULL(VersionMessage.[2.7], 0)	AS '2.7'
			,ISNULL(VersionMessage.[2.6], 0)	AS '2.6'
			,ISNULL(VersionMessage.[2.5], 0)	AS '2.5'
			,ISNULL(VersionMessage.[2.2], 0)	AS '2.2'
			,ISNULL(VersionMessage.[2.0], 0)	AS '2.0'
			,ISNULL(VersionMessage.[x], 0)		AS 'x'
	FROM (
		SELECT 
			#Tmp.MemberGuid AS MemberEM
			,PackageXmlVersion
			,COUNT(*) AS CountPackageXmlVersion
		FROM #Tmp
		GROUP BY 
			#Tmp.MemberGuid
			,PackageXmlVersion
	)x
	PIVOT (
	MAX(CountPackageXmlVersion)
		FOR PackageXmlVersion
		IN([2.7.1],[2.7],[2.6],[2.5],[2.2],[2.0], [x])
	) AS VersionMessage
) AS EM
LEFT JOIN (
	SELECT --EM = ������ �������� �� 2.7.1 � ������ ������ �� ��
			MemberED
			,'AllContainer' = ISNULL(VersionContainer.[2.7.1], 0) + ISNULL(VersionContainer.[2.7], 0) + ISNULL(VersionContainer.[NoContainer], 0) + ISNULL(VersionContainer.[x], 0)
			,ISNULL(VersionContainer.[2.7.1], 0) AS '2.7.1' 
			,ISNULL(VersionContainer.[2.7], 0) AS '2.7'
			,ISNULL(VersionContainer.[NoContainer], 0)  AS 'NoContainer'
			,ISNULL(VersionContainer.[x], 0)  AS 'x'
	FROM (
		SELECT
			MemberED
			,ContainerXmlVersion
			,COUNT(*) AS CountContainerXmlVersion
		FROM (
			SELECT 
				#Tmp.MemberGuid AS MemberED
				,CASE 
					WHEN #Tmp.Type = 3 				--��������
						THEN 'NoContainer'
					WHEN #Tmp.Type = 4 AND #Tmp.ContainerXmlVersion is null
						THEN 'x'				--��
					ELSE
						#Tmp.ContainerXmlVersion
					END 
				AS ContainerXmlVersion			
			FROM #Tmp
		) AS Containers
		GROUP BY 
			MemberED
			,ContainerXmlVersion
	)x
	PIVOT (
	MAX(CountContainerXmlVersion)
		FOR ContainerXmlVersion
		IN([2.7.1],[2.7],[NoContainer],[x])
	) AS VersionContainer
) AS ED
	ON ED.MemberED = EM.MemberEM
INNER JOIN Member
	ON Member.Guid = EM.MemberEM COLLATE SQL_Latin1_General_CP1_CI_AS