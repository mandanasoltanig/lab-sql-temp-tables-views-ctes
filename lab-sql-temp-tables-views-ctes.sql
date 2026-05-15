USE sakila;

-- Step 1:
CREATE VIEW customer_rental_summary AS 
SELECT
    customer_table.customer_id,
    customer_table.first_name,
    customer_table.last_name,
    customer_table.email,
    COUNT(rental_table.rental_id) AS rental_count
FROM customer customer_table
LEFT JOIN rental rental_table
ON customer_table.customer_id = rental_table.customer_id
GROUP BY
    customer_table.customer_id, 
    customer_table.first_name,
    customer_table.last_name,
    customer_table.email;

-- Step 2:
CREATE TEMPORARY TABLE customer_payment AS 
SELECT 
    customer_rental_summary.customer_id,
    customer_rental_summary.first_name,
    customer_rental_summary.last_name,
    customer_rental_summary.email,
    customer_rental_summary.rental_count,
    SUM(payment_table.amount) AS total_paid
FROM customer_rental_summary
LEFT JOIN payment payment_table
ON customer_rental_summary.customer_id = payment_table.customer_id
GROUP BY 
    customer_rental_summary.customer_id, 
    customer_rental_summary.first_name,
    customer_rental_summary.last_name,
    customer_rental_summary.email,
    customer_rental_summary.rental_count;

-- Step 3:
WITH customer_summary_cte AS (
SELECT
    CONCAT(customer_rental_summary.first_name, ' ', customer_rental_summary.last_name) AS customer_name, 
    customer_rental_summary.email,
    customer_rental_summary.rental_count,
    customer_payment.total_paid
FROM customer_rental_summary
JOIN customer_payment
ON customer_rental_summary.customer_id = customer_payment.customer_id
)
SELECT
    customer_name, 
    email,
    rental_count,
    total_paid,
    ROUND(total_paid / NULLIF(rental_count, 0), 2) AS average_payment_per_rental
FROM customer_summary_cte;