CREATE DATABASE ngo_tracker;
USE ngo_tracker;
CREATE TABLE donors (
    donor_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    country VARCHAR(50),
    donor_type VARCHAR(50)
);
INSERT INTO donors (name,email,country,donor_type) VALUES
('Anita Sharma','anita@gmail.com','India','Individual'),
('Rahul Verma','rahul@gmail.com','India','Individual'),
('Global Aid Trust','contact@globalaid.org','USA','Organization'),
('Priya Nair','priya@gmail.com','India','Individual'),
('Hope Foundation','info@hope.org','UK','Organization'),
('Arjun Rao','arjun@gmail.com','India','Individual');
CREATE TABLE donations (
    donation_id INT AUTO_INCREMENT PRIMARY KEY,
    donor_id INT,
    amount DECIMAL(10,2) NOT NULL,
    donation_date DATE,
    payment_method VARCHAR(50),
    FOREIGN KEY (donor_id) REFERENCES donors(donor_id)
);
INSERT INTO donations (donor_id,amount,donation_date,payment_method) VALUES
(1,10000,'2024-05-01','UPI'),
(2,5000,'2024-05-02','Card'),
(3,75000,'2024-05-03','Bank Transfer'),
(4,12000,'2024-05-05','UPI'),
(5,60000,'2024-05-06','Bank Transfer'),
(6,15000,'2024-06-03','Cash');
CREATE TABLE projects (
    project_id INT AUTO_INCREMENT PRIMARY KEY,
    project_name VARCHAR(100),
    category VARCHAR(50),
    start_date DATE,
    budget DECIMAL(12,2)
);
INSERT INTO projects (project_name,category,start_date,budget) VALUES
('Child Education Program','Education','2024-01-10',500000),
('Food for All','Food','2024-02-01',300000),
('Medical Aid Camp','Health','2024-03-15',250000),
('Women Skill Training','Empowerment','2024-04-01',200000),
('Winter Blanket Drive','Relief','2024-11-01',150000),
('Clean Water Initiative','Health','2024-06-01',180000);
select * from projects;
CREATE TABLE expenses (
    expense_id INT AUTO_INCREMENT PRIMARY KEY,
    project_id INT,
    amount DECIMAL(10,2),
    expense_type VARCHAR(50),
    expense_date DATE,
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);
INSERT INTO expenses (project_id,amount,expense_type,expense_date) VALUES
(1,15000,'Books','2024-05-10'),
(1,10000,'Stationery','2024-05-15'),
(2,12000,'Groceries','2024-05-18'),
(3,20000,'Medicines','2024-05-20'),
(4,15000,'Training Materials','2024-05-22'),
(5,10000,'Blankets','2024-06-02');
CREATE TABLE beneficiaries (
    beneficiary_id INT AUTO_INCREMENT PRIMARY KEY,
    project_id INT,
    age INT,
    gender VARCHAR(10),
    support_type VARCHAR(50),
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);
INSERT INTO beneficiaries (project_id,age,gender,support_type) VALUES
(1,10,'Female','Education'),
(1,12,'Male','Education'),
(2,45,'Female','Food Support'),
(3,35,'Female','Medical'),
(4,22,'Female','Skill Training'),
(5,65,'Female','Winter Relief');
CREATE TABLE fund_allocations (
    allocation_id INT AUTO_INCREMENT PRIMARY KEY,
    donation_id INT,
    project_id INT,
    allocated_amount DECIMAL(10,2),
    FOREIGN KEY (donation_id) REFERENCES donations(donation_id),
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);
INSERT INTO fund_allocations (donation_id,project_id,allocated_amount) VALUES
(1,1,10000),
(2,2,5000),
(3,1,40000),
(3,3,35000),
(4,2,12000),
(5,4,60000);
SELECT * FROM donors;
SELECT * FROM projects;
SELECT * FROM donations;
SELECT * FROM expenses;

-- Donor and Their Donations (INNER)
SELECT d.name, o.amount, o.donation_date
FROM donors d
INNER JOIN donations o
ON d.donor_id = o.donor_id;

-- All projects and their expenses(LEFT)
SELECT p.project_name, e.amount
FROM projects p
LEFT JOIN expenses e
ON p.project_id = e.project_id;

-- Donor → Donation → Project
SELECT d.name,
       p.project_name,
       f.allocated_amount
FROM fund_allocations f
JOIN donations o
ON f.donation_id = o.donation_id
JOIN donors d
ON o.donor_id = d.donor_id
JOIN projects p
ON f.project_id = p.project_id;

-- Total donation per donor (JOIN with GROUP BY)
SELECT d.name,
       SUM(o.amount) AS total_donation
FROM donors d
JOIN donations o
ON d.donor_id = o.donor_id
GROUP BY d.name;

-- Project + beneficiaries(JOIN with Beneficiaries)
SELECT p.project_name,
       b.support_type,
       b.age
FROM projects p
JOIN beneficiaries b
ON p.project_id = b.project_id;

-- VIEW
CREATE VIEW donor_summary AS
SELECT d.name, SUM(o.amount)
FROM donors d
JOIN donations o
ON d.donor_id=o.donor_id
GROUP BY d.name;
select * from donor_summary;

-- Stored Procedure – Project Expense Summary(Shows how much money each project spent)
DELIMITER $$
CREATE PROCEDURE project_expense_summary()
BEGIN
SELECT p.project_name,
SUM(e.amount) AS total_expense
FROM projects p
JOIN expenses e
ON p.project_id = e.project_id
GROUP BY p.project_name;
END $$
DELIMITER ;
CALL project_expense_summary();

-- Trigger – Automatic Donation Log (Whenever new donation is inserted system automatically stores it in a log table)
CREATE TABLE donation_log(
log_id INT AUTO_INCREMENT PRIMARY KEY,
donor_id INT,
amount DECIMAL(10,2),
log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER donation_after_insert
AFTER INSERT ON donations
FOR EACH ROW
INSERT INTO donation_log(donor_id,amount)
VALUES(NEW.donor_id,NEW.amount);
INSERT INTO donations(donor_id,amount,donation_date,payment_method)
VALUES(2,9000,'2024-06-10','UPI');
SHOW CREATE TRIGGER donation_after_insert;

-- TRANSACTION
START TRANSACTION;
-- Step 1: Insert a new donation
INSERT INTO donations (donor_id, amount, donation_date, payment_method)
VALUES (1, 15000, '2024-06-25', 'UPI');
-- Step 2: Allocate the donation to a project
INSERT INTO fund_allocations (donation_id, project_id, allocated_amount)
VALUES (LAST_INSERT_ID(), 1, 15000);
COMMIT;
rollback;
SELECT * FROM donations;

-- Total Donations Received
SELECT SUM(amount) AS total_donation
FROM donations;

