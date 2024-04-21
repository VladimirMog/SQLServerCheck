
CREATE PROCEDURE dbo.[__GetDatabaseInfo]
AS

SELECT 
	available_bytes,
	available_bytes / (1024*1024*1024) AGB,
	max_size / 128 GB,
	CASE 
		WHEN max_size = -1 THEN available_bytes / (1024*1024*1024)
		WHEN max_size / 128 > available_bytes / (1024*1024*1024) THEN available_bytes / (1024*1024*1024)
		ELSE max_size / 128 END AS Max_Size_GB, -- SELECT 
		*

FROM sys.master_files mf
		CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.FILE_ID) dovs
--WHERE name = 'FIN'


/*
SELECT db.name as DatabaseName, 
		SUM(mf.size) as DatabaseSize,
		db.recovery_model_desc as RecoveryModel,
		db.state_desc as DatabaseState,


		dovs.logical_volume_name AS LogicalName,
			dovs.volume_mount_point AS Drive,
			MAX(CONVERT(NUMERIC(36, 2), dovs.total_bytes / 1048576.00 / 1024.00)) AS TotalSpaceInGB,
			MAX(CONVERT(NUMERIC(36, 2), dovs.available_bytes / 1048576.00 / 1024.00)) AS FreeSpaceInGB
		FROM sys.master_files mf
		CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.FILE_ID) dovs
		INNER JOIN sys.databases db ON mf.database_id = db.database_id
		GROUP BY db.name, 
				db.recovery_model_desc,
		db.state_desc,
		dovs.logical_volume_name,
			dovs.volume_mount_point

SELECT *
FROM sys.databases

SELECT 268435456/128

--2097152
*/