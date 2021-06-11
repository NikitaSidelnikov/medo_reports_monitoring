SELECT
	ROW_NUMBER() OVER (ORDER BY LastDeliveredOn)
	,Member.Name
	,Member.Guid
	,CheckLastPackage.LastDeliveredOn
FROM Member
LEFT JOIN (
	SELECT 
		MemberGuid 
		,MAX(DeliveredOn)  as LastDeliveredOn
	FROM Batch
	GROUP BY 
		MemberGuid
) AS CheckLastPackage
	ON CheckLastPackage.MemberGuid = Member.Guid
WHERE 
	Member.Active = 1
