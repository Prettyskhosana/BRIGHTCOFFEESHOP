-- Databricks notebook source
----Previewing dataset 

SELECT *
FROM brightcoffee.shop.bright_coffee_shop_sales;

----Total Sales by Product Type

SELECT
    product_type,
    SUM(unit_price * transaction_qty) AS total_sales
FROM brightcoffee.shop.bright_coffee_shop_sales
GROUP BY product_type
ORDER BY total_sales DESC;

----Sales by Time Bucket

SELECT
    HOUR(transaction_time) AS transaction_time_bucket,
    SUM(unit_price * transaction_qty) AS total_revenue,
    COUNT(*) AS number_of_transactions
FROM brightcoffee.shop.bright_coffee_shop_sales
GROUP BY HOUR(transaction_time)
ORDER BY transaction_time_bucket;

----Quantity Sold by Product Category

SELECT
    product_category,
    SUM(transaction_qty) AS total_quantity_sold
FROM brightcoffee.shop.bright_coffee_shop_sales
GROUP BY product_category
ORDER BY total_quantity_sold DESC;

----Top 10 Best-Selling Products

SELECT
    product_detail,
    SUM(transaction_qty) AS quantity_sold
FROM brightcoffee.shop.bright_coffee_shop_sales
GROUP BY product_detail
ORDER BY quantity_sold DESC
LIMIT 10;

----Revenue by Store Location

SELECT
    store_location,
    SUM(unit_price * transaction_qty) AS total_revenue
FROM brightcoffee.shop.bright_coffee_shop_sales
GROUP BY store_location
ORDER BY total_revenue DESC;

----Average Transaction Value by Product Type

SELECT
    product_type,
    AVG(unit_price * transaction_qty) AS average_transaction_value
FROM brightcoffee.shop.bright_coffee_shop_sales
GROUP BY product_type
ORDER BY average_transaction_value DESC;

----Peak Trading Periods

SELECT
    HOUR(transaction_time) AS transaction_time_bucket,
    COUNT(*) AS transaction_count,
    SUM(unit_price * transaction_qty) AS revenue
FROM brightcoffee.shop.bright_coffee_shop_sales
GROUP BY HOUR(transaction_time)
ORDER BY revenue DESC;

----Extract Month

SELECT
    MONTH(transaction_date) AS sales_month
FROM brightcoffee.shop.bright_coffee_shop_sales;

----Extract Day of Week

SELECT
DATE_FORMAT(transaction_date, 'EEEE') AS day_name
FROM brightcoffee.shop.bright_coffee_shop_sales;

----Weekend vs Weekday Analysis

SELECT
    CASE
        WHEN DAYOFWEEK(transaction_date) IN (1,7)
            THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    SUM(unit_price * transaction_qty) AS revenue
FROM brightcoffee.shop.bright_coffee_shop_sales
GROUP BY day_type;


------------------------------------------------------------------------------------------------------------------------------------------------------

---FINAL BIG QUERY WITH ALL NEW COLUMNS

CREATE OR REPLACE TEMP VIEW bright_coffee_shop_sales_transformed AS

SELECT
    *,  -- Includes all original columns

    -- Clean unit_price
    CAST(REPLACE(unit_price, ',', '.') AS DOUBLE) AS clean_unit_price,

    -- Create total_amount (this is your revenue/sales amount)
    CAST(REPLACE(unit_price, ',', '.') AS DOUBLE) * transaction_qty
        AS total_amount,

    -- Create 30-minute time bucket
    CONCAT(
        LPAD(HOUR(transaction_time), 2, '0'),
        ':',
        CASE
            WHEN MINUTE(transaction_time) < 30 THEN '00'
            ELSE '30'
        END
    ) AS transaction_time_bucket,

    -- Additional useful columns
    YEAR(transaction_date) AS sales_year,
    MONTH(transaction_date) AS sales_month,
    DATE_FORMAT(transaction_date, 'MMMM') AS month_name,
    DATE_FORMAT(transaction_date, 'EEEE') AS day_name,
    HOUR(transaction_time) AS transaction_hour,

    CASE
        WHEN DAYOFWEEK(transaction_date) IN (1, 7)
            THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,

    CASE
        WHEN HOUR(transaction_time) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN HOUR(transaction_time) BETWEEN 12 AND 16 THEN 'Afternoon'
        WHEN HOUR(transaction_time) BETWEEN 17 AND 20 THEN 'Evening'
        ELSE 'Night'
    END AS part_of_day

FROM brightcoffee.shop.bright_coffee_shop_sales;

------FINAL

SELECT *
FROM bright_coffee_shop_sales_transformed;





