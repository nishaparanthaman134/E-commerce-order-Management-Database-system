Payment Management And Analysis:

Project Overview:

This project focuses on creating and analyzing a Payment Management System using MySQL. The Payment table is connected with the Orders table through a foreign key relationship, allowing payment details to be tracked for each order.

Objectives:
* Create a structured Payment table.
* Establish an Order–Payment relationship using a foreign key.
* Store payment mode, status, date, and transaction amount.
* Perform payment status analysis.
* Analyze payment methods and revenue.
* Display customer payment history using table joins.

Payment Table Design:

The Payment table stores payment details such as Order ID, Payment Date, Payment Mode, Payment Status, and Transaction Amount. It uses Primary Key, Foreign Key, Auto Increment, Default, and CHECK constraints for proper data management.

ER Relationship:

The Payment table is connected to the Orders table using:

Orders (1) ─────── (Many) Payment

One order can have payment records associated with it, while each payment belongs to a particular order.
<img width="707" height="741" alt="image" src="https://github.com/user-attachments/assets/6283d7bb-efc8-41e5-8750-2051f5828818" />

Payment Analysis Reports

Report 1 – Payment Mode Analysis



<img width="765" height="167" alt="image" src="https://github.com/user-attachments/assets/b23c778a-6d6d-47f4-9c46-88ce6a7069c8" />
Shows the number of UPI transactions, card payments and the most preferred payment method.

Report 2 – Revenue Analysis

<img width="913" height="163" alt="image" src="https://github.com/user-attachments/assets/43bfceac-f1fa-467e-b654-1405c73681b1" />
Shows total revenue, revenue by payment method and average transaction amount.

Report 3 – Customer Payment History

<img width="947" height="317" alt="image" src="https://github.com/user-attachments/assets/861f62af-2127-4c94-9b8e-b2fb998f78c2" />
Shows customer name, order ID, payment mode, amount and payment status.

Technologies Used
MySQL
MySQL Workbench
SQL


Conclusion
The Payment Management System provides a structured way to store and analyze customer payment information. The SQL queries help identify preferred payment methods, analyze revenue, monitor transaction statuses, and track individual customer payment history.




