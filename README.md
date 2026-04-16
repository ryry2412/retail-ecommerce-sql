# 🛒 Retail E-Commerce Sales Analysis — SQL Data Exploration

**Author:** Riley Allen  
**Tools:** SQL, PostgreSQL  
**Dataset:** [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) *(Kaggle — free download, no account required)*  
**Status:** In Progress

---

## 📌 Project Overview

This project explores a real-world retail e-commerce dataset using SQL to uncover business insights around **revenue performance, customer behavior, and operational KPIs**.

The dataset contains 100,000+ orders from a Brazilian e-commerce marketplace (Olist) between 2016–2018, spanning customers, sellers, products, payments, and reviews across multiple tables — making it ideal for demonstrating real SQL skills including joins, aggregations, subqueries, and window functions.

**Business Questions This Project Answers:**
1. What is the overall revenue trend month-over-month?
2. Which product categories drive the most revenue?
3. What is the average order value (AOV) by category?
4. Which states have the highest customer concentration?
5. What percentage of orders are delivered on time vs. late?
6. How does delivery performance affect customer review scores?
7. Who are the top 10 sellers by revenue?
8. What is the customer repeat purchase rate?

---

## 📁 Repository Structure

```
retail-ecommerce-sql/
│
├── data/
│   └── README.md               # Instructions for downloading the Olist dataset
│
├── queries/
│   ├── 01_revenue_trends.sql
│   ├── 02_category_performance.sql
│   ├── 03_customer_geography.sql
│   ├── 04_delivery_performance.sql
│   ├── 05_seller_rankings.sql
│   └── 06_repeat_customers.sql
│
├── results/
│   ├── revenue_trends.csv       # Query output snapshots
│   ├── category_performance.csv
│   └── delivery_performance.csv
│
└── README.md
```

---

## 🗄️ Dataset Schema

The Olist dataset contains 9 relational tables. This project primarily uses:

| Table | Key Columns | Description |
|---|---|---|
| `orders` | order_id, customer_id, order_status, order_purchase_timestamp, order_delivered_timestamp | Master order records |
| `order_items` | order_id, product_id, seller_id, price, freight_value | Line items per order |
| `order_payments` | order_id, payment_value | Payment totals |
| `order_reviews` | order_id, review_score | Customer review scores |
| `products` | product_id, product_category_name | Product catalog |
| `customers` | customer_id, customer_state | Customer location |
| `sellers` | seller_id, seller_state | Seller location |

---

## 🔍 SQL Queries & Findings

### 1. Revenue Trend — Month Over Month

```sql
SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month,
    COUNT(DISTINCT o.order_id)                       AS total_orders,
    ROUND(SUM(p.payment_value)::NUMERIC, 2)          AS total_revenue,
    ROUND(AVG(p.payment_value)::NUMERIC, 2)          AS avg_order_value
FROM orders o
JOIN order_payments p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY order_month
ORDER BY order_month;
```

**Finding:** The total number of orders, and in turn revenue generated, saw significant increases in the months of May 2017 and November 2017 (excluding the first few months upon opening to establish a platform in the marketplace, so we will omit the data from October 2016 through December 2016). However, the overall revenue during these months was not as high as usual because the average order for these peaks was about $10 lower than the previous month, indicating that the increases in total orders may have come because of a sale or decrease in the average order value. Additionally, we can see from the data that after the substantial increase in order numbers from November 2017, other than a down month following, the company has generated stable revenue, order numbers and average order value from every month in 2018.

---

### 2. Top Revenue-Generating Product Categories

```sql
SELECT
    p.product_category_name                          AS category,
    COUNT(DISTINCT oi.order_id)                      AS total_orders,
    ROUND(SUM(oi.price)::NUMERIC, 2)                 AS total_revenue,
    ROUND(AVG(oi.price)::NUMERIC, 2)                 AS avg_item_price
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
  AND p.product_category_name IS NOT NULL
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 10;
```

**Finding:** There is nothing that stands out as an outlier in terms of revenue generation by category or price point, but the general categories that have a lower cost in comparison to other categories within the shop have higher overall numbers of sales. This is demonstrated through the amount of sales through cama mesa banho (bed, bath, and table linens), which is in the top 3 categories for total revenue generated, which is the only one in the top 5 that has an average item price below $100 ($ in Brazilian Real), meaning it made the top 5 revenue generating categories mostly off of the volume of sales. However, the total revenue generated for each category within the top 10 is relatively even, with the highest being 9.45% and the lowest being 3.61%, showing that the sales are fairly evenly distributed among the categories.

---

### 3. Customer Geographic Distribution

```sql
SELECT
    c.customer_state                                 AS state,
    COUNT(DISTINCT c.customer_id)                    AS total_customers,
    ROUND(COUNT(DISTINCT c.customer_id) * 100.0
        / SUM(COUNT(DISTINCT c.customer_id)) OVER(), 2) AS pct_of_customers
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY state
ORDER BY total_customers DESC
LIMIT 10;
```

**Finding:** From the data, we are able to see that a significant volume of the customers come from the "SP" region (Sao Paolo), with 41.98% of the total customers coming from this state alone. 2 other areas with a fairly significant percentage of customers were the "RJ" (Rio De Janeiro) at 12.80% and "MG" (Minas Gerais) at 11.77%, with no other regions making up more than 6% of the total customer base.

```sql
SELECT
    COUNT(DISTINCT order_id)                         AS total_delivered_orders,
    SUM(CASE
        WHEN order_delivered_customer_date <= order_estimated_delivery_date
        THEN 1 ELSE 0
    END)                                             AS on_time_orders,
    ROUND(SUM(CASE
        WHEN order_delivered_customer_date <= order_estimated_delivery_date
        THEN 1 ELSE 0
    END) * 100.0 / COUNT(DISTINCT order_id), 2)     AS on_time_pct,
    ROUND(AVG(
        EXTRACT(EPOCH FROM (order_delivered_customer_date
            - order_purchase_timestamp)) / 86400
    ), 1)                                            AS avg_delivery_days
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;
```

**Finding:** The key points to take away from this data is that while the total amounts of orders that arrive on time is high, at 91.89 percent, there is obvious room for improvement that would likely increase customer satisfaction. With an increase in customer satisfaction, the effects will likely have the store's customer base return to make more purchases, and for higher amounts of goods (in terms of value and quantity of goods purchased). While the logistics may take more investigating, improving both the on-time delivery percentage and the average delivery time for late orders are clear operational priorities.

```sql
SELECT
    CASE
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date
        THEN 'On Time'
        ELSE 'Late'
    END                                              AS delivery_status,
    ROUND(AVG(r.review_score), 2)                   AS avg_review_score,
    COUNT(DISTINCT o.order_id)                       AS total_orders
FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status
ORDER BY delivery_status;
```

**Finding:** As one would expect, the customer rating for their purchases when the order is late drops significantly (4.29 average rating for on-time orders in comparison to a 2.57 average rating for late deliveries). The more concerning information is that the average late delivery takes 31.4 days, which is 288% of the usual delivery time of 10.9 days. While late deliveries are inevitable, a nearly triple average delivery time will lose lots of customers who the company would look for repeat business.

---

### 6. Top 10 Sellers by Revenue

```sql
SELECT
    oi.seller_id,
    s.seller_state,
    COUNT(DISTINCT oi.order_id)                      AS total_orders,
    ROUND(SUM(oi.price)::NUMERIC, 2)                 AS total_revenue,
    ROUND(AVG(oi.price)::NUMERIC, 2)                 AS avg_item_price
FROM order_items oi
JOIN sellers s ON oi.seller_id = s.seller_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY oi.seller_id, s.seller_state
ORDER BY total_revenue DESC
LIMIT 10;
```

**Finding:** From the data set generated here, we can see that all but the second-highest revenue-generating sellers was based in "SP" (Sao Paolo), with the lone exception coming from Buenos Aires (which could be an input error or data anomaly), which aligns with the previous data showing that an extremely high level of sales and revenue generated come from Sao Paolo. The amount of revenue generated by the sales consists mostly of lower-priced items with higher volumes of total orders in comparison to more expensive items in this list. This is illustrated by the fact that only 3 of the top 10 sellers had an average item price over $200 ($ in Brazilian Real), while 5 sellers in the same list were under $125 ($ in Brazilian Real). Running an extra query to see the customer reviews of their purchases shows even more noteworthy findings; among them being that many of the top revenue generating items had relatively low satisfaction rankings, with only 3 of the top 20 items being in the top 100 satisfaction rankings. Additionally, items number 3 and 5 on the rankings had extremely low average score reviews and satisfaction rankings (relative to the other top revenue-generating items), which is a risk for customer retention.

```sql
WITH customer_order_counts AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS order_count
    FROM orders
    WHERE order_status = 'delivered'
    GROUP BY customer_id
)
SELECT
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END)   AS repeat_customers,
    COUNT(*)                                             AS total_customers,
    ROUND(SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2)                          AS repeat_rate_pct
FROM customer_order_counts;
```

**Finding:** An extremely concerning outcome is shown in this data set, with ZERO repeat customers, meaning there is a disconnect between the products and customer retention. There are plausible explanations behind this, with one being that because each order has a unique customer id attached to it, a customer that is returning to purchase a new item may be mistakenly identified as a new customer, or customers are using a different account for each of their orders. However, it would be prudent to not only investigate the methodology of tracking customer identification, but to also probe the customer base and see whether the service, products or delivery is dissuading them from purchasing again, or if the need for a replacement or other products hasn't arisen yet.

There are several key insights that we can gather from the datasets we created, with several being encouraging and others showing room for improvement. Among the positives were the steady rate of average number of purchases per month, average value of purchases, overall distribution of products being sold, and overall customer satisfaction with their purchases when the delivery is on time (along with a relatively high amount of on-time deliveries being made). However, several of the concerning indicators include: the current calculated lack of repeat customers, the disparity between average delivery times for on-time and late deliveries, low satisfaction ratings for the top revenue-generating products relative to the total offerings in the store, and the low raw customer ratings for several of the top revenue-generating items. One can speculate that there are a steady amount of customers who are trying out the services and products from the company every month, but low customer ratings of the items being purchased as well as complaints about late deliveries have damaged the company's reputation among potential new customers. Additionally, with the current data showing repeat customers at a zero, we are unable to discern whether this is because the methodology for tracking customer orders is flawed or because the customers who are receiving their orders are unhappy overall with their purchases and choosing not to return. The first order of business would be to establish a more conclusive and clear protocol to record customer accounts and purchases (with this being applied to past data to widen the scope of investigation) so that we can get a better idea of how the company is doing in regards to repeat customers. Recommended next steps to improve customer retention, revenue growth, and overall number of orders include: incentivizing repeat purchases (a discount for the next purchase as a preliminary idea), improving the quality of products being sold, cleaning up the delivery process (both percentage of on-time purchases and especially the average delivery time for late deliveries) and expanding the consumer base from a geographical perspective. In conclusion, the positive metrics show that the company is generating a steady stream of revenue, but this could increase substantially with an improvement to customer retention and overall satisfaction with the goods and services being purchased.

---

## ⚙️ How to Reproduce This Analysis

### 1. Download the Dataset
- Go to [Kaggle — Brazilian E-Commerce Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- Download and unzip — you'll get 9 CSV files

### 2. Set Up PostgreSQL
```bash
# Create a new database
createdb olist_ecommerce

# Connect
psql -d olist_ecommerce
```

### 3. Create Tables & Import Data
```sql
-- Example: create and load the orders table
CREATE TABLE orders (
    order_id                        VARCHAR PRIMARY KEY,
    customer_id                     VARCHAR,
    order_status                    VARCHAR,
    order_purchase_timestamp        TIMESTAMP,
    order_approved_at               TIMESTAMP,
    order_delivered_carrier_date    TIMESTAMP,
    order_delivered_customer_date   TIMESTAMP,
    order_estimated_delivery_date   TIMESTAMP
);

\COPY orders FROM 'olist_orders_dataset.csv' CSV HEADER;
```
*(Repeat for each table — full schema setup script coming soon)*

### 4. Run the Queries
Open any `.sql` file in the `queries/` folder and run against your local `olist_ecommerce` database.

---

## 🔗 Related Projects

- [Revenue Growth Models — Lariat Rent-A-Car](https://github.com/ryry2412/Thinkful/blob/main/Capstone%201%20(version%201).xlsb.xlsx)
- [Fuel Efficiency Statistical Analysis](https://github.com/ryry2412/Thinkful/blob/main/DA_-_epa-fuel-economy%20excel%20(version%201).xlsx)
- *Python EDA + A/B Test — coming soon*
- *Data Cleaning Pipeline — coming soon*
- *Dashboard Storytelling — coming soon*

---

## 👤 About the Author

**Riley Allen** — Data Analyst | Columbus, OH  
[LinkedIn](https://www.linkedin.com/in/rileyallen2412) · [GitHub](https://github.com/ryry2412) · rileyallen2412@gmail.com
