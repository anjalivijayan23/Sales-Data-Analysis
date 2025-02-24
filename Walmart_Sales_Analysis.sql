CREATE DATABASE walmart_sales
USE walmart_sales

CREATE TABLE sales_data (
	Store INT,
    Date DATETIME,
    Weekly_sales FLOAT,
    Holiday_flag INT,
    Temperature FLOAT,
    fuel_price FLOAT,
    cpi FLOAT,
    Unemployment FLOAT
);

LOAD DATA LOCAL INFILE 'F:\Data CSVs\archive\sales_data.csv'
INTO TABLE sales_data
FIELDS TERMINATED BY ','  
ENCLOSED BY '"'  
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SHOW VARIABLES LIKE 'max_allowed_packet'
SET GLOBAL wait_timeout = 6000
SET GLOBAL net_read_timeout = 6000
SET GLOBAL sql_mode = ' '

SELECT * FROM sales_data 
SELECT COUNT(*) FROM sales_data
SELECT MIN(Date), MAX(Date) FROM sales_data

SELECT 'Store' , COUNT(*) AS Missing_values FROM sales_data 
WHERE Store IS NULL
UNION 
SELECT 'Weekly_sales' , COUNT(*) FROM sales_data 
WHERE Weekly_sales IS NULL
UNION
SELECT 'cpi' , COUNT(*) FROM sales_data 
WHERE cpi IS NULL

SET sql_safe_updates = 0

-- Filing missing data
WITH avg_sales_cte AS (
    SELECT Store, AVG(Weekly_Sales) AS avg_sales
    FROM sales_data
    WHERE Weekly_Sales IS NOT NULL
    GROUP BY Store
)
UPDATE sales_data s
JOIN avg_sales_cte a ON s.Store = a.Store
SET s.Weekly_Sales = a.avg_sales
WHERE s.Weekly_Sales IS NULL;

SELECT store, SUM(weekly_sales) AS total_sales
FROM sales_data
GROUP BY store
ORDER BY total_sales DESC

-- sales trend over time
SELECT Date, SUM(weekly_sales) AS total_sales
FROM sales_data
GROUP BY Date
ORDER BY Date

-- Impact of holidays on sales
SELECT holiday_flag, AVG(weekly_sales) AS avg_sales
From sales_data
GROUP BY holiday_flag

-- Correlation between fuel price and sales
SELECT fuel_price, AVG(weekly_sales) AS avg_sales
FROM sales_data
GROUP BY fuel_price
ORDER BY Fuel_price

SELECT unemployment, AVG(weekly_sales) AS avg_sales
FROM sales_data
GROUP BY unemployment
ORDER BY unemployment

-- monthly analysis
SELECT 
    DATE_FORMAT (Date, '%Y-%m') AS Month, 
    AVG(Unemployment) AS Avg_Unemployment, 
    SUM(Weekly_Sales) AS Total_Sales
FROM sales_data
GROUP BY Month
ORDER BY Month;

SELECT 
    Store, 
    AVG(Unemployment) AS Avg_Unemployment, 
    SUM(Weekly_Sales) AS Total_Sales
FROM sales_data
GROUP BY Store
ORDER BY Avg_Unemployment DESC;

-- Consumer Price Index vs sales
SELECT 
    CPI, 
    AVG(Weekly_Sales) AS Avg_Sales
FROM sales_data
GROUP BY CPI
ORDER BY CPI;

-- growth in sales in stores 
SELECT 
    Store, 
    DATE_FORMAT(Date, '%Y-%m') AS Month, 
    SUM(Weekly_Sales) AS Monthly_Sales
FROM sales_data
GROUP BY Store, Month
ORDER BY Store, Month;



