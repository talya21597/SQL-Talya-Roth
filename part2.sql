USE MyCompanyDB_Talya_Roth;
GO

-- ========================================
-- חלק ב - ניתוח גישה למידע במערכת ריבוי משתמשים
-- ========================================
-- הערה: השאילתות באה להוסיף טבלת Requests נוספת לבדיקה

-- יצירת טבלת Requests (להוספה למסד הנתונים)
IF OBJECT_ID('dbo.Requests', 'U') IS NOT NULL DROP TABLE dbo.Requests;
GO

CREATE TABLE dbo.Requests (
    RequestID INT PRIMARY KEY,
    UserID INT NOT NULL,
    DocumentID INT,
    RequestTime DATETIME NOT NULL,
    ResponseTime DATETIME,
    Priority INT,
    ExpirationTime DATETIME
);
GO

-- ========================================
-- בעיה א - זיהוי משתמשים תובעניים
-- ========================================
-- משתמש תובעני = משתמש ששלח יותר מ-10 בקשות במהלך חלון זמן של 5 דקות

WITH WindowCounts AS (
    SELECT
        r.UserID,
        r.RequestTime,
        COUNT(*) AS Cnt
    FROM dbo.Requests r
    CROSS APPLY (
        SELECT COUNT(*) AS RequestCount
        FROM dbo.Requests r2
        WHERE r2.UserID = r.UserID
          AND r2.RequestTime >= r.RequestTime
          AND r2.RequestTime < DATEADD(MINUTE, 5, r.RequestTime)
    ) wc
    GROUP BY r.UserID, r.RequestTime
),
PerUserMax AS (
    SELECT
        UserID,
        MAX(Cnt) AS MaxRequestsIn5Min
    FROM WindowCounts
    GROUP BY UserID
),
DemandingUsers AS (
    SELECT *
    FROM PerUserMax
    WHERE MaxRequestsIn5Min > 10
)
SELECT *
FROM DemandingUsers
WHERE MaxRequestsIn5Min = (SELECT MAX(MaxRequestsIn5Min) FROM DemandingUsers)
ORDER BY UserID;

-- ========================================
-- בעיה ב - מקסום טיפול בבקשות דחופות
-- ========================================
-- בחירת רצף בקשות עם סכום עדיפות מקסימלי תוך שמירה על זמן והסדר

WITH FilteredRequests AS (
    SELECT *
    FROM dbo.Requests
    WHERE ResponseTime IS NOT NULL
      AND ResponseTime <= ExpirationTime
),
SortedRequests AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY ResponseTime) AS rn
    FROM FilteredRequests
),
PrevRequest AS (
    SELECT sr.*,
           (SELECT MAX(sr2.rn)
            FROM SortedRequests sr2
            WHERE sr2.ResponseTime <= sr.RequestTime) AS prev_rn
    FROM SortedRequests sr
),
DynamicProgram AS (
    SELECT rn, Priority AS BestValue
    FROM PrevRequest WHERE rn = 1
    UNION ALL
    SELECT pr.rn,
           CASE
               WHEN ISNULL(dp2.BestValue, 0) + pr.Priority >= dp1.BestValue
               THEN ISNULL(dp2.BestValue, 0) + pr.Priority
               ELSE dp1.BestValue
           END
    FROM PrevRequest pr
    INNER JOIN DynamicProgram dp1 ON dp1.rn = pr.rn - 1
    LEFT JOIN DynamicProgram dp2 ON dp2.rn = pr.prev_rn
)
SELECT MAX(BestValue) AS MaxTotalPriority
FROM DynamicProgram
OPTION (MAXRECURSION 0);

-- ========================================
-- בעיה ג - זיהוי צווארי בקבוק
-- ========================================
-- זמן המתנה ממוצע הגבוה ביותר בפרקי זמן קבועים של 5 דקות

DECLARE @TimeInterval INT = 5; -- גודל פרק הזמן בדקות

WITH Buckets AS (
    SELECT
        DATEADD(MINUTE, (DATEDIFF(MINUTE, 0, RequestTime) / @TimeInterval) * @TimeInterval, 0) AS BucketStart,
        DATEDIFF(MINUTE, RequestTime, ResponseTime) AS WaitTimeMinutes
    FROM dbo.Requests
    WHERE ResponseTime IS NOT NULL
)
SELECT TOP 1
    BucketStart,
    AVG(CAST(WaitTimeMinutes AS FLOAT)) AS AvgWaitTimeMinutes
FROM Buckets
GROUP BY BucketStart
ORDER BY AvgWaitTimeMinutes DESC;
--    WaitSec = DATEDIFF(SECOND, RequestTime, ResponseTime)
--  FROM Requests
--  WHERE ResponseTime IS NOT NULL AND ResponseTime >= RequestTime
--)
--SELECT TOP (1)
--  BucketStart,
--  DATEADD(MINUTE,@M,BucketStart) AS BucketEnd,
--  AVG(1.0*WaitSec) AS AvgWaitSec
--FROM B
--GROUP BY BucketStart
--ORDER BY AvgWaitSec DESC;
