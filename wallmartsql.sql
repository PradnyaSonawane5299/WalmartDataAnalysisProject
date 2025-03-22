-- Active: 1732945778237@@127.0.0.1@3306@walmartdb
use walmartdb

select * from walmart;

select count(*) from walmart

SELECT payment_method, COUNT(*) from walmart GROUP BY payment_method;

SELECT COUNT(DISTINCT BRANCH) Branch FROM walmart;

SELECT MAX(quantity) FROM walmart;

SELECT MIN(quantity) FROM walmart;

--- Business Problems ---
-- 1. For each payment method find the number of transactions and the quantity sold
SELECT payment_method, COUNT(*) as no_of_payments,
 SUM(quantity) as no_of_quantity_sold 
 from walmart GROUP BY payment_method;

 -- 2. Identify the hightest rated category in each branch, displaying the branch, category, AVG Rating

 SELECT 
 branch, category,
 AVG(rating) as avg_rating
 FROM walmart
 GROUP BY branch, category
 ORDER BY branch, avg_rating DESC;

-- same as above using rank function
SELECT                                              
    branch,
    category,
    AVG(rating) as avg_rating,
    RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as rankk
 FROM walmart
 GROUP BY branch, category;


 -- to find the first rank 

SELECT * 
FROM
(
 SELECT 
    branch,
    category,
    AVG(rating) as avg_rating,
    RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as rankk
 FROM walmart
 GROUP BY branch, category
) as ranked_data
WHERE rankk = 1;

--3. Identify the busiest day based on the numer of transactions 
-- we have to convert date type to text

SELECT 
date,
DATE_FORMAT(STR_TO_DATE(date, '%d/%m/%y'), '%W') as day_name
FROM walmart;



SELECT * FROM  
(
SELECT 
branch,
DATE_FORMAT(STR_TO_DATE(date, '%d/%m/%y'), '%W') as day_name,
count (*) number_of_transactions,
RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) as rankk
FROM walmart
GROUP BY branch, day_name
) as ranked_data
WHERE rankk=1;


--4. Calculate the total quantity of items sold per payment_method.List payment_method and total_quantity
SELECT 
    payment_method,
    SUM(quantity) AS no_qty_sold
FROM walmart
GROUP BY payment_method;

-- Q5: Determine the average, minimum, and maximum rating of categories for each city
SELECT 
    city,
    category,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating,
    AVG(rating) AS avg_rating
FROM walmart
GROUP BY city, category;

--6.
SELECT category, 
SUM(total) as total_revenue,
SUM(total * profit_margin) as total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;

-- Q7: Determine the most common payment method for each branch
WITH cte AS (
    SELECT 
        branch,
        payment_method,
        COUNT(*) AS total_trans,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rankk
    FROM walmart
    GROUP BY branch, payment_method
)
SELECT branch, payment_method AS preferred_payment_method
FROM cte
WHERE rankk = 1;

-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts
SELECT
    branch,
    CASE 
        WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS num_invoices
FROM walmart
GROUP BY branch, shift
ORDER BY branch, num_invoices DESC;

-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)
WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;