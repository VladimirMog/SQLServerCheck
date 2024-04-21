
CREATE   PROCEDURE [dbo].[GetDatabaseSpaceInfo]
	@title NVARCHAR(255) = 'Database Space Info',
	@width INT = 6,
	@html NVARCHAR(MAX) OUTPUT
AS
DECLARE @server_name SYSNAME
DECLARE @sql VARCHAR(400)
DECLARE @is_cmdshell_enabled BIT
DECLARE @database_id INT;
DECLARE @database_name SYSNAME
DECLARE @database_state SYSNAME
DECLARE @recovery_model SYSNAME
DECLARE @max_size_mb FLOAT
DECLARE @database_size_mb FLOAT
DECLARE @free_percent_size FLOAT

EXECUTE sp_configure 'show advanced options'
	, 1;

SELECT @is_cmdshell_enabled = CAST([value] AS BIT)
FROM sys.configurations
WHERE [name] = 'xp_cmdshell'

IF @is_cmdshell_enabled = 0
BEGIN
	EXEC sp_configure 'xp_cmdshell'
		, 1

	RECONFIGURE;
END

SET @server_name = HOST_NAME()
SET @sql = 'powershell.exe -c "Get-WmiObject -ComputerName ' + QUOTENAME(@server_name, '''') + ' -Class Win32_Volume -Filter ''DriveType = 3'' | select name,capacity,freespace | foreach{$_.name+''|''+$_.capacity/1048576+''%''+$_.freespace/1048576+''*''}"'

CREATE TABLE #output (line VARCHAR(255))

INSERT #output
EXEC xp_cmdshell @sql;

-- width of the block
SET @width = CASE 
				WHEN @width < 1 THEN 1
				WHEN @width > 12 THEN 12
				ELSE @width END
SET @html += N'<div class="col-' + CAST(@width AS NVARCHAR(2)) + '">';
-- block of the data
SET @html += N'<div class="card"><div class="card-body"><div class="card-header"><center><b>' + @title + '</b></center></div><table class="table table-bordered"><thead class="bg-gray-light"><tr>';          
SET @html += N'<th style="width: 30%">Database Name</th>';
SET @html += N'<th style="width: 15%">Database State</th>';
SET @html += N'<th style="width: 15%">Recovery Model</th>';
SET @html += N'<th style="width: 15%">Max Size (MB)</th>';
SET @html += N'<th style="width: 15%">Database Size (MB)</th>';
SET @html += N'<th style="width: 10%">Free Size (%)</th>';
SET @html += N'</tr></thead><tbody><tr>';

DECLARE CUR CURSOR LOCAL STATIC FORWARD_ONLY
FOR
WITH cte
AS (
	SELECT LEFT(LTRIM(line), 1) AS DriveName
		, ROUND(CAST(RTRIM(LTRIM(SUBSTRING(line, CHARINDEX('|', line) + 1, (CHARINDEX('%', line) - 1) - CHARINDEX('|', line)))) AS FLOAT), 0) AS FullSize
		, ROUND(CAST(RTRIM(LTRIM(SUBSTRING(line, CHARINDEX('%', line) + 1, (CHARINDEX('*', line) - 1) - CHARINDEX('%', line)))) AS FLOAT), 0) AS FreeSpace
	FROM #output
	WHERE line LIKE '[A-Z][:]%'
	)
SELECT t.database_id
	, t.DatabaseName
	, t.DatabaseState
	, t.RecoveryModel
	, MIN(t.MaxSizeMB) AS MaxSizeMB
	, SUM(t.DatabaseSizeMB) AS DatabaseSizeMB
	, IIF(ISNULL(MIN(t.MaxSizeMB),0) > 0, (100 - SUM(t.DatabaseSizeMB) * 100 / MIN(t.MaxSizeMB)), 0 ) AS FreePercentSize
FROM (
	SELECT 
		db.database_id
		, db.[name] AS DatabaseName
		, db.recovery_model_desc AS RecoveryModel
		, db.state_desc + IIF(db.is_read_only = 1,' READ ONLY', '') + IIF(db.is_in_standby = 1,' STANDBY', '') AS DatabaseState
		, SUM(size) / 128 AS DatabaseSizeMB
		, CASE 
			WHEN MIN(max_size) = - 1
				THEN cte.FreeSpace
			WHEN MAX(max_size) = - 1
				THEN cte.FreeSpace
			WHEN MAX(max_size) > cte.FreeSpace
				THEN cte.FreeSpace
			ELSE MAX(max_size)
			END AS MaxSizeMB 
	FROM sys.master_files mf
	OUTER APPLY sys.dm_os_volume_stats(mf.database_id, mf.FILE_ID) dovs
	INNER JOIN sys.databases db ON mf.database_id = db.database_id
	LEFT JOIN cte ON cte.DriveName = LEFT(LTRIM(mf.physical_name), 1)
	GROUP BY db.[name]
		, db.database_id
		, cte.FreeSpace
		, db.state_desc
		, db.recovery_model_desc
		, db.is_read_only
		, db.is_in_standby
	) t
GROUP BY t.database_id
	, t.DatabaseName
	, t.DatabaseState
	, t.RecoveryModel
ORDER BY CASE 
		WHEN t.database_id < 5
			THEN CAST(t.database_id AS VARCHAR)
		ELSE t.DatabaseName
		END

OPEN CUR

WHILE (1=1)
	BEGIN
		FETCH NEXT FROM CUR INTO @database_id , @database_name , @database_state , @recovery_model , @max_size_mb , @database_size_mb , @free_percent_size
		IF @@FETCH_STATUS <> 0 
			BREAK;
		SET @html += N'<tr>';
		SET @html += N'<td>' + @database_name + '</td>';
		SET @html += N'<td class="center">' + @database_state + '</td>';
		SET @html += N'<td class="center">' + @recovery_model + '</td>';
		SET @html += N'<td class="right">' + ISNULL(FORMAT(@max_size_mb, '####'),'-') + '</td>';
		SET @html += N'<td class="right">' + ISNULL(FORMAT(@database_size_mb, '####'),'-') + '</td>'; 
		SET @html += N'<td class="right"><label>' + FORMAT(@free_percent_size, 'N1') + '<meter min="0" max="100" low="30" high="75" optimum="80" value="' + CAST(ROUND(@free_percent_size,1) AS NVARCHAR(5)) + '"></meter></label></td>';
	END

CLOSE CUR
DEALLOCATE CUR

DROP TABLE #output

SET @html += N'</tr></tbody></table></div></div>';

IF @is_cmdshell_enabled = 0
BEGIN
	EXEC sp_configure 'xp_cmdshell'
		, 0

	RECONFIGURE;
END

EXECUTE sp_configure 'show advanced options'
	, 0;
