-- How many orders are in each order status?

select * from orders;
select order_status, count(*) as total_orders,
ROUND(COUNT(*) * 100.0/ (select COUNT(*) from orders), 2) as pct
from orders 
group by order_status 
order by total_orders DESC ;


-- "How many orders were placed each month?"

select
	to_char( order_purchase_timestamp::timestamp, 'MM-YYYY') as order_month,
	COUNT(*) as total_orders
from orders 
group by to_char( order_purchase_timestamp::timestamp, 'MM-YYYY')
order by MIN(order_purchase_timestamp::timestamp);

--Month ON Month Revenue Trend

with monthly_revenue as
(
	select  
		order_month_ts as month,
		sum(total_payment) as revenue
	from clean_orders 
	group by order_month_ts
	order by order_month_ts
),
revenue_with_previous as
(
	select 
		month,
		revenue,
		LAG(revenue) over (order by month) as previous_revenue
	from monthly_revenue
)
select 
	month,
	revenue,
	previous_revenue,
	ROUND(( 100.0*(revenue - previous_revenue)
	/ nullif(previous_revenue, 0)
	)::numeric,
	2) as mom_growth_pct
from revenue_with_previous;


-- Top category by revenue

select p.category_en, ROUND(SUM(oi.price + oi.freight_value)) as tot_revenue
from clean_orders c 
join order_items oi on c.order_id = oi.order_id
join products_en p on oi.product_id = p.product_id
group by p.category_en
order by tot_revenue DESC;


-- Which product categories sell the most items?

select p.category_en, count(oi.product_id) as sold_items
from clean_orders c
join order_items oi on c.order_id = oi.order_id 
join products_en p on oi.product_id = p.product_id 
group by p.category_en 
order by sold_items desc;


-- EXECUTIVE KPI QUERIES

SELECT 
    COUNT(order_id) AS total_orders
FROM clean_orders;


SELECT 
    ROUND(SUM(payment_value)::numeric,2) AS total_revenue
FROM order_payments;

SELECT 
    COUNT(DISTINCT customer_unique_id) AS total_customers
FROM customers;


select ROUND(AVG(total_payment):: NUMERIC,2) as AOV
from clean_orders;



