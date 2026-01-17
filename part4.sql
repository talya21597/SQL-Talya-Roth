USE MyCompanyDB_Talya_Roth;
GO

-- ========================================
-- חלק ד - פונקציה MyReverse
-- ========================================
-- פונקציה שהופכת מחרוזת ללא שימוש בפונקציה REVERSE המקורית

-- יצירת הפונקציה
CREATE FUNCTION dbo.MyReverse (@str NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @result NVARCHAR(MAX) = '';
    DECLARE @i INT = LEN(@str);

    WHILE @i > 0
    BEGIN
        SET @result = @result + SUBSTRING(@str, @i, 1);
        SET @i = @i - 1;
    END

    RETURN @result;
END
GO

-- שימוש בפונקציה החדשה
SELECT dbo.MyReverse('ABCDEF') AS ReversedString;
SELECT dbo.MyReverse('Talya Roth') AS ReversedName;
SELECT dbo.MyReverse('Hello World') AS ReversedGreeting;
