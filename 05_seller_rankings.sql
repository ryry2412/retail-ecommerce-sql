-- ============================================================
-- Query 05: Seller Rankings
-- Author: Riley Allen
-- Dataset: Olist Brazilian E-Commerce (Kaggle)
-- Description: Ranks sellers by revenue, order volume, and
--              average review score to identify top performers.
-- ============================================================

-- Top 10 sellers by total revenue
SELECT
    oi.seller_id,
    s.seller_state,
    COUNT(DISTINCT oi.order_id)                      AS total_orders,
    ROUND(SUM(oi.price)::NUMERIC, 2)                 AS total_revenue,
    ROUND(AVG(oi.price)::NUMERIC, 2)                 AS avg_item_price
FROM order_items oi
JOIN sellers s
    ON oi.seller_id = s.seller_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY oi.seller_id, s.seller_state
ORDER BY total_revenue DESC
LIMIT 10;


-- ============================================================
-- BONUS: Seller Performance Scorecard
-- Combines revenue rank AND review score to identify
-- truly high-performing vs. high-revenue-but-low-rated sellers
-- ============================================================

WITH seller_stats AS (
    SELECT
        oi.seller_id,
        s.seller_state,
        COUNT(DISTINCT oi.order_id)                  AS total_orders,
        ROUND(SUM(oi.price)::NUMERIC, 2)             AS total_revenue,
        ROUND(AVG(r.review_score), 2)                AS avg_review_score
    FROM order_items oi
    JOIN sellers s
        ON oi.seller_id = s.seller_id
    JOIN orders o
        ON oi.order_id = o.order_id
    JOIN order_reviews r
        ON o.order_id = r.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY oi.seller_id, s.seller_state
    HAVING COUNT(DISTINCT oi.order_id) >= 50        -- min 50 orders for meaningful data
)
SELECT
    seller_id,
    seller_state,
    total_orders,
    total_revenue,
    avg_review_score,
    RANK() OVER (ORDER BY total_revenue DESC)        AS revenue_rank,
    RANK() OVER (ORDER BY avg_review_score DESC)     AS satisfaction_rank
FROM seller_stats
ORDER BY revenue_rank
LIMIT 20;
