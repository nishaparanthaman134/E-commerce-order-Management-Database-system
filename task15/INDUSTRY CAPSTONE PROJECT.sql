USE inventory_db;

-- 1. DISPLAY ALL DATABASE TABLES

SHOW TABLES;

-- 2. CUSTOMER MANAGEMENT

SELECT * FROM Customers;

-- 3. PRODUCT MANAGEMENT

SELECT * FROM Products;

-- 4. SELLER AND INVENTORY MANAGEMENT

SELECT * FROM Inventory;

-- 5. ORDER MANAGEMENT

SELECT * FROM Orders;

-- 6. PAYMENT MANAGEMENT

SELECT * FROM Payment;

-- 7. ORDER DETAILS

SELECT * FROM Order_Details;


-- 8. BASIC SQL QUERIES

-- SELECT
SELECT * FROM Products;

-- WHERE
SELECT * FROM Products
WHERE Price > 1000;

-- ORDER BY
SELECT * FROM Products
ORDER BY Price DESC;

-- DISTINCT
SELECT DISTINCT Order_Status
FROM Orders;

-- LIKE
SELECT * FROM Products
WHERE Product_Name LIKE '%Laptop%';

-- BETWEEN
SELECT * FROM Products
WHERE Price BETWEEN 1000 AND 50000;


-- 9. JOIN OPERATIONS

SELECT
    c.Customer_Name,
    o.Order_ID,
    o.Total_Amount,
    o.Order_Status
FROM Customers c
JOIN Orders o
ON c.Customer_ID = o.Customer_ID;


-- 10. AGGREGATE FUNCTIONS

SELECT
    COUNT(*) AS Total_Orders,
    SUM(Total_Amount) AS Total_Sales,
    AVG(Total_Amount) AS Average_Sales,
    MAX(Total_Amount) AS Highest_Order,
    MIN(Total_Amount) AS Lowest_Order
FROM Orders;


-- 11. GROUP BY AND HAVING

SELECT
    Customer_ID,
    COUNT(Order_ID) AS Total_Orders,
    SUM(Total_Amount) AS Total_Spending
FROM Orders
GROUP BY Customer_ID
HAVING SUM(Total_Amount) > 1000;


-- 12. SUBQUERY

SELECT *
FROM Products
WHERE Price > (
    SELECT AVG(Price)
    FROM Products
);


-- 13. WINDOW FUNCTIONS

SELECT
    Product_ID,
    SUM(Quantity) AS Total_Sales,
    RANK() OVER(
        ORDER BY SUM(Quantity) DESC
    ) AS Sales_Rank
FROM Order_Details
GROUP BY Product_ID;


-- 14. CUSTOMER ORDER HISTORY VIEW

CREATE OR REPLACE VIEW Customer_Order_History AS
SELECT
    c.Customer_Name,
    o.Order_ID,
    o.Order_Date,
    o.Total_Amount,
    o.Order_Status
FROM Customers c
JOIN Orders o
ON c.Customer_ID = o.Customer_ID;


-- 15. SALES REPORT VIEW

CREATE OR REPLACE VIEW Sales_Report AS
SELECT
    DATE(Order_Date) AS Sales_Date,
    COUNT(Order_ID) AS Total_Orders,
    SUM(Total_Amount) AS Daily_Revenue
FROM Orders
GROUP BY DATE(Order_Date);


-- 16. PRODUCT PERFORMANCE VIEW

CREATE OR REPLACE VIEW Product_Performance AS
SELECT
    p.Product_Name,
    SUM(od.Quantity) AS Quantity_Sold,
    SUM(od.Quantity * p.Price) AS Total_Revenue
FROM Products p
JOIN Order_Details od
ON p.Product_ID = od.Product_ID
GROUP BY p.Product_ID, p.Product_Name;


-- 17. STORED PROCEDURE FOR SALES CALCULATION

DELIMITER //

CREATE PROCEDURE CalculateSales()
BEGIN
    SELECT
        SUM(Total_Amount) AS Total_Sales,
        COUNT(Order_ID) AS Total_Orders,
        AVG(Total_Amount) AS Average_Sales
    FROM Orders;
END //

DELIMITER ;

CALL CalculateSales();


-- 18. FUNCTION FOR CUSTOMER SPENDING

DELIMITER //

CREATE FUNCTION GetCustomerSpending(
    p_Customer_ID INT
)
RETURNS DECIMAL(12,2)
READS SQL DATA
BEGIN
    DECLARE v_Total DECIMAL(12,2);

    SELECT COALESCE(SUM(Total_Amount), 0)
    INTO v_Total
    FROM Orders
    WHERE Customer_ID = p_Customer_ID;

    RETURN v_Total;
END //

DELIMITER ;

SELECT GetCustomerSpending(1) AS Total_Spending;


-- 19. FUNCTION FOR PRODUCT REVENUE

DELIMITER //

CREATE FUNCTION GetProductRevenue(
    p_Product_ID INT
)
RETURNS DECIMAL(12,2)
READS SQL DATA
BEGIN
    DECLARE v_Revenue DECIMAL(12,2);

    SELECT COALESCE(SUM(od.Quantity * p.Price), 0)
    INTO v_Revenue
    FROM Order_Details od
    JOIN Products p
    ON od.Product_ID = p.Product_ID
    WHERE od.Product_ID = p_Product_ID;

    RETURN v_Revenue;
END //

DELIMITER ;

SELECT GetProductRevenue(1) AS Product_Revenue;


-- 20. CREATE AUDIT TABLE

CREATE TABLE IF NOT EXISTS Order_Audit (
    Audit_ID INT AUTO_INCREMENT PRIMARY KEY,
    Order_ID INT,
    Action_Type VARCHAR(50),
    Action_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- 21. TRIGGER FOR ORDER AUDIT

DELIMITER //

CREATE TRIGGER Order_Audit_Trigger
AFTER INSERT ON Orders
FOR EACH ROW
BEGIN
    INSERT INTO Order_Audit
    (Order_ID, Action_Type)
    VALUES
    (NEW.Order_ID, 'New Order Created');
END //

DELIMITER ;


-- 22. TRIGGER FOR PAYMENT STATUS

DELIMITER //

CREATE TRIGGER Update_Order_After_Payment
AFTER UPDATE ON Payment
FOR EACH ROW
BEGIN
    IF NEW.Payment_Status = 'successful' THEN
        UPDATE Orders
        SET Order_Status = 'Completed'
        WHERE Order_ID = NEW.Order_ID;

    ELSEIF NEW.Payment_Status = 'failed' THEN
        UPDATE Orders
        SET Order_Status = 'Cancelled'
        WHERE Order_ID = NEW.Order_ID;
    END IF;
END //

DELIMITER ;


-- 23. PERFORMANCE OPTIMIZATION

CREATE INDEX idx_product_search
ON Products(Product_Name);

CREATE INDEX idx_customer_lookup
ON Orders(Customer_ID);

CREATE INDEX idx_order_retrieval
ON Orders(Order_Date);


-- 24. QUERY PERFORMANCE ANALYSIS

EXPLAIN
SELECT *
FROM Products
WHERE Product_Name = 'Gaming Laptop 16GB RAM';

EXPLAIN
SELECT *
FROM Orders
WHERE Customer_ID = 1;


-- 25. SALES INTELLIGENCE REPORT

SELECT
    SUM(Total_Amount) AS Total_Revenue,
    COUNT(Order_ID) AS Total_Orders
FROM Orders;


-- 26. MONTHLY SALES TREND

SELECT
    YEAR(Order_Date) AS Sales_Year,
    MONTH(Order_Date) AS Sales_Month,
    SUM(Total_Amount) AS Monthly_Sales
FROM Orders
GROUP BY YEAR(Order_Date), MONTH(Order_Date)
ORDER BY Sales_Year, Sales_Month;


-- 27. BEST SELLING PRODUCTS

SELECT
    p.Product_Name,
    SUM(od.Quantity) AS Total_Sold
FROM Products p
JOIN Order_Details od
ON p.Product_ID = od.Product_ID
GROUP BY p.Product_ID, p.Product_Name
ORDER BY Total_Sold DESC;


-- 28. CUSTOMER INTELLIGENCE REPORT

SELECT
    c.Customer_Name,
    COUNT(o.Order_ID) AS Purchase_Frequency,
    SUM(o.Total_Amount) AS Total_Spending
FROM Customers c
JOIN Orders o
ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY Total_Spending DESC;


-- 29. INVENTORY INTELLIGENCE REPORT

SELECT
    Item_Name,
    Stock_Quantity,
    Reorder_Level,
    CASE
        WHEN Stock_Quantity <= Reorder_Level
        THEN 'Low Stock'
        ELSE 'Available'
    END AS Stock_Status
FROM Inventory;


-- 30. FINAL OUTPUT

SELECT * FROM Customer_Order_History;

SELECT * FROM Sales_Report;

SELECT * FROM Product_Performance;

SELECT * FROM Order_Audit;

SHOW FULL TABLES IN inventory_db
WHERE TABLE_TYPE = 'VIEW';

SHOW PROCEDURE STATUS
WHERE Db = 'inventory_db';

SHOW FUNCTION STATUS
WHERE Db = 'inventory_db';

SHOW TRIGGERS FROM inventory_db;
