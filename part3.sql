USE MyCompanyDB_Talya_Roth;
GO

-- ========================================
-- חלק ג - קומבינציות של שלושה ערכים
-- ========================================

-- יצירת טבלה A לדוגמה
IF OBJECT_ID('dbo.A', 'U') IS NOT NULL DROP TABLE dbo.A;
GO

CREATE TABLE dbo.A (
    val INT
);
GO

-- הוספת נתונים לדוגמה
INSERT INTO dbo.A VALUES (2), (6), (8), (10), (14), (20), (24);
GO

-- ========================================
-- סעיף א: קומבינציות עם חשיבות לסדר
-- ========================================
-- כל סידור ייחשב כתוצאה נפרדת
-- דוגמה: X = 32

SELECT a1.val AS num1, a2.val AS num2, a3.val AS num3
FROM dbo.A a1
CROSS JOIN dbo.A a2
CROSS JOIN dbo.A a3
WHERE a1.val <> a2.val 
  AND a2.val <> a3.val 
  AND a1.val <> a3.val
  AND a1.val + a2.val + a3.val = 32
ORDER BY a1.val, a2.val, a3.val;
GO

-- ========================================
-- סעיף ב: קומבינציות ללא חשיבות לסדר
-- ========================================
-- כל קומבינציה תופיע פעם אחת בלבד

SELECT a1.val AS num1, a2.val AS num2, a3.val AS num3
FROM dbo.A a1
INNER JOIN dbo.A a2 ON a2.val > a1.val
INNER JOIN dbo.A a3 ON a3.val > a2.val
WHERE a1.val + a2.val + a3.val = 32
ORDER BY a1.val, a2.val, a3.val;

-- ========================================
-- סעיף ג: הקומבינציה עם המכפלה הגדולה ביותר
-- ========================================
-- שומרים את התוצאות של סעיף ב' בטבלה זמנית

DROP TABLE IF EXISTS #temp_table;

SELECT a1.val AS num1, a2.val AS num2, a3.val AS num3
INTO #temp_table
FROM dbo.A a1
INNER JOIN dbo.A a2 ON a2.val > a1.val
INNER JOIN dbo.A a3 ON a3.val > a2.val
WHERE a1.val + a2.val + a3.val = 32;

-- חזרת הקומבינציה עם המכפלה הגדולה ביותר
SELECT TOP 1 WITH TIES *,
       (CAST(num1 AS BIGINT) * num2 * num3) AS product
FROM #temp_table
ORDER BY (CAST(num1 AS BIGINT) * num2 * num3) DESC;
