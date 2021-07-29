USE ReportServer

-- SSRS Report Query for SSRS Report Usage

-- Parameters
-- DECLARE @StartDate DATETIME
-- DECLARE @EndDate DATETIME
-- SET @StartDate = '2020-09-01 00:00:00'
-- SET @EndDate = '2020-09-03 00:00:00'

SELECT
    MAX(log.TimeStart) AS Timestamp,
    log.UserName,
    log.Status,
    Catalog.Path

FROM
    ExecutionLogStorage log

    INNER JOIN Catalog
    ON log.ReportID = Catalog.ItemID
        AND Catalog.Type = 2

WHERE
    log.TimeStart BETWEEN @StartDate AND @EndDate
    AND log.ExecutionId IS NOT NULL

GROUP BY ExecutionId, UserName, Status, Path
ORDER BY MAX(log.TimeStart) DESC
