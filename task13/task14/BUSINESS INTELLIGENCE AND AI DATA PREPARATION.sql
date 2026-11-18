USE inventory_db;

-- 1. SALES PERFORMANCE REPORT

SELECT
    SUM(Total_Amount) AS Total_Sales,
    COUNT(Order_ID) AS Number_of_Orders,
    AVG(Total_Amount) AS Average_Order_Value
FROM Orders;


-- 2. MONTHLY REVENUE REPORT

SELECT
    YEAR(Order_Date) AS Sales_Year,
    MONTH(Order_Date) AS Sales_Month,
    SUM(Total_Amount) AS Monthly_Revenue
FROM Orders
GROUP BY YEAR(Order_Date), MONTH(Order_Date)
ORDER BY Sales_Year, Sales_Month;


-- 3. CUSTOMER ANALYSIS REPORT

SELECT
    c.Customer_Name,
    SUM(o.Total_Amount) AS Total_Purchases,
    COUNT(o.Order_ID) AS Number_of_Orders,
    MAX(o.Order_Date) AS Last_Purchase_Date
FROM Customers c
JOIN Orders o
ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name;


-- 4. PRODUCT PERFORMANCE REPORT

SELECT
    p.Product_Name,
    SUM(od.Quantity) AS Quantity_Sold,
    SUM(od.Quantity * p.Price) AS Revenue_Generated
FROM Products p
JOIN Order_Details od
ON p.Product_ID = od.Product_ID
GROUP BY p.Product_ID, p.Product_Name;


-- 5. RANK PRODUCTS BASED ON SALES

SELECT
    Product_ID,
    SUM(Quantity) AS Total_Sales,
    RANK() OVER(
        ORDER BY SUM(Quantity) DESC
    ) AS Sales_Rank
FROM Order_Details
GROUP BY Product_ID;


-- 6. DENSE RANK PRODUCTS

SELECT
    Product_ID,
    SUM(Quantity) AS Total_Sales,
    DENSE_RANK() OVER(
        ORDER BY SUM(Quantity) DESC
    ) AS Product_Rank
FROM Order_Details
GROUP BY Product_ID;


-- 7. RANK CUSTOMERS BASED ON PURCHASE AMOUNT

SELECT
    Customer_ID,
    SUM(Total_Amount) AS Total_Spending,
    RANK() OVER(
        ORDER BY SUM(Total_Amount) DESC
    ) AS Spending_Rank
FROM Orders
GROUP BY Customer_ID;


-- 8. GENERATE LATEST ORDER SEQUENCE

SELECT
    Order_ID,
    Customer_ID,
    Order_Date,
    ROW_NUMBER() OVER(
        ORDER BY Order_Date DESC
    ) AS Order_Sequence
FROM Orders;


-- 9. CUSTOMER SEGMENTATION REPORT

SELECT
    c.Customer_Name,
    SUM(o.Total_Amount) AS Total_Purchase,
    COUNT(o.Order_ID) AS Total_Orders,
    CASE
        WHEN SUM(o.Total_Amount) >= 50000
             AND COUNT(o.Order_ID) >= 5
        THEN 'Premium'
        WHEN COUNT(o.Order_ID) >= 2
        THEN 'Regular'
        ELSE 'Low Value'
    END AS Customer_Segment
FROM Customers c
JOIN Orders o
ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name;


-- 10. CUSTOMER BEHAVIOR DATASET

SELECT
    c.Customer_ID,
    c.Customer_Name,
    COUNT(o.Order_ID) AS Total_Purchases,
    COALESCE(SUM(o.Total_Amount), 0) AS Total_Spending,
    COALESCE(AVG(o.Total_Amount), 0) AS Average_Order_Value,
    MAX(o.Order_Date) AS Last_Purchase_Date
FROM Customers c
LEFT JOIN Orders o
ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name;


-- 11. REMOVE DUPLICATE CUSTOMER RECORDS

SELECT DISTINCT
    Customer_ID,
    Customer_Name
FROM Customers;


-- 12. HANDLE MISSING VALUES

SELECT
    c.Customer_ID,
    COALESCE(c.Customer_Name, 'Unknown') AS Customer_Name,
    COALESCE(SUM(o.Total_Amount), 0) AS Total_Spending
FROM Customers c
LEFT JOIN Orders o
ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name;


-- 13. NUMERICAL CUSTOMER SEGMENT ENCODING

SELECT
    Customer_ID,
    SUM(Total_Amount) AS Total_Spending,
    CASE
        WHEN SUM(Total_Amount) >= 50000 THEN 3
        WHEN SUM(Total_Amount) >= 20000 THEN 2
        ELSE 1
    END AS Customer_Category_Code
FROM Orders
GROUP BY Customer_ID;


-- 14. CUSTOMER FEATURE EXTRACTION

SELECT
    Customer_ID,
    COUNT(Order_ID) AS Purchase_Count,
    SUM(Total_Amount) AS Total_Spending,
    AVG(Total_Amount) AS Avg_Order_Value,
    MAX(Order_Date) AS Last_Purchase_Date
FROM Orders
GROUP BY Customer_ID;


-- 15. PRODUCT FEATURE EXTRACTION

SELECT
    p.Product_ID,
    p.Product_Name,
    COALESCE(SUM(od.Quantity), 0) AS Total_Sales_Quantity,
    COALESCE(SUM(od.Quantity * p.Price), 0) AS Revenue_Generated,
    i.Stock_Quantity AS Stock_Availability
FROM Products p
LEFT JOIN Order_Details od
ON p.Product_ID = od.Product_ID
LEFT JOIN Inventory i
ON p.Product_Name = i.Item_Name
GROUP BY
    p.Product_ID,
    p.Product_Name,
    i.Stock_Quantity;


-- 16. TIME BASED FEATURE EXTRACTION

SELECT
    Order_ID,
    Customer_ID,
    YEAR(Order_Date) AS Purchase_Year,
    MONTH(Order_Date) AS Purchase_Month,
    DAY(Order_Date) AS Purchase_Day
FROM Orders;


-- 17. CUSTOMER SEGMENTATION REPORT

SELECT
    c.Customer_Name,
    COUNT(o.Order_ID) AS Purchase_Frequency,
    SUM(o.Total_Amount) AS Total_Spending,
    CASE
        WHEN SUM(o.Total_Amount) >= 50000 THEN 'Premium'
        WHEN COUNT(o.Order_ID) >= 2 THEN 'Regular'
        ELSE 'Low Value'
    END AS Customer_Category
FROM Customers c
JOIN Orders o
ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name;


-- 18. SALES RANKING REPORT

SELECT
    p.Product_Name,
    SUM(od.Quantity) AS Total_Sales,
    RANK() OVER(
        ORDER BY SUM(od.Quantity) DESC
    ) AS Sales_Rank
FROM Products p
JOIN Order_Details od
ON p.Product_ID = od.Product_ID
GROUP BY p.Product_ID, p.Product_Name;


-- 19. FINAL SALES ANALYSIS

SELECT
    COUNT(Order_ID) AS Total_Orders,
    SUM(Total_Amount) AS Total_Revenue,
    AVG(Total_Amount) AS Average_Revenue
FROM Orders;


-- 20. FINAL OUTPUT

SELECT * FROM Customers;

SELECT * FROM Products;

SELECT * FROM Orders;

SELECT * FROM Order_Details;

SELECT * FROM Inventory;
