-- ============================================================
-- Query 03: Customer Geographic Distribution
-- Author: Riley Allen
-- Dataset: Olist Brazilian E-Commerce (Kaggle)
-- Description: Identifies which states drive the most customers
--              and revenue — useful for regional strategy.
-- ============================================================

-- Customer concentration by state
SELECT
    c.customer_state                                         AS state,
    COUNT(DISTINCT c.customer_id)                            AS total_customers,
    ROUND(COUNT(DISTINCT c.customer_id) * 100.0
        / SUM(COUNT(DISTINCT c.customer_id)) OVER(), 2)     AS pct_of_customers
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY state
ORDER BY total_customers DESC
LIMIT 10;


-- ============================================================
-- BONUS: Revenue by State
-- Combines customer location with revenue to identify
-- highest-value geographic markets
-- ============================================================

SELECT
    c.customer_state                                         AS state,
    COUNT(DISTINCT o.order_id)                               AS total_orders,
    ROUND(SUM(p.payment_value)::NUMERIC, 2)                  AS total_revenue,
    ROUND(AVG(p.payment_value)::NUMERIC, 2)                  AS avg_order_value
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_payments p
    ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY state
ORDER BY total_revenue DESC
LIMIT 10;
