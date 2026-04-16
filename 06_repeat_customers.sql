-- ============================================================
-- Query 06: Repeat Customer Rate
-- Author: Riley Allen
-- Dataset: Olist Brazilian E-Commerce (Kaggle)
-- Description: Calculates customer retention metrics —
--              what % of customers placed more than one order?
-- ============================================================

-- Overall repeat purchase rate
WITH customer_order_counts AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id)                             AS order_count
    FROM orders
    WHERE order_status = 'delivered'
    GROUP BY customer_id
)
SELECT
    COUNT(*)                                                 AS total_customers,
    SUM(CASE WHEN order_count = 1  THEN 1 ELSE 0 END)       AS one_time_customers,
    SUM(CASE WHEN order_count > 1  THEN 1 ELSE 0 END)       AS repeat_customers,
    ROUND(SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2)                              AS repeat_rate_pct,
    ROUND(AVG(order_count), 2)                              AS avg_orders_per_customer
FROM customer_order_counts;


-- ============================================================
-- BONUS: Order Frequency Distribution
-- Shows breakdown of how many orders customers place
-- ============================================================

WITH customer_order_counts AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id)                             AS order_count
    FROM orders
    WHERE order_status = 'delivered'
    GROUP BY customer_id
)
SELECT
    order_count                                              AS orders_placed,
    COUNT(*)                                                 AS number_of_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2)       AS pct_of_customers
FROM customer_order_counts
GROUP BY order_count
ORDER BY order_count;


-- ============================================================
-- BONUS: Revenue Contribution — One-Time vs. Repeat Customers
-- Shows how much revenue each segment generates
-- ============================================================

WITH customer_segments AS (
    SELECT
        o.customer_id,
        COUNT(DISTINCT o.order_id)                           AS order_count,
        ROUND(SUM(p.payment_value)::NUMERIC, 2)              AS total_spent
    FROM orders o
    JOIN order_payments p
        ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.customer_id
)
SELECT
    CASE
        WHEN order_count = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END                                                      AS customer_segment,
    COUNT(*)                                                 AS total_customers,
    ROUND(SUM(total_spent)::NUMERIC, 2)                     AS total_revenue,
    ROUND(AVG(total_spent)::NUMERIC, 2)                     AS avg_revenue_per_customer,
    ROUND(SUM(total_spent) * 100.0
        / SUM(SUM(total_spent)) OVER(), 2)                  AS pct_of_total_revenue
FROM customer_segments
GROUP BY customer_segment
ORDER BY total_revenue DESC;
