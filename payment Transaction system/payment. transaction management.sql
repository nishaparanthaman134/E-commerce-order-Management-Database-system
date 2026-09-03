create table payment(
Payment_ID int auto_increment,
Order_ID int NOT NULL,
Payment_Date timestamp default current_timestamp,
Payment_Mode VARCHAR(100),
Payment_Status VARCHAR(100),
Transaction_Amount decimal(10,2),

constraint pk_key primary key (Payment_ID),
constraint chk_amt CHECK(Transaction_Amount >0),
constraint fk_key foreign key (Order_ID) references orders(Order_ID)
);

select * FROM Orders;

insert into payment(Order_ID, Payment_Mode, Payment_Status, Transaction_Amount) values
(1, "UPI", "pending",450),
(2, "credit card", "successfull",450),
(3, "debit card", "successfull",450),
(4, "Cash on delivery", "successfull",1450),
(5, "debit card", "failed",5000);

select * FROM Orders;

insert into payment(Order_ID, Payment_Mode, Payment_Status, Transaction_Amount) values
(1, "UPI", "pending",450),
(2, "credit card", "successfull",450),
(3, "debit card", "successfull",450),
(4, "Cash on delivery", "successfull",1450),
(5, "debit card", "failed",5000);


select * FROM payment;

-- Display all successful payments.

select * from payment where Payment_Status = "successfull";

-- Find failed transactions.

select * from payment where Payment_Status = "failed";

-- Count total successful and failed payments.

select
count(*) as Number_of_Transcations, Payment_Mode
from payment group by Payment_Mode;

select
count(*) as Number_of_Transcations, Payment_Status
from payment group by Payment_Status;

select * from payment where Payment_Status = "failed";

-- Update failed payments after retry.

update payment set Payment_Status = "Successful" where Payment_ID = 10;

-- Identify pending transactions.

select * from payment where Payment_Status = "Pending";

