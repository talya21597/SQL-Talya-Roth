USE MyCompanyDB_Talya_Roth;
GO

-- ========================================
-- חלק א - שאילתות על מערכת המכירות
-- ========================================

-- שאילתה 1: הכמות, סכום המכירות וכמות החשבוניות לכל פריט
SELECT 
    i.ItemCode,
    ISNULL(SUM(s.Qty), 0) AS TotalQuantity,
    COUNT(DISTINCT s.DocNum) AS NumInvoices,
    ISNULL(SUM(s.LineSum - (h.DocDiscount * s.LineSum / NULLIF(SUM(s.LineSum) OVER (PARTITION BY h.DocNum), 0))), 0) AS TotalSalesAfterDiscount
FROM 
    dbo.Items i
LEFT JOIN 
    dbo.SalesLine s ON i.ItemCode = s.ItemCode
LEFT JOIN 
    dbo.SalesHeader h ON s.DocNum = h.DocNum
GROUP BY 
    i.ItemCode
ORDER BY
    i.ItemCode;
---- שאילתה 2: מספרי חשבוניות שבכל אחת מהן קיים פריט 3611010 וגם 3611600
SELECT DISTINCT sl1.DocNum
FROM dbo.SalesLine sl1
WHERE sl1.ItemCode = 3611010
INTERSECT
SELECT DISTINCT sl2.DocNum
FROM dbo.SalesLine sl2
WHERE sl2.ItemCode = 3611600;
---- שאילתה 3: אנשי מכירות שמכרו את כלל הפריטים המוצעים בקטלוג
WITH SalesPersonItems AS (
    SELECT h.SalesPersonCode, COUNT(DISTINCT l.ItemCode) AS CountItemsSold
    FROM dbo.SalesHeader h
    INNER JOIN dbo.SalesLine l ON h.DocNum = l.DocNum
    GROUP BY h.SalesPersonCode
)
SELECT sp.SalesPersonCode, sp.SalesPersonName
FROM SalesPersonItems spi
INNER JOIN dbo.SalesPerson sp ON spi.SalesPersonCode = sp.SalesPersonCode
WHERE spi.CountItemsSold = (SELECT COUNT(DISTINCT ItemCode) FROM dbo.Items);

---- שאילתה 4: פריטים שנמכרו הן אצל איש המכירות עם המגוון הגדול ביותר 
-- והן אצל איש המכירות עם הכמות הגדולה ביותר, אך לא אצל איש עם המגוון הקטן ביותר
SELECT DISTINCT l.ItemCode
FROM dbo.SalesLine l
INNER JOIN dbo.SalesHeader h ON l.DocNum = h.DocNum
WHERE h.SalesPersonCode = (
    SELECT TOP 1 SalesPersonCode
    FROM dbo.SalesLine l2
    INNER JOIN dbo.SalesHeader h2 ON l2.DocNum = h2.DocNum
    GROUP BY h2.SalesPersonCode
    ORDER BY COUNT(DISTINCT l2.ItemCode) DESC
)
INTERSECT
SELECT DISTINCT l.ItemCode
FROM dbo.SalesLine l
INNER JOIN dbo.SalesHeader h ON l.DocNum = h.DocNum
WHERE h.SalesPersonCode = (
    SELECT TOP 1 SalesPersonCode
    FROM dbo.SalesLine l2
    INNER JOIN dbo.SalesHeader h2 ON l2.DocNum = h2.DocNum
    GROUP BY h2.SalesPersonCode
    ORDER BY SUM(l2.Qty) DESC
)
EXCEPT
SELECT DISTINCT l.ItemCode
FROM dbo.SalesLine l
INNER JOIN dbo.SalesHeader h ON l.DocNum = h.DocNum
WHERE h.SalesPersonCode = (
    SELECT TOP 1 SalesPersonCode
    FROM dbo.SalesLine l2
    INNER JOIN dbo.SalesHeader h2 ON l2.DocNum = h2.DocNum
    GROUP BY h2.SalesPersonCode
    ORDER BY COUNT(DISTINCT l2.ItemCode) ASC
);
-- שאילתה 5: פריטים שנמכרו מתחת לממוצע מכירות לפריט לכל איש מכירות
WITH AvgQtyPerItem AS (
    SELECT 
        h.SalesPersonCode,
        l.ItemCode,
        AVG(CAST(l.Qty AS FLOAT)) AS AvgQtyPerItem
    FROM dbo.SalesHeader h
    INNER JOIN dbo.SalesLine l ON l.DocNum = h.DocNum
    GROUP BY h.SalesPersonCode, l.ItemCode
)
SELECT 
    h.SalesPersonCode,
    l.ItemCode,
    aq.AvgQtyPerItem,
    SUM(l.LineSum - (h.DocDiscount * l.LineSum / NULLIF(SUM(l.LineSum) OVER (PARTITION BY h.DocNum), 0))) AS NetSaleAmount
FROM dbo.SalesHeader h
INNER JOIN dbo.SalesLine l ON l.DocNum = h.DocNum
INNER JOIN AvgQtyPerItem aq ON aq.SalesPersonCode = h.SalesPersonCode AND aq.ItemCode = l.ItemCode
WHERE l.Qty < aq.AvgQtyPerItem
GROUP BY h.SalesPersonCode, l.ItemCode, aq.AvgQtyPerItem;

---- שאילתה 6: אנשי מכירות שתרומתם מהווה 88% מסך הכמות הנמכרת
WITH SalesTeamCTE AS (
    SELECT 
        h.SalesPersonCode,
        SUM(l.Qty) AS TotalQtyPerPerson,
        (CAST(SUM(l.Qty) AS FLOAT) / SUM(SUM(l.Qty)) OVER()) AS IndividualPct
    FROM dbo.SalesHeader h
    INNER JOIN dbo.SalesLine l ON h.DocNum = l.DocNum
    GROUP BY h.SalesPersonCode
),
RankedSales AS (
    SELECT 
        *,
        SUM(IndividualPct) OVER (ORDER BY IndividualPct DESC) AS CumulativePct
    FROM SalesTeamCTE
),
Top88Pct AS (
    SELECT *
    FROM RankedSales
    WHERE CumulativePct <= 0.88
)
SELECT 
    sp.SalesPersonCode,
    sp.SalesPersonName,
    h.DocNum,
    SUM(l.Qty) AS DocQuantity
FROM Top88Pct t88
INNER JOIN dbo.SalesPerson sp ON t88.SalesPersonCode = sp.SalesPersonCode
INNER JOIN dbo.SalesHeader h ON t88.SalesPersonCode = h.SalesPersonCode
INNER JOIN dbo.SalesLine l ON h.DocNum = l.DocNum
GROUP BY sp.SalesPersonCode, sp.SalesPersonName, h.DocNum
ORDER BY sp.SalesPersonCode, h.DocDate DESC;
--    FROM SalesTeamCTE
--)

--SELECT 
--    r.SalesPersonCode,
--    h.DocNum,
--    l.Qty,
--    h.DocDate
--FROM [dbo].[SalesHeader] h
--JOIN [dbo].[SalesLine] l ON h.DocNum = l.DocNum
--JOIN RankedSales r ON h.SalesPersonCode = r.SalesPersonCode

-- שאילתה 7: סכום המכירות הכולל וממוצע המכירות לכל חשבונית לכל איש מכירות
SELECT 
    sp.SalesPersonCode,
    sp.SalesPersonName,
    (SELECT SUM(l.LineSum - (h.DocDiscount * l.LineSum / NULLIF(SUM(l.LineSum) OVER (PARTITION BY h.DocNum), 0)))
     FROM dbo.SalesLine l
     INNER JOIN dbo.SalesHeader h ON h.DocNum = l.DocNum
     WHERE h.SalesPersonCode = sp.SalesPersonCode) AS TotalSalesSum,
    (SELECT SUM(l.LineSum - (h.DocDiscount * l.LineSum / NULLIF(SUM(l.LineSum) OVER (PARTITION BY h.DocNum), 0))) / NULLIF(COUNT(DISTINCT h.DocNum), 0)
     FROM dbo.SalesHeader h
     INNER JOIN dbo.SalesLine l ON h.DocNum = l.DocNum
     WHERE h.SalesPersonCode = sp.SalesPersonCode) AS AvgSalesPerInvoice
FROM dbo.SalesPerson sp;
