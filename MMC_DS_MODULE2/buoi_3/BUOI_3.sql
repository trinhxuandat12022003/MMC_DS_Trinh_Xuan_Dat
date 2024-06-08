USE testingsystem;
-- Q2
SELECT * FROM department;

-- Q3
SELECT DepartmentID FROM department WHERE DepartmentName = N'Sale';

-- Q4
SELECT * FROM `Account` WHERE LENGTH(Fullname) = (SELECT MAX(LENGTH(Fullname)) FROM `Account`) ORDER BY Fullname DESC;

-- Q5
WITH cte_dep3 AS (
    SELECT * FROM `Account` WHERE DepartmentID = 3
)
SELECT * FROM cte_dep3
WHERE LENGTH(Fullname) = (SELECT MAX(LENGTH(Fullname)) FROM cte_dep3)
ORDER BY Fullname ASC;

-- Q6
SELECT GroupName FROM `Group`
WHERE CreateDate < '2019-12-20';

-- q7
SELECT a.QuestionID, COUNT(a.QuestionID) AS SL 
FROM answer a 
GROUP BY a.QuestionID
HAVING COUNT(a.QuestionID) >= 4;

-- Q8
SELECT Code FROM Exam
WHERE Duration >= 60 AND CreateDate < '2019-12-20';

-- Q9
SELECT * FROM `Group`
ORDER BY CreateDate DESC
LIMIT 5;

-- Q10
SELECT DepartmentID, COUNT(AccountID) AS SL 
FROM `Account`
WHERE DepartmentID = 2
GROUP BY DepartmentID;

-- Q11
SELECT * FROM `Account`
WHERE Fullname LIKE 'D%o';

-- Q12
DELETE FROM Exam
WHERE CreateDate < '2019-12-20';

-- Q13
DELETE FROM `question`
WHERE Content LIKE 'câu hỏi%';

-- Q14
UPDATE `Account`
SET Fullname = N'Nguyễn Bá Lộc',
    Email = 'loc.nguyenba@vti.com.vn'
WHERE AccountID = 5;

-- Q15
UPDATE `GroupAccount`
SET GroupID = 4
WHERE AccountID = 5;

