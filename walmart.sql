 SELECT * FROM walmart

 -- number of payments for each payment methods 
SELECT PAYMENT_METHOD,COUNT(*)
FROM WALMART
GROUP BY PAYMENT_METHOD

--Drop tabel to change to lower case of Brance and City column  names
drop table walmart

--distinct branch 
SELECT COUNT(DISTINCT branch )
FROM walmart

--max quantity
SELECT MAX(quantity)
FROM walmart 


--Business Problems

--Q1) What are the different payment methods, and how many transactions and Quantity sold with each method?

SELECT PAYMENT_METHOD,
       COUNT(*) as no_payments,
	   SUM(quantity) as no_qnt_sold
FROM WALMART
GROUP BY PAYMENT_METHOD

--Q2) Identify the highest-rated category in each branch , displaying the branch and category avg rating

SELECT * 
FROM
			(SELECT 
			    branch,
				category,
			    AVG(rating) as avg_rating,
				RANK() OVER( PARTITION BY branch ORDER BY AVG(rating)DESC) as rank
			FROM walmart
			GROUP BY branch, category 
			ORDER BY branch, avg_rating DESC )
WHERE RANK=1		

--Q3) Identify the busiest day for each branch on the number of transactions
SELECT *
FROM
		(SELECT 
		  branch,
		  TO_CHAR(TO_DATE(date,'DD/MM/YY'), 'Day') as day_name,
		  COUNT(*) as no_transactions,
		  RANK() OVER (PARTITION BY branch ORDER BY COUNT(*)DESC) as rank
		FROM walmart
		GROUP BY branch, day_name)
WHERE RANK=1

--Q4) Calculate the total quantity of items sold per payment method. List payment_method and total_quantity .

SELECT PAYMENT_METHOD,
	   SUM(quantity) as no_qnt_sold
FROM WALMART
GROUP BY PAYMENT_METHOD

-- Q5) Determine the average, minimum, and maximum rating of categories for each city.List the city, avg_rating,max_rating,min_rating

SELECT
		city,
		category,
		AVG(rating)as avg_rating,
		MAX(rating) as max_rating,
		MIN(rating) as min_rating
 

FROM walmart
GROUP BY city, category

-- Q6) Calculate the total profit for each category by considering total_profit as(unit_price * profit * profit_margin)
--List category aand total_profit, ordered from highest to lowest profit

	SELECT 
			category,
			SUM(total) as revenue,
			SUM(total*profit_margin) as profit
			
	FROM walmart
	GROUP BY category 

-- Q7) Determine the most common payment method for each branch, Diplay branch and preferred_payment_methods

SELECT *
FROM
	(SELECT 
			branch ,
			payment_method,
			COUNT (*) as total_trans,
			RANK() OVER(PARTITION BY branch  ORDER BY COUNT(*) DESC) as rank
	FROM walmart
	GROUP BY branch, payment_method)
WHERE rank=1

--Q8) Categorize sales into Morning, Afternoon, and Evening shifts
-- Find out each of the shifts and no of invoices 
SELECT
  	branch,
   		CASE 
		   WHEN EXTRACT(HOUR FROM(time::time)) <12 THEN 'Morning'	
		   WHEN EXTRACT(HOURS FROM (time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		   ELSE 'Evening'
		END  day_time,
		COUNT(*)
		   
FROM walmart
GROUP BY 1,2
ORDER BY 1,3 DESC 

-- Q9: Identify the 5 branches with the highest revenue decrease ratio in
-- from last year to current year (e.g., 2022 to 2023)


SELECT *,
EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) as formated_date
FROM walmart

-- 2022 sales
WITH revenue_2022
AS
(
	SELECT 
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022 -- psql
	-- WHERE YEAR(TO_DATE(date, 'DD/MM/YY')) = 2022 -- mysql
	GROUP BY 1
),

revenue_2023
AS
(

	SELECT 
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
	GROUP BY 1
)

SELECT 
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as cr_year_revenue,
	ROUND(
		(ls.revenue - cs.revenue)::numeric/
		ls.revenue::numeric * 100, 
		2) as rev_dec_ratio
FROM revenue_2022 as ls
JOIN
revenue_2023 as cs
ON ls.branch = cs.branch
WHERE 
	ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5
