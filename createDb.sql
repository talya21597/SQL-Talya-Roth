-- =============================
-- יצירת מסד נתונים חדש
-- =============================
CREATE DATABASE MyCompanyDB_Talya_Roth;
GO

-- בחירה במסד החדש
USE MyCompanyDB_Talya_Roth;
GO

-- =============================
-- ניקוי טבלאות קיימות
-- =============================
IF OBJECT_ID('dbo.SalesHeader', 'U') IS NOT NULL DROP TABLE dbo.SalesHeader;
IF OBJECT_ID('dbo.SalesLine', 'U') IS NOT NULL DROP TABLE dbo.SalesLine;
IF OBJECT_ID('dbo.Items', 'U') IS NOT NULL DROP TABLE dbo.Items;
IF OBJECT_ID('dbo.SalesPerson', 'U') IS NOT NULL DROP TABLE dbo.SalesPerson;
IF OBJECT_ID('dbo.mini_cost', 'U') IS NOT NULL DROP TABLE dbo.mini_cost;
GO

-- =============================
-- יצירת טבלאות
-- =============================
CREATE TABLE dbo.mini_cost (
    MonthNum INT,
    JM_Cost INT,
    BB_Cost INT
);

CREATE TABLE dbo.SalesHeader (
    DocNum INT PRIMARY KEY,
    DocDate DATE NOT NULL,
    DocDiscount FLOAT NULL,
    SalesPersonCode INT NOT NULL
);

CREATE TABLE dbo.SalesLine (
    DocNum INT NOT NULL,
    DocLine INT NOT NULL,
    ItemCode INT NOT NULL,
    Qty INT NOT NULL,
    LineSum FLOAT NOT NULL,
    PRIMARY KEY (DocNum, DocLine)
);

CREATE TABLE dbo.Items (
    ItmsGroupCode INT NOT NULL,
    ItemCode INT PRIMARY KEY
);

CREATE TABLE dbo.SalesPerson (
    SalesPersonCode INT PRIMARY KEY,
    SalesPersonName VARCHAR(50) NOT NULL
);
GO

-- =============================
-- הכנסת נתונים לטבלאות
-- =============================

-- mini_cost
INSERT INTO dbo.mini_cost VALUES
(1, 1, 50),
(2, 3, 20),
(3, 20, 2),
(4, 30, 4);

-- Items
INSERT INTO dbo.Items VALUES
(136,3620010),
(136,3611000),
(136,3611600),
(139,3614507),
(139,3620020),
(139,3614517),
(149,3611010),
(149,3613000);

-- SalesPerson
INSERT INTO dbo.SalesPerson VALUES
(172,'Golan'),
(120,'Elad'),
(100,'Meir'),
(174,'Ben'),
(-1,'WO');

-- SalesHeader
INSERT INTO dbo.SalesHeader VALUES
(61748,'2023-10-17',-33,172),
(544567,'2023-10-15',37,120),
(544566,'2023-10-15',-17,120),
(544565,'2023-10-15',-34,100),
(544564,'2023-10-15',2,100),
(544563,'2023-10-15',-3,100),
(544561,'2023-10-15',-7,100),
(544560,'2023-10-15',167,100),
(544559,'2023-10-15',19,100),
(544557,'2023-10-15',-15,100),
(544556,'2023-10-15',-38,172),
(61750,'2023-10-15',NULL,172),
(61749,'2023-10-15',17,172);

-- SalesLine (דוגמה חלקית)
INSERT INTO dbo.SalesLine VALUES
(61748,1,3620010,36240,86035.57),
(544567,1,3611000,25960,119520.88),
(544566,1,3611000,35500,163443.42),
(544565,1,3611600,1320,110880),
(544564,1,3611010,2600,15685.49),
(544563,1,3611010,2240,13513.65),
(544561,1,3611010,8720,41531.62),
(544561,2,3611010,9820,52617.03),
(544560,1,3611010,34150,166038.15),
(544559,1,3611010,34180,162792.5);
GO
