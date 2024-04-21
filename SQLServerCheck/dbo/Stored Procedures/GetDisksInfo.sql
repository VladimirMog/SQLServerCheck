
CREATE PROCEDURE [dbo].[GetDisksInfo]
	@title NVARCHAR(255) = 'Server Disks Information',
	@width INT = 6,
	@html NVARCHAR(MAX) OUTPUT
AS
DECLARE @server_name SYSNAME;
DECLARE @cmd VARCHAR(400);
DECLARE @is_cmdshell_enabled BIT;
DECLARE @drive_name NVARCHAR(2);
DECLARE @full_size_mb FLOAT;
DECLARE @free_size_mb FLOAT;
DECLARE @free_percent_size FLOAT;

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
SET @cmd = 'powershell.exe -c "Get-WmiObject -ComputerName ' + QUOTENAME(@server_name, '''') + ' -Class Win32_Volume -Filter ''DriveType = 3'' | select name,capacity,freespace | foreach{$_.name+''|''+$_.capacity/1048576+''%''+$_.freespace/1048576+''*''}"'

CREATE TABLE #output (line VARCHAR(255))

INSERT #output
EXEC xp_cmdshell @cmd

-- width of the block
SET @width = CASE 
				WHEN @width < 1 THEN 1
				WHEN @width > 12 THEN 12
				ELSE @width END
SET @html += N'<div class="col-' + CAST(@width AS NVARCHAR(2)) + '">';
-- block of the data
SET @html += N'<div class="card"><div class="card-body"><div class="card-header"><center><b>' + @title + '</b></center></div><table class="table table-bordered"><thead class="bg-gray-light"><tr>';          
SET @html += N'<th style="width: 25%">Disk</th>';
SET @html += N'<th style="width: 25%">Full Size (MB)</th>';
SET @html += N'<th style="width: 25%">Free Space (MB)</th>';
SET @html += N'<th style="width: 25%">Free Size (%)</th>';
SET @html += N'</tr></thead><tbody><tr>';

DECLARE CUR CURSOR LOCAL STATIC FORWARD_ONLY
FOR
SELECT 
	  LEFT(LTRIM(line),1) AS DriveName
	, ROUND(CAST(RTRIM(LTRIM(SUBSTRING(line, CHARINDEX('|', line) + 1, (CHARINDEX('%', line) - 1) - CHARINDEX('|', line)))) AS FLOAT), 0) AS FullSize
	, ROUND(CAST(RTRIM(LTRIM(SUBSTRING(line, CHARINDEX('%', line) + 1, (CHARINDEX('*', line) - 1) - CHARINDEX('%', line)))) AS FLOAT), 0) AS FreeSpace
FROM #output
WHERE line LIKE '[A-Z][:]%'
ORDER BY drivename

OPEN CUR

WHILE (1=1)
	BEGIN
		FETCH NEXT FROM CUR INTO @drive_name , @full_size_mb , @free_size_mb
		IF @@FETCH_STATUS <> 0 
			BREAK;
		SET @html += N'<tr>';
		SET @html += N'<td>' + @drive_name + '</td>';
		SET @html += N'<td class="right">' + ISNULL(FORMAT(@full_size_mb, '###'),'-') + '</td>';
		SET @html += N'<td class="right">' + ISNULL(FORMAT(@free_size_mb, '###'),'-') + '</td>'; 
		IF ISNULL(@full_size_mb,0) = 0
			SET @free_percent_size = 0
		ELSE
			SET @free_percent_size = 100 * @free_size_mb / @full_size_mb
		SET @html += N'<td class="right"><label>' + FORMAT(@free_percent_size, 'N1')
			+ '<meter min="0" max="100" low="30" high="75" optimum="80" value="' 			
			+ CAST(@free_percent_size AS NVARCHAR(10)) + '"></meter></label></td>';

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
