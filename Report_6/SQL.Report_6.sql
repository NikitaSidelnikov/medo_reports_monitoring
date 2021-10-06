---------------------------���������-------------------------------
--DECLARE @DateStart DateTime2
--DECLARE @DateEnd DateTime2
--SET @DateStart = '2021-03-01'
--SET @DateEnd = '2021-04-01'
-------------------------------------------------------------------

if object_id('tempdb..#Tmp') IS NOT NULL
	drop table #Tmp

CREATE TABLE #Tmp (LogId BIGINT NOT NULL)

INSERT INTO #Tmp
	SELECT --ActualPackages = ������������ ������ � ��������� ����� � ������ ������
		ProcessedPackage.LogId
	FROM(
		SELECT -- ActualLog = ��������� ��� �� ������
			ValidationLog.Package	AS PackageId
			,MAX(ValidationLog.ValidatedOn)	AS Max_ValidatedOn
		FROM ValidationLog	
		WHERE 
			Success = 1
		GROUP BY
			ValidationLog.Package
	) AS ActualLog
	INNER JOIN (
		SELECT --ProcessedPackage = ������������ ������ � ������ ������
			ValidationLog.Package
			,ValidationLog.Id			AS LogId
			,ValidationLog.ValidatedOn
		FROM Package
		INNER JOIN ValidationLog
			ON ValidationLog.Package = Package.Id
		WHERE
			Processed = 1
			AND Success = 1
			AND Incoming = 0 --������ ��������� ������
			AND Package.ReceivedOn >=  DATETIMEFROMPARTS(DATEPART(YEAR, @DateStart), DATEPART(MONTH, @DateStart), DATEPART(DAY, @DateStart), '0', '0', '0', '0') --������ ������� ������
			AND Package.ReceivedOn < DATETIMEFROMPARTS(DATEPART(YEAR, @DateEnd), DATEPART(MONTH, @DateEnd), DATEPART(DAY, @DateEnd), '23', '59', '59', '0') --��������� ������� ������
	) AS ProcessedPackage
		ON ProcessedPackage.Package = ActualLog.PackageId
		AND ProcessedPackage.ValidatedOn = ActualLog.Max_ValidatedOn


/*
	������ = ����(Prop_ES*w), ��� w - ��� ������������� �����������
	--��� "��� ���������"		= 0.4
	--��� "���� ���������"		= 0.2
	--��� "������ ���������"	= 0.2
	--��� "��� ����� ���������"	= 0.2
	����� ����. = 1
*/

SELECT
	DENSE_RANK() OVER (
						PARTITION BY 
							MemberType 
						ORDER BY 
							Score DESC
					 )	AS Rank		--������� � ��������
	,*
FROM (
	SELECT --������ ������������� ������������ � ����������		
		Member.Name
		,Member.Type	AS MemberType
		,ROUND(100 * ( 0.4 * CAST(Prop_ED_Type		AS  FLOAT)
					 + 0.2 * CAST(Prop_ED_Signature AS  FLOAT)
					 + 0.2 * CAST(Prop_ED_Region	AS  FLOAT) 
					 + 0.2 * CAST(Prop_ED_Relation	AS  FLOAT)
					 ) 
				,2)	AS Score	--������ ���������
		,Count_ED
		,ISNULL(SUM_ED_Type, 0)						AS SUM_ED_Type
		,ISNULL(SUM_ED_Signature, 0)				AS SUM_ED_Signature
		,ISNULL(SUM_ED_Region, 0)					AS SUM_ED_Region
		,ISNULL(SUM_ED_Relation, 0)					AS SUM_ED_Relation
		,ISNULL(ROUND(Prop_ED_Type, 4), 0)			AS Prop_ED_Type
		,ISNULL(ROUND(Prop_ED_Signature, 4), 0)		AS Prop_ED_Signature
		,ISNULL(ROUND(Prop_ED_Region, 4), 0)		AS Prop_ED_Region
		,ISNULL(ROUND(Prop_ED_Relation, 4), 0)		AS Prop_ED_Relation
	FROM (
		SELECT --���������� �� ������������� ������������ � ��
			MemberGuid
			,IIF(Using_Directory.MemberGuid is not null, COUNT(*), 0)	AS Count_ED				--����� ����������
			,SUM(ED_Type)												AS SUM_ED_Type			--����� �� � ����������� "��� ���������"
			,SUM(ED_Signature)											AS SUM_ED_Signature		--����� �� � ����������� "���� ���������"
			,SUM(ED_Region)												AS SUM_ED_Region		--����� �� � ����������� "������ ���������"
			,SUM(ED_Relation)											AS SUM_ED_Relation		--����� �� � ����������� "��� ����� ���������"
			,SUM(CAST(ED_Type AS FLOAT))/COUNT(*)						AS Prop_ED_Type			--���� �� � ����������� "��� ���������"
			,SUM(CAST(ED_Signature AS FLOAT))/COUNT(*)					AS Prop_ED_Signature	--���� �� � ����������� "���� ���������"
			,SUM(CAST(ED_Region AS FLOAT))/COUNT(*)						AS Prop_ED_Region		--���� �� � ����������� "������ ���������"
			,SUM(CAST(ED_Relation AS FLOAT))/COUNT(*)					AS Prop_ED_Relation		--���� �� � ����������� "��� ����� ���������"
		FROM (
			SELECT --�������� �� � ��������� ������������� ������������ (����������������� �������)
				ValidationLog
				,MemberGuid
				,MAX(ED_Type)		AS ED_Type
				,MAX(ED_Signature)	AS ED_Signature
				,MAX(ED_Region)		AS ED_Region
				,MAX(ED_Relation)	AS ED_Relation
			FROM (
				SELECT --�������� �� � ��������� ������������� ������������
					Score.ValidationLog
					,Score.MemberGuid
					,IIF(Score.Value <> 0 and Score.Criterion = '3.6', 1, 0)	AS ED_Type		--�������� "��� ���������"
					,IIF(Score.Value <> 0 and Score.Criterion = '3.7', 1, 0)	AS ED_Signature	--�������� "���� ���������"
					,IIF(Score.Value <> 0 and Score.Criterion = '3.8', 1, 0)	AS ED_Region	--�������� "������ ���������"
					,IIF(Score.Value <> 0 and Score.Criterion = '3.11', 1, 0)	AS ED_Relation	--�������� "��� ����� ���������"
				FROM #Tmp 
				INNER JOIN Score
					ON Score.ValidationLog = #Tmp.LogId
				WHERE 
					Score.Criterion IN ('3.6', '3.7', '3.8', '3.11')
			) AS ED_Directory
			GROUP BY
				MemberGuid		
				,ValidationLog
		) AS Using_Directory
		GROUP BY 
			MemberGuid
	) AS Stats_Directory
	RIGHT JOIN Member
		ON Member.Guid = Stats_Directory.MemberGuid
	WHERE
		Member.Active = 1
) AS Score_Directory

