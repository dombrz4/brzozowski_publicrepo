/*
1. Task: Create a list of all the different (distinct) replacement costs of the films.

Question: What's the lowest replacement cost?
*/

SELECT DISTINCT
	film_id,
	replacement_cost
FROM	
	film
ORDER BY 
	replacement_cost;
	
/*
2. Task: Write a query that gives an overview of how many films have replacements costs in the following cost ranges
low: 9.99 - 19.99
medium: 20.00 - 24.99
high: 25.00 - 29.99

Question: How many films have a replacement cost in the "low" group?
*/

SELECT
	COUNT(*) AS no_of_films,
CASE
WHEN replacement_cost BETWEEN 9.99 AND 19.99 THEN 'low'
WHEN replacement_cost BETWEEN 20.00 AND 24.99 THEN 'medium'
ELSE 'high'
END as cost_range
FROM
	film
GROUP BY
	cost_range
ORDER BY
	no_of_films;

/*
3. Task: Create a list of the film titles including their title, length, and category name ordered descendingly by length. Filter the results to only the movies in the category 'Drama' or 'Sports'.

Question: In which category is the longest film and how long is it?
*/
SELECT
	title,
	length,
	name AS category
FROM
	film f
LEFT JOIN
	film_category fc
ON
	f.film_id = fc.film_id
LEFT JOIN
	category c
ON
	fc.category_id = c.category_id
WHERE
	name = 'Drama' OR name = 'Sports'
ORDER BY
	length DESC;

/*
4. Task: Create an overview of how many movies (titles) there are in each category (name).

Question: Which category (name) is the most common among the films?
*/

SELECT
	name AS category,
	COUNT(*) AS no_of_films
FROM
	film f
LEFT JOIN
	film_category fc
ON
	f.film_id = fc.film_id
LEFT JOIN
	category c
ON
	fc.category_id = c.category_id
GROUP BY
	category
ORDER BY
	no_of_films DESC;

/*
5. Task: Create an overview of the actors' first and last names and in how many movies they appear in.

Question: Which actor is part of most movies?
*/


SELECT
	first_name,
	last_name,
	COUNT(*)
FROM
	actor a
LEFT JOIN
	film_actor fa
ON
	a.actor_id = fa.actor_id
GROUP BY
	first_name, last_name
ORDER BY
	count DESC;

/*
6. Task: Create an overview of the addresses that are not associated to any customer.

Question: How many addresses are that?
*/

SELECT
	address,
	customer_id
FROM
	address a
LEFT JOIN
	customer c
ON
	a.address_id = c.address_id
WHERE customer_id is null;

/*
7. Task: Create the overview of the sales  to determine the from which city (we are interested in the city in which the customer lives, not where the store is) most sales occur.

Question: What city is that and how much is the amount?
*/

SELECT
	city,
	SUM(amount) total_amount,
	COUNT(*) no_of_payments
FROM
	payment p
LEFT JOIN
	customer c
ON
	p.customer_id = c.customer_id
LEFT JOIN
	address a
ON
	c.address_id = a.address_id
LEFT JOIN
	city ci
ON
	a.city_id = ci.city_id
GROUP BY
	city
ORDER BY
	total_amount DESC;

/*
8. Task: Create an overview of the revenue (sum of amount) grouped by a column in the format "country, city".

Question: Which country, city has the least sales?
*/

SELECT
	country || ', ' || city AS country_city,
	SUM(amount) AS revenue
FROM
	payment p
LEFT JOIN
	customer c
ON
	p.customer_id = c.customer_id
LEFT JOIN
	address a
ON
	c.address_id = a.address_id
LEFT JOIN
	city ci
ON
	a.city_id = ci.city_id
LEFT JOIN
	country co
ON
	ci.country_id = co.country_id
GROUP BY
	country_city
ORDER BY
	revenue;

/*
9. Task: Create a list with the average of the sales amount each staff_id has per customer.

Question: Which staff_id makes on average more revenue per customer?
*/

SELECT
	staff_id,
	ROUND(AVG(total_per_customer), 2) AS avg_per_customer
FROM (
	SELECT SUM(amount) AS total_per_customer, customer_id, staff_id
	FROM payment
	GROUP BY customer_id, staff_id
	ORDER BY customer_id
	) AS sub_payment
GROUP BY
	staff_id;

/*
10. Task: Create a query that shows average daily revenue of all Sundays.

Question: What is the daily average revenue of all Sundays?
*/

SELECT
	ROUND(AVG(sum), 2) AS avg_daily_revenue_sunday
FROM (
	SELECT
		date(payment_date) AS date,
		SUM(amount)
	FROM
		payment
	WHERE
		EXTRACT(DOW from payment_date) = 0
	GROUP BY
		date
	) AS sub_payment;

/*
11. Task: Create a list of movies - with their length and their replacement cost - that are longer than the average length in each replacement cost group.

Question: Which two movies are the shortest on that list and how long are they?
*/

SELECT
	title,
	length,
	replacement_cost
FROM
	film f
WHERE
	length > (
	SELECT
		AVG(length)
	FROM
		film sub_f
	WHERE
		f.replacement_cost = sub_f.replacement_cost
	)
ORDER BY length;

/*
12. Task: Create a list that shows the "average customer lifetime value" grouped by the different districts.

Example:
If there are two customers in "District 1" where one customer has a total (lifetime) spent of $1000 
and the second customer has a total spent of $2000 
then the "average customer lifetime spent" in this district is $1500.

Question: Which district has the highest average customer lifetime value?
*/

SELECT
	district,
	ROUND(AVG(singular_customer_total), 2) AS avg_lifetime_value
FROM
	(
	SELECT
		district,
		p.customer_id,
		SUM(amount) AS singular_customer_total
	FROM
		payment p
	LEFT JOIN
		customer c
	ON
		p.customer_id = c.customer_id
	LEFT JOIN
		address a
	ON
		c.address_id = a.address_id
	GROUP BY p.customer_id, district
	ORDER BY district
	)
GROUP BY 
	district
ORDER BY
	avg_lifetime_value DESC;

/*
13. Task: Create a list that shows all payments including the payment_id, amount, and the film category (name) plus the total amount that was made in this category. 
Order the results ascendingly by the category (name) and as second order criterion by the payment_id ascendingly.

Question: What is the total revenue of the category 'Action' and what is the lowest payment_id in that category 'Action'?
*/

SELECT
	payment_id,
	amount,
	name AS category,
	(
	SELECT
		SUM(amount)
	FROM
		payment sub_p
	LEFT JOIN
		rental r
	ON
		p.rental_id = r.rental_id
	LEFT JOIN
		inventory i
	ON
		r.inventory_id = i.inventory_id
	LEFT JOIN
		film_category fc
	ON
		i.film_id = fc.film_id
	LEFT JOIN
		category cat1
	ON
		fc.category_id = cat.category_id
	WHERE
		cat1.name = cat.name
	)
FROM
	payment p
LEFT JOIN
	rental r
ON
	p.rental_id = r.rental_id
LEFT JOIN
	inventory i
ON
	r.inventory_id = i.inventory_id
LEFT JOIN
	film_category fc
ON
	i.film_id = fc.film_id
LEFT JOIN
	category cat
ON
	fc.category_id = cat.category_id
ORDER BY
	category, payment_id;

/*
14. Task: Create a list with the top overall revenue of a film title (sum of amount per title) for each category (name).

Question: Which is the top-performing film in the animation category?
*/

SELECT
	title,
	name,
	SUM(amount) AS total
FROM
	payment p
LEFT JOIN
	rental r
ON
	r.rental_id=p.rental_id
LEFT JOIN 
	inventory i
ON 
	i.inventory_id=r.inventory_id
LEFT JOIN 
	film f
ON 
	f.film_id=i.film_id
LEFT JOIN 
	film_category fc
ON 
	fc.film_id=f.film_id
LEFT JOIN 
	category cat
ON 
	cat.category_id=fc.category_id
GROUP BY
	name, 
	title
HAVING
	SUM(amount) =
		(
		SELECT
			MAX(total)
		FROM
			(
			SELECT
				title, 
				name,
				SUM(amount) as total
				FROM 
					payment p
			    LEFT JOIN 
					rental r
			    ON 
					r.rental_id=p.rental_id
			    LEFT JOIN 
					inventory i
			    ON 
					i.inventory_id=r.inventory_id
				LEFT JOIN
					film f
				ON
					f.film_id=i.film_id
				LEFT JOIN
					film_category fc
				ON
					fc.film_id=f.film_id
				LEFT JOIN
					category cat1
				ON 
					cat1.category_id=fc.category_id
				GROUP BY 
					name,
					title
					) sub
			WHERE 
				cat.name = sub.name
			)

