-- ============================================================
-- Query 02: Category Performance
-- Author: Riley Allen
-- Dataset: Olist Brazilian E-Commerce (Kaggle)
-- Description: Ranks product categories by revenue, order
--              volume, and average item price.
-- ============================================================

-- Top 10 categories by total revenue
SELECT
    p.product_category_name                          AS category,
    COUNT(DISTINCT oi.order_id)                      AS total_orders,
    ROUND(SUM(oi.price)::NUMERIC, 2)                 AS total_revenue,
    ROUND(AVG(oi.price)::NUMERIC, 2)                 AS avg_item_price,
    ROUND(SUM(oi.price) * 100.0
        / SUM(SUM(oi.price)) OVER (), 2)             AS pct_of_total_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
  AND p.product_category_name IS NOT NULL
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 10;


-- ============================================================
-- BONUS: Average Order Value (AOV) by Category
-- Useful KPI — higher AOV categories = higher revenue per transaction
-- ============================================================

SELECT
    p.product_category_name                          AS category,
    COUNT(DISTINCT oi.order_id)                      AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value)::NUMERIC, 2) AS total_revenue_incl_freight,
    ROUND(AVG(oi.price + oi.freight_value)::NUMERIC, 2) AS avg_order_value
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
  AND p.product_category_name IS NOT NULL
GROUP BY category
HAVING COUNT(DISTINCT oi.order_id) >= 100    -- filter low-volume categories
ORDER BY avg_order_value DESC
LIMIT 10;
