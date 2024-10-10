-- user-defined FUNCTION

CREATE OR REPLACE FUNCTION count_rr (min_r decimal(4,2), max_r decimal(4,2))
RETURNS INT
LANGUAGE plpgsql
AS
$$
DECLARE
movie_count INT;
BEGIN
SELECT COUNT(*)
INTO movie_count
FROM film
WHERE rental_rate BETWEEN min_r AND max_r;
RETURN movie_count;
END;
$$
;

SELECT count_rr(3,6);

CREATE OR REPLACE FUNCTION name_search (f_name VARCHAR(20), l_name VARCHAR(20))
RETURNS numeric
LANGUAGE plpgsql
AS
$$
DECLARE
customer_total numeric;
BEGIN
SELECT SUM(amount)
INTO customer_total
FROM payment
NATURAL JOIN customer
WHERE first_name = f_name AND last_name = l_name;
RETURN customer_total;
END;
$$
;

SELECT 
	first_name,
	last_name,
	name_search(first_name, last_name) AS customer_total
FROM
	customer;

-- TRANSACTION / WORK / or just BEGIN; not visible in other sessions before COMMIT

CREATE TABLE IF NOT EXISTS acc_balance (
    id SERIAL PRIMARY KEY,
    first_name TEXT NOT NULL,
	last_name TEXT NOT NULL,
    amount DEC(9,2) DEFAULT 0.00   
);

-- INSERT INTO acc_balance
-- VALUES 
-- (1,'Tim','Brown', 2600),
-- (2,'Sandra','Miller', 3200);

SELECT * FROM acc_balance;

-- BEGIN;
-- UPDATE acc_balance
-- SET amount = amount -100
-- WHERE id = 2;
-- UPDATE acc_balance
-- SET amount = amount +100
-- WHERE id = 1;
-- COMMIT;

-- BEGIN;
-- UPDATE emp_info
-- SET position_title = 'Head of Sales'
-- WHERE emp_id = 2;
-- UPDATE emp_info
-- SET position_title = 'Head of BI'
-- WHERE emp_id = 3;
-- UPDATE emp_info
-- SET salary = 12587
-- WHERE emp_id = 2;
-- UPDATE emp_info
-- SET salary = 14614
-- WHERE emp_id = 3;
-- COMMIT;

SELECT * FROM emp_info;

-- ROLLBACK allows to undo a transaction, ROLLBACK TO SAVEPOINT does not abort the transaction but rolls back to a specified point

-- BEGIN;
-- UPDATE acc_balance
-- SET amount = amount -100
-- WHERE id = 2;
-- UPDATE acc_balance
-- SET amount = amount +100
-- WHERE id = 1;
-- SAVEPOINT s1;
-- DELETE FROM acc_balance
-- WHERE id = 1;
-- ROLLBACK TO SAVEPOINT s1;
-- COMMIT;


-- STORED PROCEDURES

CREATE OR REPLACE PROCEDURE sp_transfer
(tr_amount numeric, sender INT, recipient INT)
LANGUAGE plpgsql
AS
$$
BEGIN
-- add balance
UPDATE acc_balance
SET amount = amount + tr_amount
WHERE id = recipient;
-- subtract balance
UPDATE acc_balance
SET amount = amount - tr_amount
WHERE id = sender;
COMMIT;
END;
$$

-- CALL sp_transfer (500,1,2);

CREATE OR REPLACE PROCEDURE emp_swap (emp1 INT, emp2 INT)
LANGUAGE plpgsql
AS
$$
DECLARE 
	emp1_title VARCHAR(30);
	emp1_salary DECIMAL(8,2);
	emp2_title VARCHAR(30);
	emp2_salary DECIMAL(8,2);
BEGIN

-- store values in variables
SELECT position_title
INTO emp1_title
FROM emp_info
WHERE emp_id = emp1;

SELECT position_title
INTO emp2_title
FROM emp_info
WHERE emp_id = emp2;

SELECT salary
INTO emp1_salary
FROM emp_info
WHERE emp_id = emp1;

SELECT salary
INTO emp2_salary
FROM emp_info
WHERE emp_id = emp2;

-- swap titles
UPDATE emp_info
SET position_title = emp2_title
WHERE emp_id = emp1;

UPDATE emp_info
SET position_title = emp1_title
WHERE emp_id = emp2;

-- swap salaries
UPDATE emp_info
SET salary = emp2_salary
WHERE emp_id = emp1;

UPDATE emp_info
SET salary = emp1_salary
WHERE emp_id = emp2;

COMMIT;
END;
$$
;

SELECT * FROM emp_info
ORDER BY emp_id;
CALL emp_swap (3,4);
