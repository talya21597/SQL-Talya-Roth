# פרוקיט SQL - בדיקה מקדימה לחברת Logical

## סקירה כללית
פרוקיט זה כולל פתרונות SQL מקצועיים המכסים נושאים מתקדמים של שפת SQL Server, כמו שנדרש לבדיקה בחברת Logical.

**שם המועמד:** טליה רות (Talya Roth)
**מספר זהות:** 215970450

## מבנה הפרוקיט

### קובצי ההגשה
```
createDb.sql     - יצירת מסד הנתונים וטבלאות היסוד
part1.sql        - חלק א: שאילתות על מערכת מכירות
part2.sql        - חלק ב: ניתוח גישה למידע בחלק ריבוי משתמשים
part3.sql        - חלק ג: קומבינציות של שלושה ערכים
part4.sql        - חלק ד: פונקציה MyReverse מותאמת אישית
part5.sql        - חלק ה: עמודה KOTERET עם Window Functions
```

---

## חלק א - שאילתות על מערכת מכירות

מסד הנתונים מכיל מערכת מידע של חברה מסחרית עם הטבלאות הבאות:
- **SalesHeader**: כותרות של חשבוניות
- **SalesLine**: שורות של חשבוניות (פריטים)
- **Items**: קטלוג פריטים
- **SalesPerson**: אנשי מכירות

### 7 שאילתות (part1.sql):

1. **כמות, סכום מכירות וחשבוניות לכל פריט**
   - מציגה את הכמות הכוללת, סכום המכירות לאחר הנחה, וכמות החשבוניות לכל פריט

2. **חשבוניות עם פריטים ספציפיים**
   - מציגה מספרי חשבוניות שבהן קיימים הן פריט 3611010 והן פריט 3611600
   - שימוש ב-INTERSECT

3. **אנשי מכירות שמכרו את כלל הפריטים**
   - זיהוי איש מכירות שמכר את כל הפריטים בקטלוג
   - שימוש ב-CTE ו-Window Functions

4. **פריטים עם יוצרי תבחין**
   - פריטים שנמכרו אצל איש המכירות עם המגוון הגדול ביותר
   - ו/או אצל איש המכירות עם הכמות הגדולה ביותר
   - אבל לא אצל איש עם המגוון הקטן ביותר
   - שימוש ב-INTERSECT ו-EXCEPT

5. **פריטים מתחת לממוצע**
   - מציגה פריטים שנמכרו בכמות נמוכה מהממוצע של אותו איש מכירות
   - שימוש ב-CTE ו-Window Functions

6. **אנשי מכירות עם 88% מהמכירות**
   - זיהוי איש/ים המכירות בעלי תרומה של 88% מסך הכמות הנמכרת
   - הצגה בחלוקה לפי חשבוניות, ממוינים לפי כמות ותאריך

7. **סכום וממוצע מכירות לאיש מכירות**
   - סכום המכירות הכולל לאיש מכירות
   - ממוצע המכירות לכל חשבונית
   - שימוש בתת-שאילתה ב-SELECT

---

## חלק ב - ניתוח גישה למידע במערכת ריבוי משתמשים

טבלת **Requests** מכילה בקשות גישה למסמכים עם השדות:
- RequestID, UserID, DocumentID, RequestTime, ResponseTime, Priority, ExpirationTime

### 3 בעיות עמוקות (part2.sql):

#### בעיה א - זיהוי משתמשים תובעניים
משתמש תובעני = משתמש ששלח יותר מ-10 בקשות בחלון זמן של 5 דקות.

**גישה:**
1. CROSS APPLY לחישוב מספר בקשות בכל חלון זמן של 5 דקות
2. MAX לכל משתמש
3. סינון המשתמשים עם יותר מ-10 בקשות
4. בחירת המשתמש/ים עם הערך הגבוה ביותר

#### בעיה ב - מקסום טיפול בבקשות דחופות
בחירת רצף בקשות אופטימלי לטיפול עם סכום עדיפות מקסימלי תוך שמירה על אילוצים זמן.

**גישה (Dynamic Programming):**
1. סינון בקשות חוקיות (ResponseTime ≤ ExpirationTime)
2. מיון לפי ResponseTime
3. עבור כל בקשה, חישוב הבקשה האחרונה שאינה חופפת בזמן
4. DP רקורסיבי לחישוב סכום העדיפויות המקסימלי

#### בעיה ג - זיהוי צווארי בקבוק
מציאת פרק הזמן עם זמן המתנה ממוצע הגבוה ביותר.

**גישה:**
1. חישוב זמן המתנה לכל בקשה (ResponseTime - RequestTime)
2. ווקטוריזציה לפרקי זמן קבועים (5 דקות)
3. חישוב ממוצע זמן המתנה לכל פרק
4. בחירת הפרק עם הממוצע הגבוה ביותר

---

## חלק ג - קומבינציות של שלושה ערכים

טבלת **A** מכילה עמודה אחת (INT) עם ערכים שונים, חיוביים ושליליים.

### 3 סעיפים (part3.sql):

#### סעיף א - קומבינציות עם חשיבות לסדר
מציאת כל הקומבינציות של 3 ערכים שונים שסכומם = X, כאשר כל סידור נחשב לתוצאה נפרדת.

**דוגמה:** X=32
```
2, 6, 24
2, 24, 6
6, 2, 24
... וכו'
```

#### סעיף ב - קומבינציות ללא חשיבות לסדר
קומבינציות ללא חשיבות לסדר, כך שכל קומבינציה מופיעה פעם אחת בלבד.

**דוגמה:** X=32
```
2, 6, 24
```

**גישה:**
- שימוש ב-INNER JOIN עם תנאי `a2.val > a1.val` ו-`a3.val > a2.val`
- זה מגביל את הסדר ומונע כפילויות

#### סעיף ג - קומבינציה עם המכפלה הגדולה ביותר
מציאת הקומבינציה עם המכפלה של שלושת הערכים הגדולה ביותר.

**גישה:**
1. שמירת תוצאות סעיף ב' בטבלה זמנית
2. חישוב המכפלה לכל שורה
3. בחירת השורה/ות עם המכפלה הגדולה ביותר

---

## חלק ד - פונקציה MyReverse

יצירת פונקציה ב-SQL Server המהופכת מחרוזת ללא שימוש בפונקציה REVERSE המקורית.

### הגישה:
```sql
CREATE FUNCTION dbo.MyReverse (@str NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
```

**לולאה:**
1. התחל מהתו האחרון (LENGTH של המחרוזת)
2. עבור כל תו מהסוף להתחלה
3. הוסף את התו לתוצאה

**שימוש בפונקציה:**
```sql
SELECT dbo.MyReverse('ABCDEF') AS ReversedString;  -- תוצאה: FEDCBA
```

---

## חלק ה - עמודה KOTERET עם Window Functions

טבלת **T** מכילה שדות:
- **SHURA**: מספר סדר
- **TEUR**: ערך (יכול להיות NULL)

### המטרה:
הוספת עמודה **KOTERET** שמכילה הערך הראשון של כל קבוצה.

**הגדרת קבוצה:**
- שורה ראשונה של הטבלה
- או שורה שבה הערך הקודם ב-TEUR היה NULL

### הגישה (Window Functions):

1. **זיהוי תחילת קבוצה:**
   ```sql
   LAG(TEUR) OVER (ORDER BY SHURA) IS NULL AND TEUR IS NOT NULL
   ```
   
2. **מספור קבוצות:**
   ```sql
   SUM(...) OVER (ORDER BY SHURA)
   ```
   
3. **הוספת ערך ראשון לכל קבוצה:**
   ```sql
   FIRST_VALUE(TEUR) OVER (PARTITION BY grp ORDER BY SHURA)
   ```

---

## נושאים שנעבדו

✓ JOIN (INNER, LEFT, CROSS)
✓ משפטי WHERE עם לוגיקה מורכבת
✓ חישובים אגרגטיביים (SUM, COUNT, AVG)
✓ GROUP BY ו-HAVING
✓ DISTINCT
✓ UNION, UNION ALL, INTERSECT, EXCEPT
✓ תת-שאילתות (FROM, WHERE, SELECT)
✓ Window Functions (LAG, FIRST_VALUE, SUM OVER, PARTITION BY, ORDER BY)
✓ CTE (WITH clauses) - רגיל ורקורסיבי
✓ Dynamic Programming ב-SQL
✓ פונקציות מותאמות אישית (CREATE FUNCTION)

---

## הוראות הרצה

1. הרץ את `createDb.sql` ראשון לייצור מסד הנתונים
2. הרץ כל חלק בנפרד:
   - `part1.sql` - שאילתות מכירות
   - `part2.sql` - ניתוח בקשות
   - `part3.sql` - קומבינציות
   - `part4.sql` - פונקציה MyReverse
   - `part5.sql` - Window Functions

---

## הערות חשובות

- **חלק א**: סכום המכירות מחושב **לאחר הנחה**
- **חלק ב**: כל בעיה יכולה לרוץ בנפרד - אין תלות בין הבעיות
- **חלק ג**: יש ליצור את טבלה A בנפרד עם נתונים לבדיקה
- **חלק ד**: הפונקציה MyReverse מטפלת במחרוזות עם NULL
- **חלק ה**: ה-Window Functions מוצאים קבוצות כל פעם שיש NULL בערך הקודם

---

## תכונות כלליות

- קוד תואם **SQL Server 2016+**
- שימוש ב-**GO** לחלוקת batches
- **Comments בעברית** להסבר קוד
- **Error handling** עם DROP TABLE IF EXISTS
- **Performance optimization** עם Index-friendly queries

---

## הוראות Git & GitHub

### שם ה-Repository המומלץ:
```
SQL-Logical-Interview-Talya-Roth
```

### צעדים להעלאה ל-GitHub:

1. **יצור repository חדש על GitHub:**
   - כנס ל-https://github.com/new
   - שם: `SQL-Logical-Interview-Talya-Roth`
   - תיאור: `SQL Server Interview Assignment for Logical Ltd`
   - בחר Private (אם זה רק שלך)

2. **ב-PowerShell, בתיקייה של הפרוקט:**
   ```powershell
   git init
   git add .
   git commit -m "Initial commit: SQL Interview Project for Logical"
   git branch -M main
   git remote add origin https://github.com/YOUR_USERNAME/SQL-Logical-Interview-Talya-Roth.git
   git push -u origin main
   ```

3. **אם כבר יש repository:**
   ```powershell
   git status
   git add .
   git commit -m "Update: Complete SQL Interview Assignment"
   git push
   ```

### קבצים בـ Repository:
```
SQL-Logical-Interview-Talya-Roth/
├── createDb.sql          # יצירת מסד הנתונים
├── part1.sql             # חלק א (7 שאילתות)
├── part2.sql             # חלק ב (3 בעיות)
├── part3.sql             # חלק ג (קומבינציות)
├── part4.sql             # חלק ד (MyReverse)
├── part5.sql             # חלק ה (KOTERET)
├── README.md             # תיעוד מלא
└── .gitignore            # קבצים להתעלמות
```

---

## מידע נוסף

פרוקיט זה משלב טכניקות SQL מתקדמות ופתרונות אלגוריתמיים מורכבים כמו:
- Dynamic Programming לאופטימיזציה
- Window Functions ללוגיקה סדרתית
- Recursive CTEs למעבר חוזר
- Set Operations להשוואת קבוצות נתונים

טליה רות | 215970450
