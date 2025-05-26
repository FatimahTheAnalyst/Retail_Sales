# Retail Sales SQL Project

## Project Overview

**Project Title**: Retail Sales Analysis  
**Level**: Beginner  
**Database**: `Retail Sales Project_db`

This project focuses on building a structured retail sales database and conducting exploratory data analysis (EDA) to uncover key business insights. Using SQL, I dive into real-world sales data to answer impactful business questions, helping stakeholders make smarter decisions through data-driven storytelling.



## Objectives

1. **Set up the retail sales database**: Build and populate a robust database with the provided sales data to ensure a reliable analytical foundation..
2. **Clean and prepare the data**: Detect and handle missing or null values to maintain data integrity for accurate analysis.
3. **Exploratory Data Analysis (EDA)**: Perform exploratory data analysis (EDA) to uncover key patterns, trends, and insights.
4. **Analyze business questions with SQL**: Use targeted SQL queries to extract actionable insights that address core business challenges.
5. **Findings and recommendations**: Summarize insights clearly and provide strategic recommendations to drive informed business decisions.


## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `Retail Sales Project_db`.
- **Table Creation**: A table named `retail` is created to store the sales data. The table structure includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity, price per unit, cost of goods sold (COGS), and total sale amount.

```sql
CREATE DATABASE Retail Sales Project_db;

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
```

### 2. Data Exploration & Cleaning

- **Record Count**: Determine the total number of records in the dataset.
- **Customer Count**: Find out how many unique customers are in the dataset.
- **Category Count**: Identify all unique product categories in the dataset.
- **Null Value Check**: Check for any null values in the dataset and delete records with missing data.

```sql
SELECT COUNT(*) FROM retail;
SELECT  COUNT(DISTINCT customer_id) FROM retail;
SELECT  DISTINCT (category) FROM retail;
SELECT * FROM retail
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL 
	OR gender IS NULL OR age IS NULL OR category IS NULL 
	OR quantity IS NULL OR price_per_unit IS NULLOR cogs IS NULL;

DELETE FROM retail
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;
```

### 3. Data Analysis

The following SQL queries were developed to answer specific business questions:

1. **What is the total number of transactions, and how do they break down by category and gender?**:
```sql
SELECT 
    category,
    gender,
    COUNT(*) as total_trans,
	ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage_of_total
FROM retail
GROUP BY 
   (category,
    gender)
ORDER BY 1;
```

2. **What is the total and average sales revenue per product category?
```sql
SELECT
	  category,
        SUM(total_sale) AS total_sale,
        ROUND(AVG(total_sale)) AS avg_sale
    FROM retail
GROUP BY category
ORDER BY total_sale DESC;
```

3. ** Which gender contributes more to overall sales? What does the average sale per transaction look like for each gender?**:
```sql
SELECT 
    gender,
    SUM(total_sale) AS total_sales,
    ROUND(AVG(total_sale)::numeric, 2) AS avg_sales,
    ROUND((SUM(total_sale) * 100.0 / SUM(SUM(total_sale)) OVER ())::numeric, 2) AS pct_of_total_sales
FROM retail
GROUP BY gender
ORDER BY total_sales DESC;
```

4. **What is the average quantity purchased and average unit price for each category? Which categories tend to have larger cart sizes?**:
```sql
SELECT 
		Category,
		ROUND(AVG(quantity)::numeric, 2) AS avg_qty,
		ROUND(AVG(price_per_unit)::numeric, 2) AS avg_unit_price
FROM retail
GROUP BY category
ORDER BY 2 DESC;
```

5. **Who are the top 5 customers by total spending?**:
```sql
SELECT 
	customer_id,
	COUNT(*) AS total_transactions,
	SUM(total_sale) AS total_spending
FROM retail
GROUP BY customer_id
ORDER BY total_spending DESC
LIMIT 5
```

6. **which month had the highest sales in each year?**:
```sql
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
```

7. **How many unique customers purchased items from each category? Are some categories dependent on repeat buyers or one-time customers?**:
```sql
SELECT 
    category,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(customer_id) AS total_transactions,
	ROUND(1.0 * COUNT(customer_id) / COUNT(DISTINCT customer_id), 2) AS avg_transactions_per_customer
FROM retail
GROUP BY category
ORDER BY unique_customers DESC;
```

8. **What is the average age of customers for each category? Do certain categories attract younger or older demographics?**:
```sql
SELECT 
		category,
		ROUND(AVG(age)::numeric, 2) AS avg_customer_age
FROM retail
GROUP BY category
ORDER BY avg_customer_age
```

9. **How do sales vary by time of day (Morning, Afternoon, Evening)? Which shift generates the most orders?**:
```sql
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
```

10. **What percentage of transactions had a quantity above 3? How often do large orders occur, and in which categories?**:
```sql
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
```

## Findings
Our analysis of transaction data reveals compelling insights into customer behavior, sales performance, and shopping patterns across product categories and demographics.
- **Transaction Volume and Customer Demographics**: The total number of transactions shows that Clothing and Electronics dominate purchase volume, with male customers slightly leading in transaction counts. When examining sales revenue, Electronics emerges as the top-performing category, contributing the highest total and average sales amounts of $311445 and $309995 respectively, indicating both popularity and strong purchase value.
- **Gender-Based Spending Patterns**: Gender-wise, female customers contribute 50.99% of overall sales and have a higher average sale per transaction, highlighting opportunities for targeted marketing to maintain and grow this segment. On the other hand, the average quantity and unit price data reveal that categories like Clothing tend to have larger cart sizes, while some categories have higher unit prices, reflecting premium positioning.
- **High-Value Customers and Loyalty Potential**: An analysis of the top 5 customers by total spending reveals significant contributions to overall revenue, indicating their high value to the business. They  are not only frequent shoppers but also consistent spenders, making them ideal candidates for personalized loyalty programs, early access offers, or exclusive rewards.
- **Repeat vs. One-Time Buyers by Category**: Customer purchasing frequency varies subtly across product categories, Electronics leads slightly with an average of 4.71 transactions per customer, followed closely by Clothing at 4.68, suggesting that these categories attract more repeat purchases. This indicates a steady customer interest possibly driven by varied product options or recurring needs. In contrast, Beauty records a lower average of 4.33 transactions per customer, hinting at a larger proportion of one-time buyers or less frequent repeat purchases. This trend may reflect trial-based buying or gifting behavior.
- **Age Demographics and Category Preferences**: Beauty products attract a relatively younger audience with an average age of 40.42, while Electronics and Clothing appeal more to slightly older customers, averaging 41.60 and 41.93 years respectively. 
- **Sales by Time of Day**:The Evening shift drives the highest transaction volume, suggesting that operational and marketing focus during this period can yield better results.

## Recommendations 

- **Tailor Marketing by Gender and Product Affinity**: Capitalize on female shoppers' higher average spending and interest in premium items. Develop targeted campaigns and bundle offers based on gender-product dynamics, especially for categories like Clothing and Electronics.
- **Launch Loyalty Programs for High-Spending Customers**: Introduce tiered rewards or VIP access for top customers who show both high transaction frequency and total spend. This builds retention and increases lifetime value.
- **Boost Repeat Purchases Through Engagement Tactics**: Leverage product categories with strong repeat buying behavior such as Electronics and Clothing with reminders, upsells, or loyalty perks. For Beauty, consider trial-to-subscription strategies to convert one-time buyers into loyal customers.
- **Design Demographic-Specific Campaigns**: Use age insights to drive messaging promote Beauty with trend-based language and influencer partnerships for younger buyers, and focus on durability, value, and reliability for Electronics and Clothing to appeal to slightly older customers.
- **Maximize Evening Sales with Targeted Promotions**: Since the Evening is the busiest transaction period, increase visibility and promotions during this time. Run flash sales, retargeting ads, or limited-time offers to drive urgency during peak shopping hours.

## Conclusion
This analysis highlights critical patterns in customer behavior, category performance, and transaction trends that can directly inform business strategy and marketing decisions. From identifying high-value customers and peak sales periods to uncovering category preferences by age and purchase frequency, the data offers actionable insights that can improve both customer engagement and revenue generation.
