-- Get active subscriptions in SSRS and their intervals
-- Ref https://docs.microsoft.com/en-us/sql/relational-databases/system-tables/dbo-sysschedules-transact-sql?view=sql-server-ver15

SELECT
	rs_catalog.Name,
	rs_sub.ExtensionSettings AS Config,
    rs_sub.Parameters AS Parameters,
    CAST(rs_sub.ExtensionSettings AS XML).value('(/ParameterValues/ParameterValue[1]/Value)[1]', 'VARCHAR(256)') AS Target,
    CASE
        WHEN CAST(rs_sub.ExtensionSettings AS XML).value('(/ParameterValues/ParameterValue[2]/Name)[1]', 'VARCHAR(256)') = 'CC' THEN CAST(rs_sub.ExtensionSettings AS XML).value('(/ParameterValues/ParameterValue[2]/Value)[1]', 'VARCHAR(256)')
        ELSE ''
    END AS CC,
	jobs.name AS JobName,
	CASE sched.freq_type
		WHEN 1 THEN 'Once'
		WHEN 4 THEN 'Daily'
		WHEN 8 THEN 'Weekly'
		WHEN 16 THEN 'Monthly'
		WHEN 32 THEN 'Monthly'
		ELSE 'ERROR'
	END AS Freq,
	CASE sched.freq_type
		WHEN 1 THEN 'Once'
		WHEN 4 THEN 'Every ' + CAST(sched.freq_interval AS VARCHAR) + ' days'
		WHEN 8 THEN
			CASE WHEN sched.freq_interval & 1 = 1 THEN 'Sun' ELSE '' END
            + CASE WHEN sched.freq_interval & 2 = 2 THEN 'Mon' ELSE '' END
            + CASE WHEN sched.freq_interval & 4 = 4 THEN 'Tue' ELSE '' END
            + CASE WHEN sched.freq_interval & 8 = 8 THEN 'Wed' ELSE '' END
            + CASE WHEN sched.freq_interval & 16 = 16 THEN 'Thu' ELSE '' END
            + CASE WHEN sched.freq_interval & 32 = 32 THEN 'Fri' ELSE '' END
            + CASE WHEN sched.freq_interval & 64 = 64 THEN 'Sat' ELSE '' END
		WHEN 16 THEN 'On dat ' + CAST(sched.freq_interval AS VARCHAR) + ' of the month'
		WHEN 32 THEN
			CASE sched.freq_interval
				WHEN 1 THEN 'Sun'
				WHEN 2 THEN 'Mon'
				WHEN 3 THEN 'Tue'
				WHEN 4 THEN 'Wed'
				WHEN 5 THEN 'Thu'
				WHEN 6 THEN 'Fri'
				WHEN 7 THEN 'Sat'
				WHEN 8 THEN 'Day'
				WHEN 9 THEN 'Weekday'
				WHEN 10 THEN 'Weekend'
				ELSE 'Err'
			END
		ELSE 'ERROR'
	END AS Interval,
	CASE sched.freq_subday_type
        WHEN 1 THEN 'Once'
        WHEN 2 THEN 'Seconds'
        WHEN 4 THEN 'Minutes'
        WHEN 8 THEN 'Hours'
        ELSE 'Err'
    END AS Subday,
	CASE sched.freq_subday_interval
        WHEN 0 THEN ''
        ELSE CAST(sched.freq_subday_interval AS VARCHAR)
    END AS SubdayInterval,
    CASE
        WHEN sched.freq_type = 32 THEN
            CASE sched.freq_relative_interval
                WHEN '0' THEN ''
                WHEN '1' THEN 'First'
                WHEN '2' THEN 'Second'
                WHEN '4' THEN 'Third'
                WHEN '8' THEN 'Fourth'
                WHEN '16' THEN 'Last'
                ELSE 'Err'
            END
        ELSE ''
    END AS MonthlyInterval,
	CASE
		WHEN sched.freq_type = 8 THEN 'Every ' + CAST(sched.freq_recurrence_factor AS VARCHAR) + ' Weeks'
		WHEN sched.freq_type = 16 OR sched.freq_type = 32 THEN 'Every ' + CAST(sched.freq_recurrence_factor AS VARCHAR) + ' Months'
		ELSE ''
	END AS Freq,
	sched.active_start_date,
    CAST(CAST(sched.active_start_date AS VARCHAR) AS DATE) AS StartDate,
    STUFF(STUFF(RIGHT('0' + RTRIM(CAST(sched.active_start_time AS VARCHAR)), 6), 3, 0, ':'), 6, 0, ':') AS StartTime,
    CASE sched.active_end_date
        WHEN 99991231 THEN NULL
        ELSE CAST(CAST(sched.active_end_date AS VARCHAR) AS DATE)
    END AS EndDate
FROM
	ReportServer.dbo.Subscriptions AS rs_sub

	LEFT OUTER JOIN ReportServer.dbo.Catalog AS rs_catalog
	ON rs_catalog.ItemID = rs_sub.Report_OID

	LEFT OUTER JOIN ReportServer.dbo.ReportSchedule AS rs_sched
	ON rs_sched.SubscriptionID = rs_sub.SubscriptionID

	LEFT OUTER JOIN msdb.dbo.sysjobs AS jobs
	ON jobs.name = CAST(rs_sched.ScheduleId AS NVARCHAR(128))

	LEFT OUTER JOIN msdb.dbo.sysjobschedules AS jobs_sched
	ON jobs_sched.job_id = jobs.job_id

	LEFT OUTER JOIN msdb.dbo.sysschedules AS sched
	ON sched.schedule_id = jobs_sched.schedule_id
WHERE
	sched.enabled = 1