create table revenue_transactions(order_id int,
customer_id varchar(50),
plan varchar(50),
list_price int,
discount_pct int,
final_price int,
quantity int,
payment_status varchar(50),
refund_flag varchar(50),
order_date date,
region varchar(50)
)
------------ Expected vs actual revenue per order
SELECT
    order_id,
    customer_id,
    plan,
    list_price * quantity AS expected_revenue,
    final_price * quantity AS actual_revenue,
    (list_price - final_price) * quantity AS revenue_leakage
FROM revenue_transactions
WHERE (list_price * quantity) <> (final_price * quantity);
----------- Total revenue lost due to discounts(by plan & region)
SELECT
    plan,
    region,
    SUM((list_price - final_price) * quantity) AS total_discount_loss
FROM revenue_transactions
WHERE payment_status = 'Success'
GROUP BY plan, region
ORDER BY total_discount_loss DESC;
---------revenue leakage due to failed payments
SELECT
    SUM(list_price * quantity) AS potential_revenue_lost
FROM revenue_transactions
WHERE payment_status = 'Failed';
---------------- refunded revenue & % of total revenue
WITH total_revenue AS (
    SELECT SUM(final_price * quantity) AS total_rev
    FROM revenue_transactions
    WHERE payment_status = 'Success'
)
SELECT
    SUM(final_price * quantity) AS refunded_revenue,
    ROUND(
        SUM(final_price * quantity) * 100.0 / 
        (SELECT total_rev FROM total_revenue),
        2
    ) AS refund_percentage
FROM revenue_transactions
WHERE refund_flag = 'Yes';

--PRICING & OPTIMIZATION
-------Average discount % by plan + flag high discount plans
SELECT
    plan,
    ROUND(AVG(discount_pct), 2) AS avg_discount_pct,
    CASE
        WHEN AVG(discount_pct) > 25 THEN 'High Discount Risk'
        ELSE 'Normal'
    END AS discount_flag
FROM revenue_transactions
GROUP BY plan
ORDER BY avg_discount_pct DESC;
---------Ineffective Discounting (discount!=higher quantity)
SELECT
    order_id,
    customer_id,
    plan,
    discount_pct,
    quantity
FROM revenue_transactions
WHERE discount_pct > 0
  AND quantity = 1;
-----------rank regions by discount-to revenue ration(window function)
WITH region_metrics AS (
    SELECT
        region,
        SUM((list_price - final_price) * quantity) AS discount_loss,
        SUM(final_price * quantity) AS actual_revenue
    FROM revenue_transactions
    GROUP BY region
)
SELECT
    region,
    ROUND(discount_loss * 1.0 / actual_revenue, 3) AS discount_revenue_ratio,
    RANK() OVER (ORDER BY discount_loss * 1.0 / actual_revenue DESC) AS region_rank
FROM region_metrics;
--------------Customer paying below plan average
WITH plan_avg AS (
    SELECT
        plan,
        AVG(final_price) AS avg_plan_price
    FROM revenue_transactions
    GROUP BY plan
)
SELECT
    r.customer_id,
    r.plan,
    ROUND(AVG(r.final_price), 2) AS customer_avg_price
FROM revenue_transactions r
JOIN plan_avg p
  ON r.plan = p.plan
GROUP BY r.customer_id, r.plan, p.avg_plan_price
HAVING AVG(r.final_price) < p.avg_plan_price;
----------running revenue leakage over time
SELECT
    order_date,
    SUM((list_price - final_price) * quantity) AS daily_leakage,
    SUM(SUM((list_price - final_price) * quantity))
        OVER (ORDER BY order_date) AS cumulative_leakage
FROM revenue_transactions
GROUP BY order_date
ORDER BY order_date;
----------- pareto:top 20% costumers causing 80% leakage
WITH customer_leakage AS (
    SELECT
        customer_id,
        SUM((list_price - final_price) * quantity) AS total_leakage
    FROM revenue_transactions
    GROUP BY customer_id
),
ranked AS (
    SELECT
        customer_id,
        total_leakage,
        SUM(total_leakage) OVER () AS overall_leakage,
        SUM(total_leakage) OVER (ORDER BY total_leakage DESC) AS running_leakage
    FROM customer_leakage
)
SELECT *
FROM ranked
WHERE running_leakage <= 0.8 * overall_leakage;
--------pricing anomalies(same plan & region,diferent prices)
SELECT
    plan,
    region,
    COUNT(DISTINCT final_price) AS price_variants
FROM revenue_transactions
GROUP BY plan, region
HAVING COUNT(DISTINCT final_price) > 1;
---------discount distribution(median,avg,max)
SELECT
    plan,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY discount_pct) AS median_discount,
    ROUND(AVG(discount_pct), 2) AS avg_discount,
    MAX(discount_pct) AS max_discount
FROM revenue_transactions
GROUP BY plan;
---------------leakage severity flag
SELECT
    order_id,
    customer_id,
    CASE
        WHEN refund_flag = 'Yes'
          OR payment_status = 'Failed'
          OR discount_pct > 40 THEN 'High'
        WHEN discount_pct BETWEEN 20 AND 40 THEN 'Medium'
        ELSE 'Low'
    END AS leakage_severity
FROM revenue_transactions;
---------month-over-month leakage trend & growth rate
WITH monthly_leakage AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        SUM((list_price - final_price) * quantity) AS leakage
    FROM revenue_transactions
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT
    month,
    leakage,
    ROUND(
        (leakage - LAG(leakage) OVER (ORDER BY month)) * 100.0 /
        LAG(leakage) OVER (ORDER BY month),
        2
    ) AS mom_growth_pct
FROM monthly_leakage;