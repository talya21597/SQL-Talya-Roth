USE MyCompanyDB_Talya_Roth;
GO

-- ========================================
-- חלק ה - עמודה KOTERET עם Window Functions
-- ========================================

-- יצירת טבלה T לדוגמה
IF OBJECT_ID('dbo.T', 'U') IS NOT NULL DROP TABLE dbo.T;
GO

CREATE TABLE dbo.T (
    SHURA INT,
    TEUR NVARCHAR(50)
);
GO

-- הוספת נתונים לדוגמה
INSERT INTO dbo.T VALUES
(1, 'ערך1'),
(2, NULL),
(3, NULL),
(4, 'ערך2'),
(5, NULL),
(6, 'ערך3'),
(7, NULL),
(8, NULL);
GO

-- ========================================
-- הוספת עמודה KOTERET
-- ========================================
-- זיהוי קבוצות לפי תחילת קבוצה חדשה (שורה ראשונה או NULL בערך הקודם)
-- הוספת הערך הראשון של כל קבוצה לכל השורות בקבוצה

WITH GroupDetection AS (
    SELECT 
        *,
        SUM(CASE 
            WHEN LAG(TEUR) OVER (ORDER BY SHURA) IS NULL AND TEUR IS NOT NULL THEN 1 
            ELSE 0 
        END) OVER (ORDER BY SHURA) AS grp
    FROM dbo.T
),
FirstValuePerGroup AS (
    SELECT 
        *,
        FIRST_VALUE(TEUR) OVER (PARTITION BY grp ORDER BY SHURA) AS KOTERET
    FROM GroupDetection
)
SELECT *
FROM FirstValuePerGroup
ORDER BY SHURA;
