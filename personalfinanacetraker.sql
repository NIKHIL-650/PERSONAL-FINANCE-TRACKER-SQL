-- Step 1: Create Database
CREATE DATABASE PersonalFinanceTracker;
USE PersonalFinanceTracker;

-- Step 2: Create Tables
CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE
);

CREATE TABLE Categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL,
    type ENUM('Income', 'Expense') NOT NULL
);

CREATE TABLE Income (
    income_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    category_id INT,
    amount DECIMAL(10,2) NOT NULL,
    income_date DATE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

CREATE TABLE Expenses (
    expense_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    category_id INT,
    amount DECIMAL(10,2) NOT NULL,
    expense_date DATE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

-- Step 3: Insert Sample Data
INSERT INTO Users (name, email) VALUES
('Nikhil', 'nikhil@example.com'),
('Anusha', 'anusha@example.com');

INSERT INTO Categories (category_name, type) VALUES
('Salary', 'Income'),
('Freelancing', 'Income'),
('Food', 'Expense'),
('Rent', 'Expense'),
('Travel', 'Expense'),
('Shopping', 'Expense');

INSERT INTO Income (user_id, category_id, amount, income_date) VALUES
(1, 1, 50000.00, '2025-09-01'),
(1, 2, 10000.00, '2025-09-05'),
(2, 1, 40000.00, '2025-09-01');

INSERT INTO Expenses (user_id, category_id, amount, expense_date) VALUES
(1, 3, 3000.00, '2025-09-02'),
(1, 4, 15000.00, '2025-09-03'),
(1, 5, 2000.00, '2025-09-04'),
(2, 3, 2500.00, '2025-09-02'),
(2, 6, 5000.00, '2025-09-05');

-- Step 4: Useful Queries
-- All transactions (income + expenses)
SELECT u.name, c.category_name, i.amount, i.income_date
FROM Income i JOIN Users u ON i.user_id=u.user_id
JOIN Categories c ON i.category_id=c.category_id
UNION
SELECT u.name, c.category_name, e.amount, e.expense_date
FROM Expenses e JOIN Users u ON e.user_id=u.user_id
JOIN Categories c ON e.category_id=c.category_id;

-- Monthly income summary
SELECT u.name, YEAR(i.income_date) AS year, MONTH(i.income_date) AS month,
       SUM(i.amount) AS total_income
FROM Income i JOIN Users u ON i.user_id=u.user_id
GROUP BY u.name, YEAR(i.income_date), MONTH(i.income_date);

-- Monthly expense summary
SELECT u.name, YEAR(e.expense_date) AS year, MONTH(e.expense_date) AS month,
       SUM(e.amount) AS total_expenses
FROM Expenses e JOIN Users u ON e.user_id=u.user_id
GROUP BY u.name, YEAR(e.expense_date), MONTH(e.expense_date);

-- Category-wise spending
SELECT u.name, c.category_name, SUM(e.amount) AS total_spent
FROM Expenses e JOIN Users u ON e.user_id=u.user_id
JOIN Categories c ON e.category_id=c.category_id
GROUP BY u.name, c.category_name;

-- Balance (Income - Expenses)
SELECT u.name,
       (SELECT IFNULL(SUM(amount),0) FROM Income WHERE user_id=u.user_id) -
       (SELECT IFNULL(SUM(amount),0) FROM Expenses WHERE user_id=u.user_id) AS balance
FROM Users u;

-- Step 5: Create Views
CREATE VIEW Monthly_Report AS
SELECT u.name, YEAR(e.expense_date) AS year, MONTH(e.expense_date) AS month,
       (SELECT IFNULL(SUM(amount),0) FROM Income i WHERE i.user_id=u.user_id 
        AND YEAR(i.income_date)=YEAR(e.expense_date) 
        AND MONTH(i.income_date)=MONTH(e.expense_date)) AS total_income,
       SUM(e.amount) AS total_expenses
FROM Expenses e JOIN Users u ON e.user_id=u.user_id
GROUP BY u.name, YEAR(e.expense_date), MONTH(e.expense_date);

CREATE VIEW Balance_Tracker AS
SELECT u.name,
       (SELECT IFNULL(SUM(amount),0) FROM Income WHERE user_id=u.user_id) AS total_income,
       (SELECT IFNULL(SUM(amount),0) FROM Expenses WHERE user_id=u.user_id) AS total_expenses,
       (SELECT IFNULL(SUM(amount),0) FROM Income WHERE user_id=u.user_id) -
       (SELECT IFNULL(SUM(amount),0) FROM Expenses WHERE user_id=u.user_id) AS balance
FROM Users u;
