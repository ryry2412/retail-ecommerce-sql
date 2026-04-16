-- ============================================================
-- Query 01: Revenue Trends — Month Over Month
-- Author: Riley Allen
-- Dataset: Olist Brazilian E-Commerce (Kaggle)
-- Description: Tracks total orders, revenue, and average order
--              value (AOV) per month for delivered orders.
-- ============================================================

SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month,
    COUNT(DISTINCT o.order_id)                       AS total_orders,
    ROUND(SUM(p.payment_value)::NUMERIC, 2)          AS total_revenue,
    ROUND(AVG(p.payment_value)::NUMERIC, 2)          AS avg_order_value
FROM orders o
JOIN order_payments p
    ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY order_month
ORDER BY order_month;


-- ============================================================
-- BONUS: Month-over-Month Revenue Growth Rate (%)
-- Uses a window function to calculate % change vs. prior month
-- ============================================================

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month,
        ROUND(SUM(p.payment_value)::NUMERIC, 2)         AS total_revenue
    FROM orders o
    JOIN order_payments p
        ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY order_month
)
SELECT
    order_month,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY order_month)   AS prior_month_revenue,
    ROUND(
        (total_revenue - LAG(total_revenue) OVER (ORDER BY order_month))
        * 100.0
        / NULLIF(LAG(total_revenue) OVER (ORDER BY order_month), 0),
    2)                                               AS mom_growth_pct
FROM monthly_revenue
ORDER BY order_month;
