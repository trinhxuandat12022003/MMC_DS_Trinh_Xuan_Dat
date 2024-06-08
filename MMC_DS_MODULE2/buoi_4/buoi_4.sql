USE testingsystem;

-- Q1
SELECT A.Email, A.Username, A.FullName, D.DepartmentName
FROM `Account` A
INNER JOIN Department D ON A.DepartmentID = D.DepartmentID;

-- Q2
SELECT * FROM `Account`
WHERE CreateDate > '2010-12-20';

-- Q3
SELECT A.FullName, A.Email, P.PositionName
FROM `Account` A
INNER JOIN Position P ON A.PositionID = P.PositionID
WHERE P.PositionName = 'Dev';

-- Q4
SELECT D.DepartmentName, COUNT(A.DepartmentID) AS SL
FROM Account A
INNER JOIN Department D ON A.DepartmentID = D.DepartmentID
GROUP BY A.DepartmentID
HAVING COUNT(A.DepartmentID) > 3;

-- Q5
SELECT E.QuestionID, Q.Content
FROM ExamQuestion E
INNER JOIN Question Q ON Q.QuestionID = E.QuestionID
GROUP BY E.QuestionID
HAVING COUNT(E.QuestionID) = (
    SELECT MAX(countQues) AS maxcountQues 
    FROM (
        SELECT COUNT(E.QuestionID) AS countQues 
        FROM ExamQuestion E
        GROUP BY E.QuestionID
    ) AS countTable
);

-- Q6
SELECT cq.CategoryID, cq.CategoryName, COUNT(q.CategoryID)
FROM CategoryQuestion cq
JOIN Question q ON cq.CategoryID = q.CategoryID
GROUP BY q.CategoryID;

-- Q7
SELECT q.QuestionID, q.Content, COUNT(eq.QuestionID)
FROM Question q
RIGHT JOIN ExamQuestion eq ON q.QuestionID = eq.QuestionID
GROUP BY q.QuestionID;

-- Q8
SELECT Q.QuestionID, Q.Content, COUNT(A.QuestionID)
FROM Answer A
INNER JOIN Question Q ON Q.QuestionID = A.QuestionID
GROUP BY A.QuestionID
HAVING COUNT(A.QuestionID) = (
    SELECT MAX(countQues)
    FROM (
        SELECT COUNT(B.QuestionID) AS countQues
        FROM Answer B
        GROUP BY B.QuestionID
    ) AS countAnsw
);

-- Q9
SELECT G.GroupID, COUNT(GA.AccountID) AS 'SO LUONG'
FROM GroupAccount GA
JOIN `Group` G ON GA.GroupID = G.GroupID
GROUP BY G.GroupID
ORDER BY G.GroupID ASC;

-- Q10
SELECT P.PositionID, P.PositionName, COUNT(A.PositionID) AS SL
FROM Account A
INNER JOIN Position P ON A.PositionID = P.PositionID
GROUP BY A.PositionID
HAVING COUNT(A.PositionID) = (
    SELECT MIN(minP)
    FROM (
        SELECT COUNT(B.PositionID) AS minP
        FROM Account B
        GROUP BY B.PositionID
    ) AS minPA
);

-- Q11
SELECT d.DepartmentID, d.DepartmentName, p.PositionName, COUNT(p.PositionName)
FROM Account a
INNER JOIN Department d ON a.DepartmentID = d.DepartmentID
INNER JOIN Position p ON a.PositionID = p.PositionID
GROUP BY d.DepartmentID, p.PositionID;

-- Q12
SELECT Q.QuestionID, Q.Content, A.FullName AS Author, TQ.TypeName, ANS.Content AS Answer
FROM Question Q
INNER JOIN CategoryQuestion CQ ON Q.CategoryID = CQ.CategoryID
INNER JOIN TypeQuestion TQ ON Q.TypeID = TQ.TypeID
INNER JOIN Account A ON A.AccountID = Q.CreatorID
INNER JOIN Answer ANS ON Q.QuestionID = ANS.QuestionID
ORDER BY Q.QuestionID ASC;

-- Q13
SELECT TQ.TypeID, TQ.TypeName, COUNT(Q.TypeID) AS SL
FROM Question Q
INNER JOIN TypeQuestion TQ ON Q.TypeID = TQ.TypeID
GROUP BY Q.TypeID;

-- Q14
SELECT * FROM `Group` g
LEFT JOIN GroupAccount ga ON g.GroupID = ga.GroupID
WHERE ga.AccountID IS NULL;

-- Q15
SELECT * FROM GroupAccount ga
RIGHT JOIN `Group` g ON ga.GroupID = g.GroupID
WHERE ga.AccountID IS NULL;

-- Q16
SELECT * FROM Question
WHERE QuestionID NOT IN (SELECT QuestionID FROM Answer);

SELECT q.QuestionID
FROM Answer a
RIGHT JOIN Question q ON a.QuestionID = q.QuestionID
WHERE a.AnswerID IS NULL;

-- Q17
SELECT A.FullName 
FROM `Account` A
JOIN GroupAccount GA ON A.AccountID = GA.AccountID 
WHERE GA.GroupID = 1

UNION

SELECT A.FullName 
FROM `Account` A
JOIN GroupAccount GA ON A.AccountID = GA.AccountID 
WHERE GA.GroupID = 2;

-- Q18
SELECT g.GroupName, COUNT(ga.GroupID) AS SL 
FROM GroupAccount ga
JOIN `Group` g ON ga.GroupID = g.GroupID 
GROUP BY g.GroupID 
HAVING COUNT(ga.GroupID) > 5

UNION

SELECT g.GroupName, COUNT(ga.GroupID) AS SL 
FROM GroupAccount ga
JOIN `Group` g ON ga.GroupID = g.GroupID 
GROUP BY g.GroupID 
HAVING COUNT(ga.GroupID) < 7;
