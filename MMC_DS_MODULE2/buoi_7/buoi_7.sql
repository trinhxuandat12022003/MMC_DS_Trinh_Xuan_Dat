USE testingsystem;

-- Question 1
DELIMITER $$
CREATE TRIGGER trg_CheckGroupCreateDate
BEFORE INSERT ON `group`
FOR EACH ROW
BEGIN
    IF NEW.CreateDate < DATE_SUB(CURDATE(), INTERVAL 1 YEAR) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Không thể tạo Group có ngày tạo trước 1 năm!';
    END IF;
END$$
DELIMITER ;

-- Question 2
DELIMITER $$
CREATE TRIGGER trg_PreventAddingUserToSaleDepartment
BEFORE INSERT ON `account`
FOR EACH ROW
BEGIN
    IF NEW.DepartmentID = (SELECT DepartmentID FROM `department` WHERE DepartmentName = 'Sale') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Department "Sale" cannot add more user';
    END IF;
END$$
DELIMITER ;

-- Test trigger
-- INSERT INTO `account` (Email, Username, FullName, DepartmentID, PositionID, CreateDate)
-- VALUES ('test@gmail.com', 'test', 'Test User', (SELECT DepartmentID FROM `department` WHERE DepartmentName = 'Sale'), 1, NOW());

-- Question 3
DELIMITER $$
CREATE TRIGGER trg_LimitUsersPerGroup
BEFORE INSERT ON groupaccount
FOR EACH ROW
BEGIN
    DECLARE var_CountGroupID INT;
    SELECT COUNT(*) INTO var_CountGroupID FROM groupaccount WHERE GroupID = NEW.GroupID;
    IF var_CountGroupID >= 5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Mỗi group chỉ được thêm tối đa 5 user';
    END IF;
END$$
DELIMITER ;

-- Question 4
DELIMITER $$
CREATE TRIGGER trg_LimitQuestionsPerExam
BEFORE INSERT ON examquestion
FOR EACH ROW
BEGIN
    DECLARE var_CountExamID INT;
    SELECT COUNT(*) INTO var_CountExamID FROM examquestion WHERE ExamID = NEW.ExamID;
    IF var_CountExamID >= 10 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Mỗi bài thi chỉ được thêm tối đa 10 câu hỏi';
    END IF;
END$$
DELIMITER ;

-- Question 5
DELIMITER $$
CREATE TRIGGER trg_PreventDeletingAdminAccount
BEFORE DELETE ON `account`
FOR EACH ROW
BEGIN
    IF OLD.Email = 'admin@gmail.com' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Không thể xóa tài khoản admin!';
    ELSE
        -- Xóa thông tin liên quan đến user
        DELETE FROM groupaccount WHERE AccountID = OLD.AccountID;
        -- Thêm các bảng liên quan khác nếu cần
    END IF;
END$$
DELIMITER ;

-- Question 6
DELIMITER $$
CREATE TRIGGER trg_AssignDefaultDepartment
BEFORE INSERT ON `account`
FOR EACH ROW
BEGIN
    IF NEW.DepartmentID IS NULL THEN
        SET NEW.DepartmentID = (SELECT DepartmentID FROM `department` WHERE DepartmentName = 'waiting Department');
    END IF;
END$$
DELIMITER ;

-- Question 7
DELIMITER $$
CREATE TRIGGER trg_LimitAnswersPerQuestion
BEFORE INSERT ON `answer`
FOR EACH ROW
BEGIN
    DECLARE var_CountAnswer INT;
    DECLARE var_CountCorrectAnswer INT;

    SELECT COUNT(*), SUM(CASE WHEN isCorrect = 1 THEN 1 ELSE 0 END) 
    INTO var_CountAnswer, var_CountCorrectAnswer 
    FROM `answer` 
    WHERE QuestionID = NEW.QuestionID;

    IF var_CountAnswer >= 4 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Mỗi câu hỏi chỉ được thêm tối đa 4 câu trả lời';
    END IF;

    IF var_CountCorrectAnswer >= 2 AND NEW.isCorrect = 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Mỗi câu hỏi chỉ được có tối đa 2 đáp án đúng';
    END IF;
END$$
DELIMITER ;

-- Question 8
DELIMITER $$
CREATE TRIGGER trg_StandardizeGender
BEFORE INSERT ON `account`
FOR EACH ROW
BEGIN
    CASE NEW.Gender
        WHEN 'nam' THEN SET NEW.Gender = 'M';
        WHEN 'nữ' THEN SET NEW.Gender = 'F';
        WHEN 'chưa xác định' THEN SET NEW.Gender = 'U';
        ELSE SET NEW.Gender = 'U'; -- Giá trị mặc định nếu không thuộc 3 trường hợp trên
    END CASE;
END$$
DELIMITER ;

-- Question 9
DELIMITER $$
CREATE TRIGGER trg_PreventDeletingRecentExam
BEFORE DELETE ON `exam`
FOR EACH ROW
BEGIN
    IF OLD.CreateDate >= DATE_SUB(CURDATE(), INTERVAL 2 DAY) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cant Delete This Exam!!';
    END IF;
END$$
DELIMITER ;

-- Question 10
DELIMITER $$
CREATE TRIGGER trg_PreventModifyingUsedQuestion
BEFORE UPDATE ON `question`
FOR EACH ROW
BEGIN
    DECLARE v_CountQuesByID INT DEFAULT -1;
    SELECT COUNT(1) INTO v_CountQuesByID
    FROM examquestion
    WHERE QuestionID = OLD.QuestionID;

    IF v_CountQuesByID > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Question is used in exam. Cannot update!';
    END IF;
END $$
DELIMITER ;

-- Trigger cho DELETE
DELIMITER $$
CREATE TRIGGER trg_PreventDeletingUsedQuestion
BEFORE DELETE ON `question`
FOR EACH ROW
BEGIN
    DECLARE v_CountQuesByID INT DEFAULT -1;
    SELECT COUNT(1) INTO v_CountQuesByID
    FROM examquestion
    WHERE QuestionID = OLD.QuestionID;

    IF v_CountQuesByID > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Question is used in exam. Cannot delete!';
    END IF;
END $$
DELIMITER ;

-- Question 12
SELECT ExamID,
       CASE 
           WHEN Duration <= 30 THEN 'Short time'
           WHEN Duration > 30 AND Duration <= 60 THEN 'Medium time'
           ELSE 'Long time'
       END AS DurationDescription
FROM `exam`;

-- Question 13
SELECT g.GroupName, 
       COUNT(ga.AccountID) AS UserCount,
       CASE 
           WHEN COUNT(ga.AccountID) <= 5 THEN 'few'
           WHEN COUNT(ga.AccountID) > 5 AND COUNT(ga.AccountID) <= 20 THEN 'normal'
           ELSE 'higher'
       END AS the_number_user_amount
FROM `group` g
LEFT JOIN groupaccount ga ON g.GroupID = ga.GroupID
GROUP BY g.GroupName;

-- Question 14
SELECT d.DepartmentName, 
       CASE 
           WHEN COUNT(a.AccountID) > 0 THEN COUNT(a.AccountID) 
           ELSE 'Không có User' 
       END AS UserCount
FROM `department` d
LEFT JOIN `account` a ON d.DepartmentID = a.DepartmentID
GROUP BY d.DepartmentName;