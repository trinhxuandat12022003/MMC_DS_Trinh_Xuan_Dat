USE testingsystem;

-- Question 1
DELIMITER $$
CREATE PROCEDURE sp_GetAccountsByDepartmentName(IN departmentName VARCHAR(50))
BEGIN
    SELECT a.Email, a.Username
    FROM `account` a
    JOIN `department` d ON a.DepartmentID = d.DepartmentID
    WHERE d.DepartmentName = departmentName;
END$$
DELIMITER ;

-- Question 2
DELIMITER $$
CREATE PROCEDURE sp_GetAccountCountByGroup()
BEGIN
    SELECT g.GroupName, COUNT(ga.AccountID) AS AccountCount
    FROM `group` g
    LEFT JOIN groupaccount ga ON g.GroupID = ga.GroupID
    GROUP BY g.GroupName;
END$$
DELIMITER ;

-- Question 3
DELIMITER $$
CREATE PROCEDURE sp_GetQuestionCountByTypeInCurrentMonth()
BEGIN
    SELECT t.TypeName, COUNT(q.QuestionID) AS QuestionCount
    FROM `typequestion` t
    LEFT JOIN `question` q ON t.TypeID = q.TypeID
    WHERE MONTH(q.CreateDate) = MONTH(CURDATE())
    GROUP BY t.TypeName;
END$$
DELIMITER ;

-- Question 4
DELIMITER $$
CREATE PROCEDURE sp_GetTypeQuestionWithMostQuestions(OUT typeID INT)
BEGIN
    WITH QuestionCountByType AS (
        SELECT TypeID, COUNT(*) AS QuestionCount
        FROM `question`
        GROUP BY TypeID
    )
    SELECT TypeID INTO typeID 
    FROM QuestionCountByType
    ORDER BY QuestionCount DESC
    LIMIT 1;
END$$
DELIMITER ;

-- Question 5
DELIMITER $$
CREATE PROCEDURE sp_GetNameOfTypeQuestionWithMostQuestions()
BEGIN
    DECLARE mostPopularTypeID INT;
    CALL sp_GetTypeQuestionWithMostQuestions(mostPopularTypeID);

    SELECT TypeName 
    FROM `typequestion` 
    WHERE TypeID = mostPopularTypeID;
END$$
DELIMITER ;

-- Question 6
DELIMITER $$
CREATE PROCEDURE sp_SearchGroupOrUser(IN searchString VARCHAR(255))
BEGIN
    SELECT GroupName AS Result
    FROM `group`
    WHERE GroupName LIKE CONCAT('%', searchString, '%')
    UNION
    SELECT Username AS Result
    FROM `account`
    WHERE Username LIKE CONCAT('%', searchString, '%');
END$$
DELIMITER ;

-- Question 7
DELIMITER $$
CREATE PROCEDURE sp_CreateAccount(IN fullName VARCHAR(255), IN email VARCHAR(255))
BEGIN
    DECLARE username VARCHAR(255);
    DECLARE positionID TINYINT UNSIGNED;
    DECLARE departmentID TINYINT UNSIGNED;

    SET username = SUBSTRING_INDEX(email, '@', 1);
    SET positionID = (SELECT PositionID FROM `position` WHERE PositionName = 'Dev');
    SET departmentID = (SELECT DepartmentID FROM `department` WHERE DepartmentName = 'Phòng chờ');

    INSERT INTO `account` (Email, Username, FullName, DepartmentID, PositionID, CreateDate)
    VALUES (email, username, fullName, departmentID, positionID, NOW());

    SELECT 'Tạo tài khoản thành công!';
END$$
DELIMITER ;

-- Question 8
DELIMITER $$
CREATE PROCEDURE sp_GetLongestQuestionByType(IN var_Choice VARCHAR(255))
BEGIN
    DECLARE v_TypeID TINYINT UNSIGNED;
    
    SELECT TypeID INTO v_TypeID 
    FROM `typequestion` 
    WHERE TypeName = var_Choice;

    SELECT QuestionID, Content, length(Content) AS ContentLength
    FROM `question`
    WHERE TypeID = v_TypeID
    ORDER BY ContentLength DESC
    LIMIT 1;
END$$
DELIMITER ;

-- Question 9
DELIMITER $$
CREATE PROCEDURE sp_DeleteExamWithID(IN examID TINYINT UNSIGNED)
BEGIN
    DELETE FROM `examquestion` WHERE ExamID = examID;
    DELETE FROM `exam` WHERE ExamID = examID;
END$$
DELIMITER ;

-- Question 10
DELIMITER $$
CREATE PROCEDURE SP_DeleteExamBefore3Year()
BEGIN
    -- Khai báo biến sử dụng trong chương trình  
    DECLARE v_ExamID TINYINT UNSIGNED;
    DECLARE v_CountExam TINYINT UNSIGNED DEFAULT 0;
    DECLARE v_CountExamquestion TINYINT UNSIGNED DEFAULT 0;
    DECLARE i TINYINT UNSIGNED DEFAULT 1;
    DECLARE v_print_Del_info_Exam VARCHAR(50) ;

    -- Tạo bảng tạm
    DROP TABLE IF EXISTS ExamIDBefore3Year_Temp;
    CREATE TABLE ExamIDBefore3Year_Temp(
        ID INT PRIMARY KEY AUTO_INCREMENT,
        ExamID INT
    );

    -- Insert dữ liệu bảng tạm
    INSERT INTO ExamIDBefore3Year_Temp(ExamID)
    SELECT ExamID 
    FROM `exam` 
    WHERE YEAR(CreateDate) <= YEAR(CURDATE()) - 3;

    -- Lấy số lượng số Exam và ExamQuestion cần xóa.
    SELECT count(1) INTO v_CountExam FROM ExamIDBefore3Year_Temp;        
    SELECT count(1) INTO v_CountExamquestion FROM examquestion ex
    INNER JOIN ExamIDBefore3Year_Temp et ON ex.ExamID = et.ExamID;


    -- Thực hiện xóa trên bảng Exam và ExamQuestion sử dụng Procedure đã tạo ở Question9 bên trên
    WHILE (i <= v_CountExam) DO
        SELECT ExamID INTO v_ExamID FROM ExamIDBefore3Year_Temp WHERE ID=i;
        CALL sp_DeleteExamWithID(v_ExamID);
        SET i = i +1;
    END WHILE;

    -- In câu thông báo
    SELECT CONCAT("DELETE ",v_CountExam," IN Exam AND ", v_CountExamquestion ," IN ExamQuestion") INTO v_print_Del_info_Exam;
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = v_print_Del_info_Exam ;

    -- Xóa bảng tạm sau khi hoàn thành
    DROP TABLE IF EXISTS ExamIDBefore3Year_Temp; 
END$$
DELIMITER ;

-- Run Procedure
CALL SP_DeleteExamBefore3Year();

-- Question 11
DELIMITER $$
CREATE PROCEDURE sp_DeleteDepartmentAndMoveAccounts(IN departmentName VARCHAR(255))
BEGIN
    DECLARE defaultDepartmentID TINYINT UNSIGNED;
    
    SELECT DepartmentID INTO defaultDepartmentID 
    FROM `department` 
    WHERE DepartmentName = 'Phòng chờ';

    UPDATE `account` 
    SET DepartmentID = defaultDepartmentID 
    WHERE DepartmentID = (SELECT DepartmentID FROM `department` WHERE DepartmentName = departmentName);

    DELETE FROM `department` WHERE DepartmentName = departmentName;
END$$
DELIMITER ;

-- Question 12
DELIMITER $$
CREATE PROCEDURE sp_GetQuestionCountByMonthInCurrentYear()
BEGIN
    WITH CTE_12Months AS (
        SELECT 1 AS MonthNumber UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
        UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 
        UNION SELECT 11 UNION SELECT 12
    )
    SELECT M.MonthNumber, COUNT(Q.QuestionID) AS QuestionCount
    FROM CTE_12Months M
    LEFT JOIN `question` Q ON M.MonthNumber = MONTH(Q.CreateDate) AND YEAR(Q.CreateDate) = YEAR(CURDATE())
    GROUP BY M.MonthNumber
    ORDER BY M.MonthNumber;
END$$
DELIMITER ;

-- Question 13
DELIMITER $$
CREATE PROCEDURE sp_GetQuestionCountByMonthInLast6Months()
BEGIN
    WITH CTE_6Months AS (
        SELECT MONTH(CURDATE()) AS MonthNumber
        UNION SELECT MONTH(DATE_SUB(CURDATE(), INTERVAL 1 MONTH))
        UNION SELECT MONTH(DATE_SUB(CURDATE(), INTERVAL 2 MONTH))
        UNION SELECT MONTH(DATE_SUB(CURDATE(), INTERVAL 3 MONTH))
        UNION SELECT MONTH(DATE_SUB(CURDATE(), INTERVAL 4 MONTH))
        UNION SELECT MONTH(DATE_SUB(CURDATE(), INTERVAL 5 MONTH))
    )
    SELECT M.MonthNumber, 
           CASE WHEN COUNT(Q.QuestionID) > 0 THEN COUNT(Q.QuestionID) 
                ELSE 'không có câu hỏi nào trong tháng' END AS QuestionCount
    FROM CTE_6Months M
    LEFT JOIN `question` Q ON M.MonthNumber = MONTH(Q.CreateDate) AND Q.CreateDate >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
    GROUP BY M.MonthNumber
    ORDER BY M.MonthNumber;
END$$
DELIMITER ;

-- BONUS THÊM VỀ FUNCTION:
-- 1. Nhập vào DepartmentID sau đó sử dụng function để in ra DepartmentName
DELIMITER $$
CREATE FUNCTION fn_GetDepartmentName(departmentID TINYINT UNSIGNED)
RETURNS VARCHAR(255)
BEGIN
    DECLARE departmentName VARCHAR(255);
    
    SELECT DepartmentName INTO departmentName 
    FROM `department` 
    WHERE DepartmentID = departmentID;

    RETURN departmentName;
END$$
DELIMITER ;