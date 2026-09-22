USE inventory_db;

SELECT *
FROM customers;

<img width="597" height="207" alt="image" src="https://github.com/user-attachments/assets/0a01f703-b468-4579-b4a3-c4b5834eaeed" />


SELECT *
FROM products;

<img width="765" height="210" alt="image" src="https://github.com/user-attachments/assets/0a4ff933-c71b-4ec5-9b65-c7a973287ff7" />

SELECT product_name, price
FROM products;

<img width="332" height="192" alt="image" src="https://github.com/user-attachments/assets/174ffb37-f24c-4c5b-833a-c4247739ef9f" />

SELECT *
FROM orders;

<img width="536" height="190" alt="image" src="https://github.com/user-attachments/assets/dca07602-e13e-4371-acc4-f8272f2a359c" />


SELECT *
FROM payments;

<img width="747" height="330" alt="image" src="https://github.com/user-attachments/assets/9fdfe236-4324-4d1f-9d84-9fa077e2e059" />


SELECT *
FROM reviews;

<img width="742" height="192" alt="image" src="https://github.com/user-attachments/assets/e4c6e636-111a-4340-8d2f-85973adf2ea5" />



SELECT
    product_name,
    price,
    stock_quantity,
    CASE
        WHEN stock_quantity > 0 THEN 'Available'
        ELSE 'Out of Stock'
    END AS availability_status
FROM products
ORDER BY product_name;
SELECT COUNT(*) AS total_customers
FROM customers;

<img width="182" height="67" alt="image" src="https://github.com/user-attachments/assets/e4acfbea-acfa-42ce-90e2-e5b2f652cab9" />


SELECT
    customer_id,
    customer_name,
    email,
    phone,
    address,
    created_at
FROM customers
ORDER BY created_at DESC;

SELECT
    COUNT(*) AS total_orders,
    SUM(CASE WHEN p.payment_status = 'Successful' THEN 1 ELSE 0 END) AS completed_orders,
    SUM(CASE WHEN p.payment_status = 'Pending' THEN 1 ELSE 0 END) AS pending_orders,
    SUM(CASE WHEN p.payment_status = 'Failed' THEN 1 ELSE 0 END) AS failed_orders
FROM orders o
LEFT JOIN payments p
ON o.order_id = p.order_id;

SELECT
    p.product_name,
    p.price,
    p.stock_quantity,
    COUNT(r.review_id) AS total_reviews,
    ROUND(AVG(r.rating), 2) AS average_rating
FROM products p
LEFT JOIN reviews r
ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name, p.price, p.stock_quantity
ORDER BY total_reviews DESC, average_rating DESC;

<img width="652" height="176" alt="image" src="https://github.com/user-attachments/assets/13b3d8b3-4bc4-4dbc-87fd-9f1fa0cc0d5b" />





