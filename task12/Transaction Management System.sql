USE inventory_db;

-- 1. ORDER PLACEMENT TRANSACTION

DELIMITER //

CREATE PROCEDURE PlaceCustomerOrder(
    IN p_Customer_ID INT,
    IN p_Product_ID INT,
    IN p_Quantity INT
)
BEGIN
    DECLARE v_Price DECIMAL(10,2);
    DECLARE v_Stock INT;
    DECLARE v_Order_ID INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT Price INTO v_Price
    FROM Products
    WHERE Product_ID = p_Product_ID;

    SELECT i.Stock_Quantity INTO v_Stock
    FROM Inventory i
    JOIN Products p
    ON i.Item_Name = p.Product_Name
    WHERE p.Product_ID = p_Product_ID
    FOR UPDATE;

    IF v_Stock < p_Quantity OR p_Quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient Stock';
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

    UPDATE Inventory
    SET Stock_Quantity = Stock_Quantity - p_Quantity
    WHERE Item_Name = (
        SELECT Product_Name
        FROM Products
        WHERE Product_ID = p_Product_ID
    );

    INSERT INTO Payment
    (Order_ID, Payment_Mode, Payment_Status)
    VALUES
    (v_Order_ID, 'UPI', 'successful');

    UPDATE Orders
    SET Order_Status = 'Completed'
    WHERE Order_ID = v_Order_ID;

    COMMIT;
END //

DELIMITER ;

CALL PlaceCustomerOrder(1, 1, 1);


-- 2. COMMIT OPERATION

START TRANSACTION;

UPDATE Orders
SET Order_Status = 'Completed'
WHERE Order_ID = 1;

COMMIT;


-- 3. ROLLBACK OPERATION

START TRANSACTION;

UPDATE Orders
SET Order_Status = 'Cancelled'
WHERE Order_ID = 1;

ROLLBACK;


-- 4. ACID PROPERTIES
-- Atomicity: All operations succeed or fail together.
-- Consistency: Database remains accurate.
-- Isolation: Transactions work independently.
-- Durability: Committed data remains saved.


-- 5. FAILED TRANSACTION

START TRANSACTION;

UPDATE Inventory
SET Stock_Quantity = Stock_Quantity - 1
WHERE Item_Name = 'Gaming Laptop 16GB RAM';

ROLLBACK;


-- 6. DATABASE CONSISTENCY

-- Check Invalid Customer IDs

SELECT o.*
FROM Orders o
LEFT JOIN Customers c
ON o.Customer_ID = c.Customer_ID
WHERE c.Customer_ID IS NULL;


-- Check Invalid Payment Order IDs

SELECT p.*
FROM Payment p
LEFT JOIN Orders o
ON p.Order_ID = o.Order_ID
WHERE o.Order_ID IS NULL;


-- Check Negative Stock

SELECT *
FROM Inventory
WHERE Stock_Quantity < 0;


-- Check Completed Orders with Failed Payments

SELECT
    o.Order_ID,
    o.Order_Status,
    p.Payment_Status
FROM Orders o
JOIN Payment p
ON o.Order_ID = p.Order_ID
WHERE o.Order_Status = 'Completed'
AND p.Payment_Status <> 'successful';


-- 7. ORDER TRANSACTION REPORT

SELECT
    o.Order_ID,
    c.Customer_Name,
    o.Total_Amount,
    p.Payment_Status,
    o.Order_Status
FROM Orders o
JOIN Customers c
ON o.Customer_ID = c.Customer_ID
LEFT JOIN Payment p
ON o.Order_ID = p.Order_ID;


-- 8. FAILED TRANSACTION REPORT

SELECT
    o.Order_ID,
    o.Order_Status,
    p.Payment_Status
FROM Orders o
JOIN Payment p
ON o.Order_ID = p.Order_ID
WHERE p.Payment_Status = 'failed'
OR o.Order_Status = 'Cancelled';


-- 9. INVENTORY UPDATE REPORT

SELECT
    p.Product_Name,
    i.Stock_Quantity AS Current_Stock
FROM Products p
JOIN Inventory i
ON p.Product_Name = i.Item_Name;


-- 10. FINAL OUTPUT

SELECT * FROM Orders;

SELECT * FROM Order_Details;

SELECT * FROM Payment;

SELECT * FROM Inventory;