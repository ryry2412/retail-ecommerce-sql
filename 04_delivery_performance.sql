-- ============================================================
-- Query 04: Delivery Performance KPIs
-- Author: Riley Allen
-- Dataset: Olist Brazilian E-Commerce (Kaggle)
-- Description: Measures on-time delivery rate, average delivery
--              time, and impact of delivery performance on
--              customer satisfaction (review scores).
-- ============================================================

-- Overall delivery performance KPI
SELECT
    COUNT(DISTINCT order_id)                                 AS total_delivered_orders,
    SUM(CASE
        WHEN order_delivered_customer_date <= order_estimated_delivery_date
        THEN 1 ELSE 0
    END)                                                     AS on_time_orders,
    ROUND(SUM(CASE
        WHEN order_delivered_customer_date <= order_estimated_delivery_date
        THEN 1 ELSE 0
    END) * 100.0 / COUNT(DISTINCT order_id), 2)             AS on_time_pct,
    ROUND(AVG(
        EXTRACT(EPOCH FROM (order_delivered_customer_date
            - order_purchase_timestamp)) / 86400
    ), 1)                                                    AS avg_delivery_days
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;


-- ============================================================
-- Delivery Performance vs. Customer Review Score
-- Key insight: does late delivery hurt ratings?
-- ============================================================

SELECT
    CASE
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date
        THEN 'On Time'
        ELSE 'Late'
    END                                                      AS delivery_status,
    COUNT(DISTINCT o.order_id)                               AS total_orders,
    ROUND(AVG(r.review_score), 2)                            AS avg_review_score,
    ROUND(AVG(
        EXTRACT(EPOCH FROM (o.order_delivered_customer_date
            - o.order_purchase_timestamp)) / 86400
    ), 1)                                                    AS avg_delivery_days
FROM orders o
JOIN order_reviews r
    ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status
ORDER BY delivery_status;


-- ============================================================
-- BONUS: Days Late Distribution
-- Buckets late orders to see how late they actually were
-- ============================================================

SELECT
    CASE
        WHEN order_delivered_customer_date <= order_estimated_delivery_date
            THEN '0 - On Time'
        WHEN order_delivered_customer_date <= order_estimated_delivery_date + INTERVAL '3 days'
            THEN '1 - 1 to 3 days late'
        WHEN order_delivered_customer_date <= order_estimated_delivery_date + INTERVAL '7 days'
            THEN '2 - 4 to 7 days late'
        ELSE '3 - 8+ days late'
    END                                                      AS lateness_bucket,
    COUNT(DISTINCT order_id)                                 AS total_orders,
    ROUND(COUNT(DISTINCT order_id) * 100.0
        / SUM(COUNT(DISTINCT order_id)) OVER(), 2)          AS pct_of_orders
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
GROUP BY lateness_bucket
ORDER BY lateness_bucket;
