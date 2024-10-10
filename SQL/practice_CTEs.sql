/*
Challenge:
- Create a CTE to calculate the total rental count and total rental amount for each customer.
- Use the CTE to filter customers who have rented more than the average number of films.
*/


-- Step 1

WITH customer_stats AS (
    SELECT 
		c.customer_id,
		c.first_name,
		c.last_name,
		COUNT(r.rental_id) AS rental_count,
		SUM(p.amount) AS total_amount
    FROM 
		customer c
    JOIN 
		rental r 
		ON c.customer_id = r.customer_id
    JOIN 
		payment p 
		ON c.customer_id = p.customer_id AND p.rental_id = r.rental_id
    GROUP BY 
		c.customer_id, c.first_name, c.last_name
)
 
-- Step 2

SELECT
	customer_id,
	first_name,
	last_name,
	rental_count,
	total_amount
FROM
	customer_stats
WHERE
	rental_count > (SELECT AVG(rental_count) FROM customer_stats);

/*
Challenge:
- Create a CTE to calculate the total rental count and total rental amount for each customer.
- Create a CTE to calculate the average rental count across all customers.
- Create a CTE to identify customers who have rented more than the average number of films (high-rental customers).
- List the details of the films rented by these high-rental customers.
*/

-- Step 1, 2, 3

WITH 
customer_stats AS (
    SELECT 
		c.customer_id,
		c.first_name,
		c.last_name,
		COUNT(r.rental_id) AS rental_count,
		SUM(p.amount) AS total_amount
    FROM 
		customer c
    JOIN 
		rental r 
		ON c.customer_id = r.customer_id
    JOIN 
		payment p 
		ON c.customer_id = p.customer_id AND p.rental_id = r.rental_id
    GROUP BY 
		c.customer_id, c.first_name, c.last_name
),

avg_rental_count AS (
SELECT
	AVG(rental_count) AS avg_rental_count
FROM
	customer_stats
),

high_rental_customers AS (
SELECT
	customer_id,
	first_name,
	last_name,
	rental_count,
	total_amount
FROM
	customer_stats
WHERE
	rental_count > (SELECT avg_rental_count FROM avg_rental_count)
)

-- Step 4

SELECT
	hrc.customer_id,
	hrc.first_name,
	hrc.last_name,
	hrc.rental_count,
	hrc.total_amount,
	f.film_id,
	f.title
FROM
	high_rental_customers hrc
JOIN 
	rental r ON hrc.customer_id = r.customer_id
JOIN
	inventory i ON r.inventory_id = i.inventory_id
JOIN
	film f ON i.film_id = f.film_id
ORDER BY
	customer_id;

/*
Challenge: Use a recursive CTE to find all subordinates of a given employee.
*/

-- Create the employee table
CREATE TABLE IF NOT EXISTS employee (
    employee_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    manager_id INTEGER REFERENCES employee(employee_id)
);
 
-- -- Insert sample data to establish an employee hierarchy
-- INSERT INTO employee (employee_id, name, manager_id) VALUES
-- (1, 'Alice', NULL),       -- Alice is the CEO, no manager
-- (2, 'Bob', 1),            -- Bob reports to Alice
-- (3, 'Charlie', 1),        -- Charlie reports to Alice
-- (4, 'David', 2),          -- David reports to Bob
-- (5, 'Eve', 2),            -- Eve reports to Bob
-- (6, 'Frank', 3);          -- Frank reports to Charlie

WITH RECURSIVE emp_subordinates AS (
	SELECT e.employee_id, e.name, e.manager_id, 1 AS level
    FROM employee e
    WHERE e.employee_id = 1

	UNION ALL

	SELECT e.employee_id, e.name, e.manager_id, es.level + 1 AS level
    FROM employee e
    INNER JOIN emp_subordinates es ON e.manager_id = es.employee_id
	
)

SELECT employee_id, name, manager_id, level
FROM emp_subordinates;