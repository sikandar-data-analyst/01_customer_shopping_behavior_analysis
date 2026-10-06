-- =============================================================
--  Business Analysis using SQL Queries
-- =============================================================
-- 1. CREATING DATABASE
CREATE DATABASE customer_analysis; 
USE customer_analysis;

-- SELECTING ALL DATA FROM TABLE 
SELECT *
FROM customer_shopping;

-- FINDING HOW MANY ROWS IN TABLE
SELECT COUNT(*)
FROM customer_shopping;  -- 3900 ROWS

-- INFO ABOUT ALL COLUMNS DATA TYPES
DESCRIBE customer_shopping;

-- Q1. What is the total revenue genarated by male vs. female customers?
SELECT gender, SUM(purchase_amount) as total_revenue
FROM customer_shopping
GROUP BY gender;
-- OUTPUT :----
-- gender	total_revenue
-- Male	157890
-- Female	75191


-- Q2. Which customers used a discount but still spent more than the average purchase amount?
SELECT customer_id, purchase_amount
FROM customer_shopping
WHERE discount_applied = 'Yes' and purchase_amount >= (SELECT  AVG(purchase_amount)
 FROM customer_shopping);

-- Q3. Which are the top 5 products with the highest average review rating?
SELECT item_purchased, AVG(review_rating  ) as "Average Product Rating"
FROM customer_shopping
GROUP BY item_purchased
ORDER BY AVG(review_rating) desc
LIMIT 5;

-- Q4. Compare the average Purchase AMount between Standard and Express Shopping?
SELECT shipping_type, ROUND(AVG(purchase_amount),2)
FROM customer_shopping
WHERE shipping_type IN ('Standard', 'Express')
GROUP BY shipping_type;

-- Q5. Do subscribed customers spend more? Copare average spend and total revenue
-- between subscibers and non-subcribers.
SELECT subscription_status, COUNT(customer_id),
ROUND(AVG(purchase_amount),2) AS avg_spend,
ROUND(SUM(purchase_amount),2) AS total_revenue
FROM customer_shopping
GROUP BY subscription_status
ORDER BY total_revenue, avg_spend Desc;

-- Q6. Which 5 products have the highest percentage of purchsases with disscount applied?
SELECT item_purchased,
ROUND(
    SUM(CASE 
        WHEN discount_applied = 'Yes' THEN 1 
        ELSE 0 
    END) / COUNT(*) * 100, 2
) AS discount_rate
FROM customer_shopping
GROUP BY item_purchased
ORDER BY discount_rate DESC
LIMIT 5;

-- Q7. Segment customers into New, Returning, and Loyal based on their total
-- number of previous purchases, and show the count of each segment.

WITH customer_type AS (
SELECT customer_id, previous_purchases,
CASE 
    WHEN previous_purchases = 1 THEN 'New'
    WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
    ELSE 'Loyal'
    END AS customer_segment
FROM customer_shopping
)
    
SELECT customer_segment, COUNT(*) AS 'Number of Customers'
FROM customer_type
GROUP BY  customer_segment;

-- Q8. What are the top 3 most purchased products within each category?
WITH item_counts AS (
SELECT category, item_purchased,
COUNT(customer_id) AS total_orders,
ROW_NUMBER() OVER(PARTITION BY category ORDER BY COUNT(customer_id) DESC) AS item_rank
FROM customer_shopping
GROUP BY category, item_purchased
)

SELECT item_rank, category, item_purchased, total_orders
FROM item_counts
WHERE item_rank <= 3;

-- Q9. Are customers who are repeat buyers(more than 5 previous purchases) also likely to subscribe?
SELECT  subscription_status,
COUNT(customer_id) AS repeat_buyers
FROM customer_shopping
WHERE previous_purchases > 5
GROUP BY subscription_status;
    
-- Q10. What is the revenue countribution of each age group?
SELECT age_group, 
SUM(purchase_amount) AS total_revenue
FROM customer_shopping
GROUP BY age_group
ORDER BY total_revenue DESC;