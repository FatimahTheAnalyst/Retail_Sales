-- CREATE TABLE 
CREATE TABLE retail(
	transactions_id	INT PRIMARY KEY,
	sale_date DATE,
	sale_time TIME,
	customer_id INT,
	gender CHAR(1), 
	age INT,
	category VARCHAR(30),
	quantity INT,
	price_per_unit FLOAT,
	cogs FLOAT,
	total_sale FLOAT
);

--  Data Exploration & Cleaning

-- Total number of records in the dataset.
SELECT COUNT(*) FROM retail;

-- How many unique customers are in the dataset.
SELECT  COUNT(DISTINCT customer_id) FROM retail;

-- Identify all unique product categories in the dataset.
SELECT  DISTINCT (category) FROM retail;

-- Check for any null values in the dataset 
SELECT * FROM retail
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL 
	OR gender IS NULL OR age IS NULL OR category IS NULL 
	OR quantity IS NULL OR price_per_unit IS NULLOR cogs IS NULL;

-- Delete records with missing data.
DELETE FROM retail
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;

-- Data Analysis
-- 1. What is the total number of transactions, and how do they break down by category and gender?
SELECT 
    category,
    gender,
    COUNT(*) as total_trans,
	ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage_of_total
FROM retail
GROUP BY 
   (category,
    gender)
ORDER BY 1

-- 2. What is the total and average sales revenue per product category?
SELECT
	  category,
        SUM(total_sale) AS total_sale,
        ROUND(AVG(total_sale)) AS avg_sale
    FROM retail
GROUP BY category
ORDER BY total_sale DESC;

-- 3. Which gender contributes more to overall sales? What does the average sale per transaction look like for each gender?
SELECT 
    gender,
    SUM(total_sale) AS total_sales,
    ROUND(AVG(total_sale)::numeric, 2) AS avg_sales,
    ROUND((SUM(total_sale) * 100.0 / SUM(SUM(total_sale)) OVER ())::numeric, 2) AS pct_of_total_sales
FROM retail
GROUP BY gender
ORDER BY total_sales DESC;

-- 4. What is the average quantity purchased and average unit price for each category? Which categories tend to have larger cart sizes?
SELECT 
		Category,
		ROUND(AVG(quantity)::numeric, 2) AS avg_qty,
		ROUND(AVG(price_per_unit)::numeric, 2) AS avg_unit_price
FROM retail
GROUP BY category
ORDER BY 2 DESC;

-- 5. Who are the top 5 customers by total spending?
SELECT 
	customer_id,
	COUNT(*) AS total_transactions,
	SUM(total_sale) AS total_spending
FROM retail
GROUP BY customer_id
ORDER BY total_spending DESC
LIMIT 5

-- 6. which month had the highest sales in each year?
WITH monthly_sales AS (
    SELECT 
        EXTRACT(YEAR FROM sale_date) AS year,
        TO_CHAR(sale_date, 'Month') AS month,
        TO_CHAR(sale_date, 'MM') AS month_number,
        SUM(total_sale) AS total_monthly_sales
    FROM retail
    GROUP BY year, month, month_number
)
SELECT *
FROM (
    SELECT *,
        RANK() OVER (PARTITION BY year ORDER BY total_monthly_sales DESC) AS rank_in_year
    FROM monthly_sales
) ranked
WHERE rank_in_year = 1
ORDER BY year;

-- 7. How many unique customers purchased items from each category? Are some categories dependent on repeat buyers or one-time customers?
SELECT 
    category,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(customer_id) AS total_transactions,
	ROUND(1.0 * COUNT(customer_id) / COUNT(DISTINCT customer_id), 2) AS avg_transactions_per_customer
FROM retail
GROUP BY category
ORDER BY unique_customers DESC;
		
-- 8. What is the average age of customers for each category? Do certain categories attract younger or older demographics?
SELECT 
		category,
		ROUND(AVG(age)::numeric, 2) AS avg_customer_age
FROM retail
GROUP BY category
ORDER BY avg_customer_age
-- 9. How do sales vary by time of day (Morning, Afternoon, Evening)? Which shift generates the most orders?
SELECT
  CASE
    WHEN sale_time <= '12:00:00' THEN 'Morning'
    WHEN sale_time > '12:00:00' AND sale_time <= '17:00:00' THEN 'Afternoon'
    ELSE 'Evening'
  END AS shift,
  COUNT(*) AS total_orders,
  ROUND(SUM(total_sale)::numeric) AS total_sales
FROM retail
GROUP BY shift
ORDER BY total_orders DESC;

-- 10. What percentage of transactions had a quantity above 10? How often do large orders occur, and in which categories?
WITH large_orders AS (
    SELECT *
    FROM retail
    WHERE quantity > 3
)

SELECT 
    category,
    COUNT(*) AS large_order_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM retail), 2) AS percentage_of_total,
    ROUND(AVG(quantity), 2) AS avg_large_quantity
FROM large_orders
GROUP BY category
ORDER BY percentage_of_total DESC;






























































































	