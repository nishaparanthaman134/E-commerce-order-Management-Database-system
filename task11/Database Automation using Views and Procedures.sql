
USE inventory_db;

-- 1. CUSTOMER ORDER REPORT (VIEW)

CREATE OR REPLACE VIEW Customer_Order_Report AS
SELECT
    c.Customer_Name,
    o.Order_ID,
    o.Order_Date,
    o.Total_Amount,
    o.Order_Status
FROM Customers c
JOIN Orders o
ON c.Customer_ID = o.Customer_ID;


-- 2. PRODUCT SALES REPORT (VIEW)

CREATE OR REPLACE VIEW Product_Sales_Report AS
SELECT
    p.Product_Name,
    SUM(od.Quantity) AS Quantity_Sold,
    SUM(od.Quantity * p.Price) AS Total_Revenue
FROM Products p
JOIN Order_Details od
ON p.Product_ID = od.Product_ID
GROUP BY p.Product_ID, p.Product_Name;


-- 3. PAYMENT STATUS REPORT (VIEW)

CREATE OR REPLACE VIEW Payment_Status_Report AS
SELECT
    Order_ID,
    Payment_Mode,
    Payment_Status
FROM Payment;


-- 4. UPDATE ORDER STATUS (PROCEDURE)

DROP PROCEDURE IF EXISTS UpdateOrderStatus;

DELIMITER //

CREATE PROCEDURE UpdateOrderStatus(
    IN OrderID INT,
    IN NewStatus VARCHAR(50)
)
BEGIN
    UPDATE Orders
    SET Order_Status = NewStatus
    WHERE Order_ID = OrderID;
END //

DELIMITER ;


-- 5. ADD NEW CUSTOMER ORDER (PROCEDURE)

DROP PROCEDURE IF EXISTS AddNewCustomerOrder;

DELIMITER //

CREATE PROCEDURE AddNewCustomerOrder(
    IN p_Customer_ID INT,
    IN p_Product_ID INT,
    IN p_Quantity INT
)
BEGIN
    DECLARE v_Price DECIMAL(10,2);
    DECLARE v_Order_ID INT;

    IF p_Quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid Quantity';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM Customers
        WHERE Customer_ID = p_Customer_ID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid Customer ID';
    END IF;

    SELECT Price INTO v_Price
    FROM Products
    WHERE Product_ID = p_Product_ID;

    IF v_Price IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid Product ID';
    END IF;

    INSERT INTO Orders
    (Customer_ID, Order_Date, Total_Amount, Order_Status)
    VALUES
    (p_Customer_ID, CURDATE(),
     v_Price * p_Quantity, 'Pending');

    SET v_Order_ID = LAST_INSERT_ID();

    INSERT INTO Order_Details
    (Order_ID, Product_ID, Quantity)
    VALUES
    (v_Order_ID, p_Product_ID, p_Quantity);

END //

DELIMITER ;


-- 6. CUSTOMER PURCHASE HISTORY (PROCEDURE)

DROP PROCEDURE IF EXISTS GetCustomerPurchaseHistory;

DELIMITER //

CREATE PROCEDURE GetCustomerPurchaseHistory(
    IN Cust_ID INT
)
BEGIN
    SELECT
        o.Order_ID,
        o.Order_Date,
        p.Product_Name,
        od.Quantity,
        o.Total_Amount AS Purchase_Amount,
        o.Order_Status
    FROM Orders o
    JOIN Order_Details od
    ON o.Order_ID = od.Order_ID
    JOIN Products p
    ON od.Product_ID = p.Product_ID
    WHERE o.Customer_ID = Cust_ID;
END //

DELIMITER ;


-- 7. CALCULATE TOTAL SALES (FUNCTION)

DROP FUNCTION IF EXISTS CalculateTotalSales;

DELIMITER //

CREATE FUNCTION CalculateTotalSales(
    StartDate DATE,
    EndDate DATE
)
RETURNS DECIMAL(12,2)
READS SQL DATA
BEGIN
    DECLARE TotalSales DECIMAL(12,2);

    SELECT COALESCE(SUM(Total_Amount), 0)
    INTO TotalSales
    FROM Orders
    WHERE DATE(Order_Date)
    BETWEEN StartDate AND EndDate;

    RETURN TotalSales;
END //

DELIMITER ;


-- 8. CALCULATE CUSTOMER SPENDING (FUNCTION)

DROP FUNCTION IF EXISTS CalculateCustomerSpending;

DELIMITER //

CREATE FUNCTION CalculateCustomerSpending(
    Cust_ID INT
)
RETURNS DECIMAL(12,2)
READS SQL DATA
BEGIN
    DECLARE TotalSpending DECIMAL(12,2);

    SELECT COALESCE(SUM(Total_Amount), 0)
    INTO TotalSpending
    FROM Orders
    WHERE Customer_ID = Cust_ID;

    RETURN TotalSpending;
END //

DELIMITER ;


-- 9. CALCULATE PRODUCT REVENUE (FUNCTION)

DROP FUNCTION IF EXISTS CalculateProductRevenue;

DELIMITER //

CREATE FUNCTION CalculateProductRevenue(
    Prod_ID INT
)
RETURNS DECIMAL(12,2)
READS SQL DATA
BEGIN
    DECLARE ProductRevenue DECIMAL(12,2);

    SELECT COALESCE(SUM(od.Quantity * p.Price), 0)
    INTO ProductRevenue
    FROM Order_Details od
    JOIN Products p
    ON od.Product_ID = p.Product_ID
    WHERE od.Product_ID = Prod_ID;

    RETURN ProductRevenue;
END //

DELIMITER ;


-- 10. DAILY SALES REPORT

SELECT
    DATE(Order_Date) AS Sales_Date,
    COUNT(Order_ID) AS Total_Orders,
    SUM(Total_Amount) AS Daily_Revenue
FROM Orders
GROUP BY DATE(Order_Date)
ORDER BY Sales_Date;


-- 11. MONTHLY SALES REPORT

SELECT
    YEAR(Order_Date) AS Sales_Year,
    MONTH(Order_Date) AS Sales_Month,
    COUNT(Order_ID) AS Total_Orders,
    SUM(Total_Amount) AS Monthly_Revenue
FROM Orders
GROUP BY YEAR(Order_Date), MONTH(Order_Date)
ORDER BY Sales_Year, Sales_Month;


-- 12. LOW STOCK REPORT

SELECT
    Item_Name AS Product_Name,
    Stock_Quantity,
    Reorder_Level,
    'Low Stock' AS Stock_Status
FROM Inventory
WHERE Stock_Quantity <= Reorder_Level;


-- 13. ADD INVENTORY STOCK (PROCEDURE)

DROP PROCEDURE IF EXISTS AddInventoryStock;

DELIMITER //

CREATE PROCEDURE AddInventoryStock(
    IN p_Item_ID INT,
    IN p_Quantity INT
)
BEGIN
    IF p_Quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid Quantity';
    END IF;

    UPDATE Inventory
    SET Stock_Quantity = Stock_Quantity + p_Quantity
    WHERE Item_ID = p_Item_ID;
END //

DELIMITER ;


-- 14. REDUCE INVENTORY STOCK (PROCEDURE)

DROP PROCEDURE IF EXISTS ReduceInventoryStock;

DELIMITER //

CREATE PROCEDURE ReduceInventoryStock(
    IN p_Product_ID INT,
    IN p_Quantity INT
)
BEGIN
    IF p_Quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid Quantity';
    END IF;

    UPDATE Inventory i
    JOIN Products p
    ON i.Item_Name = p.Product_Name
    SET i.Stock_Quantity =
        i.Stock_Quantity - p_Quantity
    WHERE p.Product_ID = p_Product_ID
    AND i.Stock_Quantity >= p_Quantity;
END //

DELIMITER ;


-- FINAL OUTPUT VERIFICATION

SELECT * FROM Customer_Order_Report;

SELECT * FROM Product_Sales_Report;

SELECT * FROM Payment_Status_Report;

CALL UpdateOrderStatus(1, 'Shipped');

SELECT * FROM Orders
WHERE Order_ID = 1;

CALL GetCustomerPurchaseHistory(1);

SELECT CalculateTotalSales(
    '2025-01-01', '2025-12-31'
) AS Total_Sales;

SELECT CalculateCustomerSpending(1)
AS Total_Spending;

SELECT CalculateProductRevenue(1)
AS Product_Revenue;


-- CHECK ALL VIEWS

SHOW FULL TABLES IN inventory_db
WHERE TABLE_TYPE = 'VIEW';


-- CHECK ALL PROCEDURES

SHOW PROCEDURE STATUS
WHERE Db = 'inventory_db';


-- CHECK ALL FUNCTIONS

SHOW FUNCTION STATUS
WHERE Db = 'inventory_db';
