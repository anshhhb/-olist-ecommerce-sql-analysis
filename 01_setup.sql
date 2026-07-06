-- Filters out cancelled/unavailable orders and undelivered orders

create or replace view clean_orders as
select 
	o.order_id,
	o.customer_id,
	o.order_status,
	o.order_purchase_timestamp,
	o.order_delivered_customer_date,
	o.order_estimated_delivery_date,
	extract (year from o.order_purchase_timestamp)::INT as order_year,
	extract (month from o.order_purchase_timestamp)::INT as order_month,
	DATE_TRUNC('month', o.order_purchase_timestamp) as order_month_ts,
	SUM(p.payment_value) as total_payment,
	MAX(p.payment_type) as primary_payment_type
from orders o
join order_payments p on o.order_id = p.order_id
where
	o.order_status not in ('canceled', 'unavailable')
	and o.order_delivered_customer_date is not null
	-- Exclude last 2 months (data cutoff artifact)
	and o.order_purchase_timestamp < '2018-09-01'
group by 1,2,3,4,5,6,7,8,9;
	


-- ── ADD ENGLISH CATEGORY NAMES to products ──
create or replace view products_en as
select 
	p.*,
	COALESCE(t.product_category_name_english, 'unknown') as category_en
from products p
left join category_translation t
	on p.product_category_name = t.product_category_name;




-- ── DATE RANGE (important: dataset ends Oct 2018) ──
select
	MIN(order_purchase_timestamp) as earliest_order,
	MAX(order_purchase_timestamp) as latest_order
from orders;


-- ── DUPLICATE PAYMENTS check ──
select 
	order_id,
	COUNT(*) as payment_rows
from order_payments
group by 1
having count(*) > 1
limit 10;



-- Clean Orders Row Count Verification


SELECT 
	COUNT(*) AS total_clean_orders
FROM clean_orders;