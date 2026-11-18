USE inventory_db;

-- 1. CREATE DATABASE USERS

CREATE USER IF NOT EXISTS 'admin_user'@'localhost'
IDENTIFIED BY 'Admin@123';

CREATE USER IF NOT EXISTS 'sales_user'@'localhost'
IDENTIFIED BY 'Sales@123';

CREATE USER IF NOT EXISTS 'inventory_user'@'localhost'
IDENTIFIED BY 'Inventory@123';

CREATE USER IF NOT EXISTS 'support_user'@'localhost'
IDENTIFIED BY 'Support@123';


-- 2. CREATE DATABASE ROLES

CREATE ROLE IF NOT EXISTS 'admin_role';
CREATE ROLE IF NOT EXISTS 'sales_role';
CREATE ROLE IF NOT EXISTS 'inventory_role';
CREATE ROLE IF NOT EXISTS 'support_role';


-- 3. GRANT PERMISSIONS TO ROLES

-- Admin Role
GRANT ALL PRIVILEGES ON inventory_db.*
TO 'admin_role';

-- Sales Role
GRANT SELECT ON inventory_db.Orders
TO 'sales_role';

GRANT SELECT ON inventory_db.Products
TO 'sales_role';

GRANT SELECT ON inventory_db.Customer_Order_Report
TO 'sales_role';

GRANT SELECT ON inventory_db.Product_Sales_Report
TO 'sales_role';

-- Inventory Role
GRANT SELECT, UPDATE ON inventory_db.Inventory
TO 'inventory_role';

GRANT SELECT ON inventory_db.Products
TO 'inventory_role';

-- Customer Support Role
GRANT SELECT ON inventory_db.Customers
TO 'support_role';

GRANT SELECT ON inventory_db.Orders
TO 'support_role';


-- 4. ASSIGN ROLES TO USERS

GRANT 'admin_role' TO 'admin_user'@'localhost';

GRANT 'sales_role' TO 'sales_user'@'localhost';

GRANT 'inventory_role' TO 'inventory_user'@'localhost';

GRANT 'support_role' TO 'support_user'@'localhost';


-- 5. SET DEFAULT ROLES

SET DEFAULT ROLE ALL TO 'admin_user'@'localhost';

SET DEFAULT ROLE ALL TO 'sales_user'@'localhost';

SET DEFAULT ROLE ALL TO 'inventory_user'@'localhost';

SET DEFAULT ROLE ALL TO 'support_user'@'localhost';


-- 6. REVOKE PERMISSIONS

REVOKE SELECT ON inventory_db.Products
FROM 'sales_role';


-- 7. CREATE INDEXES

CREATE INDEX idx_product_name
ON Products(Product_Name);

CREATE INDEX idx_category_id
ON Products(Category_ID);

CREATE INDEX idx_customer_email
ON Customers(Email);

CREATE INDEX idx_customer_phone
ON Customers(Phone);

CREATE INDEX idx_order_date
ON Orders(Order_Date);

CREATE INDEX idx_customer_id
ON Orders(Customer_ID);


-- 8. PRODUCT SEARCH QUERY

SELECT *
FROM Products
WHERE Product_Name = 'Gaming Laptop 16GB RAM';

-- 9. CUSTOMER ORDER HISTORY

SELECT *
FROM Orders
WHERE Customer_ID = 1;


-- 10. SALES REPORT

SELECT
    Product_ID,
    SUM(Quantity) AS Total_Sales
FROM Order_Details
GROUP BY Product_ID;


-- 11. TOP SELLING PRODUCTS

SELECT
    p.Product_Name,
    SUM(od.Quantity) AS Total_Quantity
FROM Products p
JOIN Order_Details od
ON p.Product_ID = od.Product_ID
GROUP BY p.Product_ID, p.Product_Name
ORDER BY Total_Quantity DESC;


-- 12. QUERY PERFORMANCE ANALYSIS

EXPLAIN
SELECT *
FROM Products
WHERE Product_Name = 'Gaming Laptop 16GB RAM';

EXPLAIN
SELECT *
FROM Orders
WHERE Customer_ID = 1;


-- 13. USER ACCESS REPORT

SHOW GRANTS FOR 'admin_user'@'localhost';

SHOW GRANTS FOR 'sales_user'@'localhost';

SHOW GRANTS FOR 'inventory_user'@'localhost';

SHOW GRANTS FOR 'support_user'@'localhost';


-- 14. DATABASE SECURITY REPORT

SELECT User, Host
FROM mysql.user;


-- 15. DISPLAY INDEXES

SHOW INDEX FROM Products;

SHOW INDEX FROM Customers;

SHOW INDEX FROM Orders;