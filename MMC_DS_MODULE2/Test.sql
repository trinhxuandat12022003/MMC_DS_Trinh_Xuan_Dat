-- Question 1
CREATE TABLE CUSTOMER (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100),
    Phone VARCHAR(15),
    Email VARCHAR(100),
    Address VARCHAR(255),
    Note TEXT
);

CREATE TABLE CAR (
    CarID INT PRIMARY KEY,
    Maker ENUM('HONDA', 'TOYOTA', 'NISSAN'),
    Model VARCHAR(100),
    Year YEAR,
    Color VARCHAR(50),
    Note TEXT
);

CREATE TABLE `ORDER` (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT,
    CarID INT,
    Amount INT DEFAULT 1,
    SalePrice DECIMAL(10, 2),
    OrderDate DATE,
    DeliveryDate DATE,
    DeliveryAddress VARCHAR(255),
    Status INT DEFAULT 0,
    Note TEXT,
    FOREIGN KEY (CustomerID) REFERENCES CUSTOMER(CustomerID),
    FOREIGN KEY (CarID) REFERENCES CAR(CarID)
);

-- Thêm bản ghi vào bảng CUSTOMER
INSERT INTO CUSTOMER (Name, Phone, Email, Address, Note) VALUES
('Nguyen Van A', '0912345678', 'nguyenvana@example.com', '123 Main St', 'VIP Customer'),
('Le Thi B', '0987654321', 'lethib@example.com', '456 Second St', 'Regular Customer'),
('Tran Van C', '0909090909', 'tranvanc@example.com', '789 Third St', 'New Customer'),
('Pham Thi D', '0922334455', 'phamthid@example.com', '101 First St', 'Returning Customer'),
('Hoang Van E', '0944556677', 'hoangvane@example.com', '202 Fourth St', 'Frequent Buyer');

-- Thêm bản ghi vào bảng CAR
INSERT INTO CAR (CarID, Maker, Model, Year, Color, Note) VALUES
(1, 'HONDA', 'Civic', 2022, 'Black', 'New Model'),
(2, 'TOYOTA', 'Corolla', 2021, 'White', 'Popular Model'),
(3, 'NISSAN', 'Altima', 2022, 'Blue', 'Sporty Model'),
(4, 'HONDA', 'Accord', 2020, 'Red', 'Luxury Model'),
(5, 'TOYOTA', 'Camry', 2022, 'Silver', 'Comfortable Model');

-- Thêm bản ghi vào bảng ORDER
INSERT INTO `ORDER` (CustomerID, CarID, Amount, SalePrice, OrderDate, DeliveryDate, DeliveryAddress, Status, Note) VALUES
(1, 1, 2, 20000.00, '2023-01-01', '2023-01-16', '123 Nguyen Trai', 0, 'First Order'),
(2, 2, 1, 18000.00, '2023-02-01', '2023-02-16', '456 Au Co', 0, 'Second Order'),
(3, 3, 3, 15000.00, '2023-03-01', '2023-03-16', '789 Nguyen Hue', 1, 'Third Order'),
(4, 4, 1, 25000.00, '2023-04-01', '2023-04-16', '101 Dinh Tien Hoang', 1, 'Fourth Order'),
(5, 5, 2, 22000.00, '2023-05-01', '2023-05-16', '202 Ho Chi Minh', 2, 'Fifth Order');

-- Question 2
SELECT 
    c.Name, 
    SUM(o.Amount) AS TotalCarsPurchased
FROM 
    CUSTOMER c
JOIN 
    `ORDER` o ON c.CustomerID = o.CustomerID
GROUP BY 
    c.Name
ORDER BY 
    TotalCarsPurchased ASC;
    
-- Question 3
CREATE FUNCTION TopSellerThisYear()
RETURNS VARCHAR(100)
BEGIN
    DECLARE topMaker VARCHAR(100);

    SELECT c.Maker
    INTO topMaker
    FROM CAR c
    JOIN `ORDER` o ON c.CarID = o.CarID
    WHERE YEAR(o.OrderDate) = YEAR(CURDATE())
    GROUP BY c.Maker
    ORDER BY SUM(o.Amount) DESC
    LIMIT 1;
    
    RETURN topMaker;
END;


-- Question 4
CREATE PROCEDURE DeleteCancelledOrders();
BEGIN
    DECLARE deletedCount INT;
    
    DELETE FROM `ORDER`
    WHERE Status = 2 AND YEAR(OrderDate) < YEAR(CURDATE());
    
    SET deletedCount = ROW_COUNT();
    
    SELECT CONCAT('Deleted ', deletedCount, ' cancelled orders.');
END;

-- Question 5
CREATE PROCEDURE GetCustomerOrders(IN CustID INT)
BEGIN
    SELECT 
        c.Name AS CustomerName, 
        o.OrderID, 
        o.Amount, 
        car.Maker
    FROM 
        CUSTOMER c
    JOIN 
        `ORDER` o ON c.CustomerID = o.CustomerID
    JOIN 
        CAR car ON o.CarID = car.CarID
    WHERE 
        c.CustomerID = CustID;
END;

-- Question 6
CREATE TRIGGER check_delivery_date
BEFORE INSERT ON `ORDER`
FOR EACH ROW
BEGIN
    IF NEW.DeliveryDate < DATE_ADD(NEW.OrderDate, INTERVAL 15 DAY) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Delivery date must be at least 15 days after order date';
    END IF;
END;

