USE apple_price;

DROP TABLE IF EXISTS apple_pricing;

CREATE TABLE apple_pricing (
    date_raw VARCHAR(20),
    platform VARCHAR(20),
    product_category VARCHAR(30),
    model_name VARCHAR(50),
    `condition` VARCHAR(20),
    launch_price_usd INT,
    launch_price_inr INT,
    current_price_usd FLOAT,
    current_price_inr FLOAT,
    discount_pct FLOAT,
    sale_event VARCHAR(30),
    stock_status VARCHAR(20),
    rating FLOAT,
    reviews_count INT,
    z_score INT
);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/apple_pricing_clean.csv'
INTO TABLE apple_pricing
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM apple_pricing;

# Q1 Get all distinct product_category values

SELECT DISTINCT product_category 
FROM apple_pricing;

#Q2 Find total number of rows for each platform

SELECT platform, count(*)
FROM apple_pricing
GROUP BY platform;

#Q3 Get all rows where condition = 'Refurbished' 

SELECT model_name,`condition`,current_price_inr
FROM apple_pricing
WHERE `condition` ="Referbished"
ORDER BY model_name;

#Q4  Find the average current_price_usd for each product_category.

SELECT product_category, ROUND(AVG(current_price_usd),2) AS Average 
FROM apple_pricing
GROUP BY product_category
ORDER BY Average DESC;

#Q5 List all rows where discount_pct is negative.

SELECT model_name,product_category,`condition`,current_price_inr,launch_price_inr,discount_pct FROM apple_pricing
WHERE discount_pct<0;

#Q6 Find the top 5 model_name with the highest average current_price_usd.

SELECT model_name,ROUND(AVG(current_price_usd),2) AS Average
FROM apple_pricing
GROUP BY model_name
ORDER BY Average DESC
LIMIT 5;

#Q7 For each sale_event, find the average discount given (excluding "Regular Sale")

SELECT sale_event, ROUND(AVG(discount_pct),2) AS Average_Discount
FROM apple_pricing
WHERE sale_event != "Regular Sale"
GROUP BY sale_event
ORDER BY Average_Discount DESC;

#Q8  Find the number of "Out of Stock" rows per platform.

SELECT platform, COUNT(stock_status) AS total_out_of_stock
FROM apple_pricing
WHERE stock_status = "Out of stock"
GROUP BY platform
ORDER BY total_out_of_stock;

#Q9 Find the month with the highest number of listings overall (GROUP BY on date).

SELECT DATE_FORMAT(STR_TO_DATE(date_raw, '%d-%m-%Y'), '%Y-%m') AS year_mont, COUNT(*) AS total_listings
FROM apple_pricing
GROUP BY year_mont
ORDER BY total_listings DESC
LIMIT 1;

#Q10 Find products where current_price_usd > launch_price_usd (price went up) — count how many per category.

SELECT product_category,COUNT(*) AS Price_Went_Up
FROM apple_pricing
WHERE current_price_usd>launch_price_usd
GROUP BY product_category
ORDER BY Price_Went_Up DESC;

#Q11 For each model_name, find the row with the lowest current_price_usd ever recorded 
SELECT model_name,current_price_usd
FROM (
SELECT DISTINCT model_name,current_price_usd,
RANK()
OVER( PARTITION BY model_name ORDER BY current_price_usd ) AS Price_Rank
FROM apple_pricing)ranked
WHERE Price_Rank = 1
ORDER BY current_price_usd;

#Q12 Find the month-over-month average price change for each product_category using LAG().
SELECT product_category,year_mont,Average_Price,
Average_Price - LAG(Average_Price) OVER ( PARTITION BY product_category ORDER BY year_mont) AS price_change
FROM(
SELECT product_category,
DATE_FORMAT(STR_TO_DATE(date_raw,'%d-%m-%Y'),'%Y-%m') AS year_mont,
ROUND(AVG(current_price_usd),2) AS Average_Price
FROM apple_pricing
GROUP BY product_category,year_mont
) monthly
ORDER BY product_category,year_mont;

#Q13  For each platform, rank models by total reviews_count
SELECT platform,model_name,total_reviews,
DENSE_RANK () OVER (PARTITION BY platform ORDER BY total_reviews DESC) AS reviews_rank
FROM
(SELECT platform,model_name,SUM(reviews_count)AS total_reviews
FROM apple_pricing
GROUP BY platform,model_name
)counts
ORDER BY platform,reviews_rank;

#Q14 Find the 2nd highest current_price_usd for each product_category (without using LIMIT/OFFSET — use a window function).

SELECT product_category,current_price_usd
FROM(
SELECT product_category,current_price_usd,
DENSE_RANK() OVER( PARTITION BY product_category ORDER BY current_price_usd DESC) AS rnk
FROM apple_pricing)rnked
WHERE rnk=2;

#Q15  Write a CTE that calculates average discount per platform per sale_event, then find which platform gives the best average discount overall.

WITH platform_sale_avg AS 
(SELECT platform,sale_event,ROUND(AVG(discount_pct),2) AS Average_Discount
FROM apple_pricing
GROUP BY platform,sale_event
ORDER BY platform)
SELECT platform,ROUND(AVG(Average_Discount),2) AS Platform_Avg_Discount
FROM platform_sale_avg
GROUP BY platform
ORDER BY Platform_Avg_Discount DESC;

#Q16  Find all rows where the price is higher than the average price of its own product_category (correlated subquery)

SET GLOBAL net_read_timeout = 600;
SET GLOBAL net_write_timeout = 600;
SET GLOBAL wait_timeout = 28800;
SET GLOBAL interactive_timeout = 28800;

SELECT model_name,platform,product_category
FROM apple_pricing p1
WHERE current_price_usd >
(SELECT AVG(current_price_usd) AS Average_Price
FROM apple_pricing p2
WHERE p2.product_category=p1.product_category
);

SELECT p.model_name, p.platform, p.product_category, p.current_price_usd
FROM apple_pricing p
JOIN (
    SELECT product_category, AVG(current_price_usd) AS avg_price
    FROM apple_pricing
    GROUP BY product_category
) cat_avg
ON p.product_category = cat_avg.product_category
WHERE p.current_price_usd > cat_avg.avg_price;




#Q17 Find model_names that have appeared with sale_event != 'No Sale' at least once (use EXISTS).

SELECT DISTINCT model_name
FROM apple_pricing p1
WHERE EXISTS (SELECT 1
			  FROM apple_pricing p2
              WHERE p1.model_name = p2.model_name
              AND p2.sale_event != "Regular Sale");