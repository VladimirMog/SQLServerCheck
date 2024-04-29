	-- SQL Server CPU Usage Details
	
CREATE PROCEDURE dbo.GetCpuUsage
	@title NVARCHAR(255) = 'Server Disks Information',
	@width INT = 6,
	@html NVARCHAR(MAX) OUTPUT
AS
BEGIN
	IF object_id('tempdb..#CPU') IS NOT NULL
		DROP TABLE #CPU;

	CREATE TABLE #CPU (
		EventTime2 DATETIME,
		SQLProcessUtilization VARCHAR(50),
		SystemIdle VARCHAR(50),
		OtherProcessUtilization VARCHAR(50)
		);

	DECLARE @ts BIGINT;
	DECLARE @lastNmin TINYINT;

	SET @lastNmin = 240;

	SELECT @ts = (
			SELECT cpu_ticks / (cpu_ticks / ms_ticks)
			FROM sys.dm_os_sys_info
			);

	INSERT INTO #CPU
	SELECT *
	FROM (
		SELECT DATEADD(ms, - 1 * (@ts - [timestamp]), GETDATE()) AS [Event_Time],
			SQLProcessUtilization AS [SQLServer_CPU_Utilization],
			SystemIdle AS [System_Idle_Process],
			100 - SystemIdle - SQLProcessUtilization AS [Other_Process_CPU_Utilization]
		FROM (
			SELECT record.value('(./Record/@id)[1]', 'int') AS record_id,
				record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS [SystemIdle],
				record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS [SQLProcessUtilization],
				[timestamp]
			FROM (
				SELECT [timestamp],
					convert(XML, record) AS [record]
				FROM sys.dm_os_ring_buffers
				WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
					AND record LIKE '%%'
				) AS x
			) AS y
		) d
END