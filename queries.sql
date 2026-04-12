-- ============================================================
-- E-Commerce Customer Churn Analysis — SQL Queries
-- Dataset: ecommerce_customer_churn_dataset (50,000 customers)
-- Database: SQLite (ecommerce.db)
-- ============================================================


-- ============================================================
-- Q1: What is the overall churn rate in our customer base?
-- ============================================================
SELECT
    ROUND(SUM(Churned) * 100.0 / COUNT(*), 2) AS churn_rate_pct,
    SUM(Churned)              AS total_churned,
    COUNT(*) - SUM(Churned)   AS total_active,
    COUNT(*)                  AS total_customers
FROM customers;


-- ============================================================
-- Q2: How does churn rate vary by country?
-- ============================================================
SELECT
    Country,
    COUNT(*)                                        AS total_customers,
    SUM(Churned)                                    AS churned,
    ROUND(SUM(Churned) * 100.0 / COUNT(*), 2)       AS churn_rate_pct
FROM customers
GROUP BY Country
ORDER BY churn_rate_pct DESC;


-- ============================================================
-- Q3: Do customers with higher cart abandonment rates churn more?
-- ============================================================
SELECT
    CASE
        WHEN Cart_Abandonment_Rate < 25              THEN 'Low (<25%)'
        WHEN Cart_Abandonment_Rate BETWEEN 25 AND 50 THEN 'Medium (25-50%)'
        WHEN Cart_Abandonment_Rate BETWEEN 50 AND 75 THEN 'High (50-75%)'
        ELSE                                              'Very High (>75%)'
    END AS abandonment_group,
    COUNT(*)                                        AS total_customers,
    ROUND(SUM(Churned) * 100.0 / COUNT(*), 2)       AS churn_rate_pct
FROM customers
GROUP BY abandonment_group
ORDER BY churn_rate_pct DESC;


-- ============================================================
-- Q4: Does membership seniority protect against churn?
-- ============================================================
SELECT
    CASE
        WHEN Membership_Years < 1                   THEN '< 1 year'
        WHEN Membership_Years BETWEEN 1 AND 3       THEN '1-3 years'
        WHEN Membership_Years BETWEEN 3 AND 5       THEN '3-5 years'
        ELSE                                             '> 5 years'
    END AS membership_group,
    COUNT(*)                                        AS total_customers,
    ROUND(SUM(Churned) * 100.0 / COUNT(*), 2)       AS churn_rate_pct,
    ROUND(AVG(Lifetime_Value), 2)                   AS avg_lifetime_value
FROM customers
GROUP BY membership_group
ORDER BY churn_rate_pct DESC;


-- ============================================================
-- Q5: What is the average order value of churned vs. active customers?
-- ============================================================
SELECT
    CASE WHEN Churned = 1 THEN 'Churned' ELSE 'Active' END AS status,
    ROUND(AVG(Average_Order_Value), 2)              AS avg_order_value,
    ROUND(AVG(Total_Purchases), 2)                  AS avg_purchases,
    ROUND(AVG(Lifetime_Value), 2)                   AS avg_lifetime_value
FROM customers
GROUP BY Churned;


-- ============================================================
-- Q6: Does customer service call frequency predict churn?
-- ============================================================
SELECT
    CAST(Customer_Service_Calls AS INT)             AS calls,
    COUNT(*)                                        AS total_customers,
    ROUND(SUM(Churned) * 100.0 / COUNT(*), 2)       AS churn_rate_pct
FROM customers
GROUP BY calls
ORDER BY calls;


-- ============================================================
-- Q7: Do high-discount users churn more?
-- ============================================================
SELECT
    CASE
        WHEN Discount_Usage_Rate < 25               THEN 'Low (<25%)'
        WHEN Discount_Usage_Rate BETWEEN 25 AND 50  THEN 'Medium (25-50%)'
        WHEN Discount_Usage_Rate BETWEEN 50 AND 75  THEN 'High (50-75%)'
        ELSE                                             'Very High (>75%)'
    END AS discount_group,
    COUNT(*)                                        AS total_customers,
    ROUND(SUM(Churned) * 100.0 / COUNT(*), 2)       AS churn_rate_pct,
    ROUND(AVG(Average_Order_Value), 2)              AS avg_order_value
FROM customers
GROUP BY discount_group
ORDER BY churn_rate_pct DESC;


-- ============================================================
-- Q8: How does login frequency impact churn?
-- ============================================================
SELECT
    CASE
        WHEN Login_Frequency < 5                    THEN 'Low (<5)'
        WHEN Login_Frequency BETWEEN 5 AND 15       THEN 'Medium (5-15)'
        WHEN Login_Frequency BETWEEN 15 AND 25      THEN 'High (15-25)'
        ELSE                                             'Very High (>25)'
    END AS login_group,
    COUNT(*)                                        AS total_customers,
    ROUND(SUM(Churned) * 100.0 / COUNT(*), 2)       AS churn_rate_pct
FROM customers
GROUP BY login_group
ORDER BY churn_rate_pct DESC;


-- ============================================================
-- Q9: Which signup quarter has the highest long-term churn?
-- ============================================================
SELECT
    Signup_Quarter,
    COUNT(*)                                        AS total_customers,
    SUM(Churned)                                    AS churned,
    ROUND(SUM(Churned) * 100.0 / COUNT(*), 2)       AS churn_rate_pct
FROM customers
GROUP BY Signup_Quarter
ORDER BY churn_rate_pct DESC;


-- ============================================================
-- Q10: Who are the top 10 highest-value customers at risk of churning?
-- (Active customers showing multiple churn risk signals)
-- ============================================================
SELECT
    customer_id,
    Country,
    Age,
    Lifetime_Value,
    Total_Purchases,
    Customer_Service_Calls,
    Cart_Abandonment_Rate,
    Days_Since_Last_Purchase
FROM customers
WHERE Churned = 0
    AND Days_Since_Last_Purchase > 60
    AND Customer_Service_Calls >= 5
    AND Cart_Abandonment_Rate > 60
ORDER BY Lifetime_Value DESC
LIMIT 10;
